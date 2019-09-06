CREATE OR REPLACE PACKAGE CECRED.TELA_RATMOV IS

  ---------------------------------------------------------------------------
  --   Programa: tela_ratmov
  --   Sistema : CECRED
  --   Sigla   : RATMOV
  --   Autor   : Daniele Rocha/AMcom
  --   Data    : Fevereiro/2019                 Ultima atualizacao: 12/07/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  : Centralizar rotinas relacionadas a Tela RATMOV
  --
  -- Alterações:
  --             29/05/2019 - PRJ 450 - Ajuste no filtro "Contrato Liquidado" no cursor
  --                          cr_busca_contratos (Heckmann - AMcom)
  --
  --             12/07/2019 - PRJ 450 - Ajuste na clausula WHERE no cursor
  --                          cr_busca_contratos - estava travando sua 
  --                          execução (Heckmann - AMcom)
  --
  --             22/07/2019 - PRJ 450 - Criação dos cursores cr_busca_contratos_emp e
  --                          cr_busca_contratos_lim para substituir um cursor
  --                          genérico para melhoria de performance
  --                          (Luiz Otávio Olinger Momm / AMCOM)
  --
  --             23/07/2019 - PRJ 450 - Criação da tabela typ_tab_busca_contratos para
  --                          gerenciamento das buscas dos cursores
  --                          cr_busca_contratos_emp e cr_busca_contratos_lim
  --                          (Luiz Otávio Olinger Momm / AMCOM)
  --
  --             20/08/2019 - PRJ 450 - Adicionado cursor para consultar pré-aprovado
  --                          (Weverton Otoni (Amcom))	
  --
  --             04/09/2019 - PRJ 450 - Alteração nos cursores cr_busca_contratos_emp 
  --                          para considerar os pré-aprovados antes da data de corte,
  --                          carregando como empréstimos e no cursor cr_busca_pre_aprovado
  --                          para considerar a data de corte
  --                          (Heckmann - AMcom)
  --
  --             06/09/2019 - PJ450 - Bug 26058 - Erro classificação Ratmov- Correção nos 
  --                          cursores cr_busca_contratos_emp e cr_busca_pre_aprovado, 
  --                          referente a Data de Corte.
  --                          (Marcelo Elias Gonçalves - AMcom).
  ---------------------------------------------------------------------------

    /* consultar cpf */
  PROCEDURE pc_consultar(pr_NMPRIMTL  IN VARCHAR2,
                         pr_NRCPFCGC  IN INTEGER,
                         pr_xmllog    IN VARCHAR2, --> XML com informações de LOG
                         pr_cdcritic  OUT PLS_INTEGER, --> Código da crítica
                         pr_dscritic  OUT VARCHAR2, --> Descrição da crítica
                         pr_retxml    IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                         pr_nmdcampo  OUT VARCHAR2, --> Nome do campo com erro
                         pr_des_erro  OUT VARCHAR2) ;

  /*.Consulta contratos e o rating.*/
  PROCEDURE pc_consultar_rating(pr_nrcpfcgc   IN INTEGER, --> CPF/CNPJ
                                pr_nrdconta   IN INTEGER,  --> CONTA
                                pr_nrctro     IN INTEGER,  --CONTRATO
                                pr_status     IN INTEGER,
                                pr_datafim    IN VARCHAR2,  -- DATA INICIO PARA BUSCA
                                pr_dataini    IN VARCHAR2,  -- DATA FIM  PARA A BUSCA
                                pr_crapbdc    IN CHAR,  -- Cadastro de borderos de descontos de cheques
                                pr_crapbdt    IN CHAR,  -->Cadastro de borderos de descontos de titulos
                                pr_craplim    IN CHAR,  -->Contratos de Limite de credito
                                pr_crawepr    IN CHAR,  --> tabela empre
                                pr_crapcpa    IN CHAR,  --> pre aprovado
                                pr_contrliq   IN CHAR,  --> se contrato é liquidado
                                pr_xmllog     IN VARCHAR2, --> XML com informações de LOG
                                pr_cdcritic   OUT PLS_INTEGER, --> Código da crítica
                                pr_dscritic   OUT VARCHAR2, --> Descrição da crítica
                                pr_retxml     IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                pr_nmdcampo   OUT VARCHAR2, --> Nome do campo com erro
                                pr_des_erro   OUT VARCHAR2);

  /*Sugerir Rating esteira / motor */
  PROCEDURE pc_alterar_rating(pr_nrcpfcgc           IN INTEGER,
                              pr_nrdconta           IN INTEGER,
                              pr_nrctro             IN INTEGER,
                              Pr_tpproduto          IN INTEGER,
                              pr_rating_sugerido    IN VARCHAR2,
                              pr_justificativa      IN VARCHAR2,
                              pr_botao_chamada      IN INTEGER,
                              pr_xmllog             IN VARCHAR2, --> XML com informações de LOG
                              pr_cdcritic           OUT PLS_INTEGER, --> Código da crítica
                              pr_dscritic           OUT VARCHAR2, --> Descrição da crítica
                              pr_retxml             IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                              pr_nmdcampo           OUT VARCHAR2, --> Nome do campo com erro
                              pr_des_erro           OUT VARCHAR2) ;

   /* Validar o rating que foi sugerido*/
  FUNCTION fn_valida_rating_sugerido(pr_cdcooper           IN  tbrat_param_geral.cdcooper%TYPE,
                                     pr_msg                OUT VARCHAR2,
                                     pr_inpessoa           IN  tbrat_param_geral.inpessoa%TYPE,
                                     pr_tpproduto          IN  tbrat_param_geral.tpproduto%TYPE,
                                     pr_rating_sugerido    IN  CHAR,
                                     pr_rating_modelo      IN  CHAR,
                                     pr_data_rating_modelo IN  DATE,
                                     pr_origem_validacao   IN  CHAR )
                                      /* C na consulta / ou A quando altera */ return CHAR;

  FUNCTION fn_pode_alterar_rating (pr_cdcooper  IN INTEGER,
                                   pr_cdcritic OUT pls_INTEGER, --> codigo da critica
                                   pr_dscritic OUT VARCHAR2 --> descricao da critica
                                   )RETURN BOOLEAN;

  PROCEDURE pc_apresenta_rating_motor(pr_nrdconta   IN INTEGER, --> CONTA
                                      pr_nrctro     IN INTEGER, --CONTRATO
                                      pr_tpctrato   IN INTEGER,
                                      pr_xmllog     IN VARCHAR2, --> XML com informacoes de LOG
                                      pr_cdcritic   OUT PLS_INTEGER, --> Codigo da critica
                                      pr_dscritic   OUT VARCHAR2, --> Descricao da critica
                                      pr_retxml     IN OUT NOCOPY xmltype, --> Arquivo de retorno do XML
                                      pr_nmdcampo   OUT VARCHAR2, --> Nome do campo com erro
                                      pr_des_erro   OUT VARCHAR2);

   /* Gerar Historico pela tela do ratmov*/
  PROCEDURE pc_imp_historico_web(pr_nrcpfcgc   IN INTEGER,              --> CPF/CNPJ
                                 pr_nrdconta   IN INTEGER,              --> CONTA
                                 pr_nrctro     IN INTEGER,              --> CONTRATO
                                 pr_status     IN INTEGER,
                                 pr_datafim    IN VARCHAR2,                 --> DATA FIM PARA BUSCA
                                 pr_dataini    IN VARCHAR2,                 --> DATA INICIO  PARA A BUSCA
                                 pr_crapbdc    IN CHAR,                 --> Cadastro de borderos de descontos de cheques
                                 pr_crapbdt    IN CHAR,                 -->Cadastro de borderos de descontos de titulos
                                 pr_craplim    IN CHAR,                 -->Contratos de Limite de credito
                                 pr_crawepr    IN CHAR,                 --> tabela empre
                                 pr_crapcpa    IN CHAR,                 --> pre aprovado
                                 pr_contrliq   IN CHAR,                 --> se contrato é liquidado
                                 pr_xmllog     IN VARCHAR2,             --> XML com informacoes de LOG
                                 pr_cdcritic   OUT PLS_INTEGER,         --> Codigo da critica
                                 pr_dscritic   OUT VARCHAR2,            --> Descricao da critica
                                 pr_retxml     IN OUT NOCOPY xmltype,   --> Arquivo de retorno do XML
                                 pr_nmdcampo   OUT VARCHAR2,            --> Nome do campo com erro
                                 pr_des_erro   OUT VARCHAR2);

   /* sequencia de imprimir o histórico rating*/
  PROCEDURE pc_imp_historico(pr_cdcooper   IN crapcop.cdcooper%TYPE,      --> Código da Cooperativa
                             pr_nrcpfcgc   IN INTEGER,                    --> CPF/CNPJ
                             pr_nrdconta   IN INTEGER,                    --> CONTA
                             pr_nrctro     IN INTEGER,                    --> CONTRATO
                             pr_status     IN INTEGER,
                             pr_datafim    IN VARCHAR2,                   --> DATA FIM PARA BUSCA
                             pr_dataini    IN VARCHAR2,                   --> DATA INICIO  PARA A BUSCA
                             pr_crapbdc    IN CHAR,                       --> Cadastro de borderos de descontos de cheques
                             pr_crapbdt    IN CHAR,                       -->Cadastro de borderos de descontos de titulos
                             pr_craplim    IN CHAR,                       -->Contratos de Limite de credito
                             pr_crawepr    IN CHAR,                       --> tabela empre
                             pr_contrliq   IN CHAR,                       --> se contrato é liquidado
                             pr_cdopecxa   IN crapope.cdoperad%TYPE,
                             pr_idorigem   IN INTEGER,                    --> Identificador de Origem
                             pr_cdprogra   IN crapprg.cdprogra%TYPE,      --> Codigo do programa
                             pr_cdoperad   IN crapope.cdoperad%TYPE,      --> Código do operador
                             pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE,      --> Data de Movimento
                             pr_flgerlog   IN INTEGER,                    --> Indicador se deve gerar log(0-nao, 1-sim)
                             pr_nmdatela   IN craptel.nmdatela%TYPE ,
                             --------> OUT <--------
                             pr_nmarqpdf   OUT VARCHAR2,                  --> Retorna Nome do arquivo
                             pr_cdcritic   OUT PLS_INTEGER,               --> Código da crítica
                             pr_dscritic   OUT VARCHAR2);                 --> Descrição da crítica

                                ---------->> CURSORES <<--------
  -- Calendário da cooperativa selecionada
  rw_crapdat           btch0001.cr_crapdat%ROWTYPE;
  vr_des_mask_contrato VARCHAR2(14); 
  
  -- buscar contratos emprestimos
  -- ************************************************************
  CURSOR cr_busca_contratos_emp(vr_cdcooper    IN crapass.CDCOOPER%TYPE,
                                vr_nrcpfcgc    IN crapass.nrcpfcgc%type,
                                vr_nrdconta    IN crawepr.nrdconta%type,
                                vr_nrctro      IN crawepr.Nrctremp%type,
                                vr_status      IN INTEGER,
                                vr_dataini     IN DATE,
                                vr_datafim     IN DATE,
                                vr_contrliq    IN CHAR,
                                vr_finalidade  IN INTEGER := 0                              
                               ) IS
  
     SELECT /*+ INDEX(crapepr CRAPEPR##CRAPEPR3) */
       epr.dtmvtolt               AS rat_atu_data
      ,epr.nrdconta               AS nrdconta
      ,90                         AS origem_consulta
      ,epr.nrctremp               AS contrato
      ,epr.vlemprst               AS valor
      ,oper.inrisco_rating_autom  AS rating_modelo
      ,oper.dtrisco_rating_autom  AS rat_mod_data
      ,inrisco_rating             AS rating_atual
      ,oper.dtrisco_rating        AS data_efet
      ,oper.dtrisco_rating + DECODE(NVL(oper.innivel_rating,2)
                                       ,1, tpg.qtdias_atualizacao_autom_baixo
                                       ,2, tpg.qtdias_atualizacao_autom_medio
                                       ,3, tpg.qtdias_atualizacao_autom_alto) AS dt_vencimento
      ,epr.cdcooper               AS cdcooper
      ,ass.nrcpfcgc               AS nrcpfcgc
      ,ass.inpessoa               AS tipo_pessoa
      ,insituacao_rating          AS status
      ,ass.nmprimtl               AS nmprimtl
      ,decode(oper.inorigem_rating,
              1,'MOTOR',
              2,'ESTEIRA',
              3,'REGRA AIMARO',
              4,'CONTINGÊNCIA')   AS origem_rating
      ,decode(oper.insituacao_rating,
              0,'NAO ENVIADO',
              1,'EM ANALISE',
              2,'ANALISADO',
              3,'VENCIDO',
              4,'EFETIVADO',
              5,'EM CONTINGENCIA') AS desc_sit
      ,decode(nvl(oper.innivel_rating, 2),
              1,tpg.qtdias_atualizacao_autom_baixo,
              2,tpg.qtdias_atualizacao_autom_medio,
              3,tpg.qtdias_atualizacao_autom_alto) AS qt_dias_vencimento
      ,epr.inliquid AS situacaoContrato
      ,0 AS majorado
      ,epr.cdfinemp AS finalidade
    FROM  
        crapepr            epr
        ,crapass           ass
        ,tbrisco_operacoes oper
        ,tbrat_param_geral tpg
    WHERE 
          epr.nrdconta = ass.nrdconta
      AND epr.cdcooper = ass.cdcooper
      AND oper.cdcooper = epr.cdcooper
      AND oper.nrdconta = epr.nrdconta
      AND oper.nrctremp = epr.nrctremp
      AND tpg.cdcooper = ass.cdcooper
      AND tpg.inpessoa = ass.inpessoa
      AND ass.dtdemiss IS NULL -- ativos
      AND tpg.tpproduto = 90
      AND epr.cdcooper = vr_cdcooper
      /* não mostrar contratos que não tem rating */
      AND (oper.inrisco_rating_autom IS NOT NULL)
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      AND ((epr.nrdconta = vr_nrdconta AND
          NVL(vr_nrctro, epr.nrctremp) = epr.nrctremp) OR
          (vr_nrdconta IS NULL AND vr_nrcpfcgc = ass.nrcpfcgc AND
          NVL(vr_nrctro, epr.nrctremp) = epr.nrctremp))
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      /* pesquisa por data proposta */
      AND ((vr_dataini IS NULL) OR (epr.dtmvtolt >= vr_dataini))
      AND ((vr_datafim IS NULL) OR (epr.dtmvtolt <= vr_datafim))
      /* pesquisa por data proposta */
      AND ((NVL(vr_contrliq, 'N') = 'S') OR /* considerar todos os contratos se tiver flagado S*/
          (NVL(vr_contrliq, 'N') = 'N' AND epr.inliquid <> 1))
      AND ((vr_status <> 9 AND oper.insituacao_rating = vr_status) OR
          vr_status = 9)
     ;
  -- ************************************************************
  -- buscar contratos lim
  -- ************************************************************
  CURSOR cr_busca_contratos_lim(vr_cdcooper  IN crapass.CDCOOPER%TYPE,
                                vr_nrcpfcgc  IN crapass.nrcpfcgc%type,
                                vr_nrdconta  IN crawepr.nrdconta%type,
                                vr_nrctro    IN crawepr.Nrctremp%type,
                                vr_status    IN INTEGER,
                                vr_tpproduto IN INTEGER,
                                vr_dataini   IN DATE,
                                vr_datafim   IN DATE,
                                vr_contrliq  IN CHAR -- contrato liquidado
                               ) IS
    SELECT /*+ INDEX(craplim CRAPLIM##CRAPLIM1) */
        lim.dtpropos              AS rat_atu_data
       ,lim.nrdconta              AS nrdconta
       ,vr_tpproduto              AS origem_consulta
       ,lim.nrctrlim              AS contrato
       ,lim.vllimite              AS valor
       ,oper.inrisco_rating_autom AS rating_modelo
       ,oper.dtrisco_rating_autom AS rat_mod_data
       ,oper.inrisco_rating       AS rating_atual
       ,oper.dtrisco_rating       AS data_efet
       ,oper.dtrisco_rating + DECODE(NVL(oper.innivel_rating,2)
                                          ,1, tpg.qtdias_atualizacao_autom_baixo
                                          ,2, tpg.qtdias_atualizacao_autom_medio
                                          ,3, tpg.qtdias_atualizacao_autom_alto) AS dt_vencimento
       ,lim.cdcooper              AS cdcooper
       ,ass.nrcpfcgc              AS nrcpfcgc
       ,ass.inpessoa              AS tipo_pessoa
       ,oper.insituacao_rating    AS status
       ,ass.nmprimtl              AS nmprimtl
       ,decode(oper.inorigem_rating,
               1,'MOTOR',
               2,'ESTEIRA',
               3,'REGRA AIMARO',
               4,'CONTINGÊNCIA')  AS origem_rating
       ,decode(oper.insituacao_rating,
               0,'NAO ENVIADO',
               1,'EM ANALISE',
               2,'ANALISADO',
               3,'VENCIDO',
               4,'EFETIVADO',
               5,'EM CONTINGENCIA')  AS desc_sit
       ,decode(nvl(oper.innivel_rating, 2),
               1,tpg.qtdias_atualizacao_autom_baixo,
               2,tpg.qtdias_atualizacao_autom_medio,
               3,tpg.qtdias_atualizacao_autom_alto) AS qt_dias_vencimento
       ,lim.insitlim AS situacaoContrato
       ,0 AS majorado
       ,0 AS finalidade
    FROM 
        craplim           lim
       ,crapass           ass
       ,tbrat_param_geral tpg
       ,tbrisco_operacoes oper
    WHERE 
          lim.cdcooper = oper.cdcooper
      AND lim.nrdconta = oper.nrdconta
      AND lim.nrctrlim = oper.nrctremp
      AND lim.nrdconta = ass.nrdconta
      AND lim.cdcooper = ass.cdcooper
      AND lim.tpctrlim = oper.tpctrato
      AND dtdemiss IS NULL -- ativos
      AND tpg.cdcooper = ass.cdcooper
      AND tpg.inpessoa = ass.inpessoa
      AND tpg.tpproduto = lim.tpctrlim
      AND dtdemiss IS NULL
      AND lim.tpctrlim = vr_tpproduto
      AND lim.cdcooper = vr_cdcooper
      /* não mostrar contratos que não tem rating */
      AND (oper.inrisco_rating_autom IS NOT NULL)
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      AND ((lim.nrdconta = vr_nrdconta AND
          NVL(vr_nrctro, lim.nrctrlim) = lim.nrctrlim) OR
          (vr_nrdconta IS NULL AND vr_nrcpfcgc = ass.nrcpfcgc AND
          NVL(vr_nrctro, lim.nrctrlim) = lim.nrctrlim))
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      /* pesquisa por data proposta */
      AND ((vr_dataini IS NULL) OR (lim.dtpropos >= vr_dataini))
      AND ((vr_datafim IS NULL) OR (lim.dtpropos <= vr_datafim))
      /* pesquisa por data proposta */
      AND (((NVL(vr_contrliq, 'N') = 'S') AND lim.insitlim IN (2,3))
          OR ((NVL(vr_contrliq, 'N') = 'N') AND lim.insitlim = 2))
      AND ((vr_status <> 9 AND oper.insituacao_rating = vr_status) OR
          vr_status = 9)
    ;
  -- ************************************************************
  -- buscar contratos lim majorados
  -- ************************************************************
  CURSOR cr_busca_contratos_lim_maj(vr_cdcooper  IN crapass.CDCOOPER%TYPE,
                                    vr_nrcpfcgc  IN crapass.nrcpfcgc%type,
                                    vr_nrdconta  IN crawepr.nrdconta%type,
                                    vr_nrctro    IN crawepr.Nrctremp%type,
                                    vr_status    IN INTEGER,
                                    vr_tpproduto IN INTEGER,
                                    vr_dataini   IN DATE,
                                    vr_datafim   IN DATE,
                                    vr_contrliq  IN CHAR -- contrato liquidado
                                   ) IS
    SELECT /*+ INDEX(craplim CRAPLIM##CRAPLIM1) */
        lim.dtpropos              AS rat_atu_data
       ,lim.nrdconta              AS nrdconta
       ,vr_tpproduto              AS origem_consulta
       ,lim.nrctrmnt              AS contrato
       ,lim.vllimite              AS valor
       ,oper.inrisco_rating_autom AS rating_modelo
       ,oper.dtrisco_rating_autom AS rat_mod_data
       ,oper.inrisco_rating       AS rating_atual
       ,oper.dtrisco_rating       AS data_efet
       ,oper.dtrisco_rating + DECODE(NVL(oper.innivel_rating,2)
                                          ,1, tpg.qtdias_atualizacao_autom_baixo
                                          ,2, tpg.qtdias_atualizacao_autom_medio
                                          ,3, tpg.qtdias_atualizacao_autom_alto) AS dt_vencimento
       ,lim.cdcooper              AS cdcooper
       ,ass.nrcpfcgc              AS nrcpfcgc
       ,ass.inpessoa              AS tipo_pessoa
       ,oper.insituacao_rating    AS status
       ,ass.nmprimtl              AS nmprimtl
       ,decode(oper.inorigem_rating,
               1,'MOTOR',
               2,'ESTEIRA',
               3,'REGRA AIMARO',
               4,'CONTINGÊNCIA')  AS origem_rating
       ,decode(oper.insituacao_rating,
               0,'NAO ENVIADO',
               1,'EM ANALISE',
               2,'ANALISADO',
               3,'VENCIDO',
               4,'EFETIVADO',
               5,'EM CONTINGENCIA')  AS desc_sit
       ,decode(nvl(oper.innivel_rating, 2),
               1,tpg.qtdias_atualizacao_autom_baixo,
               2,tpg.qtdias_atualizacao_autom_medio,
               3,tpg.qtdias_atualizacao_autom_alto) AS qt_dias_vencimento
       ,lim.insitlim AS situacaoContrato
       ,1 AS majorado
       ,0 AS finalidade
    FROM 
        crawlim           lim
       ,crapass           ass
       ,tbrat_param_geral tpg
       ,tbrisco_operacoes oper
    WHERE 
          lim.cdcooper = oper.cdcooper
      AND lim.nrdconta = oper.nrdconta
      AND lim.nrctrmnt = oper.nrctremp
      AND lim.nrdconta = ass.nrdconta
      AND lim.cdcooper = ass.cdcooper
      AND lim.tpctrlim = oper.tpctrato
      AND dtdemiss IS NULL -- ativos
      AND tpg.cdcooper = ass.cdcooper
      AND tpg.inpessoa = ass.inpessoa
      AND tpg.tpproduto = lim.tpctrlim
      AND lim.tpctrlim = vr_tpproduto
      AND lim.cdcooper = vr_cdcooper
      AND lim.insitlim IN (1,2) -- Apenas Em Etudo para Majoracao
      /* não mostrar contratos que não tem rating */
      AND (oper.inrisco_rating_autom IS NOT NULL)
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      AND lim.nrdconta = vr_nrdconta
      AND lim.nrctrmnt = NVL(vr_nrctro, lim.nrctrmnt) 
      /* consulta por conta ou conta e contrato ou cpf/cnpj ou cpf/cnpj e contrato */
      /* pesquisa por data proposta */
      AND ((vr_dataini IS NULL) OR (lim.dtpropos >= vr_dataini))
      AND ((vr_datafim IS NULL) OR (lim.dtpropos <= vr_datafim))
      /* pesquisa por data proposta */
      AND ((vr_status <> 9 AND oper.insituacao_rating = vr_status) OR
          vr_status = 9)
    ;
  -- ************************************************************
  -- buscar pre-aprovado
  -- ************************************************************
  CURSOR cr_busca_pre_aprovado(vr_cdcooper  IN crapass.CDCOOPER%TYPE,
                               vr_nrcpfcgc  IN crapass.nrcpfcgc%type,
                               vr_nrdconta  IN crapass.nrdconta%type,
                               vr_status    IN INTEGER,
                               vr_contrliq  IN CHAR -- contrato liquidado                             
                              ) IS
    SELECT /*+ INDEX(crapcpa CRAPCPA##CRAPCPA1) */ 
        DISTINCT
        cpa.dtmvtolt              AS rat_atu_data
       ,decode(vr_nrdconta,NULL,0,ass.nrdconta) AS nrdconta
       ,68                        AS origem_consulta
       ,oper.nrctremp             AS contrato
       ,cpa.vlpot_lim_max         AS valor
       ,oper.inrisco_rating_autom AS rating_modelo
       ,oper.dtrisco_rating_autom AS rat_mod_data
       ,oper.inrisco_rating       AS rating_atual
       ,oper.dtrisco_rating       AS data_efet
       ,oper.dtrisco_rating + DECODE(NVL(oper.innivel_rating,2)
                                          ,1, tpg.qtdias_atualizacao_autom_baixo
                                          ,2, tpg.qtdias_atualizacao_autom_medio
                                          ,3, tpg.qtdias_atualizacao_autom_alto) AS dt_vencimento
       ,cpa.cdcooper              AS cdcooper
       ,ass.nrcpfcgc              AS nrcpfcgc
       ,decode(vr_nrdconta,NULL,0,ass.inpessoa) AS tipo_pessoa
       ,oper.insituacao_rating    AS status
       ,decode(vr_nrdconta,NULL,'',ass.nmprimtl ) AS nmprimtl
       ,decode(oper.inorigem_rating,
               1,'MOTOR',
               2,'ESTEIRA',
               3,'REGRA AIMARO',
               4,'CONTINGÊNCIA')  AS origem_rating
       ,decode(oper.insituacao_rating,
               0,'NAO ENVIADO',
               1,'EM ANALISE',
               2,'ANALISADO',
               3,'VENCIDO',
               4,'EFETIVADO',
               5,'EM CONTINGENCIA') AS desc_sit
       ,decode(nvl(oper.innivel_rating, 2),
               1,tpg.qtdias_atualizacao_autom_baixo,
               2,tpg.qtdias_atualizacao_autom_medio,
               3,tpg.qtdias_atualizacao_autom_alto) AS qt_dias_vencimento
       ,0 AS situacaoContrato
       ,0 AS majorado
       ,0 AS finalidade
    FROM 
        crapcpa           cpa
       ,crapass           ass
       ,tbrat_param_geral tpg
       ,tbrisco_operacoes oper
       ,tbepr_carga_pre_aprv car
       ,crapdat           dat
    WHERE 
          cpa.cdcooper = ass.cdcooper
      AND cpa.nrcpfcnpj_base = ass.nrcpfcnpj_base
      AND cpa.cdcooper = oper.cdcooper
      AND cpa.nrcpfcnpj_base = oper.nrcpfcnpj_base 
      AND oper.tpctrato = 68
      AND cpa.cdcooper = vr_cdcooper
      AND cpa.cdcooper = dat.cdcooper
      AND cpa.cdcooper = car.cdcooper
      AND cpa.iddcarga = car.idcarga
      AND (((NVL(vr_contrliq, 'N') = 'S') AND cpa.cdsituacao IN ('A','R','B'))
          OR ((NVL(vr_contrliq, 'N') = 'N') AND cpa.cdsituacao = 'A'))
      AND car.indsituacao_carga  = 2
      AND car.flgcarga_bloqueada = 0
      AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(dat.dtmvtolt)
      AND tpg.cdcooper = oper.cdcooper
      AND tpg.inpessoa = ass.inpessoa
      AND tpg.tpproduto = 90 -- Para Pré-Aprovado utilizar 90 - Empréstimo.
      /* não mostrar contratos que não tem rating */
      AND (oper.inrisco_rating_autom IS NOT NULL)
      /* consulta por conta ou cpf/cnpj */
      AND ((ass.nrdconta = vr_nrdconta) OR
           (ass.nrcpfcgc = vr_nrcpfcgc AND vr_nrdconta IS NULL))
      /* consulta por conta ou cpf/cnpj */
      AND ((vr_status <> 9 AND oper.insituacao_rating = vr_status) OR
          vr_status = 9)
  ;
  -- ************************************************************
  -- tabela temporaria para busca de contratos
  -- ************************************************************
  TYPE typ_rec_busca_contratos
    IS RECORD (rat_atu_data       DATE,
               nrdconta           NUMBER(10),
               origem_consulta    NUMBER(5),
               contrato           NUMBER(10),
               valor              NUMBER(25,2),
               rating_modelo      NUMBER(5),
               rat_mod_data       DATE,
               rating_atual       NUMBER(5),
               data_efet          DATE,
               dt_vencimento      DATE,
               cdcooper           NUMBER(10),
               nrcpfcgc           NUMBER(25),
               tipo_pessoa        NUMBER(5),
               status             NUMBER(5),
               nmprimtl           VARCHAR2(60),
               origem_rating      VARCHAR2(60),
               desc_sit           VARCHAR2(60),
               qt_dias_vencimento NUMBER(10),
               situacaoContrato   NUMBER(5),
               majorado           NUMBER(1),
               finalidade         NUMBER(5));

  TYPE typ_tab_busca_contratos IS TABLE OF typ_rec_busca_contratos INDEX BY binary_integer;

