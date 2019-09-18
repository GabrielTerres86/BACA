CREATE OR REPLACE PACKAGE CECRED."RATI0003" IS

   ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0003                     Antiga:
  --  Sistema  : Rotinas para Rating dos Produtos
  --  Sigla    : RATI
  --  Autor    : Anderson Luiz Heckmann - AMcom
  --  Data     : Fevereiro/2019.                   Ultima atualizacao: 26/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Produtos.
  --
  -- Alteracao:
  --            prj450 - Criação da procedure Busca Status do Rating (Fabio Adriano - AMcom).
  --            25/03/2019         P450 - Rating, verificar parametros contingencia PAREST e PARRAT, se ligado, gravar
  --                               rating contingencia (pc_verifica_continge_rating e pc_grava_rat_contingencia).
  --                               Também verificado o endividamento, para calcular o rating ou não para o
  --                               cooperado (pc_verifica_endivid_param).  (Elton AMcom).
  --
  --            28/03/2019         P450 - Rating - inclusão da procedute pc_atualiza_rating.
  --                               procedure chamada pelo JOB JBATUALIZARATING.  (Mário AMcom)
  --
  --            09/04/2019         P450 - Rating, criada procedure pc_ret_risco_tbrisco, que retorna risco Rating, por situação  (Elton AMcom).
  --
  --            30/04/2019         P450 - Alterado o cursor cr_operacoes da pc_busca_dados_rating_inclusao
  --                               para buscar as informações do Rating e não da Inclusão (Luiz Otávio Olinger Momm - AMCOM)
  --
  --            06/05/2019         P450 - Ajuste na procedure pc_grava_rat_contingencia - Rotina grava o rating contigencia
  --                               Ao chamar pc_grava_rating_operacao efetuado correção de parametro de Data do Movimento
  --                               (Mário - AMcom)
  --
  --            19/08/2019         P450 - Adicionado rotina para respeitar parametro PARRAT
  --                               (Weverton Paulo Otoni (Amcom))
  --
  --            22/08/2019         P450 - nova rotina pc_busca_risco_rat_preapr
  --                               (Elton (Amcom))
  --
  ---------------------------------------------------------------------------------------------------------------

---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Definicao do tipo da tabela para linhas de credito
    TYPE typ_reg_risco_op IS
     RECORD(cdlcremp         craplcr.cdlcremp%TYPE,
            dslcremp         craplcr.dslcremp%TYPE,
            flgstlcr         craplcr.flgstlcr%TYPE,
            nrgrplcr         craplcr.nrgrplcr%TYPE,
            txmensal         craplcr.txmensal%TYPE,
            txdiaria         craplcr.txdiaria%TYPE,
            txjurfix         craplcr.txjurfix%TYPE,
            rowid_aux        rowid);

    TYPE typ_tab_risco_op IS
      TABLE OF typ_reg_risco_op
        INDEX BY PLS_INTEGER; -- Codigo da conta
    -- Vetor para armazenar os dados de Linha de Credito
    vr_tab_risco_op typ_tab_risco_op;

 /* Gravar o Rating da operação que retornou do Ibratan. */
  PROCEDURE pc_grava_rating_operacao(pr_cdcooper  IN crapcop.cdcooper%TYPE                                      --> Código da Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE                                      --> Conta do associado
                                    ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0                                      --> Tipo do contrato de rating
                                    ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0                                      --> Número do contrato do rating
                                    ,pr_ntrating  IN tbrisco_operacoes.inrisco_rating%TYPE DEFAULT NULL         --> Nivel de Risco Rating EFETIVO
                                    ,pr_ntrataut  IN tbrisco_operacoes.inrisco_rating_autom%TYPE DEFAULT NULL   --> Nivel de Risco Rating retornado do MOTOR
                                    ,pr_dtrating  IN tbrisco_operacoes.dtrisco_rating%TYPE DEFAULT NULL         --> Data de Efetivacao do Rating
                                    ,pr_strating  IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL      --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                    ,pr_orrating  IN tbrisco_operacoes.inorigem_rating%TYPE DEFAULT NULL        --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                    ,pr_cdoprrat  IN tbrisco_operacoes.cdoperad_rating%TYPE DEFAULT NULL        --> Codigo Operador que Efetivou o Rating
                                    ,pr_dtrataut  IN tbrisco_operacoes.dtrisco_rating_autom%TYPE DEFAULT NULL   --> Data do Rating retornado do MOTOR
                                    ,pr_innivel_rating IN tbrisco_operacoes.innivel_rating%TYPE DEFAULT NULL    --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                    ,pr_nrcpfcnpj_base IN tbrisco_operacoes.nrcpfcnpj_base%TYPE DEFAULT 0       --> Numero do CPF/CNPJ Base do associado
                                    ,pr_inpontos_rating IN tbrisco_operacoes.inpontos_rating%TYPE DEFAULT NULL  --> Pontuacao do Rating retornada do Motor
                                    ,pr_insegmento_rating IN tbrisco_operacoes.insegmento_rating%TYPE DEFAULT NULL  --> Informacao de qual Garantia foi utilizada para calculo Rating do Motor
                                    ,pr_inrisco_rat_inc IN tbrisco_operacoes.inrisco_rat_inc%TYPE DEFAULT NULL  --> Nivel de Rating da Inclusao da Proposta
                                    ,pr_innivel_rat_inc IN tbrisco_operacoes.innivel_rat_inc%TYPE DEFAULT NULL  --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                    ,pr_inpontos_rat_inc IN tbrisco_operacoes.inpontos_rat_inc%TYPE DEFAULT NULL  --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                    ,pr_insegmento_rat_inc IN tbrisco_operacoes.insegmento_rat_inc%TYPE DEFAULT NULL  --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                    ,pr_efetivacao_rating IN PLS_INTEGER DEFAULT 0                               --> Indica se é apenas Efetivação do Rating
                                    --Variáveis para gravar o histórico
                                    ,pr_cdoperad IN tbrisco_operacoes.cdoperad_rating%TYPE DEFAULT NULL         --> Operador que gerou historico de rating
                                    ,pr_dtmvtolt IN tbrating_historicos.dthr_operacao%TYPE DEFAULT NULL         --> Data/Hora do historico de rating
                                    ,pr_valor IN crapepr.vlemprst%TYPE DEFAULT NULL                             --> Valor Contratado/Operaca
                                    ,pr_rating_sugerido IN tbrating_historicos.inrisco_rating_novo%TYPE DEFAULT NULL --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                    ,pr_justificativa IN tbrating_historicos.ds_justificativa%TYPE DEFAULT NULL --> Justificativa do operador para alteracao do Rating
                                    ,pr_tpoperacao_rating IN tbrating_historicos.tpoperacao_rating%TYPE DEFAULT NULL --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                    --Variáveis de crítica
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                                      --> Critica encontrada no processo
                                    ,pr_dscritic OUT VARCHAR2);                                                 --> Descritivo do erro

  FUNCTION fn_registra_historico
                                        (pr_cdcooper             IN  tbrisco_operacoes.cdcooper%TYPE,
                                         pr_cdoperad             IN  tbrisco_operacoes.cdoperad_rating%TYPE,
                                         pr_nrdconta             IN  tbrisco_operacoes.nrdconta%TYPE,  --> CONTA
                                         pr_nrctro               IN  tbrisco_operacoes.nrctremp%TYPE,  --CONTRATO
                                         pr_dtmvtolt             IN  tbrating_historicos.dthr_operacao%TYPE,
                                         pr_valor                IN  crapepr.vlemprst%type,
                                         pr_tpctrato             IN  tbrisco_operacoes.tpctrato%TYPE,
                                         pr_rating_sugerido      IN  INTEGER,
                                         pr_justificativa        IN  VARCHAR2,
                                         pr_inrisco_rating       IN  tbrisco_operacoes.inrisco_rating%TYPE,
                                         pr_inrisco_rating_autom IN  tbrisco_operacoes.inrisco_rating_autom%TYPE,
                                         pr_dtrisco_rating_autom IN  tbrisco_operacoes.dtrisco_rating_autom%TYPE,
                                         pr_dtrisco_rating       IN  tbrisco_operacoes.dtrisco_rating%TYPE,
                                         pr_insituacao_rating    IN  tbrisco_operacoes.insituacao_rating%TYPE,
                                         pr_inorigem_rating      IN  tbrisco_operacoes.inorigem_rating%TYPE,
                                         pr_cdoperad_rating      IN  tbrisco_operacoes.cdoperad_rating%TYPE,
                                         pr_tpoperacao_rating    IN  tbrating_historicos.tpoperacao_rating%TYPE,
                                         pr_retxml               IN OUT NOCOPY XMLType,
                                         pr_cdcritic             OUT INTEGER,
                                         pr_dscritic             OUT VARCHAR2) RETURN BOOLEAN ;

  /* Retorna modelo Rating parametrizado por cooperativa */
  FUNCTION fn_retorna_modelo_rating (pr_cdcooper         IN tbrat_param_geral.cdcooper%TYPE)RETURN INTEGER;

  FUNCTION fn_valida_limite_chq_tit(pr_cdcooper IN tbrat_param_geral.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE)
    RETURN INTEGER;

  /* Busca Status do Rating */
  PROCEDURE pc_busca_status_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                  ,pr_nrdconta  IN NUMBER                                   --> Conta ou CPFCNPJ base do associado
                                  ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE          --> Tipo do contrato
                                  ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE          --> Número do contrato
                                  ,pr_strating OUT tbrisco_operacoes.insituacao_rating%TYPE --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                  ,pr_flgrating OUT INTEGER                                 --> Flag retorna se rating valido ou nao
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                  ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_busca_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                  ,pr_nrdconta     IN crapass.nrdconta%TYPE    --> Conta do associado
                                  ,pr_vlendivi     OUT crapass.vllimcre%TYPE   --> Retorno - Valor Endividamento
                                  ,pr_vlrating     OUT crapass.vllimcre%TYPE   --> Retorno - Valor Parametro de Rating
                                  ,pr_dscritic     OUT VARCHAR2);

  PROCEDURE pc_busca_rat_contigencia( pr_cdcooper IN INTEGER,
                                    pr_nrcpfcgc IN INTEGER,-- CNPJ BASE
                                    pr_innivris OUT INTEGER,
                                    pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                    pr_dscritic OUT VARCHAR2);

  FUNCTION fn_busca_rating_efetivado     ( pr_cdcooper IN INTEGER,
                                           pr_nrdconta IN INTEGER, --> conta
                                           pr_nrctro   IN INTEGER, --contrato
                                           pr_tpctrato IN INTEGER,
                                           pr_cdcritic OUT pls_INTEGER, --> codigo da critica
                                           pr_dscritic OUT VARCHAR2 ) RETURN NUMBER  ;


  PROCEDURE  pc_grava_rating_bordero( pr_cdcooper IN INTEGER,     --> Cooperativa
                                      pr_nrdconta IN INTEGER,     --> Conta
                                      pr_nrctro   IN INTEGER,     --> Contrato
                                      pr_tpctrato IN INTEGER,     --> 2 /*CRAPBDC*/,3 /*CRAPBDT*/)
                                      pr_nrborder IN INTEGER,     --> Número do bordero
                                      pr_cdoperad IN VARCHAR2,     --> operador
                                      pr_cdcritic OUT PLS_INTEGER,--> codigo da critica
                                      pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_mostra_rating_bordero(pr_nrdconta IN INTEGER, --> Conta
                                     pr_cheq_tit IN CHAR, --> C /*CRAPBDC*/,T /*CRAPBDT*/)
                                     pr_nrborder IN INTEGER, --> Número do bordero
                                     pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                     pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2) ;

  PROCEDURE pc_consultar_risco_rating ( pr_nrdconta IN INTEGER, --> CONTA
                                        pr_nrctro   IN INTEGER, --CONTRATO
                                        pr_tpctro   IN INTEGER,
                                        pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                        pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                        pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                        pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2) ;


PROCEDURE pc_busca_dados_rating_inclusao(pr_cdcooper            IN INTEGER, -- COOPERATIVA CAMPO OBRIGATÓRIO
                                         pr_nrdconta            IN INTEGER, -- CONTA       CAMPO OBRIGATÓRIO
                                         pr_nrctro              IN INTEGER, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
                                         pr_tpctrato            IN INTEGER, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                         pr_des_inrisco_rat_inc OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° RATING   DO CONTRATO DA CONTA
                                         pr_inpontos_rat_inc    OUT INTEGER, -- SERÁ DEVOLVIDO 1° PONTOS   DO CONTRATO DA CONTA
                                         pr_innivel_rat_inc     OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° NIVEL    DO CONTRATO DA CONTA
                                         pr_insegmento_rat_inc  OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° SEGMENTO DO CONTRATO DA CONTA
                                         pr_vlr                 OUT crapepr.vlemprst%type,
                                         pr_qtdreg              OUT INTEGER,
                                         pr_nrctro_out          OUT INTEGER, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
                                         pr_tpctrato_out        OUT INTEGER, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                         pr_retxml_clob         OUT CLOB, -- XML COM TODOS OS CONTRATOS/TIPOS DA CONTA
                                         pr_cdcritic            OUT PLS_INTEGER, --> codigo da critica
                                         pr_dscritic            OUT VARCHAR2) ;

  PROCEDURE pc_consulta_contratos_ativos(pr_cdcooper  IN crapass.cdcooper%TYPE
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                        ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2);
-- Calendário da cooperativa selecionada
 rw_crapdat                           btch0001.cr_crapdat%ROWTYPE;

  --> Rotina para retornar quantidade de dias em atraso
  FUNCTION fn_obter_qtd_atr_Ext (pr_vl_prejuizo_ult48m IN NUMBER  --> Valor prejuizo 48 m
                                ,pr_vl_venc_180d       IN NUMBER  --> Valor vencimento 180 d
                                ,pr_vl_venc_120d       IN NUMBER  --> Valor vencimento 120 d
                                ,pr_vl_venc_90d        IN NUMBER  --> Valor vencimento 90 d
                                ,pr_vl_venc_60d        IN NUMBER  --> Valor vencimento 60 d
                                ,pr_vl_venc_30d        IN NUMBER  --> Valor vencimento 30 d
                                ,pr_vl_venc_15d        IN NUMBER) --> Valor vencimento 15 d
                                RETURN NUMBER;

  --> Rotina para retornar o percentual do limite de crédito utilizado
  FUNCTION fn_obter_Pc_Utiliz_limite (pr_vl_limite            IN NUMBER  --> Valor do limite utilizado
                                     ,pr_vl_limite_disponivel IN NUMBER) --> Valor do limite disponível
                                      RETURN NUMBER;

  --> Rotina para retornar o percentual do limite de crédito rotativo utilizado
  FUNCTION fn_obter_Pc_Utiliz_lim_Rot (pr_vl_limite          IN NUMBER  --> Valor do limite utilizado
                                      ,pr_vl_saldo_devedor   IN NUMBER) --> Valor do saldo devedor
                                       RETURN NUMBER;
  --> Procedure para montar o JSON do Rating com as variáveis internas
  PROCEDURE pc_json_variaveis_rating(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                    ,pr_flprepon  IN BOOLEAN DEFAULT FALSE --> Flag Repon
                                    ,pr_vlsalari  IN NUMBER  DEFAULT 0 --> Valor do Salario Associado
                                    ,pr_persocio  IN NUMBER  DEFAULT 0 --> Percential do sócio
                                    ,pr_dtadmsoc  IN DATE    DEFAULT NULL --> Data Admissãio do Sócio
                                    ,pr_dtvigpro  IN DATE    DEFAULT NULL --> Data Vigência do Produto
                                    ,pr_tpprodut  IN NUMBER  DEFAULT 0  --> Tipo de Produto
                                    ,pr_dsjsonvar OUT json --> Retorno Variáveis Json
                                    ,pr_cdcritic  OUT NUMBER --> Código de critica encontrada
                                    ,pr_dscritic  OUT VARCHAR2);

  /* Solicitar o Rating da operação na Ibratan pelo acionamento do motor. */
  PROCEDURE pc_solicitar_rating_motor(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Conta do associado
                                     ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0  --> Tipo do contrato de rating
                                     ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0  --> Número do contrato do rating
                                     ,pr_cdoperad  IN crapnrc.cdoperad%TYPE  --> Código do operador
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE  --> Código da agência
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  --> Data de movimentacao
                                     ,pr_inpessoa  IN crapass.inpessoa%TYPE  --> Tipo de pessoa
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada no processo
                                     ,pr_dscritic OUT VARCHAR2);             --> Descritivo do erro

  PROCEDURE pc_busca_rat_expirado( pr_cdcooper  IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE                    --> Conta do associado
                                  ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE          --> Tipo do contrato
                                  ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE          --> Número do contrato
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                  ,pr_dscritic OUT VARCHAR2);
  PROCEDURE pc_valida_rat_expirado(  pr_nrdconta IN INTEGER, --> CONTA
                                    pr_nrctro   IN INTEGER, --CONTRATO
                                    pr_tpctro   IN INTEGER,
                                    pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                    pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                    pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                    pr_des_erro OUT VARCHAR2);

 PROCEDURE pc_verifica_continge_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                      ,pr_tpctrato   IN PLS_INTEGER DEFAULT 0               --> Tipo do contrato de rating
                                      ,pr_inpessoa   IN crapass.inpessoa%TYPE               --> Tipo de pessoa
                                      ,pr_inconting OUT tbrat_param_geral.incontingencia%TYPE --> indicador de incontingencia do rating
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE               --> Critica encontrada no processo
                                      ,pr_dscritic  OUT VARCHAR2);

 --- grava rating contingencia
 PROCEDURE pc_grava_rat_contingencia(pr_cdcooper   IN crapcop.cdcooper%TYPE                                 --> Código da Cooperativa
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE                                 --> Conta do associado
                                    ,pr_tpctrato   IN PLS_INTEGER DEFAULT 0                                 --> Tipo do contrato de rating
                                    ,pr_nrctrato   IN PLS_INTEGER DEFAULT 0                                 --> Número do contrato do rating
                                    ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE                                 --> Data de movimentacao
                                    ,pr_cdoperad   IN crapnrc.cdoperad%TYPE                                 --> Código do operador
                                    ,pr_strating   IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                    ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                                 --> Critica encontrada no processo
                                    ,pr_dscritic  OUT VARCHAR2);


  PROCEDURE pc_verifica_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                     ,pr_nrdconta     IN crapass.nrdconta%TYPE                                 --> Conta do associado
                                     ,pr_calc_rating OUT BOOLEAN                             --> indicador de calcula rating (True False)
                                     ,pr_cdcritic    OUT crapcri.cdcritic%TYPE               --> Critica encontrada no processo
                                     ,pr_dscritic    OUT VARCHAR2);


 PROCEDURE pc_ret_tbrisco_operacoes(pr_cdcooper    IN  tbrisco_operacoes.cdcooper%TYPE         --codigo que identifica a cooperativa
                              ,pr_nrdconta    IN  tbrisco_operacoes.nrdconta%TYPE           -- Numero da conta/dv do associado.
                              ,pr_tpctrato    IN  tbrisco_operacoes.tpctrato%TYPE default null --tipo de contrato utilizado por esta linha de credito
                              ,pr_nrctremp    IN  tbrisco_operacoes.nrctremp%TYPE default null -- Numero do contrato de emprestimo.
                              ,pr_inrisco     IN    tbrisco_operacoes.inrisco_rating%TYPE default null --nivel de risco rating efetivo
                              ,pr_tab_risco_op OUT RATI0003.typ_tab_risco_op
                              ,pr_erro         OUT VARCHAR2);

  --> Chamado por JOB d atualização do Rating
  PROCEDURE pc_job_rating(pr_cdcritic OUT PLS_INTEGER --> código da crítica
                         ,pr_dscritic OUT VARCHAR2);  --> descrição da crítica

  --> Converter o tipo de contrato para o tipo de produto para gravar na tabela TBGEN_WEBSERVICE ACIONA.
  FUNCTION fn_conv_tpctrato_tpproduto(pr_tpctrato  IN tbrisco_operacoes.tpctrato%TYPE)  --> Tipo do contrato
  RETURN NUMBER;

 PROCEDURE pc_ret_risco_tbrisco(pr_cdcooper      IN  tbrisco_operacoes.cdcooper%TYPE                       --codigo que identifica a cooperativa
                               ,pr_nrdconta      IN  tbrisco_operacoes.nrdconta%TYPE                       -- Numero da conta/dv do associado.
                               ,pr_tpctrato      IN  tbrisco_operacoes.tpctrato%TYPE default null          --tipo de contrato utilizado por esta linha de credito
                               ,pr_nrctremp      IN  tbrisco_operacoes.nrctremp%TYPE default null          -- Numero do contrato de emprestimo.
                               ,pr_insit_rating  IN  tbrisco_operacoes.insituacao_rating%TYPE default null -- Numero do contrato de emprestimo.
                               ,pr_inrisco      OUT  tbrisco_operacoes.inrisco_rating%TYPE                 -- nivel de risco rating efetivo
                               ,pr_cdcritic     OUT  PLS_INTEGER               --> Critica encontrada no processo
                               ,pr_dscritic     OUT  VARCHAR2);

  -- Verificar o endividamento do cooperado
  FUNCTION fn_verifica_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE               --> Conta do associado
                                     ) RETURN NUMBER;

  --> Atualiza Numero do Contrato do Rating
  PROCEDURE pc_atualiza_contrato_rating(pr_cdcooper       IN crapcop.cdcooper%TYPE                  --> Código da Cooperativa
                                       ,pr_nrdconta       IN crapass.nrdconta%TYPE                  --> Conta do associado
                                       ,pr_tpctrato       IN tbrisco_operacoes.TPCTRATO%TYPE        --> Tipo do contrato
                                       ,pr_nrctrato       IN tbrisco_operacoes.NRCTREMP%TYPE        --> Número do contrato
                                       ,pr_nrctrato_novo  IN tbrisco_operacoes.NRCTREMP%TYPE   --> Número do contrato Novo
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                 --> Critica encontrada no processo
                                       ,pr_dscritic  OUT VARCHAR2);                            --> Descritivo do erro

   /* Busca Informações do Rating */
  PROCEDURE pc_retorna_inf_rating(pr_cdcooper              IN crapcop.cdcooper%TYPE                       --> Código da Cooperativa
                                 ,pr_nrdconta              IN crapass.nrdconta%TYPE                       --> Conta do associado
                                 ,pr_tpctrato              IN tbrisco_operacoes.TPCTRATO%TYPE             --> Tipo do contrato
                                 ,pr_nrctrato              IN tbrisco_operacoes.NRCTREMP%TYPE             --> Número do contrato
                                 ,pr_insituacao_rating    OUT tbrisco_operacoes.insituacao_rating%TYPE    --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_inorigem_rating      OUT VARCHAR2                                    --> Caracter identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_inrisco_rating_autom OUT VARCHAR2                                    --> Caracter nivel de Risco Rating retornado do MOTOR
                                 ,pr_cdcritic             OUT crapcri.cdcritic%TYPE                       --> Critica encontrada no processo
                                 ,pr_dscritic             OUT VARCHAR2);

  /* Retornar o tipo de Birô que está sendo utilizado para a cooperativa */
  FUNCTION fn_tipo_biro(pr_cdcooper  IN crapcop.cdcooper%TYPE)  --> Código da cooperativa
  RETURN NUMBER;

 PROCEDURE pc_busca_risco_rat_preapr(pr_cdcooper        IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                    ,pr_nrdconta        IN tbrisco_operacoes.nrdconta%TYPE           --> Conta do associado
                                    ,pr_inrisco_rating OUT tbrisco_operacoes.inrisco_rating%TYPE    --> risco rating
                                    ,pr_cdcritic       OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                    ,pr_dscritic       OUT VARCHAR2);

