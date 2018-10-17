CREATE OR REPLACE PACKAGE CECRED.TELA_REPEXT AS
   /*
   Programa: TELA_REPEXT                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Mostrar a tela REPEXT para permitir o gerenciamento de informações das pessoas

   Alteracoes:

   */

  --Validar se o CPF/CNPJ existe na tabela TBCADAT_PESSOA
  PROCEDURE pc_valida_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                            ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Buscar os registros que estão na tabela TBREPORTAVAL_FATCA_CRS conforme os filtros informados
  PROCEDURE pc_busca_dados_compliance(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                     ,pr_dtinicio     IN VARCHAR2                                 --> Data de inicio de reportabilidade (dd/mm/yyyy)
                                     ,pr_dtfinal      IN VARCHAR2                                 --> Data de final de reportabilidade (dd/mm/yyyy)
                                     ,pr_insituacao   IN tbreportaval_fatca_crs.insituacao%TYPE   --> Situação (Pendente, Em Aberto, Analisada)
                                     ,pr_inreportavel IN tbreportaval_fatca_crs.inreportavel%TYPE --> Indicador de Reportável (Sim, Não)
                                     ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                     ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                     ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                     ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                     ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                     ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                     ,pr_des_erro     OUT VARCHAR2);                              --> Erros do processo

  --Buscar informações complementares, referentes a FATCA/CRS, para a pessoa
  PROCEDURE pc_busca_dados_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Buscar informações das contas da pessoa
  PROCEDURE pc_busca_dados_contas(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                 ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                 ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2);                              --> Erros do processo

  --Buscar informações de Compliance da pessoa
  PROCEDURE pc_busca_dados_comp_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                      ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Validar o tipo de domínio
  PROCEDURE pc_valida_dominio_tipo(pr_cdtipo_dominio IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE --> Tipo de domínio (Declarado, Proprietário)
                                  ,pr_idtipo_dominio IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                  ,pr_xmllog         IN VARCHAR2                                     --> XML com informações de LOG
                                  ,pr_cdcritic       OUT PLS_INTEGER                                 --> Código da crítica
                                  ,pr_dscritic       OUT VARCHAR2                                    --> Descrição da crítica
                                  ,pr_retxml         IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                  ,pr_nmdcampo       OUT VARCHAR2                                    --> Nome do campo com erro
                                  ,pr_des_erro       OUT VARCHAR2);                                  --> Erros do processo

  --Validar o domínio tipo delcarado
  PROCEDURE pc_valida_tipo_declarado(pr_cdtipo_declarado IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                    ,pr_xmllog           IN VARCHAR2                                     --> XML com informações de LOG
                                    ,pr_cdcritic         OUT PLS_INTEGER                                 --> Código da crítica
                                    ,pr_dscritic         OUT VARCHAR2                                    --> Descrição da crítica
                                    ,pr_retxml           IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                    ,pr_nmdcampo         OUT VARCHAR2                                    --> Nome do campo com erro
                                    ,pr_des_erro         OUT VARCHAR2);                                  --> Erros do processo

  --Validar o domínio tipo proprietario
  PROCEDURE pc_valida_tipo_proprietario(pr_cdtipo_proprietario IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                       ,pr_xmllog              IN VARCHAR2                                     --> XML com informações de LOG
                                       ,pr_cdcritic            OUT PLS_INTEGER                                 --> Código da crítica
                                       ,pr_dscritic            OUT VARCHAR2                                    --> Descrição da crítica
                                       ,pr_retxml              IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                       ,pr_nmdcampo            OUT VARCHAR2                                    --> Nome do campo com erro
                                       ,pr_des_erro            OUT VARCHAR2);                                  --> Erros do processo

  --Atualizar as informações de compliance da pessoa
  PROCEDURE pc_atualiza_compliance_pessoa(pr_nrcpfcgc            IN tbcadast_pessoa.nrcpfcgc%TYPE                   --> CPF ou CGC da pessoa
                                         ,pr_inreportavel        IN tbreportaval_fatca_crs.inreportavel%TYPE        --> Indicador de Reportável (Sim, Não)
                                         ,pr_cdtipo_declarado    IN tbreportaval_fatca_crs.cdtipo_declarado%TYPE    --> Tipo de declarado
                                         ,pr_cdtipo_proprietario IN tbreportaval_fatca_crs.cdtipo_proprietario%TYPE --> Tipo de proprietario
                                         ,pr_dsjustificativa     IN tbreportaval_fatca_crs.dsjustificativa%TYPE     --> Descrição da Justificativa
                                         ,pr_xmllog              IN VARCHAR2                                        --> XML com informações de LOG
                                         ,pr_cdcritic            OUT PLS_INTEGER                                    --> Código da crítica
                                         ,pr_dscritic            OUT VARCHAR2                                       --> Descrição da crítica
                                         ,pr_retxml              IN OUT NOCOPY XMLType                              --> Arquivo de retorno do XML
                                         ,pr_nmdcampo            OUT VARCHAR2                                       --> Nome do campo com erro
                                         ,pr_des_erro            OUT VARCHAR2);                                     --> Erros do processo

  --Buscar os sócios de determinado CNPJ
  PROCEDURE pc_busca_dados_socios(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                 ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                 ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2);                              --> Erros do processo

  --Buscar dados complementares do sócio
  PROCEDURE pc_busca_dados_comp_socio(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                     ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                     ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                     ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                     ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                     ,pr_des_erro     OUT VARCHAR2);                              --> Erros do processo

  --Buscar o histórico de alterações da tabela TBREPORTAVAL_FATCA_CRS
  PROCEDURE pc_busca_dados_historico(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                    ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                    ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                    ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                    ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                    ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                    ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                    ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                    ,pr_des_erro     OUT VARCHAR2);                              --> Erros do processo

  --Buscar os domínios na tabela de domínios
  PROCEDURE pc_busca_dominio_tipo(pr_idtipo_dominio     IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Tipo de domínio (Declarado, Proprietário)
                                 ,pr_cdtipo_dominio     IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE --> Código do domínio
                                 ,pr_insituacao         IN VARCHAR2 DEFAULT 'T'                         --> Situação a ser pesquisada (T=Todas, A=Ativas, I=Inativas)
                                 ,pr_nrregist           IN INTEGER                                      --> Quantidade de registros
                                 ,pr_nriniseq           IN INTEGER                                      --> Qunatidade inicial
                                 ,pr_xmllog             IN VARCHAR2                                     --> XML com informações de LOG
                                 ,pr_cdcritic           OUT PLS_INTEGER                                 --> Código da crítica
                                 ,pr_dscritic           OUT VARCHAR2                                    --> Descrição da crítica
                                 ,pr_retxml             IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                 ,pr_nmdcampo           OUT VARCHAR2                                    --> Nome do campo com erro
                                 ,pr_des_erro           OUT VARCHAR2);                                  --> Erros do processo

  --Atualizar os domínios na tabela de domínios
  PROCEDURE pc_atualiza_dominio_tipo(pr_idtipo_dominio       IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE       --> Tipo de domínio (Declarado, Proprietário)
                                    ,pr_inoperacao           IN VARCHAR2                                           --> Tipo de operação (Inclusão, Alteração)
                                    ,pr_cdtipo_dominio       IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE       --> Código do domínio
                                    ,pr_dstipo_dominio       IN tbdominio_tipo_fatca_crs.dstipo_dominio%TYPE       --> Descrição do domínio
                                    ,pr_inexige_proprietario IN tbdominio_tipo_fatca_crs.inexige_proprietario%TYPE --> Exige Tipo Proprietário
                                    ,pr_insituacao           IN tbdominio_tipo_fatca_crs.insituacao%TYPE           --> Situação (Ativo, Inativo)
                                    ,pr_xmllog              IN VARCHAR2                                            --> XML com informações de LOG
                                    ,pr_cdcritic            OUT PLS_INTEGER                                        --> Código da crítica
                                    ,pr_dscritic            OUT VARCHAR2                                           --> Descrição da crítica
                                    ,pr_retxml              IN OUT NOCOPY XMLType                                  --> Arquivo de retorno do XML
                                    ,pr_nmdcampo            OUT VARCHAR2                                           --> Nome do campo com erro
                                    ,pr_des_erro            OUT VARCHAR2);                                         --> Erros do processo

  --Buscar CPF/CNPJ existentes na tabela tbreportaval_fatca_crs
  PROCEDURE pc_busca_pessoas_reportaveis(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE DEFAULT 0    --> CPF ou CGC da pessoa
                                        ,pr_nmpessoa     IN tbcadast_pessoa.nmpessoa%TYPE DEFAULT NULL --> Nome da pessoa
                                        ,pr_nrregist     IN INTEGER                                    --> Quantidade de registros
                                        ,pr_nriniseq     IN INTEGER                                    --> Qunatidade inicial
                                        ,pr_xmllog       IN VARCHAR2                                   --> XML com informações de LOG
                                        ,pr_cdcritic     OUT PLS_INTEGER                               --> Código da crítica
                                        ,pr_dscritic     OUT VARCHAR2                                  --> Descrição da crítica
                                        ,pr_retxml       IN OUT NOCOPY XMLType                         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo     OUT VARCHAR2                                  --> Nome do campo com erro
                                        ,pr_des_erro     OUT VARCHAR2);                                --> Erros do processo