END TELA_RATMOV ;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_RATMOV IS
  ---------------------------------------------------------------------------
  --
  --   Programa: tela_ratmov
  --   Sistema : CECRED
  --   Sigla   : RATMOV
  --   Autor   : Daniele Rocha/AMcom
  --   Data    : Fevereiro/2019                 Ultima atualizacao: --
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela RATMOV
  -- Alteracoes:
  -- Obs: Tipo de produto (0-Emprestimo/Financiamento, 1-Limite Desconto Cheque, 2-Limite Credito, 3-Desconto Titulo, 4-Cartao de Credito)
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar(pr_nmprimtl  IN VARCHAR2,
                         pr_nrcpfcgc  IN INTEGER,
                         pr_xmllog    IN VARCHAR2,            --> XML com informações de LOG
                         pr_cdcritic  OUT PLS_INTEGER,        --> Código da crítica
                         pr_dscritic  OUT VARCHAR2,           --> Descrição da crítica
                         pr_retxml    IN OUT NOCOPY XMLType,  --> Arquivo de retorno do XML
                         pr_nmdcampo  OUT VARCHAR2,           --> Nome do campo com erro
                         pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
    /* .............................................................................
        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : RATMOV
        Autor   : Daniele Rocha/AMcom
        Data    : Janeiro/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  :

        Observacao: -----

        Alteracoes: 30/05/2019 - Alteração da frase da pesquisa para a sugestão
                                 enviada pela Ailos (Luiz Otávio Olinger Momm - AMCOM)

                    23/07/2019 - Alteração da busca para novos cursores e tabela temporaria
                                 (Luiz Otávio Olinger Momm - AMCOM)

    ..............................................................................*/
    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic              crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic              VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida             EXCEPTION;

    vr_nrcpfcgc              crapass.nrcpfcgc%type;
    vr_nmprimtl              crapass.nmprimtl%type;
    vr_auxconta              INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    -- VariaveIS retornadas da gene0004.pc_extrai_dados
    vr_cdcooper              INTEGER;
    vr_cdoperad              VARCHAR2(100);
    vr_nmdatela              VARCHAR2(100);
    vr_nmeacao               VARCHAR2(100);
    vr_cdagenci              VARCHAR2(100);
    vr_nrdcaixa              VARCHAR2(100);
    vr_idorigem              VARCHAR2(100);

    ---------->> CURSORES <<--------
    CURSOR cr_crapass          (vr_cdcooper  IN crapass.CDCOOPER%TYPE,
                                vr_nrcpfcgc  IN crapass.nrcpfcgc%type,
                                vr_nmprimtl  IN crapass.nmprimtl%type ) IS

      SELECT
        nmprimtl,
        NRCPFCGC
      FROM
        crapass
      WHERE ((upper(NMPRIMTL) LIKE upper('%' || vr_nmprimtl || '%') AND
             vr_nrcpfcgc IS NULL AND vr_nmprimtl IS NOT NULL) OR
             (upper(NRCPFCGC) = vr_nrcpfcgc AND vr_nmprimtl IS NULL AND
             vr_nrcpfcgc IS NOT NULL) or
             (upper(nmprimtl) LIKE upper('%' || vr_nmprimtl || '%') and
             NRCPFCGC = vr_nrcpfcgc AND vr_nmprimtl IS NOT NULL AND
             vr_nrcpfcgc IS NOT NULL))
            AND dtdemiss IS NULL
            AND cdcooper  = vr_cdcooper;

    rw_crapass                    CR_crapass%ROWTYPE;
    pr_pos_conta                  integer := 0 ;


  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

     -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);



    FOR rw_crapass IN cr_crapass(vr_cdcooper => vr_cdcooper,
                                 vr_nrcpfcgc => pr_nrcpfcgc,
                                 vr_nmprimtl => pr_nmprimtl ) LOOP

     --Se encontrou, passa os valores para as variáveIS criadas

      vr_nmprimtl     := rw_crapass.nmprimtl;
      vr_nrcpfcgc     := rw_crapass.nrcpfcgc;


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'crapass',
                             pr_tag_cont => NULL,
                             pr_des_erro => pr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'crapass',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'pr_nmprimtl',
                             pr_tag_cont => vr_nmprimtl,
                             pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'crapass',
                             pr_posicao  => pr_pos_conta,
                             pr_tag_nova => 'pr_nrcpfcgc',
                             pr_tag_cont => to_char(vr_nrcpfcgc),
                             pr_des_erro => pr_dscritic);


      pr_pos_conta := pr_pos_conta + 1;

    END LOOP;

    gene0007.pc_insere_tag(pr_xml    => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'pr_totaIS',
                         pr_tag_cont => pr_pos_conta ,
                         pr_des_erro => pr_dscritic);

    --Numero registros
    IF nvl(pr_pos_conta ,0) = 0 THEN
      vr_cdcritic := 009;
      RAISE vr_exc_saida;
    END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- ExISte para satISfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                       SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- ExISte para satISfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;

  END pc_consultar;



  PROCEDURE pc_consultar_rating(pr_nrcpfcgc IN INTEGER, --> CPF/CNPJ
                                pr_nrdconta IN INTEGER, --> CONTA
                                pr_nrctro   IN INTEGER, --CONTRATO
                                pr_status   IN INTEGER,
                                pr_datafim  IN VARCHAR2, -- DATA FIM PARA BUSCA
                                pr_dataini  IN VARCHAR2, -- DATA INICIO  PARA A BUSCA
                                pr_crapbdc  IN CHAR, -- Cadastro de borderos de descontos de cheques
                                pr_crapbdt  IN CHAR, -->Cadastro de borderos de descontos de titulos
                                pr_craplim  IN CHAR, -->Contratos de Limite de credito
                                pr_crawepr  IN CHAR, --> tabela empre
                                pr_crapcpa  IN CHAR, --> pre aprovado
                                pr_contrliq IN CHAR, --> se contrato é liquidado
                                pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                pr_des_erro OUT VARCHAR2) IS

  /* .............................................................................
      Programa: pc_consultar_rating
      Sistema : CECRED
      Sigla   : RATMOV
      Autor   : Daniele Rocha/AMcom
      Data    : Fevereiro/2019                 Ultima atualizacao: --

      Dados referentes ao programa: Consultar Contratos e informações Rating

      Frequencia: Sempre que for chamado

      Objetivo  : retornar consultas para tela RATMOV

      Observacao: -----

      Alteracoes:

               02/05/2019 - PJ450 - Ajuste no Tempo de atualização do Rating no cursor cr_busca_contratos
                                    coluna QT_DIAS_VENCIMENTO (Mário/AMcom)

               22/07/2019 - PJ450 - Criação dos cursores cr_busca_contratos_emp e cr_busca_contratos_lim
                                    para substituir um cursor genérico para melhoria de performance
                                    (Luiz Otávio Olinger Momm / AMCOM)

               23/07/2019 - PJ450 - Criação da tabela typ_tab_busca_contratos para gerenciamento das
                                    buscas dos cursores cr_busca_contratos_emp e cr_busca_contratos_lim
                                    (Luiz Otávio Olinger Momm / AMCOM)

               15/08/2019 - PJ450 - Criação do produto pre aprovado na consulta da RATMOV
                                    (Luiz Otávio Olinger Momm - AMCOM)

               20/08/2019 - PJ450 - Adicionado cursor para consultar pré-aprovado
                                    (Weverton Otoni (Amcom))  
               02/09/2019 - PJ450 - Nova Sigla para contrato de emprestimos de pre-aprovado
                                    (Luiz Otávio Olinger Momm - AMCOM)                                    
                 
               04/09/2019 - PJ 450 - Alteração nos cursores cr_busca_contratos_emp 
                                     para considerar os pré-aprovados antes da data de corte,
                                     carregando como empréstimos e no cursor cr_busca_pre_aprovado
                                     para considerar a data de corte                                      
                                     (Heckmann - AMcom)
  ..............................................................................*/
  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

  -- VariaveIS retornadas da gene0004.pc_extrai_dados
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  -- paramentro a mais retornado xml para servir como parametro da consulta

  vr_data_efet              DATE;
  vr_mostra_nrdconta        INTEGER;
  vr_origem_consulta        VARCHAR2(3);
  vr_contrato               INTEGER;
  vr_valor                  NUMBER(17, 2);
  vr_rating_modelo          VARCHAR2(2);
  vr_rat_mod_data           DATE;
  vr_rating_atual           VARCHAR2(2);
  vr_mostra_nrcpfcgc        INTEGER;
  vr_rat_atu_data           DATE;
  vr_tipo_pessoa            INTEGER;
  vr_mostra_status          INTEGER;
  vr_sn_alterar_rat         VARCHAR2(1);
  vr_desc_rating_autom      VARCHAR2(2);
  vr_desc_rating_atual      VARCHAR2(2);
  vr_origem_rating          VARCHAR2(20);
  vr_desc_sit               VARCHAR2(20);
  pr_pos_conta              INTEGER := 0;
  vr_msg                    VARCHAR2(400);
  vr_finalidade             INTEGER := 0;

  vr_qt_expiracao_nota      tbrat_param_geral.qtmeses_expiracao_nota%type;
  vr_vencimento             DATE;
  
  vr_tab_busca_contratos    typ_tab_busca_contratos;
  vr_index                  INTEGER;
  vr_dt_corte_refor_rating  DATE;

