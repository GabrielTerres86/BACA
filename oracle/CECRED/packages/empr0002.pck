CREATE OR REPLACE PACKAGE CECRED.EMPR0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela PARPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela PARPRE

  -- Alteracoes: 03/08/2016 - Alterada estrutura da tela cadpre e outras rotinas
  --                          do pre aprovado para fase 3 do Projeto 299
  --                          Pre aprovado.(Lombardi)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- temptable para retornar dados da cpa, antigo b1wgen188tt.i/tt-dados-cpa
  TYPE typ_rec_dados_cpa
    IS RECORD(cdcooper crapepr.cdcooper%TYPE
             ,nrdconta crapepr.nrdconta%TYPE
             ,inpessoa crapass.inpessoa%TYPE
             ,nrcpfcgc crapass.nrcpfcgc%TYPE
             ,idastcjt crapass.idastcjt%TYPE
             ,idcarga  crapcpa.iddcarga%TYPE
             ,cdlcremp crapcpa.cdlcremp%TYPE
             ,vldiscrd crapcpa.vllimdis%TYPE
             ,vlcalpar crapcpa.vlcalpar%TYPE
             ,txmensal craplcr.txmensal%TYPE
             ,vllimctr crappre.vllimctr%TYPE
             ,flprapol craplcr.flprapol%TYPE
             ,msgmanua VARCHAR2(1000));
  TYPE typ_tab_dados_cpa
    IS TABLE OF typ_rec_dados_cpa
      INDEX BY PLS_INTEGER;

  -- Definição de tipo para temporary table de bloqueios órfãos
  TYPE typ_reg_tbepr_motivo_nao_aprv IS RECORD(
     nrdconta        tbepr_motivo_nao_aprv.nrdconta%TYPE
    ,idcarga         tbepr_motivo_nao_aprv.idcarga%TYPE
    ,tppessoa        tbepr_motivo_nao_aprv.tppessoa%TYPE
    ,nrcpfcnpj_base  tbepr_motivo_nao_aprv.nrcpfcnpj_base%TYPE
    ,idmotivo        tbepr_motivo_nao_aprv.idmotivo%TYPE
    ,liberar         BOOLEAN);

  -- Definição do índice e tabela para bloqueios órfãos
  TYPE typ_tab_tbepr_motivo_nao_aprv IS TABLE OF typ_reg_tbepr_motivo_nao_aprv INDEX BY VARCHAR2(400);

  -- Definição de temporary table para captura de processamento de contas em arquivo
  TYPE typ_reg_arquivo IS RECORD(
     nrdconta    NUMBER
    ,idcarga     NUMBER);

  -- Cursor para buscar registros de pre-aprovado com importação manual em bloqueio por rating
  CURSOR cr_busca_bloqueados_manual(pr_cdcooper IN crapcpa.cdcooper%TYPE) IS
    SELECT cpa.cdcooper
          ,cpa.iddcarga
          ,cpa.tppessoa
          ,cpa.nrcpfcnpj_base
          ,cpa.cdsituacao
    FROM crapcpa cpa
        ,tbepr_carga_pre_aprv pre
    WHERE cpa.cdcooper = NVL(pr_cdcooper, cpa.cdcooper)
      AND cpa.cdcooper = pre.cdcooper
      AND cpa.iddcarga = pre.idcarga
      AND pre.tpcarga = 1
      AND (cpa.cdsituacao = 'B'
           AND cpa.dtbloqueio IS NULL)
    ORDER BY cpa.iddcarga;

  -- Definição do índice e tabela para contas em arquivo
  TYPE typ_tab_arquivo IS TABLE OF typ_reg_arquivo INDEX BY VARCHAR2(400);

  /* Busca da flg de PreAprovado liberado ou não ao Cooperado */
  FUNCTION fn_flg_preapv_liberado(pr_cdcooper       crapcop.cdcooper%TYPE
                                 ,pr_nrdconta       crapass.nrdconta%TYPE DEFAULT 0
                                 ,pr_tppessoa       crapass.inpessoa%TYPE DEFAULT 0
                                 ,pr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE DEFAULT 0) RETURN NUMBER;

   /* Verifica se o cooperado pode efetuar a contratacao de pre aprovado de forma online */
  FUNCTION fn_preapv_perm_cont_online(pr_cdcooper IN INTEGER,               --> Codigo da Cooperativa
                               pr_nrdconta IN INTEGER DEFAULT 0,     --> Numero da Conta
                               pr_idseqttl IN crapttl.idseqttl%TYPE, --> Sequencial do titular
                               pr_nrcpfope IN crapopi.nrcpfope%TYPE, --> CPF do operador juridico
                               pr_idorigem IN INTEGER,               --> ID origem da requisição
                               pr_cdagenci IN crapage.cdagenci%TYPE, --> Código da agencia
                               pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                               pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                               )  RETURN NUMBER;

  /* Mostrar o texto dos motivos na tela de acordo com o ocorrido. */
  FUNCTION fn_busca_motivo(pr_idmotivo IN tbgen_motivo.idmotivo%TYPE) RETURN VARCHAR2;

  /* Função para buscar o id da carga atual de pre-aprovado para CPF/CNPJ raiz enviado para bloqueio */
  FUNCTION fn_idcarga_pre_aprovado_motivo(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                         ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                                         ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) RETURN NUMBER;

  /* Procedure para buscar o ID de carga independente do status da CPA */
  PROCEDURE pc_busca_ultima_carga(pr_cdcooper IN crapcop.cdcooper%TYPE         -- Cooperativa
                                 ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE   -- CPF/CNPJ Base
                                 ,pr_idcarga  OUT crapcpa.iddcarga%TYPE        -- Retorno do ID da carga
                                 ,pr_cdsitua  OUT crapcpa.cdsituacao%TYPE      -- Retorno da situacao do cooperado
                                 ,pr_critica  OUT VARCHAR2);                   -- Retorno de erros caso ocorram

  /* Validar o operador */
  PROCEDURE pc_valida_operador(pr_cdcooper  IN crapope.cdcooper%TYPE --> Codigo da Carga
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Descrição da crítica
                              ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT empr0002.typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro); --> Retorna os erros

  --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT VARCHAR2            --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT VARCHAR2);              --> Retorna os erros

  --> Procedimento para validar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_valida_dados_cpa(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_vlemprst  IN crapepr.vlemprst%TYPE    --> Valor do emprestimo
                               ,pr_diapagto  IN INTEGER                  --> Dia de pagamento
                               ,pr_nrcpfope  IN NUMBER                   --> CPF do operador
                               ,pr_nrctremp  IN crapepr.nrctremp%TYPE    --> Numero do contrato
                               ,pr_cdcritic OUT NUMBER                   --> Retorna codigo da critica
                               ,pr_dscritic OUT VARCHAR2                 --> Retorna descrição da critica
                               );

  -- Buscar as alineas
  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  -- Busca período de bloqueio de limite por refinanceamento.
  PROCEDURE pc_busca_periodo_bloq_refin(pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Bloqueio de limite do pre aprovado por refinanceamento.
  PROCEDURE pc_bloqueia_pre_aprv_por_refin(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do cooperado
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  --> Verificação de liberação/bloqueio do PreAprovado
  PROCEDURE pc_verifica_lib_blq_pre_aprov(pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE   --> Codigo da cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE                    --> Numero da conta
                                         ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> codigo da situacao
                                         ,pr_des_erro OUT VARCHAR2 --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica


  -- Gerar tabela de historico dos bens das propostas de emprestimos. - JOB
  PROCEDURE pc_carga_hist_bpr(pr_cdcooper IN crapcop.cdcooper%TYPE); --> Codigo da cooperativa

  -- Gerar a tabela de posição diária do pré-aprovado e contratos. - JOB   (M441)
  PROCEDURE pc_carga_pos_diaria_epr(pr_cdcooper      IN CRAPCOP.CDCOOPER%TYPE --> código da cooperativa (0-processa todas)
                                   ,pr_qtdias_manter IN NUMBER);  --> Quantidade de dias para manter a tabela TBEPR_POS_DIARIA_CPA

  -- Buscar a finalidade de PreAprovado conforme Coop e tipo de pessoa
  FUNCTION fn_finali_pre_aprovado(pr_cdcooper crapcop.cdcooper%TYPE
                                 ,pr_inpessoa crapass.inpessoa%TYPE) RETURN NUMBER;


  -- Function para buscar os cooperados com crédito pré-aprovado ativo - Utilizada para envio de Notificações/Push
  FUNCTION fn_sql_contas_com_preaprovado RETURN CLOB;

  -- Procedimento para efetuar a checagem de perca temporaria do PreAprovado por motivos configurados na CADPRE
  PROCEDURE pc_proces_perca_pre_aprovad(pr_cdcooper IN crapcop.cdcooper%TYPE                        -- Cooperatia
                                       ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0              -- ID da Carga
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0              -- Conta
                                       ,pr_tppessoa IN crapcpa.tppessoa%TYPE DEFAULT 0              -- Tipo de PEssoa
                                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE DEFAULT 0 -- CPF/CNPJ Base
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data atual
                                       ,pr_idmotivo IN tbgen_motivo.idmotivo%TYPE -- Motivo
                                       ,pr_qtdiaatr IN NUMBER                     -- Dias em atraso
                                       ,pr_valoratr IN NUMBER                     -- Valor em atraso
                                       ,pr_dscritic OUT VARCHAR2);                -- Erro na chamada

  -- Procedimento para efetuar a liberação de perca temporaria do PreAprovado por motivos configurados na CADPRE
  PROCEDURE pc_regularz_perca_pre_aprovad(pr_cdcooper IN crapcop.cdcooper%TYPE                        -- Cooperatia
                                         ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0              -- ID da Carga
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0              -- Conta
                                         ,pr_tppessoa IN crapcpa.tppessoa%TYPE DEFAULT 0              -- Tipo de PEssoa
                                         ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE DEFAULT 0 -- CPF/CNPJ Base
                                         ,pr_idmotivo IN tbgen_motivo.idmotivo%TYPE -- Motivo
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data atual
                                         ,pr_dscritic OUT VARCHAR2);                -- Erro na chamada

  -- Função para buscar o id da carga atual de pre-parovado para o CPF/CNPJ raiz enviado
  FUNCTION fn_idcarga_pre_aprovado(pr_cdcooper        IN crapcop.cdcooper%TYPE           -- Cooperativa
                                  ,pr_tppessoa        IN crapcpa.tppessoa%TYPE           -- Tipo Pessoa
                                  ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE)    -- CPF/CNPJ Base
                                    RETURN NUMBER;

  -- Função para buscar ID de carga sem considerar a data de vigencia nos status A e B
  FUNCTION fn_carga_pre_sem_vig_status(pr_cdcooper        IN crapcop.cdcooper%TYPE          -- Cooperativa
                                      ,pr_tppessoa        IN crapcpa.tppessoa%TYPE          -- Tipo Pessoa
                                      ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE)   -- CPF/CNPJ Base
                                    RETURN NUMBER;

  -- Função para buscar ID de carga sem considerar a data de vigencia
  FUNCTION fn_idcarga_pre_aprv_sem_vig(pr_cdcooper        IN crapcop.cdcooper%TYPE         -- Cooperativa
                                      ,pr_tppessoa        IN crapcpa.tppessoa%TYPE         -- Tipo Pessoa
                                      ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE)  -- CPF/CNPJ Base
                                      RETURN NUMBER;

  -- Função para buscar o id da carga atual de pre-parovado para a conta enviada
  FUNCTION fn_idcarga_pre_aprovado_cta(pr_cdcooper IN crapcop.cdcooper%TYPE           -- Cooperativa
                                      ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE)    -- CPF/CNPJ Base
                                    RETURN NUMBER;

  -- Procedure para invocar a função de busca do id da carga atual de pre-parovado para a conta enviada
  PROCEDURE pc_idcarga_pre_aprovado_cta(pr_cdcooper IN crapcop.cdcooper%TYPE           -- Cooperativa
                                       ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE     -- Conta
                                       ,pr_idcarga OUT crapcpa.iddcarga%TYPE);         -- ID da carga disponível

  -- Processo de carga via SAS
  PROCEDURE pc_carga_autom_via_SAS(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                  ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                  ,pr_skcarga  IN tbepr_carga_pre_aprv.skcarga_sas%TYPE -- SK Carga SAS
                                  ,pr_cddopcao   IN VARCHAR2             -- Opção (Importar ou Bloquear)
                                  ,pr_dsrejeicao IN VARCHAR2             -- Texto da rejeição
                                  ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                   );

  -- Carga manual via arquivo
  PROCEDURE pc_carga_manual_via_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                       ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                       ,pr_tpexecuc IN VARCHAR2               -- Tipo da Execução (Simulação ou Importação)
                                       ,pr_dsdireto IN VARCHAR2               -- Diretorio do arquivo
                                       ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                       ,pr_xmldados IN OUT NOCOPY CLOB        -- Saida de informações
                                       ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                       );

  -- Processo de carga de exclusao via arquivo enviado
  PROCEDURE pc_carga_exclus_via_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                       ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                       ,pr_tpexecuc IN VARCHAR2               -- Tipo da Execução (Simulação ou Importação)
                                       ,pr_dsdireto IN VARCHAR2               -- Diretorio do arquivo
                                       ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                       ,pr_xmldados IN OUT NOCOPY CLOB        -- Saida de informações
                                       ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                       );

  -- Efetuar checagem do Rating do PreAprovado oriundo do SAS
  PROCEDURE pc_verifica_rating_sas(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  ,pr_tppessoa IN crapass.inpessoa%TYPE
                                  ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                  ,pr_iddcarga IN crapcpa.iddcarga%TYPE DEFAULT 0
                                  ,pr_dscritic OUT VARCHAR2);

  -- Bloquear/Liberar a carga enviada
  PROCEDURE pc_bloq_libera_carga(pr_cdcooper IN crapcop.cdcooper%TYPE             --> Codigo Cooperativa
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE             --> Codigo tela
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Operador
                                ,pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                                ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                                ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                );

  -- Procedure para calculo do valor do PreAprovado do CPF/CNPJ enviado
  PROCEDURE pc_calc_pre_aprovado_analitico(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_tppessoa IN crapcpa.tppessoa%TYPE              -- Tipo de PEssoa
                                          ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE -- CPF/CNPJ Base
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_nrfimpre          OUT craplcr.nrfimpre%TYPE          -- Quantidade de parcelas
                                          ,pr_vlpot_parc_max    OUT crapcpa.vlpot_parc_maximo%TYPE -- Potencial parcela Maximo
                                          ,pr_vlpot_lim_max     OUT crapcpa.vlpot_lim_max%TYPE     -- Potencial Limite Maximo
                                          ,pr_vl_scr_61_90      OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90
                                          ,pr_vl_scr_61_90_cje  OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90 Conjuge
                                          ,pr_vlope_pos_scr     OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr
                                          ,pr_vlope_pos_scr_cje OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr Conjuge
                                          ,pr_vlprop_andamt     OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento
                                          ,pr_vlprop_andamt_cje OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento Conjuge
                                          ,pr_vlparcel          OUT NUMBER                         -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                         -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2);                     -- Saida de Critica

  -- Procedure para calculo do valor do PreAprovado da Conta enviada
  PROCEDURE pc_calc_pre_aprovad_analit_cta(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_nrdconta IN crapcpa.nrdconta%TYPE              -- Conta
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_nrfimpre          OUT craplcr.nrfimpre%TYPE          -- Quantidade de parcelas
                                          ,pr_vlpot_parc_max    OUT crapcpa.vlpot_parc_maximo%TYPE -- Potencial parcela Maximo
                                          ,pr_vlpot_lim_max     OUT crapcpa.vlpot_lim_max%TYPE     -- Potencial Limite Maximo
                                          ,pr_vl_scr_61_90      OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90
                                          ,pr_vl_scr_61_90_cje  OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90 Conjuge
                                          ,pr_vlope_pos_scr     OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr
                                          ,pr_vlope_pos_scr_cje OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr Conjuge
                                          ,pr_vlprop_andamt     OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento
                                          ,pr_vlprop_andamt_cje OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento Conjuge
                                          ,pr_vlparcel          OUT NUMBER                         -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                         -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2);                     -- Saida de Critica

  -- Procedure para calculo do valor do PreAprovado do CPF/CNPJ enviado
  PROCEDURE pc_calc_pre_aprovado_sintetico(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_tppessoa IN crapcpa.tppessoa%TYPE              -- Tipo de PEssoa
                                          ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE -- CPF/CNPJ Base
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_vlparcel          OUT NUMBER                   -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                   -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2);               -- Saida de Critica

  -- Procedure para calculo do valor do PreAprovado da conta enviada
  PROCEDURE pc_calc_pre_aprovad_sint_cta(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                        ,pr_nrdconta IN crapcpa.nrdconta%TYPE              -- Conta
                                        ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                        -- Variaveis de saida
                                        ,pr_vlparcel OUT NUMBER                   -- Valor da Parcela
                                        ,pr_vldispon OUT NUMBER                   -- Valor Disponivel
                                        ,pr_dscritic OUT VARCHAR2);               -- Saida de Critica

  -- Procedure para solicitar a Importação das Cargas SAS semanalmente via JOB
  PROCEDURE pc_proc_job_imp_preapv_sas(pr_cdcritic OUT NUMBER
                                      ,pr_dscritic OUT VARCHAR2);

  -- Function para retornar cursor dos registros bloqueados órfãos
  FUNCTION fn_cursor_registros_bloq_orfao(pr_cdcooper IN VARCHAR2, pr_motivos IN VARCHAR2) RETURN typ_tab_tbepr_motivo_nao_aprv;

  -- Procedure para interpolar registros processados com os registros de bloqueios órfãos.
  PROCEDURE pc_libera_bloqueio_orfao(pr_cdcooper                  IN  crapass.cdcooper%TYPE         --> Código da cooperativa
                                    ,pr_tab_tbepr_motivo_nao_aprv IN  typ_tab_tbepr_motivo_nao_aprv --> Temporary table dos motivos com bloqueio
                                    ,pr_tab_arquivo               IN  typ_tab_arquivo               --> Temporary table com os registros processados
                                    ,pr_des_erro                  OUT VARCHAR2);                    --> Retorno da crítica (erro)
									  
  -- Procedure para aprovar liberação de carga manual após rating
  PROCEDURE pc_libera_manual_rating(pr_cdcooper        IN crapass.cdcooper%TYPE         --> Código da cooperativa
                                   ,pr_idcarga         IN crapcpa.iddcarga%TYPE         --> Código do carga manual
                                   ,pr_des_erro        OUT VARCHAR2);                   --> Retorno da crítica (erro)

  -- Sobrecarga de método para garantir compatibilidade com o legado
  PROCEDURE pc_busca_carga_ativa(pr_cdcooper   IN NUMBER      --> Código da cooperativa
                                ,pr_nrdconta   IN NUMBER      --> Número da conta do cooperado
                                ,pr_idcarga    OUT NUMBER);   --> Código da carga retornada

  /* Gerar multiplas assinaturas para PJ na contratação de pré-aprovado */
  PROCEDURE pc_gera_m_assina_pre_aprov(pr_cdcooper  IN crawepr.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Códigi da conta
                                      ,pr_nrctremp  IN NUMBER                 --> Código do contrato
                                      ,pr_assinatu  OUT VARCHAR2              --> Texto formatado das assinaturas
                                      ,pr_cdcritic  OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic  OUT VARCHAR2);            --> Descrição da crítica

  -- Busca a parcela liberada no pré aprovado
  PROCEDURE pc_busca_parcela_preaprov(pr_cdcooper IN crapcpa.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrdconta IN crapcpa.nrdconta%TYPE  --> Códigi da conta
                                     ,pr_nrctremp IN NUMBER                 --> Número do contrato
                                     ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);            --> Retorno de erro geral

  --Busca a assinatura do contrato
  PROCEDURE pc_assinatura_contrato_pre(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_cdagenci     IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                      ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                      ,pr_idseqttl     IN INTEGER --> Titularidade do Cooperado
                                      ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                      ,pr_cdorigem     IN INTEGER  --> Codigo da origem do canal
                                      ,pr_nrctremp     IN NUMBER   --> numero o contrato de emprestimo
                                      ,pr_tpassinatura IN NUMBER --> tipo de assinatura (1 socio/2 - cooperativa)
                                      ,pr_assinatu     OUT VARCHAR2  --> Texto formatado das assinaturas
                                      ,pr_des_reto     OUT VARCHAR   --> Retorno OK / NOK
                                      ,pr_cdcritic     OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic     OUT VARCHAR2);

  PROCEDURE pc_desbloqueio_pre_aprv_rating(pr_cdcooper  IN crawepr.cdcooper%TYPE DEFAULT 0 --> Código da Cooperativa
                                          ,pr_cdcritic  OUT INTEGER                        --> Código de críticia
                                          ,pr_dscritic  OUT VARCHAR2);
                                        
  PROCEDURE pc_job_desblo_preapvr_rating(pr_cdcritic  OUT INTEGER            
                                        ,pr_dscritic  OUT VARCHAR2); 
                                      
END EMPR0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela CADPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao: 13/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela CADPRE
  --
  -- Alteracoes: 13/11/2015 - Ajustado leitura na CRAPOPE incluindo upper (Odirlei-AMcom)
  --             24/08/2019 - Concatenado Rating na mensagem para o operador na pc_busca_dados_cpa
  --             (Luiz Otavio Olinegr Momm - AMCOM)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT cdcooper
        ,nmrescop
        ,vlmaxleg
    FROM crapcop
   WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Busca da flg de PreAprovado liberado ou não ao Cooperado */
  FUNCTION fn_flg_preapv_liberado(pr_cdcooper       crapcop.cdcooper%TYPE
                                 ,pr_nrdconta       crapass.nrdconta%TYPE DEFAULT 0
                                 ,pr_tppessoa       crapass.inpessoa%TYPE DEFAULT 0
                                 ,pr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE DEFAULT 0) RETURN NUMBER IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_motivo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lombardi
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Mostrar o texto dos motivos na tela de acordo com o ocorrido.
    --
    --   Alteracoes:
    -- .............................................................................
    DECLARE
      -- Retornos da chamada
      vr_flglibera  tbcc_param_pessoa_produto.flglibera%TYPE;
      vr_dtvigencia tbcc_param_pessoa_produto.dtvigencia_paramet%TYPE;
      vr_idmotivo   tbcc_param_pessoa_produto.idmotivo%TYPE;
      vr_dscritic   VARCHAR2(4000);
    BEGIN
      -- Direcionar para ponto central de busca
      cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => pr_cdcooper
                                         ,pr_nrdconta           => pr_nrdconta
                                         ,pr_tppessoa           => pr_tppessoa
                                         ,pr_nrcpfcnpj_base     => pr_nrcpfcnpj_base
                                         ,pr_cdproduto          => 25 -- PréAprovado
                                         ,pr_cdoperac_produto   => 1  -- Liberação
                                         ,pr_flglibera          => vr_flglibera
                                         ,pr_dtvigencia_paramet => vr_dtvigencia
                                         ,pr_idmotivo           => vr_idmotivo
                                         ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        -- Em caso de erro, conta como não liberado
        RETURN 0;
      ELSE
        -- Retornar o valor encontrado
        RETURN vr_flglibera;
      END IF;
    EXCEPTION
      -- Em caso de erro, conta como não liberado
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_flg_preapv_liberado;

   /* Verifica se o cooperado pode efetuar a contratacao de pre aprovado de forma online */
  FUNCTION fn_preapv_perm_cont_online(pr_cdcooper IN INTEGER,               --> Codigo da Cooperativa
                               pr_nrdconta IN INTEGER DEFAULT 0,     --> Numero da Conta
                               pr_idseqttl IN crapttl.idseqttl%TYPE, --> Sequencial do titular
                               pr_nrcpfope IN crapopi.nrcpfope%TYPE, --> CPF do operador juridico
                               pr_idorigem IN INTEGER,               --> ID origem da requisição
                               pr_cdagenci IN crapage.cdagenci%TYPE, --> Código da agencia
                               pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE, --> Numero do caixa
                               pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da tela
                               )  RETURN NUMBER IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_preapv_perm_cont_online
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Werinton
    --  Data     : Julho/2019.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Verificar se o cooperado possui saldo para constratacao de pre aprovado e se nao exige
    --   assinatura conjunta no auto atendimento.
    --
    --   Alteracoes:
    -- .............................................................................
    DECLARE
      -- Retornos da chamada
      vr_flglibera  tbcc_param_pessoa_produto.flglibera%TYPE;
      -- Retorna dados do credito pre aprovado
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      -- Variáveis de ERRO
      vr_des_reto VARCHAR2(5);
      vr_tab_erro gene0001.typ_tab_erro;
    BEGIN
      vr_flglibera := 0;

     -- Verificar se o cooperado possui pré-aprovado
        EMPR0002.pc_busca_dados_cpa(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_cdoperad => '1' -- InternetBank.w e TAA_autorizador enviam fixo '1'
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_idorigem => pr_idorigem
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nrcpfope => pr_nrcpfope
                                   ,pr_tab_dados_cpa => vr_tab_dados_cpa
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => vr_tab_erro);
        -- Verificar se não ocorreu erro
        IF NVL(vr_des_reto,'OK') != 'NOK' THEN
          -- Verificar se existe informação de contratação do pré-aprovado
          IF vr_tab_dados_cpa.COUNT > 0 THEN
            -- Verificar se o valor para contratação do pré-aprovado é maior que zero
            -- E que não seja necessario a assinatura conjunta no auto atendimento.
            IF vr_tab_dados_cpa(vr_tab_dados_cpa.FIRST).vldiscrd > 0
              AND vr_tab_dados_cpa(vr_tab_dados_cpa.FIRST).idastcjt = 0  THEN
              vr_flglibera := 1;
            END IF;
          END IF;
        END IF;

        RETURN vr_flglibera;

    EXCEPTION
      -- Em caso de erro, conta como não liberado
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_preapv_perm_cont_online;

  /* Mostrar o texto dos motivos na tela de acordo com o ocorrido. */
  FUNCTION fn_busca_motivo(pr_idmotivo IN tbgen_motivo.idmotivo%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_motivo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lombardi
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Mostrar o texto dos motivos na tela de acordo com o ocorrido.
    --
    --   Alteracoes:
    -- .............................................................................

    DECLARE
      -- Efetuar a busca da descrição na tabela
      CURSOR cr_tbgen_motivo IS
        SELECT mot.dsmotivo
          FROM tbgen_motivo mot
         WHERE mot.idmotivo = pr_idmotivo;
      vr_dsmotivo tbgen_motivo.dsmotivo%TYPE;
    BEGIN
      -- Busca descrição da critica cfme parâmetro passado
      OPEN cr_tbgen_motivo;
      FETCH cr_tbgen_motivo
       INTO vr_dsmotivo;
      -- Se não encontrou nenhum registro
      IF cr_tbgen_motivo%NOTFOUND THEN
        -- Montar descrição padrão
        vr_dsmotivo := pr_idmotivo || ' - Critica nao cadastrada!';
      END IF;
      -- Apenas fechar o cursor
      CLOSE cr_tbgen_motivo;
      -- Retornar a string montada
      RETURN vr_dsmotivo;
    END;
  END fn_busca_motivo;

  PROCEDURE pc_valida_operador(pr_cdcooper  IN crapope.cdcooper%TYPE --> Codigo da Carga
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Descrição da crítica
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_valida_operador
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Valida o operador.

     Alteracoes: 29/11/2016 - P341 - Automatização BACENJUD - Alterado para validar o departamento à partir
                              do código e não mais pela descrição (Renato Darosci - Supero)

     ..............................................................................*/
    DECLARE
      -- Busca o operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cddepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;

    BEGIN
      -- Buscar Dados do Operador
      OPEN cr_crapope (pr_cdcooper => pr_cdcooper
                      ,pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapope%FOUND;
      -- Fecha cursor
      CLOSE cr_crapope;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;

      -- Somente o departamento credito irá ter acesso para alterar as informacoes
      IF rw_crapope.cddepart NOT IN (14,20) THEN
        vr_cdcritic := 36;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
    END;

  END pc_valida_operador;

  --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT empr0002.typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro) IS --> Retorna os erros

    /* .............................................................................

     Programa: pc_busca_dados_cpa        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Odirlei Busana(AMcom)
     Data    : Outubro/2015.                    Ultima atualizacao: 24/09/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para buscar dados do credito pré-aprovado (crapcpa)

     Alteracoes: 19/10/2015 - Conversão Progress -> Oracle (Odirlei/AMcom)

                 13/01/2016 - Verificacao de carga ativa - Pre-Aprovado fase II.
                              (Jaison/Anderson)

                 12/02/2018 - Repasse de novos campos

                 24/08/2019 - Concatenado Rating na mensagem para o operador na pc_busca_dados_cpa
                 (Luiz Otavio Olinegr Momm - AMCOM)
    ..............................................................................*/ 

    ---------------> CURSORES <-----------------

    --> Verifica se o associado pode obter o credido pre-aprovado
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
            ,ass.nrcpfcnpj_base
            ,idastcjt
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Verifica se esta na tabela do pre-aprovado
    CURSOR cr_crapcpa (pr_cdcooper       IN crapcpa.cdcooper%TYPE
                      ,pr_tppessoa       IN crapcpa.tppessoa%TYPE
                      ,pr_nrcpfcnpj_base IN crapcpa.nrcpfcnpj_base%TYPE
                      ,pr_idcarga        IN crapcpa.iddcarga%TYPE) IS
      SELECT cpa.nrcpfcnpj_base
            ,cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
            ,cpa.cdlcremp
            ,cpa.vlcalpar
            ,carga.tpcarga
            ,carga.dsmensagem_aviso as mensagem
            ,carga.dscarga
        FROM crapcpa cpa
            ,tbepr_carga_pre_aprv carga
       WHERE cpa.cdcooper = pr_cdcooper
         AND cpa.tppessoa = pr_tppessoa
         AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
         AND cpa.iddcarga = pr_idcarga
         AND cpa.cdcooper = carga.cdcooper
         AND cpa.iddcarga = carga.idcarga;
    rw_crapcpa cr_crapcpa%rowtype;

    --> Verifica se esta bloqueado o pre-aprovado
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.vllimctr
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;

    --> Buscar linha de credito
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%TYPE,
                       pr_cdlcremp craplcr.cdlcremp%TYPE)IS
      SELECT lcr.txmensal
            ,lcr.flprapol
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    --> Busca NivelRating - P450 24/08/2019
    CURSOR cr_risco_operacoes (pr_cdcooper       IN crapcpa.cdcooper%TYPE
                              ,pr_nrcpfcnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) IS
      SELECT oper.inrisco_rating_autom
        FROM tbrisco_operacoes oper
       WHERE oper.tpctrato = 68
         AND oper.cdcooper = pr_cdcooper
         AND oper.nrcpfcnpj_base = pr_nrcpfcnpj_base;
    
    ---------------> VARIAVEIS <----------------

    --> Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);

    -- Auxiliares
    vr_idx          PLS_INTEGER;
    vr_idcarga      tbepr_carga_pre_aprv.idcarga%TYPE;
    vr_vlparcel     NUMBER(25,2);
    vr_vldispon     NUMBER(25,2);
    vr_dscargamanu  tbepr_carga_pre_aprv.dscarga%TYPE;
    vr_innivris     NUMBER;        -- P450 24/08/2019 - nivelRisco Rating (AA a HH)
    vr_dsnivris     VARCHAR2(200); -- P450 24/08/2019 - nota Rating (AA a HH)
    
  BEGIN
    pr_tab_erro.delete;
    pr_tab_dados_cpa.delete;

    --> Somente o primeiro titular pode contratrar o pre-aprovado e nao
    --  pode ser operador de conta juridica
    IF pr_idseqttl > 1 OR pr_nrcpfope > 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se o associado pode obter o credido pre-aprovado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> Associado nao cadastrado
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Busca a carga ativa
    vr_idcarga := EMPR0002.fn_idcarga_pre_aprovado(pr_cdcooper        => pr_cdcooper
                                                  ,pr_tppessoa        => rw_crapass.inpessoa
                                                  ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base);

    --  Caso nao possua carga ativa
    IF vr_idcarga = 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se esta na tabela do pre-aprovado
    OPEN cr_crapcpa(pr_cdcooper       => pr_cdcooper
                   ,pr_tppessoa       => rw_crapass.inpessoa
                   ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                   ,pr_idcarga        => vr_idcarga);
    FETCH cr_crapcpa INTO rw_crapcpa;

    -- caso nao esteja, aborta com ok
    IF cr_crapcpa%NOTFOUND THEN
      CLOSE cr_crapcpa;
      pr_des_reto := 'OK';
      RETURN;
    ELSE
      CLOSE cr_crapcpa;
    END IF;

    -- Na tela de contas nao podemos verificar a flag
    IF pr_nmdatela <> 'CONTAS' AND fn_flg_preapv_liberado(pr_cdcooper,pr_nrdconta) = 0 THEN
      -- Saimos sem ofertas
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se esta bloqueado o pre-aprovado
    OPEN cr_crappre(pr_cdcooper => rw_crapass.cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;

    --> Buscar linha de credito
    OPEN cr_craplcr (pr_cdcooper => rw_crappre.cdcooper,
                     pr_cdlcremp => rw_crapcpa.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;

    IF cr_craplcr%NOTFOUND THEN
       CLOSE cr_craplcr;
      vr_cdcritic := 363; --> Linha nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplcr;
    END IF;


    --> Acionar o calculo do PreAprovado
    pc_calc_pre_aprovado_sintetico(pr_cdcooper        => rw_crapass.cdcooper
                                  ,pr_tppessoa        => rw_crapass.inpessoa
                                  ,pr_nrcpf_cnpj_base => rw_crapcpa.nrcpfcnpj_base
                                  ,pr_idcarga         => vr_idcarga
                                  ,pr_vlparcel        => vr_vlparcel
                                  ,pr_vldispon        => vr_vldispon
                                  ,pr_dscritic        => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Carregar temptable
    vr_idx := pr_tab_dados_cpa.count + 1;
    pr_tab_dados_cpa(vr_idx).cdcooper := rw_crapass.cdcooper;
    pr_tab_dados_cpa(vr_idx).nrdconta := rw_crapass.nrdconta;
    pr_tab_dados_cpa(vr_idx).inpessoa := rw_crapass.inpessoa;
    pr_tab_dados_cpa(vr_idx).nrcpfcgc := rw_crapass.nrcpfcnpj_base;
    pr_tab_dados_cpa(vr_idx).idastcjt := rw_crapass.idastcjt;
    pr_tab_dados_cpa(vr_idx).idcarga  := vr_idcarga;
    pr_tab_dados_cpa(vr_idx).cdlcremp := rw_crapcpa.cdlcremp;
    pr_tab_dados_cpa(vr_idx).vldiscrd := vr_vldispon;
    pr_tab_dados_cpa(vr_idx).vlcalpar := vr_vlparcel;
    pr_tab_dados_cpa(vr_idx).txmensal := rw_craplcr.txmensal;
    pr_tab_dados_cpa(vr_idx).vllimctr := rw_crapcpa.vlctrpre;
    pr_tab_dados_cpa(vr_idx).flprapol := rw_craplcr.flprapol;

     -- Se tiver valor disponível de pré aprovado
    IF NVL(vr_vldispon, 0) > 0 THEN

       vr_dscargamanu := '';
       -- Se carga manual
       IF rw_crapcpa.tpcarga = 1 THEN
          -- pega a descrição
          vr_dscargamanu := 'CARGA: '||rw_crapcpa.mensagem;

       END IF;

       -- Informar Nota Rating para Esteira - P450 24/08/2019
       OPEN cr_risco_operacoes(pr_cdcooper =>       rw_crapass.cdcooper
                           ,pr_nrcpfcnpj_base => rw_crapcpa.nrcpfcnpj_base);
       FETCH cr_risco_operacoes
         INTO vr_innivris;
       CLOSE cr_risco_operacoes;

       -- Se não localizar não incluir o bloco de indicadoresGeradosRegra que viria do MOTOR - P450 24/08/2019
           vr_dsnivris := '';
           IF vr_innivris IS NOT NULL THEN
             vr_dsnivris := risc0004.fn_traduz_risco(vr_innivris);
             IF LENGTH(TRIM(NVL(vr_dsnivris, ''))) > 0 THEN
               vr_dsnivris := 'Rating (' || vr_dsnivris || ') ';
             END IF;
           END IF;
       
       pr_tab_dados_cpa(vr_idx).msgmanua := 'Atenção: Cooperado possui Crédito Pré-Aprovado, limite '||
                                            'máximo de R$ '||to_char(pr_tab_dados_cpa(vr_idx).vldiscrd,'FM999G999G990D00MI')||
                                            ', taxa de '||to_char(pr_tab_dados_cpa(vr_idx).txmensal,'FM990D00MI')||'% a.m. '||
                                            vr_dsnivris ||
                                            vr_dscargamanu;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro na rotina EMPR0002.pc_busca_dados_cpa: ' ||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_busca_dados_cpa;


-- #### TROCAR por nova chamada #####
  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT VARCHAR2            --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT VARCHAR2) IS            --> Retorna os erros
  BEGIN

    /* .............................................................................

     Programa: pc_busca_dados_cpa_prog        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison
     Data    : Janeiro/2016                    Ultima atualizacao: 12/02/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Busca dados do credito pré-aprovado (crapcpa) pelo Progress.

     Alteracoes: 12/02/2019 - P442 - Devolução de novos campos

    ..............................................................................*/

    DECLARE
      -- Variaveis
      vr_tab_erro      GENE0001.typ_tab_erro;
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      vr_dscritic      VARCHAR2(4000);
      vr_idx           PLS_INTEGER;
      vr_xml_temp      VARCHAR2(32767);
      vr_clob_cpa      CLOB;
      vr_clob_erro     CLOB;

    BEGIN
      -- Procedimento para buscar dados do credito pré-aprovado (crapcpa)
      EMPR0002.pc_busca_dados_cpa (pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                  ,pr_cdagenci  => pr_cdagenci   --> Código da agencia
                                  ,pr_nrdcaixa  => pr_nrdcaixa   --> Numero do caixa
                                  ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                  ,pr_nmdatela  => pr_nmdatela   --> Nome da tela
                                  ,pr_idorigem  => pr_idorigem   --> Id origem
                                  ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                  ,pr_idseqttl  => pr_idseqttl   --> Sequencial do titular
                                  ,pr_nrcpfope  => pr_nrcpfope   --> CPF do operador juridico
                                  ------ OUT --------
                                  ,pr_tab_dados_cpa => vr_tab_dados_cpa  --> Retorna dados do credito pre aprovado
                                  ,pr_des_reto      => pr_des_reto       --> Retorno OK/NOK
                                  ,pr_tab_erro      => vr_tab_erro);     --> Retorna os erros

      -- Gerar xml a partir da temptable
      IF vr_tab_erro.count > 0 THEN
        GENE0001.pc_xml_tab_erro(pr_tab_erro => vr_tab_erro, --> TempTable de erro
                                 pr_xml_erro => vr_clob_erro, --> XML dos registros da temptable de erro
                                 pr_tipooper => 1,           --> Tipo de operação, 1 - Gerar XML, 2 --Gerar pltable
                                 pr_dscritic => vr_dscritic);

        pr_clob_erro := to_char(vr_clob_erro);
      ELSE
        -- Chave inicial
        vr_idx := vr_tab_dados_cpa.FIRST;
        -- Se existir e possuir valor
        IF vr_tab_dados_cpa.EXISTS(vr_idx) AND
           vr_tab_dados_cpa(vr_idx).vldiscrd > 0 THEN

          -- Criar documento XML
          dbms_lob.createtemporary(vr_clob_cpa, TRUE);
          dbms_lob.open(vr_clob_cpa, dbms_lob.lob_readwrite);

          -- Insere o cabeçalho do XML
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

          -- Escreve o registro
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo => '<registro>'||
                                                     '<cdcooper>'||vr_tab_dados_cpa(vr_idx).cdcooper||'</cdcooper>'||
                                                     '<nrdconta>'||vr_tab_dados_cpa(vr_idx).nrdconta||'</nrdconta>'||
                                                     '<inpessoa>'||vr_tab_dados_cpa(vr_idx).inpessoa||'</inpessoa>'||
                                                     '<nrcpfcgc>'||vr_tab_dados_cpa(vr_idx).nrcpfcgc||'</nrcpfcgc>'||
                                                     '<idcarga>'||vr_tab_dados_cpa(vr_idx).idcarga||'</idcarga>'||
                                                     '<cdlcremp>'||vr_tab_dados_cpa(vr_idx).cdlcremp||'</cdlcremp>'||
                                                     '<vldiscrd>'||vr_tab_dados_cpa(vr_idx).vldiscrd||'</vldiscrd>'||
                                                     '<txmensal>'||vr_tab_dados_cpa(vr_idx).txmensal||'</txmensal>'||
                                                     '<vllimctr>'||vr_tab_dados_cpa(vr_idx).vllimctr||'</vllimctr>'||
                                                     '<vlcalpar>'||vr_tab_dados_cpa(vr_idx).vlcalpar||'</vlcalpar>'||
                                                     '<flprapol>'||vr_tab_dados_cpa(vr_idx).flprapol||'</flprapol>'||
                                                     '<msgmanua>'||vr_tab_dados_cpa(vr_idx).msgmanua||'</msgmanua>'||
                                                   '</registro>');
          -- Encerrar a tag raiz
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '</raiz>'
                                 ,pr_fecha_xml      => TRUE);

        END IF;

        pr_clob_cpa := to_char(vr_clob_cpa);
      END IF;
    END;
  END pc_busca_dados_cpa_prog;


  --> Procedimento para validar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_valida_dados_cpa(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_vlemprst  IN crapepr.vlemprst%TYPE    --> Valor do emprestimo
                               ,pr_diapagto  IN INTEGER                  --> Dia de pagamento
                               ,pr_nrcpfope  IN NUMBER                   --> CPF do operador
                               ,pr_nrctremp  IN crapepr.nrctremp%TYPE    --> Numero do contrato
                               ,pr_cdcritic OUT NUMBER                   --> Retorna codigo da critica
                               ,pr_dscritic OUT VARCHAR2                 --> Retorna descrição da critica
                               ) IS
    /* .............................................................................

     Programa: pc_valida_dados_cpa        antigo: b1wgen0188.p/valida_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Odirlei Busana(AMcom)
     Data    : Junho/2018.                    Ultima atualizacao: 07/02/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para validar dados do credito pré-aprovado (crapcpa)

     Alteracoes: 19/10/2015 - Conversão Progress -> Oracle (Odirlei/AMcom)

                 07/02/2019 - P442 - Nao permitir selecionar linha de PreAprovado Online durante a contratacao
                              na Atenda - Marcos(Envolti)


    ..............................................................................*/

    ---------------> CURSORES <-----------------

    --> Verifica se esta bloqueado o pre-aprovado
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.vllimctr
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;

    -- Buscar dados do cooperado
    CURSOR cr_crapass(pr_cdcooper  IN crapass.cdcooper%TYPE
                     ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrcpfcnpj_base
      FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Cursor para buscar proposta de emprestimo aprovada sem liberação
    CURSOR cr_crapewr(pr_cdcooper IN crawepr.cdcooper%TYPE
                     ,pr_nrdconta IN crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT (ewr.qtpreemp * ewr.vlpreemp) final_emprestimo
            ,ewr.vlemprst
      FROM crawepr ewr
      WHERE ewr.cdcooper = pr_cdcooper
        AND ewr.nrdconta = pr_nrdconta
        AND ewr.nrctremp = pr_nrctremp
        AND ewr.dtaprova IS NOT NULL;
    rw_crapewr cr_crapewr%ROWTYPE;

    ---------------> VARIAVEIS <----------------

    --> Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);

    vr_idxcpa        PLS_INTEGER;
    vr_tab_dados_cpa empr0002.typ_tab_dados_cpa;
    vr_des_reto      VARCHAR2(100);
    vr_tab_erro      gene0001.typ_tab_erro;

    vr_dstextab   craptab.dstextab%TYPE;
    vr_hhsicini   NUMBER;
    vr_hhsicfim   NUMBER;
    vr_flglibera  NUMBER;
    vr_dtvigencia DATE;
    vr_idmotivo   tbgen_motivo.idmotivo%TYPE;
    vr_vldaltera  NUMBER;
    vr_valctremp  NUMBER;
  BEGIN
    -- Buscar dados do cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Cooperado nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    IF pr_vlemprst = 0 THEN
      vr_dscritic := 'Valor da contratacao nao informado';
      RAISE vr_exc_erro;
    END IF; --> IF par_vlemprst = 0

    IF pr_diapagto <= 0 OR
       pr_diapagto >= 28 THEN
      vr_dscritic := 'Dia do vencimento nao permitido';
      RAISE vr_exc_erro;
    END IF;

    -- Verificar e validar vigência do bloqueio manual
    cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => pr_cdcooper
                                       ,pr_nrdconta           => pr_nrdconta
                                       ,pr_tppessoa           => rw_crapass.inpessoa
                                       ,pr_nrcpfcnpj_base     => rw_crapass.nrcpfcnpj_base
                                       ,pr_cdproduto          => 25 -- PréAprovado
                                       ,pr_cdoperac_produto   => 1  -- Liberação
                                       ,pr_flglibera          => vr_flglibera
                                       ,pr_dtvigencia_paramet => vr_dtvigencia
                                       ,pr_idmotivo           => vr_idmotivo
                                       ,pr_dscritic           => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Somente o primeiro titular irar poder contratar
    IF pr_idseqttl > 1 THEN
      vr_cdcritic := 79;
      RAISE vr_exc_erro;
    END IF;

    -- Busca dados do Pre-Aprovado
    pc_busca_dados_cpa(pr_cdcooper => pr_cdcooper
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_nrdcaixa => pr_nrdcaixa
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_nmdatela => pr_nmdatela
                      ,pr_idorigem => pr_idorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nrcpfope => pr_nrcpfope
                      ,pr_tab_dados_cpa => vr_tab_dados_cpa
                      ,pr_des_reto => vr_des_reto
                      ,pr_tab_erro => vr_tab_erro);

    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.count > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Erro ao buscar dados do credito pre-aprovado.';
      END IF;

      RAISE vr_exc_erro;
    END IF;

    vr_idxcpa := vr_tab_dados_cpa.first;

    IF nvl(vr_idxcpa,0) = 0 THEN
      vr_dscritic := 'Associado nao possui credito pre-aprovado.';
      RAISE vr_exc_erro;
    END IF;

    -- Verificar se o contrato irá validar valor (alteração ou liberação)
    OPEN cr_crapewr(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctremp => pr_nrctremp);
    FETCH cr_crapewr INTO rw_crapewr;

    IF cr_crapewr%NOTFOUND THEN
      vr_valctremp := 0;
    ELSE
      vr_valctremp := rw_crapewr.vlemprst;
    END IF;

    CLOSE cr_crapewr;

    -- Acumular valor da tabela de liberação com o valor corrente do contrato
    vr_valctremp := vr_valctremp + vr_tab_dados_cpa(vr_idxcpa).vldiscrd;

    --> Valor a ser contratado nao pode ser maior que o limite disponivel, considerando contrato não
    IF pr_vlemprst > vr_valctremp THEN
      vr_dscritic := 'Valor informado para contratacao maior que o valor do limite pre-aprovado '||
                     'disponivel. Valor disponivel: '||
                     TO_CHAR(vr_valctremp,'FM999G999G990D00MI');
      RAISE vr_exc_erro;
    END IF;

    --> Verifica se esta bloqueado o pre-aprovado
    OPEN cr_crappre(pr_cdcooper => vr_tab_dados_cpa(vr_idxcpa).cdcooper,
                    pr_inpessoa => vr_tab_dados_cpa(vr_idxcpa).inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;

    --> Caso a origem for Internet Banking ou TAA
    IF pr_idorigem IN(3,4) THEN
      --> Valor a ser contratado nao pode ser menor que limite contratado
      IF pr_vlemprst < rw_crappre.vllimctr THEN
        vr_dscritic := 'Valor informado para contratacao nao pode ser menor que R$ '||
                       to_char(rw_crappre.vllimctr,'FM999G999G990D00MI');

        RAISE vr_exc_erro;
      END IF;

      -- Busca dstextab
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'HRCTRPREAPROV'
                                               ,pr_tpregist => pr_cdagenci);

      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Parametros de Horario nao cadastrado';
        RAISE vr_exc_erro;
      END IF;

      vr_hhsicini := gene0002.fn_busca_entrada(pr_postext => 1,
                                               pr_dstext  => vr_dstextab,
                                               pr_delimitador => ' ');
      vr_hhsicfim := gene0002.fn_busca_entrada(pr_postext => 2,
                                               pr_dstext  => vr_dstextab,
                                               pr_delimitador => ' ');

      IF gene0002.fn_busca_time < vr_hhsicini OR
         gene0002.fn_busca_time > vr_hhsicfim THEN
        vr_dscritic := 'Horario nao permitido para efetuar o pre-aprovado';
        RAISE vr_exc_erro;
      END IF;

      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      IF rw_crapdat.inproces >= 3 THEN
        vr_dscritic := 'Horario nao permitido para efetuar o pre-aprovado';
        RAISE vr_exc_erro;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic,
                                                 pr_dscritic => vr_dscritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retorno não OK
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro na rotina EMPR0002.pc_valida_dados_cpa: ' ||sqlerrm;

      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
  END pc_valida_dados_cpa;

  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_busca_alinea
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar os dados da Alineas.

     Alteracoes:

     ..............................................................................*/
    DECLARE
      -- Selecionar os dados
      CURSOR cr_crapali IS
        SELECT cdalinea
              ,dsalinea
              ,COUNT(1) OVER() qtregist
          FROM crapali
      ORDER BY cdalinea;

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_dscritic VARCHAR2(10000);

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Busca as Alineas
      FOR rw_crapali IN cr_crapali LOOP
        -- Cria atributo
        IF vr_auxconta = 0 THEN
          GENE0007.pc_gera_atributo(pr_xml      => pr_retxml
                                   ,pr_tag      => 'Dados'
                                   ,pr_atrib    => 'qtregist'
                                   ,pr_atval    => rw_crapali.qtregist
                                   ,pr_numva    => 0
                                   ,pr_des_erro => vr_dscritic);
        END IF;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'alinea'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdalinea'
                              ,pr_tag_cont => rw_crapali.cdalinea
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsalinea'
                              ,pr_tag_cont => rw_crapali.dsalinea
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;
      END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;

  END pc_busca_alinea;

  -- Busca período de bloqueio de limite por refinanceamento.
  PROCEDURE pc_busca_periodo_bloq_refin(pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_periodo_bloq_refin
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Busca período de bloqueio de limite por refinanceamento da CADPRE.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      --Variaveis auxiliares
      vr_qtmesblq crappre.qtmesblq%TYPE;

      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;

      -- Busca período de bloqueio de limite por refinanceamento
      CURSOR cr_crappre (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT qtmesblq
          FROM crappre
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;

    BEGIN

      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Inicializa variavel
      vr_qtmesblq := 0;

      -- Busca período de bloqueio de limite por refinanceamento
      OPEN cr_crappre(vr_cdcooper, pr_inpessoa);
      FETCH cr_crappre INTO vr_qtmesblq;
      CLOSE cr_crappre;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>' || vr_qtmesblq || '</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_busca_periodo_bloq_refin -->  '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_periodo_bloq_refin;

  -- Bloqueio de limite do pre aprovado por refinanceamento.
  PROCEDURE pc_bloqueia_pre_aprv_por_refin(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do cooperado
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_periodo_bloq_refin
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 11/02/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Bloqueio de limite do pre aprovado por refinanceamento.
    -- Alteracoes: 11/02/2019 - P442 - Direcionar nova chamara para bloqueio do produto (Marcos-Envolti)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Busca quantos meses deve ser bloqueado o PreAprovado
      CURSOR cr_crappre(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT pre.qtmesblq
          FROM crappre pre
              ,crapass ass
         WHERE pre.cdcooper = ass.cdcooper
           AND pre.inpessoa = ass.inpessoa
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_qtmesblq crappre.qtmesblq%TYPE;

      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Desencapsular o XML do AimaroWeb
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Busca de quantos meses deve ser bloqueado
      OPEN cr_crappre(vr_cdcooper);
      FETCH cr_crappre
       INTO vr_qtmesblq;
      CLOSE cr_crappre;

      -- Bloqueia pre aprovado na conta do cooperado
      cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                          ,pr_nrdconta           => pr_nrdconta
                                          ,pr_tppessoa           => 0
                                          ,pr_nrcpfcnpj_base     => 0
                                          ,pr_cdproduto          => 25 -- Pré-Aprovado
                                          ,pr_cdoperac_produto   => 1  -- Oferta
                                          ,pr_flglibera          => 0  -- Bloqueado
                                          ,pr_dtvigencia_paramet => add_months(rw_crapdat.dtmvtolt,vr_qtmesblq)
                                          ,pr_idmotivo           => 32 -- Refin
                                          ,pr_cdoperad           => vr_cdoperad
                                          ,pr_idorigem           => vr_idorigem
                                          ,pr_nmdatela           => vr_nmdatela
                                          ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_busca_periodo_bloq_refin -->  '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_bloqueia_pre_aprv_por_refin;

  --> Verificação de liberação/bloqueio do PreAprovado
  PROCEDURE pc_verifica_lib_blq_pre_aprov(pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE   --> codigo da cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE                    --> Numero da conta
                                         ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> codigo da situacao
                                         ,pr_des_erro OUT VARCHAR2 --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................

        Programa: pc_verifica_lib_blq_pre_aprov
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para Verificação de liberação/bloqueio do PreAprovado

        Observacao: -----

        Alteracoes: 01/06/2018 - Ajustar regra de bloqueio do pré-aprovado e ajustar
                                 tratamentos de erro. (Renato - Supero)

                    11/02/2019 - P442 - Propagar a chamada para nova rotina generica
                                 que mantem a parametrização CPF/CNPJ X Produto X Operação
                                 (Marcos-Envolti)


    ..............................................................................*/
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis auxiliares
      vr_flglibera  tbcc_param_pessoa_produto.flglibera%TYPE;
      vr_dtvigencia tbcc_param_pessoa_produto.dtvigencia_paramet%TYPE;
      vr_idmotivo   tbcc_param_pessoa_produto.idmotivo%TYPE;

      vr_possuipr   VARCHAR2(1);

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'EMPR0002'
                                ,pr_action => 'pc_verifica_lib_blq_pre_aprov');
      pr_des_erro := 'NOK';

      -- Vamos chechar a situação do produto ao cooperado
      cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => pr_cdcooper
                                         ,pr_nrdconta           => pr_nrdconta
                                         ,pr_cdproduto          => 25 -- PréAprovado
                                         ,pr_cdoperac_produto   => 1  -- Liberação
                                         ,pr_flglibera          => vr_flglibera
                                         ,pr_dtvigencia_paramet => vr_dtvigencia
                                         ,pr_idmotivo           => vr_idmotivo
                                         ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a situação permite pre aprovado
      cada0006.pc_permite_produto_situacao(pr_cdprodut => 25
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_cdsitdct => pr_cdsitdct
                                          ,pr_possuipr => vr_possuipr
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
      -- Se ocorrer erro diferente de produto nao permitido
      IF vr_possuipr <> 'N' AND vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se a situação permite liberado, e a conta tem PreAprovado bloqueado com motivo 67
      IF vr_possuipr = 'S' AND vr_idmotivo = 67 AND vr_flglibera = 0 THEN
        -- Liberar o Pre Aprovado com motivo 73 -- Situação da conta regularizada.
        cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => pr_cdcooper
                                            ,pr_nrdconta           => pr_nrdconta
                                            ,pr_tppessoa           => 0
                                            ,pr_nrcpfcnpj_base     => 0
                                            ,pr_cdproduto          => 25 -- Pré-Aprovado
                                            ,pr_cdoperac_produto   => 1  -- Oferta
                                            ,pr_flglibera          => 1  -- Liberado
                                            ,pr_dtvigencia_paramet => NULL
                                            ,pr_idmotivo           => 73 -- Situação da conta regularizada.
                                            ,pr_cdoperad           => 1
                                            ,pr_idorigem           => 5
                                            ,pr_nmdatela           => 'ATENDA'
                                            ,pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      -- Senão, se deve bloquear e não está bloquado
      ELSIF vr_possuipr = 'N' AND vr_flglibera = 1 THEN
        -- Chamar o bloqueio
        cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => pr_cdcooper
                                            ,pr_nrdconta           => pr_nrdconta
                                            ,pr_tppessoa           => 0
                                            ,pr_nrcpfcnpj_base     => 0
                                            ,pr_cdproduto          => 25 -- Pré-Aprovado
                                            ,pr_cdoperac_produto   => 1  -- Oferta
                                            ,pr_flglibera          => 0  -- Bloqueado
                                            ,pr_dtvigencia_paramet => NULL
                                            ,pr_idmotivo           => 67 -- Situação da conta não permite adesão do produto
                                            ,pr_cdoperad           => 1
                                            ,pr_idorigem           => 5
                                            ,pr_nmdatela           => 'ATENDA'
                                            ,pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

      pr_des_erro := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_verifica_lib_blq_pre_aprov: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_verifica_lib_blq_pre_aprov;

  -- Gerar tabela de historico dos bens das propostas de emprestimos. - JOB
  PROCEDURE pc_carga_hist_bpr(pr_cdcooper IN crapcop.cdcooper%TYPE) IS --> Codigo da cooperativa

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_carga_hist_bpr
    Sistema  : Emprestimo
    Sigla    : EMPR
    Autor    : Odirlei Busana - AMcom
    Data     : Abril/2017                   Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo  : Gerar tabela de historico dos bens das propostas de emprestimos. - JOB


    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

    --> Buscar coops ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             dat.dtmvtolt
        FROM crapcop cop,
             crapdat dat
       WHERE cop.cdcooper = dat.cdcooper
         AND cop.flgativo = 1
         AND cop.cdcooper = decode(nvl(pr_cdcooper,0),0,cop.cdcooper,pr_cdcooper);

    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
    vr_datdodia  DATE;

    -- Variaveis de Erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;

    vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_CARGA_HIST_BPR';
    vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_CARGA_HIST_BPR';
    vr_flgerlog  BOOLEAN := FALSE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN

      --> Controlar geração de log de execução dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

    END pc_controla_log_batch;


    PROCEDURE pc_alerta_email (pr_cdcooper IN crapcop.cdcooper%TYPE,
                               pr_dscritic IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      vr_conteudo   VARCHAR2(4000);
      vr_email_dest VARCHAR2(4000);
    BEGIN

      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- buscar destinatarios do email
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB_BPR');

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('Erro ao realizar carga de base historica de  bens da proposta de emprestimo (crapbpr)' ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||
                     '<br>Critica: '         || pr_dscritic,1,4000);

      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Falha Carga Bens proposta'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                           pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        ROLLBACK;
      WHEN OTHERS THEN

        vr_dscritic := 'Erro ao enviar alerta: '||SQLERRM;
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                           pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        ROLLBACK;

    END pc_alerta_email;

  BEGIN

    -- Verificação do calendário
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    vr_datdodia := trunc(SYSDATE);

    --> Apenas realizar a copia se for o ultimo dia de processo do mês
    IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') AND rw_crapdat.dtmvtolt = vr_datdodia THEN

      pc_controla_log_batch(pr_dstiplog => 'I');

      --> Listar coops ativas
      FOR rw_crapcop IN cr_crapcop LOOP
        BEGIN
          INSERT INTO tbepr_bens_hst
            (dtrefere
            ,cdcooper
            ,nrdconta
            ,tpctrpro
            ,nrctrpro
            ,flgalien
            ,dtmvtolt
            ,cdoperad
            ,dsrelbem
            ,persemon
            ,qtprebem
            ,vlrdobem
            ,vlprebem
            ,dscatbem
            ,nranobem
            ,nrmodbem
            ,dscorbem
            ,dschassi
            ,nrdplaca
            ,flgalfid
            ,flgsegur
            ,dtvigseg
            ,flglbseg
            ,tpchassi
            ,ufdplaca
            ,uflicenc
            ,nrrenava
            ,nrcpfbem
            ,vlmerbem
            ,idseqbem
            ,dsbemfin
            ,flgrgcar
            ,vlperbem
            ,cdsitgrv
            ,nrgravam
            ,dtatugrv
            ,flginclu
            ,dtdinclu
            ,dsjstinc
            ,tpinclus
            ,flgalter
            ,dtaltera
            ,tpaltera
            ,flcancel
            ,dtcancel
            ,tpcancel
            ,flgbaixa
            ,dtdbaixa
            ,dsjstbxa
            ,tpdbaixa
            ,nrplnovo
            ,ufplnovo
            ,nrrenovo
            ,flblqjud
            ,dstipbem)
            SELECT rw_crapdat.dtultdia
                  ,bpr.cdcooper
                  ,bpr.nrdconta
                  ,bpr.tpctrpro
                  ,bpr.nrctrpro
                  ,bpr.flgalien
                  ,bpr.dtmvtolt
                  ,bpr.cdoperad
                  ,bpr.dsrelbem
                  ,bpr.persemon
                  ,bpr.qtprebem
                  ,bpr.vlrdobem
                  ,bpr.vlprebem
                  ,bpr.dscatbem
                  ,bpr.nranobem
                  ,bpr.nrmodbem
                  ,bpr.dscorbem
                  ,bpr.dschassi
                  ,bpr.nrdplaca
                  ,bpr.flgalfid
                  ,bpr.flgsegur
                  ,bpr.dtvigseg
                  ,bpr.flglbseg
                  ,bpr.tpchassi
                  ,bpr.ufdplaca
                  ,bpr.uflicenc
                  ,bpr.nrrenava
                  ,bpr.nrcpfbem
                  ,bpr.vlmerbem
                  ,bpr.idseqbem
                  ,bpr.dsbemfin
                  ,bpr.flgrgcar
                  ,bpr.vlperbem
                  ,bpr.cdsitgrv
                  ,bpr.nrgravam
                  ,bpr.dtatugrv
                  ,bpr.flginclu
                  ,bpr.dtdinclu
                  ,bpr.dsjstinc
                  ,bpr.tpinclus
                  ,bpr.flgalter
                  ,bpr.dtaltera
                  ,bpr.tpaltera
                  ,bpr.flcancel
                  ,bpr.dtcancel
                  ,bpr.tpcancel
                  ,bpr.flgbaixa
                  ,bpr.dtdbaixa
                  ,bpr.dsjstbxa
                  ,bpr.tpdbaixa
                  ,bpr.nrplnovo
                  ,bpr.ufplnovo
                  ,bpr.nrrenovo
                  ,bpr.flblqjud
                  ,bpr.dstipbem
              FROM crapbpr bpr
             WHERE bpr.flgalien = 1
               AND bpr.cdcooper = rw_crapcop.cdcooper;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel replicar dados para a coop: '||rw_crapcop.cdcooper||' -> '||SQLERRM;
            pc_alerta_email(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);

            vr_dscritic := NULL;
        END;

        COMMIT;
      END LOOP; --> Fim loop coop

      pc_controla_log_batch(pr_dstiplog => 'F');

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    pc_alerta_email(pr_cdcooper => 3,
                    pr_dscritic => vr_dscritic);


    COMMIT;

    raise_application_error(-20501,vr_dscritic);

  WHEN OTHERS THEN

    vr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    pc_alerta_email(pr_cdcooper => 3,
                    pr_dscritic => vr_dscritic);


    COMMIT;
    raise_application_error(-20501,vr_dscritic);

  END pc_carga_hist_bpr;


  -- Procedimento de carga diaria do PreAprovado para tabelas do BI
  PROCEDURE pc_carga_pos_diaria_epr(pr_cdcooper      IN CRAPCOP.CDCOOPER%TYPE --> código da cooperativa (0-processa todas)
                                   ,pr_qtdias_manter IN NUMBER) IS            --> Quantidade de dias para manter a tabela TBBI_CPA_POSICAO_DIARIA
   /*---------------------------------------------------------------------------------------------------------------

      Programa : pc_carga_pos_diaria_epr
      Sistema  : Emprestimo
      Sigla    : EMPR
      Autor    : Roberto Holz - Mout´s
      Data     : Junho/2017                   Ultima atualizacao: 21/02/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Gerar a tabela de posição diária do pré-aprovado e contratos. - JOB


      Alteracoes: 20/02/2019 - P442 - Ajustes na rotina conforme nova estrutuda PreAprovado (Marcos Martini)

    ---------------------------------------------------------------------------------------------------------------*/
  BEGIN

    DECLARE

      -- Buscar todas as cooperativas ou somente a solicitada
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
           AND cop.cdcooper <> 3
           AND cop.flgativo = 1
         order by cop.cdcooper;

      -- Buscar todos os contratos
      CURSOR cr_pos_diaria (pr_cdcooper IN TBBI_CPA_POSICAO_DIARIA.CDCOOPER%TYPE,
                            pr_dtbase   IN DATE) IS
       SELECT tab.cdcooper
             ,tab.inpessoa
             ,tab.nrcpfcnpj_base
             ,tab.tipo_reg
             ,tab.iddcarga
             ,tab.vl_contratad
             ,tab.qt_contratos
             ,tab.vlemprst
             ,tab.vlsdevat
             ,tab.vlpreemp
             ,tab.dtliberacao
             ,tab.flglibera_pre_aprv
             ,tab.dtatualiza_pre_aprv
    FROM (-- Busca os emprestimos com finalidade 68 e com saldo
          select 9 tipo_reg
                ,epr.cdcooper
                ,ass.inpessoa
                ,ass.nrcpfcnpj_base
                ,0 iddcarga
                ,0 tp_carga
                ,0 vl_contratad
                ,count(*) qt_contratos
                ,sum(epr.vlemprst) vlemprst
                ,sum(epr.vlsdevat) vlsdevat
                ,sum(epr.vlpreemp) vlpreemp
                ,NULL dtliberacao
                ,NULL flglibera_pre_aprv
                ,NULL dtatualiza_pre_aprv
            from crappre pre
                ,crapepr epr
                ,crapass ass
           where epr.cdcooper = pr_cdcooper
             AND epr.cdcooper = ass.cdcooper
             AND epr.nrdconta = ass.nrdconta
             AND epr.cdcooper = pre.cdcooper
             AND ass.Inpessoa = pre.inpessoa
             -- emmprestimos com idcarga > 0 consomem limite do pré-aprovado
             -- porém esta regra somente começou no final de 2016 e existem
             -- emprestimos antigos (idcarga = 0) que devem ser selecionados pela finalidade 68
             AND (epr.cdfinemp = pre.cdfinemp OR epr.iddcarga > 0)
             and epr.vlsdevat > 0
             and epr.inliquid = 0
             and epr.inprejuz = 0
           group by epr.cdcooper
                   ,ass.inpessoa
                   ,ass.nrcpfcnpj_base
          UNION ALL
          -- Busca as cargas ativas tanto manual como automática --
          SELECT 0
                ,carga.cdcooper
                ,cpa.tppessoa
                ,cpa.nrcpfcnpj_base
                ,carga.idcarga
                ,carga.tpcarga
                ,cpa.vlctrpre
                ,0
                ,0
                ,0
                ,0
                ,carga.dtliberacao
                ,param.flglibera
                ,param.dtvigencia_paramet
            FROM tbepr_carga_pre_aprv carga
                ,crapcpa              cpa
                ,tbcc_param_pessoa_produto param
           WHERE carga.cdcooper = pr_cdcooper
             AND carga.cdcooper = cpa.cdcooper
             AND carga.idcarga  = cpa.iddcarga
             AND cpa.iddcarga   = empr0002.fn_idcarga_pre_aprovado(cpa.cdcooper,cpa.tppessoa,cpa.nrcpfcnpj_base)
             and param.cdcooper(+) = cpa.cdcooper
             and param.tppessoa(+) = cpa.tppessoa
             AND param.nrcpfcnpj_base(+) = cpa.nrcpfcnpj_base
             AND param.cdproduto(+) = 25 -- PreAprovado
             AND param.cdoperac_produto(+) = 1 -- Oferta
             AND (  -- Esta liberado
                    nvl(param.flglibera,1) = 1
                  OR
                    -- Nao esta, mas jah venceu
                    param.dtvigencia_paramet < TRUNC(SYSDATE)
                 )) tab
      order by 1, 2, 3, 4;

      -- Cursor para buscar o valor oriundo do SAS na CPA
      CURSOR cr_cpa_sas(pr_cdcooper       IN crapcpa.cdcooper%TYPE
                       ,pr_tppessoa       IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpfcnpj_base IN crapcpa.nrcpfcnpj_base%TYPE
                       ,pr_idcarga        IN crapcpa.iddcarga%TYPE) IS
        SELECT cpa.vlpot_lim_max
        FROM crapcpa cpa
        WHERE cpa.cdcooper = pr_cdcooper
          AND cpa.tppessoa = pr_tppessoa
          AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
          AND cpa.iddcarga = pr_idcarga;
      rw_cpa_sas cr_cpa_sas%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      vr_flgachou BOOLEAN;

      -- Variaveis
      vr_salvo_cdcooper     CECRED.TBBI_CPA_POSICAO_DIARIA.CDCOOPER%TYPE;
      vr_salvo_tppessoa     CECRED.TBBI_CPA_POSICAO_DIARIA.TPPESSOA%TYPE;
      vr_salvo_nrcpfcnpj    CECRED.TBBI_CPA_POSICAO_DIARIA.NRCPFCNPJ_BASE%TYPE;

      vr_salvo_qtcontratos  CECRED.TBBI_CPA_POSICAO_DIARIA.QTEPR_ATIVOS_PRE_APRV%TYPE;
      vr_salvo_vlemprst     CECRED.TBBI_CPA_POSICAO_DIARIA.VLEPR_ATIVOS_PRE_APRV%TYPE;
      vr_salvo_vlsdevat     CECRED.TBBI_CPA_POSICAO_DIARIA.VLSALDO_EPR_ATIVOS_PRE_APRV%TYPE;
      vr_salvo_vlpreemp     CECRED.TBBI_CPA_POSICAO_DIARIA.VLPREST_EPR_ATIVOS_PRE_APRV%TYPE;

      vr_salvo_vigente          NUMBER(1);
      vr_vig_iddcarga           CECRED.TBBI_CPA_POSICAO_DIARIA.IDCARGA%TYPE;
      vr_vig_dtliberacao        CECRED.TBBI_CPA_POSICAO_DIARIA.DTLIB_CARGA_PRE_APRV%TYPE;
      vr_vig_flglibera_pre_aprv CECRED.TBBI_CPA_POSICAO_DIARIA.FLGLIBERA_PRE_APRV%TYPE;
      vr_vig_dtatualiza_pre_aprv CECRED.TBBI_CPA_POSICAO_DIARIA.DTATUALIZA_PRE_APRV%TYPE;
      vr_vig_vl_parcel          CECRED.TBBI_CPA_POSICAO_DIARIA.VLLIM_PRE_APRV_TOTAL%TYPE;
      vr_vig_vl_limite          CECRED.TBBI_CPA_POSICAO_DIARIA.VLLIM_PRE_APRV_TOTAL%TYPE;
      vr_vig_vl_disponivel      CECRED.TBBI_CPA_POSICAO_DIARIA.VLLIM_PRE_APRV_DISPONIVEL%TYPE;


      -- Variaveis de erro
      vr_exc_erro_diaria exception;
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de log
      vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_CARGA_POS_DIARIA_EPR';
      vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_CARGA_POS_DIARIA_EPR';
      vr_flgerlog  BOOLEAN := FALSE;
      vr_cdcooperlog NUMBER;

      -- Controle da tabela de LOG
      PROCEDURE pc_controla_log(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN

        --> Controlar geração de log de execução dos jobs
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

      END pc_controla_log;

      -- Limpeza da tabela conforme parametros enviados
      PROCEDURE pc_limpeza_pos_diaria(pr_tipo_excl     IN NUMBER  -- (0 = elimina data base senão elimina antigos)
                                     ,pr_qtdias_manter IN NUMBER
                                     ,pr_cdcooper      IN CRAPCOP.CDCOOPER%TYPE
                                     ,pr_dtbase        IN CRAPDAT.DTMVTOLT%TYPE
                                     ,pr_dscritic     OUT VARCHAR2) IS

      BEGIN
        -- Se eh para eliminar a data apenas
        IF pr_tipo_excl = 0 then
          DELETE
            FROM TBBI_CPA_POSICAO_DIARIA
           WHERE TBBI_CPA_POSICAO_DIARIA.DTMVTOLT = pr_dtbase
             AND TBBI_CPA_POSICAO_DIARIA.CDCOOPER = pr_cdcooper;
        -- Elimina tudo abaixo da data
        ELSE
          DELETE
            FROM TBBI_CPA_POSICAO_DIARIA
           WHERE TBBI_CPA_POSICAO_DIARIA.DTMVTOLT <= pr_dtbase - pr_qtdias_manter
             AND TBBI_CPA_POSICAO_DIARIA.CDCOOPER = pr_cdcooper;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
           pr_dscritic := 'Problema ao excluir Posição Diária Pré-Aprovado: ' || SQLERRM;
      END pc_limpeza_pos_diaria;


    BEGIN
      -- Inicializar o LOG
      pc_controla_log(pr_dstiplog => 'I');

      -- Efetuar laço sobre todas as Cooperativs
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP -- buscando todas as cooperativas

        --> Buscar a data base da cooperativa
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        vr_flgachou := BTCH0001.cr_crapdat%FOUND;
        CLOSE BTCH0001.cr_crapdat;

        vr_cdcooperlog := rw_crapcop.cdcooper;

        -- Se nao achou
        IF NOT vr_flgachou THEN
          vr_cdcritic := 1;
          RAISE vr_exc_erro_diaria;
        END IF;

        -- Executar limpeza da TBBI_CPA_POSICAO_DIARIA da data que será gerada;
        pc_limpeza_pos_diaria( pr_tipo_excl => 0
                              ,pr_qtdias_manter => pr_qtdias_manter
                              ,pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_dtbase   => rw_crapdat.dtmvtolt
                              ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro_diaria;
        END IF;

        -- Inicializar variaveis
        vr_salvo_cdcooper          := 0;
        vr_salvo_nrcpfcnpj         := 0;
        vr_salvo_qtcontratos       := 0;
        vr_salvo_vlemprst          := 0;
        vr_salvo_vlsdevat          := 0;
        vr_salvo_vlpreemp          := 0;
        vr_salvo_vigente           := 0;
        vr_vig_iddcarga            := NULL;
        vr_vig_dtliberacao         :=  NULL;
        vr_vig_flglibera_pre_aprv  := NULL;
        vr_vig_dtatualiza_pre_aprv := NULL;
        vr_vig_vl_limite           := NULL;

        -- Buscar os registros
        FOR rw_pos_diaria IN cr_pos_diaria ( pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_dtbase   => rw_crapdat.dtmvtolt) LOOP -- busca posição diária
          -- Tratar mudança de registro
          if (   rw_pos_diaria.cdcooper <> vr_salvo_cdcooper
              or rw_pos_diaria.nrcpfcnpj_base <> vr_salvo_nrcpfcnpj) and vr_salvo_cdcooper > 0 then
            BEGIN
              INSERT INTO TBBI_CPA_POSICAO_DIARIA
               ( DTMVTOLT
                ,CDCOOPER
                ,NRDCONTA
                ,TPPESSOA
                ,NRCPFCNPJ_BASE
                ,IDCARGA
                ,VLLIM_PRE_APRV_TOTAL
                ,VLLIM_PRE_APRV_DISPONIVEL
                ,QTEPR_ATIVOS_PRE_APRV
                ,VLEPR_ATIVOS_PRE_APRV
                ,VLSALDO_EPR_ATIVOS_PRE_APRV
                ,VLPREST_EPR_ATIVOS_PRE_APRV
                ,DTLIB_CARGA_PRE_APRV
                ,FLGLIBERA_PRE_APRV
                ,DTATUALIZA_PRE_APRV
               ) VALUES
               ( rw_crapdat.dtmvtolt
                ,vr_salvo_cdcooper
                ,0
                ,vr_salvo_tppessoa
                ,vr_salvo_nrcpfcnpj
                ,vr_vig_iddcarga
                --  quando o associado está bloqueado não grava os limites, só a carga ativa (M441)
                ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,rw_cpa_sas.vlpot_lim_max)
                ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,vr_vig_vl_limite)
                ,vr_salvo_qtcontratos
                ,vr_salvo_vlemprst
                ,vr_salvo_vlsdevat
                ,vr_salvo_vlpreemp
                ,vr_vig_dtliberacao
                ,vr_vig_flglibera_pre_aprv
                ,vr_vig_dtatualiza_pre_aprv
               );
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao gravar TBBI_CPA_POSICAO_DIARIA -->'||SQLERRM;
                RAISE vr_exc_erro_diaria;
            END;
            -- Inicializar controles
            vr_salvo_vigente := 0;
            vr_vig_iddcarga := NULL;
            vr_vig_dtliberacao :=  NULL;
            vr_vig_flglibera_pre_aprv := NULL;
            vr_vig_dtatualiza_pre_aprv := NULL;
            vr_vig_vl_limite := NULL;
          END IF;

          vr_salvo_cdcooper := rw_pos_diaria.cdcooper;
          vr_salvo_tppessoa := rw_pos_diaria.inpessoa;
          vr_salvo_nrcpfcnpj := rw_pos_diaria.nrcpfcnpj_base;

          -- no primeiro registro tipo = 0 salva os valores da carga vigente
          -- a partir da segunda carga, despreza pois não é vigente
          if   rw_pos_diaria.tipo_reg = 0 THEN
            if  vr_salvo_vigente = 0 THEN
               vr_salvo_vigente := 1;
               vr_vig_iddcarga := rw_pos_diaria.iddcarga;
               vr_vig_dtliberacao :=  rw_pos_diaria.dtliberacao;
               vr_vig_flglibera_pre_aprv := rw_pos_diaria.flglibera_pre_aprv;
               vr_vig_dtatualiza_pre_aprv := rw_pos_diaria.dtatualiza_pre_aprv;
               -- Calcular o PReAprovado da pessoa
               empr0002.pc_calc_pre_aprovado_sintetico(pr_cdcooper        => vr_salvo_cdcooper
                                                      ,pr_tppessoa        => vr_salvo_tppessoa
                                                      ,pr_nrcpf_cnpj_base => vr_salvo_nrcpfcnpj
                                                      ,pr_idcarga         => vr_vig_iddcarga
                                                      ,pr_vlparcel        => vr_vig_vl_parcel
                                                      ,pr_vldispon        => vr_vig_vl_limite
                                                      ,pr_dscritic        => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro_diaria;
               END IF;

               --- Buscar o valor oriundo do SAS para o limite maximo
               OPEN cr_cpa_sas(pr_cdcooper       => vr_salvo_cdcooper
                              ,pr_tppessoa       => vr_salvo_tppessoa
                              ,pr_nrcpfcnpj_base => vr_salvo_nrcpfcnpj
                              ,pr_idcarga        => vr_vig_iddcarga);
               FETCH cr_cpa_sas INTO rw_cpa_sas;
               CLOSE cr_cpa_sas;

               -- Atualizar a posição (CRAPCPA)
               BEGIN
                 UPDATE crapcpa cpa
                    SET cpa.vlcalpre = vr_vig_vl_limite
                       ,cpa.vlcalpar = vr_vig_vl_parcel
                  WHERE cpa.cdcooper = vr_salvo_cdcooper
                    AND cpa.iddcarga = vr_vig_iddcarga
                    AND cpa.tppessoa = vr_salvo_tppessoa
                    AND cpa.nrcpfcnpj_base = vr_salvo_nrcpfcnpj;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao atualizar a posicao diaria do pre-aprovado: '||SQLERRM;
                   RAISE vr_exc_erro_diaria;
               END;
            ELSE
               CONTINUE;
            END IF;
          END IF;

          -- salva valores do tipo de registro que somente existe um por conta;
          vr_salvo_qtcontratos := rw_pos_diaria.qt_contratos;
          vr_salvo_vlemprst := rw_pos_diaria.vlemprst;
          vr_salvo_vlsdevat := rw_pos_diaria.vlsdevat;
          vr_salvo_vlpreemp := rw_pos_diaria.vlpreemp;
        END LOOP; -- busca posição diária

        -- Gravar o ultimo registro da cooperativa
        IF vr_salvo_cdcooper > 0 then
          -- Efetuar a gravação da posição diária
          BEGIN
            INSERT INTO TBBI_CPA_POSICAO_DIARIA
             ( DTMVTOLT
              ,CDCOOPER
              ,NRDCONTA
              ,TPPESSOA
              ,NRCPFCNPJ_BASE
              ,IDCARGA
              ,VLLIM_PRE_APRV_TOTAL
              ,VLLIM_PRE_APRV_DISPONIVEL
              ,QTEPR_ATIVOS_PRE_APRV
              ,VLEPR_ATIVOS_PRE_APRV
              ,VLSALDO_EPR_ATIVOS_PRE_APRV
              ,VLPREST_EPR_ATIVOS_PRE_APRV
              ,DTLIB_CARGA_PRE_APRV
              ,FLGLIBERA_PRE_APRV
              ,DTATUALIZA_PRE_APRV
             ) VALUES
             ( rw_crapdat.dtmvtolt
              ,vr_salvo_cdcooper
              ,0
              ,vr_salvo_tppessoa
              ,vr_salvo_nrcpfcnpj
              ,vr_vig_iddcarga
              --  quando o associado está bloqueado não grava os limites, só a carga ativa (M441)
              ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,rw_cpa_sas.vlpot_lim_max)
              ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,vr_vig_vl_limite)
              ,vr_salvo_qtcontratos
              ,vr_salvo_vlemprst
              ,vr_salvo_vlsdevat
              ,vr_salvo_vlpreemp
              ,vr_vig_dtliberacao
              ,vr_vig_flglibera_pre_aprv
              ,vr_vig_dtatualiza_pre_aprv
             );
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao gravar TBBI_CPA_POSICAO_DIARIA -->'||SQLERRM;
              RAISE vr_exc_erro_diaria;
          END;
        END IF;

        -- Efetuvar limpeza da data base
        IF pr_qtdias_manter > 0 then
           -- Executar limpeza da TBBI_CPA_POSICAO_DIARIA retendo n dias
           pc_limpeza_pos_diaria( pr_tipo_excl     => 1
                                 ,pr_qtdias_manter => pr_qtdias_manter
                                 ,pr_cdcooper      => rw_crapcop.cdcooper
                                 ,pr_dtbase        => rw_crapdat.dtmvtolt
                                 ,pr_dscritic      => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro_diaria;
           END IF;
        END IF;

      END LOOP; -- buscando todas as cooperativas

      -- Encerra o controle de LOG
      pc_controla_log(pr_dstiplog => 'F');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro_diaria THEN
        ROLLBACK;
        -- Se foi retornado apenas código
        IF  vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Finalizar o controle de log
        pc_controla_log(pr_dstiplog => 'E',
                        pr_dscritic => vr_dscritic);
        -- Gerar log em arquivo
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooperlog
                                  ,pr_ind_tipo_log => 2 --> erro tratado
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra ||' --> ' || vr_dscritic
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        COMMIT;
        raise_application_error(-20501,vr_dscritic);
      WHEN OTHERS THEN
        ROLLBACK;
        -- Montar erro nao tratado
        vr_dscritic := 'Erro no processamento da carga diaria PreAprv para BI: '||SQLERRM;
        -- Finalizar o controle de log
        pc_controla_log(pr_dstiplog => 'E',
                        pr_dscritic => vr_dscritic);
        -- Gerar log em arquivo
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooperlog
                                  ,pr_ind_tipo_log => 2 --> erro tratado
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - '||vr_cdprogra ||' --> ' || vr_dscritic
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        COMMIT;
        raise_application_error(-20501,vr_dscritic);
    END;
  END pc_carga_pos_diaria_epr;

  -- Buscar a finalidade de PreAprovado conforme Coop e tipo de pessoa
  FUNCTION fn_finali_pre_aprovado(pr_cdcooper crapcop.cdcooper%TYPE
                                 ,pr_inpessoa crapass.inpessoa%TYPE) RETURN NUMBER IS
    CURSOR cr_crappre IS
      SELECT pre.cdfinemp
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;
  BEGIN
    OPEN cr_crappre;
    FETCH cr_crappre
      INTO rw_crappre;
    CLOSE cr_crappre;
    RETURN rw_crappre.cdfinemp;
  END;

  -- Function para buscar os cooperados com crédito pré-aprovado ativo - Utilizada para envio de Notificações/Push
  FUNCTION fn_sql_contas_com_preaprovado RETURN CLOB IS
  BEGIN
    RETURN 'SELECT usu.cdcooper
                  ,usu.nrdconta
                  ,usu.idseqttl
                  ,''#valorcalculado='' || to_char(cpa.vlcalpre, ''fm99g999g990d00'') || '';'' ||
                   ''#valorcontratado='' || to_char(cpa.vlctrpre, ''fm99g999g990d00'') || '';'' ||
                   ''#valordisponivel='' || to_char((cpa.vlcalpre - cpa.vlctrpre), ''fm99g999g990d00'') dsvariaveis
              FROM crapcpa              cpa
                  ,vw_usuarios_internet usu
                  ,crapass              ass
             WHERE ass.cdcooper = usu.cdcooper
               AND ass.nrdconta = usu.nrdconta
               AND ass.cdcooper = cpa.cdcooper
               AND ass.inpessoa = cpa.tppessoa
               AND ass.nrcpfcnpj_base = cpa.nrcpfcnpj_base
               AND empr0002.fn_flg_preapv_liberado(cpa.cdcooper,0,cpa.tppessoa,cpa.nrcpfcnpj_base) = 1
               AND cpa.iddcarga = empr0002.fn_idcarga_pre_aprovado(cpa.cdcooper,cpa.tppessoa,cpa.nrcpfcnpj_base)
               AND (cpa.vlcalpre - cpa.vlctrpre) > 0';
  END fn_sql_contas_com_preaprovado;

  -- Inclui o motivo de nao receber o Credito Pre-aprovado
  PROCEDURE pc_inclui_motivo(pr_cdcooper        IN tbepr_motivo_nao_aprv.cdcooper%TYPE
                            ,pr_idcarga         IN tbepr_motivo_nao_aprv.idcarga%TYPE
                            ,pr_tppessoa        IN tbepr_motivo_nao_aprv.tppessoa%TYPE
                            ,pr_nrcpf_cnpj_base IN tbepr_motivo_nao_aprv.nrcpfcnpj_base%TYPE
                            ,pr_idmotivo        IN tbepr_motivo_nao_aprv.idmotivo%TYPE
                            ,pr_dsvalor         IN tbepr_motivo_nao_aprv.dsvalor%TYPE
                            ,pr_dscritic       OUT VARCHAR2) IS
  /* .............................................................................

     Programa: pc_inclui_motivo
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Reaproveitamento de codigo e gravacao dos motivos de perca de pre-aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    -- Seta como Bloqueado o Credito Pre Aprovado
    BEGIN
      INSERT INTO tbepr_motivo_nao_aprv(cdcooper
                                       ,idcarga
                                       ,tppessoa
                                       ,nrcpfcnpj_base
                                       ,idmotivo
                                       ,dtbloqueio
                                       ,dsvalor)
                                VALUES (pr_cdcooper
                                       ,pr_idcarga
                                       ,pr_tppessoa
                                       ,pr_nrcpf_cnpj_base
                                       ,pr_idmotivo
                                       ,trunc(SYSDATE)
                                       ,pr_dsvalor);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao incluir o motivo da Nao Liberacao do Pre-Aprovado: ' || SQLERRM;
    END;
  END pc_inclui_motivo;

  -- Função para buscar o id da carga atual de pre-aprovado para CPF/CNPJ raiz enviado para bloqueio
  FUNCTION fn_idcarga_pre_aprovado_motivo(pr_cdcooper        IN crapcop.cdcooper%TYPE           -- Cooperativa
                                         ,pr_tppessoa        IN crapcpa.tppessoa%TYPE           -- Tipo Pessoa
                                         ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE)    -- CPF/CNPJ Base
                                            RETURN NUMBER IS
  /* .............................................................................

     Programa: fn_idcarga_pre_aprovado_motivo
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Petter Rafael
     Data    : Maio/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Busca do ID da Carga Atual ativa para o Cooperado com bloqueio do registro

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Busca do ID da Carga
      CURSOR cr_crapcpa(pr_cdcooper        IN crapcop.cdcooper%TYPE
                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE
                       ,pr_dtmvtolt        IN DATE) IS
        SELECT cpa.iddcarga
          FROM crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.iddcarga = car.idcarga
           AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(pr_dtmvtolt)
           AND cpa.cdsituacao IN ('A', 'B')
           AND ROWNUM = 1
         ORDER BY car.tpcarga ASC, car.dtcalculo DESC;

      vr_iddcarga crapcpa.iddcarga%TYPE := 0;
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Buscar data padrão do sistema
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Buscar o ID da Carga
      OPEN cr_crapcpa(pr_cdcooper, pr_tppessoa, pr_nrcpf_cnpj_base, rw_crapdat.dtmvtolt);
      FETCH cr_crapcpa INTO vr_iddcarga;
      CLOSE cr_crapcpa;

      RETURN vr_iddcarga;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_idcarga_pre_aprovado_motivo;

  -- Função para buscar ID de carga sem considerar a data de vigencia nos status A e B
  FUNCTION fn_carga_pre_sem_vig_status(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                      ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                                      ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) RETURN NUMBER IS
  BEGIN
    DECLARE
      -- Busca do ID da Carga
      CURSOR cr_crapcpa(pr_cdcooper        IN crapcop.cdcooper%TYPE
                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) IS
        SELECT cpa.iddcarga
          FROM crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.iddcarga = car.idcarga
           AND car.indsituacao_carga  = 2
           AND car.flgcarga_bloqueada = 0
           AND cpa.cdsituacao IN ('A', 'B')
           AND ROWNUM = 1;

      vr_iddcarga crapcpa.iddcarga%TYPE := 0;
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Buscar o ID da Carga
      OPEN cr_crapcpa(pr_cdcooper, pr_tppessoa, pr_nrcpf_cnpj_base);
      FETCH cr_crapcpa INTO vr_iddcarga;
      CLOSE cr_crapcpa;

      RETURN vr_iddcarga;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_carga_pre_sem_vig_status;

  -- Função para buscar ID de carga sem considerar a data de vigencia
  FUNCTION fn_idcarga_pre_aprv_sem_vig(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                      ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                                      ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) RETURN NUMBER IS
  BEGIN
    DECLARE
      -- Busca do ID da Carga
      CURSOR cr_crapcpa(pr_cdcooper        IN crapcop.cdcooper%TYPE
                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) IS
        SELECT cpa.iddcarga
          FROM crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.iddcarga = car.idcarga
           AND car.indsituacao_carga  = 2
           AND car.flgcarga_bloqueada = 0
           AND cpa.cdsituacao = 'A'
           AND ROWNUM = 1;

      vr_iddcarga crapcpa.iddcarga%TYPE := 0;
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Buscar o ID da Carga
      OPEN cr_crapcpa(pr_cdcooper, pr_tppessoa, pr_nrcpf_cnpj_base);
      FETCH cr_crapcpa INTO vr_iddcarga;
      CLOSE cr_crapcpa;

      RETURN vr_iddcarga;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_idcarga_pre_aprv_sem_vig;

  -- Função para buscar o id da carga atual de pre-parovado para o CPF/CNPJ raiz enviado
  FUNCTION fn_idcarga_pre_aprovado(pr_cdcooper        IN crapcop.cdcooper%TYPE           -- Cooperativa
                                  ,pr_tppessoa        IN crapcpa.tppessoa%TYPE           -- Tipo Pessoa
                                  ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE)    -- CPF/CNPJ Base
                                    RETURN NUMBER IS
  /* .............................................................................

     Programa: fn_idcarga_pre_aprovado
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Busca do ID da Carga Atual ativa para o Cooperado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Busca do ID da Carga
      CURSOR cr_crapcpa(pr_cdcooper        IN crapcop.cdcooper%TYPE
                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE
                       ,pr_dtmvtolt        IN DATE) IS
        SELECT cpa.iddcarga
          FROM crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.iddcarga = car.idcarga
           AND car.indsituacao_carga  = 2
           AND car.flgcarga_bloqueada = 0
           AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(pr_dtmvtolt)
           AND cpa.cdsituacao = 'A'
         ORDER BY car.tpcarga ASC, car.dtcalculo DESC;

      vr_iddcarga crapcpa.iddcarga%TYPE := 0;
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Buscar data padrão do sistema
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Buscar o ID da Carga
      OPEN cr_crapcpa(pr_cdcooper, pr_tppessoa, pr_nrcpf_cnpj_base, rw_crapdat.dtmvtolt);
      FETCH cr_crapcpa INTO vr_iddcarga;
      CLOSE cr_crapcpa;

      -- Retornar zero quando não encontrado
      RETURN vr_iddcarga;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_idcarga_pre_aprovado;

  -- Procedure para buscar o ID de carga independente do status da CPA
  PROCEDURE pc_busca_ultima_carga(pr_cdcooper IN crapcop.cdcooper%TYPE         -- Cooperativa
                                 ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE   -- CPF/CNPJ Base
                                 ,pr_idcarga  OUT crapcpa.iddcarga%TYPE        -- Retorno do ID da carga
                                 ,pr_cdsitua  OUT crapcpa.cdsituacao%TYPE      -- Retorno da situacao do cooperado
                                 ,pr_critica  OUT VARCHAR2) IS                 -- Retorno de erros caso ocorram
    /* .............................................................................

     Programa: pc_busca_ultima_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Petter Rafael - Envolti
     Data    : Maio/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Busca do ID da Carga Atual ativa para o Cooperado por Conta retornando
                 o status da CPA em conjunto.

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Buscar dados do associado
      CURSOR cr_crapass(pr_cdcooper  IN crapass.cdcooper%TYPE
                       ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper
              ,ass.nrdconta
              ,ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar dados da carga ativa ou com bloqueio por motivo
      CURSOR cr_crapcpa(pr_cdcooper        IN crapcop.cdcooper%TYPE
                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE) IS
        SELECT cpa.iddcarga
              ,cpa.cdsituacao
          FROM crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.iddcarga = car.idcarga
           AND car.indsituacao_carga  = 2
           AND car.flgcarga_bloqueada = 0
           AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
           AND cpa.cdsituacao IN ('A', 'B')
           AND rownum = 1
         ORDER BY car.tpcarga ASC
                 ,car.dtcalculo DESC
                 ,cpa.cdsituacao ASC;
      rw_crapcpa cr_crapcpa%ROWTYPE;

      vr_exc_erro  EXCEPTION;
    BEGIN
      -- Buscar valores do associado
      OPEN cr_crapass(pr_cdcooper  => pr_cdcooper
                     ,pr_nrdconta  => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        pr_critica := 'Associado nao cadastrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Buscar valores CPA
      OPEN cr_crapcpa(pr_cdcooper        => pr_cdcooper
                     ,pr_tppessoa        => rw_crapass.inpessoa
                     ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base);
      FETCH cr_crapcpa INTO rw_crapcpa;

      pr_idcarga := rw_crapcpa.iddcarga;
      pr_cdsitua := rw_crapcpa.cdsituacao;

      CLOSE cr_crapcpa;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_critica := pr_critica;
      WHEN OTHERS THEN
        pr_critica := 'Ero na procedure EMPR0002.PC_BUSCA_ULTIMA_CARGA. ' || SQLERRM;
    END;
  END pc_busca_ultima_carga;

  -- Função para buscar o id da carga atual de pre-parovado para a conta enviada
  FUNCTION fn_idcarga_pre_aprovado_cta(pr_cdcooper IN crapcop.cdcooper%TYPE           -- Cooperativa
                                      ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE)    -- CPF/CNPJ Base
                                    RETURN NUMBER IS
  /* .............................................................................

     Programa: fn_idcarga_pre_aprovado
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Busca do ID da Carga Atual ativa para o Cooperado por Conta.

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Busca o CPF/CNPJ da Conta
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE := 0;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE := 0;
    BEGIN
      -- Buscar o CPF/CNPJ base
      OPEN cr_crapass;
      FETCH cr_crapass INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;
      -- Acionar a proc que retornar o ID pelo CPF/CNPJ
      RETURN fn_idcarga_pre_aprovado(pr_cdcooper        => pr_cdcooper
                                    ,pr_tppessoa        => vr_inpessoa
                                    ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj_base);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_idcarga_pre_aprovado_cta;

  -- Procedure para invocar a função de busca do id da carga atual de pre-parovado para a conta enviada
  PROCEDURE pc_idcarga_pre_aprovado_cta(pr_cdcooper IN crapcop.cdcooper%TYPE           -- Cooperativa
                                       ,pr_nrdconta IN crapcpa.nrcpfcnpj_base%TYPE     -- Conta
                                       ,pr_idcarga OUT crapcpa.iddcarga%TYPE)          -- ID da carga disponível
                                        IS
  /* .............................................................................

     Programa: pc_idcarga_pre_aprovado_cta
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Busca do ID da Carga Atual ativa para o Cooperado por Conta.

     Alteracoes:
     ..............................................................................*/
  BEGIN
    BEGIN
      -- Invocar a função
      pr_idcarga := fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta);
    EXCEPTION
      WHEN OTHERS THEN
        pr_idcarga := 0;
    END;
  END pc_idcarga_pre_aprovado_cta;

  -- Procedimento para efetuar a checagem de perca temporaria do PreAprovado por motivos configurados na CADPRE
  PROCEDURE pc_proces_perca_pre_aprovad(pr_cdcooper        IN crapcop.cdcooper%TYPE                    -- Cooperatia
                                       ,pr_idcarga         IN crapcpa.iddcarga%TYPE DEFAULT 0          -- ID da Carga
                                       ,pr_nrdconta        IN crapass.nrdconta%TYPE DEFAULT 0          -- Conta
                                       ,pr_tppessoa        IN crapcpa.tppessoa%TYPE DEFAULT 0          -- Tipo de PEssoa
                                       ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE DEFAULT 0    -- CPF/CNPJ Base
                                       ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE                    -- Data atual
                                       ,pr_idmotivo        IN tbgen_motivo.idmotivo%TYPE               -- Motivo
                                       ,pr_qtdiaatr        IN NUMBER                                   -- Dias em atraso
                                       ,pr_valoratr        IN NUMBER                                   -- Valor em atraso
                                       ,pr_dscritic        OUT VARCHAR2)IS                             -- Erro na chamada
  BEGIN
    /* .............................................................................

     Programa: pc_proces_perca_pre_aprovad
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Rodar as regras de perca temporaria do PreAprovado em caso do Cooperado
                 nao atender os criterios

     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Buscar o associado
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = decode(pr_nrdconta,0,ass.nrdconta,pr_nrdconta)
           AND ass.inpessoa = decode(pr_tppessoa,0,ass.inpessoa,pr_tppessoa)
           AND ass.Nrcpfcnpj_Base = decode(pr_nrcpf_cnpj_base,0,ass.nrcpfcnpj_base,pr_nrcpf_cnpj_base);
      rw_crapass cr_crapass%ROWTYPE;

      -- Validar o motivo
      CURSOR cr_motivo IS
        SELECT mot.dsmotivo
          FROM tbgen_motivo mot
         WHERE mot.idmotivo = pr_idmotivo;
      rw_motivo cr_motivo%ROWTYPE;

      -- Checagem de existência
      CURSOR cr_exis(pr_idcarga        crapcpa.iddcarga%TYPE
                    ,pr_tppessoa       tbepr_motivo_nao_aprv.tppessoa%TYPE
                    ,pr_nrcpfcnpj_base tbepr_motivo_nao_aprv.nrcpfcnpj_base%TYPE
                    ,pr_idmotivo       tbepr_motivo_nao_aprv.idmotivo%TYPE) IS
        SELECT mna.ROWID
          FROM tbepr_motivo_nao_aprv mna
         WHERE mna.cdcooper = pr_cdcooper
           AND mna.idcarga  = pr_idcarga
           AND mna.tppessoa = pr_tppessoa
           AND mna.nrcpfcnpj_base = pr_nrcpfcnpj_base
           AND mna.idmotivo = pr_idmotivo
           AND mna.dtregulariza IS NULL; -- Ainda não regularizado
      vr_rowid ROWID;

      -- Variaveis auxiliares
      vr_idcarga crapcpa.iddcarga%TYPE;
      vr_dsvalor tbepr_motivo_nao_aprv.dsvalor%TYPE;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic  NUMBER;
      vr_dscritic  VARCHAR2(4000);
      vr_sem_carga EXCEPTION;
    BEGIN
      -- Buscar o associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      -- Buscar a carga ativa caso não enviada
      IF pr_idcarga = 0 THEN
        vr_idcarga := empr0002.fn_idcarga_pre_aprovado(pr_cdcooper        => pr_cdcooper
                                                      ,pr_tppessoa        => rw_crapass.inpessoa
                                                      ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base);
      ELSE
        vr_idcarga := pr_idcarga;
      END IF;

      -- Validar carga não encontrada após pesquisa
      IF vr_idcarga = 0 OR vr_idcarga IS NULL THEN
        RAISE vr_sem_carga;
      END IF;

      -- Validar o motivo
      OPEN cr_motivo;
      FETCH cr_motivo INTO rw_motivo;

      -- Se não encontrar
      IF cr_motivo%NOTFOUND THEN
        CLOSE cr_motivo;
        vr_dscritic := 'Motivo '||pr_idmotivo||' invalido!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_motivo;

      -- Passadas as validações, iremos checar se já não existe registro para o cooperado na carga com o mesmo motivo
      OPEN cr_exis(vr_idcarga
                  ,rw_crapass.inpessoa
                  ,rw_crapass.nrcpfcnpj_base
                  ,pr_idmotivo);
      FETCH cr_exis INTO vr_rowid;

      -- Se encontrou
      IF cr_exis%NOTFOUND THEN
        -- Iremos inserir
        BEGIN
          INSERT INTO tbepr_motivo_nao_aprv
                      (cdcooper
                      ,nrdconta
                      ,idcarga
                      ,idmotivo
                      ,dsvalor
                      ,tppessoa
                      ,nrcpfcnpj_base
                      ,dtbloqueio)
                VALUES(pr_cdcooper
                      ,0
                      ,vr_idcarga
                      ,pr_idmotivo
                      ,NULL
                      ,rw_crapass.inpessoa
                      ,rw_crapass.nrcpfcnpj_base
                      ,pr_dtmvtolt);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir Motivo de Perca do PreAprovado: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Atualizar a CPA para bloquear somente a pessoa
      BEGIN
        UPDATE crapcpa cpa
           SET cpa.cdsituacao = 'B'
              ,cpa.cdoperad_bloque = '1'
              ,cpa.dtbloqueio = pr_dtmvtolt
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.iddcarga = vr_idcarga
           AND cpa.tppessoa       = rw_crapass.inpessoa
           AND cpa.nrcpfcnpj_base = rw_crapass.nrcpfcnpj_base;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a situacao do pre-aprovado: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_sem_carga THEN
        NULL;
      WHEN vr_exc_saida THEN
        ROLLBACK;
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Propagar criticas
        pr_dscritic := 'Erro tratado. Rotina pc_proces_perca_pre_aprovad. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro nao tratado. Rotina pc_proces_perca_pre_aprovad. Detalhes: '||SQLERRM;
    END;
  END pc_proces_perca_pre_aprovad;

  -- Procedimento para efetuar a liberação de perca temporaria do PreAprovado por motivos configurados na CADPRE
  PROCEDURE pc_regularz_perca_pre_aprovad(pr_cdcooper IN crapcop.cdcooper%TYPE                        -- Cooperatia
                                         ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0              -- ID da Carga
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0              -- Conta
                                         ,pr_tppessoa IN crapcpa.tppessoa%TYPE DEFAULT 0              -- Tipo de PEssoa
                                         ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE DEFAULT 0 -- CPF/CNPJ Base
                                         ,pr_idmotivo IN tbgen_motivo.idmotivo%TYPE -- Motivo
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data atual
                                         ,pr_dscritic OUT VARCHAR2)                 -- Erro na chamada
                                        IS
  BEGIN
    /* .............................................................................

     Programa: pc_regularz_perca_pre_aprovad
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Fevereiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Remover a perca temporaria do PreAprovado em caso do Cooperado
                 nao atender os criterios

     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Buscar o associado
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = decode(pr_nrdconta,0,ass.nrdconta,pr_nrdconta)
           AND ass.inpessoa = decode(pr_tppessoa,0,ass.inpessoa,pr_tppessoa)
           AND ass.Nrcpfcnpj_Base = decode(pr_nrcpf_cnpj_base,0,ass.nrcpfcnpj_base,pr_nrcpf_cnpj_base);
      rw_crapass cr_crapass%ROWTYPE;

      -- Validar o motivo
      CURSOR cr_motivo IS
        SELECT mot.dsmotivo
          FROM tbgen_motivo mot
         WHERE mot.idmotivo = pr_idmotivo;
      rw_motivo cr_motivo%ROWTYPE;

      -- Verificar se existem motivos ativos
      CURSOR cr_motivos_abertos(pr_idcarga        tbepr_motivo_nao_aprv.idcarga%TYPE
                               ,pr_nrcpfcnpj_base tbepr_motivo_nao_aprv.nrcpfcnpj_base%TYPE
                               ,pr_cdcooper       tbepr_motivo_nao_aprv.cdcooper%TYPE) IS
        SELECT 1
        FROM tbepr_motivo_nao_aprv ppp
        WHERE ppp.idcarga = pr_idcarga
          AND ppp.nrcpfcnpj_base = pr_nrcpfcnpj_base
          AND ppp.cdcooper = pr_cdcooper
          AND ppp.dtregulariza IS NULL;
      rw_motivos_abertos cr_motivos_abertos%ROWTYPE;

      -- Variaveis auxiliares
      vr_idcarga crapcpa.iddcarga%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      -- Buscar o associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      -- Buscar a carga ativa caso não enviada
      IF pr_idcarga = 0 THEN
        vr_idcarga := empr0002.fn_idcarga_pre_aprovado(pr_cdcooper        => pr_cdcooper
                                                      ,pr_tppessoa        => rw_crapass.inpessoa
                                                      ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base);
      ELSE
        vr_idcarga := pr_idcarga;
      END IF;

      -- Validar o motivo
      OPEN cr_motivo;
      FETCH cr_motivo INTO rw_motivo;

      -- Se não encontrar
      IF cr_motivo%NOTFOUND THEN
        CLOSE cr_motivo;
        vr_dscritic := 'Motivo '||pr_idmotivo||' invalido!';
        RAISE vr_exc_saida;
      END IF;

      CLOSE cr_motivo;

      -- Atualizar a data de liberação do motivo
      UPDATE tbepr_motivo_nao_aprv mna
      SET mna.dtregulariza = pr_dtmvtolt
      WHERE mna.cdcooper = pr_cdcooper
        AND mna.idcarga = vr_idcarga
        AND mna.nrcpfcnpj_base = rw_crapass.nrcpfcnpj_base
        AND mna.tppessoa = rw_crapass.inpessoa
        AND mna.idmotivo = pr_idmotivo;

      -- Identificar se algum registro foi alterado
      IF SQL%ROWCOUNT > 0 THEN
        -- Verificar se existe motivo ativo antes de liberar registro de pre-aprovado
        OPEN cr_motivos_abertos(pr_idcarga        => vr_idcarga
                               ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                               ,pr_cdcooper       => pr_cdcooper);
        FETCH cr_motivos_abertos INTO rw_motivos_abertos;

        IF cr_motivos_abertos%NOTFOUND THEN
          UPDATE crapcpa cpa
          SET cpa.cdsituacao = 'A'
          WHERE cpa.cdcooper = pr_cdcooper
            AND cpa.iddcarga = vr_idcarga
            AND cpa.tppessoa       = rw_crapass.inpessoa
            AND cpa.nrcpfcnpj_base = rw_crapass.nrcpfcnpj_base;
        END IF;

        CLOSE cr_motivos_abertos;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Propagar criticas
        pr_dscritic := 'Erro tratado. Rotina pc_regularz_perca_pre_aprovad. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro nao tratado. Rotina pc_regularz_perca_pre_aprovad. Detalhes: '||SQLERRM;
    END;
  END pc_regularz_perca_pre_aprovad;

  -- Processo de carga via SAS
  PROCEDURE pc_carga_autom_via_SAS(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                  ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                  ,pr_skcarga  IN tbepr_carga_pre_aprv.skcarga_sas%TYPE -- SK Carga SAS
                                  ,pr_cddopcao   IN VARCHAR2             -- Opção (Importar ou Bloquear)
                                  ,pr_dsrejeicao IN VARCHAR2             -- Texto da rejeição
                                  ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                   ) IS
    /* .............................................................................

     Programa: pc_carga_autom_via_SAS
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Fevereiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Efetuar Carga via SAS do idCargaSas enviado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Chacagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
              ,dat.dtmvtoan
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar informações do pre-aprovado conforme tipo de pessoa
      CURSOR cr_crappre(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT pre.cdfinemp
              ,pre.qtdiavig
              ,pre.vllimaut
          FROM crappre pre
         WHERE pre.cdcooper = pr_cdcooper
           AND pre.inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Checagem da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdfinemp crapfin.cdfinemp%TYPE
                       ,pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT lcr.flgstlcr
          FROM craplcr lcr
              ,craplch lch
         WHERE lch.cdcooper = pr_cdcooper
           AND lch.cdfinemp = pr_cdfinemp
           AND lch.cdlcrhab = pr_cdlcremp
           AND lcr.cdcooper = lch.cdcooper
           AND lcr.cdlcremp = lch.cdlcrhab;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Verifica se a carga tem crítica
      CURSOR cr_crapcpa_critica(pr_idcarga crapcpa.iddcarga%TYPE) IS
        SELECT COUNT(cpa.dscritica) qtdCritica,
                cpa.dscritica dsCritica
           FROM crapcpa cpa
          WHERE cpa.dscritica IS NOT NULL
            AND cpa.iddcarga = pr_idcarga
      AND UPPER(cpa.dscritica) NOT LIKE UPPER('Encontrada carga manual%')
      AND UPPER(cpa.dscritica) NOT LIKE UPPER('cpf/cnpj%')
       GROUP BY cpa.dscritica;
       vr_crapcpa_critica VARCHAR2(3000);

      -- Buscar registros carregados
      CURSOR cr_crapcpa(pr_idcarga crapcpa.iddcarga%TYPE) IS
        SELECT cpa.rowid nr_rowid
              ,cpa.cdcooper
              ,cpa.tppessoa
              ,cpa.nrcpfcnpj_base
              ,cpa.cdlcremp
              ,cpa.vlpot_parc_maximo
              ,cpa.vlpot_lim_max
              ,row_number() over (partition By cpa.tppessoa
                                      order by cpa.tppessoa
                                              ,cpa.nrcpfcnpj_base) nrseqreg
              ,cpa.nrdconta
              ,cpa.dtmvtolt
          FROM crapcpa cpa
         WHERE cpa.iddcarga = pr_idcarga
           AND cpa.cdsituacao = 'A'; -- Somente aprovados

      -- Checagem de existencia do Cooperado
      CURSOR cr_crapass(pr_cdcooper  crapcop.cdcooper%TYPE
                       ,pr_inpessoa  crapass.inpessoa%TYPE
                       ,pr_nrcpfcnpj crapass.nrcpfcnpj_base%TYPE) IS
        SELECT nrdconta
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND nrcpfcnpj_base = pr_nrcpfcnpj;

      vr_nrdconta crapass.nrdconta%TYPE;
      vr_limMax        NUMBER;

      -- Variáveis para criação de cursor dinâmico
      vr_nom_owner     VARCHAR2(100) := gene0005.fn_get_owner_sas;
      vr_nom_dblink_ro VARCHAR2(100);
      vr_nom_dblink_rw VARCHAR2(100);

      -- Queries externas
      vr_num_cursor    number;
      vr_num_retor     number;
      vr_sql_cursor    varchar2(32000);

      -- Queries dinamicas internas
      vr_num_cursor_int    number;
      vr_num_retor_int     number;
      vr_sql_cursor_int    varchar2(32000);

      -- Colunas do retorno da carga
      vr_skcarga         NUMBER;
      vr_cdcopcar        NUMBER;
      vr_dscarga         VARCHAR2(500);
      vr_vlpotenlimtotal NUMBER := 0;
      vr_qtpfcarregados  NUMBER := 0;
      vr_qtpjcarregados  NUMBER := 0;
      vr_dtcarga         DATE;
      vr_dthoraini       DATE;
      vr_dthorafim       DATE;

      vr_indsituac       NUMBER := 0;

      -- Atualização de registros
      vr_idcarga         tbepr_carga_pre_aprv.idcarga%TYPE;
      vr_dtinicio        DATE;
      vr_dtfinali        DATE;
      vr_qtpf_erros  NUMBER := 0;
      vr_qtpj_erros  NUMBER := 0;
      vr_vllim_erros NUMBER := 0;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_critica_libera EXCEPTION;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);

      -- LOG
      vr_nrdrowid ROWID;
      vr_nrcontad  NUMBER := 0;

      -- Texto de Importado/Bloqueado
      vr_dstxtlog  VARCHAR2(4000);

      -- Buscar rejeitados manualmente
      CURSOR cr_cparej(pr_idcarga NUMBER) IS
        SELECT nvl(sum(decode(cpa.tppessoa,1,1,0)),0)
              ,nvl(sum(decode(cpa.tppessoa,2,1,0)),0)
              ,nvl(SUM(cpa.vlpot_lim_max),0)
          FROM crapcpa cpa
         WHERE cpa.iddcarga   = pr_idcarga
           AND cpa.cdsituacao = 'R';

      vr_flgrating         PLS_INTEGER;
      vr_insituacao_rating tbrisco_operacoes.insituacao_rating%TYPE;

      vr_innivris       tbrisco_operacoes.inrisco_rating%TYPE;
    BEGIN
      -- Validar se cooperativa existe
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        -- Incrementar o erro
        vr_dscritic := vr_dscritic || ' não encontrada ou inativa!';
        -- Erro critico
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Validar Modelo
      IF pr_cdcooper IS NULL THEN
        vr_dscritic := 'Cooperativa deve ser informado!';
        RAISE vr_exc_saida;
      END IF;

      -- Validar SKCarga
      IF pr_skcarga IS NULL THEN
        vr_dscritic := 'ID Carga deve ser informado!';
        RAISE vr_exc_saida;
      END IF;

      -- Validar Opção
       IF pr_cddopcao IS NULL OR pr_cddopcao NOT IN('I','R', 'L') THEN
        vr_dscritic := 'Opcao invalida! Favor enviar [I]mportar, [R]eprovar ou [L]iberar!';
        RAISE vr_exc_saida;
      END IF;

      -- Validar Operador
      IF pr_cdoperad IS NULL THEN
        vr_dscritic := 'Operador conectado deve ser informado!';
        RAISE vr_exc_saida;
      END IF;

      -- Validar Motivo Rejeicao
      IF pr_cddopcao = 'R' AND pr_dsrejeicao IS NULL THEN
        vr_dscritic := 'Motivo da Rejeicao e obrigatorio para esta opcao!';
        RAISE vr_exc_saida;
      END IF;

      vr_nom_dblink_rw := gene0005.fn_get_dblink_sas('W');
      IF vr_nom_dblink_rw IS NULL THEN
        vr_dscritic := 'Nao foi possivel retornar o DBLink(RW) do SAS, verifique!';
        RAISE vr_exc_saida;
      END IF;

      -- Validar FatorControleCarga
      vr_sql_cursor := 'SELECT pot.skcarga '
                    || '      ,pot.cdcooper '
                    || '      ,pot.dscarga '
                    || '      ,pot.vlpotenlimtotal '
                    || '      ,pot.qtpfcarregados '
                    || '      ,pot.qtpjcarregados '
                    || '      ,pot.dtcarga '
                    || '      ,car.dthorainicioprocesso '
                    || '      ,car.dthorafimprocesso '
                    || '      ,nvl(carAim.indsituacao_carga,0) indsituac '
                    || '      ,carAim.idcarga '
                    || '  FROM '||vr_nom_owner||'sas_preaprovado_carga@'||vr_nom_dblink_rw||' pot '
                    || '      ,'||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                    || '      ,tbepr_carga_pre_aprv       carAim '
                    || ' WHERE car.skcarga = carAim.Skcarga_Sas(+) '
                    || '   AND pot.skcarga = car.skcarga '
                    || '   AND pot.skcarga = '||pr_skcarga
                    || '   AND car.qtregistroprocessado > 0 '
                    || '   AND car.dthorafiminclusao is not null '
                    || '   AND nvl(carAim.Indsituacao_Carga,0) IN(0,1) '
                    || ' ORDER BY pot.dtcarga desc ';

      vr_num_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);

      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_skcarga);
      dbms_sql.define_column(vr_num_cursor, 2, vr_cdcopcar);
      dbms_sql.define_column(vr_num_cursor, 3, vr_dscarga, 500);
      dbms_sql.define_column(vr_num_cursor, 4, vr_vlpotenlimtotal);
      dbms_sql.define_column(vr_num_cursor, 5, vr_qtpfcarregados);
      dbms_sql.define_column(vr_num_cursor, 6, vr_qtpjcarregados);
      dbms_sql.define_column(vr_num_cursor, 7, vr_dtcarga);
      dbms_sql.define_column(vr_num_cursor, 8, vr_dthoraini);
      dbms_sql.define_column(vr_num_cursor, 9, vr_dthorafim);
      dbms_sql.define_column(vr_num_cursor, 10, vr_indsituac);
      dbms_sql.define_column(vr_num_cursor, 11, vr_idcarga);

      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);

      LOOP
        -- Verifica se há alguma linha de retorno do cursor
        vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);

        IF vr_num_retor = 0 THEN
          -- Se o cursor dinamico está aberto
          IF dbms_sql.is_open(vr_num_cursor) THEN
            -- Fecha o mesmo
            dbms_sql.close_cursor(vr_num_cursor);
          END IF;
          EXIT;
        ELSE
          -- Carrega variáveis com o retorno do cursor
          dbms_sql.column_value(vr_num_cursor, 1, vr_skcarga);
          dbms_sql.column_value(vr_num_cursor, 2, vr_cdcopcar);
          dbms_sql.column_value(vr_num_cursor, 3, vr_dscarga);
          dbms_sql.column_value(vr_num_cursor, 4, vr_vlpotenlimtotal);
          dbms_sql.column_value(vr_num_cursor, 5, vr_qtpfcarregados);
          dbms_sql.column_value(vr_num_cursor, 6, vr_qtpjcarregados);
          dbms_sql.column_value(vr_num_cursor, 7, vr_dtcarga);
          dbms_sql.column_value(vr_num_cursor, 8, vr_dthoraini);
          dbms_sql.column_value(vr_num_cursor, 9, vr_dthorafim);
          dbms_sql.column_value(vr_num_cursor, 10, vr_indsituac);
          dbms_sql.column_value(vr_num_cursor, 11, vr_idcarga);

          -- Acumular contador
          vr_nrcontad := nvl(vr_qtpfcarregados,0) + nvl(vr_qtpjcarregados,0);

          -- Somente em caso de Bloqueio ou Importação
          IF pr_cddopcao in('B','I', 'R') THEN
            -- Somente se o processo não tenha iniciado ainda
            IF vr_dthoraini IS NULL THEN
              -- Armazenar inicio do processo
              vr_dtinicio := SYSDATE;
            ELSE
              vr_dtinicio := vr_dthoraini;
            END IF;

            -- Primeiro vamos gravar a tabela pai (somente se não gravada ainda)
            IF vr_idcarga IS NULL THEN
              BEGIN
                INSERT INTO tbepr_carga_pre_aprv(cdcooper
                                                ,dtcalculo
                                                ,dtliberacao
                                                ,flgcarga_bloqueada
                                                ,indsituacao_carga
                                                ,tpcarga
                                                ,dscarga
                                                ,dtfinal_vigencia
                                                ,skcarga_sas
                                                ,qtcarga_pf
                                                ,qtcarga_pj
                                                ,vllimite_total
                                                ,cdoperad_libera)
                                          VALUES(vr_cdcopcar
                                                ,vr_dtcarga
                                                ,vr_dtinicio
                                                ,0 -- Bloqueada
                                                ,decode(pr_cddopcao,'I',1,3)
                                                ,2 -- Automatica
                                                ,vr_dscarga
                                                ,NULL
                                                ,vr_skcarga
                                                ,vr_qtpfcarregados
                                                ,vr_qtpjcarregados
                                                ,vr_vlpotenlimtotal
                                                ,pr_cdoperad)
                                          RETURNING idcarga INTO vr_idcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao criar historico de carga: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- Processar rejeição de carga
            IF pr_cddopcao = 'R' THEN
              BEGIN
                UPDATE tbepr_carga_pre_aprv
                SET indsituacao_carga = 3
                   ,dsmotivo_rejeicao = pr_dsrejeicao
                WHERE idcarga = vr_idcarga;

                vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                  || 'set car.dthorafimprocesso = to_date(''' || TO_CHAR(SYSDATE, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                                  || '   ,car.dthorainicioprocesso = to_date(''' || TO_CHAR(SYSDATE, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                                  || ' where car.skcarga = '||vr_skcarga;

                -- Executar query dinamica
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);

                -- Atualizar tabela SAS do header da carga para bloqueio
                vr_sql_cursor_int := 'UPDATE ' || vr_nom_owner || 'sas_preaprovado_carga@' || vr_nom_dblink_rw || ' car '
                                  || 'SET car.dtbloqueio = TO_DATE(''' || TO_CHAR(vr_dtfinali, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                                  || '   ,car.cdopbloqueio = ''' || pr_cdoperad || ''' '
                                  || 'WHERE car.skcarga = ' || vr_skcarga;

                -- Executar query dinamica
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);
             EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na carga do PreAprovado: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;

            -- Se solicitado Importação, então faremos a carga dos limites por Cooperado
            ELSIF pr_cddopcao = 'I' THEN
              -- Na sequencia a carga do score
              BEGIN
                vr_sql_cursor_int := 'INSERT INTO crapcpa(cdcooper '
                              || '                       ,nrdconta '
                              || '                       ,tppessoa '
                              || '                       ,nrcpfcnpj_base '
                              || '                       ,dtmvtolt '
                              || '                       ,iddcarga '
                              || '                       ,vlctrpre '
                              || '                       ,cdlcremp '
                              || '                       ,cdrating '
                              || '                       ,dtcalc_rating '
                              || '                       ,vlpot_parc_maximo '
                              || '                       ,vlpot_lim_max '
                              || '                       ,cdsituacao) '
                              || '                  SELECT lim.cdcooper '
                              || '                        ,0 '
                              || '                        ,lim.tppessoa '
                              || '                        ,lim.nrcpfcnpjbase '
                              || '                        ,to_date('''||to_char(rw_crapcop.dtmvtolt,'ddmmyyyy')||''',''ddmmyyyy'')'
                              || '                        ,'||vr_idcarga
                              || '                        ,0 '
                              || '                        ,lim.cdlcremp '
                              || '                        ,lim.cdrating '
                              || '                        ,lim.dtcalculorating '
                              || '                        ,lim.vlpotenparmax '
                              || '                        ,lim.vlpotenlimmax '
                              || '                        ,''A'''
                              || '                    FROM '||vr_nom_owner||'sas_preaprovado_limite@'||vr_nom_dblink_rw||' lim '
                              || '                   WHERE lim.skcarga = '||vr_skcarga;

                -- Processar cursor dinâmico
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);

                -- Gravar execução para o SAS
                vr_sql_cursor_int := 'UPDATE ' || vr_nom_owner || 'sas_preaprovado_limite@' || vr_nom_dblink_rw || ' car '
                                  || 'SET car.cdstatuscarga = 1 '
                                  || '   ,car.dsstatuscarga = ''ACEITO'' '
                                  || 'WHERE car.skcarga = ' || vr_skcarga;

                -- Processar cursor dinâmico
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);

                -- Se não carregou nada
                IF vr_num_retor_int = 0 THEN
                  vr_dscritic := 'Erro na carga do PreAprovado. Nenhum registro encontrado para o IDCarga e Cooperativa enviada!';
                  RAISE vr_exc_saida;
                END IF;
              EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na carga do PreAprovado: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Depois das exclusões
              BEGIN
                vr_sql_cursor_int := 'INSERT INTO tbepr_motivo_nao_aprv '
                              || '                       (cdcooper '
                              || '                       ,nrdconta '
                              || '                       ,idcarga '
                              || '                       ,tppessoa '
                              || '                       ,nrcpfcnpj_base '
                              || '                       ,dtbloqueio '
                              || '                       ,idmotivo_sas '
                              || '                       ,dsmotivo_sas) '
                              || '                  SELECT exc.cdcooper '
                              || '                        ,0 '
                              || '                        ,'||vr_idcarga
                              || '                        ,exc.tppessoa '
                              || '                        ,exc.nrcpfcnpjbase '
                              || '                        ,NULL '
                              || '                        ,exc.cdexclusao '
                              || '                        ,exc.dsexclusao '
                              || '                    FROM '||vr_nom_owner||'sas_preaprovado_exclusoes@'||vr_nom_dblink_rw||' exc '
                              || '                   WHERE exc.skcarga = '||vr_skcarga;

                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);
              EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na carga de exclusoes do PreAprovado: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Efetuar validação de registros (CPF e tipo pessoa que não correspondem a associado)
              FOR rw_cpa IN cr_crapcpa(vr_idcarga) LOOP
                -- No primeiro registro de Tipo de Pessoa
                IF rw_cpa.nrseqreg = 1 THEN
                  -- Buscar informações do pre-aprovado conforme tipo de pessoa
                  OPEN cr_crappre(rw_cpa.cdcooper ,rw_cpa.tppessoa);
                  FETCH cr_crappre INTO rw_crappre;

                  IF cr_crappre%NOTFOUND THEN
                    CLOSE cr_crappre;

                    -- Invalidaremos todos os registros deste tipo de pessoa
                    BEGIN
                      UPDATE crapcpa cpa
                         SET cpa.cdsituacao = 'R'
                            ,cpa.dscritica = 'Tipo Pessa Invalida! Nao encontrado configuracao Pre Aprovado para a Cooperativa e Tipo de Pesssoa!'
                       WHERE cpa.cdcooper = rw_cpa.cdcooper
                         AND cpa.tppessoa = rw_cpa.tppessoa
                         AND cpa.iddcarga  = vr_idcarga;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao atualizar situacao do registro para Rejeitado(PRE): '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  ELSE
                    CLOSE cr_crappre;
                  END IF;
                END IF;

                -- Atualizar o valor do potencial limite caso ultrapasse o parametrizado
                IF rw_cpa.vlpot_lim_max > NVL(rw_crappre.vllimaut,0)  THEN
                  BEGIN
                    UPDATE crapcpa cpa
                       SET cpa.vlpot_lim_max = rw_crappre.vllimaut
                     WHERE cpa.rowid = rw_cpa.nr_rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar situacao do registro para Rejeitado(LCR): '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;

                -- Validar existencia da Linha de Credito
                OPEN cr_craplcr(rw_cpa.cdcooper,rw_crappre.cdfinemp,rw_cpa.cdlcremp);
                FETCH cr_craplcr
                 INTO rw_craplcr;

                IF cr_craplcr%NOTFOUND THEN
                  CLOSE cr_craplcr;

                  -- Invalidaremos todos os registros da carga
                  BEGIN
                    UPDATE crapcpa cpa
                       SET cpa.cdsituacao = 'R'
                          ,cpa.dscritica = 'Carga com Linha de Credito Invalida! Nao existe relacionamento com PreAprovado ou a Linha esta bloqueada!'
                     WHERE cpa.cdcooper = rw_cpa.cdcooper
                       AND cpa.iddcarga  = vr_idcarga;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar situacao do registro para Rejeitado(LCR): '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  CLOSE cr_craplcr;
                END IF;

                -- Testar existencia de associado com o CPF/CNPJ Base
                vr_nrdconta := NULL;
                OPEN cr_crapass(rw_cpa.cdcooper,rw_cpa.tppessoa,rw_cpa.nrcpfcnpj_base);
                FETCH cr_crapass INTO vr_nrdconta;
                CLOSE cr_crapass;

                -- Se não encontrou
                IF vr_nrdconta IS NULL THEN
                  -- Iremos criticar o registro
                  BEGIN
                    UPDATE crapcpa cpa
                       SET cpa.cdsituacao = 'R'
                          ,cpa.dscritica = 'CPF/CNPJ Raiz Invalido! Nao encontrado Cooperado na Cooperativa!'
                     WHERE cpa.rowid = rw_cpa.nr_rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar situacao do registro para Rejeitado(ASS): '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  -- Buscar o status do rating pré-aprovado
                  rati0003.pc_busca_status_rating(pr_cdcooper => rw_cpa.cdcooper
                                                 ,pr_nrdconta => rw_cpa.nrcpfcnpj_base
                                                 ,pr_tpctrato => 68
                                                 ,pr_nrctrato => 0
                                                 ,pr_strating => vr_insituacao_rating 
                                                 ,pr_flgrating => vr_flgrating
                                                 ,pr_cdcritic => vr_cdcritic 
                                                 ,pr_dscritic => vr_dscritic);
                  -- So irá gravar Rating caso o limite pré-aprovado esteja invalido
                  -- Diferente de Analisado ou Efetivo
                  IF nvl(vr_flgrating,0) = 0 THEN  -- Rating nao valido
                    IF rati0003.fn_retorna_modelo_rating(pr_cdcooper => rw_cpa.cdcooper) = 2 THEN -- Modelo Ibratan
                    rati0003.pc_grava_rating_operacao(pr_cdcooper => rw_cpa.cdcooper
                                                     ,pr_nrdconta => vr_nrdconta
                                                     ,pr_tpctrato => 68
                                                     ,pr_nrctrato => 0
                                                     ,pr_strating => 3 
                                                     ,pr_orrating => 1
                                                     ,pr_cdoprrat => pr_cdoperad
                                                     ,pr_nrcpfcnpj_base => rw_cpa.nrcpfcnpj_base 
                                                     ,pr_cdoperad => pr_cdoperad 
                                                     ,pr_dtmvtolt => rw_crapcop.dtmvtolt
                                                     ,pr_justificativa => 'Carga automática SAS limite' 
                                                     ,pr_tpoperacao_rating => 68 
                                                     ,pr_cdcritic =>  vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
                    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_saida;
                      END IF;
                    ELSIF rati0003.fn_retorna_modelo_rating(pr_cdcooper => rw_cpa.cdcooper) = 1 THEN -- Modelo Aimaro, gravar em modo contingência
                      rati0003.pc_busca_rat_contigencia(pr_cdcooper => rw_cpa.cdcooper,
                                                       pr_nrcpfcgc => rw_cpa.nrcpfcnpj_base, --> CPFCNPJ BASE
                                                       pr_innivris => vr_innivris,                         --> risco contingencia
                                                       pr_cdcritic => vr_cdcritic,
                                                       pr_dscritic => vr_dscritic);
                      -- grava o rating contingencia
                      RATI0003.pc_grava_rating_operacao(pr_cdcooper       => rw_cpa.cdcooper  --> Código da Cooperativa
                                                       ,pr_nrdconta       => vr_nrdconta  --> Conta do associado
                                                       ,pr_tpctrato       => 68  --> Tipo do contrato de rating
                                                       ,pr_nrctrato       => 0  --> Número do contrato do rating
                                                       ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                                       ,pr_dtrataut       => rw_crapcop.dtmvtolt --> Data do Rating retornado do MOTOR
                                                       ,pr_strating       => 3   --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                                       ,pr_orrating       => 4   --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                                       ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                                       ,pr_nrcpfcnpj_base => rw_cpa.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                                       ,pr_cdoperad       => '1'
                                                       ,pr_dtmvtolt       => rw_crapcop.dtmvtolt
                                                       ,pr_cdcritic       => vr_cdcritic
                                                       ,pr_dscritic       => vr_dscritic);
                      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        RAISE vr_exc_saida;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END LOOP;

              -- Atualizar registros com carga manual vigente para reprovados
              BEGIN
                UPDATE crapcpa cpa
                   SET cpa.cdsituacao = 'R' -- Recusada
                      ,cpa.dscritica = 'Encontrada carga manual. Coop.: ' || cpa.cdcooper || ' - Doc.: ' || cpa.nrcpfcnpj_base || ' - em ' || rw_crapcop.dtmvtolt
                 WHERE cpa.iddcarga = vr_idcarga
                   -- Exista uma carga Manual Ativa para o mesmo
                   AND EXISTS(SELECT 1
                                FROM crapcpa              cpa2
                                    ,tbepr_carga_pre_aprv car2
                              WHERE cpa2.cdcooper = car2.cdcooper
                                AND cpa2.iddcarga = car2.idcarga
                                AND cpa2.cdcooper = cpa.cdcooper
                                AND cpa2.tppessoa = cpa.tppessoa
                                AND cpa2.nrcpfcnpj_base = cpa.nrcpfcnpj_base
                                AND cpa2.cdsituacao = 'A' -- Ativa
                                AND car2.tpcarga = 1 -- Manual
                                AND car2.indsituacao_carga = 2 -- Liberada
                                AND car2.flgcarga_bloqueada = 0 -- Não bloqueada
                                AND nvl(car2.dtfinal_vigencia,rw_crapcop.dtmvtolt) >= rw_crapcop.dtmvtolt);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar cargas automaticas para rejeitas devido carga manual: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Inserir motivo 51 para os registros marcados acima
              BEGIN
                INSERT INTO tbepr_motivo_nao_aprv mot
                            (cdcooper
                            ,nrdconta
                            ,idcarga
                            ,tppessoa
                            ,nrcpfcnpj_base
                            ,idmotivo
                            ,dtbloqueio)
                      SELECT cpa.cdcooper
                            ,cpa.nrdconta
                            ,vr_idcarga
                            ,cpa.tppessoa
                            ,cpa.nrcpfcnpj_base
                            ,51 -- Carga manual
                            ,NULL
                        FROM crapcpa cpa
                      WHERE cpa.cdcooper = pr_cdcooper
                        AND cpa.iddcarga = vr_idcarga
                        AND cpa.cdsituacao = 'R';
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir motivos cargas automaticas rejeitas devido carga manual: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              --
              -- Todo o bloco de cálculo foi realocado para a liberação da carga
              --

              -- Buscar quantidades de rejeitos para atualizar a carga
              OPEN cr_cparej(vr_idcarga);
              FETCH cr_cparej
               INTO vr_qtpf_erros
                   ,vr_qtpj_erros
                   ,vr_vllim_erros;
              CLOSE cr_cparej;

              -- Guardar data de termino
              vr_dtfinali := SYSDATE;

              BEGIN
                -- Atualizar FatorCarga com quantidade processada e fim da carga
                vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                  || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                  || '      ,car.qtregistrook = '||to_char((vr_qtpfcarregados - vr_qtpf_erros) + (vr_qtpjcarregados - vr_qtpj_erros))
                                  || '      ,car.qtregistroerro = '||to_char(vr_qtpf_erros + vr_qtpj_erros)
                                  || '      ,car.dthorainicioprocesso = to_date('''||to_char(vr_dtinicio,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                  || ' where car.skcarga = '||vr_skcarga;

                -- Executar query dinamica
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);

                -- Atualizar tabela SAS do header da carga
                vr_sql_cursor_int := 'UPDATE ' || vr_nom_owner || 'sas_preaprovado_carga@' || vr_nom_dblink_rw || ' car '
                                  || 'SET car.dtliberacao = TO_DATE(''' || TO_CHAR(vr_dtfinali, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                                  || '   ,car.cdopliberacao = ''' || pr_cdoperad || ''' '
                                  || 'WHERE car.skcarga = ' || vr_skcarga;

                -- Executar query dinamica
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);
              EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualizar quantidades processadas pois pode ter havido exclusão manual
              BEGIN
                UPDATE tbepr_carga_pre_aprv car
                   SET car.qtcarga_pf     = (vr_qtpfcarregados - vr_qtpf_erros)
                      ,car.qtcarga_pj     = (vr_qtpjcarregados - vr_qtpj_erros)
                      ,car.vllimite_total = (vr_vlpotenlimtotal - vr_vllim_erros)
                      -- Se há erros, mudamos para Rejeitada, senão mantemos a situação OK
                      ,car.indsituacao_carga = decode(vr_qtpf_erros+vr_qtpj_erros,3,indsituacao_carga,car.indsituacao_carga)
                      ,car.dsmotivo_rejeicao = vr_dscritic
                 WHERE car.idcarga = vr_idcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar quantidades da carga: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            ELSE
              -- Guardar data de termino
              vr_dtfinali := SYSDATE;

              -- Atualizar FatorCarga com quantidade de registros rejeitados e fim da carga
              BEGIN
                vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                  || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                  || '      ,car.qtregistroerro = '||to_char(vr_qtpfcarregados + vr_qtpjcarregados)
                                  || ' where car.skcarga = '||vr_skcarga;

                -- Cria cursor dinâmico
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);

                -- Atualizar tabela SAS do header da carga
                vr_sql_cursor_int := 'UPDATE ' || vr_nom_owner || 'sas_preaprovado_carga@' || vr_nom_dblink_rw || ' car '
                                  || 'SET car.dtliberacao = TO_DATE(''' || TO_CHAR(vr_dtfinali, 'ddmmrrrrhh24miss') || ''',''ddmmrrrrhh24miss'') '
                                  || '   ,car.cdopliberacao = ''' || pr_cdoperad || ''' '
                                  || 'WHERE car.skcarga = ' || vr_skcarga;

                -- Executar query dinamica
                vr_num_cursor_int := dbms_sql.open_cursor;
                dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
                vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
                dbms_sql.close_cursor(vr_num_cursor_int);
              EXCEPTION
                WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida;
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- Gravar a cada fator_controle_carga
            COMMIT;
          ELSE
           -- Se tem carga
           IF vr_idcarga IS NOT NULL THEN
               vr_crapcpa_critica := NULL;
               -- Abre o cursor buscando pela carga
               FOR rw_cr_crapcpa_critica IN cr_crapcpa_critica(vr_idcarga) LOOP
                 IF vr_crapcpa_critica IS NULL THEN
                  vr_crapcpa_critica:= 'Carga não pode ser Liberada, críticas da carga: ';
                 END IF;
                 vr_crapcpa_critica := vr_crapcpa_critica ||
                           ' QTD: '||rw_cr_crapcpa_critica.qtdCritica ||' - '||
                           rw_cr_crapcpa_critica.dsCritica;
               END LOOP;

               -- Verifica se tem crítica para a carga
               IF vr_crapcpa_critica IS NOT NULL THEN
                  vr_dscritic  := vr_crapcpa_critica;
                  RAISE vr_critica_libera;
               END IF;

            -- Processo de liberação, validaremos a situação
            IF vr_indsituac <> 1 THEN
              vr_dscritic := 'Carga nao pode ser Liberada! Verifique a situação da mesma!';
              RAISE vr_exc_saida;
            END IF;

              -- Calcular o pre-aprovado de cada associados da Carga para gerar a posição inicial da parcela e calculo
              FOR rw_cpa IN cr_crapcpa(vr_idcarga) LOOP
                DECLARE
                  vr_vlcalpar crapcpa.vlcalpar%TYPE;
                  vr_vlcalpre crapcpa.vlcalpre%TYPE;

                BEGIN
                  -- Buscar informações do pre-aprovado conforme tipo de pessoa
                  OPEN cr_crappre(rw_cpa.cdcooper ,rw_cpa.tppessoa);
                  FETCH cr_crappre INTO rw_crappre;
                  CLOSE cr_crappre;

                  -- Calcular o pre-aprovado no momento da liberação
                  pc_calc_pre_aprovado_sintetico(pr_cdcooper        => rw_cpa.cdcooper
                                                ,pr_idcarga         => vr_idcarga
                                                ,pr_tppessoa        => rw_cpa.tppessoa
                                                ,pr_nrcpf_cnpj_base => rw_cpa.nrcpfcnpj_base
                                                ,pr_vlparcel        => vr_vlcalpar
                                                ,pr_vldispon        => vr_vlcalpre
                                                ,pr_dscritic        => vr_dscritic);

                  -- Se houve erro
                  IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;

                  -- Calcular necessidade de limitar valor potencial maximo pela CADPRE
                  vr_limMax := owa_util.ite(rw_cpa.vlpot_lim_max > NVL(rw_crappre.vllimaut, 0), NVL(rw_crappre.vllimaut, 0), rw_cpa.vlpot_lim_max);

                  -- Atualizar com os valores calculados
                  UPDATE crapcpa cpa
                     SET cpa.vlcalpar = vr_vlcalpar
                        ,cpa.vlcalpre = vr_vlcalpre
                        ,cpa.vlpot_lim_max = vr_limMax
                   WHERE cpa.rowid = rw_cpa.nr_rowid;

                  -- P450 Inicio
                  -- Buscar o status do rating pré-aprovado
                  rati0003.pc_busca_status_rating(pr_cdcooper => rw_cpa.cdcooper
                                                 ,pr_nrdconta => rw_cpa.nrcpfcnpj_base
                                                 ,pr_tpctrato => 68
                                                 ,pr_nrctrato => 0
                                                 ,pr_strating => vr_insituacao_rating 
                                                 ,pr_flgrating => vr_flgrating
                                                 ,pr_cdcritic => vr_cdcritic 
                                                 ,pr_dscritic => vr_dscritic);


                  IF nvl(vr_insituacao_rating,0) NOT IN (2,4,6) THEN -- 6-Modelo Aimaro gravado em contingência
                    -- Bloquear situação do limite do cooperado
                    empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => rw_cpa.cdcooper
                                                        ,pr_idcarga         => vr_idcarga
                                                        ,pr_nrdconta        => 0 
                                                        ,pr_tppessoa        => rw_cpa.tppessoa 
                                                        ,pr_nrcpf_cnpj_base => rw_cpa.nrcpfcnpj_base
                                                        ,pr_dtmvtolt        => rw_cpa.dtmvtolt
                                                        ,pr_idmotivo        => 82--> Bloqueio pre-aprovado sem rating
                                                        ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                                        ,pr_valoratr        => 0 --> valor não será mais enviado
                                                        ,pr_dscritic        => vr_dscritic);

                    IF vr_dscritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;
                    
                  END IF;                                       
                  -- P450 Fim

                  -- Buscar todas as Contas do Cooperado via CPF/CNPJ
                  FOR rw_crapass IN cr_crapass(pr_cdcooper,rw_cpa.tppessoa,rw_cpa.nrcpfcnpj_base) LOOP
                    -- Gerar LOG
                    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => ''
                                        ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                                        ,pr_dstransa => 'Carga de PreAprovado via Carga SAS'
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1 --> TRUE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => 0
                                        ,pr_nmdatela => pr_cdprogra
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => 'Pendente');
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Linha de Credito'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => rw_cpa.cdlcremp);
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Potencial Parc. Maximo.'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(rw_cpa.vlpot_parc_maximo,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Potencial Limite Maximo.'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(rw_cpa.vlpot_lim_max,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Parc. Calculada'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_vlcalpar,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'PreAprovado Calculado'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_vlcalpre,'fm999g999g999g999d00'));
                  END LOOP;
                EXCEPTION
                  WHEN vr_exc_saida THEN
                    RAISE vr_exc_saida;
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao calcular a posicao do PreAprovado, CPF/CNPJ '||rw_cpa.nrcpfcnpj_base||', critica: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END LOOP;

              -- Atualizar a carga para liberada
              BEGIN
                UPDATE tbepr_carga_pre_aprv car
                   SET car.indsituacao_carga  = 2 -- Mudar para Liberada
                      ,car.flgcarga_bloqueada = 0 -- Desbloqueia a carga
                 WHERE car.idcarga = vr_idcarga
                   AND car.indsituacao_carga = 1;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar quantidades da carga: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Atualizar outra carga Automática para Susbtituida
              BEGIN
                 UPDATE tbepr_carga_pre_aprv car
                  SET car.indsituacao_carga = 4
                     ,car.flgcarga_bloqueada = 1
                     ,car.dtfinal_vigencia = rw_crapcop.dtmvtoan
                  WHERE car.cdcooper IN (SELECT car.cdcooper
                                         FROM tbepr_carga_pre_aprv car
                                         WHERE car.tpcarga = 2
                                           AND car.flgcarga_bloqueada = 0
                                           AND car.idcarga = vr_idcarga)
                    AND car.tpcarga = 2
                    AND car.flgcarga_bloqueada = 0
                    AND car.idcarga < vr_idcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na desativacao de outras Cargas automaticas --> '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Buscar todos os associados da carga para gerar o LOG
              FOR rw_cpa IN cr_crapcpa(vr_idcarga) LOOP
                BEGIN
                  -- Buscar todas as Contas do Cooperado via CPF/CNPJ
                  FOR rw_crapass IN cr_crapass(pr_cdcooper,rw_cpa.tppessoa,rw_cpa.nrcpfcnpj_base) LOOP
                    -- Gerar LOG
                    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => ''
                                        ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                                        ,pr_dstransa => 'Carga de PreAprovado via Carga SAS'
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1 --> TRUE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => 0
                                        ,pr_nmdatela => pr_cdprogra
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => 'Liberado');
                  END LOOP;
                EXCEPTION
                  WHEN vr_exc_saida THEN
                    RAISE vr_exc_saida;
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao gerar log da Liberacao, CPF/CNPJ '||rw_cpa.nrcpfcnpj_base||', critica: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END LOOP;
            END IF;
          END IF;
        END IF;
      END LOOP;

      -- Se não encontrou nenhum registro
      IF pr_cddopcao in('I','R') AND vr_nrcontad = 0 THEN
        -- Gerar erro
        vr_dscritic := 'IdCarga '||pr_skcarga||' na Cooperativa '||pr_cdcooper||' sem registro para carga! Processo nao efetuado...';
        RAISE vr_exc_saida;
      END IF;

      -- Montar log conforme o tipo execução
      IF pr_cddopcao = 'R' THEN
        vr_dstxtlog := ' efetuou rejeicao da Carga ID '||pr_skcarga||' com total de '||vr_nrcontad||' Cooperados. Motivo: '||pr_dsrejeicao;
      ELSIF pr_cddopcao = 'I' THEN
        vr_dstxtlog := ' solicitou a Importacao da Carga ID '||pr_skcarga||' com total de '||vr_nrcontad||' Cooperados';
      ELSE
        vr_dstxtlog := ' solicitou a Liberacao da Carga ID '||pr_skcarga||' com total de '||vr_nrcontad||' Cooperados';
      END IF;

      -- Gerar LOG no Batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2
                                ,pr_nmarqlog      => pr_cdprogra
                                ,pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - '||pr_cdprogra||' --> '
                                                  || ' Cooperativa:'||pr_cdcooper
                                                  || ',Operador '||pr_cdoperad
                                                  || vr_dstxtlog || ' via Carga SAS de PreAprovado.');

      -- Efetuar a gravação
      COMMIT;

      -- Ao final, caso tenhamos encontrado critica que invalidou a Carga, retornar ao Cooperado
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Carga invalida! Favor checar o problema abaixo e solicite nova carga SAS:<br>'||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
    WHEN vr_critica_libera THEN -- Trata a exception da carga com critica ao liberar
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_saida THEN
        ROLLBACK;
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Propagar criticas
        pr_dscritic := 'Erro tratado. Rotina pc_carga_autom_via_SAS. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro nao tratado. Rotina pc_carga_autom_via_SAS. Detalhes: '||SQLERRM;
    END;
  END pc_carga_autom_via_SAS;


  -- Processo de carga manual via arquivo enviado
  PROCEDURE pc_carga_manual_via_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                       ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                       ,pr_tpexecuc IN VARCHAR2               -- Tipo da Execução (Simulação ou Importação)
                                       ,pr_dsdireto IN VARCHAR2               -- Diretorio do arquivo
                                       ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                       ,pr_xmldados IN OUT NOCOPY CLOB        -- Saida de informações
                                       ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                       ) IS
    /* .............................................................................

     Programa: pc_carga_manual_via_arquivo
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Receber um arquivo com informações de carga de pre-aprovado,
                 efetuar leitura linha a linha e integrar as informações ao
                 produto Pré_aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Variaveis para interface SO
      vr_typ_said    VARCHAR2(50);  -- Critica
      vr_des_erro    VARCHAR2(5000); -- Critica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(32767);
      vr_cargaerr EXCEPTION;

      -- LOG
      vr_nrdrowid ROWID;

      -- Manipulação de arquivos
      vr_dsdireto   VARCHAR2(5000);
      vr_nrcontad   PLS_INTEGER := 0;                 -- Contador de registros
      vr_input_file UTL_FILE.FILE_TYPE;               -- Handle para leitura de arquivo
      vr_setlinha   VARCHAR2(5000);                   -- Texto do arquivo lido
      vr_vet_campos gene0002.typ_split;               -- Array de arquivos
      vr_dscribas   VARCHAR2(5000);                   -- Critica basica

      -- Campos da linha
      vr_cdcooper  crapcpa.cdcooper%TYPE;
      vr_dscarga   tbepr_carga_pre_aprv.dscarga%TYPE;
      vr_dsmsgavi  tbepr_carga_pre_aprv.dsmensagem_aviso%TYPE;
      vr_dtvigenci tbepr_carga_pre_aprv.dtfinal_vigencia%TYPE;
      vr_tppesoa   crapcpa.tppessoa%TYPE;
      vr_nrcpfcnpj NUMBER(14);
      vr_cdlcremp  crapcpa.cdlcremp%TYPE;
      vr_vlpotpar  crapcpa.vlpot_parc_maximo%TYPE;
      vr_vlpotlim  crapcpa.vlpot_lim_max%TYPE;
      vr_cdrating  crapcpa.cdrating%TYPE;
      vr_dtrating  crapcpa.dtcalc_rating%TYPE;
      vr_dscrireg  VARCHAR2(32000);

      -- Gravação
      vr_idcarga   crapcpa.iddcarga%TYPE;

      -- Dados para o XML
      vr_txtclob VARCHAR2(32767);
      vr_fltemerr VARCHAR2(1);      -- Se há erro
      vr_flgbloqcarga VARCHAR2(1);  -- Se há erro bloqueando a carga
      vr_dsmensag VARCHAR2(5000);   -- Mensagem para ser retornada a tela

      vr_idx2     PLS_INTEGER;

      vr_flgrating         PLS_INTEGER;
      vr_insituacao_rating tbrisco_operacoes.insituacao_rating%TYPE;
      
      -- Vetores para armazenar as chaves de Carga e Cooperado e evitar duplicidade
      TYPE typ_reg_hash_busca IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(1000);
      vr_tab_hash_cargas   typ_reg_hash_busca;
      vr_tab_hash_cooperad typ_reg_hash_busca;
      vr_idx_hash_cargas   VARCHAR2(1000);
      vr_idx_hase_cooperad VARCHAR2(1000);
      vr_idx_carga         PLS_INTEGER;

      vr_innivris       tbrisco_operacoes.inrisco_rating%TYPE;
      -- Vetor de cooperados da Carga (Detalhe)
      TYPE typ_reg_cooperad IS RECORD(tppesoa   crapcpa.tppessoa%TYPE
                                     ,nrcpfcnpj  NUMBER(14)
                                     ,cdlcremp  crapcpa.cdlcremp%TYPE
                                     ,vlpotpar  crapcpa.vlpot_parc_maximo%TYPE
                                     ,vlpotlim  crapcpa.vlpot_lim_max%TYPE
                                     ,cdrating  crapcpa.cdrating%TYPE
                                     ,dtrating  crapcpa.dtcalc_rating%TYPE
                                     ,dscrireg  VARCHAR2(32000));
      TYPE typ_tab_cooperad IS TABLE OF typ_reg_cooperad INDEX BY PLS_INTEGER; -- Tipo(1) || NrCpfCnpjBase(12)

      -- Vetor de cargas (Capa)
      TYPE typ_reg_carga IS RECORD(cdcooper  crapcpa.cdcooper%TYPE
                                  ,dscarga   tbepr_carga_pre_aprv.dscarga%TYPE
                                  ,dsmsgavi  tbepr_carga_pre_aprv.dsmensagem_aviso%TYPE
                                  ,dtvigenci tbepr_carga_pre_aprv.dtfinal_vigencia%TYPE
                                  ,vlpotpar  crapcpa.vlpot_parc_maximo%TYPE
                                  ,vlpotlim  crapcpa.vlpot_lim_max%TYPE
                                  ,vlpotlimtot  crapcpa.vlpot_lim_max%TYPE
                                  ,qtregipf  NUMBER
                                  ,qtregipj  NUMBER
                                  ,qtderros  PLS_INTEGER
                                  ,tabcooper typ_tab_cooperad);
      TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER; -- Usaremos a linha do arquivo
      vr_tab_carga typ_tab_carga;

      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Chacagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar informações do pre-aprovado conforme tipo de pessoa
      CURSOR cr_crappre(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT pre.cdfinemp
              ,pre.qtdiavig
              ,pre.vllimman
          FROM crappre pre
         WHERE pre.cdcooper = pr_cdcooper
           AND pre.inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Chacagem de existencia do Cooperado por documento e tipo de pessoa
      CURSOR cr_crapass_pessoa(pr_cdcooper  crapcop.cdcooper%TYPE
                              ,pr_nrcpfcnpj crapass.nrcpfcnpj_base%TYPE
                              ,pr_inpessoa  crapass.inpessoa%TYPE) IS
        SELECT ass.nrdconta
        FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrcpfcnpj_base = pr_nrcpfcnpj
          AND ass.inpessoa = pr_inpessoa;
      vr_nrdconta crapass.nrdconta%TYPE;

      -- Chacagem de existencia do Cooperado
      CURSOR cr_crapass(pr_cdcooper  crapcop.cdcooper%TYPE
                       ,pr_inpessoa  crapass.inpessoa%TYPE
                       ,pr_nrcpfcnpj crapass.nrcpfcnpj_base%TYPE) IS
        SELECT nrdconta
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND nrcpfcnpj_base = pr_nrcpfcnpj;

      -- Checagem da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_cdfinemp crapfin.cdfinemp%TYPE
                       ,pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT lcr.flgstlcr
          FROM craplcr lcr
              ,craplch lch
         WHERE lch.cdcooper = pr_cdcooper
           AND lch.cdfinemp = pr_cdfinemp
           AND lch.cdlcrhab = pr_cdlcremp
           AND lcr.cdcooper = lch.cdcooper
           AND lcr.cdlcremp = lch.cdlcrhab;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Buscar ultimo rating da conta
      CURSOR cr_crapnrc(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT crapnrc.indrisco
              ,crapnrc.dtmvtolt
          FROM crapnrc
         WHERE crapnrc.cdcooper = pr_cdcooper
           AND crapnrc.nrdconta = pr_nrdconta
           AND crapnrc.tpctrrat IN(1,4) -- Limite ou Epr/Fin
         ORDER BY crapnrc.dtmvtolt DESC;
    BEGIN
      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Busca o diretório do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'upload');

      IF pr_tpexecuc NOT IN ('I') THEN
        -- Realizar a cópia do arquivo do AyllosWeb para a pasta upload
        GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||pr_dsdireto||pr_nmarquiv||' S'
                     ,pr_typ_saida   => vr_typ_said
                     ,pr_des_saida   => vr_des_erro);

         -- Testar erro
        IF vr_typ_said = 'ERR' OR vr_typ_said = 'OUT' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_dscritic := 'Erro no recebimento do arquivo, nao sera possivel processar. Detalhes: ' || vr_des_erro;
        RAISE vr_cargaerr;
        END IF;
      END IF;

      -- Com o arquivo recebido, iremos transformá-lo em tabela de memória para facilidade de manutenção posterior dos dados
      GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_dsdireto||'/'||pr_nmarquiv
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_input_file
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se houve erros na abertura do arquivo
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_dsdireto||'/'||pr_nmarquiv;
        RAISE vr_cargaerr;
      END IF;

      -- Laco para leitura de linhas do arquivo
      LOOP
        BEGIN
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Incrementar quantidade linhas
          vr_nrcontad := vr_nrcontad + 1;

          -- Desconsiderar a linha de header do arquivo
          IF vr_nrcontad = 1 THEN
            continue;
          END IF;

          -- Remover possiveis " no começo e final
          vr_setlinha := rtrim(ltrim(vr_setlinha,'"'),'"');

          -- Separar os campos da linha em um vetor
          vr_vet_campos := gene0002.fn_quebra_string(vr_setlinha,';');

          -- Caso a linha não tenha 9 posições, iremos criticar o arquivo inteiro
          IF vr_vet_campos.count() <> 9 THEN
            vr_dscritic := 'Erro geral na leitura do arquivo! Linha '||vr_nrcontad||' nao possui 9 colunas!';
            RAISE vr_exc_saida;
          END IF;

          -- LImpar variaveis temp
          vr_cdcooper  := NULL;                  --> Código cooperativa
          vr_dscarga   := NULL;                  --> Descrição da carga
          vr_dsmsgavi  := NULL;                  --> Anotação da carga
          vr_dtvigenci := NULL;                  --> Data devigência
          vr_tppesoa   := NULL;                  --> Tipo pessoa
          vr_nrcpfcnpj := NULL;                  --> CNPJ/CPF
          vr_cdlcremp  := NULL;                  --> Linha de crédito
          vr_vlpotpar  := NULL;                  --> Valor potencial parcela
          vr_vlpotlim  := NULL;                  --> Limite potencial
          vr_cdrating  := 'A';
          vr_dtrating  := TRUNC(SYSDATE-180);
          vr_dscrireg  := NULL;
          vr_nrdconta  := NULL;

          -- Bloco para facilitar tratamento de erros
          BEGIN
            -- Montar inicio de mensagem de erro padrão
            --vr_dscribas := 'Erro na leitura da linha '||vr_nrcontad||' campo ';
            -- Cooperativa
            vr_dscritic := vr_dscribas || ' Cooperativa = '||vr_vet_campos(1);
            vr_cdcooper := vr_vet_campos(1);

            -- Validar se a cooperativa informada no arquivo é a correta
            IF (vr_cdcooper <> pr_cdcooper) AND (pr_cdcooper <> 3) THEN
              vr_dscritic := vr_dscritic || ' informada no arquivo está incorreta!';
              vr_flgbloqcarga := 'S';
              RAISE vr_exc_saida;
            END IF;

            -- Validar se cooperativa existe
            OPEN cr_crapcop(vr_cdcooper);
            FETCH cr_crapcop
             INTO rw_crapcop;

            IF cr_crapcop%NOTFOUND THEN
              CLOSE cr_crapcop;
              vr_dscritic := vr_dscritic || ' não encontrada ou inativa!';
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_crapcop;
            END IF;

            -- Descricao da Carga
            vr_dscritic := vr_dscribas || ' Desc. Carga = '||vr_vet_campos(7);

            IF LENGTH(vr_vet_campos(7)) > 100 THEN
              vr_dscritic := vr_dscritic || ' Valor de descricao e maior que o limite de 100 caracteres!';
              RAISE vr_exc_saida;
            END IF;

            vr_dscarga := vr_vet_campos(7);

            IF vr_dscarga IS NULL THEN
              vr_dscritic := vr_dscritic || ' Deve ser informada!';
              -- Erro critico
              RAISE vr_exc_saida;
            END IF;

            -- Mensagem de Aviso Atenda
            vr_dscritic := vr_dscribas || ' Mensa. Atenda = '||vr_vet_campos(8);
            vr_dsmsgavi := vr_vet_campos(8);

            IF vr_dsmsgavi IS NULL THEN
              vr_dscritic := vr_dscritic || ' Deve ser informada!';
              -- Erro critico
              RAISE vr_exc_saida;
            END IF;

            -- Data Vigencia
            vr_dscritic := vr_dscribas || ' Data Final Vigencia = '||vr_vet_campos(9);

            BEGIN
               vr_dtvigenci := TO_DATE(REPLACE(REPLACE(vr_vet_campos(9), CHR(10), ''), CHR(13), ''),'DD/MM/RRRR');
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := vr_dscritic || ' Invalida! Data informada está errada';
                RAISE vr_exc_saida;
            END;

            -- validar se não foi enviado uma data no passado
            IF vr_dtvigenci <= rw_crapcop.dtmvtolt THEN
              vr_dscritic := vr_dscritic || ' invalida! Data da vigência final é anterior à data atual - verifique';
              vr_flgbloqcarga := 'S';
              -- Erro critico
              RAISE vr_exc_saida;
            END IF;

            -- ## Deste ponto para baixo os erros não geram exceção, apenas povoam o registro ## --
            -- Tipo Pessoa
            vr_dscritic := vr_dscribas || ' Tipo Pessoa = '||vr_vet_campos(2);
            vr_tppesoa := NULL;

            IF vr_vet_campos(2) = 'PF' THEN
              vr_tppesoa := 1;
            ELSIF vr_vet_campos(2) = 'PJ' THEN
              vr_tppesoa := 2;
            END IF;

            -- Tratar dominio
            IF vr_tppesoa NOT in(1,2) THEN
              vr_dscrireg := 'Tipo Pessa Invalida! Somente é permitido informar 1 ou 2!'||'<br>';
            END IF;

            -- Linha de Credito
            vr_dscritic := vr_dscribas || ' Linha de Credito = '||vr_vet_campos(4);
            vr_cdlcremp := vr_vet_campos(4);

            -- Buscar informações do pre-aprovado conforme tipo de pessoa
            OPEN cr_crappre(vr_cdcooper,vr_tppesoa);
            FETCH cr_crappre
             INTO rw_crappre;

            IF cr_crappre%NOTFOUND THEN
              CLOSE cr_crappre;

              vr_dscrireg := vr_dscrireg || ' Tipo Pessoa Invalida! Nao encontrado configuracao Pre Aprovado para a Cooperativa e Tipo de Pesssoa!'||'<br>';
            ELSE
              CLOSE cr_crappre;

              -- Validar se data de contratação não passou a quantidade limite de dias parametrizada
              IF vr_dtvigenci > rw_crapcop.dtmvtolt+rw_crappre.qtdiavig THEN
                vr_dscrireg := vr_dscrireg || ' Data Final Invalida! Data ultrapassa limite maximo de dias('||rw_crappre.qtdiavig||').';
              END IF;

              -- Validar existencia da Linha de Credito
              OPEN cr_craplcr(vr_cdcooper,rw_crappre.cdfinemp,vr_cdlcremp);
              FETCH cr_craplcr
               INTO rw_craplcr;

              IF cr_craplcr%NOTFOUND THEN
                CLOSE cr_craplcr;
                vr_dscrireg := vr_dscrireg || 'Linha de Credito Invalida! Nao existe relacionamento com PreAprovado ou a Linha esta bloqueada!'||'<br>';
              ELSE
                CLOSE cr_craplcr;
              END IF;
            END IF;

            -- CPF/CNPJ do Cooperado
            vr_dscritic := vr_dscribas || ' CPF/CNPJ Raiz = '||vr_vet_campos(3);

            IF LENGTH(vr_vet_campos(3)) >= 12 THEN
              vr_nrcpfcnpj := SUBSTR(LPAD(vr_vet_campos(3), 14, '0'), 1, 8);
            ELSE
              vr_nrcpfcnpj := vr_vet_campos(3);
            END IF;

            -- Buscar se cooperado existe
            OPEN cr_crapass_pessoa(vr_cdcooper, vr_nrcpfcnpj, vr_tppesoa);
            FETCH cr_crapass_pessoa INTO vr_nrdconta;
            CLOSE cr_crapass_pessoa;

            -- Se não encontrar vamos indicar que há registros sem conta
            IF vr_nrdconta = 0 OR vr_nrdconta IS NULL  THEN
              vr_dscrireg := vr_dscrireg || 'CPF/CNPJ Raiz Invalido! Nao encontrado Cooperado na Cooperativa!'||'<br>';
            ELSE
              -- Buscar o ultimo Rating do Cooperado
              OPEN cr_crapnrc(vr_cdcooper,vr_nrdconta);
              FETCH cr_crapnrc
               INTO vr_cdrating
                   ,vr_dtrating;
              CLOSE cr_crapnrc;
            END IF;

            -- Potencial Parcela
            vr_dscritic := vr_dscribas || ' Pot. Max. Parcela = '||vr_vet_campos(5);
            vr_vlpotpar := vr_vet_campos(5);

            IF vr_vlpotpar IS NULL THEN
              vr_dscrireg := vr_dscrireg || 'Potencial Parcela Invalido! Nao existe relacionamento com PreAprovado ou a Linha esta bloqueada!'||'<br>';
            END IF;

            -- Potencial Limite
            vr_dscritic := vr_dscribas || ' Pot. Max. Limite = '||vr_vet_campos(6);
            vr_vlpotlim := vr_vet_campos(6);

            IF vr_vlpotlim IS NULL THEN
              vr_dscrireg := vr_dscrireg || 'Potencial Limite Invalido! Nao existe relacionamento com PreAprovado ou a Linha esta bloqueada!'||'<br>';
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              -- propagar
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              -- incrementar o erro e propagar
              vr_dscritic := vr_dscribas || ' indefinido -> Erro --> '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Checar se a carga já existe no vetor
          vr_idx_hash_cargas := to_char(vr_cdcooper,'fm00000')
                             || to_char(vr_dtvigenci,'ddmmyyyy')
                             || rpad(vr_dscarga,100,' ')
                             || rpad(vr_dsmsgavi,887,' ');

          IF NOT vr_tab_hash_cargas.exists(vr_idx_hash_cargas) THEN
            -- Criaremos o mesmo (o indice no vetor principal é pelas linhas)
            vr_tab_hash_cargas(vr_idx_hash_cargas) := vr_nrcontad;
            vr_idx_carga := vr_nrcontad;
            vr_tab_carga(vr_idx_carga).cdcooper  := vr_cdcooper;
            vr_tab_carga(vr_idx_carga).dscarga   := vr_dscarga;
            vr_tab_carga(vr_idx_carga).dsmsgavi  := vr_dsmsgavi;
            vr_tab_carga(vr_idx_carga).dtvigenci := vr_dtvigenci;
            vr_tab_carga(vr_idx_carga).vlpotpar  := 0;
            vr_tab_carga(vr_idx_carga).vlpotlim  := 0;
            vr_tab_carga(vr_idx_carga).vlpotlimtot  := 0;
            vr_tab_carga(vr_idx_carga).qtregipf  := 0;
            vr_tab_carga(vr_idx_carga).qtregipj  := 0;
            vr_tab_carga(vr_idx_carga).qtderros  := 0;
          END IF;

          -- Criar o Hash unico de cooperado também
          vr_idx_hase_cooperad := vr_tppesoa || lpad(vr_nrcpfcnpj,12,'0');

          -- Se o cooperado já está no vetor
          IF vr_tab_hash_cooperad.exists(vr_idx_hase_cooperad) THEN
            -- Incrementar a critica com o erro de que o Cooperado não pode repetir no arquivo
            vr_dscrireg := vr_dscrireg || 'CPF/CNPJ Raiz Invalido ja presente na linha ('||vr_tab_hash_cooperad(vr_idx_hase_cooperad)||') no arquivo!'||'<br>';
          ELSE
            -- Adicionaremos o mesmo
            vr_tab_hash_cooperad(vr_idx_hase_cooperad) := vr_nrcontad;
          END IF;

          -- Adicionar ao vetor os valores deste cooperado e a flag se há erro
          IF vr_tab_carga(vr_idx_carga).vlpotpar < vr_vlpotpar THEN
             vr_tab_carga(vr_idx_carga).vlpotpar := vr_vlpotpar;
          END IF;

          IF vr_tppesoa = 1 THEN
            vr_tab_carga(vr_idx_carga).qtregipf := vr_tab_carga(vr_idx_carga).qtregipf + 1;
          ELSE
            vr_tab_carga(vr_idx_carga).qtregipj := vr_tab_carga(vr_idx_carga).qtregipj + 1;
          END IF;

          -- Se há erro
          IF vr_dscrireg IS NOT NULL THEN
            vr_tab_carga(vr_idx_carga).qtderros := vr_tab_carga(vr_idx_carga).qtderros + 1;
            -- Setar a flag de erro
            vr_fltemerr := 'S';
          END IF;

          -- Garantir que o valor não ultrapasse o máximo permitido para cargas manuais
          IF NVL(rw_crappre.vllimman, 0) < vr_vlpotlim THEN
            vr_vlpotlim := NVL(rw_crappre.vllimman, 0);
          END IF;

          vr_tab_carga(vr_idx_carga).vlpotlimtot := vr_tab_carga(vr_idx_carga).vlpotlimtot + nvl(vr_vlpotlim,0);

          IF vr_tab_carga(vr_idx_carga).vlpotlim < vr_vlpotlim THEN
             vr_tab_carga(vr_idx_carga).vlpotlim := vr_vlpotlim;
          END IF;

          -- Enviar enviaremos ao vetor
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).tppesoa   := vr_tppesoa;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).nrcpfcnpj := vr_nrcpfcnpj;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).cdlcremp  := vr_cdlcremp;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).vlpotpar  := vr_vlpotpar;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).vlpotlim  := vr_vlpotlim;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).cdrating  := vr_cdrating;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).dtrating  := vr_dtrating;
          vr_tab_carga(vr_idx_carga).tabcooper(vr_nrcontad).dscrireg  := '<![CDATA[' || vr_dscrireg || ']]>';
        EXCEPTION
          WHEN no_data_found THEN
            -- final do arquivo
            EXIT;
          WHEN vr_exc_saida THEN
            RAISE vr_cargaerr;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' --> '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP; /* END LOOP */

      -- Controle para proteger a rotina de temporary table vazia
      IF vr_tab_carga.count = 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Conforme o tipo de execução
      IF pr_tpexecuc = 'L' THEN
         -- Caso foi solicitado o processo definitivo, mas há erros
        IF vr_fltemerr = 'S' THEN
          vr_dscritic := 'Arquivo com erros, nao e possivel liberar o Pre Aprovado!';
          RAISE vr_exc_saida;
        ELSE
          -- Efetuar laço sob cada carga encontrada
          FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
            IF vr_tab_carga.exists(vr_idx1) THEN
              -- Criar registro de carga
              BEGIN
                INSERT INTO tbepr_carga_pre_aprv(cdcooper
                                                ,dtcalculo
                                                ,tpcarga
                                                ,dscarga
                                                ,dtliberacao
                                                ,dtfinal_vigencia
                                                ,dsmensagem_aviso
                                                ,indsituacao_carga
                                                ,flgcarga_bloqueada
                                                ,skcarga_sas
                                                ,qtcarga_pf
                                                ,qtcarga_pj
                                                ,vllimite_total
                                                ,cdoperad_libera)
                                          VALUES(vr_tab_carga(vr_idx1).cdcooper
                                                ,rw_crapcop.dtmvtolt
                                                ,1 -- Manual
                                                ,vr_tab_carga(vr_idx1).dscarga
                                                ,rw_crapdat.dtmvtolt
                                                ,vr_tab_carga(vr_idx1).dtvigenci
                                                ,vr_tab_carga(vr_idx1).dsmsgavi
                                                ,1 -- Liberada
                                                ,0 -- Não bloqueada
                                                ,0 -- Não há skcarga_sas
                                                ,vr_tab_carga(vr_idx1).qtregipf
                                                ,vr_tab_carga(vr_idx1).qtregipj
                                                ,vr_tab_carga(vr_idx1).vlpotlim
                                                ,pr_cdoperad)
                                        RETURNING idcarga
                                             INTO vr_idcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na criacao da Carga, linha '||vr_idx1||' --> '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Enviar os cooperados da carga
              vr_idx2 := vr_tab_carga(vr_idx1).tabcooper.first;

              WHILE vr_idx2 IS NOT NULL LOOP
                IF vr_tab_carga(vr_idx1).tabcooper.exists(vr_idx2) THEN
                  -- Gravar os Cooperados da Carga
                  DECLARE
                    vr_vlcalpar crapcpa.vlcalpar%TYPE;
                    vr_vlcalpre crapcpa.vlcalpre%TYPE;

                  BEGIN
                    -- Inserir a carga
                    INSERT INTO crapcpa (cdcooper
                                        ,nrdconta
                                        ,dtmvtolt
                                        ,iddcarga
                                        ,tppessoa
                                        ,nrcpfcnpj_base
                                        ,cdlcremp
                                        ,vlpot_parc_maximo
                                        ,vlpot_lim_max
                                        ,cdrating
                                        ,dtcalc_rating
                                         ,cdsituacao
                                        ,vlcalpar
                                        ,vlcalpre)
                                 VALUES (vr_tab_carga(vr_idx1).cdcooper
                                        ,0 -- Novo projeto não tem conta
                                        ,rw_crapcop.dtmvtolt
                                        ,vr_idcarga
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).tppesoa
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).cdlcremp
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotpar
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotlim
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).cdrating
                                        ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).dtrating
                                        ,'B'
                                        ,0
                                        ,0);

                    -- Calcular o pre-aprovado no momento da liberação
                    pc_calc_pre_aprovado_sintetico(pr_cdcooper        => vr_tab_carga(vr_idx1).cdcooper
                                                  ,pr_idcarga         => vr_idcarga
                                                  ,pr_tppessoa        => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).tppesoa
                                                  ,pr_nrcpf_cnpj_base => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj
                                                  ,pr_vlparcel        => vr_vlcalpar
                                                  ,pr_vldispon        => vr_vlcalpre
                                                  ,pr_dscritic        => vr_dscritic);

                    -- Se houve erro
                    IF vr_dscritic IS NOT NULL THEN
                      RAISE vr_exc_saida;
                    END IF;

                    -- Atualizar valores de cálculo pós-carga
                    UPDATE crapcpa
                       SET vlcalpar = vr_vlcalpar
                          ,vlcalpre = vr_vlcalpre
                     WHERE iddcarga       = vr_idcarga
                       AND cdcooper       = vr_tab_carga(vr_idx1).cdcooper
                       AND nrcpfcnpj_base = vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj
                       AND tppessoa       = vr_tab_carga(vr_idx1).tabcooper(vr_idx2).tppesoa;

                    -- P450 - inicio
                    -- Na segunda entrega do pre-aprovado a pc_grava_rating_operacao
                    -- deverá ser colocada aqui e passar zero para o número da conta.
                    -- Atualmente está dentro do próximo laço para não dar erro de chave
                    -- na tabela tbrisco_operacoes

                    -- P450
                    -- Na segunda etapa do pré-aprovado deverá retirar daqui a gravação do rating
                    -- Gravar o rating

                    -- Testar existencia de associado com o CPF/CNPJ Base
                    vr_nrdconta := NULL;
                    OPEN cr_crapass(vr_tab_carga(vr_idx1).cdcooper
                                   ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).tppesoa
                                   ,vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj);
                    FETCH cr_crapass INTO vr_nrdconta;
                    CLOSE cr_crapass;

                    -- Buscar o status do rating pré-aprovado
                    rati0003.pc_busca_status_rating(pr_cdcooper  => vr_tab_carga(vr_idx1).cdcooper
                                                   ,pr_nrdconta  => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj
                                                   ,pr_tpctrato  => 68
                                                   ,pr_nrctrato  => 0
                                                   ,pr_strating  => vr_insituacao_rating 
                                                   ,pr_flgrating => vr_flgrating
                                                   ,pr_cdcritic  => vr_cdcritic 
                                                   ,pr_dscritic  => vr_dscritic);

                    -- So irá gravar Rating caso o limite pré-aprovado esteja invalido
                    -- Diferente de Analisado ou Efetivo
                    IF nvl(vr_flgrating,0) = 0 THEN  -- Rating nao valido
                      IF rati0003.fn_retorna_modelo_rating(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper) = 2 THEN -- Modelo Ibratan
                      rati0003.pc_grava_rating_operacao(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                                       ,pr_nrdconta => vr_nrdconta
                                                       ,pr_tpctrato => 68
                                                       ,pr_nrctrato => 0
                                                       ,pr_strating => 3 
                                                       ,pr_orrating => 1
                                                       ,pr_cdoprrat => pr_cdoperad
                                                       ,pr_nrcpfcnpj_base => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj
                                                       ,pr_cdoperad       => pr_cdoperad 
                                                       ,pr_dtmvtolt       => rw_crapcop.dtmvtolt
                                                       ,pr_justificativa  => 'Carga manual do limite' 
                                                       ,pr_tpoperacao_rating => 68 
                                                       ,pr_cdcritic        => vr_cdcritic
                                                       ,pr_dscritic        => vr_dscritic);
                       -- Não criticar garvação do rating
                      ELSIF rati0003.fn_retorna_modelo_rating(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper) = 1 THEN -- Modelo Aimaro, gravar em modo contingência
                        rati0003.pc_busca_rat_contigencia(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                                                         pr_nrcpfcgc => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj, --> CPFCNPJ BASE
                                                         pr_innivris => vr_innivris,                         --> risco contingencia
                                                         pr_cdcritic => vr_cdcritic,
                                                         pr_dscritic => vr_dscritic);
                        -- grava o rating contingencia
                        RATI0003.pc_grava_rating_operacao(pr_cdcooper       => vr_tab_carga(vr_idx1).cdcooper  --> Código da Cooperativa
                                                         ,pr_nrdconta       => vr_nrdconta  --> Conta do associado
                                                         ,pr_tpctrato       => 68  --> Tipo do contrato de rating
                                                         ,pr_nrctrato       => 0  --> Número do contrato do rating
                                                         ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                                         ,pr_dtrataut       => rw_crapcop.dtmvtolt --> Data do Rating retornado do MOTOR
                                                         ,pr_strating       => 3   --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                                         ,pr_orrating       => 4   --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                                         ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                                         ,pr_nrcpfcnpj_base => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj --> Numero do CPF/CNPJ Base do associado
                                                         ,pr_cdoperad       => '1'
                                                         ,pr_dtmvtolt       => rw_crapcop.dtmvtolt
                                                         ,pr_cdcritic       => vr_cdcritic
                                                         ,pr_dscritic       => vr_dscritic);            
                      END IF;     
                    END IF;
                     -- P450
                    
                    -- Gerar LOG
                    gene0001.pc_gera_log(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => ''
                                        ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                                        ,pr_dstransa => 'Liberacao de PreAprovado via Carga de Manual de Arquivo'
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1 --> TRUE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => 0
                                        ,pr_nmdatela => pr_cdprogra
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => 'Liberado');
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Linha de Credito'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => vr_tab_carga(vr_idx1).tabcooper(vr_idx2).cdlcremp);
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Potencial Parc. Maximo.'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotpar,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Potencial Limite Maximo.'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotlim,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Parc. Calculada'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_vlcalpar,'fm999g999g999g999d00'));
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'PreAprovado Calculado'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => to_char(vr_vlcalpre,'fm999g999g999g999d00'));
                  EXCEPTION
                    WHEN vr_exc_saida THEN
                      RAISE vr_exc_saida;
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro na criacao do Cooperado na Carga, linha '||vr_idx1||' --> '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;

                vr_idx2 := vr_tab_carga(vr_idx1).tabcooper.next(vr_idx2);
              END LOOP;
            END IF;
          END LOOP;
        END IF;
      ELSE
        -- Montar a mensagem conforme tenha havido erro ou não
        IF vr_fltemerr = 'S' THEN
          vr_dsmensag := 'Arquivo com erros, favor verifica-los e solicitar o processamento novamente!';
        ELSE
          vr_dsmensag := 'Arquivo lido com sucesso, verifique o sumario das cargas e conclua o processo clicando em ''Liberar'' ';
        END IF;

        -- Em caso de simulação, vamos devolver um XML para o AimaroWeb
        gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                               ,pr_texto_completo => vr_txtclob
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>'
                                                  || '<Dados flgerro="'||vr_fltemerr||'" flgbloqcarga="'||vr_flgbloqcarga||'" mensagem="'||vr_dsmensag||'"><cargas>');

        -- Efetuar laço sob cada carga encontrada
        FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
          IF vr_tab_carga.exists(vr_idx1) THEN
             -- Criar registro de carga
             gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                                    ,pr_texto_completo => vr_txtclob
                                    ,pr_texto_novo     => '<carga>'
                                                       || '  <idlinha>'||vr_idx1||'</idlinha>'
                                                       || '  <cdcooper>'||vr_tab_carga(vr_idx1).cdcooper||'</cdcooper>'
                                                       || '  <dtvigen>'||to_char(vr_tab_carga(vr_idx1).dtvigenci,'dd/mm/rrrr')||'</dtvigen>'
                                                       || '  <dscarga><![CDATA['||gene0007.fn_acento_xml(vr_tab_carga(vr_idx1).dscarga)||']]></dscarga>'
                                                       || '  <dsatenda><![CDATA['||gene0007.fn_acento_xml(vr_tab_carga(vr_idx1).dsmsgavi)||']]></dsatenda>'
                                                       || '  <vlpotpar>'||to_char(vr_tab_carga(vr_idx1).vlpotpar,'fm999g999g999g990d00')||'</vlpotpar>'
                                                       || '  <vlpotlim>'||to_char(vr_tab_carga(vr_idx1).vlpotlim,'fm999g999g999g990d00')||'</vlpotlim>'
                                                       || '  <vlpotlimtot>'||to_char(vr_tab_carga(vr_idx1).vlpotlimtot,'fm999g999g999g990d00')||'</vlpotlimtot>'
                                                       || '  <qtderros>'||to_char(vr_tab_carga(vr_idx1).qtderros,'fm999g999g999g990')||'</qtderros>'
                                                       || '  <qtregipf>'||vr_tab_carga(vr_idx1).qtregipf||'</qtregipf>'
                                                       || '  <qtregipj>'||vr_tab_carga(vr_idx1).qtregipj||'</qtregipj>'
                                                       || '  <qtdregistros>'||to_char(vr_tab_carga(vr_idx1).qtregipj+vr_tab_carga(vr_idx1).qtregipf,'fm999g999g999g990')||'</qtdregistros>'
                                                       || '  <cooperados>');

            -- Enviar os cooperados da carga
            vr_idx2 := vr_tab_carga(vr_idx1).tabcooper.first;

            WHILE vr_idx2 IS NOT NULL LOOP
              IF vr_tab_carga(vr_idx1).tabcooper.exists(vr_idx2) THEN
                gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                                       ,pr_texto_completo => vr_txtclob
                                       ,pr_texto_novo     => '<cooperado>'
                                                          || '  <idlinha>'||vr_idx2||'</idlinha> '
                                                          || '  <tppessoa>'||vr_tab_carga(vr_idx1).tabcooper(vr_idx2).tppesoa||'</tppessoa> '
                                                          || '  <nrcpfcnpj>'||vr_tab_carga(vr_idx1).tabcooper(vr_idx2).nrcpfcnpj||'</nrcpfcnpj> '
                                                          || '  <cdlcremp>'||vr_tab_carga(vr_idx1).tabcooper(vr_idx2).cdlcremp||'</cdlcremp> '
                                                          || '  <vlpotpar>'||to_char(vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotpar,'fm999g999g999g990d00')||'</vlpotpar> '
                                                          || '  <vlpotlim>'||to_char(vr_tab_carga(vr_idx1).tabcooper(vr_idx2).vlpotlim,'fm999g999g999g990d00')||'</vlpotlim> '
                                                          || '  <dscritic>'||vr_tab_carga(vr_idx1).tabcooper(vr_idx2).dscrireg||'</dscritic> '
                                                          || '</cooperado>');
              END IF;

        vr_idx2 := vr_tab_carga(vr_idx1).tabcooper.next(vr_idx2);
            END LOOP;

            -- Finalizar node carga
            gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                                 ,pr_texto_completo => vr_txtclob
                                 ,pr_texto_novo     => '</cooperados></carga>');
          END IF;
        END LOOP;

        -- Finalizar o XML e devolve-lo
        gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                               ,pr_texto_completo => vr_txtclob
                               ,pr_texto_novo     => '</cargas></Dados></Root>'
                               ,pr_fecha_xml      => TRUE);
      END IF;

      -- Gerar LOG no Batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2
                                ,pr_nmarqlog      => pr_cdprogra
                                ,pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - '||pr_cdprogra||' --> '
                                                  || ' Cooperativa:'||pr_cdcooper
                                                  || ',Operador '||pr_cdoperad
                                                  || ' efetuou a Carga de '||vr_nrcontad||' Cooperados via Carga Manual de PreAprovado.');

      -- Efetuar a gravação
      COMMIT;
    EXCEPTION
      WHEN vr_cargaerr THEN
        ROLLBACK;
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_saida THEN
        ROLLBACK;

        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_dscritic := 'Erro tratado. Rotina pc_carga_manual_via_arquivo. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro nao tratado. Rotina pc_carga_manual_via_arquivo. Detalhes: '||SQLERRM;
    END;
  END pc_carga_manual_via_arquivo;

  -- Processo de carga de exclusao via arquivo enviado
  PROCEDURE pc_carga_exclus_via_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Operador
                                       ,pr_idorigem IN NUMBER                 -- Origem da requisição
                                       ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Programa chamador
                                       ,pr_tpexecuc IN VARCHAR2               -- Tipo da Execução (Simulação ou Importação)
                                       ,pr_dsdireto IN VARCHAR2               -- Diretorio do arquivo
                                       ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                       ,pr_xmldados IN OUT NOCOPY CLOB        -- Saida de informações
                                       ,pr_dscritic OUT VARCHAR2              -- Saida de erro do processo
                                       ) IS
    /* .............................................................................

     Programa: pc_carga_exclus_via_arquivo
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Receber um arquivo com informações de carga de pre-aprovado,
                 efetuar leitura linha a linha e integrar as informações ao
                 produto Pré_aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Variaveis para interface SO
      vr_typ_said    VARCHAR2(50);  -- Critica
      vr_des_erro    VARCHAR2(500); -- Critica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(32700);
      vr_nrdrowid ROWID;
      vr_err_arq   EXCEPTION;

      -- Manipulação de arquivos
      vr_dsdireto   VARCHAR2(1000);
      vr_nrcontad   PLS_INTEGER := 0;                 -- Contador de registros
      vr_input_file UTL_FILE.FILE_TYPE;               -- Handle para leitura de arquivo
      vr_setlinha   VARCHAR2(4000);                   -- Texto do arquivo lido
      vr_vet_campos gene0002.typ_split;               -- Array de arquivos
      vr_dscribas   VARCHAR2(32700);                   -- Critica basica

      -- Campos da linha
      vr_cdcooper  crapcpa.cdcooper%TYPE;
      vr_tppesoa   crapcpa.tppessoa%TYPE;
      vr_nrcpfcnpj NUMBER(14);
      vr_iddcarga  crapcpa.iddcarga%TYPE;
      vr_dscrireg  VARCHAR2(32700);
      vr_cpfcnpj   VARCHAR2(20);

      -- Dados para o XML
      vr_txtclob VARCHAR2(32767);
      vr_fltemerr VARCHAR2(1);      -- Se há erro
      vr_dsmensag VARCHAR2(4000);   -- Mensagem para ser retornada a tela

      -- Vetores para armazenar as chaves de Carga e Cooperado e evitar duplicidade
      TYPE typ_reg_hash_busca IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(1000);
      vr_tab_hash_cooperad typ_reg_hash_busca;
      vr_idx_hase_cooperad VARCHAR2(1000);

      -- Vetor de cooperados da Carga (Detalhe)
      TYPE typ_reg_cooperad IS RECORD(cdcooper  crapcop.cdcooper%TYPE
                                     ,tppesoa   crapcpa.tppessoa%TYPE
                                     ,nrcpfcnpj crapcpa.nrcpfcnpj_base%TYPE
                                     ,cdlcremp  crapcpa.cdlcremp%TYPE
                                     ,iddcarga  crapcpa.iddcarga%TYPE
                                     ,dscrireg  VARCHAR2(4000));
      TYPE typ_tab_cooperad IS TABLE OF typ_reg_cooperad INDEX BY PLS_INTEGER; -- Tipo(1) || NrCpfCnpjBase(12)
      vr_tab_cooperad typ_tab_cooperad;

      -- Chacagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Chacagem de existencia do Cooperado por documento e tipo de pessoa
      CURSOR cr_crapass_pes(pr_cdcooper  crapcop.cdcooper%TYPE
                           ,pr_nrcpfcnpj crapass.nrcpfcnpj_base%TYPE
                           ,pr_inpessoa  crapass.inpessoa%TYPE) IS
        SELECT ass.nrdconta
        FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrcpfcnpj_base = pr_nrcpfcnpj
          AND ass.inpessoa = pr_inpessoa;
      vr_nrdconta crapass.nrdconta%TYPE;

      -- Chacagem de existencia do Cooperado
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrcpfcnpj crapass.nrcpfcnpj_base%TYPE) IS
        SELECT ass.nrdconta
        FROM crapass ass
        WHERE ass.cdcooper = pr_cdcooper
          AND ass.nrcpfcnpj_base = pr_nrcpfcnpj;

    BEGIN
      -- Busca o diretório do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'upload');

      -- Realizar a cópia do arquivo do AyllosWeb para a pasta upload
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||pr_dsdireto||pr_nmarquiv||' S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);

       -- Testar erro
      IF vr_typ_said = 'ERR' OR vr_typ_said = 'OUT' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_dscritic := 'Erro no recebimento do arquivo, não será possível processar. Detalhes: ' || vr_des_erro;
        RAISE vr_err_arq;
      END IF;

      -- Com o arquivo recebido, iremos transformá-lo em tabela de memória para facilidade de manutenção posterior dos dados
      GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_dsdireto||'/'||pr_nmarquiv
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_input_file
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se houve erros na abertura do arquivo
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao abrir o arquivo para exclusao: '||vr_dsdireto||pr_nmarquiv;
        RAISE vr_err_arq;
      END IF;

      -- Laco para leitura de linhas do arquivo
      LOOP
        BEGIN
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Incrementar quantidade linhas
          vr_nrcontad := vr_nrcontad + 1;

          -- HEADER
          IF vr_nrcontad = 1 THEN
            CONTINUE;
          END IF;

          -- Remover possiveis " no começo e final
          vr_setlinha := rtrim(ltrim(vr_setlinha,'"'),'"');

          -- Separar os campos da linha em um vetor
          vr_vet_campos := gene0002.fn_quebra_string(vr_setlinha,';');

          -- Caso a linha não tenha 9 posições, iremos criticar o arquivo inteiro
          IF vr_vet_campos.count() <> 3 THEN
            vr_dscritic := 'Erro geral na leitura do arquivo! Linha '||vr_nrcontad||' nao possui 3 colunas!';
            RAISE vr_err_arq;
          END IF;

          -- LImpar variaveis temp
          vr_cdcooper  := NULL;
          vr_tppesoa   := NULL;
          vr_nrcpfcnpj := NULL;
          vr_dscrireg  := NULL;
          vr_nrdconta  := NULL;

          -- Bloco para facilitar tratamento de erros
          BEGIN
            -- Montar inicio de mensagem de erro padrão
            -- vr_dscribas := 'Erro na leitura da linha '||vr_nrcontad||' campo ';
            -- Cooperativa
            vr_dscritic := vr_dscribas || ' Cooperativa = '||vr_vet_campos(1);
            vr_cdcooper := vr_vet_campos(1);

            -- Validar se a cooperativa informada no arquivo é a correta
            IF (vr_cdcooper <> pr_cdcooper) AND (pr_cdcooper <> 3) THEN
              vr_dscritic := vr_dscritic || ' informada no arquivo está incorreta!';
              RAISE vr_err_arq;
            END IF;

            -- Validar se cooperativa existe
            OPEN cr_crapcop(vr_cdcooper);
            FETCH cr_crapcop INTO rw_crapcop;

            IF cr_crapcop%NOTFOUND THEN
              CLOSE cr_crapcop;
              vr_dscritic := vr_dscritic || ' não encontrada ou inativa!';
              RAISE vr_err_arq;
            ELSE
              CLOSE cr_crapcop;
            END IF;

            -- ## Deste ponto para baixo os erros não geram exceção, apenas povoam o registro ## --
            -- Tipo Pessoa
            vr_dscritic := vr_dscribas || ' Tipo Pessoa = '||vr_vet_campos(2);

            IF vr_vet_campos(2) = 'PF' THEN
              vr_tppesoa := 1;
            ELSIF vr_vet_campos(2) = 'PJ' THEN
              vr_tppesoa := 2;
            END IF;

            -- Tratar dominio
            IF vr_tppesoa NOT in(1,2) THEN
              vr_dscrireg := 'Tipo Pessoa Invalida! Somente é permitido informar 1 ou 2!'||'<br>';
            END IF;

            vr_cpfcnpj := REPLACE(REPLACE(vr_vet_campos(3), CHR(10), ''), CHR(13), '');

            -- CPF/CNPJ do Cooperado
            vr_dscritic := vr_dscribas || ' CPF/CNPJ Raiz = '||vr_cpfcnpj;

            IF LENGTH(vr_cpfcnpj) >= 12 THEN
              vr_nrcpfcnpj := SUBSTR(LPAD(vr_cpfcnpj, 14, '0'), 1, 8);
            ELSE
              vr_nrcpfcnpj := vr_cpfcnpj;
            END IF;

            -- Buscar se cooperado existe
            OPEN cr_crapass_pes(vr_cdcooper,vr_nrcpfcnpj, vr_tppesoa);
            FETCH cr_crapass_pes INTO vr_nrdconta;
            CLOSE cr_crapass_pes;

            -- Se não encontrar vamos indicar que há registros sem conta
            IF vr_nrdconta IS NULL THEN
              vr_dscrireg := vr_dscrireg  || 'CPF/CNPJ Raiz Invalido! Nao encontrado Cooperado na Cooperativa!'||'<br>';
            END IF;

            -- Buscar a carga ativa
            vr_iddcarga := fn_idcarga_pre_aprovado(pr_cdcooper        => vr_cdcooper
                                                  ,pr_tppessoa        => vr_tppesoa
                                                  ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj);

            -- Testar se o cooperado está em alguma carga ativa
            IF vr_iddcarga = 0 or vr_iddcarga is null THEN
              vr_dscrireg := vr_dscrireg  || 'CPF/CNPJ Raiz sem Pre Aprovado - Nao e possivel efetuar exclusao!' ||'<br>';
            END IF;
          EXCEPTION
            WHEN vr_err_arq THEN
              RAISE vr_err_arq;
            WHEN vr_exc_saida THEN
              -- propagar
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              -- incrementar o erro e propagar
              vr_dscritic := vr_dscribas || ' indefinido -> Erro --> '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Criar o Hash unico de cooperado
          vr_idx_hase_cooperad := vr_tppesoa || lpad(vr_nrcpfcnpj,12,'0');

          -- Se o cooperado já está no vetor
          IF vr_tab_hash_cooperad.exists(vr_idx_hase_cooperad) THEN
            -- Incrementar a critica com o erro de que o Cooperado não pode repetir no arquivo
            vr_dscrireg := vr_dscrireg || 'CPF/CNPJ Raiz Invalido ja presente na linha ('||vr_tab_hash_cooperad(vr_idx_hase_cooperad)||')'||'<br>';
          ELSE
            -- Adicionaremos o mesmo
            vr_tab_hash_cooperad(vr_idx_hase_cooperad) := vr_nrcontad;
          END IF;

          -- Enviar enviaremos ao vetor de Cooperados o mesmo
          vr_tab_cooperad(vr_nrcontad).cdcooper  := vr_cdcooper;
          vr_tab_cooperad(vr_nrcontad).tppesoa   := vr_tppesoa;
          vr_tab_cooperad(vr_nrcontad).nrcpfcnpj := vr_nrcpfcnpj;
          vr_tab_cooperad(vr_nrcontad).iddcarga  := vr_iddcarga;
          vr_tab_cooperad(vr_nrcontad).dscrireg  := vr_dscrireg;
        EXCEPTION
          WHEN vr_err_arq THEN
            RAISE vr_err_arq;
          WHEN no_data_found THEN
            EXIT;
          WHEN vr_exc_saida THEN
            EXIT;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' --> '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP; /* END LOOP */

      -- Conforme o tipo de execução
      IF pr_tpexecuc = 'S' THEN
        -- Montar a mensagem conforme tenha havido erro ou não
        IF vr_fltemerr = 'S' OR vr_dscrireg IS NOT NULL THEN
          vr_dsmensag := 'Arquivo com erros, favor verifica-los e solicitar o processamento novamente!';
        ELSE
          vr_dsmensag := 'Arquivo lido com sucesso, conclua o processo clicando em ''Liberar'' ';
        END IF;
        -- Em caso de simulação, vamos devolver um XML para o AimaroWeb
        gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                               ,pr_texto_completo => vr_txtclob
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>'
                                                  || '<Dados flgerro="'||vr_fltemerr||'" mensagem="'||vr_dsmensag||'"><cooperados>');
        -- Enviar os cooperados da carga
        FOR vr_idx2 IN vr_tab_cooperad.first .. vr_tab_cooperad.last LOOP
          IF vr_tab_cooperad.exists(vr_idx2) THEN
            gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                                   ,pr_texto_completo => vr_txtclob
                                   ,pr_texto_novo     => '<cooperado>'
                                                      || '  <idlinha>'||vr_idx2||'</idlinha> '
                                                      || '  <cdcooper>'||vr_tab_cooperad(vr_idx2).cdcooper||'</cdcooper>'
                                                      || '  <tppessoa>'||vr_tab_cooperad(vr_idx2).tppesoa||'</tppessoa> '
                                                      || '  <nrcpfcnpj>'||vr_tab_cooperad(vr_idx2).nrcpfcnpj||'</nrcpfcnpj> '
                                                      || '  <dscritic>'||'<![CDATA[' ||vr_tab_cooperad(vr_idx2).dscrireg|| ']]>'||'</dscritic> '
                                                      || '</cooperado>');
          END IF;
        END LOOP;

        -- Finalizar o XML e devolve-lo
        gene0002.pc_escreve_xml(pr_xml            => pr_xmldados
                               ,pr_texto_completo => vr_txtclob
                               ,pr_texto_novo     => '</cooperados></Dados></Root>'
                               ,pr_fecha_xml      => TRUE);
      ELSE
        -- Caso foi solicitado o processo definitivo, mas há erros
        IF vr_fltemerr = 'S' THEN
          vr_dscritic := 'Arquivo com erros, nao e possivel efetuar a exclusao do Pre Aprovado!';
          RAISE vr_exc_saida;
        ELSE
          -- Iremos iterar sob cada registro para então proceder com seu bloqueio
          FOR vr_idx2 IN vr_tab_cooperad.first .. vr_tab_cooperad.last LOOP
            IF vr_tab_cooperad.exists(vr_idx2) and
               (vr_tab_cooperad(vr_idx2).iddcarga <> 0 and
               vr_tab_cooperad(vr_idx2).iddcarga is not null ) THEN

              -- Atualizar a carga do Cooperado para Rejeitada
              BEGIN
                UPDATE crapcpa cpa
                   SET cpa.cdoperad_bloque = pr_cdoperad
                      ,cpa.dtbloqueio      = rw_crapcop.dtmvtolt
                      ,cpa.cdsituacao      = 'R' -- Rejeitada
                      ,cpa.dscritica       = 'Rejeitado por importação de arquivo de exclusão.'
                 WHERE cpa.cdcooper = vr_tab_cooperad(vr_idx2).cdcooper
                   AND cpa.tppessoa = vr_tab_cooperad(vr_idx2).tppesoa
                   AND cpa.nrcpfcnpj_base = vr_tab_cooperad(vr_idx2).nrcpfcnpj
                   AND cpa.iddcarga       = vr_tab_cooperad(vr_idx2).iddcarga;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Nao foi possivel eliminar o Cooperado linha '||vr_idx2||' da Carga, erro --> '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Criar o registro de Motivo Nao Aprv
              BEGIN
                INSERT INTO tbepr_motivo_nao_aprv(cdcooper
                                                 ,nrdconta
                                                 ,idcarga
                                                 ,idmotivo
                                                 ,dsvalor
                                                 ,tppessoa
                                                 ,nrcpfcnpj_base
                                                 ,dtbloqueio)
                                           VALUES(vr_tab_cooperad(vr_idx2).cdcooper
                                                 ,0
                                                 ,vr_tab_cooperad(vr_idx2).iddcarga
                                                 ,69 -- 'Eliminado via carga manual.'
                                                 ,'Operador '||pr_cdoperad
                                                 ,vr_tab_cooperad(vr_idx2).tppesoa
                                                 ,vr_tab_cooperad(vr_idx2).nrcpfcnpj
                                                 ,trunc(SYSDATE));
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Nao foi possivel inserir Motivo Nao Aprv linha '||vr_idx2||' da Carga, erro --> '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Buscar todas as Contas do Cooperado via CPF/CNPJ
              FOR rw_crapass IN cr_crapass(vr_tab_cooperad(vr_idx2).cdcooper,vr_tab_cooperad(vr_idx2).nrcpfcnpj) LOOP
                -- Gerar LOG
                gene0001.pc_gera_log(pr_cdcooper => vr_tab_cooperad(vr_idx2).cdcooper
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_dscritic => ''
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                                    ,pr_dstransa => 'Eliminacao de PreAprovado via Carga de Arquivo'
                                    ,pr_dttransa => TRUNC(SYSDATE)
                                    ,pr_flgtrans => 1 --> TRUE
                                    ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                    ,pr_idseqttl => 0
                                    ,pr_nmdatela => pr_cdprogra
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);

                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => 'Bloqueado');

                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Motivo do bloqueio do pre-aprovado.'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => fn_busca_motivo(69));
              END LOOP;
            END IF;
          END LOOP;
        END IF;
      END IF;

      -- Gerar LOG no Batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2
                                ,pr_nmarqlog      => pr_cdprogra
                                ,pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - '||pr_cdprogra||' --> '
                                                  || ' Cooperativa:'||pr_cdcooper
                                                  || ',Operador '||pr_cdoperad
                                                  || ' efetuou a exclusao de '||vr_nrcontad||' Cooperados do PreAprovado.');

      -- Gravação
      COMMIT;
    EXCEPTION
      WHEN vr_err_arq THEN
        ROLLBACK;

        pr_dscritic := vr_dscritic;
      WHEN vr_exc_saida THEN
        ROLLBACK;

        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := 'Erro tratado. Rotina pc_carga_exclus_via_arquivo. Detalhes: '||vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_dscritic := 'Erro nao tratado. Rotina pc_carga_exclus_via_arquivo. Detalhes: '||SQLERRM;
    END;
  END pc_carga_exclus_via_arquivo;

  -- Efetuar checagem do Rating do PreAprovado oriundo do SAS
  PROCEDURE pc_verifica_rating_sas(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  ,pr_tppessoa IN crapass.inpessoa%TYPE
                                  ,pr_nrcpfcnpj_base IN crapass.nrcpfcnpj_base%TYPE
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                  ,pr_iddcarga IN crapcpa.iddcarga%TYPE DEFAULT 0
                                  ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* .............................................................................

     Programa: pc_verifica_rating_sas
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Fevereiro/2019                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Verificar se o rating da carga ativa esta vencido, e se estiver
                 acionar procedimento responsavel pela atualizacao no SAS

     Alteracoes:

     ..............................................................................*/
     DECLARE
       -- Buscar o rating da carga ativa
       CURSOR cr_crapcpa IS
         SELECT cpa.cdrating
               ,cpa.dtcalc_rating
           FROM crapcpa cpa
          WHERE cpa.cdcooper = pr_cdcooper
            AND cpa.tppessoa = pr_tppessoa
            AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
            -- Se não recebermos a carga, iremos acionar a função que traz a carga ativa
            AND cpa.iddcarga = decode(pr_iddcarga,0,empr0002.fn_idcarga_pre_aprovado(cpa.cdcooper,cpa.tppessoa,cpa.nrcpfcnpj_base),pr_iddcarga);
       rw_crapcpa cr_crapcpa%ROWTYPE;
     BEGIN
       -- Buscar o rating da carga ativa
       OPEN cr_crapcpa;
       FETCH cr_crapcpa
        INTO rw_crapcpa;
       CLOSE cr_crapcpa;
       -- Somente se o rating estiver expirado
       IF rw_crapcpa.dtcalc_rating < pr_dtmvtolt THEN
         -- Pendente de implementação - Projeto da Josi
         -- Aguardar JFF
         NULL;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         pr_dscritic := 'Erro ao atualizar Rating SAS: '||SQLERRM;
     END;
  END pc_verifica_rating_sas;

  -- Bloquear/Liberar a carga enviada
  PROCEDURE pc_bloq_libera_carga(pr_cdcooper IN crapcop.cdcooper%TYPE             --> Codigo Cooperativa
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE             --> Codigo tela
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Operador
                                ,pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                                ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                                ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                ) IS

  BEGIN

    /* .............................................................................

     Programa: pc_bloq_libera_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Bloquear/Liberar a Carga.

     Alteracoes:

     ..............................................................................*/
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_idcarga IN tbepr_carga_pre_aprv.idcarga%TYPE) IS
        SELECT carga.idcarga
              ,carga.indsituacao_carga
              ,carga.flgcarga_bloqueada
              ,carga.tpcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.idcarga = pr_idcarga;
      rw_carga cr_carga%ROWTYPE;

      -- Buscar a carga anterior automática
      CURSOR cr_carga_ant(pr_cdcooper in tbepr_carga_pre_aprv.cdcooper%TYPE
                         ,pr_idcarga  in tbepr_carga_pre_aprv.idcarga%TYPE ) IS
         select max(ult.idcarga) idcarga_anterior
           from tbepr_carga_pre_aprv ult
          where ult.cdcooper = pr_cdcooper
            and ult.idcarga <> pr_idcarga
            and ult.flgcarga_bloqueada = 0
            and ult.tpcarga = 2;
      rw_carga_ant cr_carga_ant%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_flbloque INTEGER;
      vr_dsbloque VARCHAR2(1000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);

    BEGIN
      -- Efetua a busca do registro
      OPEN cr_carga(pr_idcarga => pr_idcarga);
      FETCH cr_carga INTO rw_carga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_dscritic := 'Carga não encontrada.';
        RAISE vr_exc_saida;
      END IF;

      -- Mudar situação conforme a ação
      IF pr_acao = 'B' THEN
        vr_flbloque := 1; -- Bloquear
        vr_dsbloque := 'o Bloqueio';
      ELSE
        vr_flbloque := 0; -- Liberar
        vr_dsbloque := 'a Liberacao';
      END IF;

      -- Somente cargas Liberadas podem ser Liberadas/Bloqueadas
      IF rw_carga.indsituacao_carga = 1 THEN
        vr_dscritic := 'Cargas apenas importadas não podem ser selecionadas!';
        RAISE vr_exc_saida;
      ELSIF rw_carga.indsituacao_carga = 3 THEN
        vr_dscritic := 'Cargas rejeitadas não podem ser selecionadas!';
        RAISE vr_exc_saida;
      ELSIF rw_carga.indsituacao_carga = 4 THEN
        vr_dscritic := 'Cargas substituidas não podem ser selecionadas!';
        RAISE vr_exc_saida;
      END IF;

      -- Se ja estiver bloqueada(1) / liberada(0)
      IF rw_carga.flgcarga_bloqueada = vr_flbloque THEN
        IF pr_acao = 'B' THEN
          vr_dscritic := 'Carga selecionada já esta Bloqueada.';
        ELSE
          vr_dscritic := 'Carga selecionada já esta Liberada.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      -- Tratar bloco de DML
      BEGIN
        -- Se for uma liberacao
        IF pr_acao = 'L' THEN
          -- Pesquisa qual é a carga anterior não bloqueada da cooperativa
          OPEN cr_carga_ant(pr_cdcooper => pr_cdcooper
                           ,pr_idcarga  => rw_carga.idcarga);
          FETCH cr_carga_ant INTO rw_carga_ant;

          -- Se achou
          IF cr_carga_ant%FOUND THEN
            CLOSE cr_carga_ant;
            vr_dscritic := 'Ao atualizar carga automatica anterior';
            -- seta o final de vigencia na carga anterior que no update seguinte será bloqueada
            UPDATE tbepr_carga_pre_aprv
               SET tbepr_carga_pre_aprv.flgcarga_bloqueada = 1 -- Bloquear --
                  ,tbepr_carga_pre_aprv.dtbloqueio = SYSDATE
                  ,tbepr_carga_pre_aprv.cdoperad_bloque = pr_cdoperad
             WHERE tbepr_carga_pre_aprv.cdcooper = pr_cdcooper
               AND tbepr_carga_pre_aprv.idcarga  = rw_carga_ant.idcarga_anterior;
          ELSE
            CLOSE cr_carga_ant;
          END IF;

          -- Bloquear todas as cargas automaticas e antigas da cooperativa
          vr_dscritic := 'Ao bloquear cargas automaticas anterior';
          UPDATE tbepr_carga_pre_aprv
             SET tbepr_carga_pre_aprv.flgcarga_bloqueada = 1
           WHERE tbepr_carga_pre_aprv.cdcooper = pr_cdcooper
             AND tbepr_carga_pre_aprv.tpcarga  = 2
             AND tbepr_carga_pre_aprv.flgcarga_bloqueada = 0;
        END IF;

        -- Bloquear/Liberar a carga passada
        vr_dscritic := 'Ao atualizar carga selecionada';
        UPDATE tbepr_carga_pre_aprv
           SET tbepr_carga_pre_aprv.flgcarga_bloqueada = vr_flbloque
              ,tbepr_carga_pre_aprv.dtliberacao = decode(vr_flbloque,0,sysdate,tbepr_carga_pre_aprv.dtliberacao)
         WHERE tbepr_carga_pre_aprv.idcarga = rw_carga.idcarga;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema na solicitacao, detalhes: ' ||vr_dscritic|| ', erros: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      -- Gerar LOG no Batch
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 2
                                ,pr_nmarqlog      => pr_cdprogra
                                ,pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - '||pr_cdprogra||' --> '
                                                  || ' Cooperativa:'||pr_cdcooper
                                                  || ',Operador '||pr_cdoperad
                                                  || ' efetuou '||vr_dsbloque||' da Carga ID '||rw_carga.idcarga);

      -- Efetuar a gravação
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_bloq_libera_carga: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_bloq_libera_carga;

  -- Procedure para buscar as variaveis do cálculo do pre-aprovado
  PROCEDURE pc_variaveis_pre_aprovado(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                     ,pr_tppessoa IN crapcpa.tppessoa%TYPE              -- Tipo de PEssoa
                                     ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE -- CPF/CNPJ Base
                                     ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                     -- Saida
                                     ,pr_nrfimpre          OUT craplcr.nrfimpre%TYPE          -- Quantidade de parcelas
                                     ,pr_vlpot_parc_max    OUT crapcpa.vlpot_parc_maximo%TYPE -- Potencial parcela Maximo
                                     ,pr_vlpot_lim_max     OUT crapcpa.vlpot_lim_max%TYPE     -- Potencial Limite Maximo
                                     ,pr_vl_scr_61_90      OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90
                                     ,pr_vl_scr_61_90_cje  OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90 Conjuge
                                     ,pr_vlope_pos_scr     OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr
                                     ,pr_vlope_pos_scr_cje OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr Conjuge
                                     ,pr_vlprop_andamt     OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento
                                     ,pr_vlprop_andamt_cje OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento Conjuge
                                     ,pr_dscritic OUT VARCHAR2) IS                            -- Saida de Critica

  /* .............................................................................

     Programa: pc_variaveis_pre_aprovado
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Fevereiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Variaveis do Calculo disponivel do Pre aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- ID da Carga Disponível
      vr_idcarga crapcpa.iddcarga%TYPE;

      -- Buscar dados da carga
     CURSOR cr_crapcpa(pr_idcarga         crapcpa.iddcarga%TYPE
                       ,pr_cdcooper        crapcpa.cdcooper%TYPE
                       ,pr_tppessoa        crapcpa.tppessoa%TYPE
                       ,pr_nrcpf_cnpj_base crapcpa.nrcpfcnpj_base%TYPE) IS
        SELECT cpa.cdlcremp
              ,cpa.vlpot_parc_maximo
              ,cpa.vlpot_lim_max
              ,cpa.vlctrpre
              ,lcr.nrfimpre
          FROM craplcr lcr
              ,crapcpa cpa
         WHERE cpa.cdlcremp = lcr.cdlcremp
           AND cpa.cdcooper = lcr.cdcooper
           AND cpa.iddcarga = pr_idcarga
           AND cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base;
      rw_crapcpa cr_crapcpa%ROWTYPE;

      -- Buscar Contas/CNPJ do do CPF/CNPJ raiz enviado
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nrcpfcgc
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.Inpessoa = pr_tppessoa
           AND ass.Nrcpfcnpj_Base = pr_nrcpf_cnpj_base
           AND ass.Dtdemiss IS NULL;

      -- Vetor para evitar que o mesmo CPF/CNPJ seja reconsultado no SCR
      TYPE typ_tab_cpf_cnpj IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
      vr_tab_cpf_cnpj typ_tab_cpf_cnpj;
      vr_tab_cpf_cnpj_cje typ_tab_cpf_cnpj;

      --Seleciona a data de referencia
      CURSOR c_data_base(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
        SELECT MAX(dtrefere) dtrefere
        FROM crapopf opf
        where opf.nrcpfcgc = pr_nrcpfcgc;
      rw_data_base c_data_base%ROWTYPE;

      -- Buscar consulta SCR (cdvencto=130 - 61 a 90)
      CURSOR cr_crapopf(pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                        pr_dtrefere crapopf.dtrefere%type) IS
           SELECT sum(vop.vlvencto) vlvencto
          FROM crapvop vop
         WHERE vop.nrcpfcgc  = pr_nrcpfcgc
           AND vop.dtrefere >= pr_dtrefere
           AND vop.cdvencto  = 130;
      rw_crapopf cr_crapopf%ROWTYPE;

      -- Buscar parcelas de outras operações após data SCR
      CURSOR cr_crapepr_outras(pr_nrdconta crapass.nrdconta%TYPE
                              ,pr_dtmvtolt crapepr.dtmvtolt%TYPE) IS
        SELECT SUM(epr.vlpreemp) vlpreemp
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.vlsdeved > 0
           AND epr.dtmvtolt > last_day(pr_dtmvtolt);
      rw_crapepr_outras cr_crapepr_outras%ROWTYPE;

      -- Buscar outras propostas em Andamento
      CURSOR cr_crawepr_outras(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT SUM(wpr.vlpreemp) vlsdeved
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.insitapr = 1             -- Somente Aprovadas
           AND NOT EXISTS(SELECT 1
                           FROM crapepr epr
                          WHERE epr.cdcooper = wpr.cdcooper
                            AND epr.nrdconta = wpr.nrdconta
                            AND epr.nrctremp = wpr.nrctremp);
      rw_crawepr_outras cr_crawepr_outras%ROWTYPE;

      -- Busca contas do conjuge (podeter mais de 1)
      CURSOR cr_crapcje(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT crapcje.nrctacje nrctacje
              ,NVL(crapass.nrcpfcgc, crapcje.nrcpfcjg) nrcpfcgc
        FROM crapcje, crapass
        WHERE crapcje.cdcooper = pr_cdcooper
          AND crapcje.nrctacje > 0
          AND crapcje.nrcpfcjg IS NOT NULL
          AND crapcje.nrdconta IN (SELECT ttl.nrdconta
                                   FROM crapttl ttl
                                   WHERE ttl.nrdconta   = pr_nrdconta
                                     AND ttl.cdcooper   = crapcje.cdcooper
                                     AND ttl.idseqttl = 2)
          AND crapcje.idseqttl = 1
          AND crapcje.cdcooper = crapass.cdcooper(+)
          AND crapcje.nrctacje = crapass.nrdconta(+)
        UNION
        SELECT crapcje.nrctacje nrctacje
              ,NVL(crapass.nrcpfcgc, crapcje.nrcpfcjg) nrcpfcgc
        FROM crapcje, crapass
        WHERE crapcje.cdcooper = pr_cdcooper
          AND crapcje.nrctacje > 0
          AND crapcje.nrcpfcjg IS NOT NULL
          AND crapcje.nrdconta IN (SELECT ttl.nrdconta
                                   FROM crapttl ttl
                                   WHERE ttl.nrdconta   = pr_nrdconta
                                     AND ttl.cdcooper   = crapcje.cdcooper
                                     AND ttl.idseqttl = 1)
          AND crapcje.idseqttl = 1
          AND crapcje.cdcooper = crapass.cdcooper(+)
          AND crapcje.nrctacje = crapass.nrdconta(+)
          AND EXISTS (SELECT 1
                      FROM crapttl ttl
                      WHERE ttl.nrdconta   = crapcje.nrctacje
                        AND ttl.cdcooper   = crapcje.cdcooper
                        AND ttl.idseqttl = 2);
    BEGIN

      -- Reiniciar valores de saida
      pr_nrfimpre          := 0;
      pr_vlpot_parc_max    := 0;
      pr_vlpot_lim_max     := 0;
      pr_vl_scr_61_90      := 0;
      pr_vl_scr_61_90_cje  := 0;
      pr_vlope_pos_scr     := 0;
      pr_vlope_pos_scr_cje := 0;
      pr_vlprop_andamt     := 0;
      pr_vlprop_andamt_cje := 0;

      -- CAso seja passado o ID da Carga, usar o mesmo, senão buscamos o disponível
      IF pr_idcarga <> 0 THEN
        vr_idcarga := pr_idcarga;
      ELSE
        -- Buscar ID da Carga Disponível
        vr_idcarga := fn_idcarga_pre_aprovado(pr_cdcooper        => pr_cdcooper
                                             ,pr_tppessoa        => pr_tppessoa
                                             ,pr_nrcpf_cnpj_base => pr_nrcpf_cnpj_base);
      END IF;

      -- Se houver carga
      IF vr_idcarga > 0 THEN
        -- Buscar configuracação CRAPPRE
        OPEN cr_crapcpa(pr_idcarga => vr_idcarga
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_tppessoa => pr_tppessoa
                       ,pr_nrcpf_cnpj_base => pr_nrcpf_cnpj_base);
        FETCH cr_crapcpa
         INTO rw_crapcpa;

        IF cr_crapcpa%FOUND THEN
          CLOSE cr_crapcpa;

          -- Buscar todas as contas/CNPJs conforme raiz
          FOR rw_ass IN cr_crapass LOOP
            -- Se já não foi pesquisado o mesmo CPF/CNPJ
            IF NOT vr_tab_cpf_cnpj.exists(rw_ass.nrcpfcgc) THEN
              -- Adicionar ao vetor
              vr_tab_cpf_cnpj(rw_ass.nrcpfcgc) := rw_ass.nrcpfcgc;
              -- Buscar SCR 61 a 90
              rw_crapopf := NULL;
              rw_data_base := null;

              --Seleciona a data base
              open c_data_base(rw_ass.nrcpfcgc);
              fetch c_data_base
              into rw_data_base;
              close c_data_base;

              OPEN cr_crapopf(rw_ass.nrcpfcgc,
                              rw_data_base.dtrefere);
              FETCH cr_crapopf
               INTO rw_crapopf;
              CLOSE cr_crapopf;

              -- Acumular
              pr_vl_scr_61_90 := pr_vl_scr_61_90 + nvl(rw_crapopf.vlvencto,0);
            END IF;

            -- Buscar outras operações após data da SCR
            rw_crapepr_outras := NULL;
            OPEN cr_crapepr_outras(rw_ass.nrdconta,rw_data_base.dtrefere);
            FETCH cr_crapepr_outras INTO rw_crapepr_outras;
            CLOSE cr_crapepr_outras;

            -- Acumular
            pr_vlope_pos_scr := pr_vlope_pos_scr + NVL(rw_crapepr_outras.vlpreemp,0);

            -- Buscar operações não aprovadas do Cooperado
            rw_crawepr_outras := NULL;
            OPEN cr_crawepr_outras(rw_ass.nrdconta);
            FETCH cr_crawepr_outras INTO rw_crawepr_outras;
            CLOSE cr_crawepr_outras;

            -- Acumular
            pr_vlprop_andamt := pr_vlprop_andamt + NVL(rw_crawepr_outras.vlsdeved,0);

            -- Para PF
            IF pr_tppessoa = 1 THEN
              -- Buscar Conjuge desde que SegundoTitular
              for rw_crapcje in cr_crapcje (rw_ass.nrdconta) loop
                -- Se já não foi pesquisado o mesmo CPF/CNPJ
                IF NOT vr_tab_cpf_cnpj_cje.exists(rw_crapcje.nrcpfcgc) THEN
                  -- Adicionar ao vetor
                  vr_tab_cpf_cnpj_cje(rw_crapcje.nrcpfcgc) := rw_crapcje.nrcpfcgc;


                  rw_crapopf := NULL;
                  rw_data_base := null;

                  --Seleciona a data base
                  open c_data_base(rw_crapcje.nrcpfcgc);
                  fetch c_data_base
                  into rw_data_base;
                  close c_data_base;

                  -- Buscar SCR 61 a 90
                  OPEN cr_crapopf(rw_crapcje.nrcpfcgc,
                                  rw_data_base.dtrefere);
                  FETCH cr_crapopf
                   INTO rw_crapopf;
                  CLOSE cr_crapopf;

                  -- Acumular
                  pr_vl_scr_61_90_cje := pr_vl_scr_61_90_cje + nvl(rw_crapopf.vlvencto,0);
                END IF;

                -- Buscar outras operações após data da SCR do Conjuge
                rw_crapepr_outras := NULL;
                OPEN cr_crapepr_outras(rw_crapcje.nrctacje,rw_data_base.dtrefere);
                FETCH cr_crapepr_outras INTO rw_crapepr_outras;
                CLOSE cr_crapepr_outras;

                -- Acumular
                pr_vlope_pos_scr_cje := pr_vlope_pos_scr_cje + NVL(rw_crapepr_outras.vlpreemp,0);

                -- Buscar operações não aprovadas do Conjuge
                rw_crawepr_outras := NULL;
                OPEN cr_crawepr_outras(rw_crapcje.nrctacje);
                FETCH cr_crawepr_outras INTO rw_crawepr_outras;
                CLOSE cr_crawepr_outras;

                -- Acumular
                pr_vlprop_andamt_cje := pr_vlprop_andamt_cje + NVL(rw_crawepr_outras.vlsdeved,0);

              END LOOP;
            END IF;
          END LOOP;

          -- Retornar valores não calculados, ou seja, apenas buscados
          pr_nrfimpre          := rw_crapcpa.nrfimpre;
          pr_vlpot_parc_max    := rw_crapcpa.vlpot_parc_maximo;
          pr_vlpot_lim_max     := rw_crapcpa.vlpot_lim_max;
        ELSE
          CLOSE cr_crapcpa;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_variaveis_pre_aprovado: ' || SQLERRM;
    END;
  END pc_variaveis_pre_aprovado;


  -- Procedure para calculo do valor do PreAprovado do CPF/CNPJ enviado
  PROCEDURE pc_calc_pre_aprovado_analitico(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_tppessoa IN crapcpa.tppessoa%TYPE              -- Tipo de PEssoa
                                          ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE -- CPF/CNPJ Base
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_nrfimpre          OUT craplcr.nrfimpre%TYPE          -- Quantidade de parcelas
                                          ,pr_vlpot_parc_max    OUT crapcpa.vlpot_parc_maximo%TYPE -- Potencial parcela Maximo
                                          ,pr_vlpot_lim_max     OUT crapcpa.vlpot_lim_max%TYPE     -- Potencial Limite Maximo
                                          ,pr_vl_scr_61_90      OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90
                                          ,pr_vl_scr_61_90_cje  OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90 Conjuge
                                          ,pr_vlope_pos_scr     OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr
                                          ,pr_vlope_pos_scr_cje OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr Conjuge
                                          ,pr_vlprop_andamt     OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento
                                          ,pr_vlprop_andamt_cje OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento Conjuge
                                          ,pr_vlparcel          OUT NUMBER                         -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                         -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2) IS                   -- Saida de Critica

  /* .............................................................................

     Programa: pc_calc_pre_aprovado_analitico
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Calculo do disponivel e parcela do Pre aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;
      vr_dscritic        VARCHAR2(4000);
      vr_valor_presente  NUMBER;
      vr_taxa            NUMBER;
      vr_cf              NUMBER;
      vr_emprestimos     NUMBER := 0;
      -- Potencial maximo. E o Potencial do sas - o valor ja tomado em emprestimos.
      vr_potencial_max   NUMBER := 0;

      -- Busca da configuração
      CURSOR cr_crappre IS
        SELECT vllimmin
              ,vlmulpli
              ,cdlcremp
          FROM crappre pre
         WHERE pre.cdcooper = pr_cdcooper
           AND pre.inpessoa = pr_tppessoa;
      rw_crappre cr_crappre%ROWTYPE;

      --> Buscar linha de credito
      CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%TYPE,
                         pr_tppessoa  crapcpa.tppessoa%TYPE,
                         pr_nrcpf_cnpj_base crapcpa.nrcpfcnpj_base%TYPE,
                         pr_idcarga  crapcpa.iddcarga%TYPE)IS
        SELECT lcr.txmensal,
               lcr.flprapol
          FROM crapcpa cpa,
               craplcr lcr
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.nrcpfcnpj_base = pr_nrcpf_cnpj_base
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.iddcarga = pr_idcarga
           AND lcr.cdcooper = cpa.cdcooper
           AND lcr.cdlcremp = cpa.cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca contratos aprovados sem liberação para finalidade 68
      CURSOR cr_crawepr(pr_nrcpfcnpj_base  crapass.nrcpfcnpj_base%TYPE
                       ,pr_cdcooper        crawepr.cdcooper%TYPE) IS
        SELECT SUM(wer.vlemprst) vlemprst
        FROM crawepr wer
        WHERE wer.insitapr = 1
          AND wer.insitest = 3
          AND wer.dtaprova IS NOT NULL
          AND wer.nrdconta IN (SELECT ass.nrdconta
                               FROM crapass ass
                               WHERE ass.cdcooper = wer.cdcooper
                                 AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
          AND wer.cdfinemp = 68
          AND wer.cdcooper = pr_cdcooper
          AND NOT EXISTS (SELECT 1
                          FROM crapepr epr
                          WHERE epr.cdcooper = wer.cdcooper
                            AND epr.nrdconta = wer.nrdconta
                            AND epr.nrctremp = wer.nrctremp);
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Busca contratos liberados com saldo em aberto para finalidade 68
      CURSOR cr_crapepr(pr_nrcpfcnpj_base  crapass.nrcpfcnpj_base%TYPE
                       ,pr_cdcooper        crapepr.cdcooper%TYPE) IS
        SELECT SUM(vlsdeved) vlsdeved
        FROM(SELECT CASE WHEN epr.vlsdevat = 0 THEN
                       epr.vlsdeved
                     ELSE
                       epr.vlsdevat
                     END vlsdeved
              FROM crapepr epr
              WHERE epr.cdcooper = pr_cdcooper
                AND epr.inliquid = 0
                AND epr.nrdconta IN (SELECT ass.nrdconta
                                     FROM crapass ass
                                     WHERE ass.cdcooper = epr.cdcooper
                                       AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
                AND epr.cdfinemp = 68);
      rw_crapepr cr_crapepr%ROWTYPE;

    BEGIN
      -- Inicializar valores
      pr_vlparcel := 0;
      pr_vldispon := 0;
      vr_valor_presente := 0;

      -- Tratar parametrização da CADPRE
      OPEN cr_crappre;
      FETCH cr_crappre INTO rw_crappre;

      -- Se não encontrar, saimos sem pre-aprovado ao cooperado
      IF cr_crappre%NOTFOUND THEN
        CLOSE cr_crappre;
        RETURN;
      ELSE
        CLOSE cr_crappre;
        -- Direcionar para a busca das variaveis
        pc_variaveis_pre_aprovado(pr_cdcooper => pr_cdcooper               -- Cooperatia
                                 ,pr_tppessoa => pr_tppessoa               -- Tipo de PEssoa
                                 ,pr_nrcpf_cnpj_base => pr_nrcpf_cnpj_base -- CPF/CNPJ Base
                                 ,pr_idcarga => pr_idcarga                 -- ID da Carga
                                 -- Saida
                                 ,pr_nrfimpre          => pr_nrfimpre          -- Quantidade de parcelas
                                 ,pr_vlpot_parc_max    => pr_vlpot_parc_max    -- Potencial parcela Maximo
                                 ,pr_vlpot_lim_max     => pr_vlpot_lim_max     -- Potencial Limite Maximo
                                 ,pr_vl_scr_61_90      => pr_vl_scr_61_90      -- SCR de 61 a 90
                                 ,pr_vl_scr_61_90_cje  => pr_vl_scr_61_90_cje  -- SCR de 61 a 90 Conjuge
                                 ,pr_vlope_pos_scr     => pr_vlope_pos_scr     -- Saldo Devedor Pos Scr
                                 ,pr_vlope_pos_scr_cje => pr_vlope_pos_scr_cje -- Saldo Devedor Pos Scr Conjuge
                                 ,pr_vlprop_andamt     => pr_vlprop_andamt     -- Proposta em Andamento
                                 ,pr_vlprop_andamt_cje => pr_vlprop_andamt_cje -- Proposta em Andamento Conjuge
                                 ,pr_dscritic => vr_dscritic);                  -- Saida de Critica

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Caso não tenhamos valor retornado
        IF nvl(pr_vlpot_parc_max,0) + nvl(pr_vlpot_lim_max,0) <= 0 THEN
          -- Retornaremos vazio
          RETURN;
        END IF;

        --> Busca TAXA linha de credito
       OPEN cr_craplcr (pr_cdcooper         => pr_cdcooper,
                         pr_tppessoa        => pr_tppessoa,
                         pr_nrcpf_cnpj_base => pr_nrcpf_cnpj_base,
                         pr_idcarga         => pr_idcarga );

        FETCH cr_craplcr INTO rw_craplcr;

        IF cr_craplcr%NOTFOUND THEN
           CLOSE cr_craplcr;
        END IF;

        -- Ao continuar, calcularemos
        -- Parcela = SAS_POTENCIAL PARCELA - SOMA(SCR + Endividamento + Parcelas Nao Aprovadas)
        pr_vlparcel := NVL(pr_vlpot_parc_max,0) - (NVL(pr_vl_scr_61_90,0) +
                                                   NVL(pr_vl_scr_61_90_cje,0) +
                                                   NVL(pr_vlope_pos_scr,0) +
                                                   NVL(pr_vlope_pos_scr_cje,0) +
                                                   NVL(pr_vlprop_andamt,0) +
                                                   NVL(pr_vlprop_andamt_cje,0));

        -- calculo valor presente
        vr_cf :=  (rw_craplcr.txmensal/100) /(1 - (1/(power(1+(rw_craplcr.txmensal/100),(pr_nrfimpre -1)))));
        vr_valor_presente := pr_vlparcel / vr_cf;

        -- Pega o menor valor entre pr_vlpot_lim_max e vr_valor_presente
        pr_vldispon := least(NVL(pr_vlpot_lim_max,0),(vr_valor_presente));

        -- Controlar para valor negativo
        pr_vldispon := owa_util.ite(pr_vldispon > 0, pr_vldispon, 0);

        -- Aplicar descontos de contratos aprovados e/ou liberados para descrementar o valor do cálculo disponível
        -- Buscar e sumarizar emprestimos aprovados
        OPEN cr_crawepr(pr_nrcpfcnpj_base  => pr_nrcpf_cnpj_base
                       ,pr_cdcooper        => pr_cdcooper);
        FETCH cr_crawepr INTO rw_crawepr;

        IF cr_crawepr%FOUND THEN
          vr_emprestimos := vr_emprestimos + NVL(rw_crawepr.vlemprst, 0);
        END IF;

        CLOSE cr_crawepr;

        -- Buscar e sumarizar emprestimos liberados
        OPEN cr_crapepr(pr_nrcpfcnpj_base  => pr_nrcpf_cnpj_base
                       ,pr_cdcooper        => pr_cdcooper);
        FETCH cr_crapepr INTO rw_crapepr;

        IF cr_crapepr%FOUND THEN
          vr_emprestimos := vr_emprestimos + NVL(rw_crapepr.vlsdeved, 0);
        END IF;

        CLOSE cr_crapepr;

        -- Descontar do valor de emprestimos tomados
        vr_potencial_max := nvl(pr_vlpot_lim_max,0) - vr_emprestimos;

        -- Controlar para valor negativo
        vr_potencial_max := owa_util.ite(vr_potencial_max > 0, vr_potencial_max, 0);

        pr_vldispon := LEAST(vr_potencial_max, pr_vldispon);

        -- Tratar limite mínimo
        IF rw_crappre.vllimmin > pr_vldispon THEN
          -- Cooperado não tem o valor minimo, então não haverá Pre-Aprovado
          pr_vlparcel := 0;
          pr_vldispon := 0;
        ELSE
          -- Tratar valores multiplos para arredondamento
          pr_vldispon := pr_vldispon / rw_crappre.vlmulpli;
          pr_vldispon := TRUNC(pr_vldispon, 0);
          pr_vldispon := pr_vldispon * rw_crappre.vlmulpli;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_calc_pre_aprovado_analitico: ' || SQLERRM;
    END;
  END pc_calc_pre_aprovado_analitico;

  -- Procedure para calculo do valor do PreAprovado da Conta enviada
  PROCEDURE pc_calc_pre_aprovad_analit_cta(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_nrdconta IN crapcpa.nrdconta%TYPE              -- Conta
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_nrfimpre          OUT craplcr.nrfimpre%TYPE          -- Quantidade de parcelas
                                          ,pr_vlpot_parc_max    OUT crapcpa.vlpot_parc_maximo%TYPE -- Potencial parcela Maximo
                                          ,pr_vlpot_lim_max     OUT crapcpa.vlpot_lim_max%TYPE     -- Potencial Limite Maximo
                                          ,pr_vl_scr_61_90      OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90
                                          ,pr_vl_scr_61_90_cje  OUT crapvop.vlvencto%TYPE          -- SCR de 61 a 90 Conjuge
                                          ,pr_vlope_pos_scr     OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr
                                          ,pr_vlope_pos_scr_cje OUT crapepr.vlsdeved%TYPE          -- Saldo Devedor Pos Scr Conjuge
                                          ,pr_vlprop_andamt     OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento
                                          ,pr_vlprop_andamt_cje OUT crapepr.vlsdeved%TYPE          -- Proposta em Andamento Conjuge
                                          ,pr_vlparcel          OUT NUMBER                         -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                         -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2) IS                   -- Saida de Critica

  /* .............................................................................

     Programa: pc_calc_pre_aprovad_analit_cta
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Calculo do disponivel e parcela do Pre aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      -- Busca o CPF/CNPJ da Conta
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE := 0;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE := 0;
    BEGIN
      -- Buscar o CPF/CNPJ base
      OPEN cr_crapass;
      FETCH cr_crapass INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;
      -- Chamar a rotina de calculo por CPF/CNPJ base
      pc_calc_pre_aprovado_analitico(pr_cdcooper => pr_cdcooper               -- Cooperatia
                                    ,pr_tppessoa => vr_inpessoa               -- Tipo de PEssoa
                                    ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj_base  -- CPF/CNPJ Base
                                    ,pr_idcarga => pr_idcarga                 -- ID da Carga
                                    -- Saida
                                    ,pr_nrfimpre          => pr_nrfimpre          -- Quantidade de parcelas
                                    ,pr_vlpot_parc_max    => pr_vlpot_parc_max    -- Potencial parcela Maximo
                                    ,pr_vlpot_lim_max     => pr_vlpot_lim_max     -- Potencial Limite Maximo
                                    ,pr_vl_scr_61_90      => pr_vl_scr_61_90      -- SCR de 61 a 90
                                    ,pr_vl_scr_61_90_cje  => pr_vl_scr_61_90_cje  -- SCR de 61 a 90 Conjuge
                                    ,pr_vlope_pos_scr     => pr_vlope_pos_scr     -- Saldo Devedor Pos Scr
                                    ,pr_vlope_pos_scr_cje => pr_vlope_pos_scr_cje -- Saldo Devedor Pos Scr Conjuge
                                    ,pr_vlprop_andamt     => pr_vlprop_andamt     -- Proposta em Andamento
                                    ,pr_vlprop_andamt_cje => pr_vlprop_andamt_cje -- Proposta em Andamento Conjuge
                                    -- Calculo que será devolvido
                                    ,pr_vlparcel          => pr_vlparcel          -- Valor Parcela
                                    ,pr_vldispon          => pr_vldispon          -- Valor Disponível
                                    ,pr_dscritic => vr_dscritic);                 -- Saida de Critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_calc_pre_aprovad_analit_cta: ' || SQLERRM;
    END;
  END pc_calc_pre_aprovad_analit_cta;

  -- Procedure para calculo do valor do PreAprovado do CPF/CNPJ enviado
  PROCEDURE pc_calc_pre_aprovado_sintetico(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                          ,pr_tppessoa IN crapcpa.tppessoa%TYPE              -- Tipo de PEssoa
                                          ,pr_nrcpf_cnpj_base IN crapcpa.nrcpfcnpj_base%TYPE -- CPF/CNPJ Base
                                          ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                          -- Variaveis de saida
                                          ,pr_vlparcel          OUT NUMBER                   -- Valor da Parcela
                                          ,pr_vldispon          OUT NUMBER                   -- Valor Disponivel
                                          ,pr_dscritic          OUT VARCHAR2) IS             -- Saida de Critica

  /* .............................................................................

     Programa: pc_calc_pre_aprovado_sintetico
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Calculo do disponivel e parcela do Pre aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      -- Variaveis de saida que neste escopo não serão necessárias o retorno
      vr_nrfimpre          craplcr.nrfimpre%TYPE;
      vr_vlpot_parc_max    crapcpa.vlpot_parc_maximo%TYPE;
      vr_vlpot_lim_max     crapcpa.vlpot_lim_max%TYPE;
      vr_vl_scr_61_90      crapvop.vlvencto%TYPE;
      vr_vl_scr_61_90_cje  crapvop.vlvencto%TYPE;
      vr_vlope_pos_scr     crapepr.vlsdeved%TYPE;
      vr_vlope_pos_scr_cje crapepr.vlsdeved%TYPE;
      vr_vlprop_andamt     crapepr.vlsdeved%TYPE;
      vr_vlprop_andamt_cje crapepr.vlsdeved%TYPE;
    BEGIN
      -- Inicializar valores
      pr_vlparcel := 0;
      pr_vldispon := 0;
      -- Chamar o calculo e desprezar os retornos não necessários para esta
      pc_calc_pre_aprovado_analitico(pr_cdcooper => pr_cdcooper               -- Cooperatia
                                    ,pr_tppessoa => pr_tppessoa               -- Tipo de PEssoa
                                    ,pr_nrcpf_cnpj_base => pr_nrcpf_cnpj_base -- CPF/CNPJ Base
                                    ,pr_idcarga => pr_idcarga                 -- ID da Carga
                                    -- Saida
                                    ,pr_nrfimpre          => vr_nrfimpre          -- Quantidade de parcelas
                                    ,pr_vlpot_parc_max    => vr_vlpot_parc_max    -- Potencial parcela Maximo
                                    ,pr_vlpot_lim_max     => vr_vlpot_lim_max     -- Potencial Limite Maximo
                                    ,pr_vl_scr_61_90      => vr_vl_scr_61_90      -- SCR de 61 a 90
                                    ,pr_vl_scr_61_90_cje  => vr_vl_scr_61_90_cje  -- SCR de 61 a 90 Conjuge
                                    ,pr_vlope_pos_scr     => vr_vlope_pos_scr     -- Saldo Devedor Pos Scr
                                    ,pr_vlope_pos_scr_cje => vr_vlope_pos_scr_cje -- Saldo Devedor Pos Scr Conjuge
                                    ,pr_vlprop_andamt     => vr_vlprop_andamt     -- Proposta em Andamento
                                    ,pr_vlprop_andamt_cje => vr_vlprop_andamt_cje -- Proposta em Andamento Conjuge
                                    -- Calculo que será devolvido
                                    ,pr_vlparcel          => pr_vlparcel          -- Valor Parcela
                                    ,pr_vldispon          => pr_vldispon          -- Valor Disponível
                                    ,pr_dscritic => vr_dscritic);                 -- Saida de Critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_calc_pre_aprovado_sintetico: ' || SQLERRM;
    END;
  END pc_calc_pre_aprovado_sintetico;

  -- Procedure para calculo do valor do PreAprovado da conta enviada
  PROCEDURE pc_calc_pre_aprovad_sint_cta(pr_cdcooper IN crapcop.cdcooper%TYPE              -- Cooperatia
                                        ,pr_nrdconta IN crapcpa.nrdconta%TYPE              -- Conta
                                        ,pr_idcarga  IN crapcpa.iddcarga%TYPE DEFAULT 0    -- ID da Carga
                                        -- Variaveis de saida
                                        ,pr_vlparcel OUT NUMBER                   -- Valor da Parcela
                                        ,pr_vldispon OUT NUMBER                   -- Valor Disponivel
                                        ,pr_dscritic OUT VARCHAR2) IS             -- Saida de Critica

  /* .............................................................................

     Programa: pc_calc_pre_aprovado_sintetico
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Calculo do disponivel e parcela do Pre aprovado

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);

      -- Busca o CPF/CNPJ da Conta
      CURSOR cr_crapass IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE := 0;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE := 0;
    BEGIN
      -- Buscar o CPF/CNPJ base
      OPEN cr_crapass;
      FETCH cr_crapass INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;

      -- Inicializar valores
      pr_vlparcel := 0;
      pr_vldispon := 0;
      -- Chamar o calculo com a pessoa encontrada
      pc_calc_pre_aprovado_sintetico(pr_cdcooper        => pr_cdcooper               -- Cooperativa
                                    ,pr_tppessoa        => vr_inpessoa               -- Tipo de PEssoa
                                    ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj_base         -- CPF/CNPJ Base
                                    ,pr_idcarga         => pr_idcarga               -- ID da Carga
                                    -- Calculo que será devolvido
                                    ,pr_vlparcel          => pr_vlparcel          -- Valor Parcela
                                    ,pr_vldispon          => pr_vldispon          -- Valor Disponível
                                    ,pr_dscritic => vr_dscritic);                 -- Saida de Critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_calc_pre_aprovad_sint_cta: ' || SQLERRM;
    END;
  END pc_calc_pre_aprovad_sint_cta;

  -- Procedure para solicitar a Importação das Cargas SAS semanalmente via JOB
  PROCEDURE pc_proc_job_imp_preapv_sas(pr_cdcritic OUT NUMBER
                                      ,pr_dscritic OUT VARCHAR2) IS

  /* .............................................................................

     Programa: pc_proc_job_imp_preapv_sas
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Fevereiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Solicitar a importação das Cargas SAS semanalmente via JOB

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      -- Variáveis para criação de cursor dinâmico
      vr_nom_owner     VARCHAR2(100) := gene0005.fn_get_owner_sas;
      vr_nom_dblink    VARCHAR2(100);
      vr_num_cursor    number;
      vr_num_retor     number;
      vr_sql_cursor    varchar2(32000);
      -- Variaveis para a consulta das cargas disponíveis
      vr_skcarga         NUMBER;
      vr_cdcopcar        NUMBER;
      vr_dscarga         VARCHAR2(500);
      vr_dtcarga         DATE;
    BEGIN
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => 'IMPPRE'
                                ,pr_action => 'pc_proc_job_imp_preapv_sas');

      -- Buscar DBLink
      vr_nom_dblink := gene0005.fn_get_dblink_sas('W');
      IF vr_nom_dblink IS NULL THEN
        vr_dscritic := 'Nao foi possivel retornar o DBLink do SAS, verifique!';
        RAISE vr_exc_saida;
      END IF;

      -- Montar a consulta com todas as ultimas Cargas SAS por Cooperativa
      vr_sql_cursor := 'SELECT pot.skcarga '
                    || '      ,pot.cdcooper '
                    || '      ,pot.dscarga '
                    || '      ,pot.dtcarga '
                    || '  FROM '||vr_nom_owner||'sas_preaprovado_carga@'||vr_nom_dblink||' pot '
                    || '      ,'||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' car '
                    || ' WHERE pot.skcarga = car.skcarga '
                    || '   AND car.qtregistroprocessado > 0 '
                    || '   AND car.dthorafiminclusao is not null '
                    || '   AND car.dthorainicioprocesso is null '
                    || '   AND not exists(select 1 '
                    || '                    from tbepr_carga_pre_aprv carAim '
                    || '                   where car.skcarga = carAim.Skcarga_Sas) '
                    || '   AND car.skcarga in(select max(potMax.skcarga) '
                    || '                        from '||vr_nom_owner||'sas_preaprovado_carga@'||vr_nom_dblink||' potMax '
                    || '                            ,'||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink||' carMax '
                    || '                       where potMax.cdcooper = pot.cdcooper '
                    || '                         AND potMax.skcarga = carMax.skcarga '
                    || '                         AND carMax.qtregistroprocessado > 0 '
                    || '                         AND carMax.dthorafiminclusao is not null '
                    || '                         AND carMax.dthorainicioprocesso is null '
                    || '                     ) ';

      -- Cria cursor dinâmico
      vr_num_cursor := dbms_sql.open_cursor;

      -- Comando Parse
      dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);
      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_skcarga);
      dbms_sql.define_column(vr_num_cursor, 2, vr_cdcopcar);
      dbms_sql.define_column(vr_num_cursor, 3, vr_dscarga, 500);
      dbms_sql.define_column(vr_num_cursor, 4, vr_dtcarga);

      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);
      LOOP
        -- Verifica se há alguma linha de retorno do cursor
        vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
        IF vr_num_retor = 0 THEN
          -- Se o cursor dinamico está aberto
          IF dbms_sql.is_open(vr_num_cursor) THEN
            -- Fecha o mesmo
            dbms_sql.close_cursor(vr_num_cursor);
          END IF;
          EXIT;
        ELSE
          -- Carrega variáveis com o retorno do cursor
          dbms_sql.column_value(vr_num_cursor, 1, vr_skcarga);
          dbms_sql.column_value(vr_num_cursor, 2, vr_cdcopcar);
          dbms_sql.column_value(vr_num_cursor, 3, vr_dscarga);
          dbms_sql.column_value(vr_num_cursor, 4, vr_dtcarga);
          -- Para cada carga, iremos solicitar a importação do mesmo
          empr0002.pc_carga_autom_via_SAS(pr_cdcooper   => vr_cdcopcar
                                         ,pr_cdoperad   => '1' -- SuperUsuario
                                         ,pr_idorigem   =>  5  -- AimaroWeb
                                         ,pr_cdprogra   => 'IMPPRE'
                                         ,pr_skcarga    => vr_skcarga
                                         ,pr_cddopcao   => 'I' -- Importar
                                         ,pr_dsrejeicao => NULL
                                         ,pr_dscritic   => vr_dscritic);
          -- Montar log conforme o resultado
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := vr_dscritic || ' encontrou problemas na execução: '||vr_dscritic;
          ELSE
            vr_dscritic := vr_dscritic || ' Importacao efetuada com sucesso.';
          END IF;
          -- Gerar o log
          btch0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcopcar
                                    ,pr_ind_tipo_log  => 2
                                    ,pr_nmarqlog      => 'IMPPRE'
                                    ,pr_des_log       => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                      || ' - IMPPRE --> '
                                                      || ' Cooperativa:'||vr_cdcopcar
                                                      || ',Operador 1 - Processo Automatico de Carga SAS id '
                                                      || vr_skcarga||' - '||vr_dscarga||' de '||to_char(vr_dtcarga,'dd/mm/rrrr hh24:mi:ss')
                                                      ||'. Resultado: '||vr_dscritic);
        END IF;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        rollback;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        rollback;
        pr_dscritic := 'Erro geral em pc_proc_job_imp_preapv_sas: ' || SQLERRM;
    END;
  END pc_proc_job_imp_preapv_sas;

  -- Function para retornar cursor dos registros bloqueados órfãos
  FUNCTION fn_cursor_registros_bloq_orfao(pr_cdcooper IN VARCHAR2, pr_motivos IN VARCHAR2) RETURN typ_tab_tbepr_motivo_nao_aprv IS
      vr_cursor                    VARCHAR2(32767);
      tp_busca_bloqueio_orfao      SYS_REFCURSOR;
      tab_tbepr_motivo_nao_aprv    typ_tab_tbepr_motivo_nao_aprv;
      vr_nrdconta                  tbepr_motivo_nao_aprv.nrdconta%TYPE;
      vr_idcarga                   tbepr_motivo_nao_aprv.idcarga%TYPE;
      vr_tppessoa                  tbepr_motivo_nao_aprv.tppessoa%TYPE;
      vr_nrcpfcnpj_base            tbepr_motivo_nao_aprv.nrcpfcnpj_base%TYPE;
      vr_idmotivo                  tbepr_motivo_nao_aprv.idmotivo%TYPE;

    BEGIN
      vr_cursor := 'SELECT /*+ index_join (tbepr_motivo_nao_aprv TBEPR_MOTIVO_NAO_APRV_IDX01, TBEPR_MOTIVO_NAO_APRV_IDX03) */
                           mot.nrdconta
                          ,mot.idcarga
                          ,mot.tppessoa
                          ,mot.nrcpfcnpj_base
                          ,mot.idmotivo
                    FROM tbepr_motivo_nao_aprv mot
                        ,tbepr_carga_pre_aprv car
                    WHERE mot.idmotivo IN (' || pr_motivos || ')
                       AND mot.dtregulariza IS NULL
                       AND mot.cdcooper = ' || pr_cdcooper || '
                       AND mot.cdcooper = car.cdcooper
                       AND car.flgcarga_bloqueada = 0
                       AND mot.dtbloqueio IS NOT NULL
                       AND mot.idcarga = car.idcarga ';

      OPEN tp_busca_bloqueio_orfao FOR vr_cursor;
      LOOP
        FETCH tp_busca_bloqueio_orfao INTO vr_nrdconta, vr_idcarga, vr_tppessoa, vr_nrcpfcnpj_base, vr_idmotivo;
        EXIT WHEN tp_busca_bloqueio_orfao%NOTFOUND;

        tab_tbepr_motivo_nao_aprv(vr_idcarga || vr_idmotivo || vr_nrdconta).nrdconta := vr_nrdconta;
        tab_tbepr_motivo_nao_aprv(vr_idcarga || vr_idmotivo || vr_nrdconta).idcarga := vr_idcarga;
        tab_tbepr_motivo_nao_aprv(vr_idcarga || vr_idmotivo || vr_nrdconta).tppessoa := vr_tppessoa;
        tab_tbepr_motivo_nao_aprv(vr_idcarga || vr_idmotivo || vr_nrdconta).nrcpfcnpj_base := vr_nrcpfcnpj_base;
        tab_tbepr_motivo_nao_aprv(vr_idcarga || vr_idmotivo || vr_nrdconta).idmotivo := vr_idmotivo;
      END LOOP;
      CLOSE tp_busca_bloqueio_orfao;

      RETURN tab_tbepr_motivo_nao_aprv;
    END;

  -- Procedure para interpolar registros processados com os registros de bloqueios órfãos.
  PROCEDURE pc_libera_bloqueio_orfao(pr_cdcooper                  IN  crapass.cdcooper%TYPE         --> Código da cooperativa
                                    ,pr_tab_tbepr_motivo_nao_aprv IN  typ_tab_tbepr_motivo_nao_aprv --> Temporary table dos motivos com bloqueio
                                    ,pr_tab_arquivo               IN  typ_tab_arquivo               --> Temporary table com os registros processados
                                    ,pr_des_erro                  OUT VARCHAR2) IS                  --> Retorno da crítica (erro)
  /* .............................................................................

     Programa: pc_libera_bloqueio_orfao
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Petter Rafael
     Data    : Fevereiro/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Interpolar as temporary table com registros processos e registros com bloqueio
                 para determinar se o registro órfão será ou não liberado.

     Alteracoes:
     ..............................................................................*/
  BEGIN
    DECLARE
      inx      PLS_INTEGER;
      vr_erro  EXCEPTION;

    BEGIN
      inx := pr_tab_tbepr_motivo_nao_aprv.first;

      WHILE inx IS NOT NULL
      LOOP
        IF NOT pr_tab_arquivo.EXISTS(inx) THEN

          empr0002.pc_regularz_perca_pre_aprovad(pr_cdcooper   => pr_cdcooper
                                                ,pr_idcarga    => pr_tab_tbepr_motivo_nao_aprv(inx).idcarga
                                                ,pr_nrdconta   => pr_tab_tbepr_motivo_nao_aprv(inx).nrdconta
                                                ,pr_idmotivo   => pr_tab_tbepr_motivo_nao_aprv(inx).idmotivo
                                                ,pr_dtmvtolt   => SYSDATE
                                                ,pr_dscritic   => pr_des_erro);

          IF pr_des_erro IS NOT NULL THEN
            RAISE vr_erro;
          END IF;
        END IF;

        inx := pr_tab_tbepr_motivo_nao_aprv.next(inx);
      END LOOP;
    EXCEPTION
      WHEN vr_erro THEN
        pr_des_erro := 'Erro tratado em PC_LIBERA_BLOQUEIO_ORFAO. ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erronao tratado em PC_LIBERA_BLOQUEIO_ORFAO. ' || SQLERRM;
    END;
  END pc_libera_bloqueio_orfao;

  -- Procedure para aprovar liberação de carga manual por CPF/CNPJ após rating
  PROCEDURE pc_libera_doc_manual_rating(pr_cdcooper        IN crapass.cdcooper%TYPE         --> Código da cooperativa
                                       ,pr_nrcpfcnpj_base  IN crapcpa.nrcpfcnpj_base%TYPE   --> CPF/CNPJ do cooperado
                                       ,pr_rating          IN VARCHAR2                      --> Rating calculado
                                       ,pr_des_erro        OUT VARCHAR2) IS                 --> Retorno da crítica (erro)
  BEGIN
    DECLARE
      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Checagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
              ,dat.dtmvtoan
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar ultima carga com bloqueio de rating
      CURSOR cr_busca_idcarga(pr_cdcooper       crapcop.cdcooper%TYPE
                             ,pr_nrcpfcnpj_base crapcpa.nrcpfcnpj_base%TYPE) IS
        SELECT MAX(cpa.iddcarga) idcarga
        FROM crapcpa cpa
            ,tbepr_carga_pre_aprv pre
        WHERE cpa.cdcooper = NVL(pr_cdcooper, cpa.cdcooper)
          AND cpa.cdcooper = pre.cdcooper
          AND cpa.iddcarga = pre.idcarga
          AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
          AND pre.tpcarga = 1
          AND (cpa.cdsituacao = 'B'
               AND cpa.dtbloqueio IS NULL);
      rw_busca_idcarga cr_busca_idcarga%ROWTYPE;

      vr_exc_saida EXCEPTION;
    BEGIN
      -- Validar se cooperativa existe
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_des_erro := ' não encontrada ou inativa!';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Validar Modelo
      IF pr_cdcooper IS NULL THEN
        pr_des_erro := 'Cooperativa deve ser informado!';
        RAISE vr_exc_saida;
      END IF;

      -- Buscar ultima carga com bloqueio de rating
      OPEN cr_busca_idcarga(pr_cdcooper       => pr_cdcooper
                           ,pr_nrcpfcnpj_base => pr_nrcpfcnpj_base);
      FETCH cr_busca_idcarga INTO rw_busca_idcarga;

      IF cr_busca_idcarga%NOTFOUND THEN
        CLOSE cr_busca_idcarga;
        pr_des_erro := 'Sem carga localizada.';
        RAISE vr_exc_saida;
      END IF;

      CLOSE cr_busca_idcarga;

      -- Liberar carga para uso na primeira liberação de registro
      UPDATE tbepr_carga_pre_aprv car
      SET car.indsituacao_carga  = 2
         ,car.flgcarga_bloqueada = 0
         ,car.dtliberacao = rw_crapdat.dtmvtolt
      WHERE car.idcarga = rw_busca_idcarga.idcarga
        AND car.indsituacao_carga = 1;

      -- Substituir cargas anteriores para o CPF/CNPJ
      UPDATE crapcpa cpa
        SET cpa.cdsituacao = 'S'
      WHERE cpa.cdcooper = pr_cdcooper
        AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
        AND cpa.iddcarga < rw_busca_idcarga.idcarga;

      -- Liberar a carga atual do CPF/CNPJ
      UPDATE crapcpa cpa
      SET cpa.cdsituacao = 'A'
         ,cpa.cdrating = pr_rating
      WHERE cpa.iddcarga = rw_busca_idcarga.idcarga
        AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
        AND cpa.cdcooper = pr_cdcooper;

      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_des_erro := 'Erro tratado. Rotina pc_libera_manual_rating. Detalhes: ' || pr_des_erro;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_des_erro := 'Erro nao tratado. Rotina pc_libera_manual_rating. Detalhes: ' || SQLERRM;
    END;
  END pc_libera_doc_manual_rating;

  -- Procedure para aprovar liberação de carga manual após rating
  PROCEDURE pc_libera_manual_rating(pr_cdcooper        IN crapass.cdcooper%TYPE         --> Código da cooperativa
                                   ,pr_idcarga         IN crapcpa.iddcarga%TYPE         --> Código do carga manual
                                   ,pr_des_erro        OUT VARCHAR2) IS                 --> Retorno da crítica (erro)
    /* .............................................................................

     Programa: pc_libera_manual_rating
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Petter Rafael
     Data    : Março/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Objetivo  : Liberar carga manual após cálculo de rating.

     Alteracoes:
                 23/08/2019 - Bloquear limites caso não tenha rating analisado ou efetivo
                              Bloquear a carga caso todos os limites estão bloqueados
                              (P450 - Heckmann - AMcom).
     ..............................................................................*/
  BEGIN
    DECLARE
      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Chacagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
              ,dat.dtmvtoan
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor para resgatar CPF/CNPJ Base para substituição
      CURSOR cr_substitui_cpa(pr_cdcooper        IN crapass.cdcooper%TYPE
                             ,pr_idcarga         IN crapcpa.iddcarga%TYPE) IS
        SELECT cpa.nrcpfcnpj_base
              ,cpa.tppessoa
              ,cpa.cdcooper
              ,cpa.nrdconta
        FROM crapcpa cpa
        WHERE cpa.cdcooper = pr_cdcooper
          AND cpa.iddcarga = pr_idcarga;

      -- Cursor para verificar se todos os limites da carga estão liberados
      CURSOR cr_bloqueados_cpa(pr_cdcooper        IN crapass.cdcooper%TYPE
                              ,pr_idcarga         IN crapcpa.iddcarga%TYPE) IS
        SELECT count(1) qt_registros
        FROM crapcpa cpa
        WHERE cpa.cdcooper = pr_cdcooper
          AND cpa.iddcarga = pr_idcarga
          AND cpa.cdsituacao IN ('A','B');
      rw_bloqueados_cpa cr_bloqueados_cpa%ROWTYPE;

      vr_exc_saida EXCEPTION;
      vr_flgrating         PLS_INTEGER;
      vr_insituacao_rating tbrisco_operacoes.insituacao_rating%TYPE;
      vr_cdcritic          PLS_INTEGER;
      vr_dscritic          VARCHAR2(4000);
    BEGIN
      -- Validar se cooperativa existe
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_des_erro := ' não encontrada ou inativa!';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Validar Modelo
      IF pr_cdcooper IS NULL THEN
        pr_des_erro := 'Cooperativa deve ser informado!';
        RAISE vr_exc_saida;
      END IF;

      -- Liberar carga para uso
      UPDATE tbepr_carga_pre_aprv car
      SET car.indsituacao_carga  = 2
         ,car.flgcarga_bloqueada = 0
         ,car.dtliberacao = rw_crapdat.dtmvtolt
      WHERE car.idcarga = pr_idcarga
        AND car.indsituacao_carga = 1;

      -- Liberar situação dos cooperados
      UPDATE crapcpa cpa
      SET cpa.cdsituacao = 'A'
      WHERE cpa.iddcarga = pr_idcarga
        AND cpa.cdcooper = pr_cdcooper;

    -- Susbituir registros do mesmo documento anteriores, deixando vigente somente o mais atual
      FOR rw_substitui_cpa IN cr_substitui_cpa(pr_cdcooper => pr_cdcooper, pr_idcarga => pr_idcarga) LOOP

        -- P450 Inicio
        -- Manter os limites bloqueados caso não tenham rating
        rati0003.pc_busca_status_rating(pr_cdcooper => pr_cdcooper
                                       -- É passado o número do cpfcnpj base para verificar se há rating
                                       ,pr_nrdconta => rw_substitui_cpa.nrcpfcnpj_base
                                       ,pr_tpctrato => 68
                                       ,pr_nrctrato => 0
                                       ,pr_strating => vr_insituacao_rating
                                       ,pr_flgrating => vr_flgrating
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
        IF nvl(vr_insituacao_rating,0) NOT IN (2,4,6) THEN -- 6-Modelo Aimaro gravado em contingência
          -- Bloquear situação do limite do cooperado

          empr0002.pc_proces_perca_pre_aprovad(pr_cdcooper        => pr_cdcooper
                                              ,pr_idcarga         => pr_idcarga
                                              ,pr_nrdconta        => 0
                                              ,pr_tppessoa        => rw_substitui_cpa.tppessoa
                                              ,pr_nrcpf_cnpj_base => rw_substitui_cpa.nrcpfcnpj_base
                                              ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                              ,pr_idmotivo        => 82--> Bloqueio pre-aprovado sem rating
                                              ,pr_qtdiaatr        => 0 --> valor não será mais enviado
                                              ,pr_valoratr        => 0 --> valor não será mais enviado
                                              ,pr_dscritic        => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;
        -- P450 Fim

        UPDATE crapcpa cpa
           SET cpa.cdsituacao = 'S'
         WHERE cpa.cdcooper = rw_substitui_cpa.cdcooper
           AND cpa.tppessoa = rw_substitui_cpa.tppessoa
           AND cpa.nrcpfcnpj_base = rw_substitui_cpa.nrcpfcnpj_base
           AND cpa.iddcarga < pr_idcarga;
      END LOOP;

      -- P450 Inicio
      -- Verificar se todos os limites da carga estão liberados
      OPEN cr_bloqueados_cpa(pr_cdcooper => pr_cdcooper
                            ,pr_idcarga => pr_idcarga);
      FETCH cr_bloqueados_cpa INTO rw_bloqueados_cpa;
      CLOSE cr_bloqueados_cpa;

      -- Se não tiver nenhum limite ativo, deve bloquear toda a carga
      IF rw_bloqueados_cpa.qt_registros = 0 THEN

        -- Bloquear carga
        UPDATE tbepr_carga_pre_aprv car
           SET car.indsituacao_carga  = 1
              ,car.flgcarga_bloqueada = 1
         WHERE car.idcarga = pr_idcarga;

       END IF;
      -- P450 Fim

      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        pr_des_erro := 'Erro tratado. Rotina pc_libera_manual_rating. Detalhes: ' || pr_des_erro;
      WHEN OTHERS THEN
        ROLLBACK;
        pr_des_erro := 'Erro nao tratado. Rotina pc_libera_manual_rating. Detalhes: ' || SQLERRM;
    END;
  END pc_libera_manual_rating;

  -- Sobrecarga de método para garantir compatibilidade com o legado
  PROCEDURE pc_busca_carga_ativa(pr_cdcooper   IN NUMBER        --> Código da cooperativa
                                ,pr_nrdconta   IN NUMBER        --> Número da conta do cooperado
                                ,pr_idcarga    OUT NUMBER) IS   --> Código da carga retornada
  BEGIN
     pr_idcarga := fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta);
  END pc_busca_carga_ativa;

  /* Gerar multiplas assinaturas para PJ na contratação de pré-aprovado */
  PROCEDURE pc_gera_m_assina_pre_aprov(pr_cdcooper  IN crawepr.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Códigi da conta
                                      ,pr_nrctremp  IN NUMBER                 --> Código do contrato
                                      ,pr_assinatu  OUT VARCHAR2              --> Texto formatado das assinaturas
                                      ,pr_cdcritic  OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição da crítica
  /*.............................................................................
         programa: pc_gera_m_assina_pre_aprov
         sigla   : cred
         autor   : Petter Rafael - Envolti
         data    : Maio/2019                      ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado.
         objetivo  : Montar multiplas assinaturas para um contrato de emprestimo
                     para o pre-aprovado

         alteracoes:
    ............................................................................. */
  BEGIN
    DECLARE
      -- Checagem de existencia de cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,dat.dtmvtolt
              ,dat.dtmvtoan
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Checagem de existencia do Cooperado/conta
      CURSOR cr_crapass(pr_cdcooper  crapcop.cdcooper%TYPE
                       ,pr_nrdconta  crapass.nrdconta%TYPE) IS
        SELECT nrdconta
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar tabela de assinaturas pre-carregadas pela contratação
      CURSOR cr_assina_contrato(pr_cdcooper  IN crawepr.cdcooper%TYPE  --> Código da Cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Códigi da conta
                               ,pr_nrctremp  IN NUMBER) IS             --> Código do contrato
        SELECT nmassinatura
              ,dtassinatura
              ,hrassinatura
        FROM tbepr_assinaturas_contrato
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nrctremp = pr_nrctremp;

      vr_exec_saida  EXCEPTION;
    BEGIN

      -- Verificar a existencia da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      IF cr_crapcop%NOTFOUND THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Cooperativa informado nao existe ou esta inativa!';

        RAISE vr_exec_saida;
      END IF;

      CLOSE cr_crapcop;

      -- Verificar a existencia do cooperado/conta
      OPEN cr_crapass(pr_cdcooper  => pr_cdcooper, pr_nrdconta  => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Conta informada nao existe ou esta inativa!';

        RAISE vr_exec_saida;
      END IF;

      CLOSE cr_crapass;

      -- Carregar loop de assinaturas do contrato
      FOR rw_assina_contrato IN cr_assina_contrato(pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_nrctremp => pr_nrctremp) LOOP
        IF pr_assinatu IS NOT NULL THEN
          pr_assinatu := pr_assinatu || ', ';
        END IF;

        pr_assinatu := pr_assinatu || 'Assinado eletronicamente pelo CONTRATANTE '
                    || rw_assina_contrato.nmassinatura
                    || ' , no dia '
                    || TO_CHAR(rw_assina_contrato.dtassinatura, 'DD/MM/RRRR')
                    || ' , as '
                    || rw_assina_contrato.hrassinatura
                    || ' , mediante digitacao de senha numerica e letras de seguranca.';
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;

        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na EMPR0002.PC_GERA_M_ASSINA_PRE_APROV ' || SQLERRM;
    END;
  END pc_gera_m_assina_pre_aprov;

  -- Retornar valor de limite da parcela para validação da contratação do pré-aprovado
  PROCEDURE pc_busca_parcela_preaprov(pr_cdcooper IN crapcpa.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrdconta IN crapcpa.nrdconta%TYPE  --> Códigi da conta
                                     ,pr_nrctremp IN NUMBER                 --> Número do contrato
                                     ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Retorno de erro geral
  BEGIN
    /* .............................................................................

     Programa: pc_busca_parcela_preaprov
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : David Valente  [Envolti]
     Data    : Maio/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia:

     Objetivo  : Busca a valor de parcela liberada no pré aprovado

     Alteracoes: 28/05/2019 - Incluir check no contrato aprovado (Petter - Envolti)

     ..............................................................................*/
    DECLARE
      -- Trata o erro
      vr_exec_saida  EXCEPTION;
      pr_cdcritic NUMBER;

      -- ID DA CARGA
      pr_idcarga NUMBER;

      -- Reiniciar valores de saida
      vr_nrfimpre          NUMBER;
      vr_vlpot_parc_max    NUMBER;
      vr_vlpot_lim_max     NUMBER;
      vr_vl_scr_61_90      NUMBER;
      vr_vl_scr_61_90_cje  NUMBER;
      vr_vlope_pos_scr     NUMBER;
      vr_vlope_pos_scr_cje NUMBER;
      vr_vlprop_andamt     NUMBER;
      vr_vlprop_andamt_cje NUMBER;
      vr_vlparcel          NUMBER;
      vr_vldispon          NUMBER;
      vr_dscritic          VARCHAR2(4000);

      -- Selecionar os dados
      CURSOR cr_crapcpa (pr_cdcooper IN crawepr.cdcooper%TYPE  --> Código da Cooperativa
                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Códigi da conta
                        ,pr_idcarga  IN NUMBER) IS
         SELECT cpa.tppessoa, cpa.nrcpfcnpj_base
           FROM crapass ass, crapcpa cpa
          WHERE ass.nrcpfcnpj_base = cpa.nrcpfcnpj_base
            AND ass.nrdconta = pr_nrdconta
            AND ass.cdcooper = cpa.cdcooper
            AND cpa.cdcooper = pr_cdcooper
            AND cpa.iddcarga = pr_idcarga;

      -- Cursor para buscar proposta de emprestimo aprovada sem liberação
      CURSOR cr_crapewr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT ewr.vlemprst
              ,ewr.vlpreemp
        FROM crawepr ewr
        WHERE ewr.cdcooper = pr_cdcooper
          AND ewr.nrdconta = pr_nrdconta
          AND ewr.nrctremp = pr_nrctremp
          AND ewr.dtaprova IS NOT NULL;
      rw_crapewr cr_crapewr%ROWTYPE;

      vr_vlcalpar        crapcpa.vlcalpar%TYPE := 0;
      vr_tppessoa        crapcpa.tppessoa%TYPE := 0;
      vr_nrcpf_cnpj_base crapcpa.nrcpfcnpj_base%TYPE := 0;
      vr_valctremp       NUMBER;

    BEGIN
      -- Reiniciar valores de saida
      vr_nrfimpre          := 0;
      vr_vlpot_parc_max    := 0;
      vr_vlpot_lim_max     := 0;
      vr_vl_scr_61_90      := 0;
      vr_vl_scr_61_90_cje  := 0;
      vr_vlope_pos_scr     := 0;
      vr_vlope_pos_scr_cje := 0;
      vr_vlprop_andamt     := 0;
      vr_vlprop_andamt_cje := 0;
      vr_vlparcel          := 0;
      vr_vldispon          := 0;
      vr_dscritic          := NULL;

      -- PEGA O CÓDIGO DA CARGA ATIVA
      pr_idcarga := fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta);

      -- Busca o valor da parcela
      OPEN cr_crapcpa(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_idcarga  => pr_idcarga);
      FETCH cr_crapcpa
      INTO vr_tppessoa, vr_nrcpf_cnpj_base;
      CLOSE cr_crapcpa;

      -- retorna o valor da parcela calculada entre outras coisas
      pc_calc_pre_aprovado_analitico(pr_cdcooper          => pr_cdcooper,
                                     pr_tppessoa          => vr_tppessoa,
                                     pr_nrcpf_cnpj_base   => vr_nrcpf_cnpj_base,
                                     pr_idcarga           => pr_idcarga,
                                     pr_nrfimpre          => vr_nrfimpre,
                                     pr_vlpot_parc_max    => vr_vlpot_parc_max,
                                     pr_vlpot_lim_max     => vr_vlpot_lim_max,
                                     pr_vl_scr_61_90      => vr_vl_scr_61_90,
                                     pr_vl_scr_61_90_cje  => vr_vl_scr_61_90_cje,
                                     pr_vlope_pos_scr     => vr_vlope_pos_scr,
                                     pr_vlope_pos_scr_cje => vr_vlope_pos_scr_cje,
                                     pr_vlprop_andamt     => vr_vlprop_andamt,
                                     pr_vlprop_andamt_cje => vr_vlprop_andamt_cje,
                                     pr_vlparcel          => vr_vlparcel,
                                     pr_vldispon          => vr_vldispon,
                                     pr_dscritic          => vr_dscritic);

      -- Verificar se o contrato irá validar valor (alteração ou liberação)
      OPEN cr_crapewr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapewr INTO rw_crapewr;

      IF cr_crapewr%NOTFOUND THEN
        vr_valctremp := 0;
      ELSE
        vr_valctremp := rw_crapewr.vlpreemp;
      END IF;

      CLOSE cr_crapewr;

      -- Acumular valor da tabela de liberação com o valor corrente do contrato
      vr_valctremp := vr_valctremp + vr_vlparcel;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcalpar'
                            ,pr_tag_cont => vr_valctremp
                            ,pr_des_erro => pr_dscritic);
    EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na busca de parcelas: ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;
  END pc_busca_parcela_preaprov;

  /* Gerar multiplas assinaturas para PJ na contratação de pré-aprovado */
  PROCEDURE pc_assinatura_contrato_pre(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_cdagenci     IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                      ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                      ,pr_idseqttl     IN INTEGER --> Titularidade do Cooperado
                                      ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                      ,pr_cdorigem     IN INTEGER  --> Codigo da origem do canal
                                      ,pr_nrctremp     IN NUMBER   --> numero o contrato de emprestimo
                                      ,pr_tpassinatura IN NUMBER --> tipo de assinatura (1 socio/2 - cooperativa)
                                      ,pr_assinatu     OUT VARCHAR2  --> Texto formatado das assinaturas
                                      ,pr_des_reto     OUT VARCHAR   --> Retorno OK / NOK
                                      ,pr_cdcritic     OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic     OUT VARCHAR2) IS
  BEGIN
    DECLARE
      CURSOR cr_busca_assinatura(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta     IN crapass.nrdconta%TYPE
                                ,pr_nrctremp     IN NUMBER) IS
        SELECT 1
        FROM tbepr_assinaturas_contrato assina
        WHERE assina.cdcooper = pr_cdcooper
          AND assina.nrdconta = pr_nrdconta
          AND assina.nrctremp = pr_nrctremp;
     rw_busca_assinatura cr_busca_assinatura%ROWTYPE;

    BEGIN
      OPEN cr_busca_assinatura(pr_cdcooper  => pr_cdcooper
                              ,pr_nrdconta  => pr_nrdconta
                              ,pr_nrctremp  => pr_nrctremp);
      FETCH cr_busca_assinatura INTO rw_busca_assinatura;

      IF cr_busca_assinatura%NOTFOUND THEN

        --Chama a rotina para criar a assinatura
        empr0017.pc_assinatura_contrato(pr_cdcooper => pr_cdcooper,
                                        pr_cdagenci => pr_cdagenci,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_idseqttl => pr_idseqttl,
                                        pr_dtmvtolt => pr_dtmvtolt,
                                        pr_cdorigem => pr_cdorigem,
                                        pr_nrctremp => pr_nrctremp,
                                        pr_tpassinatura => pr_tpassinatura,
                                        pr_des_reto => pr_des_reto,
                                        pr_dscritic => pr_dscritic);
      END IF;

      CLOSE cr_busca_assinatura;

      IF pr_des_reto = 'OK' OR pr_des_reto IS NULL THEN
        --Formata a assinatura
        pc_gera_m_assina_pre_aprov(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_assinatu => pr_assinatu,
                                   pr_cdcritic => pr_cdcritic,
                                   pr_dscritic => pr_dscritic);

      END IF;
    END;
  END pc_assinatura_contrato_pre;

  /* Desbloqueio pre-aprovado quando bloqueados por falta de rating */
  PROCEDURE pc_desbloqueio_pre_aprv_rating(pr_cdcooper  IN crawepr.cdcooper%TYPE DEFAULT 0 --> Código da Cooperativa
                                          ,pr_cdcritic  OUT INTEGER               --> Código de críticia
                                          ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição da crítica
  /*.............................................................................
         programa: pc_desbloqueio_pre_aprv_rating
         sigla   : cred
         autor   : Elton (Amcom)
         data    : Agosto/2019                      ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado a partir do JOB
         objetivo  : desbloquear pre-aprovado por motivo de falta de rating. 

         alteracoes:
    ............................................................................. */
  BEGIN
    DECLARE

      -- busca cooperativas ativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,dat.dtmvtolt
              ,dat.dtmvtoan
          FROM crapcop cop
              ,crapdat dat
         WHERE cop.cdcooper = dat.cdcooper
           AND cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper) -- 0-para todas
           AND cop.flgativo = 1;

      -- lista cargas ativas
      CURSOR cr_cargas(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS   
        SELECT distinct cpa.iddcarga
            FROM crapcpa              cpa
                ,tbepr_carga_pre_aprv car
           WHERE cpa.cdcooper = pr_cdcooper
             AND car.cdcooper = cpa.cdcooper
             AND cpa.iddcarga = car.idcarga
             AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(pr_dtmvtolt)
             AND cpa.cdsituacao IN ('A','B');

      -- Buscar casos com bloqueio 
      CURSOR cr_desbloquear (pr_iddcarga crapcpa.iddcarga%TYPE) IS           
        SELECT ppp.cdcooper, ppp.nrcpfcnpj_base, ppp.tppessoa
          FROM tbepr_motivo_nao_aprv ppp
         WHERE ppp.idmotivo = 82 --Bloqueio pre-aprovado sem rating
           AND ppp.idcarga  = pr_iddcarga;
     
      vr_flgrating         PLS_INTEGER;
      vr_insituacao_rating tbrisco_operacoes.insituacao_rating%TYPE;
      
      vr_exc_saida  EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
      
    BEGIN              

      -- Carregar cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP 
                                                  
        -- buscar cargas ativas (manuais ou automaticas)
        FOR rw_cargas IN cr_cargas(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_dtmvtolt => rw_crapcop.dtmvtolt)  LOOP

          -- verificar casos bloqueados
          FOR rw_desbloquear IN cr_desbloquear(pr_iddcarga => rw_cargas.iddcarga) LOOP

             --verifica se tem rating para cooperado
             rati0003.pc_busca_status_rating(pr_cdcooper  => rw_crapcop.cdcooper
                                            ,pr_nrdconta  => rw_desbloquear.nrcpfcnpj_base
                                            ,pr_tpctrato  => 68
                                            ,pr_nrctrato  => 0
                                            ,pr_strating  => vr_insituacao_rating 
                                            ,pr_flgrating => vr_flgrating
                                            ,pr_cdcritic  => vr_cdcritic 
                                            ,pr_dscritic  => vr_dscritic);
        
             IF nvl(vr_insituacao_rating,0) IN (2,4) THEN --2-Analisado 4-efetivo
                --desbloquear
                pc_regularz_perca_pre_aprovad(pr_cdcooper        => rw_crapcop.cdcooper
                                             ,pr_idcarga         => rw_cargas.iddcarga
                                             ,pr_nrdconta        => 0
                                             ,pr_tppessoa        => rw_desbloquear.tppessoa    
                                             ,pr_nrcpf_cnpj_base => rw_desbloquear.nrcpfcnpj_base
                                             ,pr_idmotivo        => 82
                                             ,pr_dtmvtolt        => rw_crapcop.dtmvtolt
                                             ,pr_dscritic        => vr_dscritic);
        
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
             
             END IF;   
          END LOOP;
        END LOOP;    
      END LOOP;    
      COMMIT;
    EXCEPTION

      WHEN vr_exc_saida THEN
        ROLLBACK;
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := 'Erro na EMPR0002.pc_desbloqueio_pre_aprv_rating. '||vr_dscritic;
        
      WHEN OTHERS THEN
        ROLLBACK;
        
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na EMPR0002.pc_desbloqueio_pre_aprv_rating ' || SQLERRM; 
    END;
  END pc_desbloqueio_pre_aprv_rating; 

  /* Job para Desbloqueio pre-aprovado quando bloqueados por falta de rating */
  PROCEDURE pc_job_desblo_preapvr_rating(pr_cdcritic  OUT INTEGER               --> Código de críticia
                                        ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição da crítica
  /*.............................................................................
         programa: pc_job_desblo_preapvr_rating
         sigla   : cred
         autor   : Elton (Amcom)
         data    : Agosto/2019                      ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado a partir do JOB JBEPR_DESBLOQ_PREAPRV_RAT
         objetivo  : desbloquear pre-aprovado por motivo de falta de rating. 

         alteracoes:
    ............................................................................. */
  BEGIN
    DECLARE

      CURSOR cr_busca_cargas IS
        SELECT cdcooper, idcarga
          FROM tbepr_carga_pre_aprv
         WHERE indsituacao_carga = 1
           AND tpcarga = 1;
           
	    vr_exc_erro  EXCEPTION;
     
    BEGIN              
 
      FOR rw_busca_cargas IN cr_busca_cargas LOOP
        pc_libera_manual_rating(pr_cdcooper   => rw_busca_cargas.cdcooper
                               ,pr_idcarga    => rw_busca_cargas.idcarga
                               ,pr_des_erro   => pr_dscritic);
                                     
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

      -- gera a tentativa de desbloqueio dos casos de pre aprovados bloqueados por falta de rating
      pc_desbloqueio_pre_aprv_rating(pr_cdcooper => 0-- para todas as cooperativas
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);
   
    EXCEPTION

      WHEN vr_exc_erro THEN
        pr_dscritic := 'Erro ao executar empr0002.pc_job_desblo_preapvr_rating: ' || pr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        ROLLBACK;
    END;   
  END pc_job_desblo_preapvr_rating;   

  -- Rotina para validar e registrar a requição de contratação do pré-aprovado
  PROCEDURE pc_registra_requisicao_pre(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da Conta do Cooperado
                                      ,pr_idcontrl    OUT tbepr_pre_aprovado_controle.idcontrole%TYPE
                                      ,pr_dscritic    OUT VARCHAR2)  IS
    /* .............................................................................

     Programa: pc_registra_requisicao_pre
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Renato Darosci  [Supero]
     Data    : Julho/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia:

     Objetivo  : Realizar o tratamento e registro de requisições do pré-aprovado

     Alteracoes: 

     ..............................................................................*/
  
    -- Rotina pragma, destinada a registrar a requisição do pré-aprovado
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    -- CURSORES
    -- Buscar o número do CPF do titular da conta
    CURSOR cr_crapass IS
      SELECT t.nrcpfcgc
        FROM crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    
    -- Buscar registros de requisições para a conta ou CPF
    CURSOR cr_requisicao(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT *
        FROM tbepr_pre_aprovado_controle t
       WHERE (t.cdcooper = pr_cdcooper
         AND  t.nrdconta = pr_nrdconta)
          OR t.nrcpfcgc = pr_nrcpfcgc
       ORDER BY t.dhrequisao DESC;
    rw_requisicao    cr_requisicao%ROWTYPE;
    
    -- Buscar a última requisição inclusa na tabela 
    CURSOR cr_lastid IS
      SELECT MAX(idcontrole) 
        FROM tbepr_pre_aprovado_controle t;
    
    -- Buscar o parametro de intervalo de tempo
    CURSOR cr_prmtempo(pr_cdpartar    crappco.cdpartar%TYPE) IS
      SELECT to_number(t.dsconteu)
        FROM crappco t
       WHERE t.cdcooper = pr_cdcooper
         AND t.cdpartar = pr_cdpartar;
    
    -- Cursor para extrair os tempos 
    CURSOR cr_calculo(pr_hrtstamp  TIMESTAMP
                     ,pr_hrrequis  TIMESTAMP) IS
      SELECT (EXTRACT(DAY    FROM (pr_hrtstamp - pr_hrrequis ) ) * 86.400 )
           + (EXTRACT(HOUR   FROM (pr_hrtstamp - pr_hrrequis ) ) * 3600   )
           + (EXTRACT(MINUTE FROM (pr_hrtstamp - pr_hrrequis ) ) * 60     )
           +  EXTRACT(SECOND FROM (pr_hrtstamp - pr_hrrequis ) ) 
        FROM dual;
           
    -- VARIÁVEIS
    vr_idrequis    BOOLEAN;
    vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;
    vr_idcontrl    tbepr_pre_aprovado_controle.idcontrole%TYPE;
    vr_qttmpreq    NUMBER;
    vr_qtinterv    NUMBER;
    vr_cdpartar    crappco.cdpartar%TYPE;
    vr_nrdrowid    VARCHAR2(100);
    vr_dsmsglog    VARCHAR2(1000);
    vr_hrtstamp    TIMESTAMP;
    
  BEGIN
    
    -- Buscar o número do documento do cooperado
    OPEN  cr_crapass;
    FETCH cr_crapass INTO vr_nrcpfcgc;
    
    -- Se não encontrar cooperado
    IF cr_crapass%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapass;
      -- retornar a mensagem de critica
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => 9);
      -- Rolback da sessão
      ROLLBACK;
      -- Sair da rotina
      RETURN;
    END IF;
    
    -- Fechar cursor
    CLOSE cr_crapass;
  
    -- Realizar o lock da tabela de controle
    LOCK TABLE tbepr_pre_aprovado_controle IN EXCLUSIVE MODE; 
    
    -- Verificar se existe registro de solicitação pela conta ou pelo CPF
    OPEN  cr_requisicao(vr_nrcpfcgc);
    FETCH cr_requisicao INTO rw_requisicao;
    
    -- Guardar a situação do cursor
    vr_idrequis := cr_requisicao%FOUND;
      
    -- Fechar o cursor aberto
    CLOSE cr_requisicao;
    
    -- Se não encontrar registros
    IF NOT vr_idrequis THEN
      -- Buscar o último ID gerado na tabela
      OPEN  cr_lastid;
      FETCH cr_lastid INTO vr_idcontrl;
      CLOSE cr_lastid;
      
      -- Incrementar variável
      vr_idcontrl := NVL(vr_idcontrl,0) + 1;
      
      -- Inserir o registro de controle
      INSERT INTO tbepr_pre_aprovado_controle
                       (idcontrole
                       ,cdcooper
                       ,nrdconta
                       ,nrcpfcgc
                       ,dhrequisao
                       ,idsucesso)
                VALUES (vr_idcontrl   -- idcontrole
                       ,pr_cdcooper   -- cdcooper
                       ,pr_nrdconta   -- nrdconta
                       ,vr_nrcpfcgc   -- nrcpfcgc
                       ,SYSTIMESTAMP  -- dhrequisao
                       ,0);           -- idsucesso
       
      -- Retornar o id controle gerado
      pr_idcontrl := vr_idcontrl;
      
    ELSE
     
      -- Verificar se a requisição é uma requisição concluída com sucesso
      IF rw_requisicao.idsucesso = 1 THEN
        vr_cdpartar := 73; -- Validar pelo parametro de tempo entre solicitações de empréstimos efetuadas
      ELSE 
        vr_cdpartar := 72; -- Validar pelo parametro de tempo entre requisições
      END IF;
      
      BEGIN
        -- Buscar o intervalo para solicitações de pré-aprovado
        OPEN  cr_prmtempo(vr_cdpartar);
        FETCH cr_prmtempo INTO vr_qttmpreq;
        
        -- Se não encontrar o parametro de tempo cadastrado, não valida
        IF cr_prmtempo%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_prmtempo;
          
          -- O processo seguirá normalmente
          pr_dscritic := NULL;
          
          -- Rollback da sessão
          ROLLBACK;
          
          -- Encerra a rotina 
          RETURN;
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_prmtempo;
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar mensagem de crítica
          pr_dscritic := 'Erro ao buscar parametros das requisicoes: '||SQLERRM;
          -- Aplicar o rollback na sessão pragma
          ROLLBACK;
          -- Sair da rotina
          RETURN;
      END;
      
      -- Armazenar o timestamp utilizado nas validações
      vr_hrtstamp := SYSTIMESTAMP;
      
      BEGIN
        -- Calcular o intervalo
        OPEN  cr_calculo(vr_hrtstamp, rw_requisicao.dhrequisao);
        FETCH cr_calculo INTO vr_qtinterv;
        CLOSE cr_calculo;
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar mensagem de crítica
          pr_dscritic := 'Erro ao calcular intervalo das requisicoes: '||SQLERRM;
          -- Aplicar o rollback na sessão pragma
          ROLLBACK;
          -- Sair da rotina
          RETURN;
      END;
        
      -- Verifica se o tempo mínimo foi atingido
      IF vr_qtinterv >= vr_qttmpreq THEN
        
        -- Atualizar o horário da última requisição
        UPDATE tbepr_pre_aprovado_controle t
           SET t.dhrequisao = vr_hrtstamp
             , t.idsucesso  = 0 -- novo fluxo
         WHERE t.idcontrole = rw_requisicao.idcontrole;
        
        -- Retornar o id controle gerado
        pr_idcontrl := rw_requisicao.idcontrole;
        
      ELSE
        -- Verificar se a requisição é uma requisição concluída com sucesso
        IF rw_requisicao.idsucesso = 1 THEN
          -- Retornar mensagem de critica solicitando que aguarde mais alguns minutos
          pr_dscritic := 'Verificado contrato de pre-aprovado efetivado recentemente.';
          
        ELSE
          -- Retornar mensagem de critica solicitando que aguarde mais alguns minutos
          pr_dscritic := 'Verificado ocorrencia de requisicoes seguidas ou simultaneas.';

        END IF;
                
        -- Gerar log de erro
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => '1',
                             pr_dscritic => pr_dscritic,
                             pr_dsorigem => '',
                             pr_dstransa => 'Requisicao de Pre Aprovado REJEITADA',
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 0,
                             pr_hrtransa => to_char(SYSDATE, 'SSSSS'),
                             pr_idseqttl => 1,
                             pr_nmdatela => ' ',
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);

        -- Gravar o tempo entre as requisições
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Horario das requisicoes',
                                  pr_dsdadant => to_char(rw_requisicao.dhrequisao, 'hh24:mi:ss.sssss'),
                                  pr_dsdadatu => to_char(vr_hrtstamp             , 'hh24:mi:ss.sssss'));
        
        -- Gravar o parametro utilizado na validação
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Tempo minimo param.(segundos)',
                                  pr_dsdadant => vr_qttmpreq,
                                  pr_dsdadatu => NULL);
      END IF;
   
    END IF ;                
    
    -- Commita a sessão liberando o lock da tabela
    COMMIT;
          
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao registrar requisicao: '||SQLERRM;
      ROLLBACK;
  END pc_registra_requisicao_pre;
  
  -- Rotina para validar e registrar a requição de contratação do pré-aprovado
  PROCEDURE pc_requisicao_pre_finaliza(pr_idcontrl     IN tbepr_pre_aprovado_controle.idcontrole%TYPE -- Id de controle
                                      ,pr_dscritic    OUT VARCHAR2)  IS
    /* .............................................................................

     Programa: pc_requisicao_pre_finaliza
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Renato Darosci  [Supero]
     Data    : Julho/2019.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia:

     Objetivo  : Realizar a indicação de finalização do processo de solicitação de pré-aprovado

     Alteracoes: 

     ..............................................................................*/
    
    -- Rotina pragma, destinada a registrar finalização da requisição do pré-aprovado
    PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
      
    -- Se foi informado id de controle
    IF NVL(pr_idcontrl,0) > 0 THEN
      -- Atualizar o indicador da requisição
      UPDATE tbepr_pre_aprovado_controle t
         SET t.idsucesso  = 1 -- Indica sucesso na solicitação
       WHERE t.idcontrole = pr_idcontrl;
    END IF;
    
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao atualizar indicador da requisicao: '||SQLERRM;
      ROLLBACK;
  END pc_requisicao_pre_finaliza;
  
END EMPR0002;
/