END RATI0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED."RATI0003" IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0003                     Antiga:
  --  Sistema  : Rotinas para Rating dos Produtos
  --  Sigla    : RATI
  --  Autor    : Anderson Luiz Heckmann - AMcom
  --  Data     : Fevereiro/2019.                   Ultima atualizacao: 28/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Produtos.
  --
  -- Alteracao:
  --            prj450 - Criação da procedure Busca Status do Rating (Fabio Adriano - AMcom).
  --            25/03/2019         P450 - Rating, verificar parametros contingencia PAREST e PARRAT, se ligado, gravar
  --                               rating contingencia (pc_verifica_continge_rating e pc_grava_rat_contingencia).
  --                               Também verificado o endividamento, para calcular o rating ou não para o
  --                               cooperado (pc_verifica_endivid_param).  (Elton AMcom).
  --
  --            09/04/2019         P450 - Rating - Buscar os parâmetros da PARRAT e gravar na  tabela
  --                               de históricos (Heckmann - AMcom)
  --
  --            10/04/2019         P450 - Rating - Criação da Function fn_verifica_endivid_param para
  --                               verificar o endividamento do cooperado (Heckmann - AMcom)
  --
  --            30/04/2019         P450 - Alterado o cursor cr_operacoes da pc_busca_dados_rating_inclusao
  --                               para buscar as informações do Rating e não da Inclusão (Luiz Otávio Olinger Momm - AMCOM)
  --
  --            06/05/2019         P450 - Ajuste na procedure pc_grava_rat_contingencia - Rotina grava o rating contigencia
  --                               Ao chamar pc_grava_rating_operacao efetuado correção de parametro de Data do Movimento
  --                               (Mário - AMcom)
  --
  --            08/05/2019         P450 - Alterado status de Expirado para Vencido (Luiz Otávio Olinger Momm - AMCOM)
  --
  --            14/05/2019         P450 - Alterado para considerar o rating da central quando estiver em contingencia (Heckmann - AMCOM)
  --
  --            28/06/2019         P450 - Reposicionado VariaveisInterna abaixo de VariaveisAdicionais no Proponente (Mario - AMcom)
  --
  --            07/08/2019         P450 - Alterado pc_atualiza_contrato_rating para retornar sucesso caso não tiver Rating
  --                               (Luiz Otávio Olinger Momm - AMCOM)
  --
  --            12/08/2019         P450 - Adicionada a rotina para pegar o parâmetro do
  --                               de reaproveitamento e inserir no JSON em configuracoes
  --                               para Ibratan (Luiz Otavio Olinger Momm - AMCOM)
  --
  --            12/08/2019         P450 - Adicionada função fn_retorna_modeloRating para verificar
  --                               o modelo do Rating na Ibratan
  --                               (Luiz Otavio Olinger Momm - AMCOM)
  --
  --            14/08/2019         P450 - Quando a rotina pc_grava_rating_operacao é chamada na liberação do Borderô ou
  --                               efetivação do Rating, não pode ser verificado se o sistema está em contingência (Heckmann - AMcom)
  --                               (Luiz Otavio Olinger Momm - AMCOM)
  --
  --            14/08/2019         P450 - Adicionado em indicadoresCliente.modeloRating o modelo que a Ibratan
  --                               deve calcular e retornar para Aimaro
  --                               (Luiz Otavio Olinger Momm - AMCOM)
  --
  --            16/08/2019         P450 - Estória 25229 - Pré-aprovado - GRAVAR RATING DO LIMITE: (LOTE)
  --                               Gravar rating para os Empréstimos Pré-Aprovado (Finalidade 68) conforme
  --                               Rating do limite de crédito Pré-Aprovado (Finalidade 68).
  --                               Quando acontecer a manutenção do limite de crédito do Pré-Aprovado, todos
  --                               os empréstimos contratados com a finalidade 68 deverão ser atualizados com
  --                               o novo Rating calculado para o Limite do Pré-Aprovado.
  --                               (Marcelo Elias Gonçalves - AMCOM)
  --
  --            20/08/2019         P450 - Estória 25229 - Pré-aprovado - GRAVAR RATING DO LIMITE: (LOTE)
  --                               Buscar os Empréstimos (Finalidade 68) através do CPF/CNPJ Base do Associado.
  --                               (Marcelo Elias Gonçalves - AMCOM)
  --
  --            23/08/2019         P450 - Estória 25229(SM01 - Data de Corte do Rating) - Pré-aprovado - GRAVAR RATING
  --                               DO LIMITE: (LOTE)
  --                               Gravar rating para os Empréstimos Pré-Aprovado (Finalidade 68) se a data de
  --                               corte for menor que a data do parametro DT_CORTE_REFOR_RATING (CRAPPRM).
  --                               Quando acontecer a manutenção do limite de crédito do Pré-Aprovado, todos os
  --                               empréstimos contratados com a finalidade 68 deverão ser atualizados com o novo
  --                               Rating calculado para o Limite do Pré-Aprovado, deste que a data de corte seja
  --                               maior ou igual a data do parametro DT_CORTE_REFOR_RATING (CRAPPRM).
  --                               (Marcelo Elias Gonçalves - AMCOM)
  ---------------------------------------------------------------------------------------------------------------

  /* Gravar o Rating da operação que retornou do Ibratan. */
  PROCEDURE pc_grava_rating_operacao(pr_cdcooper  IN crapcop.cdcooper%TYPE                                     --> Código da Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE                                      --> Conta do associado
                                    ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0                                      --> Tipo do contrato de rating
                                    ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0                                      --> Número do contrato do rating
                                    ,pr_ntrating  IN tbrisco_operacoes.inrisco_rating%TYPE DEFAULT NULL         --> Nivel de Risco Rating EFETIVO
                                    ,pr_ntrataut  IN tbrisco_operacoes.inrisco_rating_autom%TYPE DEFAULT NULL   --> Nivel de Risco Rating retornado do MOTOR
                                    ,pr_dtrating  IN tbrisco_operacoes.dtrisco_rating%TYPE DEFAULT NULL         --> Data de Efetivacao do Rating
                                    ,pr_strating  IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL      --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                    ,pr_orrating  IN tbrisco_operacoes.inorigem_rating%TYPE DEFAULT NULL        --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                    ,pr_cdoprrat  IN tbrisco_operacoes.cdoperad_rating%TYPE DEFAULT NULL        --> Codigo Operador que Efetivou o Rating
                                    ,pr_dtrataut  IN tbrisco_operacoes.dtrisco_rating_autom%TYPE DEFAULT NULL   --> Data do Rating retornado do MOTOR
                                    ,pr_innivel_rating IN tbrisco_operacoes.innivel_rating%TYPE DEFAULT NULL    --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                    ,pr_nrcpfcnpj_base IN tbrisco_operacoes.nrcpfcnpj_base%TYPE DEFAULT 0       --> Numero do CPF/CNPJ Base do associado
                                    ,pr_inpontos_rating IN tbrisco_operacoes.inpontos_rating%TYPE DEFAULT NULL  --> Pontuacao do Rating retornada do Motor
                                    ,pr_insegmento_rating IN tbrisco_operacoes.insegmento_rating%TYPE DEFAULT NULL  --> Informacao de qual Garantia foi utilizada para calculo Rating do Motor
                                    ,pr_inrisco_rat_inc IN tbrisco_operacoes.inrisco_rat_inc%TYPE DEFAULT NULL  --> Nivel de Rating da Inclusao da Proposta
                                    ,pr_innivel_rat_inc IN tbrisco_operacoes.innivel_rat_inc%TYPE DEFAULT NULL  --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                    ,pr_inpontos_rat_inc IN tbrisco_operacoes.inpontos_rat_inc%TYPE DEFAULT NULL  --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                    ,pr_insegmento_rat_inc IN tbrisco_operacoes.insegmento_rat_inc%TYPE DEFAULT NULL  --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                    ,pr_efetivacao_rating IN PLS_INTEGER DEFAULT 0                               --> Indica se é apenas Efetivação do Rating
                                    --Variáveis para gravar o histórico
                                    ,pr_cdoperad IN tbrisco_operacoes.cdoperad_rating%TYPE DEFAULT NULL         --> Operador que gerou historico de rating
                                    ,pr_dtmvtolt IN tbrating_historicos.dthr_operacao%TYPE DEFAULT NULL         --> Data/Hora do historico de rating
                                    ,pr_valor IN crapepr.vlemprst%TYPE DEFAULT NULL                             --> Valor Contratado/Operaca
                                    ,pr_rating_sugerido IN tbrating_historicos.inrisco_rating_novo%TYPE DEFAULT NULL --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                    ,pr_justificativa IN tbrating_historicos.ds_justificativa%TYPE DEFAULT NULL --> Justificativa do operador para alteracao do Rating
                                    ,pr_tpoperacao_rating IN tbrating_historicos.tpoperacao_rating%TYPE DEFAULT NULL --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                    --Variáveis de crítica
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                                      --> Critica encontrada no processo
                                    ,pr_dscritic OUT VARCHAR2) IS                                               --> Descritivo do erro
    /* ..........................................................................

       Programa: pc_grava_rating_operacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Anderson Luiz Heckmann
       Data    : Fevereiro/2019.                          Ultima Atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que chamado.
       Objetivo  : Gravar o Rating da operação que retornou do Ibratan.

       Alteracoes:

    ............................................................................. */

     PRAGMA AUTONOMOUS_TRANSACTION;

     -- CURSORES
     CURSOR cr_crapass IS
       SELECT ass.inpessoa
             ,ass.nrcpfcnpj_base
         FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;
     
     CURSOR cr_tbrat_param_geral(pr_inpessoa IN crapass.inpessoa%TYPE) IS
       SELECT qtdias_atualizacao_autom_baixo
             ,qtdias_atualizacao_autom_medio
             ,qtdias_atualizacao_autom_alto
         FROM tbrat_param_geral
        WHERE cdcooper = pr_cdcooper
          AND tpproduto = pr_tpctrato
          AND inpessoa = pr_inpessoa;
     rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

     -- VARIAVEIS
     vr_cdcritic    PLS_INTEGER;
     vr_dscritic    VARCHAR2(4000);
     vr_exc_erro    EXCEPTION;
     vr_retorno     BOOLEAN DEFAULT(FALSE);
     vr_retxml      xmltype;
     vr_inconting             tbrat_param_geral.incontingencia%TYPE;
     vr_inrisco_rating        tbrisco_operacoes.inrisco_rating%TYPE;
     vr_inrisco_rating_autom  tbrisco_operacoes.inrisco_rating_autom%TYPE;
     vr_insituacao_rating     tbrisco_operacoes.insituacao_rating%TYPE;
     vr_inorigem_rating       tbrisco_operacoes.inorigem_rating%TYPE;
     vr_inpessao              tbrisco_operacoes.inpessoa%TYPE;
     vr_vencimento            tbrisco_operacoes.dtvencto_rating%TYPE;
     vr_qtdiasvencto          tbrisco_operacoes.qtdiasvencto_rating%TYPE;
     vr_flintegrar_sas        tbrisco_operacoes.flintegrar_sas%TYPE;

     BEGIN

       /*
       TPCTRATO para a TBRISCO_OPERACOES:
         1 - Limite de Crédito
         2 - Limite de Desconto de Cheque
         3 - Limite de Desconto de Título
         68 - Pré-aprovado
         90 - Empréstimos/Financiamentos
         91 - Borderôs de descontos de Títulos
         92 - Borderôs de descontos de Cheques

       TPPRODUTO para a PC_GRAVAR_ACIONAMENTO
         0 – Empréstimos/Financiamento
         2 – Desconto Cheques - Limite
         3 – Desconto Títulos - Limite
         4 – Cartão de Crédito
         5 – Limite de Crédito
         6 – Desconto Cheque – Borderô
         7 – Desconto de Título – Borderô

       INORIGEM_RATING:
         1 - Motor
         2 - Esteira
         3 - Regra Aimaro
         4 - Contingência
         5 - Herdado do Limite

       INSITUACAO_RATING:
         0 - Não Enviado
         1 - Em Análise
         2 - Analisado
         3 - Vencido
         4 - Efetivado
         5 - Efetivo Vencido
       */

       /********************* ATENÇÂO ***********************

         O parâmetro PR_STRATING referente a situação do rating deve
         ser passado na chamada da Procedure conforme o momento.
         Por exemplo:
         Quando o acionamento for a partir de uma "Análise", deverá ser gravado status 2-Analisado.
         Quando for acionado por uma "Efetivação", deverá ser gravado 4-Efetivado.

         Dúvidas falar com Anderson ou Guilherme (ambos Amcom).

       *****************************************************/

       -- Para a cooperativa 3 - Ailos, não deverá gravar o rating, pois será utilizado o rating antigo (tabela CRAPNRC)
       IF pr_cdcooper <> 3 THEN

         vr_inrisco_rating       := pr_ntrating;
         vr_inrisco_rating_autom := pr_ntrataut;
         -- A situação efetivo vencido acontece quando ocorre uma efetivação de proposta onde
         -- o rating nasceu como contingencia e por causa do valor de endividamento ele
         -- deveria ser efetivo.
         IF pr_strating = 5 THEN  --efetivo vencido
            vr_insituacao_rating    := 3;
         ELSE
           vr_insituacao_rating    := pr_strating;
         END IF;

        -- vr_insituacao_rating    := pr_strating;
         vr_inorigem_rating      := pr_orrating;
         vr_inconting            := 0;

         -- Buscar o tipo da pessoa
         OPEN cr_crapass;
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;
         
         -- Adiciona tipo de pessoa na tabela de risco_operacoes
         vr_inpessao := rw_crapass.inpessoa;

         -- Quando a rotina é chamada na liberação do Borderô,
         -- o sistema não pode verificar se o sistema está em contingência.
         -- Quando isto ocorrer, passar 1 no parâmetro.
         IF pr_efetivacao_rating = 0 THEN

           --- verifica se a contingencia está ligada (P450 - Rating)
           pc_verifica_continge_rating(pr_cdcooper  => pr_cdcooper          --> Cooper
                                      ,pr_tpctrato  => pr_tpctrato          --> Tipo do contrato de rating
                                      ,pr_inpessoa  => rw_crapass.inpessoa  --> Tipo de pessoa
                                      ,pr_inconting => vr_inconting
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);

           IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

         END IF;


         IF ((vr_inconting = 1 AND NVL(pr_strating,0) > 0) OR  -- em contigencia (1-Sim 0-Não) (P450 - Rating)
            (pr_orrating = 4)) THEN -- Origem Rating igual a 4, quando está em contingencia ou quando tem aprovação automática
           -- busca o rating contingencia
           pc_busca_rat_contigencia(pr_cdcooper => pr_cdcooper
                                   ,pr_nrcpfcgc => rw_crapass.nrcpfcnpj_base --> CPFCNPJ BASE
                                   ,pr_innivris => vr_inrisco_rating                   --> risco contingencia
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

           IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;
           vr_insituacao_rating    := 3;
           vr_inorigem_rating      := 4;
           vr_inrisco_rating_autom := vr_inrisco_rating;
         END IF;
         
         vr_vencimento := NULL;
         vr_qtdiasvencto := 0;
         
         -- Pesquisa a quantidade de dias da PARRAT a calcula o vencimento para registrar em 
         -- tabela 4-Efetivado e 5-Efetivo Vencido.
         IF pr_strating IN (4,5) THEN
           OPEN cr_tbrat_param_geral(pr_inpessoa => vr_inpessao);
           FETCH cr_tbrat_param_geral INTO rw_tbrat_param_geral;
           IF cr_tbrat_param_geral%FOUND THEN
             IF pr_innivel_rating = 1 THEN
               vr_qtdiasvencto := rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo;
             ELSIF pr_innivel_rating = 2 OR pr_innivel_rating IS NULL THEN
               vr_qtdiasvencto := rw_tbrat_param_geral.qtdias_atualizacao_autom_medio;
             ELSIF pr_innivel_rating = 3 THEN
               vr_qtdiasvencto := rw_tbrat_param_geral.qtdias_atualizacao_autom_alto;
             END IF;
             vr_vencimento := pr_dtrating + vr_qtdiasvencto;
           ELSE
             -- caso não econtrar o parâmetro usar como padrao 180 dias
             vr_qtdiasvencto := 180;
             vr_vencimento := pr_dtrating + vr_qtdiasvencto;
           END IF;
           CLOSE cr_tbrat_param_geral;
         END IF;
         
         -- Indicar se deve integrar com o SAS ou não
         vr_flintegrar_sas       := 0;
         IF pr_tpctrato = 68 AND pr_ntrating IS NULL THEN
           vr_flintegrar_sas := 1;
         END IF; 

         -- Atualiza as informações do rating na tabela de operações
         -- A atualização ocorrerá com maior frequência
         UPDATE tbrisco_operacoes
         SET inrisco_rating       = DECODE(pr_strating, 5, NVL(vr_inrisco_rating, inrisco_rating_autom) -- 5-efetivado vencido
                                                      , 4, NVL(vr_inrisco_rating, inrisco_rating_autom)
                                                      , 3, inrisco_rating
                                                         , NULL)
            ,dtrisco_rating       = DECODE(pr_strating, 5, NVL(pr_dtrating, dtrisco_rating)
                                                      , 4, NVL(pr_dtrating, dtrisco_rating)
                                                      , 3, dtrisco_rating
                                                         , NULL)

            ,inrisco_rating_autom = DECODE(pr_strating, 0, NULL, NVL(vr_inrisco_rating_autom, inrisco_rating_autom))
            ,dtrisco_rating_autom = DECODE(pr_strating, 0, NULL, NVL(pr_dtrataut, dtrisco_rating_autom))

            ,insituacao_rating    = NVL(vr_insituacao_rating, insituacao_rating)

            ,inorigem_rating      = NVL(vr_inorigem_rating, inorigem_rating)

            ,innivel_rating       = DECODE(pr_strating, 0, NULL, NVL(pr_innivel_rating, innivel_rating))
            ,inpontos_rating      = DECODE(pr_strating, 0, NULL, NVL(pr_inpontos_rating, inpontos_rating))
            ,insegmento_rating    = DECODE(pr_strating, 0, NULL,  NVL(pr_insegmento_rating, insegmento_rating))

            ,nrcpfcnpj_base       = NVL(pr_nrcpfcnpj_base, nrcpfcnpj_base)
            ,inpessoa             = NVL(vr_inpessao, inpessoa)

            ,cdoperad_rating      = NVL(pr_cdoprrat, cdoperad_rating)

            ,inrisco_rat_inc      = NVL(pr_inrisco_rat_inc, inrisco_rat_inc)
            ,innivel_rat_inc      = NVL(pr_innivel_rat_inc, innivel_rat_inc)
            ,inpontos_rat_inc     = NVL(pr_inpontos_rat_inc, inpontos_rat_inc)
            ,insegmento_rat_inc   = NVL(pr_insegmento_rat_inc, insegmento_rat_inc)
            ,dtvencto_rating      = NVL(vr_vencimento, dtvencto_rating)
            ,qtdiasvencto_rating  = NVL(vr_qtdiasvencto, qtdiasvencto_rating)
            ,flintegrar_sas       = NVL(vr_flintegrar_sas, flintegrar_sas)
          WHERE cdcooper             = pr_cdcooper
            AND nrdconta             = pr_nrdconta
            AND nrctremp             = pr_nrctrato
            AND tpctrato             = pr_tpctrato;

         -- Caso não existir o registro do rating na tabela de operações, faz a inserção
         IF SQL%ROWCOUNT = 0 AND NVL(pr_nrcpfcnpj_base,0) > 0 THEN
           INSERT INTO tbrisco_operacoes
                     ( cdcooper
                      ,nrdconta
                      ,nrctremp
                      ,tpctrato
                      ,inrisco_rating
                      ,inrisco_rating_autom
                      ,dtrisco_rating
                      ,insituacao_rating
                      ,inorigem_rating
                      ,cdoperad_rating
                      ,dtrisco_rating_autom
                      ,innivel_rating
                      ,nrcpfcnpj_base
                      ,inpessoa
                      ,inpontos_rating
                      ,insegmento_rating
                      ,inrisco_rat_inc
                      ,innivel_rat_inc
                      ,inpontos_rat_inc
                      ,insegmento_rat_inc
                      ,dtvencto_rating
                      ,qtdiasvencto_rating
                      ,flintegrar_sas)
               VALUES
                     ( pr_cdcooper
                      ,pr_nrdconta
                      ,pr_nrctrato
                      ,pr_tpctrato
                      ,DECODE(pr_strating, 4, vr_inrisco_rating, NULL)
                      ,vr_inrisco_rating_autom
                      ,DECODE(pr_strating, 4, pr_dtrating, NULL)
                      ,vr_insituacao_rating
                      ,vr_inorigem_rating
                      ,pr_cdoprrat
                      ,pr_dtrataut
                      ,pr_innivel_rating
                      ,pr_nrcpfcnpj_base
                      ,vr_inpessao
                      ,pr_inpontos_rating
                      ,pr_insegmento_rating
                      ,pr_inrisco_rat_inc
                      ,pr_innivel_rat_inc
                      ,pr_inpontos_rat_inc
                      ,pr_insegmento_rat_inc
                      ,vr_vencimento
                      ,vr_qtdiasvencto
                      ,vr_flintegrar_sas);

         END IF;

         --Deverá ser colocado o log aqui. Até o momento a tabela ainda não foi criada.
         vr_retorno := fn_registra_historico(pr_cdcooper => pr_cdcooper
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctro => pr_nrctrato
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_valor => pr_valor
                                            ,pr_tpctrato => pr_tpctrato
                                            ,pr_rating_sugerido => pr_rating_sugerido
                                            ,pr_justificativa => pr_justificativa
                                            ,pr_inrisco_rating => vr_inrisco_rating
                                            ,pr_inrisco_rating_autom => vr_inrisco_rating_autom
                                            ,pr_dtrisco_rating_autom => pr_dtrataut
                                            ,pr_dtrisco_rating => pr_dtrating
                                            ,pr_insituacao_rating => vr_insituacao_rating
                                            ,pr_inorigem_rating => vr_inorigem_rating
                                            ,pr_cdoperad_rating => pr_cdoprrat
                                            ,pr_tpoperacao_rating => pr_tpoperacao_rating
                                            ,pr_retxml => vr_retxml
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;

       END IF;

       COMMIT;

     EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         ROLLBACK;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina RATI0003.pc_grava_rating_operacao '||SQLERRM;
         ROLLBACK;
  END pc_grava_rating_operacao;

  FUNCTION fn_retorna_modelo_rating (pr_cdcooper         IN tbrat_param_geral.cdcooper%TYPE)
  /* .............................................................................

      Programa: fn_retorna_modelo_rating
      SIStema : CECRED
      Sigla   :
      Autor   : Luiz Otavio Olinger Momm/AMCOM
      Data    : Agosto/2019                 Ultima atualizacao: --

      Verifica por cooperativa o modelo utilizado para calculo do Rating
      Frequencia: Sempre que for chamado

      Objetivo  : Será chamado toda vez que gerar requisição para Ibratan

      Observacao: -----

      Alteracoes:

  ..............................................................................*/

  RETURN INTEGER IS
    -- Buscar PA do operador de envio da proposta
    CURSOR cr_paramgeral IS
      SELECT MAX(tpmodelo_rating)
        FROM tbrat_param_geral
       WHERE cdcooper = pr_cdcooper;
    vr_tpmodelo INTEGER;
  BEGIN
    OPEN cr_paramgeral;
    FETCH cr_paramgeral INTO vr_tpmodelo;
    CLOSE cr_paramgeral;

    -- Assume o padrão modelo de calculo Aimaro caso não configurado na tabela
    IF vr_tpmodelo IS NOT NULL THEN
      IF vr_tpmodelo = 0 THEN
        vr_tpmodelo := 1;
      END IF;
    END IF;

    RETURN NVL(vr_tpmodelo, 1);
  EXCEPTION
    WHEN OTHERS THEN
      -- Em caso de erro assume o padrão modelo de calculo Aimaro caso não configurado na tabela
      RETURN NVL(vr_tpmodelo, 1);
  END;

  FUNCTION fn_valida_limite_chq_tit(pr_cdcooper IN tbrat_param_geral.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE)
  /* .............................................................................

        Programa: fn_valida_limite
        Sistema : CRED
        Sigla   :
        Autor   : Guilherme/AMCOM
        Data    : Agosto/2019                 Ultima atualizacao: --


        Frequencia: Sempre que for chamado

        Objetivo  : Verificar se o contrato de limite que esteja cancelado
                   tem Borderos ativo
                   Retorno 1 - Com Bordero Ativo  / 0 - Apenas Bordero Encerrado

        Observacao: -----

        Alteracoes:

    ..............................................................................*/

   RETURN INTEGER IS

    -- Buscar PA do operador de envio da proposta
    CURSOR cr_bordero_chq IS
      SELECT COUNT(*) qtd_borderos
        FROM crapbdc bdc, crapcdb cdb
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrctrlim = pr_nrctremp
         AND bdc.dtlibbdc IS NOT NULL
         AND bdc.insitbdc = 3
         AND cdb.cdcooper = bdc.cdcooper
         AND cdb.nrborder = bdc.nrborder
         AND cdb.nrdconta = bdc.nrdconta
         AND cdb.dtdevolu IS NULL
         AND cdb.dtlibbdc IS NULL
      --AND t.dtlibera > '10/08/2019'
      ;
    rw_bordero_chq cr_bordero_chq%ROWTYPE;

    CURSOR cr_bordero_tit IS
      SELECT COUNT(*) qtd_borderos
        FROM crapbdt bdt, craptdb tdb
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrctrlim = pr_nrctremp
         AND bdt.flverbor = 1
         AND bdt.dtlibbdt IS NOT NULL
         AND bdt.insitbdt = 3
         AND tdb.cdcooper = bdt.cdcooper
         AND tdb.nrdconta = bdt.nrdconta
         AND tdb.nrborder = bdt.nrborder
         AND tdb.vlsldtit > 0;
    rw_bordero_tit cr_bordero_tit%ROWTYPE;

    vr_qtd_borderos INTEGER := 0;
  BEGIN

    IF pr_tpctrato = 2 THEN
      -- Cheques
      OPEN cr_bordero_chq;
      FETCH cr_bordero_chq
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_chq;
    ELSIF pr_tpctrato = 3 THEN
      -- Titulos
      OPEN cr_bordero_tit;
      FETCH cr_bordero_tit
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_tit;
    ELSE
      RETURN 0; -- Encerrado
    END IF;

    IF vr_qtd_borderos > 0 THEN
      RETURN 1; -- 1 - Com Bordero Ativo
    ELSE
      RETURN 0; -- 0 - Apenas Bordero Encerrado
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END fn_valida_limite_chq_tit;



  FUNCTION fn_registra_historico(pr_cdcooper             IN tbrisco_operacoes.cdcooper%TYPE,
                                 pr_cdoperad             IN tbrisco_operacoes.cdoperad_rating%TYPE,
                                 pr_nrdconta             IN tbrisco_operacoes.nrdconta%TYPE, --> CONTA
                                 pr_nrctro               IN tbrisco_operacoes.nrctremp%TYPE, --CONTRATO
                                 pr_dtmvtolt             IN tbrating_historicos.dthr_operacao%TYPE,
                                 pr_valor                IN crapepr.vlemprst%type,
                                 pr_tpctrato             IN tbrisco_operacoes.tpctrato%TYPE,
                                 pr_rating_sugerido      IN INTEGER,
                                 pr_justificativa        IN VARCHAR2,
                                 pr_inrisco_rating       IN tbrisco_operacoes.inrisco_rating%TYPE,
                                 pr_inrisco_rating_autom IN tbrisco_operacoes.inrisco_rating_autom%TYPE,
                                 pr_dtrisco_rating_autom IN tbrisco_operacoes.dtrisco_rating_autom%TYPE,
                                 pr_dtrisco_rating       IN tbrisco_operacoes.dtrisco_rating%TYPE,
                                 pr_insituacao_rating    IN tbrisco_operacoes.insituacao_rating%TYPE,
                                 pr_inorigem_rating      IN tbrisco_operacoes.inorigem_rating%TYPE,
                                 pr_cdoperad_rating      IN tbrisco_operacoes.cdoperad_rating%TYPE,
                                 pr_tpoperacao_rating    IN tbrating_historicos.tpoperacao_rating%TYPE,
                                 pr_retxml               IN OUT NOCOPY XMLType,
                                 pr_cdcritic             OUT INTEGER,
                                 pr_dscritic             OUT VARCHAR2)
 RETURN BOOLEAN IS
  /* .............................................................................

      Programa: fc_registra_justificativa
      SIStema : CECRED
      Sigla   : RATMOV
      Autor   : Daniele Rocha/AMcom
      Data    : Fevereiro/2019                 Ultima atualizacao: --

      Dados referentes ao programa: Será chamado pelo alterar rating registrar justificativa
      Frequencia: Sempre que for chamado

      Objetivo  : Será chamado pelo alterar rating registrar justificativa

      Observacao: -----

      Alteracoes:

                 09/04/2019         P450 - Rating - Buscar os parâmetros da PARRAT e gravar na  tabela
                                     de históricos (Heckmann - AMcom)

  ..............................................................................*/

  vr_sequencia          INTEGER;
  vr_retorno            BOOLEAN DEFAULT(FALSE);
  vr_dsxml_param_rating CLOB;
  vr_hora               VARCHAR2(40);
  vr_auxconta           INTEGER := 0; -- Contador auxiliar p/ posicao no XML
  vr_emp_efetivado      INTEGER := 0; -- Contrato efetivado (0 = não / 1 = sim)

  CURSOR cr_tbrating_historicos IS
    SELECT NVL(MAX(nrseq_operacao) + 1, 1)
      AS vr_sequencia
      FROM tbrating_historicos
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctro
       AND tpctrato = pr_tpctrato;

  CURSOR cr_crapass IS
    SELECT ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_emprestimo_efetivado IS
    SELECT 1
      FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrdconta
       AND dtmvtolt = pr_dtmvtolt;
  rw_emprestimo_efetivado cr_emprestimo_efetivado%ROWTYPE;

  CURSOR cr_tbrat_param_geral (pr_cdcooper IN crapass.cdcooper%TYPE
                              ,pr_inpessoa IN crapass.inpessoa%TYPE
                              ,pr_tpproduto IN tbrat_param_geral.tpproduto%TYPE) IS
    SELECT tpg.*
      FROM tbrat_param_geral tpg
     WHERE tpg.cdcooper = pr_cdcooper
       AND tpg.inpessoa = pr_inpessoa
       AND tpg.tpproduto = pr_tpctrato;
  rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;


BEGIN
  --- BUSCA O SEQUENCIAL
  OPEN cr_tbrating_historicos;
  FETCH cr_tbrating_historicos
    INTO vr_sequencia;
  CLOSE cr_tbrating_historicos;

  vr_hora :=' '|| to_char(sysdate,'HH24:MI:SS');

  -- Buscar o tipo da pessoa
  OPEN cr_crapass;
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;

  -- Buscar os parâmetros gerais da PARRAT
  OPEN cr_tbrat_param_geral (pr_cdcooper => pr_cdcooper
                            ,pr_inpessoa => rw_crapass.inpessoa
                            ,pr_tpproduto => pr_tpctrato);
  FETCH cr_tbrat_param_geral INTO rw_tbrat_param_geral;
  CLOSE cr_tbrat_param_geral;

  --Montar as informeções para o XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

  -- Tag principal Root
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                        pr_des_erro => pr_dscritic);

  -- Campos da Tag Dados
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'cdcooper',
                         pr_tag_cont => to_char(pr_cdcooper),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'inpessoa',
                         pr_tag_cont => to_char(rw_crapass.inpessoa),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'tpproduto',
                         pr_tag_cont => to_char(pr_tpctrato),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_niveis_reducao',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_niveis_reducao),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'idnivel_risco_permite_reducao',
                         pr_tag_cont => rw_tbrat_param_geral.idnivel_risco_permite_reducao,
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_atencede_atualizacao',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_atencede_atualizacao),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_reaproveitamento',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_reaproveitamento),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtmeses_expiracao_nota',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtmeses_expiracao_nota),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_atualizacao_autom_baixo',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_atualizacao_autom_baixo),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_atualizacao_autom_medio',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_atualizacao_autom_medio),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_atualizacao_autom_alto',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_atualizacao_autom_alto),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'qtdias_atualizacao_manual',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.qtdias_atualizacao_manual),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'incontingencia',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.incontingencia),
                         pr_des_erro => pr_dscritic);

  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'inpermite_alterar',
                         pr_tag_cont => to_char(rw_tbrat_param_geral.inpermite_alterar),
                         pr_des_erro => pr_dscritic);

  vr_dsxml_param_rating := pr_retxml.getStringVal();

  /* P450 - Empréstimo efetivado */
  IF pr_tpctrato = 90 THEN
    OPEN cr_emprestimo_efetivado;
    FETCH cr_emprestimo_efetivado
      INTO rw_emprestimo_efetivado;
      IF cr_emprestimo_efetivado%FOUND THEN
        vr_emp_efetivado := 1;
      ELSE
        vr_emp_efetivado := 0;
      END IF;
    CLOSE cr_emprestimo_efetivado;
  END IF;
  /* P450 - Empréstimo efetivado */

  BEGIN
    INSERT INTO tbrating_historicos
      (cdcooper,
       nrdconta,
       nrctremp,
       tpctrato,
       nrseq_operacao,
       dthr_operacao,
       cdoperador_operacao,
       tpoperacao_rating,
       vloperacao,
       inrisco_rating,
       dtrisco_rating,
       inrisco_rating_autom,
       dtrisco_rating_autom,
       inrisco_rating_novo,
       dtrisco_rating_novo,
       dsxml_param_rating,
       ds_justificativa)
    VALUES
      (pr_cdcooper, -- cdcooper,
       pr_nrdconta, -- nrdconta,
       pr_nrctro, -- nrctremp,
       pr_tpctrato, -- tpctrato,
       vr_sequencia, -- nrseq_operacao,
       to_date(to_char(pr_dtmvtolt,'dd-mm-yy')||vr_hora, 'dd-mm-yy hh24:mi:ss'), -- dthr_operacao
       pr_cdoperad, -- cdoperador_operacao,
       pr_tpoperacao_rating, -- tpoperacao_rating, 1--> alteração do rating / 2 efetivação rating
       pr_valor, -- vloperacao,
       pr_inrisco_rating, -- inrisco_rating,
       pr_dtrisco_rating, -- dtrisco_rating,
       pr_inrisco_rating_autom, -- inrisco_rating_autom,
       pr_dtrisco_rating_autom, -- dtrisco_rating_autom,
       pr_rating_sugerido, -- inrisco_rating_novo  confirma se é essa informação mesmo
       pr_dtmvtolt, -- dtrisco_rating_novo,
       vr_dsxml_param_rating, -- dsxml_param_rating,
       pr_justificativa); -- ds_justificativa

    vr_retorno := true;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := pr_dscritic || 'Erro ao Registar Justificativa ' ||
                     ' Cooperativa = ' || pr_cdcooper || ' Conta = ' ||
                     pr_nrdconta || ' Contrato = ' || pr_nrctro ||
                     ' Tipo = ' || pr_tpctrato || ' ' || sqlerrm;

      vr_retorno := FALSE;
      ROLLBACK;

  END;

  RETURN(vr_retorno);

EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := pr_dscritic || 'Erro ao Registar Operacoes ' ||
                   ' Cooperativa = ' || pr_cdcooper || ' Conta = ' ||
                   pr_nrdconta || ' Contrato = ' || pr_nrctro || ' Tipo = ' ||
                   pr_tpctrato || ' ' || sqlerrm;

    ROLLBACK;
    vr_retorno := FALSE;
    RETURN(vr_retorno);
END;

  /* Busca Status do Rating */
  PROCEDURE pc_busca_status_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                  ,pr_nrdconta  IN NUMBER                                    --> Conta ou CPFCNPJ base do associado
                                  ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE          --> Tipo do contrato
                                  ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE          --> Número do contrato
                                  ,pr_strating  OUT tbrisco_operacoes.insituacao_rating%TYPE --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                  ,pr_flgrating OUT INTEGER                                  --> Flag retorna se rating valido ou nao
                                  ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                  ,pr_dscritic  OUT VARCHAR2) IS                             --> Descritivo do erro

  /* ..........................................................................

  Programa: pc_busca_status_rating
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Fabio Adriano (AMcom)
  Data    : Fevereiro/2019.                          Ultima Atualizacao: 27/03/2019

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Busca o Status do Rating.

  Alteracoes:
              28/03/2019 - padronização de validação do Rating para todos os produtos (Fabio Adriano AMcom).

              08/04/2019 - validar a data de vencimento do Rating conforme Parametrização (Mário - AMcom).

              06/05/2019 - adequar as MENSAGENS de Rating Expirado e Vencido (Mário - AMcom).

              23/08/2019 - verificar se há rating analisado ou efetivo para o cpfcnpj base (Heckmann - AMcom).

              03/09/2019 - liberar o Rating dos Pré-Aprovados gravados em Contingência (Weverton Otoni - AMcom).
  ............................................................................. */

  -- CURSORES

  -- tbrisco_operacoes Status do Rating
  CURSOR cr_tbrisco_operacoes (pr_cdcooper  IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                              ,pr_nrdconta  IN NUMBER                          --> Conta ou CPFCNPJ base do associado
                              ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE --> Tipo do contrato de rating
                              ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE --> Número do contrato do rating
                              ) IS
    SELECT nvl(opr.insituacao_rating,0) insituacao_rating
          ,opr.dtrisco_rating
          ,opr.dtrisco_rating + DECODE(nvl(opr.innivel_rating,2)
                                      ,1,nvl(tpg.qtdias_atualizacao_autom_baixo,0)
                                      ,2,nvl(tpg.qtdias_atualizacao_autom_medio,0)
                                      ,3,nvl(tpg.qtdias_atualizacao_autom_alto,0)) dtvencto_risco
          ,opr.dtrisco_rating_autom + nvl(tpg.qtmeses_expiracao_nota,0) dtexpiracao
                              -- Apesar de "meses", é "dias"
      FROM tbrisco_operacoes opr
          ,crapass           ass
          ,tbrat_param_geral tpg
     WHERE opr.cdcooper = pr_cdcooper
       AND opr.nrdconta = pr_nrdconta
       AND opr.nrctremp = pr_nrctrato
       AND opr.tpctrato = pr_tpctrato
       AND ass.cdcooper = opr.cdcooper
       AND ass.nrdconta = opr.nrdconta
       AND tpg.cdcooper = ass.cdcooper
       AND tpg.inpessoa = ass.inpessoa
       AND tpg.tpproduto = pr_tpctrato
       AND pr_tpctrato <> 68
     UNION ALL
     -- Pre-aprovado
     SELECT nvl(opr.insituacao_rating,0) insituacao_rating
          ,opr.dtrisco_rating
          ,opr.dtrisco_rating + DECODE(nvl(opr.innivel_rating,2)
                                      ,1,nvl(tpg.qtdias_atualizacao_autom_baixo,0)
                                      ,2,nvl(tpg.qtdias_atualizacao_autom_medio,0)
                                      ,3,nvl(tpg.qtdias_atualizacao_autom_alto,0)) dtvencto_risco
          ,opr.dtrisco_rating_autom + nvl(tpg.qtmeses_expiracao_nota,0) dtexpiracao
                              -- Apesar de "meses", é "dias"
      FROM tbrisco_operacoes opr
          ,crapass           ass
          ,tbrat_param_geral tpg
     WHERE opr.cdcooper       = pr_cdcooper
       AND opr.nrcpfcnpj_base = pr_nrdconta -- Quando pre-aprovado, este parametro vem ocpfcnpj base
       AND opr.tpctrato  = 68
       AND ass.cdcooper  = opr.cdcooper
       AND ass.nrdconta  = opr.nrdconta
       AND tpg.cdcooper  = ass.cdcooper
       AND tpg.inpessoa  = ass.inpessoa
       AND tpg.tpproduto = 90
       AND pr_tpctrato   = 68;
  rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

  -- VARIAVEIS
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);
  vr_exc_saida    EXCEPTION;
  vr_exc_erro     EXCEPTION;
  vr_tem_operacao BOOLEAN:=FALSE;

  BEGIN
    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Status do Rating
    pr_strating := 0;
    pr_flgrating := 0;

    -- De ultima hora: se cooperativa for 3-Ailos, nao critica ausencia de rating
    IF pr_cdcooper = 3 THEN
      pr_strating  := 9; -- Nao valida status
      pr_flgrating := 1; -- Status rating valido
      RAISE vr_exc_saida;
    END IF;

    -- Verificar o risco do rating
    OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpctrato => pr_tpctrato
                             ,pr_nrctrato => pr_nrctrato);
    FETCH cr_tbrisco_operacoes
      INTO rw_tbrisco_operacoes;

    vr_tem_operacao := cr_tbrisco_operacoes%FOUND;
    pr_strating     := nvl(rw_tbrisco_operacoes.insituacao_rating,0);

    CLOSE cr_tbrisco_operacoes;

    IF  pr_strating <> 2  -- Analisado
    AND pr_strating <> 3  -- Vencido
    AND pr_strating <> 4  -- Efetivo
    AND pr_strating <> 9 THEN -- 9 - Nao valida rating
      pr_flgrating := 0; -- status rating invalido
    ELSE
      IF vr_tem_operacao THEN
        -- Validar a Expiração do Rating Analisado
        IF rw_crapdat.dtmvtolt > rw_tbrisco_operacoes.dtexpiracao
        AND ((pr_strating <= 2)
         OR  (pr_strating  = 3 AND rw_tbrisco_operacoes.dtrisco_rating IS NULL)) THEN
          pr_strating := 0;
          -- Se já passou da Expiração, Rating invalido
          pr_flgrating := 0; --status rating invalido
          pr_dscritic := 'Contrato nao pode ser efetivado, Rating vencido. '||
                         'Necessario refazer o calculo do Rating';
        ELSE
          -- Se nao passou da Expiração, valida Vencimento
          --Validar Data de Vencimento do Rating
          IF (rw_crapdat.dtmvtolt > rw_tbrisco_operacoes.dtvencto_risco AND pr_strating = 4)
          OR (pr_strating  = 3 AND rw_tbrisco_operacoes.dtrisco_rating IS NOT NULL)  THEN
            pr_strating  := 3;
            pr_flgrating := 0; --status rating invalido
            pr_dscritic  := 'Contrato nao pode ser efetivado, Rating vencido';
          ELSE
            pr_flgrating := 1; --status rating valido
          END IF;
        END IF;
        
        -- 03/09/2019 - Se contrato de pré-aprovado e modelo Rating = Aimaro e status vencido
        -- alterar o retorno do status para 4 para liberar o limite e passar na empr0002
        IF pr_tpctrato = 68
        AND fn_retorna_modelo_rating(pr_cdcooper => pr_cdcooper) = 1
        AND pr_strating = 3 THEN
          pr_strating := 6;-- 6-Modelo Aimaro gravado em contingência
        END IF;
      ELSE
        pr_flgrating := 0; --status rating invalido
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina RATI0003.pc_busca_status_rating '||SQLERRM;

  END pc_busca_status_rating;


 PROCEDURE pc_busca_rat_contigencia( pr_cdcooper IN INTEGER,
                                    pr_nrcpfcgc IN INTEGER,-- CNPJ BASE
                                    pr_innivris OUT INTEGER,
                                    pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                    pr_dscritic OUT VARCHAR2) IS
  /* ..........................................................................

  Programa: pc_busca_rat_contigencia
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Daniele Rocha
  Data    : Março/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Tipo de busca que recebe o cnpj base e devolve o nivel do risco rating

  Alteracoes:

  ............................................................................. */


    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_data_refere DATE;
    vr_rating      INTEGER;
    -- BUSCA TODOS AS CONTAS PARA O CNPJ BASE PASSADO POR PARAMETRO
    CURSOR cr_crapass IS
      SELECT nrdconta, nrcpfcgc, nrcpfcnpj_base
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrcpfcnpj_base = pr_nrcpfcgc;
    rw_crapass cr_crapass%rowtype;

    -- BUSCA O MAIOR RATING DE CADA CPF DO nrcpfcnpj_base
    CURSOR cr_busca_risco(pr_data_refere  IN DATE,
                          pr_nrdconta     IN INTEGER ) is
      SELECT MAX(ris.inrisco_final) AS innivris
        FROM tbrisco_central_ocr ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.DTREFERE = pr_data_refere
         AND ris.NRDCONTA = pr_nrdconta;
    rw_busca_risco cr_busca_risco%ROWTYPE;
  BEGIN

    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Data para Central Anterior
    IF to_char(rw_crapdat.dtmvtoan, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM') THEN
      vr_data_refere := rw_crapdat.dtmvtoan;
    ELSE
      vr_data_refere := rw_crapdat.dtultdma;
    END IF;

    --
    vr_rating := 0;
    -- ABRE CURSOR QUE BUSCA TODOS CPFS DO nrcpfcnpj_base
    FOR rw_crapass IN cr_crapass LOOP
      -- PARA CADA CPF LIGADO AO nrcpfcnpj_base VAI BUSCAR O MAIOR VALOR DO RATING
      FOR rw_busca_risco IN cr_busca_risco(pr_data_refere     => vr_data_refere,
                                           pr_nrdconta        => rw_crapass.nrdconta ) LOOP
        -- SE EXISTIR MAIOR VALOR ENTÃO FICARÁ COM VALOR DO RATING
        IF vr_rating <  rw_busca_risco.innivris THEN
           vr_rating := rw_busca_risco.innivris;
        END IF;
      END LOOP;
    END LOOP;
    IF vr_rating = 0 THEN -- SE RETORNAR ZERO QUER DIZER QUE NAO TEVE DADOS ENTÃO RETORNAR 2 = A
      vr_rating := 2;
    END IF;

    IF vr_rating = 10 THEN -- SE RETORNAR 10(HH), ASSUME 9 (H)
      vr_rating := 9;
    END IF;

    pr_innivris := vr_rating;
  END pc_busca_rat_contigencia;

  FUNCTION fn_busca_rating_efetivado(pr_cdcooper IN INTEGER,
                                     pr_nrdconta IN INTEGER,
                                     pr_nrctro   IN INTEGER,
                                     pr_tpctrato IN INTEGER,
                                     pr_cdcritic OUT PLS_INTEGER, --> codigo da critica
                                     pr_dscritic OUT VARCHAR2) RETURN NUMBER IS

    /* .............................................................................

     programa: fn_rating_efetivado
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
      SELECT oper.inrisco_rating_autom
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
    -- variaveis do CURSOR
    vr_inrisco_rating tbrisco_operacoes.inrisco_rating%type;

  BEGIN

    -- busco informações de operações
    OPEN cr_operacoes(vr_cdcooper => pr_cdcooper,
                      vr_nrdconta => pr_nrdconta,
                      vr_tpctrato => pr_tpctrato,
                      vr_nrctremp => pr_nrctro);
    FETCH cr_operacoes
      INTO vr_inrisco_rating;
    CLOSE cr_operacoes;

    --se nao encontrou parametro
    IF vr_inrisco_rating IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Não encontrado rating efetivado para conta: ' ||
                     pr_nrdconta || ' Contrato: ' || pr_nrctro ||
                     ' Cooperativa: ' || pr_cdcooper;
      RAISE vr_exc_saida;
    END IF;
  RETURN(vr_inrisco_rating);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      RETURN(NULL);
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro Não esperado ' || sqlerrm || ' Conta: ' ||
                     pr_nrdconta || ' Contrato: ' || pr_nrctro ||
                     ' Cooperativa: ' || pr_cdcooper;
      RETURN(NULL);
  END;

  PROCEDURE pc_grava_rating_bordero(pr_cdcooper IN INTEGER,     --> Cooperativa
                                    pr_nrdconta IN INTEGER,     --> Conta
                                    pr_nrctro   IN INTEGER,     --> Contrato
                                    pr_tpctrato IN INTEGER,     --> 2 /*CRAPBDC*/,3 /*CRAPBDT*/)
                                    pr_nrborder IN INTEGER,     --> Número do bordero
                                    pr_cdoperad IN VARCHAR2,     --> operador
                                    pr_cdcritic OUT PLS_INTEGER,--> codigo da critica
                                    pr_dscritic OUT VARCHAR2) IS

  /* .............................................................................

   programa: pc_grava_rating_bordero
   sistema : seguros - cooperativa de credito
   autor   : daniele
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado

   objetivo  : Rotina recebe a chave das tabelas do borderô e gera registro na tabela de operações.

   alteracoes: 90     emprestimo/financiamento
                2     limite desconto cheque
                3     limite desconto título)
                1     contratos de limite de credito
               91     CHEQUE
               92     TITULO

                17/05/2019 - P450 - Gravar o rating da proposta no borderô (Heckmann - AMcom)
  ..............................................................................*/

  ----------->>> variaveis <<<--------
  -- variável de críticas
  vr_cdcritic              crapcri.cdcritic%type; --> cód. erro
  vr_dscritic              VARCHAR2(1000); --> desc. erro
  vr_busca_rating_contrato INTEGER;
  -- tratamento de erros
  vr_exc_saida             EXCEPTION;

  vr_tpctrato_bordero      INTEGER;
  vr_desc_rating_autom     VARCHAR2(2);
  pr_retxml                xmltype;

  ----------->>> CURSORES <<<--------
  --> Buscar o status do rating para passar na pc_grava_rating_operacao
  CURSOR cr_tbrisco_operacoes IS
  SELECT ope.*
    FROM tbrisco_operacoes ope
   WHERE ope.cdcooper = pr_cdcooper
     AND ope.nrdconta = pr_nrdconta
     AND ope.nrctremp = pr_nrctro
     AND ope.tpctrato = pr_tpctrato;
  rw_tbrisco_operacoes  cr_tbrisco_operacoes%ROWTYPE;

  --------------->>> SUB-ROTINA <<<-----------------
  --> Gerar Log da tela
  PROCEDURE pc_log_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_cdoperad IN crapope.cdoperad%TYPE,
                          pr_dscdolog IN VARCHAR2) IS
    vr_dscdolog VARCHAR2(500);
  BEGIN
    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    vr_dscdolog := to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ' ' ||
                   to_char(SYSDATE, 'HH24:MI:SS') || ' --> ' ||
                   ' --> ' || 'Operador ' || pr_cdoperad || ' ' ||
                   pr_dscdolog;

    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => vr_dscdolog,
                               pr_nmarqlog     => 'gravaratingbordero.log',
                               pr_flfinmsg     => 'N');
  END;


BEGIN
 -- validar as criticas e os logs !!!
  -- Busca a data do sistema
  OPEN btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  IF pr_tpctrato = 2 /*CRAPBDC*/ THEN
      vr_tpctrato_bordero := 92;
  ELSIF  pr_tpctrato = 3  THEN/*'CRAPBDT'*/
      vr_tpctrato_bordero := 91;
  END IF;

  IF pr_tpctrato NOT IN (2 /*CRAPBDC*/,3 /*CRAPBDT*/) THEN
     vr_cdcritic := 0;
     vr_dscritic := 'Erro ocorrido na rotina Grava Rating Borderô. Passagem Parâmetro: '||pr_tpctrato||' para o Borderô! ';
     RAISE vr_exc_saida;
  END IF;

    OPEN cr_tbrisco_operacoes;
    FETCH cr_tbrisco_operacoes INTO rw_tbrisco_operacoes;
    CLOSE cr_tbrisco_operacoes;

  -- SE OCORREU ERRO DENTRO DA ROTINA QUE BUSCA O RATING EFETIVADO CAI NA EXCESSÃO
  -- OU SE NÃO TEM INFORMAÇÃO DO RATING PARA TAL CONTRATO
    IF vr_cdcritic > 0
      OR TRIM(vr_dscritic) IS NOT NULL
      OR rw_tbrisco_operacoes.inrisco_rating_autom IS NULL
      OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    RATI0003.pc_grava_rating_operacao(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_tpctrato => vr_tpctrato_bordero
                                     ,pr_nrctrato => pr_nrborder
                                     ,pr_ntrating => rw_tbrisco_operacoes.inrisco_rating
                                     ,pr_ntrataut => rw_tbrisco_operacoes.inrisco_rating_autom
                                     ,pr_dtrating => rw_tbrisco_operacoes.dtrisco_rating
                                     ,pr_strating => rw_tbrisco_operacoes.insituacao_rating
                                     ,pr_orrating => rw_tbrisco_operacoes.inorigem_rating
                                     ,pr_cdoprrat => rw_tbrisco_operacoes.cdoperad_rating
                                     ,pr_dtrataut => rw_tbrisco_operacoes.dtrisco_rating_autom
                                     ,pr_innivel_rating     => rw_tbrisco_operacoes.innivel_rating
                                     ,pr_nrcpfcnpj_base     => rw_tbrisco_operacoes.nrcpfcnpj_base
                                     ,pr_inpontos_rating    => rw_tbrisco_operacoes.inpontos_rating
                                     ,pr_insegmento_rating  => rw_tbrisco_operacoes.insegmento_rating
                                     ,pr_inrisco_rat_inc    => rw_tbrisco_operacoes.inrisco_rat_inc
                                     ,pr_innivel_rat_inc    => rw_tbrisco_operacoes.innivel_rat_inc
                                     ,pr_inpontos_rat_inc   => rw_tbrisco_operacoes.inpontos_rat_inc
                                     ,pr_cdoperad           => '1'
                                     ,pr_dtmvtolt           => rw_crapdat.dtmvtolt
                                     ,pr_valor              => NULL
                                     ,pr_rating_sugerido    => NULL
                                     ,pr_justificativa      => NULL
                                     ,pr_tpoperacao_rating  => NULL
                                     ,pr_cdcritic           => vr_cdcritic
                                     ,pr_dscritic           => vr_dscritic);

   IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := vr_dscritic || ' Erro ao Registar Operacoes ' ||
                     ' Cooperativa = ' || pr_cdcooper || ' Conta = ' ||
                     pr_nrdconta || ' Bordero = ' || pr_nrborder || SQLERRM;
      RAISE vr_exc_saida;
  END IF;