BEGIN
  pr_des_erro := 'OK';
  -- Extrai dados do xml
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                           pr_cdcooper => vr_cdcooper,
                           pr_nmdatela => vr_nmdatela,
                           pr_nmeacao  => vr_nmeacao,
                           pr_cdagenci => vr_cdagenci,
                           pr_nrdcaixa => vr_nrdcaixa,
                           pr_idorigem => vr_idorigem,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic);

  -- Se retornou alguma crítica
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Levanta exceção
    RAISE vr_exc_saida;
  END IF;

  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  --> Buscar Parametro Data de Corte do Projeto Reformulação do Rating
  vr_dt_corte_refor_rating := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                pr_cdcooper => 0,
                                                                pr_cdacesso => 'DT_CORTE_REFOR_RATING'),
                                      'dd/mm/rrrr');

  /* Cria tabela temporário com empréstimos */
  vr_index := 0;
  IF (pr_crawepr = 'S') THEN
    FOR rw_busca IN cr_busca_contratos_emp(vr_cdcooper => vr_cdcooper,
                                           vr_nrcpfcgc => pr_nrcpfcgc,
                                           vr_nrdconta => pr_nrdconta,
                                           vr_nrctro   => pr_nrctro,
                                           vr_status   => pr_status,
                                           vr_dataini  => to_date(pr_dataini, 'DD/MM/YYYY'),
                                           vr_datafim  => to_date(pr_datafim, 'DD/MM/YYYY'),
                                           vr_contrliq => pr_contrliq -- contrato liquidado                                     
                                           ) LOOP
      vr_tab_busca_contratos(vr_index) := rw_busca;
      vr_index := vr_index + 1;
    END LOOP;
  END IF;

  /* Cria tabela temporário com limites de crédito, desconto de título e desconto de título */
  FOR i IN 1 .. 3 LOOP

    -- Limite de credito
    IF i = 1 AND pr_craplim = 'N' THEN
      CONTINUE;
    END IF;
    
    -- Limite desconto cheque
    IF i = 2 AND pr_crapbdc = 'N' THEN
      CONTINUE;
    END IF;
    
    -- Limite Desconto Título
    IF i = 3 AND pr_crapbdt = 'N' THEN
      CONTINUE;
    END IF;

    FOR rw_busca IN cr_busca_contratos_lim(vr_cdcooper  => vr_cdcooper,
                                           vr_nrcpfcgc  => pr_nrcpfcgc,
                                           vr_nrdconta  => pr_nrdconta,
                                           vr_nrctro    => pr_nrctro,
                                           vr_status    => pr_status,
                                           vr_tpproduto => i,
                                           vr_dataini  => to_date(pr_dataini, 'DD/MM/YYYY'),
                                           vr_datafim  => to_date(pr_datafim, 'DD/MM/YYYY'),
                                           vr_contrliq  => pr_contrliq
                                           ) LOOP
      vr_tab_busca_contratos(vr_index) := rw_busca;
      vr_index := vr_index + 1;
    END LOOP;
  END LOOP;
  
  -- Weverton Otoni - P450 - 22/08/2019
  IF (pr_crapcpa = 'S') THEN
    FOR rw_busca IN cr_busca_pre_aprovado(vr_cdcooper  => vr_cdcooper,
                                          vr_nrcpfcgc   => pr_nrcpfcgc,
                                          vr_nrdconta   => pr_nrdconta,
                                          vr_status     => pr_status,
                                          vr_contrliq  => pr_contrliq) LOOP
      vr_tab_busca_contratos(vr_index) := rw_busca;
      vr_index := vr_index + 1;
    END LOOP;
  END IF;                            

  /* Caso não encontrado nenhum registro na consulta */  
  IF (vr_index = 0) THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Dados não encontrados';
    RAISE vr_exc_saida;
  END IF;

  FOR i IN vr_tab_busca_contratos.FIRST .. vr_tab_busca_contratos.LAST LOOP
    vr_mostra_nrcpfcgc := vr_tab_busca_contratos(i).nrcpfcgc; --1
    vr_data_efet       := vr_tab_busca_contratos(i).data_efet; --2
    vr_mostra_nrdconta := vr_tab_busca_contratos(i).nrdconta; --3
    vr_origem_consulta := vr_tab_busca_contratos(i).origem_consulta; --4
    vr_contrato        := vr_tab_busca_contratos(i).contrato; --5
    vr_valor           := vr_tab_busca_contratos(i).valor; --6
    vr_rating_modelo   := vr_tab_busca_contratos(i).rating_modelo; --7
    vr_rat_mod_data    := vr_tab_busca_contratos(i).rat_mod_data; --8
    vr_rating_atual    := vr_tab_busca_contratos(i).rating_atual; --9
    vr_rat_atu_data    := vr_tab_busca_contratos(i).rat_atu_data; --10
    vr_tipo_pessoa     := vr_tab_busca_contratos(i).tipo_pessoa; --11
    vr_mostra_status   := vr_tab_busca_contratos(i).status; --12
    vr_origem_rating   := vr_tab_busca_contratos(i).origem_rating; --13
    vr_desc_sit        := vr_tab_busca_contratos(i).desc_sit;
    vr_finalidade      := vr_tab_busca_contratos(i).finalidade;
    
    /* Considerar antes da data de virada o CPA como EMP na RATMOV */
    IF vr_rat_atu_data < vr_dt_corte_refor_rating THEN
      vr_finalidade := 0;
    END IF;

    IF vr_data_efet IS NOT NULL THEN
      vr_vencimento      := vr_tab_busca_contratos(i).dt_vencimento;
    ELSE
      vr_vencimento      := NULL;
    END IF;

    vr_desc_rating_autom := NULL;
    IF vr_tab_busca_contratos(i).rating_modelo IS NOT NULL THEN
      BEGIN
        vr_desc_rating_autom := cecred.risc0004.fn_traduz_risco(vr_tab_busca_contratos(i).rating_modelo);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao traduzir o risco do Rating Automatico! ' ||
                         ' para cpf/cnpj:  ' || vr_mostra_nrcpfcgc ||
                         ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                         vr_mostra_nrdconta;
          vr_cdcritic := 0;
          RAISE vr_exc_saida;

      END;
    END IF;

    vr_desc_rating_atual := NULL;
    IF vr_rating_atual IS NOT NULL THEN
      BEGIN
        vr_desc_rating_atual := cecred.risc0004.fn_traduz_risco(vr_tab_busca_contratos(i).rating_atual);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao traduzir o risco do Rating Atual! ' ||
                         ' para cpf/cnpj:  ' || vr_mostra_nrcpfcgc ||
                         ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                         vr_mostra_nrdconta;
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
      END;
    END IF;

    IF  (cecred.tela_ratmov.fn_pode_alterar_rating(pr_cdcooper => vr_cdcooper,
                                                   pr_cdcritic => vr_cdcritic,
                                                   pr_dscritic => vr_dscritic)) THEN

      vr_sn_alterar_rat := cecred.tela_ratmov.fn_valida_rating_sugerido(pr_cdcooper           => vr_cdcooper,
                                                                        pr_msg                => vr_msg,
                                                                        pr_inpessoa           => vr_tipo_pessoa,
                                                                        pr_tpproduto          => vr_origem_consulta,
                                                                        pr_rating_sugerido    => NULL,
                                                                        pr_rating_modelo      => vr_desc_rating_autom,
                                                                        pr_data_rating_modelo => vr_rat_mod_data,
                                                                        pr_origem_validacao   => 'C');
    ELSE
      vr_sn_alterar_rat := 'N';
    END IF;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'crapass',
                           pr_tag_cont => NULL,
                           pr_des_erro => pr_dscritic);

    --1 CPFCNPJ
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_nrcpfcgc',
                           pr_tag_cont => to_char(vr_mostra_nrcpfcgc),
                           pr_des_erro => pr_dscritic);

    --2  Data efetivação
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_data_efet',
                           pr_tag_cont => to_char(TO_CHAR(vr_data_efet,
                                                          'DD/MM/YYYY')),
                           pr_des_erro => pr_dscritic);

    --3 Conta
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_nrdconta',
                           pr_tag_cont => to_char(vr_mostra_nrdconta),
                           pr_des_erro => pr_dscritic);
    --4  Origem da consulta
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_origem_consulta',
                           pr_tag_cont => to_char(vr_origem_consulta),
                           pr_des_erro => pr_dscritic);

    --5  Contrato
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_contrato',
                           pr_tag_cont => to_char(vr_contrato),
                           pr_des_erro => pr_dscritic);

    --6 Valor emprestimo
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_valor',
                           pr_tag_cont => to_char(vr_valor),
                           pr_des_erro => pr_dscritic);

    -- 7 Rating modelo
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_rating_modelo',
                           pr_tag_cont => to_char(vr_desc_rating_autom),
                           pr_des_erro => pr_dscritic);

    -- 8 Rating modelo Data
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_rat_mod_data',
                           pr_tag_cont => to_char(TO_CHAR(vr_rat_mod_data,
                                                          'DD/MM/YYYY')),
                           pr_des_erro => pr_dscritic);

    --9 Rating Atual
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_rating_atual',
                           pr_tag_cont => (vr_desc_rating_atual),
                           pr_des_erro => pr_dscritic);
    --10 Data Rating Atual
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_rat_atu_data',
                           pr_tag_cont => to_char(TO_CHAR(vr_rat_atu_data,
                                                          'DD/MM/YYYY')),
                           pr_des_erro => pr_dscritic);

    --11 tipo pessoa Física/ juridica
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_tipo_pessoa',
                           pr_tag_cont => to_char(vr_tipo_pessoa),
                           pr_des_erro => pr_dscritic);

    --12 status rating
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_status',
                           pr_tag_cont => to_char(vr_mostra_status),
                           pr_des_erro => pr_dscritic);

    --13 Se pode ser alterado
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_sn_alterar_rat',
                           pr_tag_cont => to_char(vr_sn_alterar_rat),
                           pr_des_erro => pr_dscritic);


    --14 Se pode ser alterado
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_origem_rating',
                           pr_tag_cont => to_char(vr_origem_rating),
                           pr_des_erro => pr_dscritic);

    --15 descrição da situação do rating
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_desc_sit',
                           pr_tag_cont => to_char(vr_desc_sit),
                           pr_des_erro => pr_dscritic);

    --16 data vencimento
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_vencimento',
                           pr_tag_cont => to_char(vr_vencimento,'DD/MM/YYYY'),
                           pr_des_erro => pr_dscritic);

    --17 finalidade
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'crapass',
                           pr_posicao  => pr_pos_conta,
                           pr_tag_nova => 'pr_finalidade',
                           pr_tag_cont => vr_finalidade,
                           pr_des_erro => pr_dscritic);

   pr_pos_conta := pr_pos_conta + 1;

  END LOOP;
  
  --dbms_output.put_line(pr_retxml.getStringVal());
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'pr_totais',
                         pr_tag_cont => pr_pos_conta,
                         pr_des_erro => pr_dscritic);

  --Numero RegIStros
  IF nvl(pr_pos_conta, 0) = 0 THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Dados não encontrados';
    RAISE vr_exc_saida;
  END IF;

