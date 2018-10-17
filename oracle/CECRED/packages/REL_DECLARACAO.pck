CREATE OR REPLACE PACKAGE CECRED.REL_DECLARACAO AS
   /*
   Programa: REL_DECLARACAO                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Devolver as informações necessárias para o Relatório Declaração de obrigação fiscal no exterior

   Alteracoes:

   */

  --Busca as informações para o relatório de Declaração
  PROCEDURE pc_busca_dados_declaracao(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Número da conta
                                     ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  PROCEDURE pc_busca_cidade(pr_cdcooper IN crapage.cdcooper%TYPE         --> Cd cooperativa
                           ,pr_nrdconta IN crapage.cdagenci%TYPE         --> Numero da conta
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo
END REL_DECLARACAO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.REL_DECLARACAO AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: REL_DECLARACAO                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Devolver as informações necessárias para o Relatório Declaração de obrigação fiscal no exterior

   Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

  --Busca as informações para o relatório de Declaração
  PROCEDURE pc_busca_dados_declaracao(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Número da conta
                                     ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_declaracao
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Busca as informações para o relatório de Declaração

   Alteracoes:

    ............................................................................. */
    CURSOR cr_declaracao (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT a.nmpessoa
          ,d.dscidade
          ,d.cdestado                    dsestado
          ,gene0002.fn_mask_cep(c.nrcep) dscodigo_postal
          ,e.nmpais                      nmpais_reportavel
          ,c.nmlogradouro||', '||c.nrlogradouro||DECODE(NVL(c.dscomplemento,' '),' ',NULL,' - '||c.dscomplemento) dsendereco
          ,CASE
           WHEN NVL(b.inobrigacao_exterior,'N') = 'S'
           THEN
             CASE
             WHEN e.inacordo IS NOT NULL
             THEN
               'S'
             ELSE
               'N'
             END
           WHEN (NVL(b.inobrigacao_exterior,'N') = 'N' AND NVL(b.insocio_obrigacao,'N') = 'S')
            THEN
              'S'
            ELSE
              'N'
            END inreportavel
          ,a.tppessoa
          ,NVL(b.inobrigacao_exterior,'N') inobrigacao_exterior
      FROM tbcadast_pessoa a
          ,tbcadast_pessoa_estrangeira b
          ,tbcadast_pessoa_endereco c
          ,crapmun d
          ,crapnac e
     WHERE a.nrcpfcgc     = pr_nrcpfcgc
       AND b.idpessoa     = a.idpessoa
       AND c.idpessoa     = a.idpessoa
       AND c.tpendereco   = DECODE(a.tppessoa,1,10,9)
       AND d.idcidade     = c.idcidade
       AND e.cdnacion     = b.cdpais;

    CURSOR cr_pais_socio(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT e.nmpais nmpais_socio
      FROM crapavt a
          ,crapass b
          ,tbcadast_pessoa c
          ,tbcadast_pessoa_estrangeira d
          ,crapnac e
     WHERE b.nrcpfcgc  = pr_nrcpfcgc
       AND b.cdsitdct <> 4
       AND b.dtdemiss is null
       AND a.cdcooper  = b.CDCOOPER
       AND a.nrdconta  = b.NRDCONTA
       AND a.tpctrato  = 6
       AND a.dsproftl <> 'PROCURADOR'
       AND a.persocio >= 10
       AND c.nrcpfcgc  = a.nrcpfcgc
       AND d.idpessoa  = c.idpessoa
       AND d.inobrigacao_exterior = 'S'
       AND e.cdnacion  = d.cdpais
    UNION
    SELECT e.nmpais nmpais_socio
      FROM crapepa a
          ,crapass b
          ,tbcadast_pessoa c
          ,tbcadast_pessoa_estrangeira d
          ,crapnac e
     WHERE b.nrcpfcgc  = pr_nrcpfcgc
       AND b.cdsitdct <> 4
       AND b.dtdemiss is null
       AND a.cdcooper  = b.CDCOOPER
       AND a.nrdconta  = b.NRDCONTA
       AND a.persocio >= 10
       AND c.nrcpfcgc  = a.nrdocsoc 
       AND d.idpessoa  = c.idpessoa
       AND d.inobrigacao_exterior = 'S'
       AND e.cdnacion  = d.cdpais;
    rw_pais_socio cr_pais_socio%rowtype;

    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;

    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;

    --Variaveis de trabalho
    vr_inexiste_declaracao NUMBER;

  BEGIN -- Inicio pc_busca_dados_declaracao



    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'REL_DECLARACAO'
                              ,pr_action => null);



    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'rel_declaracao',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    vr_inexiste_declaracao := 0;
    FOR rw_declaracao IN cr_declaracao(pr_nrcpfcgc => pr_nrcpfcgc) LOOP
      vr_inexiste_declaracao := 1;

      -- Caso a pessoa não tem obrigação no exterior e for uma PJ
      -- Deverá ser pego o país de algum sócio para ser apresentado na Declaração
      IF  rw_declaracao.inobrigacao_exterior = 'N'
      AND rw_declaracao.tppessoa             = 2
      THEN
        OPEN cr_pais_socio (pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_pais_socio INTO rw_pais_socio;
        IF cr_pais_socio%FOUND THEN
          rw_declaracao.nmpais_reportavel := rw_pais_socio.nmpais_socio;
        END IF;
        CLOSE cr_pais_socio;
      END IF;
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'rel_declaracao',pr_posicao => 0          , pr_tag_nova => 'declaracao'       , pr_tag_cont => NULL                           , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'dsendereco'       , pr_tag_cont => rw_declaracao.dsendereco       , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa'         , pr_tag_cont => rw_declaracao.nmpessoa         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'dscidade'         , pr_tag_cont => rw_declaracao.dscidade         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'dsestado'         , pr_tag_cont => rw_declaracao.dsestado         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'dscodigo_postal'  , pr_tag_cont => rw_declaracao.dscodigo_postal  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais_reportavel', pr_tag_cont => rw_declaracao.nmpais_reportavel, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'inreportavel'     , pr_tag_cont => rw_declaracao.inreportavel     , pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    IF vr_inexiste_declaracao = 0 THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'rel_declaracao',pr_posicao => 0          , pr_tag_nova => 'declaracao'       , pr_tag_cont => NULL    , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'inreportavel'     , pr_tag_cont => 'N'     , pr_des_erro => vr_dscritic);
    END IF;
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crapnac'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => 1                   --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := 0;
      pr_dscritic := 'Erro (REL_DECLARACAO.pc_busca_dados_declaracao).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_declaracao;

  PROCEDURE pc_busca_cidade(pr_cdcooper IN crapage.cdcooper%TYPE         --> Cd cooperativa
                           ,pr_nrdconta IN crapage.cdagenci%TYPE         --> Numero da conta
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_cidade
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rodrigo Costa - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Busca as informações para o relatório de Declaração

   Alteracoes:

    ............................................................................. */
    CURSOR cr_busca_agencia IS
    select CDAGENCI
      from crapass a
     where a.cdcooper = pr_cdcooper
       and a.nrdconta = pr_nrdconta;
    rw_busca_agencia cr_busca_agencia%ROWTYPE;

    CURSOR cr_agencia (pr_cdagenci IN crapage.cdagenci%TYPE) IS
    select NMCIDADE
      from crapage a
     where a.cdcooper = pr_cdcooper
       and a.cdagenci = pr_cdagenci;

    -- Variaveis de log
    VR_NMCIDADE VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;

    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;

    --Variaveis de controle

  BEGIN -- Inicio pc_busca_dados_declaracao

    --insert into CRAPLGI (CDCOOPER,NRDCONTA,IDSEQTTL,NRSEQUEN,DTTRANSA,NMDCAMPO,DSDADATU) values (1,387789,9,to_char(sysdate,'miss'),sysdate,'pr_cdcooper',pr_cdcooper);
    --insert into CRAPLGI (CDCOOPER,NRDCONTA,IDSEQTTL,NRSEQUEN,DTTRANSA,NMDCAMPO,DSDADATU) values (1,387789,9,to_char(sysdate,'miss')+1,sysdate,'pr_cdagenci',pr_cdagenci);
    --commit;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'REL_DECLARACAO'
                              ,pr_action => null);



    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_busca_agencia;
    FETCH cr_busca_agencia INTO rw_busca_agencia;
    IF cr_busca_agencia%FOUND THEN
      vr_cdagenci := rw_busca_agencia.cdagenci;
    ELSE
      vr_cdagenci := 0;
    END IF;
    CLOSE cr_busca_agencia;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'rel_declaracao',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_agencia IN cr_agencia(pr_cdagenci => vr_cdagenci) LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'rel_declaracao',pr_posicao => 0          , pr_tag_nova => 'declaracao'       , pr_tag_cont => NULL                      , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'nmcidade'         , pr_tag_cont => rw_agencia.nmcidade       , pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crapage'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => 1                   --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := 0;
      pr_dscritic := 'Erro (REL_DECLARACAO.pc_busca_cidade).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_cidade;

END REL_DECLARACAO;
/