--COMMIT; -- DESCOMENTAR PARA TESTES UNITARIOS
EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;

      pc_log_bordero(pr_cdcooper => pr_cdcooper
                    ,pr_cdoperad => pr_cdoperad
                    ,pr_dscdolog => pr_dscritic);

  WHEN OTHERS THEN
   vr_dscritic := SQLERRM;
      pc_log_bordero(pr_cdcooper => pr_cdcooper
                    ,pr_cdoperad => pr_cdoperad
                    ,pr_dscdolog => vr_dscritic);


END pc_grava_rating_bordero;

  PROCEDURE pc_mostra_rating_bordero(pr_nrdconta IN INTEGER, --> Conta
                                   pr_cheq_tit IN CHAR, --> C /*CRAPBDC*/,T /*CRAPBDT*/)
                                   pr_nrborder IN INTEGER, --> Número do bordero
                                   pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                   pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                   pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                   pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                   pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                   pr_des_erro OUT VARCHAR2) IS
  /*..............................................................................*/
  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  vr_tpctrato INTEGER;
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
  vr_desc_rating VARCHAR2(2);
  vr_inrisco_rating INTEGER;
  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_cdoperad       VARCHAR2(100);
  vr_nmdatela       VARCHAR2(100);
  vr_nmeacao        VARCHAR2(100);
  vr_cdagenci       VARCHAR2(100);
  vr_nrdcaixa       VARCHAR2(100);
  vr_idorigem       VARCHAR2(100);
  vr_incontingencia INTEGER;
  vr_cooperativa    INTEGER;
  -- paramentro a mais retornado xml para servir como parametro da consulta

  ---------->> CURSORES <<--------
  CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER,
                      vr_tpctrato IN INTEGER,
                      vr_nrctremp IN INTEGER) IS
    SELECT oper.inrisco_rating_autom
      FROM tbrisco_operacoes oper
     WHERE oper.tpctrato = vr_tpctrato
       AND oper.cdcooper = vr_cdcooper
       AND oper.nrdconta = vr_nrdconta
       AND oper.nrctremp = vr_nrctremp;
  rw_operacoes cr_operacoes%ROWTYPE;

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
  IF pr_cheq_tit = 'T' THEN
    vr_tpctrato := 91;
  ELSIF pr_cheq_tit = 'C' THEN
    vr_tpctrato := 92;
  ELSE
    vr_dscritic := 'Erro ao busar Rating do Borderô. Parâmetro não encontrado '||pr_cheq_tit;
    RAISE vr_exc_saida;
  END IF;
  -- busco informações de operações
  OPEN cr_operacoes(vr_cdcooper => vr_cdcooper,
                    vr_nrdconta => pr_nrdconta,
                    vr_tpctrato => vr_tpctrato,
                    vr_nrctremp => pr_nrborder);
  FETCH cr_operacoes
    INTO vr_inrisco_rating;
  CLOSE cr_operacoes;

  --se nao encontrou parametro
  IF vr_inrisco_rating IS NULL THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Não encontrato rating efetivado para conta: ' ||
                   pr_nrdconta || ' Boderô: ' || pr_nrborder ||
                   ' Cooperativa: ' || vr_cdcooper;
    RAISE vr_exc_saida;
  END IF;


  BEGIN
    vr_desc_rating := cecred.risc0004.fn_traduz_risco(vr_inrisco_rating);
  EXCEPTION
    WHEN OTHERS THEN
       vr_dscritic := 'Erro ao traduzir o risco do Rating !';
        RAISE vr_exc_saida;
  END;
  -- PASSA OS DADOS PARA O XML RETORNO
  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  -- Insere as tags
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => 0,
                         pr_tag_nova => 'inf',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  -- campos
  -- 1   cooperativa
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'vr_cdcooper',
                         pr_tag_cont => to_char(vr_cdcooper),
                         pr_des_erro => vr_dscritic);
  -- 2 Conta
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrdconta',
                         pr_tag_cont => to_char(pr_nrdconta),
                         pr_des_erro => vr_dscritic);
  -- 3 Cheque/titulo
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_cheq_tit',
                         pr_tag_cont => to_char(pr_cheq_tit),
                         pr_des_erro => vr_dscritic);
  -- 4 numero bordero
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrborder',
                         pr_tag_cont => to_char(pr_nrborder),
                         pr_des_erro => vr_dscritic);
  -- 4 rating bordero
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_rating',
                         pr_tag_cont => to_char(vr_desc_rating),
                         pr_des_erro => vr_dscritic);

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
    -- Existe para satisfazer exigência da interface.
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
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
    ROLLBACK;
END pc_mostra_rating_bordero;

PROCEDURE pc_consultar_risco_rating(pr_nrdconta IN INTEGER, --> CONTA
                                    pr_nrctro   IN INTEGER, --CONTRATO
                                    pr_tpctro   IN INTEGER,
                                    pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                    pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                    pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                    pr_des_erro OUT VARCHAR2) IS

    /*..............................................................................*/
  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  vr_tpctrato INTEGER;
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_cdoperad       VARCHAR2(100);
  vr_nmdatela       VARCHAR2(100);
  vr_nmeacao        VARCHAR2(100);
  vr_cdagenci       VARCHAR2(100);
  vr_nrdcaixa       VARCHAR2(100);
  vr_idorigem       VARCHAR2(100);
  vr_incontingencia INTEGER;
  vr_cooperativa    INTEGER;
  -- paramentro a mais retornado xml para servir como parametro da consulta

  ---------->> CURSORES <<--------
  CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER,
                      vr_tpctrato IN INTEGER,
                      vr_nrctremp IN INTEGER) IS
    SELECT oper.inrisco_rating_autom,
       decode(oper.inorigem_rating,1,'MOTOR',2,'ESTEIRA',3,'REGRA AIMARO',4,'CONTINGÊNCIA') origem_rating,
       decode(oper.insituacao_rating, 0,'NAO ENVIADO', 1, 'EM ANALISE', 2 ,'ANALISADO', 3, 'VENCIDO', 4, 'EFETIVADO', 5, 'EM CONTINGENCIA') desc_sit
      FROM tbrisco_operacoes oper
     WHERE oper.tpctrato = vr_tpctrato
       AND oper.cdcooper = vr_cdcooper
       AND oper.nrdconta = vr_nrdconta
       AND oper.nrctremp = vr_nrctremp;
  rw_operacoes cr_operacoes%ROWTYPE;

  vr_origem_rating  VARCHAR2(100);
  vr_desc_sit       VARCHAR2(100);
  vr_desc_rating    VARCHAR2(2);
  vr_inrisco_rating INTEGER;
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

  -- busco informações de operações
  OPEN cr_operacoes(vr_cdcooper => vr_cdcooper,
                    vr_nrdconta => pr_nrdconta,
                    vr_tpctrato => pr_tpctro,
                    vr_nrctremp => pr_nrctro);
  FETCH cr_operacoes
    INTO vr_inrisco_rating, vr_origem_rating, vr_desc_sit ;
  CLOSE cr_operacoes;

  --se nao encontrou parametro


  BEGIN
    vr_desc_rating := cecred.risc0004.fn_traduz_risco(vr_inrisco_rating);
  EXCEPTION
    WHEN OTHERS THEN
       vr_dscritic := 'Erro ao traduzir o risco do Rating !';
        RAISE vr_exc_saida;
  END;
  -- PASSA OS DADOS PARA O XML RETORNO
  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  -- Insere as tags
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => 0,
                         pr_tag_nova => 'inf',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  -- campos
  -- 1   cooperativa
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'vr_cdcooper',
                         pr_tag_cont => to_char(vr_cdcooper),
                         pr_des_erro => vr_dscritic);
  -- 2 Conta
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrdconta',
                         pr_tag_cont => to_char(pr_nrdconta),
                         pr_des_erro => vr_dscritic);

    -- 3 Contrato
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrctro',
                         pr_tag_cont => to_char(pr_nrctro),
                         pr_des_erro => vr_dscritic);


  -- 4 tipo contrato
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_tpctro',
                         pr_tag_cont => to_char(pr_tpctro),
                         pr_des_erro => vr_dscritic);
  -- 5 Origem Rating
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_origem_rating',
                         pr_tag_cont => to_char(vr_origem_rating),
                         pr_des_erro => vr_dscritic);
  -- 6 descrição Situação
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_desc_sit',
                         pr_tag_cont => to_char(vr_desc_sit),
                         pr_des_erro => vr_dscritic);

  -- 7 descrição Rating
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_desc_rating',
                         pr_tag_cont => to_char(vr_desc_rating),
                         pr_des_erro => vr_dscritic);

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
    -- Existe para satisfazer exigência da interface.
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
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
    ROLLBACK;
END pc_consultar_risco_rating;


PROCEDURE pc_busca_dados_rating_inclusao(pr_cdcooper            IN INTEGER, -- COOPERATIVA CAMPO OBRIGATÓRIO
                                         pr_nrdconta            IN INTEGER, -- CONTA       CAMPO OBRIGATÓRIO
                                         pr_nrctro              IN INTEGER, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
                                         pr_tpctrato            IN INTEGER, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                         pr_des_inrisco_rat_inc OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° RATING   DO CONTRATO DA CONTA
                                         pr_inpontos_rat_inc    OUT INTEGER, -- SERÁ DEVOLVIDO 1° PONTOS   DO CONTRATO DA CONTA
                                         pr_innivel_rat_inc     OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° NIVEL    DO CONTRATO DA CONTA
                                         pr_insegmento_rat_inc  OUT VARCHAR2, -- SERÁ DEVOLVIDO 1° SEGMENTO DO CONTRATO DA CONTA
                                         pr_vlr                 OUT crapepr.vlemprst%type,
                                         pr_qtdreg              OUT INTEGER,
                                         pr_nrctro_out          OUT INTEGER, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
                                         pr_tpctrato_out        OUT INTEGER, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                         pr_retxml_clob         OUT CLOB, -- XML COM TODOS OS CONTRATOS/TIPOS DA CONTA
                                         pr_cdcritic            OUT PLS_INTEGER, --> codigo da critica
                                         pr_dscritic            OUT VARCHAR2) IS

  /* .............................................................................

   programa: pc_busca_dados_Rating_inclusao
   sistema : seguros - cooperativa de credito
   autor   : daniele
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado

   objetivo  : rotina para apresentar
   Nota Rating(inrisco_rat_inc),
   Pontuação Rating(inpontos_rat_inc),
   Risco Rating(innivel_rat_inc),
   Segmento (insegmento_rat_inc).

   Observações: 90     emprestimo/financiamento
                 2     limite desconto cheque
                 3     limite desconto título)
                 1     contratos de limite de credito
  ..............................................................................*/


  CURSOR cr_operacoes(vr_cdcooper IN INTEGER
                     ,vr_nrdconta IN INTEGER
                     ,vr_tpctrato IN INTEGER
                     ,vr_nrctremp IN INTEGER) IS
    SELECT nrctremp
          ,tpctrato
          ,inrisco_rating_autom  inrisco_rat_inc
          ,inpontos_rating       inpontos_rat_inc
          ,decode(innivel_rating, 1, 'Baixo', 2, 'Medio', 3, 'Alto') innivel_rat_inc
          ,insegmento_rating      insegmento_rat_inc
      FROM tbrisco_operacoes
     WHERE tpctrato = nvl(vr_tpctrato, tpctrato)
       AND cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND nrctremp = nvl(vr_nrctremp, nrctremp);

  CURSOR cr_emprestimosfinan(vr_cdcooper IN INTEGER
                            ,vr_nrdconta IN INTEGER
                            ,vr_nrctremp IN INTEGER) IS
    SELECT wepr.vlemprst AS valor -- validado tela principal.php /tab_prestacoes.php
      FROM cecred.crapepr wepr
     WHERE wepr.nrdconta = vr_nrdconta
       AND wepr.nrctremp = vr_nrctremp
       AND wepr.cdcooper = vr_cdcooper;

  CURSOR cr_limite_cred(vr_cdcooper IN INTEGER
                       ,vr_nrdconta IN INTEGER
                       ,vr_nrctremp IN INTEGER
                       ,vr_tipo     IN INTEGER) IS
    SELECT lim.vllimite AS valor
      FROM craplim lim
     WHERE lim.insitlim = 2
       AND lim.tpctrlim = vr_tipo /*tbgen_dominio_campo: limite desconto */
       AND lim.nrdconta = vr_nrdconta
       AND lim.nrctrlim = vr_nrctremp
       AND lim.cdcooper = vr_cdcooper;

  ----------->>> variaveis <<<--------
  -- variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
  vr_dscritic            VARCHAR2(1000); --> desc. erro

  -- tratamento de erros
  vr_exc_saida           EXCEPTION;
  -- variaveis do CURSOR
  vr_des_inrisco_rat_inc VARCHAR2(2);
  vr_inrisco_rat_inc     INTEGER;
  vr_inpontos_rat_inc    INTEGER;
  vr_innivel_rat_inc     VARCHAR2(100);
  vr_insegmento_rat_inc  VARCHAR2(100);
  vr_nrctremp            INTEGER;
  vr_tpctrato            INTEGER;
  pr_xml_res             CLOB;
  vr_valor               crapepr.vlemprst%TYPE;
  vr_retxml              xmltype;
  vr_contador            INTEGER := 0; -- Contador para inserção dos dados no XML
  --Variaveis Locais
  vr_qtregist           INTEGER := 0;
  vr_clob               CLOB;
  vr_xml_temp           VARCHAR2(32726) := '';
  vr_qtdreg             INTEGER := 0;
BEGIN

  ------------------------------------------------------------------------
  -- se for recebido parametro chave, retornará uma linha apenas, se for
  -- retornar mais de um registro as variaveis receberão a primeira linha
  -- e o xml receberá todos os registros
  -----------------------------------------------------------------------
  -- Monta documento XML de ERRO
  dbms_lob.createtemporary(vr_clob, TRUE);
  dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

  -- Criar cabeçalho do XML
  vr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
  -- Loop principal que traz os contratos ativos de emprestimos do cooperado
  FOR rw_operacoes IN cr_operacoes(vr_cdcooper => pr_cdcooper,
                                   vr_nrdconta => pr_nrdconta,
                                   vr_tpctrato => pr_tpctrato,
                                   vr_nrctremp => pr_nrctro) LOOP
    -- BUSCO A DESCRIÇÃO NO IN RISCO
    BEGIN
      vr_des_inrisco_rat_inc := cecred.risc0004.fn_traduz_risco(rw_operacoes.inrisco_rat_inc);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao traduzir o risco do rating ' ||
                       vr_inrisco_rat_inc || ' para conta: ' || pr_nrdconta ||
                       ' Contrato: ' || pr_nrctro || ' Cooperativa: ' ||
                       pr_cdcooper;
        RAISE vr_exc_saida;
    END;
    -- BUSCO A INFORMAÇÃO VALOR
    IF rw_operacoes.tpctrato = 90 THEN
      OPEN cr_emprestimosfinan(vr_cdcooper => pr_cdcooper,
                               vr_nrdconta => pr_nrdconta,
                               vr_nrctremp => rw_operacoes.nrctremp);

      FETCH cr_emprestimosfinan
        INTO vr_valor;
      CLOSE cr_emprestimosfinan;
      -- se for limite de credito, cheque ou titulo buscara do limite de crédito
    ELSIF rw_operacoes.tpctrato IN (1, 2, 3) THEN
      OPEN cr_limite_cred(vr_cdcooper => pr_cdcooper,
                          vr_nrdconta => pr_nrdconta,
                          vr_nrctremp => rw_operacoes.nrctremp,
                          vr_tipo     => rw_operacoes.tpctrato);
      FETCH cr_limite_cred
        INTO vr_valor;
      CLOSE cr_limite_cred;

    END IF;

    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'linha', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'cdcooper', pr_tag_cont => to_char(pr_cdcooper), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'nrdconta', pr_tag_cont => to_char(pr_nrdconta), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'tpctrato', pr_tag_cont => to_char(rw_operacoes.tpctrato||' '), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'nrctro', pr_tag_cont => to_char( rw_operacoes.nrctremp||' '), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'des_inrisco_rat_inc', pr_tag_cont => vr_des_inrisco_rat_inc, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'inpontos_rat_inc', pr_tag_cont =>TO_CHAR(rw_operacoes.inpontos_rat_inc)||' ', pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'innivel_rat_inc', pr_tag_cont =>  TO_CHAR(rw_operacoes.innivel_rat_inc)||' ', pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'insegmento_rat_inc', pr_tag_cont => to_char(rw_operacoes.insegmento_rat_inc||' '), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'linha', pr_posicao  => vr_qtdreg, pr_tag_nova => 'vlr', pr_tag_cont => to_char(vr_valor), pr_des_erro => vr_dscritic);


    vr_des_inrisco_rat_inc := vr_des_inrisco_rat_inc;
    vr_inpontos_rat_inc    := rw_operacoes.inpontos_rat_inc;
    vr_innivel_rat_inc     := rw_operacoes.innivel_rat_inc;
    vr_insegmento_rat_inc  := rw_operacoes.insegmento_rat_inc;
    vr_nrctremp            := rw_operacoes.nrctremp;
    vr_tpctrato            := rw_operacoes.tpctrato;

    vr_qtdreg := vr_qtdreg + 1;
  END LOOP;


  pr_retxml_clob := vr_retxml.getclobval();

  --Se ocorreu erro
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  pr_des_inrisco_rat_inc := vr_des_inrisco_rat_inc;
  pr_inpontos_rat_inc    := vr_inpontos_rat_inc;
  pr_innivel_rat_inc     := vr_innivel_rat_inc;
  pr_insegmento_rat_inc  := vr_insegmento_rat_inc;
  pr_nrctro_out          := vr_nrctremp;
  pr_tpctrato_out        := vr_tpctrato;
  pr_qtdreg              := vr_qtdreg;
  pr_vlr                 := vr_valor;
  pr_retxml_clob         := vr_retxml.getstringval();
EXCEPTION
  WHEN vr_exc_saida THEN
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro Não esperado ' || SQLERRM || ' Conta: ' ||
                   pr_nrdconta || ' Contrato: ' || pr_nrctro ||
                   ' Cooperativa: ' || pr_cdcooper;

END pc_busca_dados_rating_inclusao;