EXCEPTION
  WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- ExISte para satISfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
    ROLLBACK;
  WHEN OTHERS THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                   SQLERRM;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- ExISte para satISfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
    ROLLBACK;

END pc_consultar_rating;


PROCEDURE pc_alterar_rating(pr_nrcpfcgc        IN INTEGER, --> CPF/CNPJ
                            pr_nrdconta        IN INTEGER, --> CONTA
                            pr_nrctro          IN INTEGER, --CONTRATO
                            pr_tpproduto       IN INTEGER,
                            pr_rating_sugerido IN VARCHAR2,
                            pr_justificativa   IN VARCHAR2,
                            pr_botao_chamada   IN INTEGER,
                            pr_xmllog          IN VARCHAR2,
                            pr_cdcritic        OUT PLS_INTEGER,--> código da crítica
                            pr_dscritic        OUT VARCHAR2, --> descrição da crítica
                            pr_retxml          IN OUT NOCOPY xmltype, --> arquivo de retorno do xml
                            pr_nmdcampo        OUT VARCHAR2, --> nome do campo com erro
                            pr_des_erro        OUT VARCHAR2) IS

  /* .............................................................................

      Programa: pc_alterar_rating
      SIStema : CECRED
      Sigla   : RATMOV
      Autor   : Daniele Rocha/AMcom
      Data    : Fevereiro/2019                 Ultima atualizacao: --

      Dados referentes ao programa: Recebe a chave para encontrar o contrato especifico e ajusta tabela (grava_rating_operacao)
                                    e envia (esteira/motor)
      Frequencia: Sempre que for chamado

      Objetivo  : apenas chamado via Mensageria!!
                 primeiro recebe os parametros para encontrar o contrato Cooperativa/conta/contrato/tipo do produto(será realizado de para tipo do contrato)
                 Seguida será separado a condição de buscar esteira e motor
                 para buscar esteira, só será permitido se o parametro da Parrat sugerir estiver SIM
                 se sim, será validado comos demais parametros da parrat se será possivel ou não sugerir
                     passando por esses filtros será enviado para esteira
                 mas se parametro estiver desligado,ou não for sugerido rating ou as condições para tal sugestão for negada
                 será enviado MOTOR
                 em segundo momento será registrado historico
                 não ocorrendo erro será commitado
      Observacao: -----

      Alteracoes:

  ..............................................................................*/
  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- VariaveIS retornadas da gene0004.pc_extrai_dados
  vr_cdcooper             INTEGER;
  vr_cdoperad             VARCHAR2(100);
  vr_nmdatela             VARCHAR2(100);
  vr_nmeacao              VARCHAR2(100);
  vr_cdagenci             VARCHAR2(100);
  vr_nrdcaixa             VARCHAR2(100);
  vr_idorigem             VARCHAR2(100);
  vr_retxml               XMLType;
  -- paramentro a mais retornado xml para servir como parametro da consulta
  vr_nrdconta             INTEGER;
  vr_nrcpfcgc             INTEGER;
  vr_sn_alterar_rat       VARCHAR2(1);
  vr_atualizou            BOOLEAN;
  vr_dsmensag             VARCHAR2(4000);
  vr_nota_rating_sugerido INTEGER;

  CURSOR cr_pessoa(vr_cdcooper IN crapass.cdcooper%TYPE
                  ,vr_nrdconta IN crapass.nrdconta%TYPE
                  ,vr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
    SELECT ass.inpessoa, ass.nrcpfcgc
      FROM crapass ass
     WHERE ass.nrdconta = vr_nrdconta
       AND ass.cdcooper = vr_cdcooper
       AND ass.nrcpfcgc = nvl(vr_nrcpfcgc, ass.nrcpfcgc);
  vr_tipo_pessoa     INTEGER;
  vr_buscou_nrcpfcgc INTEGER;

  CURSOR cr_emprestimosfinan(vr_cdcooper IN INTEGER
                            ,vr_nrdconta IN INTEGER
                            ,vr_nrctremp IN INTEGER) IS
    SELECT decode(insitest ,0,'NAO ENVIADA',1,'ENVIADA ANALISE AUTOMATICA', 2,'ENVIADA ANALISE MANUAL', 3,'ANALISE FINALIZADA', 4,'EXPIRADO') situacao
      FROM crawepr
     WHERE nrdconta = vr_nrdconta
       AND nrctremp = vr_nrctremp
       AND cdcooper = vr_cdcooper;

  CURSOR cr_limite_cred(vr_cdcooper IN INTEGER
                       ,vr_nrdconta IN INTEGER
                       ,vr_nrctremp IN INTEGER
                       ,vr_tipo     IN INTEGER) IS
    -- crawlim somente limite de credito
    SELECT DECODE (insitlim, 1, 'ESTUDO',   2 , 'ATIVO',        3 , 'CANCELADO', 4 , 'VIGENTE',
                             5 , 'APROVADO',6 , 'NAO APROVADO', 7 , 'REJEITADO', 8 , 'EXPIRADA DECURSO DE PRAZO',
                             9 , 'ANULADA') situacao
      FROM crawlim
     WHERE tpctrlim = vr_tipo
       AND nrdconta = vr_nrdconta
       AND nrctrlim = vr_nrctremp
       AND cdcooper = vr_cdcooper
    UNION ALL
    -- craplim para todos incluindo os descontos - propostas e efetivos)
     SELECT DECODE (insitlim, 1, 'ESTUDO',   2 , 'ATIVO',        3 , 'CANCELADO', 4 , 'VIGENTE',
                              5 , 'APROVADO',6 , 'NAO APROVADO', 7 , 'REJEITADO', 8 , 'EXPIRADA DECURSO DE PRAZO',
                              9 , 'ANULADA') situacao
      FROM craplim
     WHERE tpctrlim = vr_tipo
       AND nrdconta = vr_nrdconta
       AND nrctrlim = vr_nrctremp
       AND cdcooper = vr_cdcooper;


  vr_situacao             VARCHAR2(400);
  vr_orrating             INTEGER;
  vr_valor                crapepr.vlemprst%TYPE;
  vr_inrisco_rating       tbrisco_operacoes.inrisco_rating%TYPE;
  vr_inrisco_rating_autom tbrisco_operacoes.inrisco_rating_autom%TYPE;
  vr_dtrisco_rating       tbrisco_operacoes.dtrisco_rating%TYPE;
  vr_insituacao_rating    tbrisco_operacoes.insituacao_rating%TYPE;
  vr_inorigem_rating      tbrisco_operacoes.inorigem_rating%TYPE;
  vr_cdoperad_rating      tbrisco_operacoes.cdoperad_rating%TYPE;
  vr_dtrisco_rating_autom tbrisco_operacoes.dtrisco_rating_autom%TYPE;
  vr_emprestimosfinan     INTEGER DEFAULT(90);
  vr_lim_descontocheque   INTEGER DEFAULT(2);
  vr_lim_descontotitulo   INTEGER DEFAULT(3);
  vr_limite_credito       INTEGER DEFAULT(1);
  vr_erro                 VARCHAR2(4000);
  vr_msg                  VARCHAR2(4000);
  vr_msg2                 VARCHAR2(4000);
  vr_cdacesso             VARCHAR2(100);
  vr_desc_rating_autom    VARCHAR2(2);
  vr_calc_rating          BOOLEAN;
  vr_exc_sair             EXCEPTION;
  
  vr_strating             tbrisco_operacoes.insituacao_rating%TYPE; --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
  vr_flgrating            INTEGER;                                  --> Flag retorna se rating valido ou nao

  
  -- Busca do nr cpfcnpj base do associado
  CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
    SELECT  ass.nrcpfcnpj_base
       FROM crapass ass
    WHERE ass.cdcooper  = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass_ope   cr_crapass_ope%ROWTYPE;
  --------------->>> SUB-ROTINA <<<-----------------
  --> Gerar Log da tela
  PROCEDURE pc_log_ratmov(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdoperad IN crapope.cdoperad%TYPE
                         ,pr_dscdolog IN VARCHAR2) IS
    vr_dscdolog VARCHAR2(500);
    BEGIN
      -- Carrega o calendário de datas da cooperativa
      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      vr_dscdolog := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ' ' ||
                     to_char(SYSDATE, 'HH24:MI:SS') || ' --> ' || vr_cdacesso ||
                     ' --> ' || 'Operador ' || pr_cdoperad || ' ' ||
                     pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_dscdolog,
                                 pr_nmarqlog     => 'ratmov.log',
                                 pr_flfinmsg     => 'N');
    END;

  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
  
    /* Verifica se rating esta ativo e valido */
    rati0003.pc_busca_status_rating(pr_cdcooper =>  vr_cdcooper,
                                    pr_nrdconta =>  pr_nrdconta,
                                    pr_tpctrato =>  pr_tpproduto,
                                    pr_nrctrato =>  pr_nrctro,
                                    pr_strating =>  vr_strating,
                                    pr_flgrating => vr_flgrating,
                                    pr_cdcritic =>  vr_cdcritic,
                                    pr_dscritic =>  vr_dscritic);
                                    
    IF vr_strating <> 0 AND vr_flgrating <> 0 THEN
       vr_dscritic := 'Rating já calculado para essa proposta';
       RAISE vr_exc_saida;
    END IF;
    /* Verifica se rating esta ativo e valido */

    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- BUSCO A ORIGEM DO RATING SE É MOTOR OU ESTEIRA
    IF pr_rating_sugerido IS NULL THEN
       vr_orrating := 1;  -- MOTOR
    ELSE
       vr_orrating := 2;  -- ESTEIRA
    END IF;
    -- adicionado o retorno cpf o cpf
    OPEN cr_pessoa(vr_cdcooper => vr_cdcooper,
                   vr_nrdconta => pr_nrdconta,
                   vr_nrcpfcgc => pr_nrcpfcgc);

    FETCH cr_pessoa
      INTO vr_tipo_pessoa, vr_buscou_nrcpfcgc;
    CLOSE cr_pessoa;

    IF vr_tipo_pessoa IS NULL THEN
  /*    vr_dscritic := 'Não encontrado Pessoa para cpf/cnpj:  ' || pr_nrcpfcgc ||
                     ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                     vr_nrdconta;
  */
        vr_dscritic := 'Dados não encontrados';
      vr_cdcritic := 0;
      RAISE vr_exc_saida;
    END IF;


 /****************************************************************************************/
 /*****  A primeira validação a ser executada é o endividamento          *****************/
 /*****  Se não tiver endividamento superior ao parmetrizado, emite msg  *****************/
 /*****  Endividamento do cooperado, não atingiu o valor mínimo para a analise de Rating!*/
 /****************************************************************************************/
    IF pr_botao_chamada =  3  THEN  -- CHAMADA DA TELA RATMOV DEVE-SER FAZER A VALIDAÇÃO ENDIVIDAMENTO

      rati0003.pc_verifica_endivid_param( pr_cdcooper     => vr_cdcooper        --> Código da Cooperativa
                                         ,pr_nrdconta     => pr_nrdconta        --> Conta do associado
                                         ,pr_calc_rating  => vr_calc_rating     --> indicador de calcula rating (True False)
                                         ,pr_cdcritic     => vr_cdcritic
                                         ,pr_dscritic     => vr_dscritic);

      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_calc_rating = FALSE THEN -- Não calcular Rating, pois o valor é menor ou igual ao parametro TAB056.
        RAISE vr_exc_sair;  -- Neste caso, não é necessário acionar o Motor e nem chamar Contingencia. Então sai da rotina.
      END IF;
    END IF;

 /***************************************************************************************/
 /*****  A Segunda validação a ser executada somente chamar ibratan  ********************/
 /*****  se a situação da proposta estiver de acordo com a definição            *********/
 /*****  se ocorrer erro na geração motor o status do rating estará zerado!!!************/
 /***************************************************************************************/

    IF pr_tpproduto = 90 THEN
      OPEN cr_emprestimosfinan(vr_cdcooper => vr_cdcooper,
                               vr_nrdconta => pr_nrdconta,
                               vr_nrctremp => pr_nrctro);

      FETCH cr_emprestimosfinan
        INTO vr_situacao;
      CLOSE cr_emprestimosfinan;
      -- se for limite de credito, cheque ou titulo buscara do limite de crédito
    ELSIF pr_tpproduto IN (1, 2, 3) THEN
      OPEN cr_limite_cred(vr_cdcooper => vr_cdcooper,
                          vr_nrdconta => pr_nrdconta,
                          vr_nrctremp => pr_nrctro,
                          vr_tipo     => pr_tpproduto);
      FETCH cr_limite_cred
        INTO vr_situacao;
      CLOSE cr_limite_cred;

    END IF;

    IF pr_botao_chamada = 1  THEN --(BOTÃO  ANALISAR ATENDA (DESCONTO CHEQUE  )
      IF vr_situacao IN
       ('ENVIADA ANALISE AUTOMATICA', 'ENVIADA ANALISE MANUAL',  'ANALISE FINALIZADA', 'EXPIRADO',
        'ATIVO',    'CANCELADO', 'VIGENTE',  'EXPIRADA DECURSO DE PRAZO', 'ANULADA'     ) THEN

        vr_cdcritic := 0 ;
        vr_dscritic := 'Situação '||vr_situacao||' da proposta não permite analisar Rating! ';
       RAISE vr_exc_saida;
      END IF;
    ELSIF pr_botao_chamada = 2 THEN --(Botão Alterar Rating)
      IF vr_situacao IN
        ('ENVIADA ANALISE AUTOMATICA', 'ENVIADA ANALISE MANUAL',  'ANALISE FINALIZADA', 'EXPIRADO',
             'CANCELADO',   'ANULADA') THEN

         vr_cdcritic := 0 ;
         vr_dscritic := 'Situação '||vr_situacao||' da proposta não permite Altarar Rating! ';
         RAISE vr_exc_saida;
      END IF;
    END IF;

    -- fim da validação

    OPEN cr_crapass_ope(vr_cdcooper ,pr_nrdconta);
    FETCH cr_crapass_ope INTO rw_crapass_ope;
    CLOSE cr_crapass_ope;

    rati0003.pc_grava_rating_operacao( pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_tpctrato => pr_tpproduto
                                      ,pr_nrctrato => pr_nrctro
                                      ,pr_ntrating => NULL
                                      ,pr_ntrataut => NULL
                                      ,pr_dtrating => NULL
                                      ,pr_strating => 0-- AGUARDANDO ANALISE
                                      ,pr_orrating => NULL
                                      ,pr_cdoprrat => '1'
                                      ,pr_dtrataut => NULL
                                      ,pr_innivel_rating     => NULL
                                      ,pr_nrcpfcnpj_base     => rw_crapass_ope.nrcpfcnpj_base
                                      ,pr_inpontos_rating    => NULL
                                      ,pr_insegmento_rating  => NULL
                                      ,pr_inrisco_rat_inc    => NULL
                                      ,pr_innivel_rat_inc    => NULL
                                      ,pr_inpontos_rat_inc   => NULL
                                      ,pr_insegmento_rat_inc => NULL
                                      ,pr_cdoperad   => '1'           --> Operador que gerou historico de rating
                                      ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                      ,pr_valor      => NULL          --> Valor Contratado/Operaca
                                      ,pr_rating_sugerido   => NULL   --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                      ,pr_justificativa     => NULL   --> Justificativa do operador para alteracao do Rating
                                      ,pr_tpoperacao_rating => NULL   --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                      --Variáveis de crítica
                                      ,pr_cdcritic => vr_cdcritic     --> Critica encontrada no processo
                                      ,pr_dscritic => vr_dscritic);   --> Descritivo do erro

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN

      vr_cdcritic := 0;

      pc_log_ratmov(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => vr_dscritic || ' Erro ao Registar Operacoes ' ||
                     ' Cooperativa = ' || vr_cdcooper || ' Conta = ' ||
                     vr_nrdconta || ' Contrato = ' || pr_nrctro ||
                    ' Tipo contrato: = ' || CASE
                       WHEN pr_tpproduto = vr_emprestimosfinan THEN
                        'Emprest/Finac.'
                       WHEN pr_tpproduto = vr_lim_descontocheque THEN
                        'Desconto Cheque'
                       WHEN pr_tpproduto = vr_limite_credito THEN
                        'Limite Credito'
                       WHEN pr_tpproduto = vr_lim_descontotitulo THEN
                        'Desconto Título'
                       ELSE
                        'N/D'
                     END || ' ' || SQLERRM);
      RAISE vr_exc_saida;
    ELSE
      -- salva e grava o log
      COMMIT;

      pc_log_ratmov(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog =>   ' Foi zerado o status do Rating para  ' ||
                                   ' Cooperativa = ' || vr_cdcooper || ' Conta = ' ||
                                   vr_nrdconta || ' Contrato = ' || pr_nrctro ||
                                   ' Tipo contrato: = ' || CASE
                                     WHEN pr_tpproduto = vr_emprestimosfinan THEN
                                      'Emprest/Finac.'
                                     WHEN pr_tpproduto = vr_lim_descontocheque THEN
                                      'Desconto Cheque'
                                     WHEN pr_tpproduto = vr_limite_credito THEN
                                      'Limite Credito'
                                     WHEN pr_tpproduto = vr_lim_descontotitulo THEN
                                      'Desconto Título'
                                     ELSE
                                      'N/D'
                                   END || ' '  );
    END IF;

    -- consulta na PARRAT se a cooperativa está trabalhando com permissão habitita sugestão de Rating
    -- se usuário tiver sugerido
    IF TRIM(pr_rating_sugerido) IS NOT NULL AND ( tela_ratmov.fn_pode_alterar_rating( pr_cdcooper => vr_cdcooper,
                                                                                      pr_cdcritic => vr_cdcritic,
                                                                                      pr_dscritic => vr_dscritic)) THEN
      --apenas valida se pode resgistrar justificativa
      vr_sn_alterar_rat := tela_ratmov.fn_valida_rating_sugerido(pr_cdcooper           => vr_cdcooper,
                                                                 pr_msg                => vr_msg,
                                                                 pr_inpessoa           => vr_tipo_pessoa,
                                                                 pr_tpproduto          => pr_tpproduto,
                                                                 pr_rating_sugerido    => pr_rating_sugerido,
                                                                 pr_rating_modelo      => vr_desc_rating_autom,
                                                                 pr_data_rating_modelo => vr_dtrisco_rating_autom,
                                                                 pr_origem_validacao   => 'A');


      IF vr_msg IS NOT NULL THEN
        -- mensagem não quer dizer erro e sim onde caiu a condição para determinado contrato
        -- eu vou gravar no log para saber cada validação da sugestão o motivo de ser possivel ou nao sugerir tal ratig
        pc_log_ratmov(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad,
                      pr_dscdolog => vr_msg);

      END IF;
      -- variavel será usada novamente abaixo
      vr_msg := NULL;
    ELSE
      vr_sn_alterar_rat := 'N';
    END IF;

    --------------------------------------------------------------------------------------------------------------------
    -- Se for para alterar o Rating por sugestão (esteira) será chamado a rotina que gera esteira
    IF vr_sn_alterar_rat = 'S' THEN

      -->> chama esteira não está pronto, para testes chama motor ....
      rati0003.pc_solicitar_rating_motor( pr_cdcooper => vr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_tpctrato => pr_tpproduto,
                                          pr_nrctrato => pr_nrctro,
                                          pr_cdoperad => vr_cdoperad,
                                          pr_cdagenci => vr_cdagenci,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_inpessoa => vr_tipo_pessoa,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;

        pc_log_ratmov(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad,
                      pr_dscdolog => vr_dscritic || 'Erro ao Solicitar Rating Motor ' ||
                       ' Cooperativa = ' || vr_cdcooper || ' Conta = ' ||
                       vr_nrdconta || ' Contrato = ' || pr_nrctro ||
                       ' Tipo contrato: = ' || CASE
                         WHEN pr_tpproduto = vr_emprestimosfinan THEN
                          'Emprest/Finac.'
                         WHEN pr_tpproduto = vr_lim_descontocheque THEN
                          'Desconto Cheque'
                         WHEN pr_tpproduto = vr_limite_credito THEN
                          'Limite Credito'
                         WHEN pr_tpproduto = vr_lim_descontotitulo THEN
                          'Desconto Título'
                         ELSE
                          'N/D'
                       END || ' ' || SQLERRM);
        RAISE vr_exc_saida;
      END IF;
    ELSE
      --> Se não for por esteira será por Motor!!!
      -- a principio somente entrará no else
      -- aqui será chamado a rotina que envia para motor
      BEGIN
        rati0003.pc_solicitar_rating_motor(pr_cdcooper => vr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_tpctrato => pr_tpproduto, -- recebe-se codigo produto (tbrisco_operacoes) e converte para o contrat
                                           pr_nrctrato => pr_nrctro,
                                           pr_cdoperad => vr_cdoperad,
                                           pr_cdagenci => vr_cdagenci,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_inpessoa => vr_tipo_pessoa,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);

        -- OCORREU ERRO
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;

          pc_log_ratmov(pr_cdcooper => vr_cdcooper,
                        pr_cdoperad => vr_cdoperad,
                        pr_dscdolog =>  vr_dscritic || 'Erro ao solicitar Rating Motor ' ||
                         ' Cooperativa = ' || vr_cdcooper || ' Conta = ' ||
                        pr_nrdconta || ' Contrato = ' || pr_nrctro ||
                         ' Tipo contrato: = ' || CASE
                           WHEN pr_tpproduto = vr_emprestimosfinan THEN
                             'Emprest/Finac.'
                           WHEN pr_tpproduto = vr_lim_descontocheque THEN
                             'Desconto Cheque'
                           WHEN pr_tpproduto = vr_limite_credito THEN
                             'Limite Credito'
                           WHEN pr_tpproduto = vr_lim_descontotitulo THEN
                             'Desconto Título'
                           ELSE
                            'N/D'
                           END || ' ' || SQLERRM);
          RAISE vr_exc_saida;

        END IF;
      END;
    END IF;
    -- fim da chamada da Rotina gera esteira  OU Motor
    COMMIT;
  EXCEPTION
    WHEN vr_exc_sair THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Endividamento do cooperado, não atingiu o valor mínimo para a analise de Rating! ';
          pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- ExISte para satISfazer exigência da interface.
         pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- ExISte para satISfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- ExISte para satISfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
END pc_alterar_rating;




FUNCTION fn_valida_rating_sugerido     (  pr_cdcooper           IN  tbrat_param_geral.cdcooper%TYPE,
                                          pr_msg                OUT VARCHAR2,
                                          pr_inpessoa           IN  tbrat_param_geral.inpessoa%TYPE,
                                          pr_tpproduto          IN  tbrat_param_geral.tpproduto%TYPE,
                                          pr_rating_sugerido    IN  CHAR,
                                          pr_rating_modelo      IN  CHAR,
                                          pr_data_rating_modelo IN  DATE,
                                          pr_origem_validacao   IN  CHAR )/* na consulta / ou quando altera*/
 RETURN CHAR IS

 /* .............................................................................

        Programa: fc_valida_rating_sugerido
        SIStema : CECRED
        Sigla   : RATMOV
        Autor   : Daniele Rocha/AMcom
        Data    : Fevereiro/2019                 Ultima atualizacao: --

        Dados referentes ao programa: Será chamado pelo Consultar Rating/ou alterar rating para que seja manipulado
                                      se envia ou não para o motor/esteira
        Frequencia: Sempre que for chamado

        Objetivo  : Será chamado pelo Consultar Rating/ou alterar rating para que seja manipulado
                                      se envia ou não para o motor/esteira
        Observacao: -----

        Alteracoes:

    ..............................................................................*/

 ------------------------------------------------------------------------------------------

   CURSOR cr_tbrat_param_geral(vr_cdcooper  IN tbrISco_central_parametros.cdcooper%type,
                               vr_inpessoa  IN tbrat_param_geral.inpessoa%type,
                               vr_tpproduto IN tbrat_param_geral.tpproduto%type) IS
      SELECT idnivel_risco_permite_reducao,
             qtdias_niveis_reducao,
             qtmeses_expiracao_nota
        FROM cecred.tbrat_param_geral
       WHERE cdcooper  = vr_cdcooper
         AND inpessoa  = vr_inpessoa
         AND tpproduto = vr_tpproduto;
   ---
    vr_calc_rating_modelo                NUMBER ;
    vr_rating_modelo                     VARCHAR2(2) := pr_rating_modelo;
    vr_calc_rating_sugerido              NUMBER;
    vr_rating_sugerido                   VARCHAR2(2) := pr_rating_sugerido ;
    v_permite                            VARCHAR2(1)  DEFAULT('N');
    vr_idnivel_risco_permite_redu        tbrat_param_geral.idnivel_risco_permite_reducao%type;
    vr_qt_niveis_reducao                 tbrat_param_geral.qtdias_niveis_reducao%type;
    vr_qt_expiracao_nota                 tbrat_param_geral.qtmeses_expiracao_nota%type;
    vr_max_rating_pode_alt               NUMBER;
    msg_log                              VARCHAR2(4000);
BEGIN
------------------------------------------------------------------------------


 vr_calc_rating_modelo   := cecred.risc0004.fn_traduz_nivel_risco(pr_dsnivris => vr_rating_modelo);
 vr_calc_rating_sugerido := cecred.risc0004.fn_traduz_nivel_risco(pr_dsnivris => vr_rating_sugerido);



    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

  -- Buscar parâmetros
    OPEN CR_TBRAT_PARAM_GERAL(vr_cdcooper  => pr_cdcooper,
                              vr_inpessoa  => pr_inpessoa,
                              vr_tpproduto => Pr_tpproduto);

     FETCH cr_tbrat_param_geral
      INTO vr_idnivel_risco_permite_redu  ,  vr_qt_niveis_reducao,  vr_qt_expiracao_nota ;
     CLOSE cr_tbrat_param_geral;

    -- SE NÃO TIVER RATING MODELO VINDO DO MOTOR AUTOMATICO PERMITE ENVIO DO RATING
    IF  vr_rating_modelo IS NULL THEN
        v_permite := 'S' ;
    ELSIF vr_rating_modelo IS NOT NULL  AND
        vr_idnivel_risco_permite_redu  LIKE  '%'||vr_rating_modelo||'%' THEN
        v_permite := 'S' ;
    END  IF;

    IF  pr_origem_validacao = 'C' THEN
       RETURN(v_permite);
    END IF;

     IF  v_permite = 'S' THEN
      IF  vr_calc_rating_modelo IS NOT NULL THEN
        vr_max_rating_pode_alt := vr_calc_rating_modelo - NVL(vr_qt_niveis_reducao,0) ;
            IF  vr_max_rating_pode_alt <= vr_calc_rating_sugerido THEN
                v_permite := 'S';
            ELSE
              msg_log :=  ' Foi tentado enviar :'||vr_rating_sugerido||', Mas apenas poderá sugerir até ' ||NVL(vr_qt_niveis_reducao,0)||' Níveis.'||
                          ' Confome o parametrizado na PARRAT';
              v_permite := 'N';
            END IF;
       ELSE
            v_permite := 'S';
       END IF;
     END IF;
     IF msg_log IS NOT NULL THEN
        pr_msg       :=  'Gerado LOG na validação do Rating na tentativa de Alteração Rating'|| msg_log ;
     END IF;
 RETURN(v_permite);

 EXCEPTION
   WHEN OTHERS THEN
     RETURN('N');
 END;
 --------------------------------------------------------------------------------------------
 FUNCTION fn_pode_alterar_rating (pr_cdcooper  IN INTEGER,
                                  pr_cdcritic OUT pls_INTEGER, --> codigo da critica
                                  pr_dscritic OUT VARCHAR2 --> descricao da critica
                                  )RETURN BOOLEAN IS

   /* .............................................................................

        Programa: fn_pode_alterar_rating
        Sistema : CECRED
        Sigla   : PARRAT
        Autor   : Daniele Rocha/AMcom
        Data    : Março/2019                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  :Consultar o parametro que indica se possibilita sugestão
                  e devolve para ser usando em qualquer sistema

        Observacao:

        Alteracoes:

    ..............................................................................*/
    ----------->>> VARIAVEIS <<<--------
    -- Tratamento de erros
    vr_exc_saida          EXCEPTION;
    vr_inpermite_alterar  INTEGER;
    vr_cdcritic           crapcri.cdcritic%type; --> cód. erro
    vr_dscritic           VARCHAR2(1000); --> desc. erro
    ---------->> CURSORES <<--------
    CURSOR cr_tbrat_param_geral(pr_cdcooper  IN tbrisco_central_parametros.cdcooper%TYPE) IS
      -- campo inpermite_alterar ainda não criado
      SELECT     inpermite_alterar,
                 cdcooper
        FROM cecred.tbrat_param_geral C
       WHERE cdcooper  = pr_cdcooper;

    rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

  BEGIN

    -- Buscar parâmetros
    OPEN cr_tbrat_param_geral(pr_cdcooper  => pr_cdcooper);

    FETCH cr_tbrat_param_geral
     INTO rw_tbrat_param_geral;

    --Se nao encontrou parametro
    IF cr_tbrat_param_geral%NOTFOUND THEN
      CLOSE cr_tbrat_param_geral;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa '||pr_cdcooper||' não cadastrada no parâmetro Geral do Rating';
      RAISE vr_exc_saida;

    ELSE
      --Se encontrou, passa os valores para as variáveis criadas
      CLOSE cr_tbrat_param_geral;
            vr_inpermite_alterar      := rw_tbrat_param_geral.inpermite_alterar;
      -- se o valor do parâmetro estiver vazio, gere mensagem erro
      IF  vr_inpermite_alterar IS NULL THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Necessário cadastrar para Cooperativa '||pr_cdcooper||' o parâmetro do Rating';
      RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_inpermite_alterar = 1 THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      RETURN(FALSE);
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro encontrado na verificação do parâametro rating para a cooperativa: '||pr_cdcooper||' Erro: '|| sqlerrm;
      RETURN(FALSE);
  END fn_pode_alterar_rating;


 --------------------------------------------------------------------------------------------

PROCEDURE pc_apresenta_rating_motor(pr_nrdconta IN INTEGER, --> conta
                                    pr_nrctro   IN INTEGER, --contrato
                                    pr_tpctrato IN INTEGER,
                                    pr_xmllog   IN VARCHAR2, --> xml com informacoes de log
                                    pr_cdcritic OUT pls_INTEGER, --> codigo da critica
                                    pr_dscritic OUT VARCHAR2, --> descricao da critica
                                    pr_retxml   IN OUT NOCOPY XMLTYPE, --> arquivo de retorno do xml
                                    pr_nmdcampo OUT VARCHAR2, --> nome do campo com erro
                                    pr_des_erro OUT VARCHAR2) IS

  /* .............................................................................

   programa: pc_imp_historico_web
   sistema : seguros - cooperativa de credito
   autor   : daniele
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado

   objetivo  : rotina para apresentar apenas qual NOTa do raging automatico para o contrato/proposta!!

   alteracoes: 90     emprestimo/financiamento
                2     limite desconto cheque
                3     limite desconto título)
                1     contratos de limite de credito
  ..............................................................................*/

  CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER,
                      vr_tpctrato IN INTEGER,
                      vr_nrctremp IN INTEGER) IS
    SELECT inrisco_rating_autom, dtrisco_rating_autom
      FROM tbrisco_operacoes oper
     WHERE oper.tpctrato = vr_tpctrato
       AND oper.cdcooper = vr_cdcooper
       AND oper.nrdconta = vr_nrdconta
       AND oper.nrctremp = vr_nrctremp;

  ----------->>> variaveis <<<--------
  -- variável de críticas
  vr_cdcritic crapcri.cdcritic%type; --> cód. erro
  vr_dscritic VARCHAR2(1000); --> desc. erro

  -- tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_auxconta INTEGER := 0; -- contador auxiliar p/ posicao no xml
  -- variaveis do CURSOR
  vr_dtrisco_rating_autom tbrisco_operacoes.dtrisco_rating_autom%type;
  vr_inrisco_rating_autom tbrisco_operacoes.inrisco_rating_autom%type;

  -- variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper          INTEGER;
  vr_cdoperad          VARCHAR2(100);
  vr_nmdatela          VARCHAR2(100);
  vr_nmeacao           VARCHAR2(100);
  vr_cdagenci          VARCHAR2(100);
  vr_nrdcaixa          VARCHAR2(100);
  vr_idorigem          VARCHAR2(100);
  vr_desc_rating_autom VARCHAR2(2);
BEGIN
  pr_des_erro := 'OK';
  -- extrai dados do xml
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                           pr_cdcooper => vr_cdcooper,
                           pr_nmdatela => vr_nmdatela,
                           pr_nmeacao  => vr_nmeacao,
                           pr_cdagenci => vr_cdagenci,
                           pr_nrdcaixa => vr_nrdcaixa,
                           pr_idorigem => vr_idorigem,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic);

  -- se retornou alguma crítica
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- levanta exceção
    RAISE vr_exc_saida;
  END IF;

  -- busco informações de operações
  OPEN cr_operacoes(vr_cdcooper => vr_cdcooper,
                    vr_nrdconta => pr_nrdconta,
                    vr_tpctrato => pr_tpctrato,
                    vr_nrctremp => pr_nrctro);
  FETCH cr_operacoes
   INTO vr_inrisco_rating_autom, vr_dtrisco_rating_autom;
  CLOSE cr_operacoes;

  --se nao encontrou parametro
  IF vr_inrisco_rating_autom IS NULL THEN
     vr_dscritic := 'Não existe Rating para ' ||
                       ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                       pr_nrdconta||'  Contrato: '||pr_nrctro||'. Realize o Procedimento Analisar.';
        vr_cdcritic := 0;
        RAISE vr_exc_saida;

 ELSE
    BEGIN
      vr_desc_rating_autom := cecred.risc0004.fn_traduz_risco(vr_inrisco_rating_autom);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao traduzir o risco do rating automático!  ' ||
                       ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                       pr_nrdconta||'  Contrato: '||pr_tpctrato||' Nota Rating: '||vr_inrisco_rating_autom;
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END;
    IF vr_desc_rating_autom IS NULL THEN
        vr_dscritic := 'Erro ao traduzir o risco do rating automático!  ' ||
                       ' Cooperativa: ' || vr_cdcooper || ' Conta: ' ||
                       pr_nrdconta||'  Contrato: '||pr_tpctrato||' Nota Rating: '||vr_inrisco_rating_autom;
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END IF;

  END IF;

  -- passa os dados para o xml retorno
  -- criar cabeçalho do xml
  pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?><root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  -- insere as tags
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'dados',
                         pr_posicao  => 0,
                         pr_tag_nova => 'inf',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  -- campos
  -- 1 cooperativa
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_cdcooper',
                         pr_tag_cont => to_char(vr_cdcooper),
                         pr_des_erro => vr_dscritic);
  -- 2 conta
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrdconta',
                         pr_tag_cont => to_char(pr_nrdconta),
                         pr_des_erro => vr_dscritic);

  -- 3 contrato
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrctro',
                         pr_tag_cont => to_char(pr_nrctro),
                         pr_des_erro => vr_dscritic);

  -- 4 tipo contrato/produto
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_tpctrato',
                         pr_tag_cont => to_char(pr_tpctrato),
                         pr_des_erro => vr_dscritic);

  -- 5 tipo contrato/produto
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_inrisco_rating_autom',
                         pr_tag_cont => to_char(vr_desc_rating_autom),
                         pr_des_erro => vr_dscritic);