END TELA_REPEXT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_REPEXT AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_REPEXT                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Mostrar a tela REPEXT para permitir o gerenciamento de informações das pessoas

   Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

  --Validar se o CPF/CNPJ existe na tabela TBCADAT_PESSOA
  PROCEDURE pc_valida_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                            ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_valida_pessoa
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Validar se o CPF/CNPJ existe na tabela TBCADAT_PESSOA

   Alteracoes:

    ............................................................................. */
    CURSOR cr_declaracao (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT a.nmpessoa
      FROM tbcadast_pessoa a
     WHERE a.nrcpfcgc     = pr_nrcpfcgc;

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

    --Variaveis de controle

  BEGIN -- Inicio pc_valida_pessoa

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_declaracao IN cr_declaracao(pr_nrcpfcgc => pr_nrcpfcgc) LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'   ,pr_posicao => 0          , pr_tag_nova => 'declaracao'       , pr_tag_cont => NULL                           , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'declaracao'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa'         , pr_tag_cont => rw_declaracao.nmpessoa         , pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_valida_pessoa).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_valida_pessoa;

  --Buscar os registros que estão na tabela TBREPORTAVAL_FATCA_CRS conforme os filtros informados
  PROCEDURE pc_busca_dados_compliance(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                     ,pr_dtinicio     IN VARCHAR2                                 --> Data de inicio de reportabilidade (dd/mm/yyyy)
                                     ,pr_dtfinal      IN VARCHAR2                                 --> Data de final de reportabilidade (dd/mm/yyyy)
                                     ,pr_insituacao   IN tbreportaval_fatca_crs.insituacao%TYPE   --> Situação (Pendente, Em Aberto, Analisada)
                                     ,pr_inreportavel IN tbreportaval_fatca_crs.inreportavel%TYPE --> Indicador de Reportável (Sim, Não)
                                     ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                     ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                     ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                     ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                     ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                     ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                     ,pr_des_erro     OUT VARCHAR2) IS                            --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_compliance
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar os registros que estão na tabela TBREPORTAVAL_FATCA_CRS conforme os filtros informados

   Alteracoes:

    ............................................................................. */
    CURSOR cr_comliance (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE
                        ,pr_dtinicial    IN VARCHAR2
                        ,pr_dtfinal      IN VARCHAR2
                        ,pr_insituacao   IN tbreportaval_fatca_crs.insituacao%TYPE
                        ,pr_inreportavel IN tbreportaval_fatca_crs.inreportavel%TYPE) IS
    SELECT a.nrcpfcgc
          ,b.nmpessoa
          ,CASE
             WHEN a.insituacao = 'P' THEN 'PENDENTE'
             WHEN a.insituacao = 'E' THEN 'EM ABERTO'
             WHEN a.insituacao = 'A' THEN 'ANALISADA'
             ELSE                         '**/\**'
           END insituacao
          ,CASE
             WHEN a.inreportavel = 'S' THEN 'SIM'
             WHEN a.inreportavel = 'N' THEN 'NAO'
             ELSE                           ''
           END inreportavel
          ,a.cdtipo_declarado
          ,a.cdtipo_proprietario
          ,c.dstipo_dominio dstipo_declarado
          ,d.dstipo_dominio dstipo_proprietario
          ,a.dsjustificativa
          ,b.tppessoa
      FROM tbreportaval_fatca_crs a
          ,tbcadast_pessoa b
          ,tbdominio_tipo_fatca_crs c
          ,tbdominio_tipo_fatca_crs d
     WHERE a.nrcpfcgc           = NVL(pr_nrcpfcgc, a.nrcpfcgc)
       AND NVL(a.dtinicio, trunc(sysdate))
                          BETWEEN NVL(pr_dtinicial, NVL(a.dtinicio, trunc(sysdate)))
                              AND NVL(pr_dtfinal, NVL(a.dtinicio, trunc(sysdate)))
       AND a.insituacao         = pr_insituacao
       AND NVL(a.inreportavel,'.') = DECODE(pr_inreportavel,'A', NVL(a.inreportavel,'.'), NVL(pr_inreportavel,'.'))
       AND b.nrcpfcgc           = a.nrcpfcgc
       AND c.idtipo_dominio (+) = 'D'
       AND c.cdtipo_dominio (+) = a.cdtipo_declarado
       AND d.idtipo_dominio (+) = 'P'
       AND d.cdtipo_dominio (+) = a.cdtipo_proprietario;

    CURSOR cr_contador_socios (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT count(*) qtsocios
      FROM (SELECT COUNT(*) qtsocios
              FROM crapass a
                  ,crapavt b
             WHERE a.nrcpfcgc  = pr_nrcpfcgc
               AND a.cdsitdct <> 4
               AND a.dtdemiss IS NULL
               AND b.cdcooper  = a.cdcooper
               AND b.nrdconta  = a.nrdconta
               AND b.tpctrato  = 6
               AND b.dsproftl <> 'PROCURADOR'
               AND b.persocio >= 10
            UNION
    SELECT COUNT(*) qtsocios
      FROM crapass a
                  ,crapepa b
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND b.cdcooper  = a.cdcooper
       AND b.nrdconta  = a.nrdconta
               AND b.persocio >= 10);
    rw_contador_socios cr_contador_socios%ROWTYPE;

    CURSOR cr_conta (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT LPAD(cdcooper,3,'0') cdcooper
          ,nrdconta
      FROM crapass a
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND ROWNUM = 1;
    rw_conta cr_conta%ROWTYPE;

    CURSOR cr_crapdoc (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE
                      ,pr_tpdocmto1    IN crapdoc.tpdocmto%TYPE
                      ,pr_tpdocmto2    IN crapdoc.tpdocmto%TYPE) IS
    SELECT NVL(MIN(flgdigit),9) flgdigit
      FROM crapdoc a
     WHERE nrcpfcgc  = pr_nrcpfcgc
       AND (tpdocmto = pr_tpdocmto1
         OR tpdocmto = pr_tpdocmto2);
    rw_crapdoc cr_crapdoc%ROWTYPE;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

    --Variaveis de trabalho
    vr_dtinicio     tbreportaval_fatca_crs.dtinicio%TYPE;
    vr_dtfinal      tbreportaval_fatca_crs.dtfinal%TYPE;
    vr_inreportavel tbreportaval_fatca_crs.inreportavel%TYPE;
    vr_intem_socio  VARCHAR2(01);
    vr_nrcpfcgc     VARCHAR2(100);
    vr_dsdigidoc    VARCHAR2(03);
    vr_tpdocmto1    NUMBER;
    vr_tpdocmto2    NUMBER;

  BEGIN -- Inicio pc_busca_dados_compliance
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    vr_dtinicio := TO_DATE(pr_dtinicio,'dd/mm/yyyy');
    vr_dtfinal  := TO_DATE(pr_dtfinal,'dd/mm/yyyy');

    IF pr_insituacao <> 'P' THEN
      vr_inreportavel := null;
    END IF;
    --Loop nas nacionalidades
    FOR rw_comliance IN cr_comliance(pr_nrcpfcgc     => pr_nrcpfcgc
                                    ,pr_dtinicial    => vr_dtinicio
                                    ,pr_dtfinal      => vr_dtfinal
                                    ,pr_insituacao   => pr_insituacao
                                    ,pr_inreportavel => pr_inreportavel) LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      -- Buscar a Cooperativa e conta da pessoa (será utilizada na pesquisa do DIGIDOC (DIGI0001))
      OPEN cr_conta (pr_nrcpfcgc     => rw_comliance.nrcpfcgc);
      FETCH cr_conta INTO rw_conta;
      IF cr_conta%NOTFOUND THEN
        rw_conta.cdcooper := 0;
        rw_conta.nrdconta := 0;
      END IF;
      CLOSE cr_conta;

      -- Verificar se a pessoa jurídica tem sócios
      vr_intem_socio := 'N';
      --
      IF rw_comliance.tppessoa = 2 THEN
        OPEN cr_contador_socios (pr_nrcpfcgc     => rw_comliance.nrcpfcgc);
        FETCH cr_contador_socios INTO rw_contador_socios;
        IF cr_contador_socios%NOTFOUND THEN
          rw_contador_socios.qtsocios := 0;
        END IF;
        CLOSE cr_contador_socios;
        --
        IF rw_contador_socios.qtsocios > 0 THEN
          vr_intem_socio := 'S';
        END IF;
      END IF;

      TELA_FATCA_CRS.pc_buscar_tpdocmto_digidoc(pr_insocio   => 'N'
                                               ,pr_tpdocmto1 => vr_tpdocmto1
                                               ,pr_tpdocmto2 => vr_tpdocmto2);

      OPEN cr_crapdoc (pr_nrcpfcgc     => rw_comliance.nrcpfcgc
                      ,pr_tpdocmto1    => vr_tpdocmto1
                      ,pr_tpdocmto2    => vr_tpdocmto2);
      FETCH cr_crapdoc INTO rw_crapdoc;
      IF cr_crapdoc%NOTFOUND THEN
        rw_crapdoc.flgdigit := 9;
      END IF;
      CLOSE cr_crapdoc;

      IF rw_crapdoc.flgdigit IN (0, 9) THEN
        vr_dsdigidoc := 'NAO';
      ELSE
        vr_dsdigidoc := 'SIM';
      END IF;

      vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_comliance.nrcpfcgc
                                              ,pr_inpessoa => rw_comliance.tppessoa);
      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'     ,pr_posicao => 0          , pr_tag_nova => 'dados_compliance'   , pr_tag_cont => NULL                            , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc'           , pr_tag_cont => vr_nrcpfcgc                     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa'           , pr_tag_cont => rw_comliance.nmpessoa           , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'insituacao'         , pr_tag_cont => rw_comliance.insituacao         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'inreportavel'       , pr_tag_cont => rw_comliance.inreportavel       , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_declarado'   , pr_tag_cont => rw_comliance.cdtipo_declarado   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'dstipo_declarado'   , pr_tag_cont => rw_comliance.dstipo_declarado   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_proprietario', pr_tag_cont => rw_comliance.cdtipo_proprietario, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'dstipo_proprietario', pr_tag_cont => rw_comliance.dstipo_proprietario, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'dsjustificativa'    , pr_tag_cont => rw_comliance.dsjustificativa    , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'tppessoa'           , pr_tag_cont => rw_comliance.tppessoa           , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'intem_socio'        , pr_tag_cont => vr_intem_socio                  , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper'           , pr_tag_cont => rw_conta.cdcooper               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta'           , pr_tag_cont => rw_conta.nrdconta               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_compliance',pr_posicao => vr_auxconta, pr_tag_nova => 'dsdigidoc'          , pr_tag_cont => vr_dsdigidoc                    , pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_compliance).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_compliance;

  --Buscar informações complementares, referentes a FATCA/CRS, para a pessoa
  PROCEDURE pc_busca_dados_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_fatca_crs
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar informações complementares, referentes a FATCA/CRS, para a pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_dados_fatca_crs (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT a.nrcpfcgc
          ,d.cdpais
          ,b.nridentificacao
          ,e.cdpais cdpais_exterior
          ,c.dtinicio
          ,c.dtfinal
          ,d.inacordo
          ,d.nmpais
          ,e.nmpais nmpais_exterior
      FROM tbcadast_pessoa a
          ,tbcadast_pessoa_estrangeira b
          ,tbreportaval_fatca_crs c
          ,crapnac d
          ,crapnac e
     WHERE a.nrcpfcgc = pr_nrcpfcgc
       AND b.idpessoa = a.idpessoa
       AND c.nrcpfcgc = a.nrcpfcgc
       AND d.cdnacion = b.cdpais
       AND e.cdnacion (+) = b.cdpais_exterior;

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

    --Variaveis de controle

  BEGIN -- Inicio pc_busca_dados_fatca_crs

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_dados_fatca_crs IN cr_dados_fatca_crs(pr_nrcpfcgc => pr_nrcpfcgc) LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'    ,pr_posicao => 0          , pr_tag_nova => 'dados_fatca_crs', pr_tag_cont => NULL                              , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc'       , pr_tag_cont => rw_dados_fatca_crs.nrcpfcgc       , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais'         , pr_tag_cont => rw_dados_fatca_crs.cdpais         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais'         , pr_tag_cont => rw_dados_fatca_crs.nmpais         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nridentificacao', pr_tag_cont => rw_dados_fatca_crs.nridentificacao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais_exterior', pr_tag_cont => rw_dados_fatca_crs.cdpais_exterior, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais_exterior', pr_tag_cont => rw_dados_fatca_crs.nmpais_exterior, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dtinicio'       , pr_tag_cont => rw_dados_fatca_crs.dtinicio       , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dtfinal'        , pr_tag_cont => rw_dados_fatca_crs.dtfinal        , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo'       , pr_tag_cont => rw_dados_fatca_crs.inacordo       , pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_fatca_crs).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_fatca_crs;

  --Buscar informações das contas da pessoa
  PROCEDURE pc_busca_dados_contas(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                 ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                 ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2) IS                            --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_contas
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar informações das contas da pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_contas (pr_nrcpfcgc     IN crapass.nrcpfcgc%TYPE) IS
    SELECT a.cdcooper||'-'||UPPER(c.dsdircop) dscooper
          ,a.cdagenci
          ,a.nrdconta
          ,DECODE(a.inpessoa,1,'FÍSICA','JURÍDICA') tppessoa
          ,NULL insocio
          ,NULL prsocio
          ,d.nmpessoa
      FROM crapass a
          ,crapcop c
          ,tbcadast_pessoa d
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND d.nrcpfcgc  = a.nrcpfcgc
       AND c.cdcooper  = a.cdcooper
    UNION
    SELECT a.cdcooper||'-'||UPPER(c.dsdircop) dscooper
          ,a.cdagenci
          ,a.nrdconta
          ,DECODE(a.inpessoa,1,'FÍSICA','JURÍDICA') tppessoa
          ,'SIM' insocio
          ,replace(to_char(persocio,'990.00'),'.',',') prsocio
          ,d.nmpessoa
      FROM crapass a
          ,crapavt b
          ,crapcop c
          ,tbcadast_pessoa d
     WHERE b.nrcpfcgc  = pr_nrcpfcgc
       AND b.tpctrato  = 6
       AND b.dsproftl <> 'PROCURADOR'
       AND b.persocio >= 10
       AND a.cdcooper  = b.cdcooper
       AND a.nrdconta  = b.nrdconta
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND c.cdcooper  = a.cdcooper
       AND d.nrcpfcgc  = a.nrcpfcgc
    UNION
    SELECT a.cdcooper||'-'||UPPER(c.dsdircop) dscooper
          ,a.cdagenci
          ,a.nrdconta
          ,DECODE(a.inpessoa,1,'FÍSICA','JURÍDICA') tppessoa
          ,'SIM' insocio
          ,replace(to_char(persocio,'990.00'),'.',',') prsocio
          ,d.nmpessoa
      FROM crapass a
          ,crapepa b
          ,crapcop c
          ,tbcadast_pessoa d
     WHERE b.nrdocsoc  = pr_nrcpfcgc
       AND b.persocio >= 10
       AND a.cdcooper  = b.cdcooper
       AND a.nrdconta  = b.nrdconta
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND c.cdcooper  = a.cdcooper
       AND d.nrcpfcgc  = a.nrcpfcgc
     ORDER BY 5 DESC, 1,2,4;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

    -- Variaveis de trabalho
    vr_nrdconta VARCHAR2(100);

  BEGIN -- Inicio pc_busca_dados_contas
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_contas IN cr_contas(pr_nrcpfcgc     => pr_nrcpfcgc) LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      vr_nrdconta := gene0002.fn_mask_conta(pr_nrdconta => rw_contas.nrdconta);

      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext' ,pr_posicao => 0          , pr_tag_nova => 'dados_contas', pr_tag_cont => NULL              , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'dscooper'    , pr_tag_cont => rw_contas.dscooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci'    , pr_tag_cont => rw_contas.cdagenci, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta'    , pr_tag_cont => vr_nrdconta       , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'tppessoa'    , pr_tag_cont => rw_contas.tppessoa, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'insocio'     , pr_tag_cont => rw_contas.insocio , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'prsocio'     , pr_tag_cont => rw_contas.prsocio , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_contas',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa'    , pr_tag_cont => rw_contas.nmpessoa, pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_contas).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_contas;

  --Buscar informações de Compliance da pessoa
  PROCEDURE pc_busca_dados_comp_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                      ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_comp_pessoa
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar informações de Compliance da pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_reportavel (pr_nrcpfcgc     IN crapass.nrcpfcgc%TYPE) IS
    SELECT inreportavel
          ,cdtipo_declarado
          ,cdtipo_proprietario
      FROM tbreportaval_fatca_crs
     WHERE nrcpfcgc  = pr_nrcpfcgc;

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

    --Variaveis de controle

  BEGIN -- Inicio pc_busca_dados_comp_pessoa

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_reportavel IN cr_reportavel(pr_nrcpfcgc     => pr_nrcpfcgc) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'     ,pr_posicao => 0          , pr_tag_nova => 'dados_reportavel'   , pr_tag_cont => NULL                             , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_reportavel',pr_posicao => vr_auxconta, pr_tag_nova => 'inreportavel'       , pr_tag_cont => rw_reportavel.inreportavel       , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_reportavel',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_declarado'   , pr_tag_cont => rw_reportavel.cdtipo_declarado   , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_reportavel',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_proprietario', pr_tag_cont => rw_reportavel.cdtipo_proprietario, pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => 0                   --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_comp_pessoa).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_comp_pessoa;

  --Validar o tipo de domínio
  PROCEDURE pc_valida_dominio_tipo(pr_cdtipo_dominio IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE --> Tipo de domínio (Declarado, Proprietário)
                                  ,pr_idtipo_dominio IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                  ,pr_xmllog         IN VARCHAR2                                     --> XML com informações de LOG
                                  ,pr_cdcritic       OUT PLS_INTEGER                                 --> Código da crítica
                                  ,pr_dscritic       OUT VARCHAR2                                    --> Descrição da crítica
                                  ,pr_retxml         IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                  ,pr_nmdcampo       OUT VARCHAR2                                    --> Nome do campo com erro
                                  ,pr_des_erro       OUT VARCHAR2) IS                                --> Erros do processo
  /* .............................................................................
   Programa: pc_valida_dominio_tipo
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Validar o tipo de domínio

   Alteracoes:

    ............................................................................. */
    CURSOR cr_dominio (pr_cdtipo_dominio IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE
                      ,pr_idtipo_dominio IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE) IS
    SELECT cdtipo_dominio
          ,dstipo_dominio
          ,inexige_proprietario
      FROM tbdominio_tipo_fatca_crs a
     WHERE cdtipo_dominio = pr_cdtipo_dominio
       AND idtipo_dominio = pr_idtipo_dominio;

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

    --Variaveis de controle

  BEGIN -- Inicio pc_valida_dominio_tipo

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_dominio IN cr_dominio(pr_cdtipo_dominio => pr_cdtipo_dominio
                                ,pr_idtipo_dominio => pr_idtipo_dominio) LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext',pr_posicao => 0          , pr_tag_nova => 'dominio'             , pr_tag_cont => NULL                           , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dominio'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_dominio'      , pr_tag_cont => rw_dominio.cdtipo_dominio      , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dominio'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'dstipo_dominio'      , pr_tag_cont => rw_dominio.dstipo_dominio      , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dominio'    ,pr_posicao => vr_auxconta, pr_tag_nova => 'inexige_proprietario', pr_tag_cont => rw_dominio.inexige_proprietario, pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
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
      pr_dscritic := 'Erro (TELA_REPEXT.PC_VALIDA_DOMINIO_TIPO).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_valida_dominio_tipo;

  --Validar o domínio tipo delcarado
  PROCEDURE pc_valida_tipo_declarado(pr_cdtipo_declarado IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                    ,pr_xmllog           IN VARCHAR2                                     --> XML com informações de LOG
                                    ,pr_cdcritic         OUT PLS_INTEGER                                 --> Código da crítica
                                    ,pr_dscritic         OUT VARCHAR2                                    --> Descrição da crítica
                                    ,pr_retxml           IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                    ,pr_nmdcampo         OUT VARCHAR2                                    --> Nome do campo com erro
                                    ,pr_des_erro         OUT VARCHAR2) IS                                --> Erros do processo
  /* .............................................................................
   Programa: pc_valida_tipo_declarado
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Validar o domínio tipo delcarado

   Alteracoes:

    ............................................................................. */

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

    --Variaveis de controle

  BEGIN -- Inicio pc_valida_tipo_declarado

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    pc_valida_dominio_tipo(pr_cdtipo_dominio => pr_cdtipo_declarado
                          ,pr_idtipo_dominio => 'D'
                          ,pr_xmllog         => pr_xmllog
                          ,pr_cdcritic       => vr_cdcritic
                          ,pr_dscritic       => vr_dscritic
                          ,pr_retxml         => pr_retxml
                          ,pr_nmdcampo       => pr_nmdcampo
                          ,pr_des_erro       => pr_des_erro);

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
      pr_dscritic := 'Erro (TELA_REPEXT.PC_VALIDA_TIPO_DECLARADO).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_valida_tipo_declarado;

  --Validar o domínio tipo proprietario
  PROCEDURE pc_valida_tipo_proprietario(pr_cdtipo_proprietario IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Código do domínio
                                       ,pr_xmllog              IN VARCHAR2                                     --> XML com informações de LOG
                                       ,pr_cdcritic            OUT PLS_INTEGER                                 --> Código da crítica
                                       ,pr_dscritic            OUT VARCHAR2                                    --> Descrição da crítica
                                       ,pr_retxml              IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                       ,pr_nmdcampo            OUT VARCHAR2                                    --> Nome do campo com erro
                                       ,pr_des_erro            OUT VARCHAR2) IS                                --> Erros do processo
  /* .............................................................................
   Programa: pc_valida_tipo_proprietario
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Validar o domínio tipo proprietario

   Alteracoes:

    ............................................................................. */

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

    --Variaveis de controle

  BEGIN -- Inicio pc_valida_tipo_proprietario

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    pc_valida_dominio_tipo(pr_cdtipo_dominio => pr_cdtipo_proprietario
                          ,pr_idtipo_dominio => 'P'
                          ,pr_xmllog         => pr_xmllog
                          ,pr_cdcritic       => vr_cdcritic
                          ,pr_dscritic       => vr_dscritic
                          ,pr_retxml         => pr_retxml
                          ,pr_nmdcampo       => pr_nmdcampo
                          ,pr_des_erro       => pr_des_erro);

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
      pr_dscritic := 'Erro (TELA_REPEXT.PC_VALIDA_TIPO_PROPRIETARIO).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_valida_tipo_proprietario;

  --Atualizar as informações de compliance da pessoa
  PROCEDURE pc_atualiza_compliance_pessoa(pr_nrcpfcgc            IN tbcadast_pessoa.nrcpfcgc%TYPE                   --> CPF ou CGC da pessoa
                                         ,pr_inreportavel        IN tbreportaval_fatca_crs.inreportavel%TYPE        --> Indicador de Reportável (Sim, Não)
                                         ,pr_cdtipo_declarado    IN tbreportaval_fatca_crs.cdtipo_declarado%TYPE    --> Tipo de declarado
                                         ,pr_cdtipo_proprietario IN tbreportaval_fatca_crs.cdtipo_proprietario%TYPE --> Tipo de proprietario
                                         ,pr_dsjustificativa     IN tbreportaval_fatca_crs.dsjustificativa%TYPE     --> Descrição da Justificativa
                                         ,pr_xmllog              IN VARCHAR2                                        --> XML com informações de LOG
                                         ,pr_cdcritic            OUT PLS_INTEGER                                    --> Código da crítica
                                         ,pr_dscritic            OUT VARCHAR2                                       --> Descrição da crítica
                                         ,pr_retxml              IN OUT NOCOPY XMLType                              --> Arquivo de retorno do XML
                                         ,pr_nmdcampo            OUT VARCHAR2                                       --> Nome do campo com erro
                                         ,pr_des_erro            OUT VARCHAR2) IS                                   --> Erros do processo
  /* .............................................................................
   Programa: pc_atualiza_compliance_pessoa
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Atualizar as informações de compliance da pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_reportavel (pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT *
      FROM tbreportaval_fatca_crs
     WHERE nrcpfcgc  = pr_nrcpfcgc;

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

    --Variaveis de controle

    --Variaveis de trabalho
    vr_idexiste_pessoa      NUMBER;
    vr_insituacao           tbreportaval_fatca_crs.insituacao%TYPE;
    vr_dtinicio             tbreportaval_fatca_crs.dtinicio%TYPE;
    vr_dtfinal              tbreportaval_fatca_crs.dtfinal%TYPE;
    vr_dsalteracao          tbhist_reportaval_fatca_crs.dsalteracao%TYPE;

  BEGIN -- Inicio pc_atualiza_compliance_pessoa

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    vr_idexiste_pessoa := 0;

    --Loop nas nacionalidades
    FOR rw_reportavel IN cr_reportavel(pr_nrcpfcgc => pr_nrcpfcgc) LOOP
      vr_idexiste_pessoa := 1;

      IF NVL(rw_reportavel.inreportavel,'.')        <> UPPER(NVL(pr_inreportavel,'.'))
      OR NVL(rw_reportavel.cdtipo_declarado,'.')    <> UPPER(NVL(pr_cdtipo_declarado,'.'))
      OR NVL(rw_reportavel.cdtipo_proprietario,'.') <> UPPER(NVL(pr_cdtipo_proprietario,'.'))
      THEN
        IF NVL(rw_reportavel.inreportavel,'.') <> UPPER(NVL(pr_inreportavel,'.'))
        AND UPPER(pr_inreportavel) = 'S'
        THEN
          vr_insituacao := 'A';
          IF rw_reportavel.dtinicio IS NULL THEN
            vr_dtinicio := TRUNC(SYSDATE);
          ELSE
            vr_dtinicio := rw_reportavel.dtinicio;
          END IF;
          vr_dtfinal    := NULL;
        END IF;
        --
        IF NVL(rw_reportavel.inreportavel,'.') <> UPPER(NVL(pr_inreportavel,'.'))
        AND UPPER(pr_inreportavel) = 'N'
        THEN
          vr_insituacao := 'A';
          IF rw_reportavel.dtinicio IS NULL THEN
            vr_dtinicio := TRUNC(SYSDATE);
          ELSE
            vr_dtinicio := rw_reportavel.dtinicio;
          END IF;
          vr_dtfinal    := TRUNC(SYSDATE);
        END IF;
        --
        BEGIN
          UPDATE tbreportaval_fatca_crs
             SET inreportavel        = UPPER(pr_inreportavel)
                ,cdtipo_declarado    = UPPER(pr_cdtipo_declarado)
                ,cdtipo_proprietario = UPPER(pr_cdtipo_proprietario)
                ,insituacao          = vr_insituacao
                ,dtinicio            = vr_dtinicio
                ,dtfinal             = vr_dtfinal
                ,dsjustificativa     = pr_dsjustificativa
                ,dtaltera            = SYSDATE
                ,cdoperad            = vr_cdoperad
           WHERE nrcpfcgc            = pr_nrcpfcgc;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := substr('Erro alterar TBREPORTAVAL_FATCA_CRS - '||sqlerrm,1,1000);
          RAISE vr_exc_saida;
        END;
        --
        IF NVL(rw_reportavel.inreportavel,'.')       <> UPPER(NVL(pr_inreportavel,'.')) THEN
          SELECT vr_dsalteracao
                 ||'Reportavel: '
                 ||NVL(rw_reportavel.inreportavel,'Em Branco')
                 ||' ==> '
                 ||NVL(UPPER(pr_inreportavel),'Em Branco')||chr(10)
            INTO vr_dsalteracao
            FROM DUAL;
        END IF;
        IF NVL(rw_reportavel.cdtipo_declarado,-1)    <> UPPER(NVL(pr_cdtipo_declarado,'.')) THEN
          SELECT vr_dsalteracao
                 ||'Tipo Declarado: '
                 ||NVL(TO_CHAR(rw_reportavel.cdtipo_declarado),'Em Branco')
                 ||' ==> '
                 ||NVL(UPPER(pr_cdtipo_declarado),'Em Branco')||chr(10)
            INTO vr_dsalteracao
            FROM DUAL;
        END IF;
        IF NVL(rw_reportavel.cdtipo_proprietario,-1) <> UPPER(NVL(pr_cdtipo_proprietario,'.')) THEN
          SELECT vr_dsalteracao
                 ||'Tipo Proprietário: '
                 ||NVL(TO_CHAR(rw_reportavel.cdtipo_proprietario),'Em Branco')
                 ||' ==> '
                 ||NVL(UPPER(pr_cdtipo_proprietario),'Em Branco')||chr(10)
            INTO vr_dsalteracao
            FROM DUAL;
        END IF;
        --
        IF vr_dsalteracao IS NOT NULL THEN
          BEGIN
            INSERT INTO tbhist_reportaval_fatca_crs
                   (nrcpfcgc
                   ,nrseq_historico
                   ,dsalteracao
                   ,dtaltera
                   ,cdoperad)
            VALUES (pr_nrcpfcgc
                   ,NULL         -- nrseq_historico
                   ,'Data/Hora alteração: '||TO_CHAR(SYSDATE,'dd/mm/yyyy hh24:mi:ss')||chr(10)||vr_dsalteracao
                   ,SYSDATE      -- dtaltera
                   ,vr_cdoperad);
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := substr('Erro gerar Log Alteracao - '||sqlerrm,1,1000);
            RAISE vr_exc_saida;
          END;
        END IF;
      END IF;
    END LOOP;

    IF vr_idexiste_pessoa = 0 THEN
      vr_dscritic := 'CPF ou CNPJ nao encontrado tabela de reportaveis! (TBREPORTAVAL_FATCA_CRS)';
      RAISE vr_exc_saida;
    END IF;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'REPEXT.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao nos dados de reportabilidade da pessoa' ||
                                                  pr_nrcpfcgc || '.');

    pr_des_erro := 'OK';

    COMMIT;

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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_atualiza_compliance_pessoa).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_atualiza_compliance_pessoa;

  --Buscar os sócios de determinado CNPJ
  PROCEDURE pc_busca_dados_socios(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                 ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                 ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                 ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                 ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                 ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                 ,pr_des_erro     OUT VARCHAR2) IS                            --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_socios
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar os sócios de determinado CNPJ

   Alteracoes:

    ............................................................................. */
    CURSOR cr_socios (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT distinct
           c.nrcpfcgc nrcpfcgc_socio
          ,c.nmpessoa nmpessoa_socio
          ,d.nridentificacao
          ,CASE
             WHEN e.insituacao = 'P' THEN 'PENDENTE'
             WHEN e.insituacao = 'E' THEN 'EM ABERTO'
             WHEN e.insituacao = 'A' THEN 'ANALISADA'
             ELSE
               CASE
                 WHEN d.inobrigacao_exterior = 'N' THEN 'SEM OBRIGACAO'
                 ELSE                                   'NAO INFORMADO'
               END
           END insituacao
          ,CASE
             WHEN e.inreportavel = 'S' THEN 'SIM'
             WHEN e.inreportavel = 'N' THEN 'NAO'
             ELSE                           ''
           END inreportavel
          ,e.cdtipo_declarado
          ,e.cdtipo_proprietario
          ,c.tppessoa
      FROM crapass a
          ,crapavt b
          ,tbcadast_pessoa c
          ,tbcadast_pessoa_estrangeira d
          ,tbreportaval_fatca_crs e
     WHERE a.nrcpfcgc     = pr_nrcpfcgc
       AND a.cdsitdct    <> 4
       AND a.dtdemiss    IS NULL
       AND b.cdcooper     = a.cdcooper
       AND b.nrdconta     = a.nrdconta
       AND b.tpctrato     = 6
       AND b.dsproftl    <> 'PROCURADOR'
       AND b.persocio    >= 10
       AND c.nrcpfcgc (+) = b.nrcpfcgc
       AND d.idpessoa (+) = c.idpessoa
       AND e.nrcpfcgc (+) = b.nrcpfcgc
    UNION
    SELECT distinct
           c.nrcpfcgc nrcpfcgc_socio
          ,c.nmpessoa nmpessoa_socio
          ,d.nridentificacao
          ,CASE
             WHEN e.insituacao = 'P' THEN 'PENDENTE'
             WHEN e.insituacao = 'E' THEN 'EM ABERTO'
             WHEN e.insituacao = 'A' THEN 'ANALISADA'
             ELSE
               CASE
                 WHEN d.inobrigacao_exterior = 'N' THEN 'SEM OBRIGACAO'
                 ELSE                                   'NAO INFORMADO'
               END
           END insituacao
          ,CASE
             WHEN e.inreportavel = 'S' THEN 'SIM'
             WHEN e.inreportavel = 'N' THEN 'NAO'
             ELSE                           ''
           END inreportavel
          ,e.cdtipo_declarado
          ,e.cdtipo_proprietario
          ,c.tppessoa
      FROM crapass a
          ,crapepa b
          ,tbcadast_pessoa c
          ,tbcadast_pessoa_estrangeira d
          ,tbreportaval_fatca_crs e
     WHERE a.nrcpfcgc     = pr_nrcpfcgc
       AND a.cdsitdct    <> 4
       AND a.dtdemiss    IS NULL
       AND b.cdcooper     = a.cdcooper
       AND b.nrdconta     = a.nrdconta
       AND b.persocio    >= 10
       AND c.nrcpfcgc (+) = b.nrdocsoc 
       AND d.idpessoa (+) = c.idpessoa
       AND e.nrcpfcgc (+) = b.nrdocsoc;

    CURSOR cr_conta_socio (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT LPAD(cdcooper,3,'0') cdcooper
          ,nrdconta
      FROM crapass a
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL
       AND ROWNUM = 1;
    rw_conta_socio cr_conta_socio%ROWTYPE;

    CURSOR cr_crapdoc (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE
                      ,pr_tpdocmto1    IN crapdoc.tpdocmto%TYPE
                      ,pr_tpdocmto2    IN crapdoc.tpdocmto%TYPE) IS
    SELECT NVL(MIN(flgdigit),9) flgdigit
      FROM crapdoc a
     WHERE nrcpfcgc  = pr_nrcpfcgc
       AND (tpdocmto = pr_tpdocmto1
         OR tpdocmto = pr_tpdocmto2);
    rw_crapdoc cr_crapdoc%ROWTYPE;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

    --Variaveis de trabalho
    vr_nrcpfcgc_socio VARCHAR2(100);
    vr_dsdigidoc    VARCHAR2(03);
    vr_tpdocmto1    NUMBER;
    vr_tpdocmto2    NUMBER;

  BEGIN -- Inicio pc_busca_dados_socios
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_socios IN cr_socios(pr_nrcpfcgc     => pr_nrcpfcgc) LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      -- Buscar a Cooperativa e conta da pessoa (será utilizada na pesquisa do DIGIDOC (DIGI0001))
      OPEN cr_conta_socio (pr_nrcpfcgc     => rw_socios.nrcpfcgc_socio);
      FETCH cr_conta_socio INTO rw_conta_socio;
      IF cr_conta_socio%NOTFOUND THEN
        rw_conta_socio.cdcooper := 0;
        rw_conta_socio.nrdconta := 0;
      END IF;
      CLOSE cr_conta_socio;

      TELA_FATCA_CRS.pc_buscar_tpdocmto_digidoc(pr_insocio   => 'S'
                                               ,pr_tpdocmto1 => vr_tpdocmto1
                                               ,pr_tpdocmto2 => vr_tpdocmto2);

      OPEN cr_crapdoc (pr_nrcpfcgc     => pr_nrcpfcgc
                      ,pr_tpdocmto1    => vr_tpdocmto1
                      ,pr_tpdocmto2    => vr_tpdocmto2);
      FETCH cr_crapdoc INTO rw_crapdoc;
      IF cr_crapdoc%NOTFOUND THEN
        rw_crapdoc.flgdigit := 9;
      END IF;
      CLOSE cr_crapdoc;

      IF rw_crapdoc.flgdigit IN (0, 9) THEN
        vr_dsdigidoc := 'NAO';
      ELSE
        vr_dsdigidoc := 'SIM';
      END IF;

      vr_nrcpfcgc_socio := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_socios.nrcpfcgc_socio
                                                    ,pr_inpessoa => rw_socios.tppessoa);
      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext' ,pr_posicao => 0          , pr_tag_nova => 'dados_socios'       , pr_tag_cont => NULL                         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc_socio'     , pr_tag_cont => vr_nrcpfcgc_socio            , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa_socio'     , pr_tag_cont => rw_socios.nmpessoa_socio     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'inreportavel'       , pr_tag_cont => rw_socios.inreportavel       , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'nridentificacao'    , pr_tag_cont => rw_socios.nridentificacao    , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_proprietario', pr_tag_cont => rw_socios.cdtipo_proprietario, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_declarado'   , pr_tag_cont => rw_socios.cdtipo_declarado   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'insituacao'         , pr_tag_cont => rw_socios.insituacao         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'cdcooper'           , pr_tag_cont => rw_conta_socio.cdcooper      , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta'           , pr_tag_cont => rw_conta_socio.nrdconta      , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'dsdigidoc'          , pr_tag_cont => vr_dsdigidoc                 , pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;

      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_socios).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_socios;

  --Buscar os sócios de determinado CNPJ
  PROCEDURE pc_busca_dados_comp_socio(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                     ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                     ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                     ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                     ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                     ,pr_des_erro     OUT VARCHAR2) IS                            --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_comp_socio
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar dados complementares do sócio

   Alteracoes:

    ............................................................................. */
    CURSOR cr_compl_socios (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT a.cdpais cdpais_nif
          ,b.cdpais cdpais_exterior
          ,a.nmpais nmpais_nif
          ,b.nmpais nmpais_exterior
          ,d.nridentificacao
          ,a.inacordo
      FROM crapnac a
          ,crapnac b
          ,tbcadast_pessoa c
          ,tbcadast_pessoa_estrangeira d
     WHERE c.nrcpfcgc = pr_nrcpfcgc
       AND d.idpessoa = c.idpessoa
       AND a.cdnacion = d.cdpais
       AND b.cdnacion (+) = d.cdpais_exterior;

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

    --Variaveis de controle

    --Variaveis de trabalho

  BEGIN -- Inicio pc_busca_dados_comp_socio
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_compl_socios IN cr_compl_socios(pr_nrcpfcgc     => pr_nrcpfcgc) LOOP
      --Numero Registros
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'     ,pr_posicao => 0          , pr_tag_nova => 'dado_compl_socio'   , pr_tag_cont => NULL                               , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais_nif'         , pr_tag_cont => rw_compl_socios.cdpais_nif         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais_nif'         , pr_tag_cont => rw_compl_socios.nmpais_nif         , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'nridentificacao'    , pr_tag_cont => rw_compl_socios.nridentificacao    , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais_exterior'    , pr_tag_cont => rw_compl_socios.cdpais_exterior    , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais_exterior'    , pr_tag_cont => rw_compl_socios.nmpais_exterior    , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dado_compl_socio',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo'           , pr_tag_cont => rw_compl_socios.inacordo           , pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;


    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
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
      pr_dscritic := 'Erro (TELA_REPEXT.PC_BUSCA_DADOS_COMP_SOCIO).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_comp_socio;

  --Buscar o histórico de alterações da tabela TBREPORTAVAL_FATCA_CRS
  PROCEDURE pc_busca_dados_historico(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                    ,pr_nrregist     IN INTEGER                                  --> Quantidade de registros
                                    ,pr_nriniseq     IN INTEGER                                  --> Qunatidade inicial
                                    ,pr_xmllog       IN VARCHAR2                                 --> XML com informações de LOG
                                    ,pr_cdcritic     OUT PLS_INTEGER                             --> Código da crítica
                                    ,pr_dscritic     OUT VARCHAR2                                --> Descrição da crítica
                                    ,pr_retxml       IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                                    ,pr_nmdcampo     OUT VARCHAR2                                --> Nome do campo com erro
                                    ,pr_des_erro     OUT VARCHAR2) IS                            --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_historico
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar o histórico de alterações da tabela TBREPORTAVAL_FATCA_CRS

   Alteracoes:

    ............................................................................. */
    CURSOR cr_historico (pr_nrcpfcgc     IN tbreportaval_fatca_crs.nrcpfcgc%TYPE) IS
    SELECT nrcpfcgc
          ,dsalteracao
          ,TO_CHAR(dtaltera,'dd/mm/yyyy hh24:mi:ss') dtaltera
          ,cdoperad
      FROM tbhist_reportaval_fatca_crs a
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
     ORDER BY nrseq_historico desc ;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

    --Variaveis de trabalho

  BEGIN -- Inicio pc_busca_dados_historico
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_historico IN cr_historico(pr_nrcpfcgc     => pr_nrcpfcgc) LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext' ,pr_posicao => 0          , pr_tag_nova => 'dados_socios', pr_tag_cont => NULL                    , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc'    , pr_tag_cont => rw_historico.nrcpfcgc   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'dsalteracao' , pr_tag_cont => rw_historico.dsalteracao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'dtaltera'    , pr_tag_cont => rw_historico.dtaltera   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_socios',pr_posicao => vr_auxconta, pr_tag_nova => 'cdoperad'    , pr_tag_cont => rw_historico.cdoperad   , pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dados_historico).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_historico;

  --Buscar os domínios na tabela de domínios
  PROCEDURE pc_busca_dominio_tipo(pr_idtipo_dominio     IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE --> Tipo de domínio (Declarado, Proprietário)
                                 ,pr_cdtipo_dominio     IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE --> Código do domínio
                                 ,pr_insituacao         IN VARCHAR2 DEFAULT 'T'                         --> Situação a ser pesquisada (T=Todas, A=Ativas, I=Inativas)
                                 ,pr_nrregist           IN INTEGER                                      --> Quantidade de registros
                                 ,pr_nriniseq           IN INTEGER                                      --> Qunatidade inicial
                                 ,pr_xmllog             IN VARCHAR2                                     --> XML com informações de LOG
                                 ,pr_cdcritic           OUT PLS_INTEGER                                 --> Código da crítica
                                 ,pr_dscritic           OUT VARCHAR2                                    --> Descrição da crítica
                                 ,pr_retxml             IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                 ,pr_nmdcampo           OUT VARCHAR2                                    --> Nome do campo com erro
                                 ,pr_des_erro           OUT VARCHAR2) IS                                --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dominio_tipo
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar os domínios na tabela de domínios

   Alteracoes:

    ............................................................................. */
    CURSOR cr_dominio (pr_idtipo_dominio     IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE
                      ,pr_cdtipo_dominio     IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE
                      ,pr_insituacao         IN VARCHAR2) IS
    SELECT cdtipo_dominio
          ,dstipo_dominio
          ,inexige_proprietario
          ,insituacao
          ,DECODE(inexige_proprietario,'S','SIM','NÃO') dsexige_proprietario
          ,DECODE(insituacao,'I','INATIVO','ATIVO') dssituacao
      FROM tbdominio_tipo_fatca_crs a
     WHERE idtipo_dominio = pr_idtipo_dominio
       AND cdtipo_dominio = NVL(pr_cdtipo_dominio, cdtipo_dominio)
       AND insituacao     = DECODE(pr_insituacao,'T',insituacao,pr_insituacao)
     ORDER BY cdtipo_dominio;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

    --Variaveis de trabalho

  BEGIN -- Inicio pc_busca_dominio_tipo
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_dominio IN cr_dominio(pr_idtipo_dominio => pr_idtipo_dominio
                                ,pr_cdtipo_dominio => pr_cdtipo_dominio
                                ,pr_insituacao     => pr_insituacao) LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext'  ,pr_posicao => 0          , pr_tag_nova => 'dados_dominio'       , pr_tag_cont => NULL                           , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'cdtipo_dominio'      , pr_tag_cont => rw_dominio.cdtipo_dominio      , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'dstipo_dominio'      , pr_tag_cont => rw_dominio.dstipo_dominio      , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'inexige_proprietario', pr_tag_cont => rw_dominio.inexige_proprietario, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'insituacao'          , pr_tag_cont => rw_dominio.insituacao          , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'dsexige_proprietario', pr_tag_cont => rw_dominio.dsexige_proprietario, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_dominio',pr_posicao => vr_auxconta, pr_tag_nova => 'dssituacao'          , pr_tag_cont => rw_dominio.dssituacao          , pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_busca_dominio_tipo).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dominio_tipo;

  --Atualizar os domínios na tabela de domínios
  PROCEDURE pc_atualiza_dominio_tipo(pr_idtipo_dominio       IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE       --> Tipo de domínio (Declarado, Proprietário)
                                    ,pr_inoperacao           IN VARCHAR2                                           --> Tipo de operação (Inclusão, Alteração)
                                    ,pr_cdtipo_dominio       IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE       --> Código do domínio
                                    ,pr_dstipo_dominio       IN tbdominio_tipo_fatca_crs.dstipo_dominio%TYPE       --> Descrição do domínio
                                    ,pr_inexige_proprietario IN tbdominio_tipo_fatca_crs.inexige_proprietario%TYPE --> Exige Tipo Proprietário
                                    ,pr_insituacao           IN tbdominio_tipo_fatca_crs.insituacao%TYPE           --> Situação (Ativo, Inativo)
                                    ,pr_xmllog               IN VARCHAR2                                           --> XML com informações de LOG
                                    ,pr_cdcritic             OUT PLS_INTEGER                                       --> Código da crítica
                                    ,pr_dscritic             OUT VARCHAR2                                          --> Descrição da crítica
                                    ,pr_retxml               IN OUT NOCOPY XMLType                                 --> Arquivo de retorno do XML
                                    ,pr_nmdcampo             OUT VARCHAR2                                          --> Nome do campo com erro
                                    ,pr_des_erro             OUT VARCHAR2) IS                                      --> Erros do processo

  /* .............................................................................
   Programa: pc_atualiza_dominio_tipo
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Atualizar os domínios na tabela de domínios

   Alteracoes:

    ............................................................................. */
    CURSOR cr_dominio (pr_idtipo_dominio     IN tbdominio_tipo_fatca_crs.idtipo_dominio%TYPE
                      ,pr_cdtipo_dominio     IN tbdominio_tipo_fatca_crs.cdtipo_dominio%TYPE) IS
    SELECT *
      FROM tbdominio_tipo_fatca_crs a
     WHERE idtipo_dominio = pr_idtipo_dominio
       AND cdtipo_dominio = pr_cdtipo_dominio;

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

    --Variaveis de controle

    --Variaveis de trabalho
    vr_inexiste_dominio NUMBER;

  BEGIN -- Inicio pc_atualiza_dominio_tipo

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    vr_inexiste_dominio := 0;

    IF pr_inoperacao = 'I' THEN
      BEGIN
        INSERT INTO tbdominio_tipo_fatca_crs
               (idtipo_dominio
               ,cdtipo_dominio
               ,dstipo_dominio
               ,inexige_proprietario
               ,insituacao
               ,dtaltera
               ,cdoperad)
        VALUES (pr_idtipo_dominio
               ,UPPER(pr_cdtipo_dominio)
               ,UPPER(pr_dstipo_dominio)
               ,UPPER(pr_inexige_proprietario)
               ,UPPER(pr_insituacao)
               ,SYSDATE     --dtaltera
               ,vr_cdoperad);
        vr_inexiste_dominio := 1;
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := substr('Erro incluir o Dominio - '||sqlerrm,1,1000);
        RAISE vr_exc_saida;
      END;
    ELSE
      vr_inexiste_dominio := 0;

      FOR rw_dominio IN cr_dominio(pr_idtipo_dominio => pr_idtipo_dominio
                                  ,pr_cdtipo_dominio => UPPER(pr_cdtipo_dominio)) LOOP
        vr_inexiste_dominio := 1;
        IF rw_dominio.dstipo_dominio       <> UPPER(pr_dstipo_dominio)
        OR rw_dominio.inexige_proprietario <> UPPER(pr_inexige_proprietario)
        OR rw_dominio.insituacao           <> UPPER(pr_insituacao)
        THEN
          BEGIN
            UPDATE tbdominio_tipo_fatca_crs
               SET dstipo_dominio       = UPPER(pr_dstipo_dominio)
                  ,inexige_proprietario = UPPER(pr_inexige_proprietario)
                  ,insituacao           = UPPER(pr_insituacao)
                  ,dtaltera             = SYSDATE
                  ,cdoperad             = vr_cdoperad
             WHERE idtipo_dominio       = pr_idtipo_dominio
               AND cdtipo_dominio       = UPPER(pr_cdtipo_dominio);
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := substr('Erro alterar o Doínio - '||sqlerrm,1,1000);
            RAISE vr_exc_saida;
          END;
        END IF;
      END LOOP;
      --
      IF vr_inexiste_dominio = 0 THEN
        vr_dscritic := 'Dominio nao encontrado no cadastro! (TBDOMINIO_TIPO_FATCA_CRS)';
        RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_inexiste_dominio = 0 THEN
      vr_dscritic := 'CPF ou CNPJ nao encontrado tabela de reportaveis! (TBREPORTAVAL_FATCA_CRS)';
      RAISE vr_exc_saida;
    END IF;

    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'REPEXT.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao nos dados de dominio - ' ||
                                                  pr_idtipo_dominio||'-'||UPPER(pr_cdtipo_dominio) || '.');

    pr_des_erro := 'OK';

    COMMIT;

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
      pr_dscritic := 'Erro (TELA_REPEXT.pc_atualiza_dominio_tipo).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_atualiza_dominio_tipo;

  --Buscar CPF/CNPJ existentes na tabela TBREPORTAVAL_FATCA_CRS
  PROCEDURE pc_busca_pessoas_reportaveis(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE DEFAULT 0    --> CPF ou CGC da pessoa
                                        ,pr_nmpessoa     IN tbcadast_pessoa.nmpessoa%TYPE DEFAULT NULL --> Nome da pessoa
                                        ,pr_nrregist     IN INTEGER                                    --> Quantidade de registros
                                        ,pr_nriniseq     IN INTEGER                                    --> Qunatidade inicial
                                        ,pr_xmllog       IN VARCHAR2                                   --> XML com informações de LOG
                                        ,pr_cdcritic     OUT PLS_INTEGER                               --> Código da crítica
                                        ,pr_dscritic     OUT VARCHAR2                                  --> Descrição da crítica
                                        ,pr_retxml       IN OUT NOCOPY XMLType                         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo     OUT VARCHAR2                                  --> Nome do campo com erro
                                        ,pr_des_erro     OUT VARCHAR2) IS                              --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_pessoas_reportaveis
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar CPF/CNPJ existentes na tabela TBREPORTAVAL_FATCA_CRS

   Alteracoes:

    ............................................................................. */
    CURSOR cr_pessoas IS
    SELECT a.nrcpfcgc
          ,b.nmpessoa
      FROM tbreportaval_fatca_crs a
          ,tbcadast_pessoa b
     WHERE a.nrcpfcgc    = b.nrcpfcgc
       AND b.nrcpfcgc    = DECODE(pr_nrcpfcgc,0,b.nrcpfcgc,pr_nrcpfcgc)
       AND b.nmpessoa like '%'||UPPER(pr_nmpessoa)||'%'
     ORDER BY 1;

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

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

  BEGIN -- Inicio pc_busca_pessoas_reportaveis
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_REPEXT'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'tela_repext',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    --Loop nas nacionalidades
    FOR rw_pessoas IN cr_pessoas LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tela_repext' ,pr_posicao => 0     , pr_tag_nova => 'pessoas' , pr_tag_cont => NULL               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'pessoas',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_pessoas.nrcpfcgc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'pessoas',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa', pr_tag_cont => rw_pessoas.nmpessoa, pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tela_repext'       --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
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
      pr_dscritic := 'Erro (TELA_REPEXT.PC_BUSCA_PESSOAS_REPORTAVEIS).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_pessoas_reportaveis;
END TELA_REPEXT;
/
