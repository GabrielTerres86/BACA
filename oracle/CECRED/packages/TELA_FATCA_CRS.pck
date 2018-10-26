CREATE OR REPLACE PACKAGE CECRED.TELA_FATCA_CRS AS

   /*
   Programa: TELA_FATCA_CRS                          antigo:
   Sistema : Compliance
   Sigla   : CRED

   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                              Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Mostrar a tela FATCA_CRS para permitir o gerenciamento de informações das pessoas

   Alteracoes:

   */

  --Buscar as informações de FATCA/CRS da pessoa
  PROCEDURE pc_busca_dados_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                    ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                                    ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Buscar as informações de FATCA/CRS dos sócios da empresa
  PROCEDURE pc_busca_dados_socio_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                          ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                                          ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                                          ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Atualizar as informações de FATCA/CRS da pessoa
  PROCEDURE pc_atualiza_dados_fatca_crs(pr_nrcpfcgc             IN tbcadast_pessoa.nrcpfcgc%TYPE                         --> CPF ou CGC da pessoa
                                       ,pr_inobrigacao_exterior IN tbcadast_pessoa_estrangeira.inobrigacao_exterior%TYPE --> Possui domicílio ou obrigação fiscal fora do país
                                       ,pr_cdpais               IN crapnac.cdpais%TYPE                                   --> Código do pais no FATCA/CRS
                                       ,pr_nridentificacao      IN tbcadast_pessoa_estrangeira.nridentificacao%TYPE      --> Numero identificacao fiscal
                                       ,pr_insocio_obrigacao    IN tbcadast_pessoa_estrangeira.insocio_obrigacao%TYPE    --> Possui algum sócio ou acionista estrangeiro que individualmente possua mais de 10% de capital
                                       ,pr_cdpais_exterior      IN crapnac.cdpais%TYPE                                   --> Código do pais aonde possui domicílio ou obrigação fiscal fora do país
                                       ,pr_dscodigo_postal      IN tbcadast_pessoa_estrangeira.dscodigo_postal%TYPE      --> Número do código posta do endereço no exterior
                                       ,pr_nmlogradouro         IN tbcadast_pessoa_estrangeira.nmlogradouro%TYPE         --> Nome do logradouro
                                       ,pr_nrlogradouro         IN VARCHAR2                                              --> Número do logradouro
                                       ,pr_dscomplemento        IN tbcadast_pessoa_estrangeira.dscomplemento%TYPE        --> Complemento do logradouro
                                       ,pr_dscidade             IN tbcadast_pessoa_estrangeira.dscidade%TYPE             --> Nome da cidade do endereço no exterior
                                       ,pr_dsestado             IN tbcadast_pessoa_estrangeira.dsestado%TYPE             --> Nome da estado do endereço no exterior
                                       ,pr_insocio              IN VARCHAR2                                              --> Indica se o CPF é de um sócio de uma CNPJ
                                       ,pr_nrdconta             IN crapass.nrdconta%TYPE                                 --> Número da conta aonde foi feito a alteração de FATCA/CRS
                                       ,pr_xmllog               IN VARCHAR2                                              --> XML com informações de LOG
                                       ,pr_cdcritic             OUT PLS_INTEGER                                          --> Código da crítica
                                       ,pr_dscritic             OUT VARCHAR2                                             --> Descrição da crítica
                                       ,pr_retxml               IN OUT NOCOPY XMLType                                    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo             OUT VARCHAR2                                             --> Nome do campo com erro
                                       ,pr_des_erro             OUT VARCHAR2);                                           --> Erros do processo

  --Buscar os paises da tabela CRAPNAC
  PROCEDURE pc_busca_paises(pr_inacordo IN VARCHAR2                      --> Buscar paises que tem acordo FATCA/CRS (S=Sim, N=Não)
                           ,pr_cdpais   IN crapnac.cdpais%TYPE           --> Código do pais
                           ,pr_dspais   IN crapnac.nmpais%TYPE           --> Descrição do pais
                           ,pr_cdpais_exterior   IN crapnac.cdpais%TYPE           --> Código do pais
                           ,pr_dspais_exterior   IN crapnac.nmpais%TYPE           --> Descrição do pais
                           ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                           ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Validar o país na tabela CRAPNAC
  PROCEDURE pc_valida_pais(pr_cdpais   IN crapnac.cdpais%TYPE           --> Código do pais no FATCA/CRS
                          ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                          ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                          ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  --Tratar a mudança para não da informação de "Possui obrigação no exterior"
  PROCEDURE pc_tratar_fatca_crs_para_nao(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                        ,pr_inreportavel IN VARCHAR2                                 --> Indicador de Reportável (Sim, Não)
                                        ,pr_cdcritic    OUT PLS_INTEGER                              --> Código da crítica
                                        ,pr_dscritic    OUT VARCHAR2);                               --> Descrição da crítica


  PROCEDURE pc_buscar_tpdocmto_digidoc(pr_insocio   IN VARCHAR2
                                      ,pr_intem_nif IN  VARCHAR2 DEFAULT 'S'
                                      ,pr_tpdocmto1 OUT NUMBER
                                      ,pr_tpdocmto2 OUT NUMBER);

  PROCEDURE pc_tratar_alteracao_pais(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                    ,pr_cdpais_old   IN crapnac.cdpais%TYPE                      --> Código do pais antes da alteração
                                    ,pr_cdpais_new   IN crapnac.cdpais%TYPE                      --> Código do pais após da alteração
                                    ,pr_cdoperad     IN VARCHAR2                                 --> Operador que fez a alteração
                                    ,pr_cdcritic    OUT PLS_INTEGER                              --> Código da crítica
                                    ,pr_dscritic    OUT VARCHAR2);                               --> Descrição da crítica
END TELA_FATCA_CRS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_FATCA_CRS AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_FATCA_CRS                          antigo:
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano - CECRED
   Data    : Junho/2017                       Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Buscar as informações de FATCA/CRS da pessoa

   Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

  --Buscar as informações de FATCA/CRS da pessoa
  PROCEDURE pc_busca_dados_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                    ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                                    ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_fatca_crs
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar as informações de FATCA/CRS da pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_tbcadast_pessoa (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT idpessoa
      FROM tbcadast_pessoa
     WHERE nrcpfcgc = pr_nrcpfcgc;

    CURSOR cr_tbcadast_pessoa_estrangeira (pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT a.inobrigacao_exterior
          ,b.cdpais
          ,b.nmpais
          ,b.inacordo
          ,a.nridentificacao
          ,a.insocio_obrigacao
          ,a.dscidade
          ,a.dsestado
          ,a.cdpais_exterior
          ,a.dscodigo_postal
          ,a.nmlogradouro
          ,CASE
             WHEN LENGTH(a.nrlogradouro) > 3 THEN
               LTRIM(SUBSTR(LPAD(a.nrlogradouro,10,' '),1,7)||'.'||SUBSTR(LPAD(a.nrlogradouro,10,' '),8,3))
             ELSE
               TO_CHAR(a.nrlogradouro)
           END nrlogradouro
          ,a.dscomplemento
      FROM tbcadast_pessoa_estrangeira a
          ,crapnac b
     WHERE a.idpessoa   = pr_idpessoa
       AND b.cdnacion   = a.cdpais;
    rw_tbcadast_pessoa_estrangeira cr_tbcadast_pessoa_estrangeira%ROWTYPE;

    CURSOR cr_pais_exterior (pr_cdpais_exterior IN tbcadast_pessoa_estrangeira.cdpais_exterior%TYPE) IS
    SELECT cdpais cdpais_exterior
          ,nmpais nmpais_exterior
      FROM crapnac
     WHERE cdnacion = pr_cdpais_exterior;
    rw_pais_exterior cr_pais_exterior%ROWTYPE;

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
    vr_inobrigacao_exterior tbcadast_pessoa_estrangeira.inobrigacao_exterior%TYPE;
    vr_cdpais               crapnac.cdpais%TYPE;
    vr_nmpais               crapnac.nmpais%TYPE;
    vr_inacordo             crapnac.inacordo%TYPE;
    vr_nridentificacao      tbcadast_pessoa_estrangeira.nridentificacao%TYPE;
    vr_insocio_obrigacao    tbcadast_pessoa_estrangeira.insocio_obrigacao%TYPE;
    vr_cdpais_exterior      crapnac.cdpais%TYPE;
    vr_nmpais_exterior      crapnac.nmpais%TYPE;
    vr_dscodigo_postal      tbcadast_pessoa_estrangeira.dscodigo_postal%TYPE;
    vr_nmlogradouro         tbcadast_pessoa_estrangeira.nmlogradouro%TYPE;
    vr_nrlogradouro         VARCHAR2(11);
    vr_dscomplemento        tbcadast_pessoa_estrangeira.dscomplemento%TYPE;
    vr_dscidade             tbcadast_pessoa_estrangeira.dscidade%TYPE;
    vr_dsestado             tbcadast_pessoa_estrangeira.dsestado%TYPE;
    vr_pais_exterior        tbcadast_pessoa_estrangeira.cdpais_exterior%TYPE;

  BEGIN -- Inicio pc_busca_dados_fatca_crs
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'FATCA_CRS'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'fatca_crs',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    vr_inobrigacao_exterior := NULL;
    vr_cdpais               := NULL;
    vr_nmpais               := NULL;
    vr_inacordo             := NULL;
    vr_nridentificacao      := NULL;
    vr_insocio_obrigacao    := NULL;
    vr_cdpais_exterior      := NULL;
    vr_nmpais_exterior      := NULL;
    vr_dscodigo_postal      := NULL;
    vr_nmlogradouro         := NULL;
    vr_nrlogradouro         := NULL;
    vr_dscomplemento        := NULL;
    vr_dscidade             := NULL;
    vr_dsestado             := NULL;
    vr_pais_exterior        := NULL;

    FOR rw_tbcadast_pessoa IN cr_tbcadast_pessoa (pr_nrcpfcgc => pr_nrcpfcgc) LOOP

      OPEN cr_tbcadast_pessoa_estrangeira (pr_idpessoa => rw_tbcadast_pessoa.idpessoa);

      FETCH cr_tbcadast_pessoa_estrangeira INTO rw_tbcadast_pessoa_estrangeira;
      IF cr_tbcadast_pessoa_estrangeira%FOUND THEN
        vr_inobrigacao_exterior := rw_tbcadast_pessoa_estrangeira.inobrigacao_exterior;
        vr_cdpais               := rw_tbcadast_pessoa_estrangeira.cdpais;
        vr_nmpais               := rw_tbcadast_pessoa_estrangeira.nmpais;
        vr_inacordo             := rw_tbcadast_pessoa_estrangeira.inacordo;
        vr_nridentificacao      := rw_tbcadast_pessoa_estrangeira.nridentificacao;
        vr_insocio_obrigacao    := rw_tbcadast_pessoa_estrangeira.insocio_obrigacao;
        vr_dscidade             := rw_tbcadast_pessoa_estrangeira.dscidade;
        vr_dsestado             := rw_tbcadast_pessoa_estrangeira.dsestado;
        vr_pais_exterior        := rw_tbcadast_pessoa_estrangeira.cdpais_exterior;
        vr_dscodigo_postal      := rw_tbcadast_pessoa_estrangeira.dscodigo_postal;
        vr_nmlogradouro         := rw_tbcadast_pessoa_estrangeira.nmlogradouro;
        vr_nrlogradouro         := rw_tbcadast_pessoa_estrangeira.nrlogradouro;
        vr_dscomplemento        := rw_tbcadast_pessoa_estrangeira.dscomplemento;
      END IF;
      CLOSE cr_tbcadast_pessoa_estrangeira;

      -- Limpar o campo CDPAIS se INOBRIGACAO_EXTERIOR = 'N',
      -- pois o campo é obrigatório na TBCADAST_PESSOA_ESTRANGEIRA e é populado com a mesma nacionalidade da CRAPASS se o PR_CDPAIS esta em branco.
      --
      IF NVL(vr_inobrigacao_exterior,'N') = 'N' THEN
        vr_cdpais := null;
        vr_nmpais := null;
      END IF;
      --
      IF vr_pais_exterior IS NOT NULL THEN

        OPEN cr_pais_exterior (pr_cdpais_exterior => vr_pais_exterior);

        FETCH cr_pais_exterior INTO rw_pais_exterior;
        IF cr_pais_exterior%FOUND THEN
          vr_cdpais_exterior := rw_pais_exterior.cdpais_exterior;
          vr_nmpais_exterior := rw_pais_exterior.nmpais_exterior;
        END IF;
        CLOSE cr_pais_exterior;
      END IF;

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
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'fatca_crs'      ,pr_posicao => 0          , pr_tag_nova => 'dados_fatca_crs'     , pr_tag_cont => NULL                   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'inobrigacao_exterior', pr_tag_cont => vr_inobrigacao_exterior, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais'              , pr_tag_cont => vr_cdpais              , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais'              , pr_tag_cont => vr_nmpais              , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nridentificacao'     , pr_tag_cont => vr_nridentificacao     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'insocio_obrigacao'   , pr_tag_cont => vr_insocio_obrigacao   , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais_exterior'     , pr_tag_cont => vr_cdpais_exterior     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais_exterior'     , pr_tag_cont => vr_nmpais_exterior     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dscodigo_postal'     , pr_tag_cont => vr_dscodigo_postal     , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmlogradouro'        , pr_tag_cont => vr_nmlogradouro        , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nrlogradouro'        , pr_tag_cont => vr_nrlogradouro        , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dscomplemento'       , pr_tag_cont => vr_dscomplemento       , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dscidade'            , pr_tag_cont => vr_dscidade            , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'dsestado'            , pr_tag_cont => vr_dsestado            , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo'            , pr_tag_cont => vr_inacordo            , pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP; -- cr_tbcadast_pessoa

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'fatca_crs'         --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_FATCA_CRS.pc_busca_dados_fatca_crs).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_fatca_crs;

  --Buscar as informações de FATCA/CRS dos sócios da empresa
  PROCEDURE pc_busca_dados_socio_fatca_crs(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE --> CPF ou CGC da pessoa
                                          ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                                          ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                                          ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_busca_dados_socio_fatca_crs
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar as informações de FATCA/CRS dos sócios da empresa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_socios (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT DISTINCT
           a.nrcpfcgc nrcpfcgc_socio
      FROM crapavt a
          ,crapass b
     WHERE b.nrcpfcgc  = pr_nrcpfcgc
       AND b.cdsitdct <> 4
       AND b.dtdemiss is null
       AND a.cdcooper  = b.CDCOOPER
       AND a.nrdconta  = b.NRDCONTA
       AND a.tpctrato  = 6
       AND a.dsproftl <> 'PROCURADOR'
       AND a.persocio >= 10
    UNION
    SELECT DISTINCT
           x.nrdocsoc nrcpfcgc_socio
      FROM crapepa x
          ,crapass z
     WHERE z.nrcpfcgc  = pr_nrcpfcgc
       AND z.cdsitdct <> 4
       AND z.dtdemiss is null
       AND x.cdcooper  = z.CDCOOPER
       AND x.nrdconta  = z.NRDCONTA
       AND x.persocio >= 10
     ORDER BY 1;

    CURSOR cr_tbcadast_pessoa_socio (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT SUBSTR(a.nmpessoa,1,30) nmpessoa_socio
          ,CASE
             WHEN b.inobrigacao_exterior = 'S' THEN 'SIM'
             WHEN b.inobrigacao_exterior = 'N' THEN 'NAO'
             ELSE                                   ''
           END inobrigacao_exterior
          ,b.nridentificacao
          ,b.cdpais
          ,b.cdpais_exterior
          ,a.tppessoa
      FROM tbcadast_pessoa a
          ,tbcadast_pessoa_estrangeira b
     WHERE a.nrcpfcgc = pr_nrcpfcgc
       AND a.idpessoa = b.idpessoa (+);

    CURSOR cr_pais_socio (pr_cdnacion IN crapnac.cdnacion%TYPE) IS
    SELECT cdpais
      FROM crapnac
     WHERE cdnacion = pr_cdnacion;
    rw_pais_socio cr_pais_socio%ROWTYPE;

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
    vr_cdpais_nif      crapnac.cdpais%TYPE;
    vr_cdpais_exterior crapnac.cdpais%TYPE;
    vr_nrcpfcgc_socio  VARCHAR2(100);

  BEGIN -- Inicio pc_busca_dados_socio_fatca_crs

    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'FATCA_CRS'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'fatca_crs_socio',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    FOR rw_socios IN cr_socios (pr_nrcpfcgc => pr_nrcpfcgc) LOOP
      vr_cdpais_nif := NULL;
      --Loop dos sócios
      FOR rw_tbcadast_pessoa_socio IN cr_tbcadast_pessoa_socio (pr_nrcpfcgc => rw_socios.nrcpfcgc_socio) LOOP
        vr_nrcpfcgc_socio := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_socios.nrcpfcgc_socio
                                                      ,pr_inpessoa => rw_tbcadast_pessoa_socio.tppessoa);

        IF NVL(rw_tbcadast_pessoa_socio.inobrigacao_exterior,'NAO') = 'NAO' THEN
          rw_tbcadast_pessoa_socio.cdpais := NULL;
        END IF;

        IF rw_tbcadast_pessoa_socio.cdpais IS NOT NULL THEN
          OPEN cr_pais_socio (pr_cdnacion => rw_tbcadast_pessoa_socio.cdpais);

          FETCH cr_pais_socio INTO rw_pais_socio;
          IF cr_pais_socio%FOUND THEN
            vr_cdpais_nif := rw_pais_socio.cdpais;
          ELSE
            vr_cdpais_nif := NULL;
          END IF;
          CLOSE cr_pais_socio;
        END IF;

        IF rw_tbcadast_pessoa_socio.cdpais_exterior IS NOT NULL THEN
          OPEN cr_pais_socio (pr_cdnacion => rw_tbcadast_pessoa_socio.cdpais_exterior);

          FETCH cr_pais_socio INTO rw_pais_socio;
          IF cr_pais_socio%FOUND THEN
            vr_cdpais_exterior := rw_pais_socio.cdpais;
          ELSE
            vr_cdpais_exterior := NULL;
          END IF;
          CLOSE cr_pais_socio;
        END IF;

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
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'fatca_crs_socio', pr_posicao => 0          , pr_tag_nova => 'socios_fatca_crs'    , pr_tag_cont => NULL                                          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'socios_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc_socio'      , pr_tag_cont => vr_nrcpfcgc_socio                             , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'socios_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpessoa_socio'      , pr_tag_cont => rw_tbcadast_pessoa_socio.nmpessoa_socio       , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'socios_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'inobrigacao_exterior', pr_tag_cont => rw_tbcadast_pessoa_socio.inobrigacao_exterior , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'socios_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais_nif'          , pr_tag_cont => vr_cdpais_nif                                 , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'socios_fatca_crs',pr_posicao => vr_auxconta, pr_tag_nova => 'nridentificacao'     , pr_tag_cont => rw_tbcadast_pessoa_socio.nridentificacao      , pr_des_erro => vr_dscritic);
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := nvl(vr_auxconta,0) + 1;

        END IF;

        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;

      END LOOP;
    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'fatca_crs_socio'   --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_FATCA_CRS.PC_BUSCA_DADOS_SOCIO_FATCA_CRS).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_dados_socio_fatca_crs;

  --Atualizar as informações de FATCA/CRS da pessoa
  PROCEDURE pc_atualiza_dados_fatca_crs(pr_nrcpfcgc             IN tbcadast_pessoa.nrcpfcgc%TYPE                         --> CPF ou CGC da pessoa
                                       ,pr_inobrigacao_exterior IN tbcadast_pessoa_estrangeira.inobrigacao_exterior%TYPE --> Possui domicílio ou obrigação fiscal fora do país
                                       ,pr_cdpais               IN crapnac.cdpais%TYPE                                   --> Código do pais no FATCA/CRS
                                       ,pr_nridentificacao      IN tbcadast_pessoa_estrangeira.nridentificacao%TYPE      --> Numero identificacao fiscal
                                       ,pr_insocio_obrigacao    IN tbcadast_pessoa_estrangeira.insocio_obrigacao%TYPE    --> Possui algum sócio ou acionista estrangeiro que individualmente possua mais de 10% de capital
                                       ,pr_cdpais_exterior      IN crapnac.cdpais%TYPE                                   --> Código do pais aonde possui domicílio ou obrigação fiscal fora do país
                                       ,pr_dscodigo_postal      IN tbcadast_pessoa_estrangeira.dscodigo_postal%TYPE      --> Número do código posta do endereço no exterior
                                       ,pr_nmlogradouro         IN tbcadast_pessoa_estrangeira.nmlogradouro%TYPE            --> Nome do logradouro
                                       ,pr_nrlogradouro         IN VARCHAR2                                              --> Número do logradouro
                                       ,pr_dscomplemento        IN tbcadast_pessoa_estrangeira.dscomplemento%TYPE           --> Complemento do logradouro
                                       ,pr_dscidade             IN tbcadast_pessoa_estrangeira.dscidade%TYPE             --> Nome da cidade do endereço no exterior
                                       ,pr_dsestado             IN tbcadast_pessoa_estrangeira.dsestado%TYPE             --> Nome da estado do endereço no exterior
                                       ,pr_insocio              IN VARCHAR2                                              --> Indica se o CPF é de um sócio de uma CNPJ
                                       ,pr_nrdconta             IN crapass.nrdconta%TYPE                                 --> Número da conta aonde foi feito a alteração de FATCA/CRS
                                       ,pr_xmllog               IN VARCHAR2                                              --> XML com informações de LOG
                                       ,pr_cdcritic             OUT PLS_INTEGER                                          --> Código da crítica
                                       ,pr_dscritic             OUT VARCHAR2                                             --> Descrição da crítica
                                       ,pr_retxml               IN OUT NOCOPY XMLType                                    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo             OUT VARCHAR2                                             --> Nome do campo com erro
                                       ,pr_des_erro             OUT VARCHAR2) IS                                         --> Erros do processo
  /* .............................................................................
   Programa: pc_atualiza_dados_fatca_crs
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Atualizar as informações de FATCA/CRS da pessoa

   Alteracoes:

    ............................................................................. */
    CURSOR cr_tbcadast_pessoa (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT idpessoa
      FROM tbcadast_pessoa
     WHERE nrcpfcgc = pr_nrcpfcgc;

    CURSOR cr_crapass (pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_cdcooper IN crapass.cdcooper%TYPE) IS
    SELECT nrcpfcgc
      FROM crapass
     WHERE nrdconta = pr_nrdconta
       AND cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapass_cdnacion (pr_cdcooper IN crapass.cdcooper%TYPE
                               ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
    SELECT cdnacion
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrcpfcgc = pr_nrcpfcgc
       AND a.cdsitdct <> 4
       AND a.dtdemiss IS NULL;
    rw_crapass_cdnacion cr_crapass_cdnacion%ROWTYPE;

    CURSOR cr_tbcadast_pessoa_estrangeira (pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT a.inobrigacao_exterior
          ,b.cdpais
          ,a.nridentificacao
          ,a.insocio_obrigacao
          ,a.dscidade
          ,a.dsestado
          ,c.cdpais cdpais_exterior
          ,a.dscodigo_postal
          ,a.nmlogradouro
          ,a.nrlogradouro
          ,a.dscomplemento
      FROM tbcadast_pessoa_estrangeira a
          ,crapnac b
          ,crapnac c
     WHERE a.idpessoa     = pr_idpessoa
       AND b.cdnacion (+) = a.cdpais
       AND c.cdnacion (+) = a.cdpais_exterior;
    rw_tbcadast_pessoa_estrangeira cr_tbcadast_pessoa_estrangeira%ROWTYPE;

    CURSOR cr_crapnac (pr_cdpais IN crapnac.cdpais%TYPE) IS
    SELECT cdnacion
          ,nmpais
          ,inacordo
      FROM crapnac
     WHERE cdpais = pr_cdpais;
    rw_crapnac cr_crapnac%ROWTYPE;

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
    vr_des_erro crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;

    --Variaveis de trabalho
    vr_id_existe_pessoa     NUMBER;
    vr_tpdocmto1            NUMBER;
    vr_tpdocmto2            NUMBER;
    vr_inexiste_estrangeira NUMBER;
    vr_inexiste_endereco    NUMBER;
    vr_nrseq_endereco       NUMBER;
    vr_dsaltera             crapalt.dsaltera%TYPE;
    vr_inobrigacao_exterior tbcadast_pessoa_estrangeira.inobrigacao_exterior%TYPE;
    vr_cdpais_nif           crapnac.cdpais%TYPE;
    vr_nridentificacao      tbcadast_pessoa_estrangeira.nridentificacao%TYPE;
    vr_insocio_obrigacao    tbcadast_pessoa_estrangeira.insocio_obrigacao%TYPE;
    vr_cdpais_exterior      crapnac.cdpais%TYPE;
    vr_dscodigo_postal      tbcadast_pessoa_estrangeira.dscodigo_postal%TYPE;
    vr_nmlogradouro         tbcadast_pessoa_estrangeira.nmlogradouro%TYPE;
    vr_nrlogradouro         tbcadast_pessoa_estrangeira.nrlogradouro%TYPE;
    vr_dscomplemento        tbcadast_pessoa_estrangeira.dscomplemento%TYPE;
    vr_dscidade             tbcadast_pessoa_estrangeira.dscidade%TYPE;
    vr_dsestado             tbcadast_pessoa_estrangeira.dsestado%TYPE;
    vr_cdnacion_nif         crapnac.cdnacion%TYPE;
    vr_cdnacion_exterior    crapnac.cdnacion%TYPE;
    vr_nmpais_exterior      crapnac.nmpais%TYPE;
    vr_pr_nrlogradouro      tbcadast_pessoa_estrangeira.nrlogradouro%TYPE;
    vr_inacordo             crapnac.inacordo%TYPE;

    w_passo varchar2(100);

    PROCEDURE grava_pend_digitalizacao( pr_cdcooper  IN crapdoc.cdcooper%TYPE --> Nr. da conta
                                       ,pr_nrdconta  IN crapdoc.nrdconta%TYPE --> Código do produto
                                       ,pr_idseqttl  IN crapdoc.idseqttl%TYPE --> Indicador de titular
                                       ,pr_nrcpfcgc  IN crapdoc.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                       ,pr_dtmvtolt  IN crapdoc.dtmvtolt%TYPE --> Data do movimento
                                       ,pr_tpdocmto  IN crapdoc.tpdocmto%TYPE --> Tipo do documento
                                       ,pr_cdoperad  IN crapdoc.cdoperad%TYPE --> Codigo do operador
                                       ,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2 ) IS        --> Descricao da critica IS
      --> Verificar se ja existe pendencia no dia atual
      CURSOR cr_crapdoc_1 ( pr_cdcooper crapdoc.cdcooper%TYPE
                           ,pr_dtmvtolt crapdoc.dtmvtolt%TYPE
                           ,pr_tpdocmto crapdoc.tpdocmto%TYPE
                           ,pr_nrdconta crapdoc.nrdconta%TYPE
                           ,pr_nrcpfcgc crapdoc.nrcpfcgc%TYPE
                           ) IS
        SELECT doc.rowid,
               doc.flgdigit
          FROM crapdoc doc
         WHERE doc.cdcooper = pr_cdcooper
           AND doc.dtmvtolt = pr_dtmvtolt
           AND doc.tpdocmto = pr_tpdocmto
           AND ((doc.nrdconta = pr_nrdconta
             AND doc.idseqttl = pr_idseqttl)
              OR doc.nrcpfcgc = pr_nrcpfcgc);
      rw_crapdoc_1 cr_crapdoc_1%ROWTYPE;

      --------------> VARIAVEIS <-----------------
      -- Variavel de criticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro      EXCEPTION;
      vr_exc_return    EXCEPTION;
    BEGIN
      --> Verificar se ja existe pendencia no dia atual
      rw_crapdoc_1 := NULL;
      OPEN cr_crapdoc_1 ( pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_tpdocmto => pr_tpdocmto
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrcpfcgc => pr_nrcpfcgc);

      FETCH cr_crapdoc_1 INTO rw_crapdoc_1;
      --> Caso encontre
      IF cr_crapdoc_1%FOUND THEN
        CLOSE cr_crapdoc_1;

        --> Caso encontre um documento na data atual,
        --> porem ja digitalizado, deve apenas reabrir a pendencia
        IF rw_crapdoc_1.flgdigit = 1 THEN
          BEGIN
            UPDATE crapdoc doc
               SET doc.flgdigit = 0
             WHERE doc.rowid = rw_crapdoc_1.rowid;
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar pendencia: '||SQLERRM;
            RAISE vr_exc_erro;
          END;

          -- Apos realizar o ajustes apenas deve sair da rotina
          RAISE vr_exc_return;

        --> Caso a pendencia ja esteja em aberto
        ELSIF rw_crapdoc_1.flgdigit = 0 THEN
          --> apenas sair da rotina
          RAISE vr_exc_return;
        END IF;
      ELSE
        CLOSE cr_crapdoc_1;
      END IF; --> fim cr_crapdoc_1

      BEGIN
        INSERT INTO crapdoc
               ( cdcooper
               , nrdconta
               , flgdigit
               , dtmvtolt
               , tpdocmto
               , cdoperad
               , nrcpfcgc )
         VALUES( pr_cdcooper   --> cdcooper
               , pr_nrdconta   --> nrdconta
               , 0             --> flgdigit
               , pr_dtmvtolt   --> dtmvtolt
               , pr_tpdocmto   --> tpdocmto
               , pr_cdoperad   --> cdoperad
               , pr_nrcpfcgc   --> nrcpfcgc
               );

      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir pendencia: '||SQLERRM;
        RAISE vr_exc_erro;
      END;

    EXCEPTION
    WHEN vr_exc_return THEN
      --> Apenas sair, usado qnd nao precisa gerar pendencia
      NULL;
    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) <> 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel gravar pendencia: '||SQLERRM;
    END grava_pend_digitalizacao;

  BEGIN -- Inicio pc_atualiza_dados_fatca_crs
w_passo := 1;
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADNAC'
                              ,pr_action => null);
w_passo := 2;
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
w_passo := 3;
    -- Verifica se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_pr_nrlogradouro := REPLACE(pr_nrlogradouro,'.','');

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><fatca_crs/>');

    vr_inexiste_estrangeira := 0;
    vr_inexiste_endereco    := 0;
    vr_nrseq_endereco       := 0;
    vr_inobrigacao_exterior := NULL;
    vr_cdpais_nif           := NULL;
    vr_nridentificacao      := NULL;
    vr_insocio_obrigacao    := NULL;
    vr_cdpais_exterior      := NULL;
    vr_dscodigo_postal      := NULL;
    vr_nmlogradouro         := NULL;
    vr_nrlogradouro         := NULL;
    vr_dscomplemento        := NULL;
    vr_dscidade             := NULL;
    vr_dsestado             := NULL;
    vr_cdnacion_nif         := NULL;
    vr_cdnacion_exterior    := NULL;
    vr_nmpais_exterior      := NULL;
    vr_inacordo             := NULL;

    -- Buscar CDNACION dos paises recebidos no parâmetro
    IF pr_cdpais IS NOT NULL THEN
      OPEN cr_crapnac (pr_cdpais => UPPER(pr_cdpais));
      FETCH cr_crapnac INTO rw_crapnac;
      IF cr_crapnac%FOUND THEN
        vr_cdnacion_nif := rw_crapnac.cdnacion;
        vr_inacordo     := rw_crapnac.inacordo;
      ELSE
        vr_dscritic := 'Pais do Domicilio/Obrigacao nao encontrado na CRAPNAC!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapnac;
    ELSE
      -- Popular o campo CDPAIS se INOBRIGACAO_EXTERIOR = 'N' com a nacionalidade da CRAPASS
      -- pois o campo é obrigatório na TBCADAST_PESSOA_ESTRANGEIRA.
      IF pr_inobrigacao_exterior = 'N' THEN
        OPEN cr_crapass_cdnacion (pr_cdcooper => vr_cdcooper
                                 ,pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_crapass_cdnacion INTO rw_crapass_cdnacion;
        IF cr_crapass_cdnacion%FOUND THEN
          IF rw_crapass_cdnacion.cdnacion = 0 THEN
            vr_cdnacion_nif := 42;
          ELSE
            vr_cdnacion_nif := rw_crapass_cdnacion.cdnacion;
          END IF;
        ELSE
          vr_cdnacion_nif := 42;
        END IF;
        CLOSE cr_crapass_cdnacion;
      END IF;
    END IF;

    IF pr_cdpais_exterior IS NOT NULL THEN
      OPEN cr_crapnac (pr_cdpais => UPPER(pr_cdpais_exterior));
      FETCH cr_crapnac INTO rw_crapnac;
      IF cr_crapnac%FOUND THEN
        vr_cdnacion_exterior := rw_crapnac.cdnacion;
        vr_nmpais_exterior   := rw_crapnac.nmpais;
      ELSE
        vr_dscritic := 'Pais do endereco no exterior nao encontrado na CRAPNAC!'||pr_cdpais_exterior;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapnac;
    END IF;

    vr_id_existe_pessoa := 0;

    FOR rw_tbcadast_pessoa IN cr_tbcadast_pessoa(pr_nrcpfcgc => pr_nrcpfcgc) LOOP
w_passo := 4;
      vr_id_existe_pessoa := 1;

      OPEN cr_tbcadast_pessoa_estrangeira (pr_idpessoa => rw_tbcadast_pessoa.idpessoa);

      FETCH cr_tbcadast_pessoa_estrangeira INTO rw_tbcadast_pessoa_estrangeira;
      IF cr_tbcadast_pessoa_estrangeira%FOUND THEN
--        IF rw_tbcadast_pessoa_estrangeira.cdpais IS NOT NULL THEN
          vr_inexiste_estrangeira := 1;
          vr_inobrigacao_exterior := rw_tbcadast_pessoa_estrangeira.inobrigacao_exterior;
          vr_cdpais_nif           := rw_tbcadast_pessoa_estrangeira.cdpais;
          vr_nridentificacao      := rw_tbcadast_pessoa_estrangeira.nridentificacao;
          vr_insocio_obrigacao    := rw_tbcadast_pessoa_estrangeira.insocio_obrigacao;
          vr_dscidade             := rw_tbcadast_pessoa_estrangeira.dscidade;
          vr_dsestado             := rw_tbcadast_pessoa_estrangeira.dsestado;
          vr_cdpais_exterior      := rw_tbcadast_pessoa_estrangeira.cdpais_exterior;
          vr_dscodigo_postal      := rw_tbcadast_pessoa_estrangeira.dscodigo_postal;
          vr_nmlogradouro         := rw_tbcadast_pessoa_estrangeira.nmlogradouro;
          vr_nrlogradouro         := rw_tbcadast_pessoa_estrangeira.nrlogradouro;
          vr_dscomplemento        := rw_tbcadast_pessoa_estrangeira.dscomplemento;
--        END IF;
      END IF;
      CLOSE cr_tbcadast_pessoa_estrangeira;
w_passo := 41;
      IF pr_inobrigacao_exterior = 'S' THEN
        vr_inexiste_endereco := 1;
      END IF;

w_passo := 44;

      IF vr_inexiste_estrangeira = 0 THEN
        BEGIN
          INSERT INTO tbcadast_pessoa_estrangeira
                 (idpessoa
                 ,cdpais
                 ,nridentificacao
                 ,dsnatureza_relacao
                 ,nrpassaporte
                 ,tpdeclarado
                 ,incrs
                 ,infatca
                 ,dsnaturalidade
                 ,inobrigacao_exterior
                 ,insocio_obrigacao
                 ,cdpais_exterior
                 ,dscidade
                 ,dsestado
                 ,dscodigo_postal
                 ,nmlogradouro
                 ,nrlogradouro
                 ,dscomplemento)
          VALUES (rw_tbcadast_pessoa.idpessoa
                 ,vr_cdnacion_nif
                 ,pr_nridentificacao
                 ,NULL            -- dsnatureza_relacao
                 ,NULL            -- nrpassaporte
                 ,NULL            -- tpdeclarado
                 ,NULL            -- incrs
                 ,NULL            -- infatca
                 ,NULL            -- dsnaturalidade
                 ,pr_inobrigacao_exterior
                 ,pr_insocio_obrigacao
                 ,vr_cdnacion_exterior
                 ,pr_dscidade
                 ,pr_dsestado
                 ,pr_dscodigo_postal
                 ,pr_nmlogradouro
                 ,vr_pr_nrlogradouro
                 ,pr_dscomplemento);
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := substr('Erro inserir TBCADAST_PESSOA_ESTRANGEIRA - '||rw_tbcadast_pessoa.idpessoa||' - '||sqlerrm,1,1000);
          RAISE vr_exc_saida;
        END;
      ELSE
w_passo := 45;
        IF NVL(pr_inobrigacao_exterior,'.')   <> NVL(vr_inobrigacao_exterior,'.')
        OR NVL(UPPER(pr_cdpais),'.')          <> NVL(vr_cdpais_nif,'.')
        OR NVL(pr_nridentificacao,-1)         <> NVL(vr_nridentificacao,-1)
        OR NVL(pr_insocio_obrigacao,'.')      <> NVL(vr_insocio_obrigacao,'.')
        OR NVL(UPPER(pr_cdpais_exterior),'.') <> NVL(vr_cdpais_exterior,'.')
        OR NVL(pr_dscidade,'.')               <> NVL(vr_dscidade,'.')
        OR NVL(pr_dsestado,'.')               <> NVL(vr_dsestado,'.')
        OR NVL(pr_nmlogradouro,'.')           <> NVL(vr_nmlogradouro,'.')
        OR NVL(vr_pr_nrlogradouro,-1)         <> NVL(vr_nrlogradouro,-1)
        OR NVL(pr_dscomplemento,'.')          <> NVL(vr_dscomplemento,'.')
        OR NVL(pr_dscodigo_postal,'.')        <> NVL(vr_dscodigo_postal,'.')
        THEN
          BEGIN
            UPDATE tbcadast_pessoa_estrangeira
               SET cdpais               = vr_cdnacion_nif
                  ,nridentificacao      = pr_nridentificacao
                  ,inobrigacao_exterior = pr_inobrigacao_exterior
                  ,insocio_obrigacao    = pr_insocio_obrigacao
                  ,cdpais_exterior      = vr_cdnacion_exterior
                  ,dscidade             = pr_dscidade
                  ,dsestado             = pr_dsestado
                  ,dscodigo_postal      = pr_dscodigo_postal
                  ,nmlogradouro         = pr_nmlogradouro
                  ,nrlogradouro         = vr_pr_nrlogradouro
                  ,dscomplemento        = pr_dscomplemento
            WHERE idpessoa = rw_tbcadast_pessoa.idpessoa;
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := substr('Erro alterar TBCADAST_PESSOA_ESTRANGEIRA - '||sqlerrm,1,1000);
            RAISE vr_exc_saida;
          END;
        END IF;
      END IF; -- IF vr_inexiste_estrangeira = 0 THEN
      --
      IF (NVL(vr_inobrigacao_exterior,'N') = 'N' AND pr_inobrigacao_exterior = 'S')
      OR (NVL(vr_insocio_obrigacao,'N')    = 'N' AND pr_insocio_obrigacao    = 'S')
      THEN
        IF (NVL(vr_insocio_obrigacao,'N')  = 'N' AND pr_insocio_obrigacao    = 'S')
        AND vr_inacordo IS NULL
        THEN
          vr_inacordo := 'S';
        END IF;
        --
        IF vr_inacordo IS NOT NULL THEN
w_passo := 51;
          BEGIN
            INSERT INTO tbreportaval_fatca_crs
                   (nrcpfcgc
                   ,insituacao
                   ,inreportavel
                   ,cdtipo_declarado
                   ,cdtipo_proprietario
                   ,dsjustificativa
                   ,dtinicio
                   ,dtfinal
                   ,dtaltera
                   ,cdoperad)
            VALUES (pr_nrcpfcgc
                   ,'P'             -- insituacao  -- Pendente
                   ,NULL            -- inreportavel
                   ,NULL            -- cdtipo_declarado
                   ,NULL            -- cdtipo_proprietario
                   ,NULL            -- dsjustificativa
                   ,NULL            -- dtinicio
                   ,NULL            -- dtfinal
                   ,SYSDATE         -- dtaltera
                   ,vr_cdoperad);
          EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := substr('Erro inserir TBREPORTAVAL_FATCA_CRS - '||sqlerrm,1,1000);
            RAISE vr_exc_saida;
          END;
          --
w_passo := 52;
          -- Ficou definido pela Suelen que se:
          -- A Empresa não tem obrigação fiscal no exterior (inobrigacao_exterior = N), mas
          -- que tenha algum sócio que tenha obrigação discal no exterior e mais de 10% (insocio_obrigacao = S)
          -- deve ser gerada a pendencia no DIGIDOC para a Declaração da Empresa.
          --
          -- IF vr_inacordo <> 'S' THEN
            pc_buscar_tpdocmto_digidoc(pr_insocio   => pr_insocio
                                      ,pr_intem_nif => pr_nridentificacao
                                      ,pr_tpdocmto1 => vr_tpdocmto1
                                      ,pr_tpdocmto2 => vr_tpdocmto2);

            -- Buscar o CNPJ do titular da conta aonde é sócio
            IF pr_insocio = 'S' THEN
              OPEN cr_crapass (pr_nrdconta => pr_nrdconta
                              ,pr_cdcooper => vr_cdcooper);
              FETCH cr_crapass INTO rw_crapass;
              CLOSE cr_crapass;
            ELSE
              rw_crapass.nrcpfcgc := pr_nrcpfcgc;
            END IF;
            --
            IF vr_tpdocmto1 IS NOT NULL THEN
              grava_pend_digitalizacao(pr_cdcooper  => vr_cdcooper
                                      ,pr_nrdconta  => pr_nrdconta
                                      ,pr_idseqttl  => 1
                                      ,pr_nrcpfcgc  => rw_crapass.nrcpfcgc
                                      ,pr_dtmvtolt  => TRUNC(SYSDATE)
                                      ,pr_tpdocmto  => vr_tpdocmto1
                                      ,pr_cdoperad  => vr_cdoperad
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END IF;
            --
w_passo := 53;
            --
            IF vr_tpdocmto2 IS NOT NULL THEN
              grava_pend_digitalizacao(pr_cdcooper  => vr_cdcooper
                                      ,pr_nrdconta  => pr_nrdconta
                                      ,pr_idseqttl  => 1
                                      ,pr_nrcpfcgc  => rw_crapass.nrcpfcgc
                                      ,pr_dtmvtolt  => TRUNC(SYSDATE)
                                      ,pr_tpdocmto  => vr_tpdocmto2
                                      ,pr_cdoperad  => vr_cdoperad
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END IF;
          -- END IF;
        END IF;
      END IF;
      --
      vr_dsaltera := NULL;
w_passo := 60;
      --
      IF vr_inexiste_estrangeira = 1 THEN
        IF NVL(pr_inobrigacao_exterior,'.') <> NVL(vr_inobrigacao_exterior,'.') THEN
          SELECT vr_dsaltera
                 ||'Obrigação no Exterior: '
                 ||DECODE(NVL(vr_inobrigacao_exterior,'.'),'S','SIM','NÃO')
                 ||' ==> '
                 ||DECODE(NVL(pr_inobrigacao_exterior,'.'),'S','SIM','NÃO')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 61;
        IF NVL(UPPER(pr_cdpais),'.')               <> NVL(vr_cdpais_nif,'.') THEN
          SELECT vr_dsaltera
                 ||'Pais do NIF: '
                 ||NVL(vr_cdpais_nif,'Em Branco')
                 ||' ==> '
                 ||NVL(UPPER(pr_cdpais),'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 62;
        IF NVL(pr_nridentificacao,-1)      <> NVL(vr_nridentificacao,-1) THEN
          SELECT vr_dsaltera
                 ||'NIF: '
                 ||NVL(TO_CHAR(vr_nridentificacao),'Em Branco')
                 ||' ==> '
                 ||NVL(TO_CHAR(pr_nridentificacao),'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 63;
        IF NVL(pr_insocio_obrigacao,'.')    <> NVL(vr_insocio_obrigacao,'.') THEN
          SELECT vr_dsaltera
                 ||'Possui sócio com 10% ou mais com obrigação no exterior: '
                 ||DECODE(NVL(vr_insocio_obrigacao,'.'),'S','SIM','NÃO')
                 ||' ==> '
                 ||DECODE(NVL(pr_insocio_obrigacao,'.'),'S','SIM','NÃO')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 64;
        IF NVL(UPPER(pr_cdpais_exterior),'.') <> NVL(vr_cdpais_exterior,'.') THEN
          SELECT vr_dsaltera
                 ||'Pais no Exterior: '
                 ||NVL(vr_cdpais_exterior,'Em Branco')
                 ||' ==> '
                 ||NVL(UPPER(pr_cdpais_exterior),'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 65;
        IF NVL(pr_dscidade,'.')    <> NVL(vr_dscidade,'.') THEN
          SELECT vr_dsaltera
                 ||'Cidade no Exterior: '
                 ||NVL(vr_dscidade,'Em Branco')
                 ||' ==> '
                 ||NVL(pr_dscidade,'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 66;
        IF NVL(pr_dsestado,'.')    <> NVL(vr_dsestado,'.') THEN
          SELECT vr_dsaltera
                 ||'Estado no Exterior: '
                 ||NVL(vr_dsestado,'Em Branco')
                 ||' ==> '
                 ||NVL(pr_dsestado,'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
      END IF;
w_passo := 70;
      IF vr_inexiste_endereco > 0 THEN
        IF NVL(pr_nmlogradouro,'.')  <> NVL(vr_nmlogradouro,'.') THEN
          SELECT vr_dsaltera
                 ||'Nome Logradouro: '
                 ||NVL(vr_nmlogradouro,'Em Branco')
                 ||' ==> '
                 ||NVL(pr_nmlogradouro,'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 71;
        IF NVL(vr_pr_nrlogradouro,-1)  <> NVL(vr_nrlogradouro,-1) THEN
          SELECT vr_dsaltera
                 ||'Número Logradouro: '
                 ||NVL(TO_CHAR(vr_nrlogradouro),'Em Branco')
                 ||' ==> '
                 ||NVL(TO_CHAR(vr_pr_nrlogradouro),'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 72;
        IF NVL(pr_dscomplemento,'.') <> NVL(vr_dscomplemento,'.') THEN
          SELECT vr_dsaltera
                 ||'Complemento Logradouro: '
                 ||NVL(vr_dscomplemento,'Em Branco')
                 ||' ==> '
                 ||NVL(pr_dscomplemento,'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
w_passo := 73;
        IF NVL(pr_dscodigo_postal,-1) <> NVL(vr_dscodigo_postal,-1) THEN
          SELECT vr_dsaltera
                 ||'Número Código Postal: '
                 ||NVL(vr_dscodigo_postal,'Em Branco')
                 ||' ==> '
                 ||NVL(pr_dscodigo_postal,'Em Branco')||chr(10)
            INTO vr_dsaltera
            FROM DUAL;
        END IF;
      END IF;
      --
      IF vr_dsaltera IS NOT NULL THEN
w_passo := 80;
        BEGIN
          INSERT INTO crapalt
                 (nrdconta
                 ,dtaltera
                 ,cdoperad
                 ,dsaltera
                 ,tpaltera
                 ,flgctitg
                 ,cdcooper)
          VALUES (pr_nrdconta
                 ,SYSDATE       -- dtaltera
                 ,vr_cdoperad
                 ,'Data/Hora alteração: '||TO_CHAR(SYSDATE,'dd/mm/yyyy hh24:mi:ss')||
                  ' - CPF/CNPJ: '||pr_nrcpfcgc||chr(10)||
                  vr_dsaltera
                 ,2             -- tpaltera -- Alterações Diversas
                 ,1             -- flgctitg -- Enviada
                 ,vr_cdcooper);
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := substr('Erro gerar Log ALTERA - '||sqlerrm,1,1000);
          RAISE vr_exc_saida;
        END;
      END IF;
      --
w_passo := 90;
      IF  NVL(vr_inobrigacao_exterior,'.') = 'S'
      AND NVL(pr_inobrigacao_exterior,'.') = 'N'
      THEN
        TELA_FATCA_CRS.PC_TRATAR_FATCA_CRS_PARA_NAO(pr_nrcpfcgc     => pr_nrcpfcgc
                                                   ,pr_inreportavel => pr_inobrigacao_exterior
                                                   ,pr_cdcritic     => vr_cdcritic
                                                   ,pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;
      --
      IF NVL(vr_cdpais_nif,'.') <> NVL(UPPER(pr_cdpais),'.')
      THEN
        TELA_FATCA_CRS.PC_TRATAR_ALTERACAO_PAIS(pr_nrcpfcgc     => pr_nrcpfcgc
                                               ,pr_cdpais_old   => vr_cdpais_nif
                                               ,pr_cdpais_new   => UPPER(pr_cdpais)
                                               ,pr_cdoperad     => vr_cdoperad
                                               ,pr_cdcritic     => vr_cdcritic
                                               ,pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

    END LOOP; -- cr_tbcadast_pessoa (

    IF vr_id_existe_pessoa = 0 THEN
      vr_dscritic := 'CPF ou CNPJ nao encontrado no cadastro unificado! (TBCADAST_PESSOA)';
      RAISE vr_exc_saida;
    END IF;

w_passo :=999;
    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => 'FATCA_CRS.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteração nos dados FATCA/CRS da pessoa' ||
                                                  pr_nrcpfcgc || '.');

    pr_des_erro := 'OK';
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := w_passo||'-'||vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := 0;
      pr_dscritic := w_passo||'-'||'Erro (TELA_CADNAC.pc_atualiza_dados_fatca_crs).'||sqlerrm;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_atualiza_dados_fatca_crs;

  --Buscar os paises da tabela CRAPNAC
  PROCEDURE pc_busca_paises(pr_inacordo IN VARCHAR2                      --> Buscar paises que tem acordo FATCA/CRS (S=Sim, N=Não)
                           ,pr_cdpais   IN crapnac.cdpais%TYPE           --> Código do pais
                           ,pr_dspais   IN crapnac.nmpais%TYPE           --> Descrição do pais
                           ,pr_cdpais_exterior   IN crapnac.cdpais%TYPE           --> Código do pais
                           ,pr_dspais_exterior   IN crapnac.nmpais%TYPE           --> Descrição do pais
                           ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                           ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo

  /* .............................................................................
   Programa: pc_busca_paises
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Buscar os paises da tabela CRAPNAC

   Alteracoes:

    ............................................................................. */
    CURSOR cr_crapnac (pr_inacordo IN VARCHAR2
                      ,pr_cdpais   IN crapnac.cdpais%TYPE
                      ,pr_dspais   IN crapnac.nmpais%TYPE) IS
    SELECT *
      FROM crapnac
     WHERE cdpais IS NOT NULL
       AND (pr_inacordo IS NULL
        OR (pr_inacordo = 'S' AND inacordo IS NOT NULL)
        OR (pr_inacordo = 'N' AND inacordo IS NULL))
       AND cdpais LIKE '%'||pr_cdpais||'%'
       AND nmpais LIKE '%'||pr_dspais||'%'
     ORDER BY nmpais;

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

  BEGIN -- Inicio pc_busca_paises

    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'FATCA_CRS'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'crapnac',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    FOR rw_crapnac IN cr_crapnac (pr_inacordo => UPPER(pr_inacordo)
                                 ,pr_cdpais   => UPPER(NVL(pr_cdpais,pr_cdpais_exterior))
                                 ,pr_dspais   => UPPER(NVL(pr_dspais,pr_dspais_exterior))) LOOP

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
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'crapnac'      ,pr_posicao => 0          , pr_tag_nova => 'dados_crapnac', pr_tag_cont => NULL               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais'       , pr_tag_cont => rw_crapnac.cdpais  , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais'       , pr_tag_cont => rw_crapnac.nmpais  , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo'     , pr_tag_cont => rw_crapnac.inacordo, pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crapnac'           --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_FATCA_CRS.pc_busca_paises).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_busca_paises;

  --Validar o país na tabela CRAPNAC
  PROCEDURE pc_valida_pais(pr_cdpais   IN crapnac.cdpais%TYPE           --> Código do pais no FATCA/CRS
                          ,pr_nrregist IN INTEGER                       --> Quantidade de registros
                          ,pr_nriniseq IN INTEGER                       --> Qunatidade inicial
                          ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
  /* .............................................................................
   Programa: pc_valida_pais
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Validar o país na tabela CRAPNAC

   Alteracoes:

    ............................................................................. */
    CURSOR cr_crapnac (pr_cdpais    IN crapnac.cdpais%TYPE) IS
    SELECT *
      FROM crapnac
     WHERE cdpais IS NOT NULL
       AND cdpais = pr_cdpais;
    rw_crapnac cr_crapnac%ROWTYPE;

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
    vr_cdpais   crapnac.cdpais%TYPE;
    vr_nmpais   crapnac.nmpais%TYPE;
    vr_inacordo crapnac.inacordo%TYPE;

  BEGIN -- Inicio pc_valida_pais

    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'FATCA_CRS'
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

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'crapnac',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    vr_cdpais   := null;
    vr_nmpais   := null;
    vr_inacordo := null;

    OPEN cr_crapnac (pr_cdpais => UPPER(pr_cdpais));
    FETCH cr_crapnac INTO rw_crapnac;
    IF cr_crapnac%FOUND THEN
      vr_cdpais   := rw_crapnac.cdpais;
      vr_nmpais   := rw_crapnac.nmpais;
      vr_inacordo := rw_crapnac.inacordo;
    ELSE
      vr_dscritic := 'Pais nao encontrado na CRAPNAC!'||pr_cdpais||'**';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapnac;

    --Incrementar Quantidade Registros do Parametro
    vr_qtregist:= nvl(vr_qtregist,0) + 1;

    --Numero Registros
    IF vr_nrregist > 0 THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'crapnac'      ,pr_posicao => 0          , pr_tag_nova => 'dados_crapnac', pr_tag_cont => NULL       , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'cdpais'       , pr_tag_cont => vr_cdpais  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'nmpais'       , pr_tag_cont => vr_nmpais  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crapnac',pr_posicao => vr_auxconta, pr_tag_nova => 'inacordo'     , pr_tag_cont => vr_inacordo, pr_des_erro => vr_dscritic);
      -- Incrementa contador p/ posicao no XML
      vr_auxconta := nvl(vr_auxconta,0) + 1;
    END IF;

    --Diminuir registros
    vr_nrregist:= nvl(vr_nrregist,0) - 1;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crapnac'           --> Nome da TAG XML
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
      pr_dscritic := 'Erro geral (TELA_FATCA_CRS.pc_valida_pais).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_valida_pais;

--Tratar a mudança para não da informação de "Possui obrigação no exterior"
  PROCEDURE pc_tratar_fatca_crs_para_nao(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                        ,pr_inreportavel IN VARCHAR2 -- tbreportaval_fatca_crs.inreportavel%TYPE --> Indicador de Reportável (Sim, Não)
                                        ,pr_cdcritic    OUT PLS_INTEGER                              --> Código da crítica
                                        ,pr_dscritic    OUT VARCHAR2) IS                             --> Erros do processo
  /* .............................................................................
   Programa: pc_tratar_fatca_crs_para_nao
   Sistema : Compliance - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Marcelo Telles Coelho - Mouts
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para Tratar a alteração do indicador obrigação no exterior de SIM para NÃO alterando o indicador de reportável para NÃO

   Alteracoes:

    ............................................................................. */
    CURSOR cr_reportaval (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT a.inreportavel
          ,b.tppessoa
      FROM tbreportaval_fatca_crs a
          ,tbcadast_pessoa b
     WHERE a.nrcpfcgc = pr_nrcpfcgc
       AND b.nrcpfcgc = a.nrcpfcgc;
    rw_reportaval cr_reportaval%ROWTYPE;
    rw_reportaval_socio cr_reportaval%ROWTYPE;

    CURSOR cr_cnpj_empresa (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT distinct
           b.nrcpfcgc nrcpfcgc_empresa
      FROM crapavt a
          ,crapass b
     WHERE a.nrcpfcgc  = pr_nrcpfcgc
       AND a.tpctrato  = 6
       AND a.dsproftl <> 'PROCURADOR'
       AND b.cdcooper  = a.cdcooper
       AND b.nrdconta  = a.nrdconta
    UNION
    SELECT DISTINCT
           z.nrcpfcgc
      FROM crapepa x
          ,crapass z
     WHERE x.nrdocsoc  = pr_nrcpfcgc
       AND z.cdcooper  = x.CDCOOPER
       AND z.nrdconta  = x.NRDCONTA;

    CURSOR cr_empresas (pr_nrcpfcgc_empresa IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT distinct
           a.nrdconta nrdconta_empresa
          ,a.cdcooper cdcooper_empresa
          ,b.nrcpfcgc nrcpfcgc_empresa
      FROM crapavt a
          ,crapass b
     WHERE b.nrcpfcgc  = pr_nrcpfcgc_empresa
       AND a.tpctrato  = 6
       AND a.dsproftl <> 'PROCURADOR'
       AND b.cdcooper  = a.cdcooper
       AND b.nrdconta  = a.nrdconta;

    CURSOR cr_empresa_socios (pr_cdcooper_empresa IN crapass.cdcooper%TYPE
                             ,pr_nrdconta_empresa IN crapass.nrdconta%TYPE) IS
    SELECT nrcpfcgc nrcpfcgc_socio
      FROM crapavt a
     WHERE a.cdcooper  = pr_cdcooper_empresa
       AND a.nrdconta  = pr_nrdconta_empresa
       AND a.tpctrato  = 6
       AND a.dsproftl <> 'PROCURADOR'
    UNION
    SELECT x.nrdocsoc nrcpfcgc_socio
      FROM crapepa x
     WHERE x.cdcooper  = pr_cdcooper_empresa
       AND x.nrdconta  = pr_nrdconta_empresa;

    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;

    --Variaveis de trabalho
    vr_nrreportavel NUMBER;

  BEGIN -- pc_tratar_fatca_crs_para_nao
    --
    -- Buscar INREPORTAVEL da pessoa
    OPEN cr_reportaval (pr_nrcpfcgc => pr_nrcpfcgc);
    FETCH cr_reportaval INTO rw_reportaval;
    IF cr_reportaval%NOTFOUND THEN
      vr_dscritic := 'Pessoa não existe na tabela de reportaveis!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_reportaval;
    --
    IF rw_reportaval.inreportavel = 'S' THEN
      BEGIN
        UPDATE tbreportaval_fatca_crs
           SET inreportavel    = 'N'
              ,dtfinal         = TRUNC(SYSDATE)
              ,dsjustificativa = dsjustificativa||'Alteracao de cooperado possui obrigação no exterior de SIM para NÃO'||chr(10)
         WHERE nrcpfcgc        = pr_nrcpfcgc;
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := substr('Erro alterar TBREPORTAVAL_FATCA_CRS - '||sqlerrm,1,1000);
        RAISE vr_exc_saida;
      END;
      --
      -- Se pessoa Física, verificar as contas em que ela é sócia para desmarcacr o INREPORTAVAL
      IF rw_reportaval.tppessoa = 1 THEN
        -- Buscar CNPJ de empresas onde a PF é sócia
        FOR rw_cnpj_empresa in cr_cnpj_empresa(pr_nrcpfcgc => pr_nrcpfcgc)
        LOOP
          -- Buscar as Cooperativas/Contas onde o CNPJ é Titular
          FOR rw_empresas in cr_empresas(pr_nrcpfcgc_empresa => rw_cnpj_empresa.nrcpfcgc_empresa)
          LOOP
            -- Buscar Sócios da Cooperativa/Conta
            FOR rw_empresa_socios IN cr_empresa_socios(pr_cdcooper_empresa => rw_empresas.cdcooper_empresa
                                                      ,pr_nrdconta_empresa => rw_empresas.nrdconta_empresa)
            LOOP
              vr_nrreportavel := 0;
              --
              OPEN cr_reportaval (pr_nrcpfcgc => rw_empresa_socios.nrcpfcgc_socio);
              FETCH cr_reportaval INTO rw_reportaval_socio;
              IF cr_reportaval%FOUND THEN
                IF rw_reportaval_socio.inreportavel = 'S' THEN
                  vr_nrreportavel := vr_nrreportavel + 1;
                END IF;
              END IF;
              CLOSE cr_reportaval;
            END LOOP; -- cr_empresa_socios
            --
          END LOOP; -- cr_empresas
          -- Se não
          IF vr_nrreportavel = 0 THEN
            BEGIN
              UPDATE tbreportaval_fatca_crs
                 SET inreportavel    = 'N'
                    ,dtfinal         = TRUNC(SYSDATE)
                    ,dsjustificativa = dsjustificativa||'Alteracao do único sócio possui obrigação no exterior de SIM para NÃO'||chr(10)
               WHERE nrcpfcgc        = rw_cnpj_empresa.nrcpfcgc_empresa
                 AND inreportavel    = 'S';
            EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := substr('Erro alterar TBREPORTAVAL_FATCA_CRS empresa - '||sqlerrm,1,1000);
              RAISE vr_exc_saida;
            END;
          END IF;
        END LOOP; -- cr_cnpj_empresa
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;

      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := 0;
      pr_dscritic := 'Erro (TELA_FATCA_CRS.tratar_fatca_crs_para_nao).'||sqlerrm;

      ROLLBACK;

  END pc_tratar_fatca_crs_para_nao;

  PROCEDURE pc_buscar_tpdocmto_digidoc(pr_insocio   IN  VARCHAR2
                                      ,pr_intem_nif IN  VARCHAR2 DEFAULT 'S'
                                      ,pr_tpdocmto1 OUT NUMBER
                                      ,pr_tpdocmto2 OUT NUMBER) IS
    vr_database VARCHAR2(100);
  BEGIN
    SELECT UPPER(sys_context('USERENV', 'DB_NAME'))
      INTO vr_database
      FROM DUAL;
    --
    IF vr_database = 'AYLLOSP' THEN -- Produção
      IF pr_insocio = 'S' THEN
        SELECT NULL -- '62' -- Declaração de obrigação fiscal no exterior - Sócio
              ,'63' -- Documento NIF - Sócio
          INTO pr_tpdocmto1
              ,pr_tpdocmto2
          FROM dual;
      ELSE
        SELECT '60' -- Declaração de obrigação fiscal no exterior
              ,'61' -- Documento NIF
          INTO pr_tpdocmto1
              ,pr_tpdocmto2
          FROM dual;
      END IF;
    ELSE
      IF pr_insocio = 'S' THEN
        SELECT NULL -- '97' -- Declaração de obrigação fiscal no exterior - Sócio
              ,'98' -- Documento NIF - Sócio
          INTO pr_tpdocmto1
              ,pr_tpdocmto2
          FROM dual;
      ELSE
        SELECT '95' -- Declaração de obrigação fiscal no exterior
              ,'96' -- Documento NIF
          INTO pr_tpdocmto1
              ,pr_tpdocmto2
          FROM dual;
      END IF;
    END IF;
    --
    IF pr_intem_nif IS NULL THEN
      pr_tpdocmto2 := NULL;
    END IF;
  END pc_buscar_tpdocmto_digidoc;

  PROCEDURE pc_tratar_alteracao_pais(pr_nrcpfcgc     IN tbcadast_pessoa.nrcpfcgc%TYPE            --> CPF ou CGC da pessoa
                                    ,pr_cdpais_old   IN crapnac.cdpais%TYPE                      --> Código do pais antes da alteração
                                    ,pr_cdpais_new   IN crapnac.cdpais%TYPE                      --> Código do pais após da alteração
                                    ,pr_cdoperad     IN VARCHAR2                                 --> Operador que fez a alteração
                                    ,pr_cdcritic    OUT PLS_INTEGER                              --> Código da crítica
                                    ,pr_dscritic    OUT VARCHAR2) IS                             --> Descrição da crítica
    CURSOR cr_crapnac (pr_cdpais IN crapnac.cdpais%TYPE) IS
    SELECT inacordo
      FROM crapnac
     WHERE cdpais = pr_cdpais;
    rw_crapnac cr_crapnac%ROWTYPE;
    --
    vr_dscritic     crapcri.dscritic%TYPE;
    vr_inacordo_old crapnac.cdpais%TYPE;
    vr_inacordo_new crapnac.cdpais%TYPE;
    vr_rowcount     NUMBER;
    vr_exc_saida    EXCEPTION;
  BEGIN
    OPEN cr_crapnac (pr_cdpais => pr_cdpais_old);
    FETCH cr_crapnac INTO rw_crapnac;
    IF cr_crapnac%FOUND THEN
      vr_inacordo_old := rw_crapnac.inacordo;
    ELSE
      vr_inacordo_old := NULL;
    END IF;
    CLOSE cr_crapnac;
    --
    OPEN cr_crapnac (pr_cdpais => pr_cdpais_new);
    FETCH cr_crapnac INTO rw_crapnac;
    IF cr_crapnac%FOUND THEN
      vr_inacordo_new := rw_crapnac.inacordo;
    ELSE
      vr_inacordo_new := NULL;
    END IF;
    CLOSE cr_crapnac;
    --
    IF  NVL(vr_inacordo_old,'.') <> NVL(vr_inacordo_new,'.')
    THEN
      BEGIN
        UPDATE tbreportaval_fatca_crs
           SET inreportavel        = NULL
              ,insituacao          = 'P'
              ,cdtipo_declarado    = NULL
              ,cdtipo_proprietario = NULL
              ,dtinicio            = NULL
              ,dtfinal             = NULL
         WHERE nrcpfcgc            = pr_nrcpfcgc;
        vr_rowcount := SQL%ROWCOUNT;
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := substr('Erro alterar TBREPORTAVAL_FATCA_CRS - '||sqlerrm,1,1000);
        RAISE vr_exc_saida;
      END;
      --
      IF vr_rowcount > 0 THEN
        BEGIN
          INSERT INTO tbhist_reportaval_fatca_crs
                 (nrcpfcgc
                 ,nrseq_historico
                 ,dsalteracao
                 ,dtaltera
                 ,cdoperad)
          VALUES (pr_nrcpfcgc
                 ,NULL         -- nrseq_historico
                 ,'Data/Hora alteração: '||TO_CHAR(SYSDATE,'dd/mm/yyyy hh24:mi:ss')||chr(10)||
                  'Alterada a situação para PENDENTE'||chr(10)||
                  'Pois foi alterado o acordo do pais: '
                 ||NVL(vr_inacordo_old,'Em Branco')
                 ||' ==> '
                 ||NVL(vr_inacordo_new,'Em Branco')||chr(10)
                 ,SYSDATE      -- dtaltera
                 ,pr_cdoperad);
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := substr('Erro gerar Log Alteracao - '||sqlerrm,1,1000);
          RAISE vr_exc_saida;
        END;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_dscritic := vr_dscritic;

      ROLLBACK;

    WHEN OTHERS THEN

      pr_dscritic := 'Erro (TELA_FATCA_CRS.pc_tratar_alteracao_pais).'||sqlerrm;

      ROLLBACK;

  END pc_tratar_alteracao_pais;
END TELA_FATCA_CRS;
/