EXCEPTION
  WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'nok';
    -- carregar xml padrão para variável de retorno não utilizada.
    -- existe para satisfazer exigência da interface.
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                   '<root><erro>' || pr_dscritic ||
                                   '</erro></root>');
    ROLLBACK;
  WHEN OTHERS THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                   sqlerrm;
    pr_des_erro := 'nok';
    -- carregar xml padrão para variável de retorno não utilizada.
    -- existe para satisfazer exigência da interface.
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                   '<root><erro>' || pr_dscritic ||
                                   '</erro></root>');
    ROLLBACK;

END;

PROCEDURE pc_imp_historico_web(pr_nrcpfcgc IN INTEGER, --> CPF/CNPJ
                               pr_nrdconta IN INTEGER, --> CONTA
                               pr_nrctro   IN INTEGER, --CONTRATO
                               pr_status   IN INTEGER,
                               pr_datafim  IN VARCHAR2, -- DATA FIM PARA BUSCA
                               pr_dataini  IN VARCHAR2, -- DATA INICIO  PARA A BUSCA
                               pr_crapbdc  IN CHAR, -- Cadastro de borderos de descontos de cheques
                               pr_crapbdt  IN CHAR, -->Cadastro de borderos de descontos de titulos
                               pr_craplim  IN CHAR, -->Contratos de Limite de credito
                               pr_crawepr  IN CHAR, --> tabela empre
                               pr_crapcpa  IN CHAR, --> pre aprovado
                               pr_contrliq IN CHAR, --> se contrato é liquidado
                               pr_xmllog   IN VARCHAR2, --> XML com informacoes de LOG
                               pr_cdcritic OUT PLS_INTEGER, --> Codigo da critica
                               pr_dscritic OUT VARCHAR2, --> Descricao da critica
                               pr_retxml   IN OUT NOCOPY xmltype, --> Arquivo de retorno do XML
                               pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                               pr_des_erro OUT VARCHAR2) IS

  /* .............................................................................

   Programa: pc_imp_historico_web
   Sistema : Seguros - Cooperativa de Credito
   Autor   : Daniele
   Data    : Fevereiro/2019                 Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

   Alteracoes: 15/08/2019 - PJ450 - Criação do produto pre aprovado na consulta da RATMOV
                                    (Luiz Otávio Olinger Momm - AMCOM)

  ..............................................................................*/

  -- Cursor da data
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  -- Variavel de criticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

  -- Variaveis de log
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  -- Variaveis gerais
  vr_nmarqpdf VARCHAR2(1000);