PROCEDURE pc_consulta_contratos_ativos(pr_cdcooper  IN crapass.cdcooper%TYPE
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                        ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_contratos_ativos
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Maio/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Pesquisa que retorna os contratos ativos do coooperado.

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --
    CURSOR cr_crapepr(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT epr.nrctremp ,
             epr.dtmvtolt ,
            'Emprest/Finac.' tpcontrato
        FROM crapepr epr
       WHERE epr.nrdconta = pr_nrdconta
         AND epr.cdcooper = pr_cdcooper
         AND epr.inliquid = 0
    UNION ALL
      SELECT lim.nrctrlim,
             lim.dtpropos as dtmvtolt,
             decode (lim.tpctrlim , 2 , 'Desconto Cheque',1,'Limite Credito',3, 'Desconto Título')tpcontrato
        FROM craplim lim
       WHERE lim.nrdconta = pr_nrdconta
         AND lim.cdcooper = pr_cdcooper
         AND lim.insitlim = 2
    ORDER BY 1         ;
    rw_crapepr cr_crapepr%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de linhas de crédito
--    vr_tab_linhas typ_tab_linhas;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_qtdreg   INTEGER;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;

    --Limpar tabela dados
    --vr_tab_linhas.DELETE;

    --Inicializar Variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    vr_qtdreg := 0;

    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><linhas>');

    -- Loop principal que traz os contratos ativos de emprestimos do cooperado
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<linha>'||
                                                   '  <nrcontrato>'||rw_crapepr.nrctremp||'</nrcontrato>'||
                                                   '  <dtmvtolt>'||TO_CHAR(rw_crapepr.dtmvtolt, 'DD/MM/YYYY')||'</dtmvtolt>'||
                                                   '  <tpcontrato>'||TO_CHAR(rw_crapepr.tpcontrato)||'</tpcontrato>'||
                                                   '</linha>');
       vr_qtdreg := vr_qtdreg + 1;
    END LOOP;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</linhas></Root>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'linhas'            --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtdreg           --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Retorno
    pr_des_erro:= 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_qualif_oper_web --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_contratos_ativos;


  --> Rotina para retornar quantidade de dias em atraso
  FUNCTION fn_obter_qtd_atr_Ext (pr_vl_prejuizo_ult48m IN NUMBER  --> Valor prejuizo 48 m
                                ,pr_vl_venc_180d       IN NUMBER  --> Valor vencimento 180 d
                                ,pr_vl_venc_120d       IN NUMBER  --> Valor vencimento 120 d
                                ,pr_vl_venc_90d        IN NUMBER  --> Valor vencimento 90 d
                                ,pr_vl_venc_60d        IN NUMBER  --> Valor vencimento 60 d
                                ,pr_vl_venc_30d        IN NUMBER  --> Valor vencimento 30 d
                                ,pr_vl_venc_15d        IN NUMBER) --> Valor vencimento 15 d
                                RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_qtd_atr_Ext
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar quantidade de dias em atraso

      Alteração :
    ..........................................................................*/
    vr_fn_qtd_atr_Ext NUMBER(3);

    BEGIN
      if    nvl(pr_vl_prejuizo_ult48m,0) > 0 then  vr_fn_qtd_atr_Ext := 999;
      elsif nvl(pr_vl_venc_180d,0) > 0 then vr_fn_qtd_atr_Ext := 181;
      elsif nvl(pr_vl_venc_120d,0) > 0 then vr_fn_qtd_atr_Ext := 121;
      elsif nvl(pr_vl_venc_90d,0)  > 0 then vr_fn_qtd_atr_Ext := 91;
      elsif nvl(pr_vl_venc_60d,0)  > 0 then vr_fn_qtd_atr_Ext := 61;
      elsif nvl(pr_vl_venc_30d,0)  > 0 then vr_fn_qtd_atr_Ext := 31;
      elsif nvl(pr_vl_venc_15d,0)  > 0 then vr_fn_qtd_atr_Ext := 15;
      else                                  vr_fn_qtd_atr_Ext := 0;
      end if;

      RETURN vr_fn_qtd_atr_Ext;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_qtd_atr_Ext;

  --> Rotina para retornar o percentual do limite de crédito utilizado
  FUNCTION fn_obter_Pc_Utiliz_limite (pr_vl_limite            IN NUMBER  --> Valor do limite utilizado
                                     ,pr_vl_limite_disponivel IN NUMBER) --> Valor do limite disponível
                                      RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_Pc_Utiliz_limite
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar o percentual do limite de crédito utilizado

      Alteração :
    ..........................................................................*/
    vr_Pc_Utiliz_limite NUMBER(18,6);

    BEGIN
      if pr_vl_limite > 0 then
         vr_Pc_Utiliz_limite := trunc((pr_vl_limite - nvl(pr_vl_limite_disponivel,0)) / pr_vl_limite,4);
      else
         vr_Pc_Utiliz_limite := 0;
      end if;
      RETURN vr_Pc_Utiliz_limite;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_Pc_Utiliz_limite;


  --> Rotina para retornar o percentual do limite de crédito rotativo utilizado
  FUNCTION fn_obter_Pc_Utiliz_lim_Rot (pr_vl_limite          IN NUMBER  --> Valor do limite utilizado
                                      ,pr_vl_saldo_devedor   IN NUMBER) --> Valor do saldo devedor
                                       RETURN NUMBER IS
  /* ..........................................................................
      Programa : fn_obter_Pc_Utiliz_limite
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Mário Bernat (Amcom)
      Data     : Março/2019.                   Ultima atualizacao: 08/03/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar o percentual do saldo devedor rotativo utilizado

      Alteração :
    ..........................................................................*/
    vr_Pc_Utiliz_saldo NUMBER(18,6);

    BEGIN
      if pr_vl_limite > 0 then
         vr_Pc_Utiliz_saldo := trunc((nvl(pr_vl_saldo_devedor,0) * 100 / pr_vl_limite) ,2);
      else
         vr_Pc_Utiliz_saldo := 0;
      end if;
      RETURN vr_Pc_Utiliz_saldo;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_obter_Pc_Utiliz_lim_Rot;

  --> Procedure para montar o JSON do Rating com as variáveis internas
  PROCEDURE pc_json_variaveis_rating(pr_cdcooper  IN crapass.cdcooper%TYPE
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE
                                    ,pr_flprepon  IN BOOLEAN DEFAULT FALSE
                                    ,pr_vlsalari  IN NUMBER  DEFAULT 0
                                    ,pr_persocio  IN NUMBER  DEFAULT 0
                                    ,pr_dtadmsoc  IN DATE    DEFAULT NULL
                                    ,pr_dtvigpro  IN DATE    DEFAULT NULL
                                    ,pr_tpprodut  IN NUMBER  DEFAULT 0
                                    ,pr_dsjsonvar OUT json
                                    ,pr_cdcritic  OUT NUMBER
                                    ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................

        Programa : pc_gera_json_pessoa_ass
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Lucas Reinert
        Data     : Maio/2017.                    Ultima atualizacao: 31/01/2019

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar todas as informações cadastrais
                    e das operações da conta parametrizada.

                    pr_tpprodut --> Tipo de produto (0 - Empréstimos e Financiamentos
                                                     1 - Desconto de Títulos
                                                     4 - Cartão de Crédito)

                   JSON   --> padrão para todos os ambientes, exceto o DEV2
                   PLJSON --> utilizar no ambiente DEV2

        Alteração : 23/01/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 relacionado ao empréstimo - (Fabio Adriano - AMcom)

                    28/01/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 relacionado ao desconto de título - (Fabio Adriano - AMcom)

                    13/03/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 utilizando CNPJ Raiz, Informação do BI e
                                 Geração de todas variáveis - (Mário Bernat - AMcom)

                    27/03/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 Inclusão das VARIAVEIS: qtatr_udmAvp12, Pc_CarRot_LimQo12 (Mário Bernat - AMcom)

                    17/04/2019 - P450 - Validações de todas as variáveis internas JSON juntamente
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

                    25/04/2019 - P450 - Validações variáveis internas JSON referente Sócios/Risco 30 dias
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

                    08/05/2019 - P450 - Validações variáveis internas JSON validar atraso independente da cooperativa
                                 com Usuário Diego Gomes - (Mário Bernat - AMcom)

    ..........................................................................*/
    DECLARE
      -- Variáveis para exceções
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_dscritaux VARCHAR2(200);
      vr_exc_saida EXCEPTION;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_exc_erro EXCEPTION;

      -- Declarar objetos Json necessários:
      vr_obj_generico  json := json();
      vr_obj_generic4  json := json(); -- Variáveis internas

      -- Variáveis auxiliares
      vr_dstextab craptab.dstextab%TYPE;
      vr_vlendivi NUMBER := 0;
      vr_qtprecal NUMBER(10) := 0;
      vr_inusatab BOOLEAN;
      vr_vltotpre NUMBER(25,4) := 0;
      vr_dtrefere_ris DATE;
      vr_ind     NUMBER(5) := 0;
      vr_nrdivisor NUMBER(2);
      vr_vlfatano NUMBER(18,4);
      vr_persocio   crapavt.persocio%TYPE;
      vr_qtdsocio   NUMBER(3);
      vr_nrcpf_socio_1 NUMBER(16) := 0;
      vr_nrcpf_socio_2 NUMBER(16) := 0;
      vr_nrcpf_socio_3 NUMBER(16) := 0;
      vr_nrcpf_socio_4 NUMBER(16) := 0;
      vr_nrcpf_socio_5 NUMBER(16) := 0;

      /* Tipo que compreende o registro da IBRATAN */
      vr_vl_max_limite            NUMBER(18,4);  --
      vr_qt_CarRotO12             NUMBER(5);     --
      vr_qt_totalQo12             NUMBER(8);     --
      vr_qt_CarRotQmp12           NUMBER(5);     --
      vr_qtd_atr_ExtQo3           NUMBER(5);     --
      vr_Pc_Utiliz_limiteAvg3     NUMBER(18,6);  --
      vr_PcQoPriOcCarRot_12       NUMBER(18,6);  --
      vr_Pc_CarRot_LimQo12        NUMBER(18,6);  --
      vr_qtatr_udmAvp12           NUMBER(18,6);  --

      vr_Pc_Utiliz_limiteMax12    NUMBER(18,6);  --
      vr_Pc_CarRot_LimAvg3        NUMBER(18,6);  --
      vr_Pc_CarRot_LimMax12       NUMBER(18,6);  --
      vr_vl_sld_devedor_totalNd3  NUMBER(18,4);  --
      vr_vl_sld_devedor_totalNd6  NUMBER(18,4);  --
      vr_vl_sld_devedor_totalNd12 NUMBER(18,4);  --
      vr_qtd_atr_ExtMax6          NUMBER(18,4);  --
      vr_qtd_atr_ExtMax12         NUMBER(18,4);  --
      vr_qtd_atr_ExtQo12          NUMBER(18,4);  --
      vr_qtatr_udmMax12           NUMBER(18,4);  --
      vr_qtatr_udmQo12            NUMBER(18,4);  --

      type vr_vl_limite_array          IS VARRAY(12) OF NUMBER(18,6);
      vr_vl_limite                     vr_vl_limite_array;

      type vr_Pc_Utiliz_limite_array   IS VARRAY(12) OF NUMBER(18,6);
      vr_Pc_Utiliz_limite              vr_Pc_Utiliz_limite_array;

      type vr_Pc_Utiliz_lim_CarRot_array IS VARRAY(12) OF NUMBER(18,6);
      vr_Pc_Utiliz_limite_CarRot       vr_Pc_Utiliz_lim_CarRot_array;

      type vr_vl_sld_devedor_rot_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_Rot            vr_vl_sld_devedor_rot_array;

      type vr_vl_sld_devedor_carrot_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_CarRot         vr_vl_sld_devedor_carrot_array;

      type vr_qtd_atr_Ext_array        IS VARRAY(12) OF  NUMBER(3);
      vr_qtd_atr_Ext                   vr_qtd_atr_Ext_array;

      type vr_vl_sld_devedor_total_array IS VARRAY(12) OF  NUMBER(18,6);
      vr_vl_sld_devedor_total          vr_vl_sld_devedor_total_array;

      type vr_qtatr_udm_array          IS VARRAY(12) OF  NUMBER(18,6);
      vr_qtatr_udm                     vr_qtatr_udm_array;

      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Busca no cadastro do associado:
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nrcpfcgc
              ,ass.cdagenci
              ,ass.dtnasctl
              ,ass.nrmatric
              ,ass.cdtipcta
              ,ass.cdsitdct
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,decode(ass.incadpos,1,'Nao Autorizado',2,'Autorizado','Cancelado') incadpos
              ,ass.dtelimin
              ,ass.inccfcop
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
              ,ass.inpessoa
              ,ass.dtcnscpf
              ,ass.cdsitcpf
              ,ass.cdclcnae
              ,ass.vllimcre
              ,ass.nmprimtl
              ,ass.dtmvtolt
              ,ass.dtadmiss
              ,ass.nrcpfcnpj_base
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar as informações do Arquivo SCR
      -- Conforme Orientação do Usuário Diego Gomes - abril/2019
      CURSOR cr_crapopf IS
        SELECT max(dtrefere) dtrefere
          FROM crapopf;
/*
       -- Não considerar CPF em função das contas inativas
       -- Conforme Orientação do Usuário Diego Gomes - abril/2019
        SELECT qtopesfn
              ,qtifssfn
              ,dtrefere
          FROM crapopf
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
         ORDER BY dtrefere DESC;
*/
      rw_crapopf cr_crapopf%ROWTYPE;

      -- Buscar os valores para as variáveis internas
      CURSOR cr_crapvopvi(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE,
                          pr_dtrefere IN crapvop.dtrefere%TYPE) IS
        SELECT SUM(CASE
                     WHEN cdvencto BETWEEN 310 AND 320 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_prejuizo_ult48m --Soma dos valores com fluxo de vencimento entre 310 e 320
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 255 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_180d --Soma dos valores com fluxo de vencimento entre 255 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 245 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_120d --Soma dos valores com fluxo de vencimento entre 245 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 240 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_90d --Soma dos valores com fluxo de vencimento entre 240 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 230 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_60d --Soma dos valores com fluxo de vencimento entre 230 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 220 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_30d --Soma dos valores com fluxo de vencimento entre 220 e 290
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 210 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_venc_15d --Soma dos valores com fluxo de vencimento entre 210 e 290
              ,SUM(CASE
                     WHEN ((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290
              ,SUM(CASE
                     WHEN ((cdvencto BETWEEN 20 AND 40) AND (cdmodali = 1901)) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_limite_disponivel --Soma dos valores com fluxo de vencimento entre 20 e 40 da modalidade 1901
              ,SUM(CASE
                     WHEN (((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) AND (cdmodali IN (101, 201, 213, 214, 204, 218, 210, 406, 1304))) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total_Rot --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290 das modalidades 101 201 213 214 204 218 210 406 1304
              ,SUM(CASE
                     WHEN (((cdvencto BETWEEN 60 AND 199) OR (cdvencto BETWEEN 205 AND 290)) AND (cdmodali IN (204, 218))) THEN
                      vlvencto
                     ELSE
                      0
                   END) vl_sld_devedor_total_CarRot --Soma dos valores com fluxo de vencimento entre 60 e 199 ou 205 e 290 das modalidade 204 218
          FROM crapvop
         WHERE nrcpfcgc = pr_nrcpfcgc
           AND dtrefere = pr_dtrefere; -- Conforme a necessidade de buscar as informações de meses anteriores, passar na variável ao abrir o cursor a data referência - 1 mês, - 2 meses, ...
      rw_crapvopvi     cr_crapvopvi%ROWTYPE;

      -- PJ/PF - Buscar o maior tempo de conta do sistema Ailos (CNPJ RAIZ)
      CURSOR cr_qtconta(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT FLOOR((pr_dtmvtolt - (ass.dtmvtolt ))/30) qtconta  --ass.dtabtcct
              ,nvl(ass.dtelimin,trunc(sysdate)) dtelimin
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrcpfcnpj_base IN (SELECT nrcpfcnpj_base
                                        FROM crapass x
                                       WHERE x.cdcooper = ass.cdcooper
                                         AND x.nrdconta = pr_nrdconta)
         ORDER BY dtelimin DESC, qtconta DESC;
      rw_qtconta cr_qtconta%ROWTYPE;

      -- PJ - Buscar o fatuamento para PJ do sistema Ailos (CNPJ RAIZ)
      -- Conforme Orientação do Usuário Diego Gomes - abril/2019
      CURSOR cr_vlfaturamento(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT COUNT(*) qt, SUM(y.vl) vl_tot FROM (
          SELECT x.dt, x.vl
            FROM (SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##1,'00')||TO_CHAR(ANOFTBRU##1,'0000'),'ddmmrrrr')) dt,VLRFTBRU##1 vl
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##1 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##2,'00')||TO_CHAR(ANOFTBRU##2,'0000'),'ddmmrrrr')) ,VLRFTBRU##2
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##2 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##3,'00')||TO_CHAR(ANOFTBRU##3,'0000'),'ddmmrrrr')) ,VLRFTBRU##3
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##3 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##4,'00')||TO_CHAR(ANOFTBRU##4,'0000'),'ddmmrrrr')) ,VLRFTBRU##4
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##4 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##5,'00')||TO_CHAR(ANOFTBRU##5,'0000'),'ddmmrrrr')) ,VLRFTBRU##5
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##5 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##6,'00')||TO_CHAR(ANOFTBRU##6,'0000'),'ddmmrrrr')) ,VLRFTBRU##6
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##6 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##7,'00')||TO_CHAR(ANOFTBRU##7,'0000'),'ddmmrrrr')) ,VLRFTBRU##7
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##7 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##8,'00')||TO_CHAR(ANOFTBRU##8,'0000'),'ddmmrrrr')) ,VLRFTBRU##8
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##8 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##9,'00')||TO_CHAR(ANOFTBRU##9,'0000'),'ddmmrrrr')) ,VLRFTBRU##9
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##9 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##10,'00')||TO_CHAR(ANOFTBRU##10,'0000'),'ddmmrrrr')) ,VLRFTBRU##10
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##10 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##11,'00')||TO_CHAR(ANOFTBRU##11,'0000'),'ddmmrrrr')) ,VLRFTBRU##11
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##11 > 0
            UNION SELECT LAST_DAY(to_date('01'||TO_CHAR(MESFTBRU##12,'00')||TO_CHAR(ANOFTBRU##12,'0000'),'ddmmrrrr')) ,VLRFTBRU##12
                    FROM crapjfn ff
                   WHERE ff.cdcooper=pr_cdcooper AND ff.nrdconta=pr_nrdconta AND MESFTBRU##12 > 0 ) x
          WHERE x.dt > ADD_MONTHS(pr_dtmvtolt, -36)
            AND x.vl > 100) y;
      rw_vlfaturamento cr_vlfaturamento%ROWTYPE;

      -- PJ/PF - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      -- Encaminhar para BI atualizar Coluna
/*
      --
      -- Query para efetuar carga no na tabela: TBCC_ASSOCIADOS
      --                                coluna: qtmax_atraso
      --
        select x.cdcooper
              ,x.qtmax_atraso
              ,x.nrdconta
              ,x.nrcpfcnpj_base
          from
               (select y.qtatr_max_ult30d  qtmax_atraso
                      ,y.nrdconta
                      ,y.nrcpfcnpj_base
                      ,y.cdcooper
                      ,row_number() over (partition By y.nrcpfcnpj_base, y.cdcooper
                                              order by y.qtatr_max_ult30d DESC) nrseqreg
                  from
                       (select max(ris.qtdiaatr) qtatr_max_ult30d
                              ,ris.nrdconta
                              ,ass.nrcpfcnpj_base
                              ,ass.cdcooper
                          FROM crapass  ass
                              ,crapris  ris
                              ,crapdat  dat
                         WHERE dat.cdcooper = 3
                           and ris.dtrefere between add_months(dat.dtmvtolt,-1) and dat.dtmvtolt
                           and ris.nrdconta = ass.nrdconta
                           and ris.cdcooper = ass.cdcooper
                         GROUP BY  nrcpfcnpj_base
                                  ,ris.nrdconta
                                  ,ass.cdcooper
                        having max(ris.qtdiaatr) > 0) y
               ) x
         where x.nrseqreg  = 1;
      -- ----------------------------------------
*/

      -- PJ/PF - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      CURSOR cr_qtatr_max_ult30d (pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
      select nvl(max(qtmax_atraso),0)  qtatr_max_ult30d
        FROM crapass          ass
            ,tbcc_associados  tbcc
       WHERE ass.cdcooper > 0
         and ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
         and tbcc.nrdconta = ass.nrdconta
         and tbcc.cdcooper = ass.cdcooper;
      rw_qtatr_max_ult30d cr_qtatr_max_ult30d%ROWTYPE;

      -- PF - Busca Idade / Diferença entre a data de nascimento do cadastro e a data da proposta em dias
      CURSOR cr_qtidade (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrcpfcgc IN crapass.NRCPFCGC%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        select pr_dtmvtolt - ass.dtnasctl qtidade
          from crapass ass
         where ass.cdcooper = pr_cdcooper
           and ass.nrcpfcgc = pr_nrcpfcgc
           and ass.inpessoa = 1
         order by 1 desc;
      rw_qtidade cr_qtidade%ROWTYPE;

      -- PF - Busca Quantidade de dias de atraso do ultimo dia do mês da ultima data base disponivel
      CURSOR cr_qtatr_udm (pr_nrcpfcgc   IN crapris.NRCPFCGC%TYPE
                          ,pr_dtbasedisp IN crapsda.dtmvtolt%type) IS
        select ris.dtrefere
              ,max(ris.qtdiaatr) qtatr_udm
          from crapris ris
              ,crapass ass
          where
               ass.nrcpfcgc = pr_nrcpfcgc
           and ass.inpessoa = 1
           --
           and ris.cdcooper = ass.cdcooper
           and ris.nrdconta = ass.nrdconta
           AND ris.dtrefere between last_day(add_months(pr_dtbasedisp,-12)) and pr_dtbasedisp
           and ris.qtdiaatr > 0
         group by ris.dtrefere
         order by ris.dtrefere desc;
      rw_qtatr_udm cr_qtatr_udm%ROWTYPE;

      -- flag_manutencao e flag_originação
      -- proposta de EMPRESTIMO
      CURSOR cr_flag_manut_orig (pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        select emp.dtmvtolt - epr.dtmvtolt qtdiasflag
          from crapepr emp
             , crawepr epr
          where emp.nrctremp = epr.nrctremp
            and emp.nrdconta = epr.nrdconta
            and emp.cdcooper = epr.cdcooper
            and emp.nrctremp = pr_nrctremp
            and emp.nrdconta = pr_nrdconta
            and emp.cdcooper = pr_cdcooper;
      rw_flag_manut_orig cr_flag_manut_orig%ROWTYPE;

      -- flag_manutencao e flag_originação
      -- proposta de DESCONTO DE TITULO
      CURSOR cr_flag_manut_orig_t (pr_cdcooper IN crapass.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
        select lim.dtpropos - pli.dtpropos qtdiasflag
          from craplim lim
             , crawlim pli
          where lim.nrctrlim = pli.nrctrlim
            and lim.nrdconta = pli.nrdconta
            and lim.cdcooper = pli.cdcooper
            and lim.nrctrlim = pr_nrctrlim
            and lim.nrdconta = pr_nrdconta
            and lim.cdcooper = pr_cdcooper;
      rw_flag_manut_orig_t cr_flag_manut_orig_t%ROWTYPE;

      -- PJ - Valor do ultimo faturamento anual disponivel
      CURSOR cr_crapjur_ibr (pr_cdcooper       IN crapass.cdcooper%TYPE
                            ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
        SELECT  max(jur.vlfatano) vlfatano
          FROM  crapjur jur
               ,crapass ass
         WHERE
               ass.cdcooper = pr_cdcooper
           and ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
           and ass.inpessoa = 2
           and jur.cdcooper = ass.cdcooper
           and jur.nrdconta = ass.nrdconta;
      rw_crapjur_ibr cr_crapjur_ibr%ROWTYPE;

      -- Buscar o maximo da quantidade de dias de atraso nos ultimos 30 dias anteriores
      --   ao dia proposta entre ate os 5 socios com maior participacao
      CURSOR cr_socqtatrmaxult30d(pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrcpfcgc_base_1 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_2 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_3 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_4 IN crapass.nrcpfcnpj_base%TYPE
                                 ,pr_nrcpfcgc_base_5 IN crapass.nrcpfcnpj_base%TYPE) IS
         SELECT nvl(max(tbcc.qtmax_atraso),0) qtdiaatr
                  FROM TBCC_ASSOCIADOS tbcc
                     , crapass ass
          WHERE ass.cdcooper > 0
            and ass.inpessoa = 1
            and ass.nrcpfcnpj_base in (pr_nrcpfcgc_base_1,pr_nrcpfcgc_base_2,pr_nrcpfcgc_base_3
                                      ,pr_nrcpfcgc_base_4,pr_nrcpfcgc_base_5)
                   and tbcc.nrdconta = ass.nrdconta
            and tbcc.cdcooper = ass.cdcooper;
       rw_socqtatrmaxult30d cr_socqtatrmaxult30d%ROWTYPE;

        -- Buscar o CPF do socio com maior participacao
       CURSOR cr_cpfsocio (pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrcpfcgc IN crapris.nrcpfcgc%TYPE) IS
        SELECT x.persocio
             , x.nrcpfcgc
             , ROW_NUMBER() OVER (PARTITION BY x.persocio ORDER BY x.persocio DESC) nrseqreg
          FROM (SELECT distinct
                       avt.persocio
                     , avt.nrcpfcgc
                  FROM crapavt avt
                      ,crapass ass
                 WHERE
                       ass.cdcooper = pr_cdcooper
                   and ass.inpessoa = 2
                   and ass.nrcpfcnpj_base = substr(to_char(pr_nrcpfcgc,'FM00000000000000'),1,8)
                   --
                   AND avt.cdcooper = ass.cdcooper
                   and avt.nrdconta = ass.nrdconta
                   and avt.persocio > 0
                   AND avt.tpctrato = 6
                   AND avt.nrctremp = 0  -- Deve ser zero para pegar a sociedade, se for diferente de zero é avalista
               ) x
           ORDER BY x.persocio DESC, nrseqreg;
       rw_cpfsocio cr_cpfsocio%ROWTYPE;

    -- ---------------------------------------------------------------
    BEGIN

      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Buscar informações cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;

      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Complemento de mensagem
      vr_dscritaux := 'Chama funcao juros';

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

      -- Buscar saldo devedor
      EMPR0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => 1               --> Codigo da agencia
                                    ,pr_nrdcaixa   => 0               --> Numero do caixa
                                    ,pr_cdoperad   => '1'             --> Codigo do operador
                                    ,pr_nmdatela   => 'ATENDA'        --> Nome datela conectada
                                    ,pr_idorigem   => 1 --Ayllos--    --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                    ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlendivi     --> Saldo devedor calculado
                                    ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacães
                                    ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                    ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                    ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

        -- Limpar tabela de erros
        vr_tab_erro.DELETE;

        RAISE vr_exc_saida;
      END IF;

      -- Novas variaveis internas para o Json
      vr_obj_generic4 := json();

      --Inicializa array
      vr_qtd_atr_Ext := vr_qtd_atr_Ext_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_limite   := vr_vl_limite_array   (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_Pc_Utiliz_limite := vr_Pc_Utiliz_limite_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_Pc_Utiliz_limite_CarRot := vr_Pc_Utiliz_lim_CarRot_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_Rot    := vr_vl_sld_devedor_rot_array    (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_CarRot := vr_vl_sld_devedor_carrot_array (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_vl_sld_devedor_total  := vr_vl_sld_devedor_total_array  (0,0,0,0,0,0,0,0,0,0,0,0);
      vr_qtatr_udm := vr_qtatr_udm_array (0,0,0,0,0,0,0,0,0,0,0,0);

      -- Variável Auxiliar utilizada somente em testes
      /*
      vr_obj_generic4.put('ID', 'VarInt' ||'_'|| pr_cdcooper
                                         ||'_'|| rw_crapass.dspessoa
                                         ||'_'|| rw_crapass.nrcpfcnpj_base
                                         ||'_'|| rw_crapass.nrdconta);
      */

      -- PF/PJ - Buscar o maior tempo de conta do sistema Ailos
      OPEN cr_qtconta(pr_cdcooper   --Cooperativa
                     ,rw_crapass.nrdconta
                     ,rw_crapdat.dtmvtolt);
      FETCH cr_qtconta
       INTO rw_qtconta;
      CLOSE cr_qtconta;
      vr_obj_generic4.put('QtConta',NVL(rw_qtconta.qtconta,0));

      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
         -- Utilizar o final do mês como data
         vr_dtrefere_ris := rw_crapdat.dtultdma;
      ELSE
         -- Utilizar a data atual
         --vr_dtrefere_ris := rw_crapdat.dtmvtoan;

         -- Utilizar somente posição de mês fechado,
         -- Conforme Orientação do Usuário Diego Gomes - abril/2019
         vr_dtrefere_ris := last_day(add_months(rw_crapdat.dtmvtolt,-1));
      END IF;

      -- Complemento de mensagem
      vr_dscritaux := 'Busca qtd maxima atraso';

      -- Buscar as informações do Arquivo SCR
      OPEN cr_crapopf;
      FETCH cr_crapopf
        INTO rw_crapopf;
      CLOSE cr_crapopf;

      -- PF/PJ - Busca Quantidade maxima de dias de atraso nos ultimos 30 dias anteriores ao dia proposta
      OPEN cr_qtatr_max_ult30d(pr_cdcooper
                              ,rw_crapass.nrcpfcnpj_base);
      FETCH cr_qtatr_max_ult30d
       INTO rw_qtatr_max_ult30d;
      CLOSE cr_qtatr_max_ult30d;
      vr_obj_generic4.put('qtatr_Max_Ult30d',NVL(rw_qtatr_max_ult30d.qtatr_max_ult30d,0));

      -- PF - Para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
        --Busca Idade / Diferença entre a data de nascimento do cadastro e a data da proposta em dias
        OPEN cr_qtidade(pr_cdcooper
                       ,rw_crapass.nrcpfcgc
                       ,rw_crapdat.dtmvtolt);
        FETCH cr_qtidade
         INTO rw_qtidade;
        CLOSE cr_qtidade;
        vr_obj_generic4.put('QtIdade',NVL(rw_qtidade.qtidade,0));

      -- Para Pessoas Juridicas
      ELSE
         -- PJ - Valor do ultimo faturamento anual disponivel
         --      Retirado Conforme Orientação do Usuário Diego Gomes - abril/2019
         /*
         OPEN cr_crapjur_ibr(pr_cdcooper,rw_crapass.nrcpfcnpj_base);
         FETCH cr_crapjur_ibr
          INTO rw_crapjur_ibr;
         CLOSE cr_crapjur_ibr;
         vr_obj_generic4.put('vl_faturamento_anual',este0001.fn_decimal_ibra(NVL(rw_crapjur_ibr.vlfatano,0)));
         */

         -- PJ - Buscar o valor do faturamento do sistema Ailos
         --      Conforme Orientação do Usuário Diego Gomes - abril/2019
         OPEN cr_vlfaturamento(pr_cdcooper
                              ,rw_crapass.nrdconta
                              ,rw_crapdat.dtmvtolt);
         FETCH cr_vlfaturamento
          INTO rw_vlfaturamento;
         CLOSE cr_vlfaturamento;

         if nvl(rw_vlfaturamento.qt,0) = 0 then
            vr_vlfatano := 0;
         else
            if nvl(rw_vlfaturamento.qt,0) = 12 then
               vr_vlfatano := nvl(rw_vlfaturamento.vl_tot,0);
            else
               vr_vlfatano := trunc(nvl(rw_vlfaturamento.vl_tot,0)
                                + ((nvl(rw_vlfaturamento.vl_tot,0) / nvl(rw_vlfaturamento.qt,0))
                                * (12 - nvl(rw_vlfaturamento.qt,0))),2);
            end if;
         end if;
         vr_obj_generic4.put('vl_faturamento_anual',este0001.fn_decimal_ibra(NVL(vr_vlfatano,0)));

         -- PJ - Buscar o CPF do socio com maior participacao
         vr_persocio := 0;
         vr_qtdsocio := 0;
         vr_nrcpf_socio_1 := 0;
         vr_nrcpf_socio_2 := 0;
         vr_nrcpf_socio_3 := 0;
         vr_nrcpf_socio_4 := 0;
         vr_nrcpf_socio_5 := 0;

         FOR rw_cpfsocio IN cr_cpfsocio (pr_cdcooper
                                        ,rw_crapass.nrcpfcgc) LOOP
           CASE
             WHEN rw_cpfsocio.nrseqreg = 1 and vr_persocio = 0 THEN
                vr_obj_generic4.put('cpf_socio_1',NVL(rw_cpfsocio.nrcpfcgc,0));
                vr_persocio := NVL(rw_cpfsocio.persocio,0);
                vr_nrcpf_socio_1 := NVL(rw_cpfsocio.nrcpfcgc,0);
                vr_qtdsocio := 1;
             WHEN rw_cpfsocio.nrseqreg = 2 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_2',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_2 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 2;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 3 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_3',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_3 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 3;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 4 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_4',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_4 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 4;
               END IF;
             WHEN rw_cpfsocio.nrseqreg = 5 THEN
               IF vr_persocio = NVL(rw_cpfsocio.persocio,0) THEN
                 vr_obj_generic4.put('cpf_socio_5',NVL(rw_cpfsocio.nrcpfcgc,0));
                 vr_nrcpf_socio_5 := NVL(rw_cpfsocio.nrcpfcgc,0);
                 vr_qtdsocio := 5;
               END IF;
             ELSE  NULL;
           END CASE;
         END LOOP;

         -- Utilizado apenas para teste pois Diego importa aruivo Json em planinha excel
         /*
         if vr_qtdsocio = 0 then
            vr_obj_generic4.put('cpf_socio_1',0);
            vr_obj_generic4.put('cpf_socio_2',0);
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 1 then
            vr_obj_generic4.put('cpf_socio_2',0);
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 2 then
            vr_obj_generic4.put('cpf_socio_3',0);
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 3 then
            vr_obj_generic4.put('cpf_socio_4',0);
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
         if vr_qtdsocio = 4 then
            vr_obj_generic4.put('cpf_socio_5',0);
         end if;
     */
         -- PJ - Buscar o maximo da quantidade de dias de atraso nos ultimos 30 dias anteriores
         --      ao dia proposta entre ate os 5 socios com maior participacao
         OPEN cr_socqtatrmaxult30d(pr_cdcooper
                                  ,vr_nrcpf_socio_1,vr_nrcpf_socio_2
                                  ,vr_nrcpf_socio_3,vr_nrcpf_socio_4,vr_nrcpf_socio_5);
         FETCH cr_socqtatrmaxult30d
          INTO rw_socqtatrmaxult30d;
         CLOSE cr_socqtatrmaxult30d;
         vr_obj_generic4.put('SocQtatrMaxUlt30d', este0001.fn_decimal_ibra(NVL(rw_socqtatrmaxult30d.qtdiaatr,0)));
      END IF;

      -- Buscar os valores dos vencimentos para alimentar as variáveis internas
      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, rw_crapopf.dtrefere);
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      -- Complemento de mensagem
      vr_dscritaux := 'Busca variaveis H';


      -- Buscar as informações para as variáveis H0

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN

         -- PF - Busca Quantidade de dias de atraso do ultimo dia do mês da ultima data base disponivel
         FOR rw_qtatr_udm IN cr_qtatr_udm(rw_crapass.nrcpfcgc
                                         ,vr_dtrefere_ris) LOOP
           vr_ind := 0;
           IF    rw_qtatr_udm.dtrefere = vr_dtrefere_ris     THEN  vr_ind := 1;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-1))  THEN  vr_ind := 2;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-2))  THEN  vr_ind := 3;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-3))  THEN  vr_ind := 4;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-4))  THEN  vr_ind := 5;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-5))  THEN  vr_ind := 6;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-6))  THEN  vr_ind := 7;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-7))  THEN  vr_ind := 8;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-8))  THEN  vr_ind := 9;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-9))  THEN  vr_ind := 10;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-10)) THEN  vr_ind := 11;
           ELSIF rw_qtatr_udm.dtrefere = last_day(add_months(vr_dtrefere_ris,-11)) THEN  vr_ind := 12;
           END IF;
           --
           if vr_ind > 0 THEN
              vr_qtatr_udm(vr_ind) := nvl(rw_qtatr_udm.qtatr_udm,0);
           END IF;
         END LOOP;
         vr_obj_generic4.put('qtatr_udm_h0',  este0001.fn_decimal_ibra(nvl(vr_qtatr_udm(1),0)));
      END IF;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h0', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      --qtd_atr_Ext_h0

       vr_qtd_atr_Ext(1) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h0', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(1)));

      vr_vl_limite(1) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h0', este0001.fn_decimal_ibra(vr_vl_limite(1)));

      vr_Pc_Utiliz_limite(1) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(1),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h0', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(1)));

      vr_Pc_Utiliz_limite_CarRot(1) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(1)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_vl_sld_devedor_total(1)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(1)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(1) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H1

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h1',  este0001.fn_decimal_ibra(vr_qtatr_udm(2)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-1));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h1', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(2) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h1', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(2)));

      vr_vl_limite(2) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h1', este0001.fn_decimal_ibra(vr_vl_limite(2)));

      vr_Pc_Utiliz_limite_CarRot(2) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(2)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(2) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(2),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h1', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(2)));

      vr_vl_sld_devedor_total(2)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(2)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(2) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H2

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h2',  este0001.fn_decimal_ibra(vr_qtatr_udm(3)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-2));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h2', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(3) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h2', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(3)));

      vr_vl_limite(3) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h2', este0001.fn_decimal_ibra(vr_vl_limite(3)));

      vr_Pc_Utiliz_limite_CarRot(3) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(3)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(3) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(3),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h2', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(3)));

      vr_vl_sld_devedor_total(3)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(3)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(3) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H3

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h3',  este0001.fn_decimal_ibra(vr_qtatr_udm(4)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-3));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h3', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(4) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h3', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(4)));

      vr_vl_limite(4) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h3', este0001.fn_decimal_ibra(vr_vl_limite(4)));

      vr_Pc_Utiliz_limite_CarRot(4) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(4)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(4) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(4),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h3', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(4)));

      vr_vl_sld_devedor_total(4)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(4)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(4) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H4

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h4',  este0001.fn_decimal_ibra(vr_qtatr_udm(5)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-4));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h4', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(5) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h4', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(5)));

      vr_vl_limite(5) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h4', este0001.fn_decimal_ibra(vr_vl_limite(5)));

      vr_Pc_Utiliz_limite_CarRot(5) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(5)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(5) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(5),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h4', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(5)));

      vr_vl_sld_devedor_total(5)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(5)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(5) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H5

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h5',  este0001.fn_decimal_ibra(vr_qtatr_udm(6)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-5));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h5', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(6) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h5', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(6)));

      vr_vl_limite(6) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h5', este0001.fn_decimal_ibra(vr_vl_limite(6)));

      vr_Pc_Utiliz_limite_CarRot(6) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(6)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(6) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(6),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h5', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(6)));

      vr_vl_sld_devedor_total(6)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(6)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(6) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H6

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h6',  este0001.fn_decimal_ibra(vr_qtatr_udm(7)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-6));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h6', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(7) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h6', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(7)));

      vr_vl_limite(7) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h6', este0001.fn_decimal_ibra(vr_vl_limite(7)));

      vr_Pc_Utiliz_limite_CarRot(7) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(7)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(7) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(7),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h6', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(7)));

      vr_vl_sld_devedor_total(7)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(7)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(7) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H7

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h7',  este0001.fn_decimal_ibra(vr_qtatr_udm(8)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-7));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h7', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(8) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h7', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(8)));

      vr_vl_limite(8) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h7', este0001.fn_decimal_ibra(vr_vl_limite(8)));

      vr_Pc_Utiliz_limite_CarRot(8) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(8)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(8) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(8),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h7', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(8)));

      vr_vl_sld_devedor_total(8)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(8)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(8) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H8

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h8',  este0001.fn_decimal_ibra(vr_qtatr_udm(9)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-8));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h8', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(9) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                               ,rw_crapvopvi.vl_venc_180d
                                               ,rw_crapvopvi.vl_venc_120d
                                               ,rw_crapvopvi.vl_venc_90d
                                               ,rw_crapvopvi.vl_venc_60d
                                               ,rw_crapvopvi.vl_venc_30d
                                               ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h8', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(9)));

      vr_vl_limite(9) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                       + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h8', este0001.fn_decimal_ibra(vr_vl_limite(9)));

      vr_Pc_Utiliz_limite_CarRot(9) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(9)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(9) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(9),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h8', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(9)));

      vr_vl_sld_devedor_total(9)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(9)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(9) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H9

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h9',  este0001.fn_decimal_ibra(vr_qtatr_udm(10)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-9));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h9', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(10) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h9', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(10)));

      vr_vl_limite(10) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h9', este0001.fn_decimal_ibra(vr_vl_limite(10)));

      vr_Pc_Utiliz_limite_CarRot(10) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(10)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(10) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(10),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h9', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(10)));

      vr_vl_sld_devedor_total(10)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(10)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(10) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H10

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h10',  este0001.fn_decimal_ibra(vr_qtatr_udm(11)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-10));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h10', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(11) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h10', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(11)));

      vr_vl_limite(11) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h10', este0001.fn_decimal_ibra(vr_vl_limite(11)));

      vr_Pc_Utiliz_limite_CarRot(11) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(11)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(11) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(11),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h10', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(11)));

      vr_vl_sld_devedor_total(11)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_Rot(11)    := nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_vl_sld_devedor_CarRot(11) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);


      -- Buscar as informações para as variáveis H11

      -- udm somente para Pessoas Fisicas
      IF rw_crapass.inpessoa = 1 THEN
         vr_obj_generic4.put('qtatr_udm_h11',  este0001.fn_decimal_ibra(vr_qtatr_udm(12)));
      END IF;

      OPEN cr_crapvopvi(rw_crapass.nrcpfcgc, add_months(rw_crapopf.dtrefere,-11));
      FETCH cr_crapvopvi
       INTO rw_crapvopvi;
      CLOSE cr_crapvopvi;

      vr_obj_generic4.put('vl_prejuizo_ult48m_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_prejuizo_ult48m,0)));
      vr_obj_generic4.put('vl_venc_180d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_180d,0)));
      vr_obj_generic4.put('vl_venc_120d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_120d,0)));
      vr_obj_generic4.put('vl_venc_90d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_90d,0)));
      vr_obj_generic4.put('vl_venc_60d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_60d,0)));
      vr_obj_generic4.put('vl_venc_30d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_30d,0)));
      vr_obj_generic4.put('vl_venc_15d_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_venc_15d,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total,0)));
      vr_obj_generic4.put('vl_limite_disponivel_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_limite_disponivel,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_Rot_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0)));
      vr_obj_generic4.put('vl_sld_devedor_total_CarRot_h11', este0001.fn_decimal_ibra(nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0)));

      vr_qtd_atr_Ext(12) := fn_obter_qtd_atr_Ext(rw_crapvopvi.vl_prejuizo_ult48m
                                                ,rw_crapvopvi.vl_venc_180d
                                                ,rw_crapvopvi.vl_venc_120d
                                                ,rw_crapvopvi.vl_venc_90d
                                                ,rw_crapvopvi.vl_venc_60d
                                                ,rw_crapvopvi.vl_venc_30d
                                                ,rw_crapvopvi.vl_venc_15d);
      vr_obj_generic4.put('qtd_atr_Ext_h11', este0001.fn_decimal_ibra(vr_qtd_atr_Ext(12)));

      vr_vl_limite(12) := nvl(rw_crapvopvi.vl_limite_disponivel,0)
                        + nvl(rw_crapvopvi.vl_sld_devedor_total_Rot,0);
      vr_obj_generic4.put('vl_limite_h11', este0001.fn_decimal_ibra(vr_vl_limite(12)));

      vr_Pc_Utiliz_limite_CarRot(12) := fn_obter_Pc_Utiliz_lim_Rot(vr_vl_limite(12)
                                                                 ,rw_crapvopvi.vl_sld_devedor_total_CarRot);

      vr_Pc_Utiliz_limite(12) := fn_obter_Pc_Utiliz_limite(vr_vl_limite(12),rw_crapvopvi.vl_limite_disponivel);
      vr_obj_generic4.put('Pc_Utiliz_limite_h11', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limite(12)));

      vr_vl_sld_devedor_total(12)  := nvl(rw_crapvopvi.vl_sld_devedor_total,0);
      vr_vl_sld_devedor_CarRot(12) := nvl(rw_crapvopvi.vl_sld_devedor_total_CarRot,0);

      -- Complemento de mensagem
      vr_dscritaux := 'Calcula indicadores';

      --Quantidade de meses com meses com ocorrencia de saldo devedor total de produtos com
      --caracteristica de rotativo (cheque especial, cartão, conta garantida, adp) nos últimos 12 meses
      vr_qt_CarRotO12 := 0;
      if vr_vl_sld_devedor_CarRot(01) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(02) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(03) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(04) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(05) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(06) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(07) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(08) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(09) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(10) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(11) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
      if vr_vl_sld_devedor_CarRot(12) > 0 then vr_qt_CarRotO12 := vr_qt_CarRotO12 +1; end if;
         vr_obj_generic4.put('vl_sld_devedor_total_CarRotQo12', este0001.fn_decimal_ibra(vr_qt_CarRotO12));

      --Quantidade de meses com meses desde a primeira ocorrencia de saldo devedor total de produtos com
      --caracteristica de rotativo (cheque especial, cartão, conta garantida, adp) nos últimos 12 meses
      if    vr_vl_sld_devedor_CarRot(12) > 0 then vr_qt_CarRotQmp12 := 12;
      elsif vr_vl_sld_devedor_CarRot(11) > 0 then vr_qt_CarRotQmp12 := 11;
      elsif vr_vl_sld_devedor_CarRot(10) > 0 then vr_qt_CarRotQmp12 := 10;
      elsif vr_vl_sld_devedor_CarRot(09) > 0 then vr_qt_CarRotQmp12 := 9;
      elsif vr_vl_sld_devedor_CarRot(08) > 0 then vr_qt_CarRotQmp12 := 8;
      elsif vr_vl_sld_devedor_CarRot(07) > 0 then vr_qt_CarRotQmp12 := 7;
      elsif vr_vl_sld_devedor_CarRot(06) > 0 then vr_qt_CarRotQmp12 := 6;
      elsif vr_vl_sld_devedor_CarRot(05) > 0 then vr_qt_CarRotQmp12 := 5;
      elsif vr_vl_sld_devedor_CarRot(04) > 0 then vr_qt_CarRotQmp12 := 4;
      elsif vr_vl_sld_devedor_CarRot(03) > 0 then vr_qt_CarRotQmp12 := 3;
      elsif vr_vl_sld_devedor_CarRot(02) > 0 then vr_qt_CarRotQmp12 := 2;
      elsif vr_vl_sld_devedor_CarRot(01) > 0 then vr_qt_CarRotQmp12 := 1;
      else  vr_qt_CarRotQmp12 := 0;
      end if;
      vr_obj_generic4.put('vl_sld_devedor_total_CarRotQmp12', este0001.fn_decimal_ibra(vr_qt_CarRotQmp12));

      --Quantidade de meses com meses com ocorrencia de saldo devedor total de rotativo de cartão de
      --credito nos últimos 12 meses
       vr_qt_totalQo12 := 0;
      if vr_vl_sld_devedor_total(01) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(02) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(03) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(04) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(05) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(06) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(07) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(08) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(09) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(10) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(11) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;
      if vr_vl_sld_devedor_total(12) > 0 then vr_qt_totalQo12 := vr_qt_totalQo12 +1; end if;

      if vr_qt_totalQo12 = 0 then
        vr_qt_totalQo12 := -100;
      end if;
      vr_obj_generic4.put('vl_sld_devedor_totalQo12', este0001.fn_decimal_ibra(vr_qt_totalQo12));

      --Maximo do valor do limite dos últimos 12 meses
      vr_vl_max_limite := greatest(vr_vl_limite(01),vr_vl_limite(02),vr_vl_limite(03)
                                  ,vr_vl_limite(04),vr_vl_limite(05),vr_vl_limite(06)
                                  ,vr_vl_limite(07),vr_vl_limite(08),vr_vl_limite(09)
                                  ,vr_vl_limite(10),vr_vl_limite(11),vr_vl_limite(12));
      vr_obj_generic4.put('vl_limiteMax12', este0001.fn_decimal_ibra(vr_vl_max_limite));

      --Pc_Utiliz_limiteAvg3
      --Percentual de utilização do limite  - média nos últimos 3 meses
      if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3))<=0 then
         vr_Pc_Utiliz_limiteAvg3 := -100;
      else
         if greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)) <= 0 then
            vr_Pc_Utiliz_limiteAvg3 := -101;
         else
            vr_Pc_Utiliz_limiteAvg3 := TRUNC( ( vr_Pc_Utiliz_limite(1)
                                       + vr_Pc_Utiliz_limite(2)
                                              + vr_Pc_Utiliz_limite(3)) /3 ,4);
         end if;
      end if;
      vr_obj_generic4.put('Pc_Utiliz_limiteAvg3', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limiteAvg3));

      IF rw_crapass.inpessoa = 1 THEN --PF

         --Pc_Utiliz_limiteMax12
         --Percentual de utilização do limite  - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <= 0 then
            vr_Pc_Utiliz_limiteMax12 := -100;
         elsif vr_vl_max_limite <= 0 then
            vr_Pc_Utiliz_limiteMax12 := -101;
         else
            vr_Pc_Utiliz_limiteMax12 := greatest(vr_Pc_Utiliz_limite(1),vr_Pc_Utiliz_limite(2),vr_Pc_Utiliz_limite(3)
                                                ,vr_Pc_Utiliz_limite(4),vr_Pc_Utiliz_limite(5),vr_Pc_Utiliz_limite(6)
                                                ,vr_Pc_Utiliz_limite(7),vr_Pc_Utiliz_limite(8),vr_Pc_Utiliz_limite(9)
                                                ,vr_Pc_Utiliz_limite(10),vr_Pc_Utiliz_limite(11),vr_Pc_Utiliz_limite(12));
         end if;
         vr_obj_generic4.put('Pc_Utiliz_limiteMax12', este0001.fn_decimal_ibra(vr_Pc_Utiliz_limiteMax12));

         --Pc_CarRot_LimAvg3
         --Percentual de rotativo cartão pelo limite - média nos últimos 3 meses
         if greatest( vr_vl_sld_devedor_total(1), vr_vl_sld_devedor_total(2), vr_vl_sld_devedor_total(3)) <= 0 then
            vr_Pc_CarRot_LimAvg3 := -100;
         elsif greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)) <= 0 then
            vr_Pc_CarRot_LimAvg3 := -101;
       --Utilizado regra do DIEGO (Planilha a regra está diferente)
       --elsif greatest(vr_vl_sld_devedor_Rot(1),vr_vl_sld_devedor_Rot(2),vr_vl_sld_devedor_Rot(3)) <= 0 then
       --   vr_Pc_CarRot_LimAvg3 := -99;
         else
            vr_nrdivisor := 0;
           if vr_Pc_Utiliz_limite_CarRot(1) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;
           if vr_Pc_Utiliz_limite_CarRot(2) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;
           if vr_Pc_Utiliz_limite_CarRot(3) <> 0 then  vr_nrdivisor :=  vr_nrdivisor +1; end if;

           IF vr_nrdivisor = 0 THEN
            vr_Pc_CarRot_LimAvg3 := -99;
           ELSE
              vr_Pc_CarRot_LimAvg3 := round(  (vr_Pc_Utiliz_limite_CarRot(1)
                                             + vr_Pc_Utiliz_limite_CarRot(2)
                                             + vr_Pc_Utiliz_limite_CarRot(3))
                                             /  vr_nrdivisor  ,4) ;
           END IF;
         --
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimAvg3', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimAvg3));

         --Pc_CarRot_LimMax12 -Linha 193
         --Percentual de rotativo cartão pelo limite - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <=0 then
            vr_Pc_CarRot_LimMax12 := -100;
         elsif vr_vl_max_limite <=0 then
            vr_Pc_CarRot_LimMax12 := -101;
         elsif vr_qt_CarRotO12 <= 0 then
            vr_Pc_CarRot_LimMax12 := -99;
         else vr_Pc_CarRot_LimMax12 :=
                             greatest( vr_Pc_Utiliz_limite_CarRot(1) , vr_Pc_Utiliz_limite_CarRot(2) ,
                                       vr_Pc_Utiliz_limite_CarRot(3) , vr_Pc_Utiliz_limite_CarRot(4) ,
                                       vr_Pc_Utiliz_limite_CarRot(5) , vr_Pc_Utiliz_limite_CarRot(6) ,
                                       vr_Pc_Utiliz_limite_CarRot(7) , vr_Pc_Utiliz_limite_CarRot(8) ,
                                       vr_Pc_Utiliz_limite_CarRot(9) , vr_Pc_Utiliz_limite_CarRot(10) ,
                                       vr_Pc_Utiliz_limite_CarRot(11), vr_Pc_Utiliz_limite_CarRot(12));
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimMax12', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimMax12));

         --vl_sld_devedor_totalNd3
         --Saldo devedor total - número de decrescimos nos últimos 3 meses
         vr_vl_sld_devedor_totalNd3 := 0;
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)) <= 0 then
            vr_vl_sld_devedor_totalNd3 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
               vr_vl_sld_devedor_totalNd3 := 1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
               vr_vl_sld_devedor_totalNd3 := vr_vl_sld_devedor_totalNd3 + 1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd3', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd3));

         --vl_sld_devedor_totalNd6
         --Saldo devedor total - número de decrescimos nos últimos 6 meses
         vr_vl_sld_devedor_totalNd6 := 0;
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)
                    ,vr_vl_sld_devedor_total(4),vr_vl_sld_devedor_total(5),vr_vl_sld_devedor_total(6)) <=0 then
            vr_vl_sld_devedor_totalNd6 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(3) < vr_vl_sld_devedor_total(4) and vr_vl_sld_devedor_total(4) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(4) < vr_vl_sld_devedor_total(5) and vr_vl_sld_devedor_total(5) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
            if vr_vl_sld_devedor_total(5) < vr_vl_sld_devedor_total(6) and vr_vl_sld_devedor_total(6) > 0 then
               vr_vl_sld_devedor_totalNd6 := vr_vl_sld_devedor_totalNd6 +1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd6', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd6));

         --vl_sld_devedor_totalNd12
         --Saldo devedor total - número de decrescimos nos últimos 12 meses
         vr_vl_sld_devedor_totalNd12 := 0;
         if vr_qt_totalQo12 <=0 then
            vr_vl_sld_devedor_totalNd12 := -100;
         else
            if vr_vl_sld_devedor_total(1) < vr_vl_sld_devedor_total(2) and vr_vl_sld_devedor_total(2) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(2) < vr_vl_sld_devedor_total(3) and vr_vl_sld_devedor_total(3) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(3) < vr_vl_sld_devedor_total(4) and vr_vl_sld_devedor_total(4) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(4) < vr_vl_sld_devedor_total(5) and vr_vl_sld_devedor_total(5) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(5) < vr_vl_sld_devedor_total(6) and vr_vl_sld_devedor_total(6) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(6) < vr_vl_sld_devedor_total(7) and vr_vl_sld_devedor_total(7) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(7) < vr_vl_sld_devedor_total(8) and vr_vl_sld_devedor_total(8) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(8) < vr_vl_sld_devedor_total(9) and vr_vl_sld_devedor_total(9) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(9) < vr_vl_sld_devedor_total(10) and vr_vl_sld_devedor_total(10) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(10) < vr_vl_sld_devedor_total(11) and vr_vl_sld_devedor_total(11) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
            if vr_vl_sld_devedor_total(11) < vr_vl_sld_devedor_total(12) and vr_vl_sld_devedor_total(12) > 0 then
                vr_vl_sld_devedor_totalNd12 := vr_vl_sld_devedor_totalNd12 +1;
            end if;
         end if;
         vr_obj_generic4.put('vl_sld_devedor_totalNd12', este0001.fn_decimal_ibra(vr_vl_sld_devedor_totalNd12));

         --qtd_atr_ExtMax6
         --  Quantidade de dias de atraso externo  - máximo nos últimos 6 meses
         if greatest(vr_vl_sld_devedor_total(1),vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)
                    ,vr_vl_sld_devedor_total(4),vr_vl_sld_devedor_total(5),vr_vl_sld_devedor_total(6)) <= 0
         and greatest(vr_vl_limite(1),vr_vl_limite(2),vr_vl_limite(3)
                     ,vr_vl_limite(4),vr_vl_limite(5),vr_vl_limite(6)) <= 0
         and greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3)
                     ,vr_qtd_atr_Ext(4),vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6)) <= 0 then
            vr_qtd_atr_ExtMax6 := -102;
         else
            vr_qtd_atr_ExtMax6 := greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3)
                                          ,vr_qtd_atr_Ext(4),vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6));
         end if;
         vr_obj_generic4.put('qtd_atr_ExtMax6', este0001.fn_decimal_ibra(vr_qtd_atr_ExtMax6));

         --qtd_atr_ExtMax12
         --Quantidade de dias de atraso externo  - máximo nos últimos 12 meses
         if vr_qt_totalQo12 <= 0
         and vr_vl_max_limite <= 0
         and  greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3),vr_qtd_atr_Ext(4)
                      ,vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6),vr_qtd_atr_Ext(7),vr_qtd_atr_Ext(8)
                      ,vr_qtd_atr_Ext(9),vr_qtd_atr_Ext(10),vr_qtd_atr_Ext(11),vr_qtd_atr_Ext(12)) <= 0 then
            vr_qtd_atr_ExtMax12 := -102;
         else
            vr_qtd_atr_ExtMax12 := greatest(vr_qtd_atr_Ext(1),vr_qtd_atr_Ext(2),vr_qtd_atr_Ext(3),vr_qtd_atr_Ext(4)
                                           ,vr_qtd_atr_Ext(5),vr_qtd_atr_Ext(6),vr_qtd_atr_Ext(7),vr_qtd_atr_Ext(8)
                                           ,vr_qtd_atr_Ext(9),vr_qtd_atr_Ext(10),vr_qtd_atr_Ext(11),vr_qtd_atr_Ext(12));
         end if;
         vr_obj_generic4.put('qtd_atr_ExtMax12', este0001.fn_decimal_ibra(vr_qtd_atr_ExtMax12));

         --qtd_atr_ExtQo12
         --Quantidade de meses com meses com ocorrencia de atraso externo nos últimos 12 meses
         vr_qtd_atr_ExtQo12 := 0;
         if vr_qt_totalQo12 <= 0
         and vr_vl_max_limite <= 0
         and vr_qtd_atr_ExtMax12 <= 0 then
           vr_qtd_atr_ExtQo12 := -102;
         else
            if vr_qtd_atr_Ext(1) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(2) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(3) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(4) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(5) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(6) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(7) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(8) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(9) > 0 then  vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(10) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(11) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
            if vr_qtd_atr_Ext(12) > 0 then vr_qtd_atr_ExtQo12 := vr_qtd_atr_ExtQo12 +1;  end if;
         end if;
         vr_obj_generic4.put('qtd_atr_ExtQo12', este0001.fn_decimal_ibra(vr_qtd_atr_ExtQo12));

         --qtatr_udmMax12
         --Quantidade de dias de atraso interno  - máximo nos últimos 12 meses
         vr_qtatr_udmMax12 := greatest(vr_qtatr_udm(1),vr_qtatr_udm(2),vr_qtatr_udm(3),vr_qtatr_udm(4)
                                      ,vr_qtatr_udm(5),vr_qtatr_udm(6),vr_qtatr_udm(7),vr_qtatr_udm(8)
                                      ,vr_qtatr_udm(9),vr_qtatr_udm(10),vr_qtatr_udm(11),vr_qtatr_udm(12));
         vr_obj_generic4.put('qtatr_udmMax12', este0001.fn_decimal_ibra(vr_qtatr_udmMax12));

         --qtatr_udmQo12
         --Quantidade de meses com meses com ocorrencia de atraso interno nos últimos 12 meses
         vr_qtatr_udmQo12 := 0;
         if vr_qtatr_udm(1) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(2) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(3) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(4) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(5) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(6) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(7) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(8) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(9) > 0 then  vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(10) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(11) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         if vr_qtatr_udm(12) > 0 then vr_qtatr_udmQo12 := vr_qtatr_udmQo12 +1;  end if;
         vr_obj_generic4.put('qtatr_udmQo12', este0001.fn_decimal_ibra(vr_qtatr_udmQo12));

         --qtatr_udmAvp12
         --Quantidade de dias de atraso interno ultimo dia do mes  - máximo nos últimos 12 meses
         IF vr_qtatr_udmMax12 > 0 THEN
           vr_qtatr_udmAvp12 := 1;
         ELSE
            IF vr_qtatr_udmMax12 = 0 THEN
              vr_qtatr_udmAvp12 := 0;
            ELSE
              vr_qtatr_udmAvp12 := 0;

              --> Gerar informaçoes do log
              /*GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => 'AILOS'
                                  ,pr_dscritic => 'Erro ao gerar a VARIAVEL INTERNA: qtatr_udmAvp12. Valor Maior que ZEROS.'
                                  ,pr_dsorigem => 'RATI003'
                                  ,pr_dstransa => 'JSON Rating - variáveis internas'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'JOB'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => 0);*/
            END IF;
         END IF;
         vr_obj_generic4.put('qtatr_udmAvp12', este0001.fn_decimal_ibra(vr_qtatr_udmAvp12));
      ELSE
         --qtd_atr_ExtQo3
         --Quantidade de meses com meses com ocorrencia de atraso nos últimos 3 meses
         vr_qtd_atr_ExtQo3 := 0;
         if  greatest(vr_vl_sld_devedor_total(1), vr_vl_sld_devedor_total(2),vr_vl_sld_devedor_total(3)) <= 0
         and greatest(vr_vl_limite(1), vr_vl_limite(2), vr_vl_limite(3)) <= 0
         and greatest(vr_qtd_atr_Ext(1), vr_qtd_atr_Ext(2), vr_qtd_atr_Ext(3)) <= 0 then
            vr_qtd_atr_ExtQo3 := -102;
         else
            if vr_qtd_atr_Ext(1) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
            if vr_qtd_atr_Ext(2) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
            if vr_qtd_atr_Ext(3) > 0 then vr_qtd_atr_ExtQo3 := vr_qtd_atr_ExtQo3 +1; end if;
         end if;
         vr_obj_generic4.put('qtd_atr_ExtQo3', este0001.fn_decimal_ibra(vr_qtd_atr_ExtQo3));

         --PcQoPriOcCarRot_12
         --Percentual da quantidade de meses com ocorrencias de rotativo cartao desde a primeira ocorrencia
         --de rotativo cartao nos ultimos 12 meses
         vr_PcQoPriOcCarRot_12 := 0;
         if vr_qt_CarRotO12 <= 0 then
            vr_PcQoPriOcCarRot_12 := -99;
         end if;
         if least(vr_Pc_Utiliz_limite_CarRot(1) , vr_Pc_Utiliz_limite_CarRot(2) ,
                  vr_Pc_Utiliz_limite_CarRot(3) , vr_Pc_Utiliz_limite_CarRot(4) ,
                  vr_Pc_Utiliz_limite_CarRot(5) , vr_Pc_Utiliz_limite_CarRot(6) ,
                  vr_Pc_Utiliz_limite_CarRot(7) , vr_Pc_Utiliz_limite_CarRot(8) ,
                  vr_Pc_Utiliz_limite_CarRot(9) , vr_Pc_Utiliz_limite_CarRot(10) ,
                  vr_Pc_Utiliz_limite_CarRot(11), vr_Pc_Utiliz_limite_CarRot(12)) <= 0 then
            vr_PcQoPriOcCarRot_12 := -100;
         end if;
         if vr_qt_totalQo12 <= 0 then
            vr_PcQoPriOcCarRot_12 := -100;
         else
            if vr_vl_max_limite <= 0 then
               vr_PcQoPriOcCarRot_12 := -101;
            else
               if vr_qt_CarRotQmp12 <> 0 and vr_qt_CarRotO12 <> 0 then
                  vr_PcQoPriOcCarRot_12 := trunc(100 * vr_qt_CarRotO12 / vr_qt_CarRotQmp12, 4);
               end if;
            end if;
         end if;
         vr_obj_generic4.put('PcQoPriOcCarRot_12', este0001.fn_decimal_ibra(vr_PcQoPriOcCarRot_12));

         --Pc_CarRot_LimQo12
         --Percentual da quantidade de meses com ocorrencias de rotativo cartao desde a primeira ocorrencia
         --de rotativo cartao nos ultimos 12 meses
         if  vr_qt_totalQo12 <= 0 then
            vr_Pc_CarRot_LimQo12 := -100;
         else
            if vr_vl_max_limite <= 0 then
               vr_Pc_CarRot_LimQo12 := -101;
            else
               vr_Pc_CarRot_LimQo12 := 0;
            end if;
         end if;
         vr_obj_generic4.put('Pc_CarRot_LimQo12', este0001.fn_decimal_ibra(vr_Pc_CarRot_LimQo12));
      end if;

      -- flag_manutencao e flag_originação
      -- EMPRESTIMO
      OPEN cr_flag_manut_orig(pr_cdcooper
                             ,pr_nrdconta
                             ,pr_nrctremp);
      FETCH cr_flag_manut_orig
       INTO rw_flag_manut_orig;
      CLOSE cr_flag_manut_orig;
      IF NVL(rw_flag_manut_orig.qtdiasflag,0) <> 0 then
         if NVL(rw_flag_manut_orig.qtdiasflag,0) > 90 then
            vr_obj_generic4.put('flag_manutencao',1);
            vr_obj_generic4.put('flag_originacao',0);
         else
            vr_obj_generic4.put('flag_manutencao',0);
            vr_obj_generic4.put('flag_originacao',1);
         end if;
      else
         -- flag_manutencao e flag_originação
         -- DESCONTO DE TITULO
         OPEN cr_flag_manut_orig_t(pr_cdcooper
                                  ,pr_nrdconta
                                  ,pr_nrctremp);
         FETCH cr_flag_manut_orig_t
          INTO rw_flag_manut_orig_t;
         CLOSE cr_flag_manut_orig_t;
         if NVL(rw_flag_manut_orig_t.qtdiasflag,0) > 90 then
            vr_obj_generic4.put('flag_manutencao',1);
            vr_obj_generic4.put('flag_originacao',0);
         else
            vr_obj_generic4.put('flag_manutencao',0);
            vr_obj_generic4.put('flag_originacao',1);
         end if;
      end if;

      vr_obj_generic4.put('dt_op_sol_manutencao'
                           ,ESTE0002.fn_Data_ibra_motor(rw_crapdat.dtmvtolt));

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonvar := vr_obj_generic4;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritaux||' - '||vr_dscritic;

      WHEN OTHERS THEN
        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritaux||' - '||vr_dscritic ||
                        dbms_utility.format_error_backtrace;

        END IF;

        -- Montar a mensagem final do erro
        vr_dscritic:= vr_dscritaux||' - '||
                     'Erro na montagem dos dados para análise automática da proposta (2.): ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;

        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');

        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
    END;
  END pc_json_variaveis_rating;

  /* Solicitar o Rating da operação na Ibratan pelo acionamento do motor. */
  PROCEDURE pc_solicitar_rating_motor(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Conta do associado
                                     ,pr_tpctrato  IN PLS_INTEGER DEFAULT 0  --> Tipo do contrato de rating
                                     ,pr_nrctrato  IN PLS_INTEGER DEFAULT 0  --> Número do contrato do rating
                                     ,pr_cdoperad  IN crapnrc.cdoperad%TYPE  --> Código do operador
                                     ,pr_cdagenci  IN crapass.cdagenci%TYPE  --> Código da agência
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  --> Data de movimentacao
                                     ,pr_inpessoa  IN crapass.inpessoa%TYPE  --> Tipo de pessoa
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada no processo
                                     ,pr_dscritic OUT VARCHAR2) IS           --> Descritivo do erro

  /* ..........................................................................

  Programa: pc_solicitar_rating_motor
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Anderson Luiz Heckmann
  Data    : Março/2019.                          Ultima Atualizacao: 05/06/2019

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Solicitar o Rating da operação na Ibratan pelo acionamento do motor.

  Alteracoes:

                  05/06/2019 - P450 - Adicionada a variavel BiroScore no JSON de envio
                  a Ibratan (Heckmann - AMcom)

                  12/08/2019 - P450 - Adicionada a rotina para pegar o parâmetro do
                               de reaproveitamento e inserir no JSON em configuracoes
                               para Ibratan (Luiz Otavio Olinger Momm - AMCOM)

                  23/08/2019 - P450 - Adicionado ao JSON o nó dos Sócios (Heckmann - AMcom)

  ............................................................................. */

  -- CURSORES

  -- Buscar PA do operador de envio da proposta
  CURSOR cr_crapope IS
    SELECT ope.cdpactra
      FROM crapope ope
          ,crawepr epr
     WHERE pr_tpctrato = 90
       AND epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctrato
       AND ope.cdcooper = pr_cdcooper
       AND upper(ope.cdoperad) = upper(epr.cdoperad)
     UNION ALL
     SELECT ope.cdpactra
      FROM crapope ope
          ,craplim lim
     WHERE pr_tpctrato <> 90
       AND lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrato
       AND ope.cdcooper = pr_cdcooper
       AND upper(ope.cdoperad) = upper(lim.cdoperad);
  vr_cdpactra crapope.cdpactra%TYPE;

  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE)IS
    SELECT ass.nrdconta,
           ass.nmprimtl,
           ass.cdagenci,
           age.nmextage,
           ass.inpessoa,
           decode(ass.inpessoa,1,0,2,1) inpessoa_ibra,
           ass.nrcpfcgc
      FROM crapass ass,
           crapage age
     WHERE ass.cdcooper = age.cdcooper
       AND ass.cdagenci = age.cdagenci
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --> Buscar cadastro do Conjuge:
  CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT crapcje.nrctacje
          ,crapcje.nmconjug
          ,crapcje.nrcpfcjg
          ,crapcje.dtnasccj
          ,crapcje.tpdoccje
          ,crapcje.nrdoccje
          ,crapcje.grescola
          ,crapcje.cdfrmttl
          ,crapcje.cdnatopc
          ,crapcje.cdocpcje
          ,crapcje.tpcttrab
          ,crapcje.dsproftl
          ,crapcje.cdnvlcgo
          ,crapcje.nrfonemp
          ,crapcje.nrramemp
          ,crapcje.cdturnos
          ,crapcje.dtadmemp
          ,crapcje.vlsalari
          ,crapcje.nrdocnpj
          ,crapcje.cdufdcje
     FROM crapcje
    WHERE crapcje.cdcooper = pr_cdcooper
      AND crapcje.nrdconta = pr_nrdconta
      AND crapcje.idseqttl = 1;
  rw_crapcje cr_crapcje%ROWTYPE;

  --> Buscar informaçoes da Proposta
  CURSOR cr_craplim IS
    SELECT --lim.insitest
          --,lim.insitapr
          --,lim.cdopeapr
           ass.cdagenci
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,ass.inpessoa
          --,lim.dsprotoc
          ,lim.cddlinha
          ,lim.tpctrlim
          --,lim.dtinsori hrinclus
          ,ldc.cddlinha cdlcremp
          ,ldc.dsdlinha dslcremp
          ,0   cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
          ,''  dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo
         /* ,case when nvl(lim.nrctrmnt,0) = 0 then 'LM'
                else                              'MJ'
           end tpproduto */
           ,'LM' tpproduto
          ,decode(ldc.tpctrato, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto  (0-Generico/ 1-Aplicacao)
          ,decode(ldc.tpctrato, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato
          ,'C' despagto --Tipo do Debito do Emprestimo: C-CONTA F-FOLHA
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,ldc.txmensal
          ,lim.vllimite
          ,0 vlpreemp
          ,0 qtpreemp
          ,lim.dtinivig
          ,lim.dtfimvig
          ,0 flgreneg -- renegociacao: Indicaçao de Operaçao de Renegociaçao
          ,lim.idquapro
          ,ass.nrcpfcgc
          ,lim.rowid
      FROM crapass ass
          ,craplim lim
          ,crapldc ldc
     WHERE ass.cdcooper = lim.cdcooper
       AND ass.nrdconta = lim.nrdconta
       AND ldc.cdcooper = lim.cdcooper
       AND ldc.cddlinha = lim.cddlinha
       AND ldc.tpdescto = lim.tpctrlim
       AND lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrato
       AND lim.tpctrlim = 2
  UNION ALL
  SELECT --lim.insitest
          --,lim.insitapr
          --,lim.cdopeapr
           ass.cdagenci
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,ass.inpessoa
          --,lim.dsprotoc
          ,lim.cddlinha
          ,lim.tpctrlim
          --,lim.dtinsori hrinclus
          ,ldc.cddlinha cdlcremp
          ,ldc.dsdlinha dslcremp
          ,0   cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
          ,''  dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo
         /* ,case when nvl(lim.nrctrmnt,0) = 0 then 'LM'
                else                              'MJ'
           end tpproduto */
           ,'LM' tpproduto
          ,decode(ldc.tpctrato, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto  (0-Generico/ 1-Aplicacao)
          ,decode(ldc.tpctrato, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato
          ,'C' despagto --Tipo do Debito do Emprestimo: C-CONTA F-FOLHA
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,ldc.txmensal
          ,lim.vllimite
          ,0 vlpreemp
          ,0 qtpreemp
          ,lim.dtinivig
          ,lim.dtfimvig
          ,0 flgreneg -- renegociacao: Indicaçao de Operaçao de Renegociaçao
          ,lim.idquapro
          ,ass.nrcpfcgc
          ,lim.rowid
      FROM crapass ass
          ,craplim lim
          ,crapldc ldc
     WHERE ass.cdcooper = lim.cdcooper
       AND ass.nrdconta = lim.nrdconta
       AND ldc.cdcooper = lim.cdcooper
       AND ldc.cddlinha = lim.cddlinha
       AND ldc.tpdescto = lim.tpctrlim
       AND lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrato
       AND lim.tpctrlim = 3
  UNION ALL
    SELECT --lim.insitest
          --,lim.insitapr
          --,lim.cdopeapr
           ass.cdagenci
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,ass.inpessoa
          --,lim.dsprotoc
          ,lim.cddlinha
          ,lim.tpctrlim
          --,lim.dtinsori hrinclus
          ,NULL cdlcremp
          ,NULL dslcremp
          ,0   cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
          ,''  dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo
         /* ,case when nvl(lim.nrctrmnt,0) = 0 then 'LM'
                else                              'MJ'
           end tpproduto */
           ,'LM' tpproduto
          ,decode(lim.tpctrlim, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto  (0-Generico/ 1-Aplicacao)
          ,decode(lim.tpctrlim, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato
          ,'C' despagto --Tipo do Debito do Emprestimo: C-CONTA F-FOLHA
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,NULL txmensal
          ,lim.vllimite
          ,0 vlpreemp
          ,0 qtpreemp
          ,lim.dtinivig
          ,lim.dtfimvig
          ,0 flgreneg -- renegociacao: Indicaçao de Operaçao de Renegociaçao
          ,lim.idquapro
          ,ass.nrcpfcgc
          ,lim.rowid
      FROM crapass ass
          ,craplim lim
     WHERE ass.cdcooper = lim.cdcooper
       AND ass.nrdconta = lim.nrdconta
       AND lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrato
       AND lim.tpctrlim = 1;
  rw_craplim cr_craplim%ROWTYPE;

  --> Buscar se a conta é de Colaborador Cecred
  CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
    SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
      FROM tbcadast_colaborador col
     WHERE col.cdcooper = pr_cdcooper
       AND col.nrcpfcgc = pr_nrcpfcgc
       AND col.flgativo = 'A';

  -- Buscar conjuge co-responsável
  CURSOR cr_crapprp IS
    SELECT prp.flgdocje
      FROM crapprp prp
     WHERE prp.cdcooper = pr_cdcooper
       AND prp.nrdconta = pr_nrdconta
       AND prp.nrctrato = pr_nrctrato
       AND prp.tpctrato = 3;
  rw_crapprp cr_crapprp%ROWTYPE;

  -- Buscar os bens em garantia na Proposta
  CURSOR cr_crapbpr IS
    SELECT crapbpr.dscatbem
          ,crapbpr.vlmerbem
          ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
          ,crapbpr.nrcpfbem
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.nrctrpro = pr_nrctrato
       AND crapbpr.tpctrpro = 3
       AND trim(crapbpr.dscatbem) is not NULL;

  -- Buscar Saldo de Cotas
  CURSOR cr_crapcot(pr_cdcooper crapass.cdcooper%type,
                    pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT vldcotas
      FROM crapcot
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  vr_vldcotas crapcot.vldcotas%TYPE;

  -- Buscar avalistas terceiros e socios
  CURSOR cr_crapavt(pr_cdcooper crapass.cdcooper%TYPE,
                    pr_nrdconta crapass.nrdconta%TYPE,
                    pr_nrctremp crapavt.nrctremp%TYPE,
                    pr_tpctrato crapavt.tpctrato%TYPE,
                    pr_dsproftl crapavt.dsproftl%TYPE) IS
    SELECT crapavt.* --> necessario ser todos os campos pois envia como parametro
      FROM crapavt
     WHERE crapavt.cdcooper = pr_cdcooper
       AND crapavt.nrdconta = pr_nrdconta
       AND crapavt.nrctremp = pr_nrctremp
       AND crapavt.tpctrato = pr_tpctrato
       AND (   pr_dsproftl IS NULL
             OR ( pr_dsproftl = 'SOCIO' AND dsproftl IN('SOCIO/PROPRIETARIO'
                                                       ,'SOCIO ADMINISTRADOR'
                                                       ,'DIRETOR/ADMINISTRADOR'
                                                       ,'SINDICO'
                                                       ,'ADMINISTRADOR'))
             OR ( pr_dsproftl = 'PROCURADOR' AND dsproftl LIKE UPPER('%PROCURADOR%'))
            );
  rw_crapavt cr_crapavt%ROWTYPE;


  -- VARIAVEIS
  vr_cdcritic           PLS_INTEGER;
  vr_dscritic           VARCHAR2(4000);
  vr_dsmensag           VARCHAR2(4000);
  vr_obj_generico       json := json();
  vr_obj_generico_conf  json := json();
  vr_obj_generico_clob  CLOB;
  vr_obj_generic1       json := json();
  vr_obj_generic2       json := json();
  vr_obj_generic4       json := json();
  vr_obj_conjuge        json := json();
  vr_obj_avalista       json := json();
  vr_obj_socios         json := json();
  vr_obj_indcliente     json := json();
  vr_lst_generico       json_list := json_list();
  vr_lst_generic2       json_list := json_list();
  vr_dsprotoc           VARCHAR2(1000);
  vr_comprecu           VARCHAR2(1000);
  vr_des_erro           VARCHAR2(2000) := 'OK';
  vr_data_aux           crapdat.dtmvtolt%TYPE;
  vr_exc_erro           EXCEPTION;
  vr_flavalis           BOOLEAN := FALSE;
  vr_flsocios           BOOLEAN := FALSE;
  vr_nrctaav1           craplim.nrctaav1%TYPE;
  vr_nrctaav2           craplim.nrctaav2%TYPE;
  vr_vllimati           craplim.vllimite%TYPE;
  vr_dsquapro           VARCHAR2(100);
  vr_cddcargo           tbcadast_colaborador.cdcooper%TYPE;
  vr_flgcolab           BOOLEAN;
  vr_flgbens            BOOLEAN := FALSE;
  vr_valoriof           NUMBER;
  vr_inconting          tbrat_param_geral.incontingencia%TYPE;
  vr_qtdiarpv           INTEGER;

  BEGIN

    --- verifica se a contingencia está ligada (P450 - Rating)
    pc_verifica_continge_rating(pr_cdcooper  => pr_cdcooper     --> Cooper
                               ,pr_tpctrato  => pr_tpctrato     --> Tipo do contrato de rating
                               ,pr_inpessoa  => pr_inpessoa     --> Tipo de pessoa
                               ,pr_inconting => vr_inconting
                               ,pr_cdcritic  => vr_cdcritic
                               ,pr_dscritic  => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
    END IF;


    IF vr_inconting = 1 THEN --- em contigencia (1-Sim 0-Não) (P450 - Rating)
       -- grava rating contingencia como Vencido
       pc_grava_rat_contingencia(pr_cdcooper   => pr_cdcooper        --> Código da Cooperativa
                                ,pr_nrdconta   => pr_nrdconta        --> Conta do associado
                                ,pr_tpctrato   => pr_tpctrato        --> Tipo do contrato de rating
                                ,pr_nrctrato   => pr_nrctrato        --> Número do contrato do rating
                                ,pr_dtmvtolt   => pr_dtmvtolt        --> Data de movimentacao
                                ,pr_cdoperad   => pr_cdoperad        --> Código do operador
                                ,pr_strating   => 3                  --> Identificador da Situacao Rating Vencido (Dominio: tbgen_dominio_campo)
                                ,pr_cdcritic   => vr_cdcritic
                                ,pr_dscritic   => vr_dscritic);

       IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
       END IF;

    ELSE -- Então aciona Motor

      /*
      TPCTRATO:
            1 - Limite de Crédito
            2 - Limite de Desconto de Cheque
            3 - Limite de Desconto de Título
            90 - Empréstimos/Financiamentos
            91 - Borderôs de descontos de Títulos
            92 - Borderôs de descontos de Cheques
      */
      IF pr_tpctrato IN (1,2,3,91,92) THEN

        --> Buscar dados do associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Caso nao encontrar abortar proceso
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 9;
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;

        IF pr_tpctrato = 91 THEN
          vr_obj_indcliente.put('segmentoCodigo', 91);
          vr_obj_indcliente.put('segmentoDescricao', 'Borderôs de descontos de Títulos');
        ELSIF pr_tpctrato = 92 THEN
          vr_obj_indcliente.put('segmentoCodigo', 92);
          vr_obj_indcliente.put('segmentoDescricao', 'Borderôs de descontos de Cheques');
        END IF;

        --> indicadoresCliente
        IF pr_tpctrato IN (1,2,3) THEN
          --> Buscar informaçoes da proposta
          OPEN cr_craplim;
          FETCH cr_craplim INTO rw_craplim;
          CLOSE cr_craplim;

          vr_nrctaav1 := rw_craplim.nrctaav1;
          vr_nrctaav2 := rw_craplim.nrctaav2;

          vr_data_aux := sysdate;
          vr_obj_indcliente.put('dataProposta', ESTE0001.fn_DataTempo_ibra(vr_data_aux));

          vr_obj_indcliente.put('cooperativa', pr_cdcooper);
          vr_obj_indcliente.put('agenci', pr_cdagenci);

          /*
          campo especifico - produtoCreditoSegmentoCodigo = 2 – Empréstimos /Financiamentos
          campo especifico - produtoCreditoSegmentoCodigo = 3   Desconto Cheque
          campo especifico - produtoCreditoSegmentoCodigo = 4 – Desconto Títulos
          campo especifico - produtoCreditoSegmentoCodigo = 8   Limite Credito    --- no programa está com 6
          */

          CASE pr_tpctrato
            WHEN 1 THEN
              BEGIN
                vr_obj_indcliente.put('segmentoCodigo', 8); -- P450 - 30/07/2019 - Alterado de produtoCreditoSegmentoCodigo
                vr_obj_indcliente.put('segmentoDescricao', 'Limite Credito'); -- P450 - 30/07/2019 - Alterado de produtoCreditoSegmentoDescricao
              END;
            WHEN 2 THEN
              BEGIN
                vr_obj_indcliente.put('segmentoCodigo', 3); -- P450 - 30/07/2019 - Alterado de produtoCreditoSegmentoCodigo
                vr_obj_indcliente.put('segmentoDescricao', 'Desconto Cheque'); -- P450 - 30/07/2019 - Alterado de produtoCreditoSegmentoDescricao
              END;
            WHEN 3 THEN
              BEGIN
                vr_obj_indcliente.put('segmentoCodigo', 5); -- P450 22/08/2019 - Adicionado Desc Tit
                vr_obj_indcliente.put('segmentoDescricao', 'Desconto Titulo'); -- P450 22/08/2019 - Adicionado Desc Tit
              END;
          END CASE;

          vr_obj_indcliente.put('linhaCreditoCodigo'    ,rw_craplim.cdlcremp);
          vr_obj_indcliente.put('linhaCreditoDescricao' ,rw_craplim.dslcremp);
          --vr_obj_generico.put('finalidadeCodigo'      ,rw_craplim.cdfinemp);
          --vr_obj_generico.put('finalidadeDescricao'   ,rw_craplim.dsfinemp);

          vr_obj_indcliente.put('tipoProduto'           ,rw_craplim.tpproduto);

          IF  rw_craplim.tpctrato > 0 THEN
            vr_obj_indcliente.put('tipoGarantiaCodigo'   , rw_craplim.tpctrato );
            vr_obj_indcliente.put('tipoGarantiaDescricao', rw_craplim.dsctrato );
          END IF;

          vr_obj_indcliente.put('debitoEm'    ,rw_craplim.despagto );
          vr_obj_indcliente.put('liquidacao'  ,rw_craplim.dsliquid!='0,0,0,0,0,0,0,0,0,0');

          vr_obj_indcliente.put('valorTaxaMensal', ESTE0001.fn_decimal_ibra(rw_craplim.txmensal));

          vr_obj_indcliente.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_craplim.vllimite));
          vr_obj_indcliente.put('quantParcela'  , rw_craplim.qtpreemp);
          vr_obj_indcliente.put('primeiroVencto', este0002.fn_data_ibra_motor(rw_craplim.dtfimvig));
          vr_obj_indcliente.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_craplim.vlpreemp));

          vr_vllimati := nvl(rw_craplim.vllimite,0);
          IF  vr_vllimati > 0 THEN
            vr_obj_indcliente.put('valorLimiteAtivo', vr_vllimati);
          END IF;

          --  valor que está sendo marjorado
          IF  rw_craplim.tpproduto = 'MJ' THEN
            vr_obj_indcliente.put('valorLimiteMaximoPermitido', rw_craplim.vllimite - vr_vllimati);
          END IF;

          vr_obj_indcliente.put('renegociacao', nvl(rw_craplim.flgreneg,0) = 1);

          vr_obj_indcliente.put('qualificaOperacaoCodigo', rw_craplim.idquapro);

          CASE rw_craplim.idquapro
            WHEN 1 THEN vr_dsquapro := 'Operacao normal';
            WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
            WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
            WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
            ELSE vr_dsquapro := ' ';
          END CASE;

          vr_obj_indcliente.put('qualificaOperacaoDescricao', vr_dsquapro);

          IF pr_inpessoa = 1 THEN
            -- Verificar se a conta é de colaborador do sistema Cecred
            vr_cddcargo := NULL;
            OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                           ,pr_nrcpfcgc => rw_craplim.nrcpfcgc);
            FETCH cr_tbcolab INTO vr_cddcargo;
            IF cr_tbcolab%FOUND THEN
              vr_flgcolab := TRUE;
            ELSE
              vr_flgcolab := FALSE;
            END IF;
            CLOSE cr_tbcolab;

            vr_obj_indcliente.put('cooperadoColaborador', vr_flgcolab);

            OPEN cr_crapprp;
            FETCH cr_crapprp INTO rw_crapprp;
            CLOSE cr_crapprp;
            vr_obj_indcliente.put('conjugeCoResponv',nvl(rw_crapprp.flgdocje,0)=1);

          END IF;

          -- Efetuar laço para trazer todos os registros
          FOR rw_crapbpr IN cr_crapbpr LOOP

            -- Indicar que encontrou
            vr_flgbens := TRUE;
            -- Para cada registro de Bem, criar objeto para a operaçao e enviar suas informaçoes
            vr_lst_generic2 := json_list();
            vr_obj_generic2 := json();
            vr_obj_generic2.put('categoriaBem', rw_crapbpr.dscatbem);
            vr_obj_generic2.put('anoGarantia', rw_crapbpr.nranobem);
            vr_obj_generic2.put('valorGarantia', ESTE0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
            vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);

            -- Adicionar Bem na lista
            vr_lst_generic2.append(vr_obj_generic2.to_json_value());

          END LOOP; -- Final da leitura dos Bens

          -- Adicionar o array bemEmGarantia
          IF vr_flgbens THEN
            vr_obj_indcliente.put('bemEmGarantia', vr_lst_generic2);
          ELSE
            -- Verificar se o valor das Cotas é Superior ao da Proposta
            OPEN cr_crapcot(pr_cdcooper
                           ,pr_nrdconta);
            FETCH cr_crapcot
            INTO vr_vldcotas;
            CLOSE cr_crapcot;
            -- Se valor das cotas é superior ao da proposta
            IF NVL(vr_vldcotas,0) > rw_craplim.vllimite THEN
              -- Adicionar as cotas
              vr_lst_generic2 := json_list();
              vr_obj_generic2 := json();
              vr_obj_generic2.put('categoriaBem','COTAS CAPITAL');
              vr_obj_generic2.put('anoGarantia',0);
              vr_obj_generic2.put('valorGarantia',ESTE0001.fn_decimal_ibra(vr_vldcotas));
              vr_obj_generic2.put('bemInterveniente',false);
              -- Adicionar Bem na lista
              vr_lst_generic2.append(vr_obj_generic2.to_json_value());
              -- Adicionar as cotas como garantia
              vr_obj_indcliente.put('bemEmGarantia', vr_lst_generic2);
            END IF;
          END IF;

          vr_obj_indcliente.put('BiroScore',RATI0003.fn_tipo_biro(pr_cdcooper => pr_cdcooper));

          -- 1 - Limite de Crédito
          -- 2 - Limite de Desconto de Cheque
          IF pr_tpctrato = 1 THEN
            vr_obj_indcliente.put('operacao', 'LIMITE CREDITO');
          ELSIF pr_tpctrato = 2 THEN
            vr_obj_indcliente.put('operacao', 'LIMITE DESCONTO CHEQUE');
          ELSIF pr_tpctrato = 3 THEN
            vr_obj_indcliente.put('operacao', 'LIMITE DESCONTO TITULO');
          END IF;

          -- Buscar IOF
          vr_valoriof := 0;
          vr_obj_indcliente.put('IOFValor', este0001.fn_decimal_ibra(nvl(vr_valoriof,0)));

          vr_obj_indcliente.put('valorPrestLiquidacao', ESTE0001.fn_decimal_ibra(0));

          /* P450 - Rating modelo calculo */
          vr_obj_indcliente.put('modeloRating', RATI0003.fn_retorna_modelo_rating(pr_cdcooper));

          vr_obj_generico.put('indicadoresCliente', vr_obj_indcliente);

        END IF;

        -- Tratativa exclusiva para ambiente de homologacao, não deve existir o parametro "URI_WEBSRV_ESTEIRA_HOMOL"
          -- em ambiente produtivo
          IF (TRIM(gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL')) IS NOT NULL) THEN
              vr_obj_generico.put('ambienteTemp','true');
              vr_obj_generico.put('urlRetornoTemp', gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') );
          END IF;

        IF pr_inpessoa = 1 THEN
          vr_obj_generico.put('protocoloPolitica', 'politicaRatingPF');
        ELSE
          vr_obj_generico.put('protocoloPolitica', 'politicaRatingPJ');
        END IF;

        -- Adicioanr o número do contrato (proposta)
        vr_obj_generico.put('proposta', gene0002.fn_mask_contrato(pr_nrctrato));
        vr_obj_generico.put('valorProposta', ESTE0001.fn_decimal_ibra(rw_craplim.vllimite));

        -- Reaproveitamento IBRATAN
        vr_qtdiarpv := TELA_PARRAT.fn_buscar_reaproveitamento(pr_cdcooper => pr_cdcooper
                                                             ,pr_inpessoa => pr_inpessoa
                                                             ,pr_tpctrato => pr_tpctrato) * 24;

        -- Buscar PA do operador
        OPEN cr_crapope;
        FETCH cr_crapope INTO vr_cdpactra;
        CLOSE cr_crapope;

        -- Montar os atributos de 'configuracoes'
        vr_obj_generico_conf := json();
        vr_obj_generico_conf.put('centroCusto', NVL(vr_cdpactra,0));
        vr_obj_generico_conf.put('horasReaproveitamento', vr_qtdiarpv);

        -- Adicionar o array configuracoes
        vr_obj_generico.put('configuracoes', vr_obj_generico_conf);
        -- Reaproveitamento IBRATAN

        este0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => 0
                                        ,pr_flprepon => FALSE
                                        ,pr_tpprodut => pr_tpctrato
                                        ,pr_inPropon => True
                                        ,pr_dsjsonan => vr_obj_generic4
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Adicionar o JSON montado do Proponente no objeto principal
        vr_obj_generico.put('proponente',vr_obj_generic4);

        --> Para Pessoa Fisica iremos buscar seu Conjuge
        IF rw_crapass.inpessoa = 1 THEN

          --> Buscar cadastro do Conjuge
          rw_crapcje := NULL;
          OPEN cr_crapcje( pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta);
          FETCH cr_crapcje INTO rw_crapcje;

          -- Se não encontrar
          IF cr_crapcje%NOTFOUND THEN
            -- apenas fechamos o cursor
            CLOSE cr_crapcje;
          ELSE
            -- Fechar o cursor e enviar
            CLOSE cr_crapcje;
            --> Se Conjuge for associado:
            IF rw_crapcje.nrctacje <> 0 THEN

              -- Passaremos a conta para montagem dos dados:
              ESTE0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => rw_crapcje.nrctacje
                                              ,pr_nrctremp => pr_nrctrato
                                              ,pr_vlsalari => rw_crapcje.vlsalari
                                              ,pr_dsjsonan => vr_obj_conjuge
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

              -- Testar possíveis erros na rotina:
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;

              -- Adicionar o JSON montado do Proponente no objeto principal
              vr_obj_generico.put('conjuge',vr_obj_conjuge);

            ELSE
              -- Enviaremos os dados básicos encontrados na tabela de conjugue
              vr_obj_conjuge.put('documento'      ,ESTE0002.fn_mask_cpf_cnpj(NVL(rw_crapcje.nrcpfcjg,0),1));
              vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
              vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);

              vr_obj_conjuge.put('dataNascimento' ,ESTE0002.fn_Data_ibra_motor(rw_crapcje.dtnasccj));

              -- Se o Documento for RG
              IF rw_crapcje.tpdoccje = 'CI' THEN
                vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
                vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
              END IF;

              -- Montar objeto Telefone para Telefone Comercial
              IF rw_crapcje.nrfonemp <> ' ' THEN
                vr_lst_generic2 := json_list();
                -- Criar objeto só para este telefone
                vr_obj_generic1 := json();
                vr_obj_generic1.put('especie', 'COMERCIAL');

                vr_obj_generic1.put('numero', ESTE0002.fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
                -- Adicionar telefone na lista
                vr_lst_generic2.append(vr_obj_generic1.to_json_value());
                -- Adicionar o array telefone no objeto Conjuge
                vr_obj_conjuge.put('telefones', vr_lst_generic2);
              END IF;

              -- Montar objeto profissao
              IF rw_crapcje.dsproftl <> ' ' THEN
                vr_obj_generic1 := json();
                vr_obj_generic1.put('titulo'   , rw_crapcje.dsproftl);
                vr_obj_conjuge.put ('profissao', vr_obj_generic1);
              END IF;

              -- Montar informações Adicionais
              vr_obj_generic1 := json();
              -- Escolaridade
              IF rw_crapcje.grescola <> 0 THEN
                vr_obj_generic1.put('escolaridade', rw_crapcje.grescola);
              END IF;
              -- Curso Superior
              IF rw_crapcje.cdfrmttl <> 0 THEN
                vr_obj_generic1.put('cursoSuperiorCodigo'
                                   ,rw_crapcje.cdfrmttl);
                vr_obj_generic1.put('cursoSuperiorDescricao'
                                   ,ESTE0002.fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
              END IF;
              -- Natureza Ocupação
              IF rw_crapcje.cdnatopc <> 0 THEN
                vr_obj_generic1.put('naturezaOcupacao', rw_crapcje.cdnatopc);
              END IF;
              -- Ocupação
              IF rw_crapcje.cdocpcje <> 0 THEN
                vr_obj_generic1.put('ocupacaoCodigo'
                                   ,rw_crapcje.cdocpcje);
                vr_obj_generic1.put('ocupacaoDescricao'
                                   ,ESTE0002.fn_des_cdocupa(rw_crapcje.cdocpcje));
              END IF;
              -- Tipo Contrato de Trabalho
              IF rw_crapcje.tpcttrab <> 0 THEN
                vr_obj_generic1.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
              END IF;
              -- Nivel Cargo
              IF rw_crapcje.cdnvlcgo <> 0 THEN
                vr_obj_generic1.put('nivelCargo', rw_crapcje.cdnvlcgo);
              END IF;
              -- Turno
              IF rw_crapcje.cdturnos <> 0 THEN
                vr_obj_generic1.put('turno', rw_crapcje.cdturnos);
              END IF;
              -- Data Admissão
              IF rw_crapcje.dtadmemp IS NOT NULL THEN
                vr_obj_generic1.put('dataAdmissao', ESTE0002.fn_Data_ibra_motor(rw_crapcje.dtadmemp));
              END IF;
              -- Salario
              IF rw_crapcje.vlsalari <> 0 THEN
                vr_obj_generic1.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
              END IF;
              -- CNPJ Empresa
              IF rw_crapcje.nrdocnpj <> 0 THEN
                vr_obj_generic1.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
              END IF;

              -- Enviar informações adicionais ao JSON Conjuge
              -- tratamento para nao enviar JSON como LISTA quando executado no PHP junto a funcao JSON_DECODE
              IF json_ac.object_count(vr_obj_generic1) > 0 THEN
                 vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generic1);
              END IF;

              -- Ao final adicionamos o json montado ao principal
              vr_obj_generico.put('conjuge' ,vr_obj_conjuge);
            END IF;

          END IF;

        END IF;

        --> BUSCAR AVALISTAS INTERNOS E EXTERNOS:
        -- Inicializar lista de Avalistas
        vr_lst_generico := json_list();

        -- Enviar avalista 01 em novo json só para avalistas
        IF nvl(vr_nrctaav1,0) <> 0 THEN
          -- Setar flag para indicar que há avalista
          vr_flavalis := true;

          ESTE0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => vr_nrctaav1
                                          ,pr_nrctremp => pr_nrctrato
                                          ,pr_dsjsonan => vr_obj_avalista
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Adicionar o avalista montato na lista de avalistas
          vr_lst_generico.append(vr_obj_avalista.to_json_value());

        END IF;

        -- Enviar avalista 02 em novo json só para avalistas
        IF nvl(vr_nrctaav2,0) <> 0 THEN
          -- Setar flag para indicar que há avalista
          vr_flavalis := true;

          ESTE0002.pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => vr_nrctaav2
                                          ,pr_nrctremp => pr_nrctrato
                                          ,pr_dsjsonan => vr_obj_avalista
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Adicionar o avalista montato na lista de avalistas
          vr_lst_generico.append(vr_obj_avalista.to_json_value());

        END IF;

        --> Efetuar laço para retornar todos os registros disponíveis:
        FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctrato
                                     ,pr_tpctrato => 1
                                     ,pr_dsproftl => null) LOOP

          -- Setar flag para indicar que há avalista
          vr_flavalis := true;
          -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros
          ESTE0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                          ,pr_dsjsonavt  => vr_obj_avalista
                                          ,pr_cdcritic   => vr_cdcritic
                                          ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Adicionar o avalista montato na lista de avalistas
          vr_lst_generico.append(vr_obj_avalista.to_json_value());

        END LOOP; --> crapavt

        -- Enviar novo objeto de avalistas para dentro do objeto principal (Se houve encontro)
        IF vr_flavalis = true THEN
          vr_obj_generico.put('avalistas' , vr_lst_generico);
        END IF;

        --> Para pessoa Jurídica buscaremos os sócios da Empresa:
        IF rw_crapass.inpessoa = 2 THEN

          -- Inicializar lista de Representantes
          vr_lst_generico := json_list();
          --> Efetuar laço para retornar todos os registros disponíveis dos socios:
          FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => 0
                                       ,pr_tpctrato => 6
                                       ,pr_dsproftl => 'SOCIO') LOOP

            -- Setar flag para indicar que há Sócios
            vr_flsocios := true;
            -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros
            ESTE0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                            ,pr_dsjsonavt  => vr_obj_socios
                                            ,pr_cdcritic   => vr_cdcritic
                                            ,pr_dscritic   => vr_dscritic);
            -- Testar possíveis erros na rotina:
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_socios.to_json_value());

          END LOOP; --> crapavt dos socios

          -- Enviar novo objeto de socios para dentro do objeto principal (Se houve encontro)
          IF vr_flsocios = true THEN
            vr_obj_generico.put('socios' , vr_lst_generico);
          END IF;

        END IF;

        -- Criar o CLOB para converter JSON para CLOB
        dbms_lob.createtemporary(vr_obj_generico_clob, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_obj_generico_clob, dbms_lob.lob_readwrite);
        json.to_clob(vr_obj_generico, vr_obj_generico_clob);

        --> Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa
        IF pr_inpessoa = 1 THEN
          vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                    ,pr_cdcooper
                                                                    ,'REGRA_ANL_MOTOR_PF_RAT')||'/start';
        ELSE
          vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                     ,pr_cdcooper
                                                                     ,'REGRA_ANL_MOTOR_PJ_RAT')||'/start';
        END IF;

        --> Enviar dados para Análise Automática Esteira (Motor)
        RATI0004.pc_enviar_analise_rating(pr_cdcooper    => pr_cdcooper           --> Codigo da cooperativa
                                          ,pr_cdagenci    => pr_cdagenci           --> Codigo da agencia
                                          ,pr_cdoperad    => pr_cdoperad           --> Codigo do operador
                                          ,pr_cdorigem    => 1                     --> Origem da operacao
                                          ,pr_nrdconta    => pr_nrdconta           --> Numero da conta do cooperado
                                          ,pr_nrctrato    => pr_nrctrato           --> Numero do contrato
                                          ,pr_tpctrato    => pr_tpctrato           --> Tipo do contrato de rating
                                          ,pr_dtmvtolt    => pr_dtmvtolt           --> Data do movimento
                                          ,pr_comprecu    => vr_comprecu           --> Complemento do recuros da URI
                                          ,pr_dsmetodo    => 'POST'                --> Descricao do metodo
                                          ,pr_conteudo    => vr_obj_generico_clob  --> Conteudo no Json para comunicacao
                                          ,pr_dsoperacao  => 'ENVIO DO CONTRATO PARA ANALISE AUTOMATICA DE RATING'  --> Operação efetuada
                                          ,pr_tpenvest    => 'M'                   --> Tipo de envio (Motor)
                                          ,pr_dsprotocolo => vr_dsprotoc           --> Protocolo gerado
                                          ,pr_dscritic    => vr_dscritic);

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_obj_generico_clob);
         dbms_lob.freetemporary(vr_obj_generico_clob);

         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;

         RATI0004.pc_solicita_retorno(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctrato => pr_nrctrato
                                     ,pr_tpctrato => pr_tpctrato
                                     ,pr_dsprotoc => vr_dsprotoc
                                     ,pr_strating => 2
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
/*
       ELSIF pr_tpctrato = 3 THEN -- Limite de Desconto de Título
         ESTE0003.pc_enviar_proposta_esteira(pr_cdcooper => pr_cdcooper
                                            ,pr_cdagenci => pr_cdagenci
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_idorigem => 1
                                            ,pr_tpenvest => 'I'
                                            ,pr_nrctrlim => pr_nrctrato
                                            ,pr_tpctrlim => pr_tpctrato
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_dsmensag => vr_dsmensag
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;

         RATI0004.pc_solicita_retorno(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctrato => pr_nrctrato
                                     ,pr_tpctrato => pr_tpctrato
                                     ,pr_dsprotoc => vr_dsprotoc
                                     ,pr_strating => 2
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
*/
       ELSIF pr_tpctrato = 90 THEN -- Empréstimos/Financiamentos
         ESTE0001.pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdorigem => 1
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctrato
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_nmarquiv => NULL
                                         ,pr_dsmensag => vr_dsmensag
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;

         RATI0004.pc_solicita_retorno(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctrato => pr_nrctrato
                                     ,pr_tpctrato => pr_tpctrato
                                     ,pr_dsprotoc => vr_dsprotoc
                                     ,pr_strating => 2
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;

       END IF;

    END IF; -- Do contingencia

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina RATI0003.pc_solicitar_rating_motor '||SQLERRM;
        ROLLBACK;
  END pc_solicitar_rating_motor;


 PROCEDURE pc_busca_rat_expirado(  pr_cdcooper  IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE                    --> Conta do associado
                                  ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE          --> Tipo do contrato
                                  ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE          --> Número do contrato
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                  ,pr_dscritic OUT VARCHAR2) IS

   /* ..........................................................................

  Programa: pc_busca_rat_expirado
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Daniele Rocha
  Data    : Março/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Valida ao efetivar proposta de limite de crédito e Cheque!!
              validação com o parametro da Parrat se tal proposta poderá ser efetivada !

  Alteracoes:

  ............................................................................. */

  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_tpproduto INTEGER;
  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_calc_rating    BOOLEAN;
  -- paramentro a mais retornado xml para servir como parametro da consulta
 rw_crapdat                           btch0001.cr_crapdat%ROWTYPE;
  ---------->> CURSORES <<--------
CURSOR cr_tbrat_param_geral(   vr_cdcooper  IN tbrisco_central_parametros.cdcooper%TYPE,
                                vr_inpessoa  in tbrat_param_geral.inpessoa%type,
                                vr_tpproduto in tbrat_param_geral.tpproduto%type) IS
      SELECT qtmeses_expiracao_nota
        FROM tbrat_param_geral C
       WHERE cdcooper  = vr_cdcooper
         and inpessoa  = vr_inpessoa
         and tpproduto = vr_tpproduto;

    vr_dias_expiracao       INTEGER;
    vr_inrisco_rating       INTEGER;
    vr_data_rating_auto     DATE;
  ---------->> CURSORES <<--------
  CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER,
                      vr_tpctro IN INTEGER,
                      vr_nrctremp IN INTEGER) IS
    SELECT oper.Inrisco_Rating,
           oper.dtrisco_rating
      FROM tbrisco_operacoes oper
     WHERE oper.tpctrato = vr_tpctro
       AND oper.cdcooper = vr_cdcooper
       AND oper.nrdconta = vr_nrdconta
       AND oper.nrctremp = vr_nrctremp;


  CURSOR cr_crapass(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER) is
    SELECT ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrdconta = vr_nrdconta;

   vr_in_pessoa INTEGER;

  CURSOR  cr_contrato (vr_cdcooper IN INTEGER,
                       vr_nrdconta IN INTEGER,
                         vr_tpctro IN INTEGER,
                         vr_nrctro IN INTEGER) IS
   SELECT lim.dtpropos
     FROM craplim lim
    WHERE lim.nrctrlim = vr_nrctro
      AND lim.nrdconta = vr_nrdconta
      AND lim.tpctrlim = vr_tpctro
      AND lim.cdcooper = vr_cdcooper;

   vr_dtpropos DATE;
BEGIN


   RATI0003.pc_verifica_endivid_param(  pr_cdcooper    => pr_cdcooper,
                                        pr_nrdconta    => pr_nrdconta,
                                        pr_calc_rating => vr_calc_rating,
                                        pr_cdcritic    => vr_cdcritic,
                                        pr_dscritic    => vr_dscritic);

   IF  NVL(vr_cdcritic,0) > 0  OR
        TRIM(vr_dscritic) IS NOT NULL THEN
       vr_dscritic := vr_dscritic||' Não foi possível consultar Endividamento!';
       RAISE vr_exc_saida;
   END IF;
  IF NOT vr_calc_rating THEN
   -- SE NÃO TEM ENDIVIDAMENTO NO VALOR MAIOR QUE O PARAMETRIZADO PARA VALIDAR RATING
   -- SAI DA ROTINA!!
   RETURN;
  END IF;

   OPEN cr_contrato(  vr_cdcooper => pr_cdcooper,
                      vr_nrdconta => pr_nrdconta,
                      vr_tpctro   => pr_tpctrato,
                      vr_nrctro   => pr_nrctrato );
    FETCH cr_contrato
      INTO vr_dtpropos ;
    CLOSE cr_contrato;

     IF vr_dtpropos IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Não foi possível encontrar data da Proposta!';
       RAISE vr_exc_saida;
     END IF;

    -- 3° Busco tipo pessoa 1 - fisica 2 juridica
    OPEN  cr_crapass(vr_cdcooper => pr_cdcooper,
                     vr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO vr_in_pessoa;
    CLOSE cr_crapass;

    -- 4° Busco quando dias possiveis para não precisar reenviar o rating
    OPEN CR_TBRAT_PARAM_GERAL(vr_cdcooper  => pr_cdcooper,
                              vr_inpessoa  => vr_in_pessoa,
                              vr_tpproduto => vr_tpproduto);

     FETCH cr_tbrat_param_geral
      INTO vr_dias_expiracao ;
     CLOSE cr_tbrat_param_geral;



  -- busco informações de operações
  OPEN cr_operacoes(vr_cdcooper => pr_cdcooper,
                    vr_nrdconta => pr_nrdconta,
                    vr_tpctro   => pr_tpctrato,
                    vr_nrctremp => pr_nrctrato);
  FETCH cr_operacoes
    INTO vr_inrisco_rating, vr_data_rating_auto ;
  CLOSE cr_operacoes;
 IF vr_inrisco_rating IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Essa operação  não possui Rating.Será necessário Analizar Rating!';
       RAISE vr_exc_saida;
 END IF;

    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

 IF  rw_crapdat.dtmvtolt < vr_data_rating_auto   + NVL(vr_dias_expiracao,0)THEN
        vr_dscritic := 'Será necessário Analizar Rating! ' || vr_tpproduto ||
                      vr_cdcooper || ' Conta: ' || pr_nrdconta;
        vr_cdcritic := 0;
    RAISE vr_exc_saida;
 END IF;

 EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina RATI0003.pc_busca_rat_expirado '||SQLERRM;
        ROLLBACK;


END pc_busca_rat_expirado;


 PROCEDURE pc_valida_rat_expirado(  pr_nrdconta IN INTEGER, --> CONTA
                                    pr_nrctro   IN INTEGER, --CONTRATO
                                    pr_tpctro   IN INTEGER,
                                    pr_xmllog   IN VARCHAR2, --> XML com informações de LOG
                                    pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                    pr_dscritic OUT VARCHAR2, --> Descrição da crítica
                                    pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                    pr_nmdcampo OUT VARCHAR2, --> Nome do campo com erro
                                    pr_des_erro OUT VARCHAR2) IS

   /* ..........................................................................

  Programa: pc_valida_rat_expirado
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Daniele Rocha
  Data    : Março/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Valida ao efetivar proposta de limite de crédito e Cheque!!
              validação com o parametro da Parrat se tal proposta poderá ser efetivada !

  Alteracoes:

  ............................................................................. */

  ----------->>> VARIAVEIS <<<--------
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  vr_tpctrato INTEGER;
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper       INTEGER;
  vr_cdoperad       VARCHAR2(100);
  vr_nmdatela       VARCHAR2(100);
  vr_nmeacao        VARCHAR2(100);
  vr_cdagenci       VARCHAR2(100);
  vr_nrdcaixa       VARCHAR2(100);
  vr_idorigem       VARCHAR2(100);
  vr_incontingencia INTEGER;
  vr_cooperativa    INTEGER;
  vr_calc_rating    BOOLEAN;
  -- paramentro a mais retornado xml para servir como parametro da consulta
  rw_crapdat                           btch0001.cr_crapdat%ROWTYPE;
  ---------->> CURSORES <<--------
  CURSOR cr_tbrat_param_geral(vr_cdcooper  IN tbrisco_central_parametros.cdcooper%TYPE
                             ,vr_inpessoa  IN tbrat_param_geral.inpessoa%TYPE
                             ,vr_tpproduto IN tbrat_param_geral.tpproduto%TYPE) IS
      SELECT qtmeses_expiracao_nota
        FROM tbrat_param_geral C
       WHERE cdcooper  = vr_cdcooper
         and inpessoa  = vr_inpessoa
         and tpproduto = vr_tpproduto;

    vr_emprestimosfinan     INTEGER DEFAULT(90);
    vr_lim_descontocheque   INTEGER DEFAULT(2);
    vr_lim_descontotitulo   INTEGER DEFAULT(3);
    vr_limite_credito       INTEGER DEFAULT(1);
    vr_dias_expiracao       INTEGER;
    vr_inrisco_rating       INTEGER;
    vr_data_rating_auto     DATE;
  ---------->> CURSORES <<--------
  CURSOR cr_operacoes(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER,
                      vr_tpctro IN INTEGER,
                      vr_nrctremp IN INTEGER) IS
    SELECT oper.Inrisco_Rating,
           oper.dtrisco_rating
      FROM tbrisco_operacoes oper
     WHERE oper.tpctrato = vr_tpctro
       AND oper.cdcooper = vr_cdcooper
       AND oper.nrdconta = vr_nrdconta
       AND oper.nrctremp = vr_nrctremp;


  CURSOR cr_crapass(vr_cdcooper IN INTEGER,
                      vr_nrdconta IN INTEGER) is
    SELECT ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrdconta = vr_nrdconta;

   vr_in_pessoa INTEGER;

  CURSOR  cr_contrato (vr_cdcooper IN INTEGER,
                       vr_nrdconta IN INTEGER,
                         vr_tpctro IN INTEGER,
                         vr_nrctro IN INTEGER) IS
   SELECT lim.dtpropos
     FROM craplim lim
    WHERE lim.nrctrlim = vr_nrctro
      AND lim.nrdconta = vr_nrdconta
      AND lim.tpctrlim = vr_tpctro
      AND lim.cdcooper = vr_cdcooper;

   vr_dtpropos DATE;
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


   RATI0003.pc_verifica_endivid_param(  pr_cdcooper    => vr_cdcooper,
                                        pr_nrdconta    => pr_nrdconta,
                                        pr_calc_rating => vr_calc_rating,
                                        pr_cdcritic    => vr_cdcritic,
                                        pr_dscritic    => vr_dscritic);

   IF  NVL(vr_cdcritic,0) > 0  OR
        TRIM(vr_dscritic) IS NOT NULL THEN
       vr_dscritic := vr_dscritic||' Não foi possível consultar Endividamento!';
       RAISE vr_exc_saida;
   END IF;
  IF NOT vr_calc_rating THEN
   -- SE NÃO TEM ENDIVIDAMENTO NO VALOR MAIOR QUE O PARAMETRIZADO PARA VALIDAR RATING
   -- SAI DA ROTINA!!
   RETURN;
  END IF;

   OPEN cr_contrato(  vr_cdcooper => vr_cdcooper,
                      vr_nrdconta => pr_nrdconta,
                      vr_tpctro   => pr_tpctro,
                      vr_nrctro   => pr_nrctro );
    FETCH cr_contrato
      INTO vr_dtpropos ;
    CLOSE cr_contrato;

     IF vr_dtpropos IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Não foi possível encontrar data da Proposta!';
       RAISE vr_exc_saida;
     END IF;

    -- 3° Busco tipo pessoa 1 - fisica 2 juridica
    OPEN  cr_crapass(vr_cdcooper => vr_cdcooper,
                     vr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO vr_in_pessoa;
    CLOSE cr_crapass;

    -- 4° Busco quando dias possiveis para não precisar reenviar o rating
    OPEN CR_TBRAT_PARAM_GERAL(vr_cdcooper  => vr_cdcooper,
                              vr_inpessoa  => vr_in_pessoa,
                              vr_tpproduto => pr_tpctro);

     FETCH cr_tbrat_param_geral
      INTO vr_dias_expiracao ;
     CLOSE cr_tbrat_param_geral;



  -- busco informações de operações
  OPEN cr_operacoes(vr_cdcooper => vr_cdcooper,
                    vr_nrdconta => pr_nrdconta,
                    vr_tpctro   => pr_tpctro,
                    vr_nrctremp => pr_nrctro);
  FETCH cr_operacoes
    INTO vr_inrisco_rating, vr_data_rating_auto ;
  CLOSE cr_operacoes;
 IF vr_inrisco_rating IS NULL THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Essa operação  não possui Rating.Será necessário Analizar Rating!';
       RAISE vr_exc_saida;
 END IF;

    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

 IF  rw_crapdat.dtmvtolt < vr_data_rating_auto   + NVL(vr_dias_expiracao,0)THEN
        vr_dscritic := 'Será necessário Analizar Rating! ' || pr_tpctro ||
                      vr_cdcooper || ' Conta: ' || pr_nrdconta;
        vr_cdcritic := 0;
    RAISE vr_exc_saida;
 END IF;

  -- PASSA OS DADOS PARA O XML RETORNO
  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Dados',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  -- Insere as tags
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Dados',
                         pr_posicao  => 0,
                         pr_tag_nova => 'inf',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);

  -- campos
  -- 1   cooperativa
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'vr_cdcooper',
                         pr_tag_cont => to_char(vr_cdcooper),
                         pr_des_erro => vr_dscritic);
  -- 2 Conta
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrdconta',
                         pr_tag_cont => to_char(pr_nrdconta),
                         pr_des_erro => vr_dscritic);

    -- 3 Contrato
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_nrctro',
                         pr_tag_cont => to_char(pr_nrctro),
                         pr_des_erro => vr_dscritic);


  -- 4 tipo contrato
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_tpctro',
                         pr_tag_cont => to_char(pr_tpctro),
                         pr_des_erro => vr_dscritic);


    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'inf',
                         pr_posicao  => vr_auxconta,
                         pr_tag_nova => 'pr_dias_expiracao',
                         pr_tag_cont => to_char(vr_dias_expiracao),
                         pr_des_erro => vr_dscritic);

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
    -- Existe para satisfazer exigência da interface.
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
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic ||
                                   '</Erro></Root>');
    ROLLBACK;