BEGIN
  -- Extrai os dados vindos do XML
  GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
                           pr_cdcooper => vr_cdcooper,
                           pr_nmdatela => vr_nmdatela,
                           pr_nmeacao  => vr_nmeacao,
                           pr_cdagenci => vr_cdagenci,
                           pr_nrdcaixa => vr_nrdcaixa,
                           pr_idorigem => vr_idorigem,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic);

  -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao',
                             pr_action => vr_nmeacao);

  -- Busca a data do sistema
  OPEN BTCH0001.cr_crapdat(vr_cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;

  pc_imp_historico(pr_cdcooper => vr_cdcooper,
                   pr_nrcpfcgc => pr_nrcpfcgc,
                   pr_nrdconta => pr_nrdconta,
                   pr_nrctro   => pr_nrctro,
                   pr_status   => pr_status,
                   pr_datafim  => pr_datafim,
                   pr_dataini  => pr_dataini,
                   pr_crapbdc  => pr_crapbdc,
                   pr_crapbdt  => pr_crapbdt,
                   pr_craplim  => pr_craplim,
                   pr_crawepr  => pr_crawepr,
                   pr_contrliq => pr_contrliq,
                   pr_cdopecxa => vr_nrdcaixa,
                   pr_idorigem => vr_idorigem,
                   pr_cdprogra => 'ratmov',
                   pr_cdoperad => 1,
                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                   pr_flgerlog => 1,
                   pr_nmdatela => vr_nmdatela,
                   pr_nmarqpdf => vr_nmarqpdf,
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);

  -- Se retornou erro
  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  -- Criar cabecalho do XML
  pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

  GENE0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  GENE0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => 0,
                         pr_tag_nova => 'nmarqpdf',
                         pr_tag_cont => vr_nmarqpdf,
                         pr_des_erro => vr_dscritic);

EXCEPTION
  WHEN vr_exc_erro THEN
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

    -- Carregar XML padrao para variavel de retorno
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' || pr_dscritic ||'</Erro></Root>');
  WHEN OTHERS THEN
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pf_web: ' ||  SQLERRM;

    -- Carregar XML padrao para variavel de retorno
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END;

-------------------------------------------------------------------------------
PROCEDURE pc_imp_historico(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                           pr_nrcpfcgc IN INTEGER, --> CPF/CNPJ
                           pr_nrdconta IN INTEGER, --> CONTA
                           pr_nrctro   IN INTEGER, --CONTRATO
                           pr_status   IN INTEGER,
                           pr_datafim  IN VARCHAR2, -- DATA FIM PARA BUSCA
                           pr_dataini  IN VARCHAR2, -- DATA INICIO  PARA A BUSCA
                           pr_crapbdc  IN CHAR, -- Cadastro de borderos de descontos de cheques
                           pr_crapbdt  IN CHAR, -->Cadastro de borderos de descontos de titulos
                           pr_craplim  IN CHAR, -->Contratos de Limite de credito
                           pr_crawepr  IN CHAR, --> tabela empre
                           pr_contrliq IN CHAR, --> se contrato é liquidado
                           pr_cdopecxa IN crapope.cdoperad%TYPE,
                           pr_idorigem IN INTEGER, --> Identificador de Origem
                           pr_cdprogra IN crapprg.cdprogra%TYPE, --> Codigo do programa
                           pr_cdoperad IN crapope.cdoperad%TYPE, -- Código do operador
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE, --> Data de Movimento
                           pr_flgerlog IN INTEGER, --> Indicador se deve gerar log(0-nao, 1-sim)
                           pr_nmdatela IN craptel.nmdatela%TYPE,
                           --------> OUT <--------
                           pr_nmarqpdf OUT VARCHAR2, --> Retorna Nome do arquivo
                           pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                           pr_dscritic OUT VARCHAR2) IS
  --> Descrição da crítica

  /* .............................................................................

   Programa: pc_imp_historico
   Sistema : Seguros - Cooperativa de Credito
   Sigla   : SICRED
   Autor   : Daniele
   Data    : Fevereiro /2019.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia:
   Objetivo  :
   Alteracoes: 22/07/2019 - PJ450 - Criação dos cursores cr_busca_contratos_emp e cr_busca_contratos_lim
                                    para substituir um cursor genérico para melhoria de performance
                                    (Luiz Otávio Olinger Momm / AMCOM)

               23/07/2019 - PJ450 - Criação da tabela typ_tab_busca_contratos para gerenciamento das
                                    buscas dos cursores cr_busca_contratos_emp e cr_busca_contratos_lim
                                    (Luiz Otávio Olinger Momm / AMCOM)
  ..............................................................................*/
  ----------->>> Cursores <<<--------
  --> Buscar informações da proposta

  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  vr_des_reto VARCHAR2(100);
  vr_tab_erro GENE0001.typ_tab_erro;

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

  vr_dsorigem craplgm.dsorigem%TYPE;
  vr_dstransa craplgm.dstransa%TYPE;
  vr_nrdrowid ROWID;

  vr_idseqttl crapttl.idseqttl%TYPE;

  vr_dsdireto VARCHAR2(4000);
  vr_nmendter VARCHAR2(4000);
  vr_dscomand VARCHAR2(4000);
  vr_typsaida VARCHAR2(100);

  vr_dsmailcop VARCHAR2(4000);
  vr_dsassmail VARCHAR2(200);
  vr_dscormail VARCHAR2(50);

  vr_id_imprime_dsp VARCHAR2(1);

  -- Variáveis para armazenar as informações em XML
  vr_des_xml  CLOB;
  vr_txtcompl VARCHAR2(32600);
  l_offset    NUMBER := 0;

  vr_dsjasper VARCHAR2(100);

  vr_ratingmodelo        VARCHAR2(4);
  vr_ratingefetivado     VARCHAR2(4);
  vr_ratingnovo          VARCHAR2(4);
  vr_tipooperacao        VARCHAR2(250);
  vr_tipo_contrato       INTEGER;
  vr_inrisco_rating_novo tbrating_historicos.inrisco_rating_novo%type;
  vr_dtrisco_rating_novo tbrating_historicos.dtrisco_rating_novo%type;
  vr_ds_justificativa    tbrating_historicos.ds_justificativa%type;

  CURSOR cr_historico(p_cdcooper      IN tbrating_historicos.cdcooper%TYPE,
                      p_nrdconta      IN tbrating_historicos.nrdconta%type,
                      p_nrctremp      IN tbrating_historicos.nrctremp%type,
                      p_tipo_contrato IN INTEGER) IS
    SELECT  inrisco_rating_novo
           ,dtrisco_rating_novo
           ,ds_justificativa
      FROM tbrating_historicos
     WHERE cdcooper = p_cdcooper
       AND nrdconta = p_nrdconta
       AND nrctremp = p_nrctremp
       AND tpctrato = p_tipo_contrato
     ORDER BY nrseq_operacao DESC;

  CURSOR cr_dados(pcdcooper IN crapass.cdcooper%type,
                  pnrcpfcgc IN crapass.nrcpfcgc%type,
                  pnrdconta IN crapass.nrdconta%type) IS
    select nrcpfcgc, nmprimtl, inpessoa
      from crapass
     where nrdconta = nvl(pnrdconta, nrdconta)
       and nrcpfcgc = nvl(pnrcpfcgc, nrcpfcgc)
       and cdcooper = pcdcooper;

  vr_ds_pessoa   INTEGER;
  vr_ds_rcpfcgc  INTEGER;
  vr_ds_nmprimtl VARCHAR2(4000);
  vr_tab_busca_contratos typ_tab_busca_contratos;
  vr_index       INTEGER;
  --------------------------- SUBROTINAS INTERNAS --------------------------
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml,
                            vr_txtcompl,
                            pr_des_dados,
                            pr_fecha_xml);
  END;

  /* Função para mascarar o contrato retirado de GENE0002, só ajustado a variavel vr_des_mask_contrato tam 9 p 14 */
  FUNCTION fn_mask_contrato(pr_nrcontrato IN crapepr.nrctremp%TYPE)
    RETURN VARCHAR2 IS
  BEGIN
    gene0001.pc_set_modulo(pr_module => NULL,
                           pr_action => 'GENE0002.fn_mask_contrato');
    IF vr_des_mask_contrato IS NULL THEN
      vr_des_mask_contrato := nvl(gene0001.fn_param_sistema('CRED', 0, 'MASK_CONTRATO'), 'zz.zzz.zz9');
    END IF;
    gene0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    -- Utilizar mascara padrão de conta de Nro Contrato
    RETURN cecred.gene0002.fn_mask(pr_nrcontrato, vr_des_mask_contrato);
  END;