END pc_valida_rat_expirado;


 PROCEDURE pc_verifica_continge_rating(pr_cdcooper   IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                      ,pr_tpctrato   IN PLS_INTEGER DEFAULT 0               --> Tipo do contrato de rating
                                      ,pr_inpessoa   IN crapass.inpessoa%TYPE               --> Tipo de pessoa
                                      ,pr_inconting OUT tbrat_param_geral.incontingencia%TYPE --> indicador de incontingencia do rating
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE               --> Critica encontrada no processo
                                      ,pr_dscritic  OUT VARCHAR2) IS                        --> Descritivo do erro

  /* .............................................................................

   programa: pc_verifica_continge_rating
   sistema : seguros - cooperativa de credito
   autor   : Elton - AMcom
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado
   objetivo  : Rotina que verifica se o parametro de contigencia do rating está ativo
  ..............................................................................*/


   -- Verificar parâmetro de Contingência na PAREST para o produto (EMPR/DSC TIT)
   CURSOR   cr_parest IS
   SELECT GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'CONTIGENCIA_ESTEIRA_IBRA') contingencia_epr
          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC') contingencia_tit
          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'CONTIGENCIA_ESTEIRA_CRD')  contingencia_crd
          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRED') analise_aut_epr
          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'ANALISE_OBRIG_MOTOR_DESC') analise_aut_tit
          ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                    pr_cdcooper => pr_cdcooper,
                                    pr_cdacesso => 'ANALISE_OBRIG_MOTOR_CRD')  analise_aut_crd
     --- Senão, se forem outros produtos, sempre falso.
   FROM dual;
   rw_parest cr_parest%ROWTYPE;

   -- BUSCA INDICADOR CONTINGENCIA NA PARRAT
   -- Contingencia é por Cooper e Produto, não mais por Pessoa
   CURSOR cr_tbrat_param IS
     SELECT MAX(a.incontingencia) incontingencia
       FROM tbrat_param_geral a
      WHERE a.cdcooper  = pr_cdcooper
        AND a.tpproduto = pr_tpctrato;

   rw_tbrat_param cr_tbrat_param%ROWTYPE;

  BEGIN

   pr_inconting := 0;

   --Se = 1 contingencia PAREST ligado
   OPEN  cr_parest;
   FETCH cr_parest
      INTO rw_parest;
   CLOSE cr_parest;

   -- pr_tpctrato = 90 -Emprestimo
   IF    pr_tpctrato = 90 and rw_parest.contingencia_epr = 1  then
           pr_inconting := 1;
   --- pr_tpctrato = 3  -- Limite de Desconto de Título
   ELSIF pr_tpctrato = 3  and rw_parest.contingencia_tit = 1  then
           pr_inconting := 1;
   ELSE -- todos os demais casos é desligado.
           pr_inconting := 0;
   END IF;

   IF pr_inconting = 0 THEN
     -- pr_tpctrato = 90 -Emprestimo
     IF pr_tpctrato = 90 and rw_parest.analise_aut_epr = 0  then
        pr_inconting := 1;
     -- pr_tpctrato = 3  -- Limite de Desconto de Título
     ELSIF pr_tpctrato = 3  and rw_parest.analise_aut_tit = 0  then
       pr_inconting := 1;
     ELSE -- todos os demais casos é desligado.
       pr_inconting := 0;
     END IF;
   END IF;


   IF pr_inconting = 0 THEN
     -- Verifica se contingencia PARRAT ligada (1-sim 0-não)
     OPEN  cr_tbrat_param;
     FETCH cr_tbrat_param
        INTO rw_tbrat_param;
     CLOSE cr_tbrat_param;
     pr_inconting := nvl(rw_tbrat_param.incontingencia,0);
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina pc_verifica_continge_rating: ' ||
                     SQLERRM;

  END pc_verifica_continge_rating;

  --- grava rating contingencia
  PROCEDURE pc_grava_rat_contingencia(pr_cdcooper   IN crapcop.cdcooper%TYPE                                 --> Código da Cooperativa
                                     ,pr_nrdconta   IN crapass.nrdconta%TYPE                                 --> Conta do associado
                                     ,pr_tpctrato   IN PLS_INTEGER DEFAULT 0                                 --> Tipo do contrato de rating
                                     ,pr_nrctrato   IN PLS_INTEGER DEFAULT 0                                 --> Número do contrato do rating
                                     ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE                                 --> Data de movimentacao
                                     ,pr_cdoperad   IN crapnrc.cdoperad%TYPE                                 --> Código do operador
                                     ,pr_strating   IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                     ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                                 --> Critica encontrada no processo
                                     ,pr_dscritic  OUT VARCHAR2) IS                                          --> Descritivo do erro

  /* .............................................................................

   programa: pc_grava_rat_contingencia
   sistema : seguros - cooperativa de credito
   autor   : Elton - AMcom
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado
   objetivo  : Rotina grava o rating contigencia
  ..............................................................................*/
  ----------->>> variaveis <<<--------
  -- variável de críticas
  vr_cdcritic              crapcri.cdcritic%type; --> cód. erro
  vr_dscritic              VARCHAR2(1000); --> desc. erro

  vr_exc_erro              EXCEPTION;

  vr_retxml         XMLType;

     -- Busca do nr cpfcnpj base do associado
   CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                         ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
   SELECT  ass.nrcpfcnpj_base
      FROM crapass ass
   WHERE ass.cdcooper  = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
   rw_crapass_ope   cr_crapass_ope%ROWTYPE;

   vr_innivris    tbrisco_operacoes.inrisco_rating%TYPE;

  BEGIN

    OPEN cr_crapass_ope(pr_cdcooper
                       ,pr_nrdconta);
    FETCH cr_crapass_ope INTO rw_crapass_ope;
    CLOSE cr_crapass_ope;
    -- busca o rating contingencia
    pc_busca_rat_contigencia( pr_cdcooper => pr_cdcooper,
                              pr_nrcpfcgc => rw_crapass_ope.nrcpfcnpj_base, --> CPFCNPJ BASE
                              pr_innivris => vr_innivris,                   --> risco contingencia
                              pr_cdcritic  => vr_cdcritic,
                              pr_dscritic  => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
    END IF;

    -- grava o rating contingencia
    RATI0003.pc_grava_rating_operacao(pr_cdcooper         => pr_cdcooper  --> Código da Cooperativa
                                     ,pr_nrdconta         => pr_nrdconta  --> Conta do associado
                                     ,pr_tpctrato         => pr_tpctrato  --> Tipo do contrato de rating
                                     ,pr_nrctrato         => pr_nrctrato  --> Número do contrato do rating

                                     ,pr_ntrataut         => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                     ,pr_dtrataut         => pr_dtmvtolt  --> Data do Rating retornado do MOTOR

                                     ,pr_strating         => pr_strating  --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                     ,pr_orrating         => 4            --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                     ,pr_cdoprrat         => pr_cdoperad  --> Codigo Operador que Efetivou o Rating
                                     ,pr_nrcpfcnpj_base   => rw_crapass_ope.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                     ,pr_cdoperad        => '1'
                                     ,pr_dtmvtolt        => pr_dtmvtolt   --rw_crapdat.dtmvtolt
                                     ,pr_cdcritic        => vr_cdcritic
                                     ,pr_dscritic        => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina pc_grava_rat_contingencia: ' ||
                     SQLERRM;

  END pc_grava_rat_contingencia;

  -- verifica o endividamento e se calcula rating para o mesmo
  PROCEDURE pc_verifica_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                     ,pr_nrdconta     IN crapass.nrdconta%TYPE                                 --> Conta do associado
                                     ,pr_calc_rating OUT BOOLEAN                             --> indicador de calcula rating (True False)
                                     ,pr_cdcritic    OUT crapcri.cdcritic%TYPE               --> Critica encontrada no processo
                                     ,pr_dscritic    OUT VARCHAR2) IS                        --> Descritivo do erro

  /* .............................................................................

   programa: pc_verifica_endivid_param
   sistema : seguros - cooperativa de credito
   autor   : Elton - AMcom
   data    : março/2019                 ultima atualizacao:

   dados referentes ao programa:

   frequencia: sempre que for chamado
   objetivo  : Rotina que verifica se o valor de endividamento é maior que o
               que o valor da TAB056 (parâmetro) e só vai acionar
               o motor/contingencia rating se o valor for maior.
  ..............................................................................*/
  ----------->>> variaveis <<<--------
  -- variável de críticas
   vr_cdcritic              crapcri.cdcritic%type; --> cód. erro
   vr_dscritic              VARCHAR2(1000); --> desc. erro

   vr_exc_erro              EXCEPTION;

   vr_opt_vlendivi  NUMBER(17,2);

   -- buscar o Valor do Rating do parâmetro (TAB056), da posição 15, com 11 caracteres.
   CURSOR   cr_tab056 IS
   SELECT gene0002.fn_char_para_number(  SUBSTR(
             TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'GENERI'
                          ,pr_cdempres => 00
                          ,pr_cdacesso => 'PROVISAOCL'
                          ,pr_tpregist => 999),15,11)) vlrtab056
     FROM dual;

   rw_tab056 cr_tab056%ROWTYPE;

   rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN


    -- Verificação do calendário
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    --> Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      --> Montar mensagem de critica
      vr_dscritic:= gene0001.fn_busca_critica(1);
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      --> Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    OPEN  cr_tab056;
    FETCH cr_tab056
      INTO rw_tab056;
    CLOSE cr_tab056;

    GECO0001.pc_calc_endividamento_individu(pr_cdcooper    => pr_cdcooper
                                           ,pr_cdagenci    => 1               --> cód. agencia
                                           ,pr_nrdcaixa    => 1               --> número do caixa
                                           ,pr_cdoperad    => 1               --> operador
                                           ,pr_nmdatela    => 'RATING'
                                           ,pr_idorigem    => 5               --> AYLLOS WEB - Aimaro
                                           ,pr_nrctasoc    => pr_nrdconta     --> Conta Cooperado
                                           ,pr_idseqttl    => 1
                                           ,pr_tpdecons    => TRUE
                                           ,pr_vlutiliz    => vr_opt_vlendivi --> OUT Valor do Endividamento
                                           ,pr_cdcritic    => vr_cdcritic
                                           ,pr_des_erro    => vr_dscritic
                                           ,pr_tab_crapdat => rw_crapdat      --> IN datas
                                           );

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
    END IF;

   --Se o valor do parâmetro retornado da GEOC0001 for maior que o valor da TAB056 deve calcular rating.
   IF nvl(vr_opt_vlendivi,0) > rw_tab056.vlrtab056 THEN
      pr_calc_rating := TRUE;
   ELSE
      pr_calc_rating := FALSE;
   END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina pc_verifica_endivid_param: ' ||
                     SQLERRM;

  END pc_verifica_endivid_param;


  PROCEDURE pc_ret_tbrisco_operacoes(pr_cdcooper    IN  tbrisco_operacoes.cdcooper%TYPE         --codigo que identifica a cooperativa
                              ,pr_nrdconta    IN  tbrisco_operacoes.nrdconta%TYPE           -- Numero da conta/dv do associado.
                              ,pr_tpctrato    IN  tbrisco_operacoes.tpctrato%TYPE default null --tipo de contrato utilizado por esta linha de credito
                              ,pr_nrctremp    IN  tbrisco_operacoes.nrctremp%TYPE default null -- Numero do contrato de emprestimo.
                              ,pr_inrisco     IN  tbrisco_operacoes.inrisco_rating%TYPE default null --nivel de risco rating efetivo
                              ,pr_tab_risco_op OUT RATI0003.typ_tab_risco_op
                              ,pr_erro         OUT VARCHAR2) AS


    --    Autor   : Elton (AMcom)
    --    Data    : 03/2019.                         Ultima atualizacao:
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado
    --
    --    Objetivo  : Retorna informações da linha de credito fixa (antiga) e da linha de
    --               credito variável (com várias taxas)