BEGIN
  --> Definir transação
  IF pr_flgerlog = 1 THEN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
  END IF;
  

  --Buscar diretorio da cooperativa
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper
                                       pr_cdcooper => pr_cdcooper);

  vr_nmendter := vr_dsdireto || '/rl/psdp001';

  vr_dscomand := 'rm ' || vr_nmendter || '* 2>/dev/null';

  --Executar o comando no unix
  gene0001.pc_OScommand(pr_typ_comando => 'S',
                        pr_des_comando => vr_dscomand,
                        pr_typ_saida   => vr_typsaida,
                        pr_des_saida   => vr_dscritic);
  --Se ocorreu erro dar RAISE
  IF vr_typsaida = 'ERR' THEN
    vr_dscritic := 'Nao foi possivel remover arquivos: ' || vr_dscomand ||
                   '. Erro: ' || vr_dscritic;
    RAISE vr_exc_erro;
  END IF;

  --> Montar nome do arquivo
  pr_nmarqpdf := 'psvp001' || gene0002.fn_busca_time || '.pdf';

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  vr_txtcompl := NULL;

  IF pr_nrdconta IS NOT NULL OR pr_nrcpfcgc IS NOT NULL THEN
    OPEN cr_dados(pcdcooper => pr_cdcooper,
                  pnrcpfcgc => pr_nrcpfcgc,
                  pnrdconta => pr_nrdconta);
    FETCH cr_dados
      INTO vr_ds_rcpfcgc, vr_ds_nmprimtl, vr_ds_pessoa;
    CLOSE cr_dados;
  ELSE
    vr_dscritic := 'Erro ao buscar dados cooperado cpf/cnpj:  ' ||
                   pr_nrcpfcgc || ' Cooperativa: ' || pr_cdcooper ||
                   ' Conta: ' || pr_nrdconta;
    vr_cdcritic := 0;
    RAISE vr_exc_erro; -- encerra programa
  END IF;

  /* Cria tabela temporário com empréstimos */
  vr_index := 0;
  IF (pr_crawepr = 'S') THEN
    FOR rw_busca IN cr_busca_contratos_emp(vr_cdcooper => pr_cdcooper,
                                           vr_nrcpfcgc => pr_nrcpfcgc,
                                           vr_nrdconta => pr_nrdconta,
                                           vr_nrctro   => pr_nrctro,
                                           vr_status   => pr_status,
                                           vr_dataini  => to_date(pr_dataini, 'DD/MM/YYYY'),
                                           vr_datafim  => to_date(pr_datafim, 'DD/MM/YYYY'),
                                           vr_contrliq => pr_contrliq -- contrato liquidado
                                           ) LOOP
      vr_tab_busca_contratos(vr_index) := rw_busca;
      vr_index := vr_index + 1;
    END LOOP;
  END IF;


  /* Cria tabela temporário com limites de crédito, desconto de título e desconto de título */
  FOR i IN 1 .. 3 LOOP

    -- Limite de credito
    IF i = 1 AND pr_craplim = 'N' THEN
      CONTINUE;
    END IF;
    
    -- Limite desconto cheque
    IF i = 2 AND pr_crapbdc = 'N' THEN
      CONTINUE;
    END IF;
    
    -- Limite Desconto Título
    IF i = 3 AND pr_crapbdt = 'N' THEN
      CONTINUE;
    END IF;

    FOR rw_busca IN cr_busca_contratos_lim(vr_cdcooper  => pr_cdcooper,
                                           vr_nrcpfcgc  => pr_nrcpfcgc,
                                           vr_nrdconta  => pr_nrdconta,
                                           vr_nrctro    => pr_nrctro,
                                           vr_status    => pr_status,
                                           vr_tpproduto => i,
                                           vr_dataini  => to_date(pr_dataini, 'DD/MM/YYYY'),
                                           vr_datafim  => to_date(pr_datafim, 'DD/MM/YYYY'),
                                           vr_contrliq  => pr_contrliq
                                           ) LOOP
      vr_tab_busca_contratos(vr_index) := rw_busca;
      vr_index := vr_index + 1;
    END LOOP;
    
    -- Pesquisa propostas majorada apenas
    IF i = 3 AND pr_crapbdt = 'S' THEN
      FOR rw_busca IN cr_busca_contratos_lim_maj(vr_cdcooper  => pr_cdcooper,
                                                 vr_nrcpfcgc  => pr_nrcpfcgc,
                                                 vr_nrdconta  => pr_nrdconta,
                                                 vr_nrctro    => pr_nrctro,
                                                 vr_status    => pr_status,
                                                 vr_tpproduto => 3,
                                                 vr_dataini  => to_date(pr_dataini, 'DD/MM/YYYY'),
                                                 vr_datafim  => to_date(pr_datafim, 'DD/MM/YYYY'),
                                                 vr_contrliq  => pr_contrliq
                                                ) LOOP
        vr_tab_busca_contratos(vr_index) := rw_busca;
        vr_index := vr_index + 1;
      END LOOP;
    END IF;
  END LOOP;

  /* Caso não encontrado nenhum registro na consulta */  
  IF (vr_index = 0) THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Dados não encontrados';
    RAISE vr_exc_erro;
  END IF;
  
  
  --> INICIO
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><dadosRelatorio>   <dps>' || vr_id_imprime_dsp || '</dps>');
  pc_escreve_xml('<dados> <cpfcnpj>' || cecred.gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_ds_rcpfcgc, pr_inpessoa => vr_ds_pessoa) || '</cpfcnpj>');
  pc_escreve_xml('<nome>' || vr_ds_nmprimtl || '</nome>');
  pc_escreve_xml('<nrdconta>' || pr_nrdconta || '</nrdconta></dados>');
  pc_escreve_xml('<contratos>'); -- Nome da cooperativa

  FOR i IN vr_tab_busca_contratos.FIRST .. vr_tab_busca_contratos.LAST LOOP

    IF vr_tab_busca_contratos(i).origem_consulta = 90 THEN
      vr_tipooperacao  := 'EMPRESTIMO/FINANCIAMENTO';
      vr_tipo_contrato := '90';
    ELSIF vr_tab_busca_contratos(i).origem_consulta = 2 THEN
      vr_tipooperacao  := 'LIMITE DESCONTO CHEQUE ';
      vr_tipo_contrato := 2;
    ELSIF vr_tab_busca_contratos(i).origem_consulta = 3 THEN
      vr_tipooperacao  := 'LIMITE DESCONTO TITULO ';
      vr_tipo_contrato := 3;
      IF vr_tab_busca_contratos(i).majorado = 1 THEN
        vr_tipooperacao := vr_tipooperacao || '(*)';
      END IF;
    ELSIF vr_tab_busca_contratos(i).origem_consulta = 1 THEN
      vr_tipooperacao  := 'LIMITE CREDITO ';
      vr_tipo_contrato := 1;
    END IF;
    -- único lugar que poderei ver o rating novo(sugerido) é na tabela de historicos
    vr_inrisco_rating_novo := NULL;
    vr_dtrisco_rating_novo := NULL;
    OPEN cr_historico(p_cdcooper      => pr_cdcooper,
                      p_nrdconta      => vr_tab_busca_contratos(i).nrdconta,
                      p_nrctremp      => vr_tab_busca_contratos(i).contrato,
                      p_tipo_contrato => vr_tipo_contrato);
    FETCH cr_historico
      INTO vr_inrisco_rating_novo,
           vr_dtrisco_rating_novo,
           vr_ds_justificativa;
    CLOSE cr_historico;

    BEGIN
      vr_ratingmodelo    := cecred.risc0004.fn_traduz_risco(vr_tab_busca_contratos(i).rating_modelo);
      vr_ratingefetivado := cecred.risc0004.fn_traduz_risco(vr_tab_busca_contratos(i).rating_atual);
      vr_ratingnovo      := cecred.risc0004.fn_traduz_risco(vr_inrisco_rating_novo);

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao traduzir o risco do Rating Automatico!  para cpf/cnpj:  ' ||
                       pr_nrcpfcgc || ' Cooperativa: ' || pr_cdcooper ||
                       ' Conta: ' || vr_tab_busca_contratos(i).nrdconta;
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
    END;

    pc_escreve_xml('<contrato> <nmextcop>' ||pr_cdcooper                                           ||'</nmextcop>'      );
    pc_escreve_xml('<conta>'               ||cecred.gene0002.fn_mask_conta(vr_tab_busca_contratos(i).nrdconta  )   ||'</conta>'         );
    pc_escreve_xml('<dataoper>'            ||to_char(vr_tab_busca_contratos(i).rat_atu_data,'DD/MM/RRRR')          ||'</dataoper>'      );
    pc_escreve_xml('<tipooperacao>'        ||vr_tipooperacao                                      ||'</tipooperacao>'  );
    pc_escreve_xml('<contrato>'            ||fn_mask_contrato(vr_tab_busca_contratos(i).contrato)                  ||'</contrato>'      );
    pc_escreve_xml('<ratingmodelo>'        ||vr_ratingmodelo                                      ||'</ratingmodelo>'  );
    pc_escreve_xml('<dataratingmodelo>'    ||to_char(vr_tab_busca_contratos(i).rat_mod_data,'DD/MM/RRRR')          ||'</dataratingmodelo>');
    pc_escreve_xml('<ratingefetivado>'     ||vr_ratingefetivado                                   || '</ratingefetivado>' );
    pc_escreve_xml('<dataratingefetivado>' || to_char(vr_tab_busca_contratos(i).data_efet,'DD/MM/RRRR')            ||'</dataratingefetivado>'   );
    pc_escreve_xml('<ratingnovo>'          || '' /**vr_ratingnovo*/                                       ||'</ratingnovo>'     );
    pc_escreve_xml('<dataratingnovo>'      || '' /*to_char(vr_dtrisco_rating_novo,'DD/MM/RRRR')*/        ||'</dataratingnovo>' );
    pc_escreve_xml('<valor>'               || TO_CHAR(vr_tab_busca_contratos(i).valor, '999G999G990D00')           ||'</valor>'          );
    pc_escreve_xml('<datavencimento>'      ||to_char(vr_tab_busca_contratos(i).dt_vencimento,'DD/MM/RRRR')                  ||'</datavencimento>' );
    pc_escreve_xml('<operador>'            ||pr_cdoperad                                          ||'</operador>'       );
    pc_escreve_xml('<justificativa>'       ||vr_ds_justificativa                                  ||'</justificativa>'||'</contrato>');

    --> Descarregar buffer
    pc_escreve_xml(' ', TRUE);
  END LOOP;
  --> Descarregar buffer
  pc_escreve_xml(' ', TRUE);
  pc_escreve_xml('</contratos>' || '</dadosRelatorio>', TRUE);

  loop
    exit when l_offset > dbms_lob.getlength(vr_des_xml);
    DBMS_OUTPUT.PUT_LINE(dbms_lob.substr(vr_des_xml, 254, l_offset) || '~');
    l_offset := l_offset + 255;
  end loop;

  vr_dsjasper := 'crrl781.jasper';

  --> Solicita geracao do PDF
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                              pr_cdprogra  => pr_cdprogra,
                              pr_dtmvtolt  => pr_dtmvtolt,
                              pr_dsxml     => vr_des_xml,
                              pr_dsxmlnode => '/dadosRelatorio',
                              pr_dsjasper  => vr_dsjasper,
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_dsdireto || '/rl/' || pr_nmarqpdf,
                              pr_flg_gerar => 'S',
                              pr_qtcoluna  => 234,
                              pr_cdrelato  => 781,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'N',
                              pr_nmformul  => ' ',
                              pr_nrcopias  => 1,
                              pr_nrvergrl  => 1,
                              pr_dsextmail => NULL,
                              pr_dsmailcop => vr_dsmailcop,
                              pr_dsassmail => vr_dsassmail,
                              pr_dscormail => vr_dscormail,
                              pr_des_erro  => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    -- verifica retorno se houve erro
    RAISE vr_exc_erro; -- encerra programa
  END IF;

  -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
  gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper,
                               pr_cdagenci => NULL,
                               pr_nrdcaixa => NULL,
                               pr_nmarqpdf => vr_dsdireto || '/rl/' || pr_nmarqpdf,
                               pr_des_reto => vr_des_reto,
                               pr_tab_erro => vr_tab_erro);
  -- Se retornou erro
  IF NVL(vr_des_reto, 'OK') <> 'OK' THEN
    IF vr_tab_erro.COUNT > 0 THEN
      -- verifica pl-table se existe erros
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
      RAISE vr_exc_erro; -- encerra programa
    END IF;
  END IF;

  -- Remover relatorio do diretorio padrao da cooperativa
  gene0001.pc_OScommand(pr_typ_comando => 'S',
                        pr_des_comando => 'rm ' || vr_dsdireto || '/rl/' ||
                                          pr_nmarqpdf,
                        pr_typ_saida   => vr_typsaida,
                        pr_des_saida   => vr_dscritic);
  -- Se retornou erro
  IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
    -- Concatena o erro que veio
    vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
    RAISE vr_exc_erro; -- encerra programa
  END IF;
  --END IF;

  --> Gerar log de sucesso
  IF pr_flgerlog = 1 THEN
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => pr_cdopecxa,
                         pr_dscritic => NULL,
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => trunc(SYSDATE),
                         pr_flgtrans => 1, -- True
                         pr_hrtransa => gene0002.fn_busca_time,
                         pr_idseqttl => vr_idseqttl,
                         pr_nmdatela => pr_nmdatela,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'nrctrseg',
                              pr_dsdadant => NULL,
                              pr_dsdadatu => pr_nrctro);
  END IF;

  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE(vr_dscritic, chr(13)), chr(10));
    END IF;

    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa,
                           pr_dscritic => pr_dscritic,
                           pr_dsorigem => vr_dsorigem,
                           pr_dstransa => vr_dstransa,
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans => 0, --FALSE
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => vr_idseqttl,
                           pr_nmdatela => pr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrctrseg',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_nrctro);
    END IF;

  WHEN OTHERS THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := replace(replace('Erro ao gerar impressao da proposta de seguro de vida prestamista: ' ||
                                   SQLERRM,
                                   chr(13)),
                           chr(10));

    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa,
                           pr_dscritic => pr_dscritic,
                           pr_dsorigem => vr_dsorigem,
                           pr_dstransa => vr_dstransa,
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans => 0, --FALSE
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => vr_idseqttl,
                           pr_nmdatela => pr_nmdatela,
                           pr_nrdconta => pr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrctrseg',
                                pr_dsdadant => NULL,
                                pr_dsdadatu => pr_nrctro);
    END IF;

END pc_imp_historico;

END TELA_RATMOV;
/