--crawepr  -- tabela proposta
--crapepr  -- tabela emprestimo

  -- Busca os dados  linha de credito

    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                  --   ,pr_cdlcremp   IN craplcr.cdlcremp%TYPE
                     ,pr_tpctrato   IN craplcr.tpctrato%TYPE) IS
    select a.*, rowid
    from  craplcr a
    where/* a.cdlcremp = nvl(pr_cdlcremp,a.cdlcremp)
    and  */ a.cdcooper = nvl(pr_cdcooper,a.cdcooper)
   /* and   a.tpctrato = nvl(pr_tpctrato,a.tpctrato)
    and   a.dslcremp = nvl(pr_dslcremp,a.dslcremp)
    and   a.cdusolcr = nvl(pr_cdusolcr,a.cdusolcr)
    and   a.flgstlcr = nvl(pr_flgstlcr,a.flgstlcr)
    and   a.cdmodali = nvl(pr_cdmodali,a.cdmodali)
    and   a.dsorgrec = nvl(pr_dsorgrec,a.dsorgrec)
    and   a.flgsaldo = nvl(pr_flgsaldo,a.flgsaldo)*/
    order by a.cdlcremp;


   vr_index    PLS_INTEGER;
   ww_teste  number(10);
  BEGIN

        FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper
                                 --   ,pr_cdlcremp => pr_cdlcremp
                                    ,pr_tpctrato => pr_tpctrato ) LOOP

             vr_index:= vr_tab_risco_op.count+1;
             vr_tab_risco_op(vr_index).cdlcremp := rw_craplcr.cdlcremp;
             vr_tab_risco_op(vr_index).dslcremp := rw_craplcr.dslcremp;
             vr_tab_risco_op(vr_index).flgstlcr := rw_craplcr.flgstlcr;
             vr_tab_risco_op(vr_index).nrgrplcr := rw_craplcr.nrgrplcr;
             vr_tab_risco_op(vr_index).txmensal := rw_craplcr.txmensal;
             vr_tab_risco_op(vr_index).txdiaria := rw_craplcr.txdiaria;
             vr_tab_risco_op(vr_index).txjurfix := rw_craplcr.txjurfix;
             vr_tab_risco_op(vr_index).rowid_aux := rw_craplcr.rowid;

        END LOOP;

 --    ww_teste := vr_tab_risco_op.count;
     pr_tab_risco_op := vr_tab_risco_op;

  EXCEPTION
        WHEN OTHERS THEN
          pr_erro := 'Erro não tratado na rotina RATI0003 - pc_ret_tbrisco_operacoes: ' || SQLERRM;


  END pc_ret_tbrisco_operacoes;

  --> Atualização do rating via JOB
  PROCEDURE pc_job_rating (pr_cdcritic    OUT PLS_INTEGER     --> Critica encontrada no processo
                          ,pr_dscritic    OUT VARCHAR2) IS    --> Descritivo do erro
  /*.............................................................................

  Procedure : PC_ATUALIZA_RATING
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  JOB     : JBATUALIZARATING
  Autor   : Mario Cesar Bernat
  Data    : Março/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Atualizar o Rating Operações na Ailos a partir do ODI-SAS/IBRATAN

      Alteracoes:

                08/04/2019 - atribuir valor padrão caso não encontre Nível do Rating (Mário - AMcom).

                16/05/2019 - inclusão de parametro ATRIBUI RATING LOTE (Mário - AMcom).

                24/05/2019 - ajuste na seleção de contratos incluindo a condição de 4-efetivados (Mário - AMcom).

                19/08/2019 - P450 - Adicionado rotina para respeitar parametro PARRAT
                             (Weverton Otoni - AMcom)

                16/08/2019 - P450 - Estória 25229 - Pré-aprovado - GRAVAR RATING DO LIMITE: (LOTE)
                             Gravar rating para os Empréstimos Pré-Aprovado (Finalidade 68) conforme
                             Rating do limite de crédito Pré-Aprovado (Finalidade 68).
                             Quando acontecer a manutenção do limite de crédito do Pré-Aprovado, todos
                             os empréstimos contratados com a finalidade 68 deverão ser atualizados com
                             o novo Rating calculado para o Limite do Pré-Aprovado.
                             (Marcelo Elias Gonçalves - AMCOM)

                20/08/2019 - P450 - Estória 25229 - Pré-aprovado - GRAVAR RATING DO LIMITE: (LOTE)
                             Buscar os Empréstimos (Finalidade 68) através do CPF/CNPJ Base do Associado.
                             (Marcelo Elias Gonçalves - AMCOM)

                23/08/2019 - P450 - Estória 25229(SM01 - Data de Corte do Rating) - Pré-aprovado - GRAVAR RATING
                             DO LIMITE: (LOTE)
                             Gravar rating para os Empréstimos Pré-Aprovado (Finalidade 68) se a data de
                             corte for menor que a data do parametro DT_CORTE_REFOR_RATING (CRAPPRM).
                             Quando acontecer a manutenção do limite de crédito do Pré-Aprovado, todos os
                             empréstimos contratados com a finalidade 68 deverão ser atualizados com o novo
                             Rating calculado para o Limite do Pré-Aprovado, deste que a data de corte seja
                             maior ou igual a data do parametro DT_CORTE_REFOR_RATING (CRAPPRM).
                             (Marcelo Elias Gonçalves - AMCOM)

                23/08/2019 - P450 - Estória 25581 - Processo de Lote / Job
                             Buscar o retorno da Ibratan apenas quando o parâmetro "Rating Modelo Ibratan"
                             estiver ligado; Todo rating processado pelo Lote deverá ser gravado como
                             Efetivo (Situação 4); Remover atualização para 0 do Flag Integrar SAS.
                             (Weverton Otoni - AMcom)

                24/08/2019 - P450 - Estória 23342 - LOTE - Exclusão do Rating no Sistema
                             Enviar apenas operações com Rating Vencido e que estão ativas;
                             Limites de desconto de cheque e título que estiverem com a
                             situação Cancelado e Vigente e tiverem borderôs ativos deverá
                             ser enviado para o processo de atualização do Rating;
                             Enviar apenas os Limites, os borderôs irão receber o Rating do Limite.
                             (Weverton Otoni - AMcom)
                               
                30/08/2019 - P450 - Estória 25729 - Pré-Aprovado - Rating Contingência
                             cooperativas que não estiverem com o parâmetro de novo calculo habilitado
                             poderão utilizar o Rating de Contingência, ou seja, da central de Risco.
                             (Weverton Otoni - AMcom)
  --.............................................................................*/

  -- CURSORES


  --> Buscar o Risco Operacoes
  CURSOR cr_tbrisco_operacoes (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_dtrating IN DATE
                              ,pr_dtmvtolt IN DATE
                              ,pr_dtmvtopr IN DATE
                              ,pr_dtultdia IN DATE
                              ) IS
    --
    -- 90 - Empréstimos
    SELECT /*+ INDEX(erp CRAPEPR##CRAPEPR2) */
           epr.cdcooper    cdcooper
          ,epr.nrdconta    nrdconta
          ,epr.nrctremp    nrctrato
          ,opr.tpctrato    tpctrato
          ,2               tpsituacao -- Contrato ativo
          ,opr.rowid       row_id
      FROM crapepr epr
          ,tbrisco_operacoes opr
          ,tbrat_param_geral tpg
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = opr.cdcooper
       AND epr.nrdconta = opr.nrdconta
       AND epr.nrctremp = opr.nrctremp
       AND opr.flintegrar_sas = 0 -- Se ja esta no lote nao pesquisar novamente
       AND epr.inliquid = 0   -- Nao pode estar liquidado
       AND epr.inprejuz = 0   -- Nao pode estar em prejuizo
       AND ((epr.cdfinemp = 68 AND epr.dtmvtolt < pr_dtrating OR
             epr.cdfinemp <> 68)) -- Não pode trazer Empréstimo Pré-Aprovado (Finalidade 68) após a Data de Corte do Projeto Reformulação do Rating (23/08/2019 - Marcelo Gonçalves/AMcom)
       AND epr.cdcooper = tpg.cdcooper
       AND NVL(opr.inpessoa,1) = tpg.inpessoa  -- 16/09/2019 - Na falta considera como PF o parametro
       AND tpg.tpproduto = 90
       AND opr.inrisco_rating_autom IS NOT NULL
       AND opr.tpctrato = 90
       AND opr.flencerrado = 0 -- Contratos ativos
       AND ( (opr.insituacao_rating = 3)
        OR  ((opr.insituacao_rating = 4)
        AND  (opr.dtrisco_rating + DECODE(NVL(opr.innivel_rating,2)
                                         ,1, tpg.qtdias_atualizacao_autom_baixo
                                         ,2, tpg.qtdias_atualizacao_autom_medio
                                         ,3, tpg.qtdias_atualizacao_autom_alto) <= CASE
              WHEN pr_dtmvtopr < to_date(tpg.qtdias_atencede_atualizacao+1||to_char(pr_dtmvtolt,'/MM/YYYY'),'DD/MM/YYYY')
              THEN pr_dtmvtolt+1
              ELSE pr_dtultdia END))
           )
       AND to_char(pr_dtmvtolt,'DD') NOT BETWEEN tpg.qtdias_atencede_atualizacao+1 AND to_char(pr_dtultdia,'DD')
    UNION ALL
    --  1-Limite de Credito
    --  2-Limite Desconto Cheque
    --  3-Desconto de Títulos
    SELECT /*+ INDEX(lim CRAPLIM##CRAPLIM1) */
           lim.cdcooper    cdcooper
          ,lim.nrdconta    nrdconta
          ,lim.nrctrlim    nrctrato
          ,opr.tpctrato    tpctrato
          ,lim.insitlim    tpsituacao
          ,opr.rowid       row_id
      FROM craplim lim
          ,tbrisco_operacoes opr
          ,tbrat_param_geral tpg
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.cdcooper = opr.cdcooper
       AND lim.nrdconta = opr.nrdconta
       AND lim.nrctrlim = opr.nrctremp
       AND lim.cdcooper = tpg.cdcooper
       AND opr.flintegrar_sas = 0 -- Se ja esta no lote nao pesquisar novamente
       AND NVL(opr.inpessoa,1) = tpg.inpessoa  -- 16/09/2019 - Na falta considera como PF o parametro
       AND opr.tpctrato IN (1,2,3) -- 1-Limite de Credito, 2-Limite Desconto Cheque, 3-Limite Desconto Titulo
       AND opr.flencerrado = 0 -- Contratos ativos
       AND lim.tpctrlim =  opr.tpctrato
       AND tpg.tpproduto = opr.tpctrato
       AND opr.inrisco_rating_autom IS NOT NULL
       AND ( (opr.insituacao_rating = 3)
        OR  ((opr.insituacao_rating = 4)
        AND  (opr.dtrisco_rating + DECODE(NVL(opr.innivel_rating,2)
                                         ,1, tpg.qtdias_atualizacao_autom_baixo
                                         ,2, tpg.qtdias_atualizacao_autom_medio
                                         ,3, tpg.qtdias_atualizacao_autom_alto) <= CASE
              WHEN pr_dtmvtopr < to_date(tpg.qtdias_atencede_atualizacao+1||to_char(pr_dtmvtolt,'/MM/YYYY'),'DD/MM/YYYY')
              THEN pr_dtmvtolt+1
              ELSE pr_dtultdia END))
           )
       AND to_char(pr_dtmvtolt,'DD') NOT BETWEEN tpg.qtdias_atencede_atualizacao+1 AND to_char(pr_dtultdia,'DD')
    UNION ALL
    -- 68 - Pré-Aprovado - (nrctremp = 0)
      SELECT /*+ INDEX(cpa CRAPCPA##CRAPCPA1) */
           cpa.cdcooper cdcooper
          ,cpa.nrdconta    nrdconta
          ,0               nrctrato
          ,opr.tpctrato    tpctrato
          ,2               tpsituacao -- Contrato ativo
          ,opr.rowid       row_id
      FROM crapcpa cpa
          ,tbepr_carga_pre_aprv pre
          ,tbrisco_operacoes opr
          ,tbrat_param_geral tpg
     WHERE cpa.cdcooper = pr_cdcooper
       AND pre.cdcooper = cpa.cdcooper
       AND pre.idcarga  = cpa.iddcarga
       AND pre.cdcooper = pr_cdcooper
       AND opr.flintegrar_sas = 0 -- Se ja esta no lote nao pesquisar novamente
       AND pre.flgcarga_bloqueada = 0  -- 0-Nao bloqueada
       AND pre.indsituacao_carga = 2   -- 2-Liberada
       AND NVL(pre.dtfinal_vigencia, trunc(pr_dtmvtolt)) >= trunc(pr_dtmvtolt) --Carga Vigente
       AND opr.cdcooper = cpa.cdcooper
       AND opr.nrcpfcnpj_base = cpa.nrcpfcnpj_base
       AND opr.nrctremp    = 0
       AND cpa.cdcooper = tpg.cdcooper
       AND NVL(cpa.tppessoa,1) = tpg.inpessoa  -- 16/09/2019 - Na falta considera como PF o parametro
       AND tpg.tpproduto = 90
       AND opr.tpctrato = 68
       AND opr.flencerrado = 0 -- Contratos ativos
       AND ( (opr.insituacao_rating = 3)
        or  ((opr.insituacao_rating = 4)
        and  (opr.dtrisco_rating + DECODE(NVL(opr.innivel_rating,2)
                                         ,1, tpg.qtdias_atualizacao_autom_baixo
                                         ,2, tpg.qtdias_atualizacao_autom_medio
                                         ,3, tpg.qtdias_atualizacao_autom_alto) <= CASE
              WHEN pr_dtmvtopr < to_date(tpg.qtdias_atencede_atualizacao+1||to_char(pr_dtmvtolt,'/MM/YYYY'),'DD/MM/YYYY')
              THEN pr_dtmvtolt+1
              ELSE pr_dtultdia END))
           )
       AND to_char(pr_dtmvtolt,'DD') NOT BETWEEN tpg.qtdias_atencede_atualizacao+1 AND to_char(pr_dtultdia,'DD');

    rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

  --> tbrisco_operacoes Informações do Rating
  CURSOR cr_tbrisco_operacoes_atu (pr_cdcooper  IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE           --> Conta do associado
                                  ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE --> Tipo do contrato de rating
                                  ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE --> Número do contrato do rating
                                  ) IS
    SELECT opr.insituacao_rating
          ,opr.inrisco_rating
          ,opr.dtrisco_rating
      FROM tbrisco_operacoes opr
     WHERE opr.cdcooper = pr_cdcooper
       AND opr.nrdconta = pr_nrdconta
       AND opr.nrctremp = pr_nrctrato
       AND opr.tpctrato = pr_tpctrato;
  rw_tbrisco_operacoes_atu cr_tbrisco_operacoes_atu%ROWTYPE;


  CURSOR cr_ass (pr_cdcooper       IN craptab.cdcooper%TYPE
                ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE) IS
    SELECT /*+ INDEX(ass CRAPASS##CRAPASS9) */
           ass.nrdconta
          ,ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper       = pr_cdcooper
       AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
       AND rownum = 1;
  rw_ass   cr_ass%ROWTYPE;

  --> Buscar o Controle Rating Carga
  CURSOR cr_tbrating_carga (pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT ca.idcarga, ca.cdcooper
      FROM cecred.tbrating_carga ca
     WHERE ca.cdcooper        = pr_cdcooper
       AND ca.dhfim_motor     IS NOT NULL
       AND ca.dhinicio_aimaro IS NULL
       AND ca.dhfim_aimaro    IS NULL
       AND nvl(ca.qtcontratos_motor, 0) > 0
     ORDER BY ca.idcarga;

  --> Buscar os Contratos Rating
  CURSOR cr_tbrating_contrato (pr_cdcooper IN craptab.cdcooper%TYPE
                              ,pr_idcarga  IN NUMBER
                              ,pr_tpctrato IN tbrating_contrato.tpctrato%TYPE DEFAULT NULL) IS
    SELECT co.skcontrato
          ,co.idcarga
          ,co.cdcooper
          ,co.nrdconta
          ,co.inpessoa
          ,co.tpctrato
          ,co.nrctrato
          ,co.nrcpfcnpj_base
            ,CASE
               WHEN co.dsrisco_rating = 'AA' THEN 1
                WHEN co.dsrisco_rating = 'A'  THEN 2
                WHEN co.dsrisco_rating = 'B'  THEN 3
                WHEN co.dsrisco_rating = 'C'  THEN 4
                WHEN co.dsrisco_rating = 'D'  THEN 5
                WHEN co.dsrisco_rating = 'E'  THEN 6
                WHEN co.dsrisco_rating = 'F'  THEN 7
                WHEN co.dsrisco_rating = 'G'  THEN 8
                WHEN co.dsrisco_rating = 'H'  THEN 9
                WHEN co.dsrisco_rating = 'HH' THEN 10
                ELSE 2 END
                                inrisco_rating
          ,CASE WHEN UPPER(co.dsnivel_rating) = 'NIVEL ALTO'  THEN 1
                WHEN UPPER(co.dsnivel_rating) = 'NIVEL MEDIO' THEN 2
                WHEN UPPER(co.dsnivel_rating) = 'NIVEL BAIXO' THEN 3
                ELSE 2 END
                                innivel_rating
          ,co.inscore_rating
          ,co.dssegmento_rating
          ,co.insituacao
          ,co.dssituacao
          ,co.inprocessado
          ,co.dtvigencia_rating
      FROM cecred.tbrating_contrato co
     WHERE co.cdcooper          = pr_cdcooper
       AND co.idcarga           = pr_idcarga
       AND co.tpctrato          = NVL(pr_tpctrato, co.tpctrato)
       AND nvl(co.insituacao,0) = 1
       AND co.inprocessado      = 0;
    rw_tbrating_contrato cr_tbrating_contrato%ROWTYPE;

  --> Cursor genérico de calendário
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,dat.dtultdia
          ,trunc(dat.dtmvtolt,'mm')                 dtinimes -- Pri. Dia Mes Corr.
          ,trunc(add_months(dat.dtmvtolt, 1), 'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))    dtultdma -- Ult. Dia Mes Ant.
          ,ROWID
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  --> Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3 -- Não deve rodar para a AILOS
     ORDER BY cop.cdcooper DESC;
    rw_crapcop cr_crapcop%ROWTYPE;

  --> Buscar Risco Operações(tbrisco_operacoes) de Limites de Crédito Pré-Aprovado
  CURSOR cr_limite_pre_aprovado(p_tpctrato IN tbrisco_operacoes.tpctrato%TYPE
                               ,p_cdcooper IN tbrisco_operacoes.cdcooper%TYPE
                               ,p_dtrisco_rating IN tbrisco_operacoes.dtrisco_rating%TYPE) IS
    SELECT t.cdcooper
          ,t.nrdconta
          ,t.inrisco_rating
          ,t.inrisco_rating_autom
          ,t.dtrisco_rating
          ,t.dtrisco_rating_autom
          ,t.insituacao_rating
          ,t.inorigem_rating
          ,t.cdoperad_rating
          ,t.innivel_rating
          ,t.nrcpfcnpj_base
          ,t.inpontos_rating
          ,t.insegmento_rating
     FROM tbrisco_operacoes  t
    WHERE t.cdcooper       = p_cdcooper
      AND t.tpctrato       = p_tpctrato
      AND t.dtrisco_rating = p_dtrisco_rating;
    rw_limite_pre_aprovado cr_limite_pre_aprovado%ROWTYPE;

  --> Buscar Empréstimos Pré-Aprovado
  CURSOR cr_empr_pre_aprovado(pr_cdfinemp       IN crapepr.cdfinemp%TYPE
                             ,pr_cdcooper       IN crapepr.cdcooper%TYPE
                             ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE
                             ,pr_dtrating       IN crapepr.dtmvtolt%TYPE) IS
    SELECT erp.cdcooper  cdcooper
          ,erp.nrdconta  nrdconta
          ,90            tpctrato
          ,erp.nrctremp  nrctrato
    FROM crapepr erp, crapass ass
    WHERE  erp.cdcooper       = ass.cdcooper
    AND    erp.nrdconta       = ass.nrdconta
    AND   (erp.inliquid = 0 OR (erp.inliquid = 1 AND erp.vlsdprej > 0)) --Não Liquidados
    AND    erp.cdfinemp       = pr_cdfinemp
    AND    erp.cdcooper       = pr_cdcooper
    AND    ass.nrcpfcnpj_base = pr_nrcpfcnpj_base
    AND    erp.inprejuz       = 0 -- Nao pode estar em prejuizo
    AND    erp.dtmvtolt      >= pr_dtrating; --Buscar Somente Empréstimos Pré-Aprovado (Finalidade 68) com data maior/igual a Data de Corte do Projeto Reformulação do Rating (23/08/2019 - Marcelo Gonçalves/AMcom)
    rw_empr_pre_aprovado cr_empr_pre_aprovado%ROWTYPE;

    --> Buscar Risco Operações de Limites de Crédito de Borderô(Pai) atualizado no dia
    CURSOR cr_limite_bordero(p_cdcooper       IN tbrisco_operacoes.cdcooper%TYPE
                            ,p_dtrisco_rating IN tbrisco_operacoes.dtrisco_rating%TYPE) IS
      -- Selecionar os limites que foram atualizados "Hoje"
      SELECT t.cdcooper
            ,t.nrdconta
            ,t.nrctremp
            ,t.tpctrato
            ,t.inrisco_rating
            ,t.inrisco_rating_autom
            ,t.dtrisco_rating
            ,t.dtrisco_rating_autom
            ,t.insituacao_rating
            ,t.inorigem_rating
            ,t.cdoperad_rating
            ,t.innivel_rating
            ,t.nrcpfcnpj_base
            ,t.inpontos_rating
            ,t.insegmento_rating
            ,t.flencerrado
        FROM tbrisco_operacoes t
       WHERE t.cdcooper = p_cdcooper
         AND t.tpctrato IN (2, 3)
         AND t.dtrisco_rating = p_dtrisco_rating;
    rw_limite_bordero cr_limite_bordero%ROWTYPE;

    --> Buscar Borderôs
    CURSOR cr_borderos(p_cdcooper IN tbrisco_operacoes.cdcooper%TYPE
                      ,p_nrdconta IN tbrisco_operacoes.nrdconta%TYPE
                      ,p_nrctremp IN tbrisco_operacoes.nrctremp%TYPE
                      ,p_tpctrato IN tbrisco_operacoes.tpctrato%TYPE) IS
      -- Selecionar os borderos associados ao limite
      -- 91 - Borderôs de descontos de Títulos
      SELECT bdt.cdcooper cdcooper
            ,bdt.nrdconta nrdconta
            ,bdt.nrborder nrctrato
            ,91           tpctrato
        FROM crapbdt bdt
       WHERE bdt.cdcooper = p_cdcooper
         AND bdt.nrdconta = p_nrdconta
         AND bdt.nrctrlim = p_nrctremp
         AND p_tpctrato = 3 -- Lim.Desc.Titulo
         AND bdt.flverbor = 1
         AND bdt.insitbdt IN (1, 2, 3)
      UNION ALL
      -- 92 - Borderôs de descontos de Cheques
      SELECT bdc.cdcooper cdcooper
            ,bdc.nrdconta nrdconta
            ,bdc.nrborder nrctrato
            ,92           tpctrato
        FROM crapbdc bdc
       WHERE bdc.cdcooper = p_cdcooper
         AND bdc.nrdconta = p_nrdconta
         AND bdc.nrctrlim = p_nrctremp
         AND p_tpctrato = 2; -- Lim.Desc.Cheque
    rw_borderos cr_borderos%ROWTYPE;

  --> Buscar Pre-Aprovados para Atualizar no modelo Aimaro
  CURSOR cr_pre_aprov_aimaro(pr_cdcooper  IN tbrisco_operacoes.cdcooper%TYPE
                            ,pr_dtmvtolt IN DATE) IS
    SELECT /*+ INDEX(crapcpa CRAPCPA##CRAPCPA1) */
           opr.cdcooper    cdcooper
          ,opr.nrdconta    nrdconta
          ,opr.nrctremp    nrctrato
          ,opr.tpctrato    tpctrato
          ,opr.nrcpfcnpj_base nrcpfcnpj_base
      FROM crapcpa cpa
          ,tbepr_carga_pre_aprv pre
          ,tbrisco_operacoes opr
          ,tbrat_param_geral tpg
     WHERE cpa.cdcooper = pr_cdcooper
       AND pre.cdcooper = cpa.cdcooper
       AND pre.idcarga  = cpa.iddcarga
       AND pre.flgcarga_bloqueada = 0  -- 0-Nao bloqueada
       AND pre.indsituacao_carga = 2   -- 2-Liberada
       AND NVL(pre.dtfinal_vigencia, trunc(pr_dtmvtolt)) >= trunc(pr_dtmvtolt) --Carga Vigente
       AND opr.cdcooper = cpa.cdcooper
       AND opr.nrcpfcnpj_base = cpa.nrcpfcnpj_base
       AND opr.nrctremp    = 0
       AND cpa.cdcooper = tpg.cdcooper
       AND NVL(cpa.tppessoa,1) = tpg.inpessoa  -- 16/09/2019 - Na falta considera como PF o parametro
       AND tpg.tpproduto   = 90
       AND opr.tpctrato = 68
       AND opr.flencerrado = 0 -- Contratos ativos
       AND opr.flintegrar_sas = 1;

  -- Parametros
  vr_dt_corte_refor_rating  DATE;
  vr_modelo_rating  tbrat_param_geral.tpmodelo_rating%TYPE;

  -- VARIAVEIS
  vr_cdcritic       PLS_INTEGER;
  vr_dscritic       VARCHAR2(4000);
  vr_dscritic_aux   VARCHAR2(400);
  vr_dtrefere       crapdat.dtmvtoan%TYPE;
  vr_exc_erro       EXCEPTION;

  vr_dtprocesso     DATE;
  vr_qtcontratos    NUMBER(12);
  vr_retxml         XMLType;
  vr_nrdrowid       ROWID;

  vr_strating       tbrisco_operacoes.insituacao_rating%TYPE;
  vr_dtrating       tbrisco_operacoes.dtrisco_rating%TYPE;
  vr_ntrating       tbrisco_operacoes.inrisco_rating%TYPE;
  vr_nrdconta       crapass.nrdconta%TYPE;
  vr_innivris       tbrisco_operacoes.inrisco_rating%TYPE;

    vr_qtde_commit NUMBER(4) := 1000;
    vr_cont_commit NUMBER(4) := 0;

  -- ----------------------------------------------------------
  BEGIN

    --23/08/2019 - Marcelo Gonçalves/AMcom
    --> Buscar Parametro Data de Corte do Projeto Reformulação do Rating
    vr_dt_corte_refor_rating := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                  pr_cdcooper => 0,
                                                                  pr_cdacesso => 'DT_CORTE_REFOR_RATING'),
                                        'dd/mm/rrrr');
    IF vr_dt_corte_refor_rating IS NULL THEN
      -- Se nao encontrou, assume data fixa
      vr_dt_corte_refor_rating := to_date('13/09/2019','dd/mm/yyyy');
    END IF;

    --> Buscar as cooperativas
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Inicializa variável auxiliar
      vr_dscritic_aux := NULL;

      -- Verificação do calendário
      OPEN  cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;

      IF cr_crapdat%NOTFOUND THEN
        CLOSE cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= '001 - Sistema sem data de movimento.';

        -- Forma a frase de erro para incluir no log
        vr_dscritic:= 'Erro: '||vr_dscritic;

        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;


      vr_modelo_rating := rati0003.fn_retorna_modelo_rating( pr_cdcooper => rw_crapcop.cdcooper ) ;


      -- Buscar Risco Operacoes
      FOR rw_tbrisco_operacoes IN cr_tbrisco_operacoes(pr_cdcooper => rw_crapcop.cdcooper
                                                      ,pr_dtrating => vr_dt_corte_refor_rating
                                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                      ,pr_dtultdia => rw_crapdat.dtultdia) LOOP
        BEGIN
          -- Para contratos de limite CHQ e TIT, deve ser verificado se
          -- esses contratos ainda estão ativos ou com borderos ativos,
          -- caso contrario, nao vai no lote
          -- Emprestimos e Pre-Aprov já sao tratados na query
          IF  rw_tbrisco_operacoes.tpctrato IN(2,3)
          AND rw_tbrisco_operacoes.tpsituacao NOT IN(1,2,3) THEN

              -- verificar se tem borderos ativos
              IF rati0003.fn_valida_limite_chq_tit(pr_cdcooper => rw_tbrisco_operacoes.cdcooper,
                                                   pr_nrdconta => rw_tbrisco_operacoes.nrdconta,
                                                   pr_nrctremp => rw_tbrisco_operacoes.nrctrato,
                                                   pr_tpctrato => rw_tbrisco_operacoes.tpctrato) = 0 THEN

                -- se nao houver bordero ativo, marca como Encerrado.
                UPDATE tbrisco_operacoes t
                   SET t.flencerrado = 1
                    ,t.flintegrar_sas = 0
                 WHERE ROWID = rw_tbrisco_operacoes.row_id;
                COMMIT;

                CONTINUE; -- Passa para o próximo e nao vai pro lote
              END IF;
          END IF;


          -- Atualiza FLAG Integração SAS
          UPDATE tbrisco_operacoes
             SET flintegrar_sas = 1
           WHERE ROWID = rw_tbrisco_operacoes.row_id;

          -- Commit parcial cada 1000 registros;
          vr_cont_commit := vr_cont_commit + 1;
          IF vr_cont_commit >= vr_qtde_commit THEN
            vr_cont_commit := 0;
            COMMIT;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --> Gerar informaçoes do log
            gene0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper,
                                 pr_cdoperad => 'MOTOR',
                                 pr_dscritic => 'Erro ao atualizar Flag Risco Operações (Parte 1). ' ||
                                                SQLERRM,
                                 pr_dsorigem => 'SAS',
                                 pr_dstransa => 'Processa Rating Operações',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, --> FALSE
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'JOBRAT',
                                 pr_nrdconta => rw_tbrisco_operacoes.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
        END;
      END LOOP;
      COMMIT;

      -- inicializa variável
      vr_qtcontratos := 0;

      -- Se Modelo Cálculo Rating = 2 - Ibratan
      IF vr_modelo_rating = 2 THEN

        -- INICIO DA LEITURA DOS RATINGS DA CARGA
        FOR rw_tbrating_carga IN cr_tbrating_carga(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          vr_dtprocesso := SYSDATE;

          -- Rating Contrato
          FOR rw_tbrating_contrato IN cr_tbrating_contrato(pr_cdcooper => rw_crapcop.cdcooper,
                                                           pr_idcarga  => rw_tbrating_carga.idcarga) LOOP

            vr_strating := 4; -- Conforme definição Ailos, registros atualizados pelo
            -- LOTE são sempre 4-Efetivo
            
            IF rw_tbrating_contrato.tpctrato = 68 THEN
              -- Para contratos 68-PreAprovado, o numero da conta nao vem
              -- Encontrar o primeiro para gravar o rating
              -- Na fase 2 nao será mais necessario esse bloco, pois será alterada a chave
              OPEN  cr_ass(pr_cdcooper       => rw_tbrating_contrato.cdcooper
                          ,pr_nrcpfcnpj_base => rw_tbrating_contrato.nrcpfcnpj_base);
              FETCH cr_ass INTO rw_ass;

              IF cr_ass%NOTFOUND THEN
                vr_nrdconta := 0;
              ELSE
                vr_nrdconta := rw_ass.nrdconta;
              END IF;
              CLOSE cr_ass;
            ELSE
              -- Assume a conta que veio na integração
              vr_nrdconta := rw_tbrating_contrato.nrdconta;
            END IF;

            -- Atualiza as informações do rating na tabela de operações
            RATI0003.pc_grava_rating_operacao
                                 (pr_cdcooper => rw_crapcop.cdcooper             --> Código da Cooperativa
                                 ,pr_nrdconta => vr_nrdconta                     --> Conta do associado
                                 ,pr_tpctrato => rw_tbrating_contrato.tpctrato   --> Tipo do contrato de rating
                                 ,pr_nrctrato => rw_tbrating_contrato.nrctrato   --> Número do contrato do rating

                                 ,pr_ntrating => rw_tbrating_contrato.inrisco_rating --> Nivel de Risco Rating EFETIVO
                                 ,pr_ntrataut => rw_tbrating_contrato.inrisco_rating  --> Nivel de Risco Rating retornado do MOTOR
                                 ,pr_dtrating => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating
                                 ,pr_dtrataut => rw_crapdat.dtmvtolt    --> Data do Rating retorn
                                 ,pr_strating => vr_strating    --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)

                                 ,pr_orrating           =>  1     --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_cdoprrat           =>  '1'   --> Codigo Operador que Efetivou o Ratingado do MOTOR
                                 ,pr_innivel_rating     => rw_tbrating_contrato.innivel_rating  --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                 ,pr_nrcpfcnpj_base     => rw_tbrating_contrato.nrcpfcnpj_base  --> Numero do CPF/CNPJ Base do associado
                                 ,pr_inpontos_rating    => rw_tbrating_contrato.inscore_rating  --> Pontuacao do Rating retornada do Motor

                                 ,pr_efetivacao_rating  => 1 -- Não deverá verificar a contingencia

                                 --Variáveis para gravar o histórico
                                 ,pr_inrisco_rat_inc    => NULL   --> Nivel de Rating da Inclusao da Proposta
                                 ,pr_innivel_rat_inc    => NULL   --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                 ,pr_inpontos_rat_inc   => NULL   --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                 ,pr_insegmento_rat_inc => NULL  --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                 ,pr_cdoperad           => '1'           --> Operador que gerou historico de rating
                                 ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                 ,pr_valor              => NULL          --> Valor Contratado/Operaca
                                 ,pr_rating_sugerido    => NULL   --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                 ,pr_justificativa      => 'Via LOTE - ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') --> Justificativa do operador para alteracao do Rating
                                 ,pr_tpoperacao_rating  => NULL   --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                 --Variáveis de crítica
                                 ,pr_cdcritic           => vr_cdcritic     --> Critica encontrada no processo
                                 ,pr_dscritic           => vr_dscritic);   --> Descritivo do erro
            -- Testa inconsistencia
            IF NVL(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) is not null then
               --> Gerar informaçoes do log
               GENE0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_cdoperad => 'MOTOR'
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_dsorigem => 'SAS'
                                   ,pr_dstransa => 'Processa Rating Operações'
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 1 --> FALSE
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'JOBRAT'
                                   ,pr_nrdconta =>  rw_tbrating_contrato.nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
            ELSE

              -- Atualiza FLAG Integração SAS
              -- Faz com que não necessite reenvio no dia seguinte
              BEGIN
                UPDATE tbrisco_operacoes ope
                   SET flintegrar_sas = 0
                 WHERE ope.cdcooper = rw_crapcop.cdcooper
                   AND ope.nrdconta = rw_tbrating_contrato.nrdconta
                   AND ope.nrctremp = rw_tbrating_contrato.nrctrato
                   AND ope.tpctrato = rw_tbrating_contrato.tpctrato
                   AND ope.nrcpfcnpj_base = rw_tbrating_contrato.nrcpfcnpj_base;
              EXCEPTION
                WHEN OTHERS THEN
                  --> Gerar informaçoes do log
                  GENE0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_cdoperad => 'MOTOR'
                                      ,pr_dscritic => 'Erro ao atualizar Flag Risco Operações. '||sqlerrm
                                      ,pr_dsorigem => 'SAS'
                                      ,pr_dstransa => 'Processa Rating Operações'
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 1 --> FALSE
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => 1
                                      ,pr_nmdatela => 'JOBRAT'
                                      ,pr_nrdconta =>  rw_tbrating_contrato.nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
              END;

              -- Busca quantidade de registros Atualizados
              BEGIN
                UPDATE cecred.tbrating_contrato
                   SET inprocessado = 1
                 WHERE skcontrato = rw_tbrating_contrato.skcontrato;
              EXCEPTION
                WHEN OTHERS THEN
                  --> Gerar informaçoes do log
                 GENE0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_cdoperad => 'MOTOR'
                                     ,pr_dscritic => 'Erro ao atualizar Rating Contrato. '||sqlerrm
                                     ,pr_dsorigem => 'SAS'
                                     ,pr_dstransa => 'Processa Rating Operações'
                                     ,pr_dttransa => TRUNC(SYSDATE)
                                     ,pr_flgtrans => 1 --> FALSE
                                     ,pr_hrtransa => gene0002.fn_busca_time
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => 'JOBRAT'
                                     ,pr_nrdconta =>  rw_tbrating_contrato.nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
              END;
            END IF;

            COMMIT;
          END LOOP;

          --> Buaca Total de Atualizações
          BEGIN
            SELECT COUNT(*)
              INTO vr_qtcontratos
              FROM cecred.tbrating_contrato r
             WHERE r.cdcooper = rw_crapcop.cdcooper
               AND r.idcarga  = rw_tbrating_carga.idcarga
               AND r.inprocessado = 1;
          EXCEPTION
            WHEN OTHERS THEN
              vr_qtcontratos := 0;
          END;

          --> Atualiza Carga
          BEGIN
            UPDATE cecred.tbrating_carga
               SET dhinicio_aimaro = vr_dtprocesso
                  ,dhfim_aimaro = SYSDATE
                  ,qtcontratos_atualizados = vr_qtcontratos
             WHERE cdcooper = rw_crapcop.cdcooper
               AND idcarga = rw_tbrating_carga.idcarga;
          EXCEPTION
            WHEN OTHERS THEN
                --> Gerar informaçoes do log
                GENE0001.pc_gera_log(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_cdoperad => 'MOTOR'
                                    ,pr_dscritic => 'Erro ao atualizar Rating Carga. '||sqlerrm
                                    ,pr_dsorigem => 'SAS'
                                    ,pr_dstransa => 'Processa Rating Operações'
                                    ,pr_dttransa => TRUNC(SYSDATE)
                                    ,pr_flgtrans => 1 --> FALSE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'JOBRAT'
                                    ,pr_nrdconta => 0
                                    ,pr_nrdrowid => vr_nrdrowid);
          END;
        END LOOP;
        COMMIT; -- Grava os registros vindos do lote
        -- FIM DA LEITURA DOS RATINGS DA CARGA

        -- REPASSE DO RATING DOs LIMITEs PARA OS CONTRATOS FILHOS

        --16/08/2019 - Marcelo Gonçalves/AMcom
        -- Atualizar os Empréstimos Pré-Aprovado(Filhos) com o Rating do Limite
        -- de Crédito Pré-Aprovado(Pai) que foram atualizados "hoje" nesse processo
        --
        --Busca Risco Operações de Limites de Crédito Pré-Aprovado(Pai)
        FOR rw_limite_pre_aprovado IN cr_limite_pre_aprovado(p_tpctrato       => 68 --Pré-Aprovado
                                                            ,p_cdcooper       => rw_crapcop.cdcooper
                                                            ,p_dtrisco_rating => rw_crapdat.dtmvtolt) LOOP
          --23/08/2019 - Marcelo Gonçalves/AMcom
          --Alterado para Buscar os Empréstimos Pré-Aprovado (Finalidade 68) com Data Maior ou Igual a Data de Corte do Projeto Reformulação do Rating
          --Busca Empréstimos Pré-Aprovado
          FOR rw_empr_pre_aprovado IN cr_empr_pre_aprovado(pr_cdfinemp       => 68 --Pré-Aprovado
                                                          ,pr_cdcooper       => rw_limite_pre_aprovado.cdcooper
                                                          ,pr_nrcpfcnpj_base => rw_limite_pre_aprovado.nrcpfcnpj_base
                                                          ,pr_dtrating       => vr_dt_corte_refor_rating) LOOP

            -- Atualiza as informações do rating na tabela de operações para os empréstimos pré-aprovados(Filhos)
            rati0003.pc_grava_rating_operacao(pr_cdcooper => rw_empr_pre_aprovado.cdcooper --> Código da Cooperativa
                                 ,pr_nrdconta => rw_empr_pre_aprovado.nrdconta --> Conta do associado
                                 ,pr_tpctrato => rw_empr_pre_aprovado.tpctrato --> Tipo do contrato de rating
                                 ,pr_nrctrato => rw_empr_pre_aprovado.nrctrato --> Número do contrato do rating

                                 ,pr_ntrating => rw_limite_pre_aprovado.inrisco_rating       --> Nivel de Risco Rating EFETIVO
                                 ,pr_ntrataut => rw_limite_pre_aprovado.inrisco_rating_autom --> Nivel de Risco Rating retornado do MOTOR
                                 ,pr_dtrating => rw_limite_pre_aprovado.dtrisco_rating       --> Data de Efetivacao do Rating
                                 ,pr_dtrataut => rw_limite_pre_aprovado.dtrisco_rating_autom --> Data do Rating retorn
                                 ,pr_strating => rw_limite_pre_aprovado.insituacao_rating    --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)

                                 ,pr_orrating          => rw_limite_pre_aprovado.inorigem_rating   --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_cdoprrat          => rw_limite_pre_aprovado.cdoperad_rating   --> Codigo Operador que Efetivou o Ratingado do MOTOR
                                 ,pr_innivel_rating    => rw_limite_pre_aprovado.innivel_rating    --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                 ,pr_nrcpfcnpj_base    => rw_limite_pre_aprovado.nrcpfcnpj_base    --> Numero do CPF/CNPJ Base do associado
                                 ,pr_inpontos_rating   => rw_limite_pre_aprovado.inpontos_rating   --> Pontuacao do Rating retornada do Motor

                                 ,pr_efetivacao_rating  => 1 -- Não deverá verificar a contingencia

                                 --Variáveis para gravar o histórico
                                 ,pr_inrisco_rat_inc    => NULL                                   --> Nivel de Rating da Inclusao da Proposta
                                 ,pr_innivel_rat_inc    => NULL                                   --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                 ,pr_inpontos_rat_inc   => NULL                                   --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                 ,pr_insegmento_rat_inc => NULL                                   --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                 ,pr_cdoperad           => rw_limite_pre_aprovado.cdoperad_rating --> Operador que gerou historico de rating
                                 ,pr_dtmvtolt           => rw_limite_pre_aprovado.dtrisco_rating  --> Data/Hora do historico de rating
                                 ,pr_valor              => NULL                                   --> Valor Contratado/Operaca
                                 ,pr_rating_sugerido    => NULL                                   --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                 ,pr_justificativa      => 'Via LOTE - Herdado do Limite' --> Justificativa do operador para alteracao do Rating
                                 ,pr_tpoperacao_rating  => NULL                                   --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                 --Variáveis de crítica
                                 ,pr_cdcritic           => vr_cdcritic   --> Critica encontrada no processo
                                 ,pr_dscritic           => vr_dscritic); --> Descritivo do erro
            -- Testa inconsistencia
            IF NVL(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) is not null then
               --> Gerar informaçoes do log
               GENE0001.pc_gera_log(pr_cdcooper => rw_empr_pre_aprovado.cdcooper
                                   ,pr_cdoperad => 'MOTOR'
                                   ,pr_dscritic => 'Erro ao gravar Rating do Empréstimo Pré-Aprovado: '||rw_empr_pre_aprovado.nrctrato||' utilizando Rating do Limite do Pré-Aprovado. Erro: '||vr_dscritic
                                   ,pr_dsorigem => 'SAS'
                                   ,pr_dstransa => 'Processa Rating Operações'
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 1 --> FALSE
                                   ,pr_hrtransa => gene0002.fn_busca_time
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'JOBRAT'
                                   ,pr_nrdconta => rw_empr_pre_aprovado.nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
            END IF;

            -- Commit parcial cada 1000 registros;
            vr_cont_commit := vr_cont_commit + 1;
            IF vr_cont_commit >= vr_qtde_commit THEN
              vr_cont_commit := 0;
              COMMIT;
            END IF;
          END LOOP;
        END LOOP;
        COMMIT; -- Grava os registros do Pre-Aprovado

        --24/08/2019 - Weverton Otoni/AMcom
        --Atualizar os Borderôs com o Rating do Limite(Pai)
        --
        --Busca Risco Operações de Limites(Pai) atualizados no dias.
        FOR rw_limite_bordero IN cr_limite_bordero(p_cdcooper       => rw_crapcop.cdcooper
                                                  ,p_dtrisco_rating => rw_crapdat.dtmvtolt) LOOP
          --Busca os Borderôs
          FOR rw_borderos IN cr_borderos(p_cdcooper => rw_limite_bordero.cdcooper,
                                         p_nrdconta => rw_limite_bordero.nrdconta,
                                         p_nrctremp => rw_limite_bordero.nrctremp,
                                         p_tpctrato => rw_limite_bordero.tpctrato) LOOP

            -- Atualiza as informações do rating na tabela de operações para os Borderôs
            -- baseado nas informações do LIMITE
            rati0003.pc_grava_rating_operacao(pr_cdcooper => rw_borderos.cdcooper --> Código da Cooperativa
                                             ,pr_nrdconta => rw_borderos.nrdconta --> Conta do associado
                                             ,pr_tpctrato => rw_borderos.tpctrato --> Tipo do contrato de rating
                                             ,pr_nrctrato => rw_borderos.nrctrato --> Número do contrato do rating

                                             ,pr_ntrating => rw_limite_bordero.inrisco_rating --> Nivel de Risco Rating EFETIVO
                                             ,pr_ntrataut => rw_limite_bordero.inrisco_rating_autom --> Nivel de Risco Rating retornado do MOTOR
                                             ,pr_dtrating => rw_limite_bordero.dtrisco_rating --> Data de Efetivacao do Rating
                                             ,pr_dtrataut => rw_limite_bordero.dtrisco_rating_autom --> Data do Rating retorn
                                             ,pr_strating => rw_limite_bordero.insituacao_rating --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)

                                             ,pr_orrating          => rw_limite_bordero.inorigem_rating --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                             ,pr_cdoprrat          => rw_limite_bordero.cdoperad_rating --> Codigo Operador que Efetivou o Ratingado do MOTOR
                                             ,pr_innivel_rating    => rw_limite_bordero.innivel_rating --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                             ,pr_nrcpfcnpj_base    => rw_limite_bordero.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                             ,pr_inpontos_rating   => rw_limite_bordero.inpontos_rating --> Pontuacao do Rating retornada do Motor

                                             ,pr_efetivacao_rating  => 1 -- Não deverá verificar a contingencia

                                              --Variáveis para gravar o histórico
                                             ,pr_inrisco_rat_inc    => NULL --> Nivel de Rating da Inclusao da Proposta
                                             ,pr_innivel_rat_inc    => NULL --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                             ,pr_inpontos_rat_inc   => NULL --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                             ,pr_insegmento_rat_inc => NULL --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                             ,pr_cdoperad           => rw_limite_bordero.cdoperad_rating --> Operador que gerou historico de rating
                                             ,pr_dtmvtolt           => rw_limite_bordero.dtrisco_rating --> Data/Hora do historico de rating
                                             ,pr_valor              => NULL --> Valor Contratado/Operaca
                                             ,pr_rating_sugerido    => NULL --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                             ,pr_justificativa      => 'Via LOTE - Herdado do Limite' --> Justificativa do operador para alteracao do Rating
                                             ,pr_tpoperacao_rating  => NULL --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                              --Variáveis de crítica
                                             ,pr_cdcritic => vr_cdcritic --> Critica encontrada no processo
                                             ,pr_dscritic => vr_dscritic); --> Descritivo do erro
            -- Testa inconsistencia
            IF nvl(vr_cdcritic, 0) > 0
               OR TRIM(vr_dscritic) IS NOT NULL THEN
              --> Gerar informaçoes do log
              gene0001.pc_gera_log(pr_cdcooper => rw_borderos.cdcooper,
                                   pr_cdoperad => 'MOTOR',
                                   pr_dscritic => 'Erro ao gravar Rating de Borderô: ' ||
                                                  rw_borderos.nrctrato ||
                                                  ' utilizando Rating do Limite. Erro: ' ||
                                                  vr_dscritic,
                                   pr_dsorigem => 'SAS',
                                   pr_dstransa => 'Processa Rating Operações',
                                   pr_dttransa => trunc(SYSDATE),
                                   pr_flgtrans => 1, --> FALSE
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'JOBRAT',
                                   pr_nrdconta => rw_borderos.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
            END IF;

            -- Commit parcial cada 1000 registros;
            vr_cont_commit := vr_cont_commit + 1;
            IF vr_cont_commit >= vr_qtde_commit THEN
              vr_cont_commit := 0;
              COMMIT;
            END IF;
          END LOOP;
        END LOOP;
        COMMIT; -- Grava os registros dos Borderos do Limite
        --
      ELSIF vr_modelo_rating = 1 THEN -- Modelo Cálculo Rating = 1 - Aimaro
        FOR rw_pre_aprov_aimaro IN cr_pre_aprov_aimaro(pr_cdcooper => rw_crapcop.cdcooper
                                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
          pc_busca_rat_contigencia(pr_cdcooper => rw_pre_aprov_aimaro.cdcooper,
                                   pr_nrcpfcgc => rw_pre_aprov_aimaro.nrcpfcnpj_base, --> CPFCNPJ BASE
                                   pr_innivris => vr_innivris,                         --> risco contingencia
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
                                     
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --> Gerar informaçoes do log
            gene0001.pc_gera_log(pr_cdcooper => rw_pre_aprov_aimaro.cdcooper,
                                 pr_cdoperad => 'MOTOR',
                                 pr_dscritic => 'Erro ao buscar o Rating de Contingência do Pré-Aprovado. ' || 
                                                'CPF/CNPJ Base: ' || rw_tbrating_contrato.nrcpfcnpj_base,
                                 pr_dsorigem => 'SAS',
                                 pr_dstransa => 'Processa Rating Operações',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, --> FALSE
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'JOBRAT',
                                 pr_nrdconta => rw_pre_aprov_aimaro.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
          END IF;
          
          -- grava o rating contingencia
          RATI0003.pc_grava_rating_operacao(pr_cdcooper       => rw_pre_aprov_aimaro.cdcooper  --> Código da Cooperativa
                                           ,pr_nrdconta       => rw_pre_aprov_aimaro.nrdconta  --> Conta do associado
                                           ,pr_tpctrato       => rw_pre_aprov_aimaro.tpctrato  --> Tipo do contrato de rating
                                           ,pr_nrctrato       => rw_pre_aprov_aimaro.nrctrato  --> Número do contrato do rating

                                           ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                           ,pr_dtrataut       => rw_crapdat.dtmvtolt --> Data do Rating retornado do MOTOR
                                           ,pr_dtrating       => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating
                                                   
                                           ,pr_strating       => 5   --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                           ,pr_orrating       => 4   --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                           ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                           ,pr_nrcpfcnpj_base => rw_pre_aprov_aimaro.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                           ,pr_cdoperad       => '1'
                                           ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                           ,pr_cdcritic       => vr_cdcritic
                                           ,pr_dscritic       => vr_dscritic);
            
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --> Gerar informaçoes do log
            gene0001.pc_gera_log(pr_cdcooper => rw_pre_aprov_aimaro.cdcooper,
                                 pr_cdoperad => 'MOTOR',
                                 pr_dscritic => 'Erro ao gravar Rating modelo Aimaro do Pré-Aprovado. Conta: ' ||
                                                rw_pre_aprov_aimaro.nrdconta || ', CPF/CNPJ Base: ' || rw_pre_aprov_aimaro.nrcpfcnpj_base,
                                 pr_dsorigem => 'SAS',
                                 pr_dstransa => 'Processa Rating Operações',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, --> FALSE
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'JOBRAT',
                                 pr_nrdconta => rw_pre_aprov_aimaro.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
          END IF;
          
          --Busca Empréstimos Pré-Aprovado
          FOR rw_empr_pre_aprovado IN cr_empr_pre_aprovado(pr_cdfinemp       => 68 --Pré-Aprovado
                                                          ,pr_cdcooper       => rw_pre_aprov_aimaro.cdcooper
                                                          ,pr_nrcpfcnpj_base => rw_pre_aprov_aimaro.nrcpfcnpj_base
                                                          ,pr_dtrating       => vr_dt_corte_refor_rating) LOOP

            -- grava o rating contingencia
            RATI0003.pc_grava_rating_operacao(pr_cdcooper       => rw_empr_pre_aprovado.cdcooper --> Código da Cooperativa
                                             ,pr_nrdconta       => rw_empr_pre_aprovado.nrdconta --> Conta do associado
                                             ,pr_tpctrato       => rw_empr_pre_aprovado.tpctrato --> Tipo do contrato de rating
                                             ,pr_nrctrato       => rw_empr_pre_aprovado.nrctrato --> Número do contrato do rating

                                             ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                             ,pr_dtrataut       => rw_crapdat.dtmvtolt --> Data do Rating retornado do MOTOR
                                             ,pr_dtrating       => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating

                                             ,pr_strating       => 5 --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                             ,pr_orrating       => 4 --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                             ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                             ,pr_nrcpfcnpj_base => rw_pre_aprov_aimaro.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                             ,pr_cdoperad       => '1'
                                             ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                             ,pr_cdcritic       => vr_cdcritic
                                             ,pr_dscritic       => vr_dscritic);
                                     
            IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --> Gerar informaçoes do log
              gene0001.pc_gera_log(pr_cdcooper => rw_empr_pre_aprovado.cdcooper,
                                   pr_cdoperad => 'MOTOR',
                                   pr_dscritic => 'Erro ao gravar Rating modelo Aimaro do Empréstimo Pré-Aprovado: ' ||
                                                  rw_pre_aprov_aimaro.nrctrato || ', CPF/CNPJ Base: ' || rw_pre_aprov_aimaro.nrcpfcnpj_base,
                                   pr_dsorigem => 'SAS',
                                   pr_dstransa => 'Processa Rating Operações',
                                   pr_dttransa => trunc(SYSDATE),
                                   pr_flgtrans => 1, --> FALSE
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'JOBRAT',
                                   pr_nrdconta => rw_empr_pre_aprovado.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
            END IF;
              
            -- Commit parcial cada 1000 registros;
            vr_cont_commit := vr_cont_commit + 1;
            IF vr_cont_commit >= vr_qtde_commit THEN
              vr_cont_commit := 0;
              COMMIT;
            END IF;
          END LOOP;
        END LOOP;
      END IF;

      -- Atualiza base de dados Cooperativa
      COMMIT;

    END LOOP;

    -- Atualiza base de dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
       vr_dscritic := vr_dscritic_aux || vr_dscritic;
       ROLLBACK;
    WHEN OTHERS THEN
       vr_dscritic:= vr_dscritic_aux || 'Erro na rotina JOB '||SQLERRM;
       ROLLBACK;
  END pc_job_rating;

  /* Converter o tipo de contrato para o tipo de produto para gravar na tabela TBGEN_WEBSERVICE ACIONA. */
  FUNCTION fn_conv_tpctrato_tpproduto(pr_tpctrato  IN tbrisco_operacoes.tpctrato%TYPE)  --> Tipo do contrato

  RETURN NUMBER IS

  /* .............................................................................

    Programa : RATI0003                    Antiga:
    Sistema  : Rotinas para Rating dos Produtos
    Sigla    : RATI
    Autor    : Anderson Luiz Heckmann - AMcom
    Data     : Abril/2019.                   Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Converter o tipo de contrato para o tipo de produto para gravar na tabela TBGEN_WEBSERVICE ACIONA.

   Alteracao:
  ..............................................................................*/

    vr_retorno NUMBER;

  BEGIN
     /*
       TPCTRATO para a TBRISCO_OPERACOES:
         1 - Limite de Crédito
         2 - Limite de Desconto de Cheque
         3 - Limite de Desconto de Título
         90 - Empréstimos/Financiamentos
         91 - Borderôs de descontos de Títulos
         92 - Borderôs de descontos de Cheques

       TPPRODUTO para a PC_GRAVAR_ACIONAMENTO
         0 – Empréstimos/Financiamento
         2 – Desconto Cheques - Limite
         3 – Desconto Títulos - Limite
         4 – Cartão de Crédito
         5 – Limite de Crédito
         6 – Desconto Cheque – Borderô
         7 – Desconto de Título – Borderô
    */

    CASE pr_tpctrato
      WHEN 1 THEN
        vr_retorno := 5;
      WHEN 2 THEN
        vr_retorno := 2;
      WHEN 3 THEN
        vr_retorno := 3;
      WHEN 90 THEN
        vr_retorno := 0;
      WHEN 91 THEN
        vr_retorno := 7;
      WHEN 92 THEN
        vr_retorno := 6;
    END CASE;

    RETURN vr_retorno;

  END fn_conv_tpctrato_tpproduto;

 PROCEDURE pc_ret_risco_tbrisco(pr_cdcooper      IN  tbrisco_operacoes.cdcooper%TYPE                       --codigo que identifica a cooperativa
                               ,pr_nrdconta      IN  tbrisco_operacoes.nrdconta%TYPE                       -- Numero da conta/dv do associado.
                               ,pr_tpctrato      IN tbrisco_operacoes.tpctrato%TYPE DEFAULT NULL --tipo de contrato utilizado por esta linha de credito
                               ,pr_nrctremp      IN tbrisco_operacoes.nrctremp%TYPE DEFAULT NULL -- Numero do contrato de emprestimo.
                               ,pr_insit_rating  IN tbrisco_operacoes.insituacao_rating%TYPE DEFAULT NULL -- Numero do contrato de emprestimo.
                               ,pr_inrisco      OUT  tbrisco_operacoes.inrisco_rating%TYPE                 -- nivel de risco rating efetivo
                               ,pr_cdcritic     OUT  PLS_INTEGER                                           -- Critica encontrada no processo
                               ,pr_dscritic     OUT  VARCHAR2) IS

    --    Autor   : Elton (AMcom)
    --    Data    : 04/2019.                         Ultima atualizacao:
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado
    --
    --    Objetivo  : Retorna risco rating tbrisco_operacoes


    CURSOR cr_tbrisco_op IS
    SELECT  a.*
    FROM  tbrisco_operacoes a
    WHERE a.cdcooper          = nvl(pr_cdcooper,a.cdcooper)
    AND   a.nrdconta          = nvl(pr_nrdconta,a.nrdconta)
    AND   a.tpctrato          = nvl(pr_tpctrato,a.tpctrato)
    AND   a.nrctremp          = nvl(pr_nrctremp,a.nrctremp)
    AND   a.insituacao_rating = nvl(pr_insit_rating,a.insituacao_rating)
    AND   a.nrcpfcnpj_base    =
                               (SELECT c.nrcpfcnpj_base
                                  FROM crapass c
                                 WHERE c.cdcooper = a.cdcooper
                                   AND c.nrdconta = a.nrdconta)
    AND  a.dtrisco_rating     =
                               (SELECT MAX(b.dtrisco_rating)
                                  FROM tbrisco_operacoes b
                                 WHERE b.cdcooper          = a.cdcooper
                                   AND b.insituacao_rating = a.insituacao_rating
                                   AND b.nrcpfcnpj_base    = a.nrcpfcnpj_base
                                )
    order by a.nrdconta;

   rw_tbrisco_op cr_tbrisco_op%ROWTYPE;

  BEGIN
    OPEN cr_tbrisco_op;
    FETCH cr_tbrisco_op
      INTO rw_tbrisco_op;
    CLOSE cr_tbrisco_op;

    pr_inrisco := rw_tbrisco_op.inrisco_rating;

  EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina RATI0003 - pc_ret_tbrisco_ope: ' || SQLERRM;


 END pc_ret_risco_tbrisco;

   -- Busca o valor de endividamento e parametro de valor Rating
  PROCEDURE pc_busca_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                  ,pr_nrdconta     IN crapass.nrdconta%TYPE    --> Conta do associado
                                  ,pr_vlendivi     OUT crapass.vllimcre%TYPE   --> Retorno - Valor Endividamento
                                  ,pr_vlrating     OUT crapass.vllimcre%TYPE   --> Retorno - Valor Parametro de Rating
                                  ,pr_dscritic     OUT VARCHAR2) IS             --> Descritivo do erro

  /* .............................................................................

   Programa: pc_busca_endivid_param
   Sistema : CRED
   Autor   : Guilherme/AMcom
   Data    : Abril/2019                 ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : Buscar o valor de endividamento da conta e também o valor do parametro
               para Rating Efetivo(tab056)

  ..............................................................................*/
  ----------->>> variaveis <<<--------
   -- variável de críticas
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic       crapcri.dscritic%TYPE;
   vr_exc_erro       EXCEPTION;


   CURSOR cr_crapcop IS
     SELECT 1
       FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
   rw_crapcop  cr_crapcop%ROWTYPE;

   CURSOR cr_crapass IS
     SELECT 1
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
   rw_crapass  cr_crapass%ROWTYPE;

   -- buscar o Valor do Rating do parâmetro (TAB056), da posição 15, com 11 caracteres.
   CURSOR cr_tab056 IS
     SELECT gene0002.fn_char_para_number(SUBSTR(
             TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'GENERI'
                          ,pr_cdempres => 00
                          ,pr_cdacesso => 'PROVISAOCL'
                          ,pr_tpregist => 999),15,11)) vlrtab056
       FROM dual;
   rw_tab056  cr_tab056%ROWTYPE;

   rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN

    pr_vlendivi := 0;
    pr_vlrating := 0;

    -- Verifica se a conta existe
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      CLOSE cr_crapcop;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;


    -- Verifica se a conta existe
    OPEN cr_crapass;
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;


    -- Verificação do calendário
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    --> Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      --> Montar mensagem de critica
      vr_dscritic:= gene0001.fn_busca_critica(1);
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
    --> Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;


    -- BUSCAR O PARAMETRO DA TAB056
    OPEN  cr_tab056;
    FETCH cr_tab056
      INTO rw_tab056;
    IF cr_tab056%NOTFOUND THEN
      CLOSE cr_tab056;
      -- Caso nao tenha o parametro cadastrado, assumir 0.
      pr_vlrating := 0;
    ELSE
      CLOSE cr_tab056;
      pr_vlrating := rw_tab056.vlrtab056;
    END IF;


    -- BUSCAR O VALOR DE ENDIVIDAMENTO DA CONTA
    GECO0001.pc_calc_endividamento_individu(pr_cdcooper    => pr_cdcooper
                                           ,pr_cdagenci    => 1               --> cód. agencia
                                           ,pr_nrdcaixa    => 1               --> número do caixa
                                           ,pr_cdoperad    => 1               --> operador
                                           ,pr_nmdatela    => 'RATING'
                                           ,pr_idorigem    => 5               --> AYLLOS WEB - Aimaro
                                           ,pr_nrctasoc    => pr_nrdconta     --> Conta Cooperado
                                           ,pr_idseqttl    => 1
                                           ,pr_tpdecons    => TRUE
                                           ,pr_vlutiliz    => pr_vlendivi --> OUT Valor do Endividamento
                                           ,pr_cdcritic    => vr_cdcritic
                                           ,pr_des_erro    => vr_dscritic
                                           ,pr_tab_crapdat => rw_crapdat      --> IN datas
                                           );

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;



  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_vlendivi := 0;
      pr_vlrating := 0;

    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_busca_endivid_param: ' ||
                     SQLERRM;
      pr_vlendivi := 0;
      pr_vlrating := 0;

  END pc_busca_endivid_param;



  -- Verificar o endividamento do cooperado
  FUNCTION fn_verifica_endivid_param(pr_cdcooper     IN crapcop.cdcooper%TYPE               --> Código da Cooperativa
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE               --> Conta do associado
                                     ) RETURN NUMBER IS

  /* ..........................................................................

       Programa: fn_verifica_endivid_param
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Anderson Luiz Heckmann
       Data    : Abril/2019.                          Ultima Atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que chamado.
       Objetivo  : Retornar o endividamento do cooperado

       Alteracoes:

  ............................................................................. */

   -- VARIAVEIS
   vr_calc_rating  BOOLEAN;
   vr_cdcritic     crapcri.cdcritic%TYPE;
   vr_dscritic     crapcri.dscritic%TYPE;

 BEGIN
   pc_verifica_endivid_param(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_calc_rating => vr_calc_rating
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

   IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
     RETURN 1;
   END IF;

   IF vr_calc_rating THEN
     RETURN 0;
   ELSE
     RETURN 1;
   END IF;

 END fn_verifica_endivid_param;

  --> Atualiza Numero do Contrato do Rating
  PROCEDURE pc_atualiza_contrato_rating(pr_cdcooper  IN crapcop.cdcooper%TYPE                  --> Código da Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE                  --> Conta do associado
                                         ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE        --> Tipo do contrato
                                         ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE        --> Número do contrato
                                         ,pr_nrctrato_novo  IN tbrisco_operacoes.NRCTREMP%TYPE   --> Número do contrato Novo
                                         ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                 --> Critica encontrada no processo
                                         ,pr_dscritic  OUT VARCHAR2) IS                          --> Descritivo do erro

  /* ..........................................................................

  Programa: pc_atualiza_nrcontrato_rating
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Mario Cesar Bernar (AMcom)
  Data    : Maio/2019.                           Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Atualizar somente o numero do contrato sem alteração das demais informacoes do Rating.

  Alteracoes:

  ............................................................................. */

  -- CURSORES

  -- tbrisco_operacoes Status do Rating
  CURSOR cr_tbrisco_operacoes (pr_cdcooper  IN crapass.cdcooper%TYPE           --> Código da Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE           --> Conta do associado
                              ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE --> Tipo do contrato de rating
                              ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE --> Número do contrato do rating
                              ) IS
    SELECT opr.*
      FROM tbrisco_operacoes opr
          ,crapass           ass
     WHERE opr.cdcooper = pr_cdcooper
       AND opr.nrdconta = pr_nrdconta
       AND opr.nrctremp = pr_nrctrato
       AND opr.tpctrato = pr_tpctrato
       AND ass.cdcooper = opr.cdcooper
       AND ass.nrdconta = opr.nrdconta;
  rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

  -- VARIAVEIS
  vr_cdcritic    PLS_INTEGER;
  vr_dscritic    VARCHAR2(4000);
  vr_exc_erro    EXCEPTION;
  vr_retorno     BOOLEAN DEFAULT(FALSE);
  vr_retxml      xmltype;

  BEGIN
    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Verifica se contrato novo ja existe
    OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpctrato => pr_tpctrato
                             ,pr_nrctrato => pr_nrctrato_novo);
    FETCH cr_tbrisco_operacoes
     INTO rw_tbrisco_operacoes;

    -- Verifica se encontrou tbrisco_operacoes
    IF cr_tbrisco_operacoes%NOTFOUND THEN
       CLOSE cr_tbrisco_operacoes;
    ELSE
       vr_dscritic := 'Numero do contato novo ja existe, deve ser informado outro numero.';
       CLOSE cr_tbrisco_operacoes;
       RAISE vr_exc_erro;
    END IF;

    -- Verifica se contrato ATUAL ja existe
    OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpctrato => pr_tpctrato
                             ,pr_nrctrato => pr_nrctrato);
    FETCH cr_tbrisco_operacoes
     INTO rw_tbrisco_operacoes;

    -- Verifica se encontrou tbrisco_operacoes
    IF cr_tbrisco_operacoes%NOTFOUND THEN
       CLOSE cr_tbrisco_operacoes;
         -- Nao ha necessidade de parar o processo pois pode alterar o contrato sem rating
--       vr_dscritic := 'Numero do contato nao existe.';
         vr_dscritic := NULL;
         vr_dscritic := NULL;
         RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbrisco_operacoes;

      -- Atualiza o numero do contrato
      UPDATE  tbrisco_operacoes
         SET nrctremp = pr_nrctrato_novo
       WHERE cdcooper   = pr_cdcooper
         AND nrdconta   = pr_nrdconta
         AND nrctremp   = pr_nrctrato
         AND tpctrato   = pr_tpctrato;

      -- Caso não existir o registro do rating na tabela de operações, faz a inserção
      IF SQL%ROWCOUNT = 0 THEN
         vr_dscritic := 'Erro ao atualizar o novo numero do contrato Rating.';
         RAISE vr_exc_erro;
      END IF;

      vr_retorno := fn_registra_historico(pr_cdcooper             => pr_cdcooper
                                         ,pr_cdoperad             => rw_tbrisco_operacoes.cdoperad_rating
                                         ,pr_nrdconta             => pr_nrdconta
                                         ,pr_nrctro               => pr_nrctrato_novo
                                         ,pr_dtmvtolt             => rw_crapdat.dtmvtolt
                                         ,pr_tpctrato             => pr_tpctrato
                                         ,pr_valor                => NULL
                                         ,pr_rating_sugerido      => rw_tbrisco_operacoes.inrisco_rating
                                         ,pr_justificativa        => NULL
                                         ,pr_inrisco_rating       => rw_tbrisco_operacoes.inrisco_rating
                                         ,pr_inrisco_rating_autom => rw_tbrisco_operacoes.inrisco_rating_autom
                                         ,pr_dtrisco_rating       => rw_tbrisco_operacoes.dtrisco_rating
                                         ,pr_dtrisco_rating_autom => rw_tbrisco_operacoes.dtrisco_rating_autom
                                         ,pr_insituacao_rating    => rw_tbrisco_operacoes.insituacao_rating
                                         ,pr_inorigem_rating      => rw_tbrisco_operacoes.inorigem_rating
                                         ,pr_cdoperad_rating      => rw_tbrisco_operacoes.CDOPERAD_RATING
                                         ,pr_tpoperacao_rating    => 1 -- 1--> alteração do rating / 2 efetivação rating
                                         ,pr_retxml               => vr_retxml
                                         ,pr_cdcritic             => vr_cdcritic
                                         ,pr_dscritic             => vr_dscritic);

      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina RATI0003.pc_atualiza_contrato_rating '||SQLERRM;

  END pc_atualiza_contrato_rating;

  /* Busca Informações do Rating */
  PROCEDURE pc_retorna_inf_rating(pr_cdcooper              IN crapcop.cdcooper%TYPE                       --> Código da Cooperativa
                                 ,pr_nrdconta              IN crapass.nrdconta%TYPE                       --> Conta do associado
                                 ,pr_tpctrato              IN tbrisco_operacoes.TPCTRATO%TYPE             --> Tipo do contrato
                                 ,pr_nrctrato              IN tbrisco_operacoes.NRCTREMP%TYPE             --> Número do contrato
                                 ,pr_insituacao_rating    OUT tbrisco_operacoes.insituacao_rating%TYPE    --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_inorigem_rating      OUT VARCHAR2                                    --> Caracter identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                 ,pr_inrisco_rating_autom OUT VARCHAR2                                    --> Caracter Nivel de Risco Rating retornado do MOTOR
                                 ,pr_cdcritic             OUT crapcri.cdcritic%TYPE                       --> Critica encontrada no processo
                                 ,pr_dscritic             OUT VARCHAR2) IS                                --> Descritivo do erro

  /* ..........................................................................

  Programa: pc_retorna_inf_rating
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Anderson Luiz Heckmann (AMcom)
  Data    : Maio/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : Busca Informações do Rating.

  Alteracoes:

  ............................................................................. */

  -- CURSORES

  -- tbrisco_operacoes Informações do Rating
  CURSOR cr_tbrisco_operacoes (pr_cdcooper  IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE           --> Conta do associado
                              ,pr_tpctrato  IN tbrisco_operacoes.TPCTRATO%TYPE --> Tipo do contrato de rating
                              ,pr_nrctrato  IN tbrisco_operacoes.NRCTREMP%TYPE --> Número do contrato do rating
                              ) IS
    SELECT nvl(opr.insituacao_rating,0) insituacao_rating
          ,opr.inrisco_rating_autom
          ,opr.inorigem_rating
      FROM tbrisco_operacoes opr
          ,crapass           ass
     WHERE opr.cdcooper = pr_cdcooper
       AND opr.nrdconta = pr_nrdconta
       AND opr.nrctremp = pr_nrctrato
       AND opr.tpctrato = pr_tpctrato
       AND ass.cdcooper = opr.cdcooper
       AND ass.nrdconta = opr.nrdconta;
  rw_tbrisco_operacoes cr_tbrisco_operacoes%ROWTYPE;

  -- VARIAVEIS
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);
  vr_exc_saida    EXCEPTION;
  vr_tem_operacao BOOLEAN:=FALSE;

  BEGIN
    -- Carrega o calendário de datas da cooperativa
    -- Busca a data do sistema
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Status do Rating
    pr_insituacao_rating := 0;

    -- De ultima hora: se cooperativa for 3-Ailos, nao critica ausencia de rating
    IF pr_cdcooper = 3 THEN
      pr_insituacao_rating  := 9; -- Nao valida status
      RAISE vr_exc_saida;
    END IF;

    -- Verificar o risco do rating
    OPEN cr_tbrisco_operacoes(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpctrato => pr_tpctrato
                             ,pr_nrctrato => pr_nrctrato);
    FETCH cr_tbrisco_operacoes
     INTO rw_tbrisco_operacoes;

    vr_tem_operacao      := cr_tbrisco_operacoes%FOUND;
    pr_insituacao_rating := nvl(rw_tbrisco_operacoes.insituacao_rating,0);

    CLOSE cr_tbrisco_operacoes;

    IF vr_tem_operacao THEN
      CASE rw_tbrisco_operacoes.inorigem_rating
        WHEN 1 THEN
          pr_inorigem_rating := 'Motor';
        WHEN 2 THEN
          pr_inorigem_rating := 'Esteira';
        WHEN 3 THEN
          pr_inorigem_rating := 'Regra Aimaro';
        WHEN 4 THEN
          pr_inorigem_rating := 'Contingência';
        ELSE
          pr_inorigem_rating := '';
      END CASE;
      IF rw_tbrisco_operacoes.inrisco_rating_autom IS NULL THEN
        pr_inrisco_rating_autom := '';
      ELSE
      pr_inrisco_rating_autom := risc0004.fn_traduz_risco(rw_tbrisco_operacoes.inrisco_rating_autom);
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina RATI0003.pc_retorna_inf_rating '||SQLERRM;

  END pc_retorna_inf_rating;

  /* Retornar o tipo de Birô que está sendo utilizado para a cooperativa */
  FUNCTION fn_tipo_biro(pr_cdcooper  IN crapcop.cdcooper%TYPE)  --> Código da cooperativa

  RETURN NUMBER IS

  /* .............................................................................

  Programa : RATI0003                    Antiga:
  Sistema  : Rotinas para Rating dos Produtos
  Sigla    : RATI
  Autor    : Anderson Luiz Heckmann - AMcom
  Data     : Junho/2019.                   Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: -----
  Objetivo  : Retornar o tipo de Birô que está sendo utilizado para a cooperativa.

  Alteracao:
  ..............................................................................*/

  -- Cursor
  CURSOR cr_tbrat_param_geral (pr_cdcooper IN crapass.cdcooper%TYPE) IS
    SELECT NVL(tpg.inbiro_ibratan,1) inbiro_ibratan
      FROM tbrat_param_geral tpg
     WHERE tpg.cdcooper = pr_cdcooper;
  rw_tbrat_param_geral cr_tbrat_param_geral%ROWTYPE;

  -- Variáveis
  vr_retorno  number := 1;

  BEGIN
    -- Buscar os parâmetros gerais da PARRAT
    OPEN cr_tbrat_param_geral (pr_cdcooper => pr_cdcooper);
    FETCH cr_tbrat_param_geral INTO rw_tbrat_param_geral;
    IF cr_tbrat_param_geral%NOTFOUND THEN
      vr_retorno := 1;
      CLOSE cr_tbrat_param_geral;
    ELSE
      vr_retorno := rw_tbrat_param_geral.inbiro_ibratan;
      CLOSE cr_tbrat_param_geral;
    END IF;

    RETURN vr_retorno;

  END fn_tipo_biro;

 PROCEDURE pc_busca_risco_rat_preapr(pr_cdcooper        IN crapcop.cdcooper%TYPE                    --> Código da Cooperativa
                                    ,pr_nrdconta        IN tbrisco_operacoes.nrdconta%TYPE           --> Conta do associado
                                    ,pr_inrisco_rating OUT tbrisco_operacoes.inrisco_rating%TYPE    --> risco rating
                                    ,pr_cdcritic       OUT crapcri.cdcritic%TYPE                    --> Critica encontrada no processo
                                    ,pr_dscritic       OUT VARCHAR2) IS

   /* ..........................................................................

  Programa: pc_busca_rat_preaprovado
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Elton (AMcom)
  Data    : Agosto/2019.                          Ultima Atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que chamado.
  Objetivo  : busca o risco rating do pre-aprovado por cfpcgc base

  Alteracoes:
  ............................................................................. */

     -- Busca do nr cpfcnpj base do associado
  CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
  SELECT ass.nrcpfcnpj_base
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass_ope   cr_crapass_ope%ROWTYPE;

  CURSOR cr_risco_preapr IS
      SELECT nvl( oper.inrisco_rating, oper.inrisco_rating_autom) inrisco_rating
          ,oper.dtrisco_rating_autom , oper.dtrisco_rating
      FROM tbrisco_operacoes oper
     WHERE oper.cdcooper       = pr_cdcooper
       AND oper.nrcpfcnpj_base = rw_crapass_ope.nrcpfcnpj_base
       AND oper.tpctrato       = 68; --pre-aprovado

  rw_risco_preapr  cr_risco_preapr%ROWTYPE;

BEGIN

  OPEN cr_crapass_ope(pr_cdcooper
                     ,pr_nrdconta);
  FETCH cr_crapass_ope INTO rw_crapass_ope;
  CLOSE cr_crapass_ope;

  OPEN cr_risco_preapr;
  FETCH cr_risco_preapr INTO rw_risco_preapr;
  CLOSE cr_risco_preapr;

  pr_inrisco_rating := rw_risco_preapr.inrisco_rating;

EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina RATI0003.pc_busca_risco_rat_preapr '||SQLERRM;

END pc_busca_risco_rat_preapr;

END RATI0003;
/
