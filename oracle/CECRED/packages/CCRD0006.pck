CREATE OR REPLACE PACKAGE CECRED.CCRD0006 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CCRD0006
  --  Autor   : Andrei Vieira
  --  Data    : Junho/2017                     Ultima Atualizacao:
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de leitura e geracao de arquivos XML de domicilio bancario
  --
  --  Alteracoes: 14/06/2017 - Criação da rotina.

  --  Variáveis globais
  vr_database_name           VARCHAR2(50);
  vr_dtprocessoexec          crapdat.dtmvtolt%TYPE;
  vr_horini_23_1cicl         VARCHAR2(15);
  vr_horfim_23_1cicl         VARCHAR2(15);
  vr_horini_23_2cicl         VARCHAR2(15);
  vr_horfim_23_2cicl         VARCHAR2(15);
  vr_horini_25_1cicl         VARCHAR2(15);
  vr_horfim_25_1cicl         VARCHAR2(15);
  vr_horini_25_2cicl         VARCHAR2(15);
  vr_horfim_25_2cicl         VARCHAR2(15);
  vr_horini_33               VARCHAR2(15);
  vr_horfim_33               VARCHAR2(15);
  vr_horini_efetiva_agend    VARCHAR2(15);
  vr_horfim_efetiva_agend    VARCHAR2(15);
  vr_horini_rec_25_1cicl     VARCHAR2(15);
  vr_horfim_rec_25_1cicl     VARCHAR2(15);
  vr_horini_rec_25_2cicl     VARCHAR2(15);
  vr_horfim_rec_25_2cicl     VARCHAR2(15);
  var_dt_ult_envio_email_slc VARCHAR2(15);
  vr_horini_33_cancel        VARCHAR2(15);
  vr_horfim_33_cancel        VARCHAR2(15);
  TYPE typ_reg_tabela IS
    RECORD(dslinha varchar2(1000));
  TYPE typ_tab_tabela IS TABLE OF typ_reg_tabela INDEX BY PLS_INTEGER;


  PROCEDURE pc_executa_processo(pr_dtprocessoexec IN DATE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2) ;


  PROCEDURE pc_leitura_arquivos_xml (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType    --> XML de retorno da operadora
                                   ,pr_nrcampo   IN VARCHAR2              --> Campo a ser buscado no XML
                                   ,pr_indcampo  IN VARCHAR2              --> Tipo de dado: S=String, D=Data, N=Numerico
                                   ,pr_retorno   OUT VARCHAR2              --> Retorno do campo do xml
                                   ,pr_dscritic  IN OUT VARCHAR2);

  PROCEDURE insere_arq_liq_transacao (pr_nomarq           IN VARCHAR2
                                     ,pr_NumCtrlEmis      IN VARCHAR2
                                     ,pr_NumCtrlDestOr    IN VARCHAR2
                                     ,pr_ISPBEmissor      IN VARCHAR2
                                     ,pr_ISPBDestinatario IN VARCHAR2
                                     ,pr_DtHrArq          IN VARCHAR2
                                     ,pr_DtRef            IN VARCHAR2
                                     ,pr_idarquivo        IN OUT NUMBER
                                     ,pr_iderro           IN NUMBER
                                     ,pr_dscritic         IN OUT VARCHAR2);


  PROCEDURE insere_liquidacao_transacao (pr_identdpartprincipal IN VARCHAR2
                                        ,pr_identdpartadmtd     IN VARCHAR2
                                        ,pr_cnpjbasecreddr      IN VARCHAR2
                                        ,pr_cnpjcreddr          IN NUMBER
                                        ,pr_ispbifdevdr         IN VARCHAR2
                                        ,pr_ispbifcredr         IN VARCHAR2
                                        ,pr_agcreddr            IN NUMBER
                                        ,pr_ctcreddr            IN NUMBER
                                        ,pr_nomcreddr            IN VARCHAR2
                                        ,pr_idarquivo           IN NUMBER
                                        ,pr_idlancto            IN OUT NUMBER
                                        ,pr_iderro              IN NUMBER
                                        ,pr_dscritic            IN OUT VARCHAR2) ;

  PROCEDURE insere_liq_trn_central(pr_tppessoacentrlz IN VARCHAR2
                                  ,pr_cnpj_cpfcentrlz IN NUMBER
                                  ,pr_codcentrlz      IN VARCHAR2
                                  ,pr_tpct            IN VARCHAR2
                                  ,pr_ctpgtocentrlz    IN NUMBER
                                  ,pr_agcentrlz       IN NUMBER
                                  ,pr_ctcentrlz        IN NUMBER
                                  ,pr_idlancto        IN NUMBER
                                  ,pr_idcentraliza    IN OUT NUMBER
                                  ,pr_dscritic        IN OUT VARCHAR2);

  PROCEDURE insere_liq_trn_cen_pve (pr_nuliquid                IN VARCHAR2
                                   ,pr_ispbifliquidpontovenda  IN VARCHAR2
                                   ,pr_codpontovenda           IN VARCHAR2
                                   ,pr_nomepontovenda          IN VARCHAR2
                                   ,pr_tppessoapontovenda      IN VARCHAR2
                                   ,pr_cnpj_cpfpontovenda      IN NUMBER
                                   ,pr_codinstitdrarrajpgto    IN VARCHAR2
                                   ,pr_tpprodliquidcred        IN NUMBER
                                   ,pr_indrformatransf         IN VARCHAR2
                                   ,pr_codmoeda                IN NUMBER
                                   ,pr_dtpgto                  IN VARCHAR2
                                   ,pr_vlrpgto                 IN NUMBER
                                   ,pr_dthrmanut               IN VARCHAR2
                                   ,pr_codocorc                IN VARCHAR2
                                   ,pr_numctrlifacto           IN VARCHAR2
                                   ,pr_numctrlcipaceito        IN VARCHAR2
                                   ,pr_idcentraliza            IN NUMBER
                                   ,pr_idpdv                   IN OUT NUMBER
                                   ,pr_dscritic                IN OUT VARCHAR2);

  FUNCTION valida_arquivo_processado(pr_nomarq  IN VARCHAR2) RETURN VARCHAR2; -- 'S' ou 'N'

  -- Rotina para processar o arquivo ASLC022 do diretorio
  PROCEDURE processa_arquivo_xml_22(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                   ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  -- Rotina para gerar o arquivo ASLC023 no diretorio
  PROCEDURE gera_arquivo_xml_23(pr_dscritic IN OUT VARCHAR2) ;


   PROCEDURE teste ;

  -- Rotina para PROCESSAR o arquivo ASLC023RET do diretorio
  PROCEDURE processa_arquivo_23ret(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  PROCEDURE processa_registro_23RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           );

  PROCEDURE processa_reg_23RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF            IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2
                                         ,pr_dthorarejei            IN DATE DEFAULT NULL) ;

  PROCEDURE processa_arquivo_23err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  PROCEDURE processa_arquivo_24(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                               ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  -- Rotina para gerar o arquivo ASLC025 no diretorio
  PROCEDURE gera_arquivo_xml_25 (pr_dscritic IN OUT VARCHAR2);

  -- Rotina para PROCESSAR o arquivo ASLC025RET do diretorio
  PROCEDURE processa_arquivo_25ret(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  PROCEDURE processa_registro_25RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           );


  PROCEDURE processa_reg_25RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF            IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2);

  PROCEDURE processa_arquivo_25err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  PROCEDURE pc_gera_critica (pr_nomearq   IN VARCHAR2
                            ,pr_idcampo   IN VARCHAR2
                            ,pr_dscritic  IN OUT VARCHAR2
                            ,pr_cdocorr   IN NUMBER DEFAULT NULL) ;

   PROCEDURE processa_arquivo_32(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                ,pr_dscritic OUT VARCHAR2);

   PROCEDURE processa_arquivo_33RET(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                   ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

   PROCEDURE gera_arquivo_xml_33 (pr_dscritic IN OUT VARCHAR2);

  PROCEDURE processa_registro_33RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           ) ;

  PROCEDURE processa_reg_33RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF            IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2);

  PROCEDURE processa_arquivo_33err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao do erro

  PROCEDURE pc_atualiza_transacao_erro (pr_idlancto     IN NUMBER
                                       ,pr_dscritic     IN OUT VARCHAR2);


  PROCEDURE atualiza_nome_arquivo (pr_idtipoarquivo    IN NUMBER  -- 1- ARQUIVO ENVIO, 2- ARQUIVO RETORNO
                                  ,pr_nomearqorigem    IN VARCHAR2
                                  ,pr_nomearqatualizar IN VARCHAR2
                                  ,pr_dscritic         IN OUT VARCHAR2);

  PROCEDURE pc_envia_email(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                          ,pr_dspara      IN VARCHAR2
                          ,pr_dsassunto   IN VARCHAR2
                          ,pr_dstexto     IN VARCHAR2
                          ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                          );                --> Descrição do erro

  PROCEDURE pc_efetiva_agendamentos(pr_dtprocesso IN DATE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2);

   PROCEDURE pc_processa_reg_pendentes(pr_dtprocesso IN DATE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2);

   PROCEDURE pc_efetiva_reg_pendentes(pr_dtprocesso IN DATE
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2);

   PROCEDURE pc_procura_ultseq_craplcm(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                      ,pr_cdagenci IN  craplcm.cdagenci%TYPE
                                      ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                      ,pr_nrdolote IN  craplcm.nrdolote%TYPE
                                      ,pr_nrseqdiglcm OUT craplcm.nrseqdig%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_procura_ultseq_craplau(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                     ,pr_dtmvtolt IN  craplau.dtmvtolt%TYPE
                                     ,pr_cdagenci IN  craplau.cdagenci%TYPE
                                     ,pr_cdbccxlt IN  craplau.cdbccxlt%TYPE
                                     ,pr_nrdolote IN  craplau.nrdolote%TYPE
                                     ,pr_nrseqdiglau OUT craplau.nrseqdig%TYPE
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2);

  -- Rotina que fará a conciliacao entre o que foi enviado nos movimentos LDL e LTR
  -- com o que foi lançado por conta na CRAPLCM pela procedure CCRD005.pc_processa_reg_pendente
  -- gera lancamento por cooperativa na CRAPLCM
  -- caso ocorra diferenca gera lançammento contábil
  -- gera relatório
  PROCEDURE pc_lancamentos_singulares(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2);

  -- faz lançamento na craplcm
  PROCEDURE pc_gerar_lcto_singulares(pr_cdcooper     IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta     IN craplcm.nrdconta%TYPE
                                    ,pr_dtmvtolt     IN craplcm.dtmvtolt%TYPE
                                    ,pr_vllancamento IN craplcm.vllanmto%TYPE
                                    ,pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic    OUT VARCHAR2);


  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_arquivos(pr_dtinicio IN VARCHAR2               --> Data inicial da consulta
                             ,pr_dtfinal  IN VARCHAR2               --> Data final da consulta
                             ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_contas(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_cddregio IN crapreg.cddregio%TYPE  --> Codigo da regional
                           ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                           ,pr_dtinicio IN VARCHAR2               --> Data inicial do lancamento da consulta
                           ,pr_dtfinal  IN VARCHAR2               --> Data final do lancamento da consulta
                           ,pr_dtiniarq IN VARCHAR2               --> Data inicial do arquivo da consulta
                           ,pr_dtfimarq IN VARCHAR2               --> Data final do arquivo da consulta
                           ,pr_insituac IN tbdomic_arq_lancto_cartoes.insituacao%TYPE --> Situacao do registro
                           ,pr_tplancto IN tbdomic_arq_lancto_cartoes.tplancamento%TYPE --> Tipo de lancamento
                           ,pr_nmarquiv IN tbdomic_arq_lancto_cartoes.nmarquivo%TYPE --> Nome do arquivo
                           ,pr_insaida  IN PLS_INTEGER            --> Indicador de saida dos dados (1-Xml, 2-Arquivo CSV)
                           ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                           ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para retornar as regionais para a tela CONSLC
  PROCEDURE pc_lista_regional(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da regional
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE processa_arquivo_erro(pr_retxml    IN OUT NOCOPY XMLType   --> Nome do arquivo
                                 ,pr_dscritic   IN OUT VARCHAR2) ;

  -- Retorna o valor da TAG do XML
  FUNCTION fn_busca_valor(pr_dslinha  IN VARCHAR2
                         ,pr_dscampo  IN VARCHAR2
                         ,pr_indcampo IN VARCHAR2
                         ,pr_tppesqu  IN VARCHAR2 DEFAULT null -- Pesquisa especial para os arquivos *_RET (NULiquid CodErro)
                         )        RETURN VARCHAR2;

  PROCEDURE lista_arquivos (pnm_diretorio IN VARCHAR2);

  PROCEDURE pc_insere_msg_domicilio (pr_vlrlancto     IN NUMBER
                                    ,pr_cnpjliqdant   IN VARCHAR2
                                    ,pr_dscritic      OUT VARCHAR2);

  FUNCTION fn_valida_liquid_antecipacao (pr_vlrlancto     IN NUMBER
                                        ,pr_cnpjliqdant   IN VARCHAR2
                                        ,pr_dtreferencia  IN DATE
                                        ,pr_tpformatransf IN VARCHAR2
                                        ,pr_idatualiza    IN VARCHAR2
                                        ) RETURN VARCHAR2;

  PROCEDURE pc_verif_arq_antecip_nproc (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_verif_arq_nao_enviados (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2);

  PROCEDURE teste2 (pr_cmd    IN VARCHAR2);
  
END CCRD0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0006 AS

  -- Rotina para o processamento do dos arquivos de domicilio bancario
  PROCEDURE pc_executa_processo(pr_dtprocessoexec IN DATE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2)  IS

    -- Cursor sobre a tabela de feriados
    CURSOR cr_crapfer IS
      SELECT 1
        FROM crapfer
       WHERE dtferiad = trunc(SYSDATE);
    rw_crapfer cr_crapfer%ROWTYPE;

    -- Verifica se alguma cooperativa esta em processo noturno
    CURSOR cr_crapdat IS
      SELECT 1
        FROM crapdat
       WHERE inproces <> 1; -- Diferente de processo normal
    rw_crapdat cr_crapdat%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis gerais
    vr_para          VARCHAR2(100);
    vr_assunto       VARCHAR2(200);
    vr_mensagem      VARCHAR2(32000);

    vr_cdprogra             VARCHAR2(40) := 'PC_EXECUTA_PROCESSO';
    vr_nomdojob             VARCHAR2(40) := 'JBDOMIC_PROCESSA_ARQ_SILOC';
    vr_flgerlog             BOOLEAN := FALSE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar geração de log de execução dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;

    BEGIN

    -- Recebe a data enviada por parâmetro
    vr_dtprocessoexec := pr_dtprocessoexec;

    -- Se for um feriado, nao deve executar o fonte
    OPEN cr_crapfer;
    FETCH cr_crapfer INTO rw_crapfer;
    IF cr_crapfer%FOUND THEN
      CLOSE cr_crapfer;
      RETURN; -- Encerra o programa;
    END IF;
    CLOSE cr_crapfer;

    -- Verifica se alguma cooperativa esta em processo noturno
    OPEN cr_crapdat;
    FETCH cr_crapdat INTO rw_crapdat;
    IF cr_crapdat%FOUND THEN
      CLOSE cr_crapdat;
      RETURN; -- Encerra o programa;
    END IF;
    CLOSE cr_crapdat;

    -- Inicio processo completo de carga e geração do domicilio bancario
    -- *****************************************************************
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I');

    -- executa o processo CCRD0006.efetiva_agendamento
    vr_horini_23_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_23_1CICL'),1,5);
    vr_horfim_23_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_23_1CICL'),7);
    vr_horini_23_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_23_2CICL'),1,5);
    vr_horfim_23_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_23_2CICL'),7);
    vr_horini_25_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_25_1CICL'),1,5);
    vr_horfim_25_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_25_1CICL'),7);
    vr_horini_25_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_25_2CICL'),1,5);
    vr_horfim_25_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_25_2CICL'),7);
    vr_horini_33       := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_33'),1,5);
    vr_horfim_33       := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_33'),7);
    vr_horini_efetiva_agend := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_EFET_AGEND'),1,5);
    vr_horfim_efetiva_agend := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_EFET_AGEND'),7);
    vr_horini_rec_25_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_REC_25_1CICL'),1,5);
    vr_horfim_rec_25_1cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_REC_25_1CICL'),7);
    vr_horini_rec_25_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_REC_25_2CICL'),1,5);
    vr_horfim_rec_25_2cicl := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_REC_25_2CICL'),7);
    var_dt_ult_envio_email_slc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'DATA_ULT_ENVIO_EMAIL_SLC');
    vr_horini_33_cancel := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_33_CANCEL'),1,5);
    vr_horfim_33_cancel := substr(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'HORARIO_SLC_33_CANCEL'),7);
    vr_database_name   := GENE0001.fn_database_name;


    if sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_efetiva_agend,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_efetiva_agend,'ddmmyyyyhh24:mi') THEN
      CCRD0006.pc_efetiva_agendamentos (pr_dtprocesso => vr_dtprocessoexec
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
    END IF;

    -- executa o processo CCRD0006.pc_leitura_arquivo_xml
    CCRD0006.pc_leitura_arquivos_xml(pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- executa o processo CCRD0006.pr_processa_reg_pendentes
    CCRD0006.pc_processa_reg_pendentes (pr_dtprocesso => vr_dtprocessoexec
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;

    -- executa o processo CCRD0006.pr_efetiva_reg_pendentes
    CCRD0006.pc_efetiva_reg_pendentes (pr_dtprocesso => vr_dtprocessoexec
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    
    -- executa o processo CCRD0006.gera_arquivo_23
    if sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_23_1cicl,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_23_1cicl,'ddmmyyyyhh24:mi')
    or sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_23_2cicl,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_23_2cicl,'ddmmyyyyhh24:mi') THEN
      CCRD0006.gera_arquivo_xml_23(pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
    END IF;
    
    -- executa o processo CCRD0006.gera_arquivo_25
    if sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_25_1cicl,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_1cicl,'ddmmyyyyhh24:mi')
    or sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_25_2cicl,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_2cicl,'ddmmyyyyhh24:mi') THEN
      CCRD0006.gera_arquivo_xml_25(pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
    END IF;

    -- executa o processo CCRD0006.gera_arquivo_33
    if sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_33,'ddmmyyyyhh24:mi')
               and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_33,'ddmmyyyyhh24:mi') then
      CCRD0006.gera_arquivo_xml_33(pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Verifica arquivos de antecipação não processados há mais de 1 hora
    pc_verif_arq_antecip_nproc(pr_cdcritic    => vr_cdcritic
                              ,pr_dscritic    => vr_dscritic);

    IF vr_dscritic is not null then
      RAISE vr_exc_saida;
    END IF;
    
    IF sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_23_2cicl,'ddmmyyyyhh24:mi') AND 
       sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_2cicl,'ddmmyyyyhh24:mi') AND
       sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_33,'ddmmyyyyhh24:mi') THEN
       IF trunc(sysdate) > to_date(nvl(var_dt_ult_envio_email_slc,'01/01/0001'),'DD/MM/YYYY') THEN
          pc_verif_arq_nao_enviados(pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);

          IF vr_dscritic is not null then
            RAISE vr_exc_saida;
          END IF;
       END IF;
    END IF;

    -- Gera log de arquivo processado
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                  ,pr_ind_tipo_log => 1 -- Aviso
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                   || 'Processado com sucesso as rotinas do Domicílio Bancário;'
                                  ,pr_nmarqlog => 'CONLDB');


    ------------ Fim do processo de leitura dos arquivos

    -- Efetua gravacao dos registros
    COMMIT;

    -- Log de fim da execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

    -- Efetua gravacao dos registros
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
      -- Enviar email em caso de erro
      vr_para     := 'mauricio.cardoso@mouts.info';
      vr_assunto  := 'Erro execução CCRD0006';
      vr_mensagem := 'Erro na execução CCRD0006: '||pr_dscritic;
      pc_envia_email(pr_cdcooper   => 1
                    ,pr_dspara     => vr_para
                    ,pr_dsassunto  => vr_assunto
                    ,pr_dstexto    => vr_mensagem
                    ,pr_dscritic   => vr_dscritic);
      raise_application_error(-20001, 'Erro na execução CCRD0006: '||pr_dscritic);
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
      -- Enviar email em caso de erro
      vr_para     := 'mauricio.cardoso@mouts.info';
      vr_assunto  := 'Erro execução CCRD0006';
      vr_mensagem := 'Erro na execução CCRD0006: '||pr_dscritic;
      pc_envia_email(pr_cdcooper   => 1
                    ,pr_dspara     => vr_para
                    ,pr_dsassunto  => vr_assunto
                    ,pr_dstexto    => vr_mensagem
                    ,pr_dscritic   => vr_dscritic);
      raise_application_error(-20001, 'Erro na execução CCRD0006: '||pr_dscritic);
  END;

  PROCEDURE pc_leitura_arquivos_xml (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT VARCHAR2)  IS

    vr_dsdiretorio     VARCHAR2(100);
    vr_listaarq        VARCHAR2(32000);     --> Lista de arquivos

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

-- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp       GENE0002.typ_split;

    -- PL/Table que vai armazenar os linhas do arquivo XML
    wpr_table_of       GENE0002.typ_tab_tabela;


    vr_indice          INTEGER;

    wpr_retxml         XMLTYPE;
    vr_ok_nok          VARCHAR2(10);
    vr_arquivo         VARCHAR2(1000);
    vr_final           VARCHAR2(100);
    vr_tipo_saida      VARCHAR2(100);
    vr_arquivo_erro    NUMBER:=0;
    vr_idcampo         VARCHAR2(1000);
    vr_nmarqtemp       VARCHAR2(1000);
    -- Tratamento de erros
    vr_exc_saida       EXCEPTION;
    vr_dirbin          VARCHAR2(200);
  BEGIN

    -- Busca o diretorio onde estao os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO_SLC');
    IF substr(vr_dsdiretorio,length(vr_dsdiretorio)) != '/' then
      vr_dsdiretorio := vr_dsdiretorio ||'/'||'recebe';
    ELSE
      vr_dsdiretorio := vr_dsdiretorio ||'recebe';
    END IF;

    IF vr_database_name = 'AYLLOSD' THEN
      vr_dsdiretorio := '/usr/sistemas/SLC/recebe';
    END IF;

    -- Mover o arquivo processado para a pasta "processados"
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdiretorio||'/*_PRO.XML /usr/sistemas/SLC/recebidos',
                                pr_typ_saida   => vr_tipo_saida,
                                pr_des_saida   => vr_dscritic);
    -- Testa erro
    IF vr_tipo_saida = 'ERR' THEN
      -- Gera log de arquivo com erro
      --        vr_cdcritic := 0;
      --        RAISE vr_exc_saida;
      NULL;
    END IF;

    -- Listar arquivos
    gene0001.pc_lista_arquivos( pr_path     => vr_dsdiretorio
                               ,pr_pesq     => '%.XML'
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => vr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF vr_dscritic IS NOT NULL THEN
      -- RAISE vr_exc_saida;
       NULL;
    END  IF;

      -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN

      --Carregar a lista de arquivos txt na pl/table
      vr_tab_arqtmp := GENE0002.fn_quebra_string(pr_string => vr_listaarq);

      -- Leitura da PL/Table e processamento dos arquivos
      vr_indice := vr_tab_arqtmp.first;

      while vr_indice IS NOT NULL loop
        -- Busca o nome do arquivo a processar
        vr_arquivo := substr(vr_tab_arqtmp(vr_indice),1,7);

        -- Inserindo quebra de linha no arquivo e gerando arquivo temporario
        --dbms_output.put_line('Antes do cat: ' ||to_char(sysdate,'DDMMYYYY HH24:MI:SS'));

        -- Copia o arquivo XML antes de formatar
        vr_nmarqtemp := to_char(sysdate,'yyyymmddhh24miss');
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdiretorio||'/'||vr_tab_arqtmp(vr_indice)||
                                                        ' '||vr_dsdiretorio||'/'||vr_tab_arqtmp(vr_indice)||
                                                        '_'||vr_nmarqtemp||'_antes',
                                    pr_typ_saida   => vr_tipo_saida,
                                    pr_des_saida   => vr_dscritic);
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          -- Gera log de arquivo com erro
          NULL;
        END IF;
        -- Formatar o arquivo XML
        vr_dirbin := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'ROOT_CECRED_BIN');
        gene0001.pc_OScommand_Shell(pr_des_comando => vr_dirbin||'formataXML.pl '||
                                                      vr_dsdiretorio||'/'||vr_tab_arqtmp(vr_indice),
                                    pr_typ_saida   => vr_tipo_saida,
                                    pr_des_saida   => vr_dscritic);
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          -- Gera log de arquivo com erro
          NULL;
        END IF;
        --dbms_output.put_line('Depois do mv: ' ||to_char(sysdate,'DDMMYYYY HH24:MI:SS'));

        -- Chama o procedimento que faz a leitura do arquivo

        -- Carrega o arquivo XML para uma tabela em memória
        GENE0002.pc_arquivo_para_table_of (vr_dsdiretorio||'/'||vr_tab_arqtmp(vr_indice)
                                          ,wpr_table_of
                                          ,vr_ok_nok
                                          ,vr_dscritic );

        vr_final := upper(substr(vr_tab_arqtmp(vr_indice),LENGTH(vr_tab_arqtmp(vr_indice))-6,3));

        vr_arquivo_erro := instr(vr_tab_arqtmp(vr_indice),'_ERR');
        IF vr_arquivo = 'ASLC022' THEN
           processa_arquivo_xml_22(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic  => vr_dscritic);
           -- Se ocorreu erro cancela o processo
           -- Se ocorreu erro cancela o processo
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC023' AND vr_final = 'RET' THEN
           -- EXECUTA ARQUIVO 23RET
           processa_arquivo_23RET(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC023' AND vr_final = 'ERR' THEN
           -- EXECUTA ARQUIVO 23ERR

           processa_arquivo_23ERR(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC024' then
           processa_arquivo_24(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                              ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC025' AND vr_final = 'RET' THEN
           -- EXECUTA ARQUIVO 23RET
           processa_arquivo_25RET(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC025' AND vr_final = 'ERR' THEN
           -- EXECUTA ARQUIVO 25ERR

           processa_arquivo_25ERR(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC032' then
           processa_arquivo_32(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                              ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              -- Gera log de arquivo com erro
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC033' AND vr_final = 'RET' THEN
           -- EXECUTA ARQUIVO 33RET
           processa_arquivo_33RET(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo = 'ASLC033' AND vr_final = 'ERR' THEN
           -- EXECUTA ARQUIVO 33ERR

           processa_arquivo_33ERR(pr_table_of  => wpr_table_of --> Tabela com os dados do arquivo XML
                                 ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        ELSIF vr_arquivo_erro > 0 THEN
           processa_arquivo_erro(pr_retxml    => wpr_retxml --> Nome do arquivo
                                ,pr_dscritic  => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
              -- Gera log de arquivo com erro
              vr_idcampo := 'Erro Geral';
              pc_gera_critica(pr_nomearq => vr_tab_arqtmp(vr_indice)
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              ROLLBACK;
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
           ELSE
              COMMIT;
           END  IF;
        END  IF;

        -- Mover o arquivo processado para a pasta "processados"
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdiretorio||'/'||vr_tab_arqtmp(vr_indice)||'* '||'/usr/sistemas/SLC/recebidos',
                                    pr_typ_saida   => vr_tipo_saida,
                                    pr_des_saida   => vr_dscritic);
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
              -- Gera log de arquivo com erro
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
              -- NULL;
        END IF;

        -- Vai para o proximo registro
        vr_indice := vr_tab_arqtmp.next(vr_indice);
      END LOOP;
    END  IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;

      -- Log de erro de execucao
      --pc_controla_log_batch(pr_dstiplog => 'E',
      --                      pr_dscritic => pr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

      -- Log de erro de execucao
      --pc_controla_log_batch(pr_dstiplog => 'E',
      --                      pr_dscritic => pr_dscritic);

  END pc_leitura_arquivos_xml;

  PROCEDURE processa_arquivo_xml_22(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                   ,pr_dscritic   OUT VARCHAR2) IS
     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
     vr_nomarq              VARCHAR2(80);
     vr_NumCtrlEmis         VARCHAR2(80);
     vr_NumCtrlDestOr       VARCHAR2(20);
     vr_ISPBEmissor         VARCHAR2(08);
     vr_ISPBDestinatario    VARCHAR2(08);
     vr_DtHrArq             VARCHAR2(19);
     vr_DtRef               VARCHAR2(10);

     vr_idarquivo           NUMBER;

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_LANCTO
     vr_IdentdPartPrincipal VARCHAR2(8);
     vr_IdentdPartAdmtd     VARCHAR2(8);
     vr_CNPJBaseCreddr      VARCHAR2(8);
     vr_CNPJCreddr          NUMBER(14);
     vr_ISPBIFDevdr         VARCHAR2(8);
     vr_ISPBIFCredr         VARCHAR2(8);
     vr_AgCreddr            NUMBER(4);
     vr_CtCreddr            NUMBER(13);
     vr_NomCreddr            VARCHAR2(80);

     vr_idlancto            NUMBER;

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_CENTRALIZA
     vr_TpPessoaCentrlz     VARCHAR2(01);
     vr_CNPJ_CPFCentrlz     NUMBER(14);
     vr_CodCentrlz          VARCHAR2(25);
     vr_TpCt                VARCHAR2(02);
     vr_CtPgtoCentrlz       NUMBER(20);
     vr_AgCentrlz           NUMBER(13);
     vr_CtCentrlz           NUMBER(13);

     vr_idcentraliza        NUMBER;

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_PDV
     vr_NULiquid               VARCHAR2(21);
     vr_ISPBIFLiquidPontoVenda VARCHAR2(08);
     vr_CodPontoVenda          VARCHAR2(25);
     vr_NomePontoVenda         VARCHAR2(80);
     vr_TpPessoaPontoVenda     VARCHAR2(01);
     vr_CNPJ_CPFPontoVenda     NUMBER(14);
     vr_CodInstitdrArrajPgto   VARCHAR2(3);
     vr_TpProdLiquidCred       NUMBER(02) ;
     vr_IndrFormaTransf        VARCHAR2(01);
     vr_CodMoeda               NUMBER(03);
     vr_DtPgto                 VARCHAR2(10);
     vr_VlrPgto                NUMBER(19,2);
     vr_DtHrManut              VARCHAR2(19);
     vr_codocorc               VARCHAR2(2) ;
     vr_numctrlifacto          VARCHAR2(20);
     vr_numctrlcipaceito       VARCHAR2(20);
     vr_idpdv                  NUMBER;

     vr_dscritic               VARCHAR2(3200);
     vr_contador               PLS_INTEGER;
     vr_contador_lqd           PLS_INTEGER;
     vr_contador_pve           PLS_INTEGER;
     vr_contador_ctz           PLS_INTEGER;
     vr_idcampo                VARCHAR2(1000);
     vr_executado              VARCHAR2(01);
     vr_iderro                 NUMBER(01):=0;
     w_idloop                  NUMBER;
     w_dscampo                 VARCHAR2(100);
     w_indice_cab              NUMBER;
     w_indice                  NUMBER;
     vr_exc_saida              EXCEPTION;

  BEGIN

    -- Inicializa o contador de consultas
    vr_contador := 1;
    w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
    w_indice     := 1;                       -- Posiciona na primeira linha do arquivo XML

    LOOP

      vr_nomarq            := NULL;
      vr_NumCtrlEmis       := NULL;
      vr_NumCtrlDestOr     := NULL;
      vr_ISPBEmissor       := NULL;
      vr_ISPBDestinatario  := NULL;
      vr_DtHrArq           := NULL;
      vr_DtRef             := NULL;
      vr_idcampo           := null;
      vr_iderro            := 0;
------------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
      BEGIN
        -- Verifica se existe dados na consulta
        IF pr_table_of.count() = 0 THEN
          EXIT;
        END IF;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        --Busca os campos do detalhe da consulta
        vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
        IF vr_nomarq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        -- valida se o arquivo com esse nome já foi processado.
        vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

        IF vr_executado = 'S' THEN
           EXIT;
        END  IF;

        vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
        IF vr_NumCtrlEmis IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlEmis';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
        IF vr_NumCtrlDestOr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlDestOr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
        IF vr_ISPBEmissor IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBEmissor';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
        IF vr_ISPBDestinatario IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBDestinatario';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
        IF vr_DtHrArq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
        IF vr_DtRef IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtRef';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

      EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
           RAISE;
      END;

      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao  (pr_nomarq           => vr_nomarq,
                                 pr_NumCtrlEmis      => vr_NumCtrlEmis,
                                 pr_NumCtrlDestOr    => vr_NumCtrlDestOr,
                                 pr_ISPBEmissor      => vr_ISPBEmissor,
                                 pr_ISPBDestinatario => vr_ISPBDestinatario,
                                 pr_DtHrArq          => vr_DtHrArq,
                                 pr_DtRef            => vr_DtRef,
                                 pr_idarquivo        => vr_idarquivo,
                                 pr_iderro           => vr_iderro,
                                 pr_dscritic         => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      ------ BUSCA DADOS DA TABELA TBDOMIC_LIQTRANS_LANCTO
      vr_contador_lqd := 1;

      -- Posicionar o arquivo no inicio do arquivo XML
      BEGIN
        w_idloop := 0; -- controle de execução do loop

        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<SISARQ';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            w_idloop := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      LOOP

        vr_IdentdPartPrincipal  := NULL;
        vr_IdentdPartAdmtd      := NULL;
        vr_CNPJBaseCreddr       := NULL;
        vr_CNPJCreddr           := NULL;
        vr_ISPBIFDevdr          := NULL;
        vr_ISPBIFCredr          := NULL;
        vr_AgCreddr             := NULL;
        vr_CtCreddr             := NULL;
        vr_NomCreddr            := NULL;
        vr_iderro               := 0;

        -- Posiciona na TAG de início do bloco
        BEGIN
          w_idloop := 0; -- controle de execução do loop
          w_indice := w_indice + 1;
          w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC022_LiquidTranscCred','S');
          IF w_dscampo IS NULL THEN
            vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
            vr_idcampo := '<Grupo_ASLC022_LiquidTranscCred';
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => vr_idcampo
                           ,pr_dscritic => vr_dscritic);
            vr_iderro := 1;
          ELSE
            IF w_dscampo <> 'OK' THEN
              w_idloop := 1;
              w_indice := w_indice - 1;
            END IF;
          END IF;
        END;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        vr_IdentdPartPrincipal := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartPrincipal','S');
        IF vr_IdentdPartPrincipal IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartPrincipal';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;
        -- Verifica se existe dados na consulta
        IF NVL(vr_IdentdPartPrincipal,0) = 0 THEN
           EXIT;
        END  IF;

        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_CNPJBaseCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJBaseCreddr','S');
        IF vr_CNPJBaseCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJBaseCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_CNPJCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJCreddr','S');
        IF vr_CNPJCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_ISPBIFDevdr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFDevdr','S');
        IF vr_ISPBIFDevdr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFDevdr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_ISPBIFCredr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFCredr','S');
        IF vr_ISPBIFCredr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFCredr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_AgCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCreddr','S');
        IF vr_AgCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'AgCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_CtCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCreddr','S');
        IF vr_CtCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CtCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_NomCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomCreddr','S');
        IF vr_NomCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
        insere_liquidacao_transacao (pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                    ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                    ,pr_CNPJBaseCreddr      => vr_CNPJBaseCreddr
                                    ,pr_CNPJCreddr          => vr_CNPJCreddr
                                    ,pr_ISPBIFDevdr         => vr_ISPBIFDevdr
                                    ,pr_ISPBIFCredr         => vr_ISPBIFCredr
                                    ,pr_AgCreddr            => vr_AgCreddr
                                    ,pr_CtCreddr            => vr_CtCreddr
                                    ,pr_NomCreddr           => vr_NomCreddr
                                    ,pr_idarquivo           => vr_idarquivo
                                    ,pr_idlancto            => vr_idlancto
                                    ,pr_iderro              => vr_iderro
                                    ,pr_dscritic            => vr_dscritic
                                    );
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_CENTRALIZA
        vr_contador_ctz := 1;

        LOOP

          vr_TpPessoaCentrlz     := null;
          vr_CNPJ_CPFCentrlz     := null;
          vr_CodCentrlz          := null;
          vr_TpCt                := null;
          vr_CtPgtoCentrlz       := null;
          vr_AgCentrlz           := null;
          vr_CtCentrlz           := null;
          vr_iderro              := 0;

          -- Posiciona na TAG de final do bloco
          BEGIN
            w_idloop := 0; -- controle de execução do loop
            w_indice := w_indice + 1;
            w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC022_Centrlz','S');
            IF w_dscampo IS NULL THEN
              vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
              vr_idcampo := 'Grupo_ASLC022_Centrlz';
              pc_gera_critica(pr_nomearq => vr_nomarq
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              vr_iderro := 1;
            ELSE
              IF w_dscampo <> 'OK' THEN
                w_idloop := 1;
                w_indice := w_indice - 1;
              END IF;
            END IF;
          END;

          -- Controla a execução do loop
          IF w_idloop = 1 THEN
            w_idloop := 0;
            EXIT;
          END IF;

          vr_TpPessoaCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaCentrlz','S');
          IF vr_TpPessoaCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpPessoaCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_CNPJ_CPFCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFCentrlz','S');
          IF vr_CNPJ_CPFCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CNPJ_CPFCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          -- Verifica se existe dados na consulta
          IF nvl(vr_CNPJ_CPFCentrlz,0) = 0 THEN
             EXIT;
          END IF;

          vr_CodCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodCentrlz','S');
          IF vr_CodCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_TpCt := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpCt','S');
          IF vr_TpCt IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpCt';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_agcentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCentrlz','S');
          IF vr_agcentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'AgCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             EXIT;
          END  IF;

          vr_ctcentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCentrlz','S');
          IF vr_ctcentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CtCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             EXIT;
          END  IF;

          -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
          IF NVL(vr_iderro,0) = 1 THEN
             pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                        ,pr_dscritic  => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
                -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                NULL;
             END IF;
          END IF;

          -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
          insere_liq_trn_central( pr_TpPessoaCentrlz  => vr_TpPessoaCentrlz
                                 ,pr_CNPJ_CPFCentrlz  => vr_CNPJ_CPFCentrlz
                                 ,pr_CodCentrlz       => vr_CodCentrlz
                                 ,pr_TpCt             => vr_TpCt
                                 ,pr_CtPgtoCentrlz    => vr_CtPgtoCentrlz
                                 ,pr_AgCentrlz        => vr_AgCentrlz
                                 ,pr_CtCentrlz        => vr_CtCentrlz
                                 ,pr_idlancto         => vr_idlancto
                                 ,pr_idcentraliza     => vr_idcentraliza
                                 ,pr_dscritic         => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          vr_contador_pve := 1;

          -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_PDV
          LOOP
             vr_NULiquid                 := NULL;
             vr_ISPBIFLiquidPontoVenda   := NULL;
             vr_CodPontoVenda            := NULL;
             vr_NomePontoVenda           := NULL;
             vr_TpPessoaPontoVenda       := NULL;
             vr_CNPJ_CPFPontoVenda       := NULL;
             vr_CodInstitdrArrajPgto     := NULL;
             vr_TpProdLiquidCred         := NULL;
             vr_IndrFormaTransf          := NULL;
             vr_CodMoeda                 := NULL;
             vr_DtPgto                   := NULL;
             vr_VlrPgto                  := NULL;
             vr_DtHrManut                := NULL;
             vr_codocorc                 := NULL;
             vr_numctrlifacto            := NULL;
             vr_numctrlcipaceito         := NULL;
             vr_iderro                   := 0;

             -- Posiciona na TAG de início do bloco
             BEGIN
               w_idloop := 0; -- controle de execução do loop
               w_indice := w_indice + 1;
               w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC022_PontoVenda','S');
               IF w_dscampo IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'Grupo_ASLC022_PontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
               ELSE
                 IF w_dscampo <> 'OK' THEN
                   w_idloop := 1;
                   w_indice := w_indice - 1;
                 END IF;
               END IF;
             END;
             -- Controla a execução do loop
             IF w_idloop = 1 THEN
               w_idloop := 0;
               EXIT;
             END IF;

             vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
             IF vr_NULiquid IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'NULiquid';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             -- Verifica se existe dados na consulta
             IF nvl(vr_NULiquid,0) = 0 THEN
                EXIT;
             END  IF;

             vr_ISPBIFLiquidPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFLiquidPontoVenda','S');
             IF vr_ISPBIFLiquidPontoVenda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'ISPBIFLiquidPontoVenda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_CodPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodPontoVenda','S');
             IF vr_CodPontoVenda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'CodPontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_NomePontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomePontoVenda','S');
             IF vr_NomePontoVenda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'NomePontoVenda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_TpPessoaPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaPontoVenda','S');
             IF vr_TpPessoaPontoVenda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'TpPessoaPontoVenda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_CNPJ_CPFPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFPontoVenda','S');
             IF vr_CNPJ_CPFPontoVenda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'CNPJ_CPFPontoVenda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_CodInstitdrArrajPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodInstitdrArrajPgto','S');
             IF vr_CodInstitdrArrajPgto IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'CodInstitdrArrajPgto';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_TpProdLiquidCred := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpProdLiquidCred','S');
             IF vr_TpProdLiquidCred IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'TpProdLiquidCred';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_IndrFormaTransf := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IndrFormaTransf','S');
             IF vr_IndrFormaTransf IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'IndrFormaTransf';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_CodMoeda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodMoeda','S');
             IF vr_CodMoeda IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'CodMoeda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_DtPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtPgto','S');
             IF vr_DtPgto IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'DtPgto';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_VlrPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'VlrPgto','S');
             IF vr_VlrPgto IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'VlrPgto';
                pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
             IF vr_DtHrManut IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'DtHrManut';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
             END  IF;

             -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
             IF NVL(vr_iderro,0) = 1 THEN
                pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                           ,pr_dscritic  => vr_dscritic);
                IF vr_dscritic IS NOT NULL THEN
                   -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                   NULL;
                END IF;
              END IF;

             -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
             insere_liq_trn_cen_pve (pr_NULiquid                => vr_NULiquid
                                    ,pr_ISPBIFLiquidPontoVenda  => vr_ISPBIFLiquidPontoVenda
                                    ,pr_CodPontoVenda           => vr_CodPontoVenda
                                    ,pr_NomePontoVenda          => vr_NomePontoVenda
                                    ,pr_TpPessoaPontoVenda      => vr_TpPessoaPontoVenda
                                    ,pr_CNPJ_CPFPontoVenda      => vr_CNPJ_CPFPontoVenda
                                    ,pr_CodInstitdrArrajPgto    => vr_CodInstitdrArrajPgto
                                    ,pr_TpProdLiquidCred        => vr_TpProdLiquidCred
                                    ,pr_IndrFormaTransf         => vr_IndrFormaTransf
                                    ,pr_CodMoeda                => vr_CodMoeda
                                    ,pr_DtPgto                  => vr_DtPgto
                                    ,pr_VlrPgto                 => vr_VlrPgto
                                    ,pr_DtHrManut               => vr_DtHrManut
                                    ,pr_codocorc                => vr_codocorc
                                    ,pr_numctrlifacto           => vr_numctrlifacto
                                    ,pr_numctrlcipaceito        => vr_numctrlcipaceito
                                    ,pr_idcentraliza            => vr_idcentraliza
                                    ,pr_idpdv                   => vr_idpdv
                                    ,pr_dscritic                => vr_dscritic);

             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             vr_contador_pve := vr_contador_pve + 1;
             -- FIM TABELA   TBDOMIC_LIQ_TRN_CEN_PVE
          END LOOP;

         vr_contador_ctz := vr_contador_ctz + 1;
         -- FIM TABELA   TBDOMIC_LIQ_TRN_CENTRAL

         -- Posiciona na TAG de final do bloco
         BEGIN
           w_idloop := 0; -- controle de execução do loop
           w_indice := w_indice + 1;
           w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC022_Centrlz','S');
           IF w_dscampo IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := '/Grupo_ASLC022_Centrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
           ELSE
             IF w_dscampo <> 'OK' THEN
               w_idloop := 1;
               w_indice := w_indice - 1;
             END IF;
           END IF;
         END;
       END LOOP;

       vr_contador_lqd := vr_contador_lqd + 1;
       -- FIM TABELA   TBDOMIC_LIQTRANS_LANCTO

       -- Posiciona na TAG de final do bloco
       BEGIN
         w_idloop := 0; -- controle de execução do loop
         w_indice := w_indice + 1;
         w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC022_LiquidTranscCred','S');
         IF w_dscampo IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := '/Grupo_ASLC022_LiquidTranscCred';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
         ELSE
           IF w_dscampo <> 'OK' THEN
             w_idloop := 1;
             w_indice := w_indice - 1;
           END IF;
         END IF;
       END;
     END LOOP;

     vr_contador := vr_contador + 1;
     --FIM TABELA  TBDOMIC_LIQTRANS_ARQUIVO

     -- Posiciona na TAG de final do bloco
     BEGIN
       w_idloop := 0; -- controle de execução do loop
       w_indice := w_indice + 1;
       w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/SISARQ','S');
       IF w_dscampo IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := '/SISARQ';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
       ELSE
         IF w_dscampo <> 'OK' THEN
           w_idloop := 1;
           w_indice := w_indice - 1;
         ELSE
           w_idloop := 1;
         END IF;
       END IF;
     END;
    END LOOP;
    dbms_output.put_line('Número de linhas processadas do arquivo '||vr_nomarq||' = '||w_indice);

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar arquivo 22 '||SQLERRM;
  END processa_arquivo_xml_22;

  -- Rotina para buscar o conteudo do campo com base no xml enviado
  PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType    --> XML de retorno da operadora
                                   ,pr_nrcampo   IN VARCHAR2              --> Campo a ser buscado no XML
                                   ,pr_indcampo  IN VARCHAR2              --> Tipo de dado: S=String, D=Data, N=Numerico
                                   ,pr_retorno   OUT VARCHAR2             --> Retorno do campo do xml
                                   ,pr_dscritic  IN OUT VARCHAR2) IS      --> Texto de erro/critica encontrada

     vr_dscritic     VARCHAR2(32000);          --> descricao do erro
     vr_exc_saida    EXCEPTION;               --> Excecao prevista
     vr_tab_xml      gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML

  BEGIN
     -- Busca a informacao no XML
     gene0007.pc_itera_nodos(pr_xpath      => pr_nrcampo
                            ,pr_xml        => pr_retxml
                            ,pr_list_nodos => vr_tab_xml
                            ,pr_des_erro   => vr_dscritic);
     IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
     END  IF;
     -- Se encontrou mais de um registro, deve dar mensagem de erro
     IF vr_tab_xml.count > 1 THEN
        vr_dscritic := 'Mais de um registro XML encontrado.';
        RAISE vr_exc_saida;
     ELSIF vr_tab_xml.count = 1 THEN -- Se encontrou, retornar o texto
        IF pr_indcampo = 'D' THEN -- Se o tipo de dado for Data, transformar para data
           -- Se for tudo zeros, desconsiderar
           IF vr_tab_xml(0).tag IN ('00000000','0','')  THEN
              pr_retorno := NULL;
           ELSE
              pr_retorno := to_date(vr_tab_xml(0).tag,'yyyymmdd');
           END  IF;
        ELSE
           pr_retorno := replace(vr_tab_xml(0).tag,'.',',');
        END  IF;
     END  IF;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||vr_dscritic;
     WHEN OTHERS THEN
        pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||SQLERRM;
  END;

  PROCEDURE insere_arq_liq_transacao (pr_nomarq           IN VARCHAR2
                                     ,pr_NumCtrlEmis      IN VARCHAR2
                                     ,pr_NumCtrlDestOr    IN VARCHAR2
                                     ,pr_ISPBEmissor      IN VARCHAR2
                                     ,pr_ISPBDestinatario IN VARCHAR2
                                     ,pr_DtHrArq          IN VARCHAR2
                                     ,pr_DtRef            IN VARCHAR2
                                     ,pr_idarquivo        IN OUT NUMBER
                                     ,pr_iderro           IN NUMBER
                                     ,pr_dscritic         IN OUT VARCHAR2) IS

    vr_arquivo       varchar2(07) := null;
    vr_tparquivo     number;
  BEGIN

    vr_arquivo := substr(pr_nomarq,1,7);

    IF vr_arquivo IN ('ASLC022','ASLC023') THEN
       vr_tparquivo := 1; -- crédito
    ELSIF vr_arquivo IN ('ASLC024','ASLC025') THEN
       vr_tparquivo := 2; -- débito
    ELSE
       vr_tparquivo := 3; -- antecipacao
    END  IF;

    INSERT INTO TBDOMIC_LIQTRANS_ARQUIVO (idarquivo
                                         ,nmarquivo_origem
                                         ,tparquivo
                                         ,nrcontrole_emissor
                                         ,nrcontrole_dest_original
                                         ,nrispb_emissor
                                         ,nrispb_destinatario
                                         ,dharquivo_origem
                                         ,dtreferencia
                                         ,dhrecebimento)
                                  values (
                                          0   -- preenchido automaticamente sequence SEQDOMIC_LIQTRANS_ARQUIVO_ID
                                         ,pr_nomarq
                                         ,vr_tparquivo
                                         ,pr_NumCtrlEmis
                                         ,pr_NumCtrlDestOr
                                         ,pr_ISPBEmissor
                                         ,pr_ISPBDestinatario
                                         ,pr_DtHrArq
                                         ,pr_DtRef
                                         ,SYSDATE
                                         ) RETURNING idarquivo INTO pr_idarquivo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao inserir o arquivo '||pr_nomarq||'. '||SQLERRM;
      RETURN;

  END insere_arq_liq_transacao;

  PROCEDURE insere_liquidacao_transacao (pr_IdentdPartPrincipal IN VARCHAR2
                                        ,pr_IdentdPartAdmtd     IN VARCHAR2
                                        ,pr_CNPJBaseCreddr      IN VARCHAR2
                                        ,pr_CNPJCreddr          IN NUMBER
                                        ,pr_ISPBIFDevdr         IN VARCHAR2
                                        ,pr_ISPBIFCredr         IN VARCHAR2
                                        ,pr_AgCreddr            IN NUMBER
                                        ,pr_CtCreddr            IN NUMBER
                                        ,pr_NomCreddr           IN VARCHAR2
                                        ,pr_idarquivo           IN NUMBER
                                        ,pr_idlancto            IN OUT NUMBER
                                        ,pr_iderro              IN NUMBER
                                        ,pr_dscritic            IN OUT VARCHAR2) IS
  BEGIN

     insert into TBDOMIC_LIQTRANS_LANCTO(idlancto
                                        ,idarquivo
                                        ,nrcnpjbase_principal
                                        ,nrcnpjbase_administrado
                                        ,nrcnpj_credenciador
                                        ,nrispb_devedor
                                        ,nrispb_credor
                                        ,cdagencia_credenciador
                                        ,nrconta_credenciador
                                        ,nmcredenciador
                                        ,insituacao
                                        ,dserro
                                        ,dhinclusao
                                        ,dhprocessamento
                                        ,dhretorno
                                        ,insituacao_retorno
                                        ,dhconfirmacao_retorno)
                                 VALUES (0 -- preenchido automaticamente da sequence TRGDOMIC_LIQTRANS_LANCTO_ID
                                        ,pr_idarquivo
                                        ,pr_IdentdPartPrincipal
                                        ,pr_IdentdPartAdmtd
                                        ,pr_CNPJCreddr
                                        ,pr_ISPBIFDevdr
                                        ,pr_ISPBIFCredr
                                        ,pr_AgCreddr
                                        ,pr_CtCreddr
                                        ,pr_NomCreddr
                                        ,decode(pr_iderro,1,2,0) -- 0 pendente, 1 processado, 2 erro ????
                                        ,NULL
                                        ,SYSDATE
                                        ,NULL
                                        ,NULL
                                        ,NULL
                                        ,NULL) RETURNING idlancto INTO pr_idlancto;
  EXCEPTION
    WHEN OTHERS THEN
       pr_dscritic := 'Erro ao inserir o transação '||pr_idlancto||'. '||SQLERRM;
       RETURN;
  END insere_liquidacao_transacao;

  PROCEDURE insere_liq_trn_central(pr_TpPessoaCentrlz    IN VARCHAR2
                                  ,pr_CNPJ_CPFCentrlz    IN NUMBER
                                  ,pr_CodCentrlz         IN VARCHAR2
                                  ,pr_TpCt               IN VARCHAR2
                                  ,pr_CtPgtoCentrlz      IN NUMBER
                                  ,pr_AgCentrlz          IN NUMBER
                                  ,pr_CtCentrlz          IN NUMBER
                                  ,pr_idlancto           IN NUMBER
                                  ,pr_idcentraliza       IN OUT NUMBER
                                  ,pr_dscritic           IN OUT varchar2) IS
  BEGIN
     insert into TBDOMIC_LIQTRANS_CENTRALIZA(idcentraliza
                                            ,idlancto
                                            ,tppessoa_centraliza
                                            ,nrcnpjcpf_centraliza
                                            ,cdcentraliza
                                            ,tpconta
                                            ,cdagencia_centraliza
                                            ,nrcta_centraliza
                                            ,nrcta_pgto_centraliza)
                                     VALUES (0 -- preenchido automaticamente da sequence TRGDOMIC_LIQTRANS_CENTRALIZAID
                                            ,pr_idlancto
                                            ,pr_TpPessoaCentrlz
                                            ,pr_CNPJ_CPFCentrlz
                                            ,pr_CodCentrlz
                                            ,pr_TpCt
                                            ,pr_AgCentrlz
                                            ,pr_CtCentrlz
                                            ,pr_CtPgtoCentrlz
                                            )  RETURNING idcentraliza INTO pr_idcentraliza;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir a transação centralizadora '||pr_idcentraliza||'. '||SQLERRM;
        RETURN;
  END;

  PROCEDURE insere_liq_trn_cen_pve (pr_NULiquid                IN VARCHAR2
                                   ,pr_ISPBIFLiquidPontoVenda  IN VARCHAR2
                                   ,pr_CodPontoVenda           IN VARCHAR2
                                   ,pr_NomePontoVenda          IN VARCHAR2
                                   ,pr_TpPessoaPontoVenda      IN VARCHAR2
                                   ,pr_CNPJ_CPFPontoVenda      IN NUMBER
                                   ,pr_CodInstitdrArrajPgto    IN VARCHAR2
                                   ,pr_TpProdLiquidCred        IN NUMBER
                                   ,pr_IndrFormaTransf         IN VARCHAR2
                                   ,pr_CodMoeda                IN NUMBER
                                   ,pr_DtPgto                  IN VARCHAR2
                                   ,pr_VlrPgto                 IN NUMBER
                                   ,pr_DtHrManut               IN VARCHAR2
                                   ,pr_codocorc                IN VARCHAR2
                                   ,pr_numctrlifacto           IN VARCHAR2
                                   ,pr_numctrlcipaceito        IN VARCHAR2
                                   ,pr_idcentraliza            IN NUMBER
                                   ,pr_idpdv                   IN OUT NUMBER
                                   ,pr_dscritic                IN OUT VARCHAR2) IS
  BEGIN
       insert into TBDOMIC_LIQTRANS_PDV(idpdv
                                       ,idcentraliza
                                       ,nrliquidacao
                                       ,nrispb_liquid_pdv
                                       ,cdpdv
                                       ,nmpdv
                                       ,tppessoa_pdv
                                       ,nrcnpjcpf_pdv
                                       ,cdinst_arranjo_pagamento
                                       ,tpproduto_credito
                                       ,tpforma_transf
                                       ,cdmoeda
                                       ,dtpagamento
                                       ,vlpagamento
                                       ,dhmanutencao
                                       ,cdocorrencia
                                       ,nrcontrole_if
                                       ,nrcontrole_cip
                                       ,dhretorno
                                       ,cdocorrencia_retorno)
                                VALUES (0   --  preenchido automaticamente da sequence TRGDOMIC_LIQTRANS_PDV_ID
                                       ,pr_idcentraliza
                                       ,pr_NULiquid
                                       ,pr_ISPBIFLiquidPontoVenda
                                       ,pr_CodPontoVenda
                                       ,pr_NomePontoVenda
                                       ,pr_TpPessoaPontoVenda
                                       ,pr_CNPJ_CPFPontoVenda
                                       ,pr_CodInstitdrArrajPgto
                                       ,pr_TpProdLiquidCred
                                       ,pr_IndrFormaTransf
                                       ,pr_CodMoeda
                                       ,pr_DtPgto
                                       ,pr_VlrPgto
                                       ,to_date(replace(pr_DtHrManut,'T',' '),'YYYY-MM-DD HH24:MI:SS')
                                       ,pr_codocorc
                                       ,pr_numctrlifacto
                                       ,pr_numctrlcipaceito
                                       ,NULL
                                       ,pr_codocorc )  RETURNING idpdv INTO pr_idpdv ;
    EXCEPTION
      WHEN OTHERS THEN
         pr_dscritic := 'Erro ao inserir o transação PDV '||pr_idcentraliza||'. '||SQLERRM;
         RETURN;
  END;


  FUNCTION valida_arquivo_processado (pr_nomarq  IN VARCHAR2) RETURN varchar2 IS -- 'S' ou 'N'

    CURSOR c1 IS
       SELECT 1
         FROM tbdomic_liqtrans_arquivo
        WHERE nmarquivo_origem = pr_Nomarq;
        r1 c1%ROWTYPE;
  BEGIN

    OPEN c1;
    FETCH c1 INTO r1;

    IF c1%NOTFOUND THEN
       RETURN ('N');
    END  IF;

    RETURN('S');

  END valida_arquivo_processado;

  PROCEDURE gera_arquivo_xml_23 (pr_dscritic IN OUT VARCHAR2) IS

    CURSOR c0 IS
      SELECT d.idarquivo
            ,d.nrispb_emissor
            ,nrcontrole_emissor
            ,nrcontrole_dest_original
            ,nrispb_destinatario
            ,d.dtreferencia
        FROM tbdomic_liqtrans_arquivo d
       WHERE SUBSTR(d.nmarquivo_origem,1,7) = 'ASLC022'
         AND nmarquivo_gerado IS NULL
         AND EXISTS
             (SELECT 'S'
                FROM tbdomic_liqtrans_lancto tll
                    ,tbdomic_liqtrans_centraliza tlc
               WHERE tll.idlancto = tlc.idlancto
                 AND tll.idarquivo = d.idarquivo
                 AND tll.insituacao in (1));

    CURSOR c1 (pr_idarquivo IN NUMBER) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.idpdv
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
      WHERE tll.idlancto = tlc.idlancto
        AND tlc.idcentraliza = tlp.idcentraliza
        AND tll.idarquivo = pr_idarquivo
        AND tll.insituacao in (1); -- os pendentes e os com erro

   CURSOR c2 IS
     SELECT TO_NUMBER(LPAD(fn_sequence (pr_nmtabela => 'tbdomic_liqtrans_arquivo'
                                       ,pr_nmdcampo => 'TPARQUIVO'
                                       ,pr_dsdchave => 1),4,'0'))  seq
       FROM dual;
     r2 c2%ROWTYPE;

    vr_dscritic    VARCHAR2(32000);
    --vr_contador    PLS_INTEGER := 0;
    vr_caminho     VARCHAR2(1000);
    vr_arquivo     VARCHAR2(1000);
    vr_retxml      XMLTYPE;
    vr_nrsequencia NUMBER;
    vr_clob        CLOB;
    vr_xml_temp    VARCHAR2(32726) := '';

    vr_exc_saida         EXCEPTION;
    vr_nomarq       VARCHAR2(1000);
  BEGIN

    FOR r0 IN c0 LOOP

      -- busca a sequencia para o nome do arquivo
      OPEN c2;
      FETCH c2 INTO r2;
      vr_nrsequencia := r2.seq;
      CLOSE c2;

      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?>');

      vr_nomarq := 'ASLC023_'||r0.nrispb_destinatario||'_'||to_char(sysdate,'YYYYMMDD')||'_'||lpad(vr_nrsequencia,5,'0');
      vr_arquivo :=  vr_nomarq ||'.XML';

      -- Cria o no inicial do XML
/*      vr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><ASLC023/>');


      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC023',pr_posicao => NULL, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC023',pr_posicao => 0, pr_tag_nova => 'BCARQ', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NomArq', pr_tag_cont => vr_arquivo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlEmis', pr_tag_cont => r0.nrcontrole_emissor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlDestOr', pr_tag_cont => r0.nrcontrole_dest_original, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'ISPBDestinatario', pr_tag_cont => r0.nrispb_destinatario, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtHrArq', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd hh24:mi:ss'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtRef', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd'), pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC023',pr_posicao => 0, pr_tag_nova => 'SISARQ', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'SISARQ',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
*/
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<ASLCDOC xmlns="http://www.cip-bancos.org.br/ARQ/ASLC023.xsd">'||
                                                   '<BCARQ>'||
                                                   '<NomArq>'     || vr_nomarq     ||'</NomArq>'||
                                                   '<NumCtrlEmis>'    || to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r0.idarquivo,12,'0')    ||'</NumCtrlEmis>'||
                                           --        '<NumCtrlDestOr>'    || r0.nrcontrole_dest_original  ||'</NumCtrlDestOr>'||
                                                   '<ISPBEmissor>' || r0.nrispb_destinatario ||'</ISPBEmissor>'||
                                                   '<ISPBDestinatario>' || r0.nrispb_emissor ||'</ISPBDestinatario>'||
                                                   '<DtHrArq>'   || to_char(SYSDATE,'yyyy-mm-dd')||'T'||to_char(SYSDATE,'hh24:mi:ss')   ||'</DtHrArq>'||
                                                   '<DtRef>'       || to_char(SYSDATE,'yyyy-mm-dd')     ||'</DtRef>'||
                                                   '</BCARQ>'||
                                                   '<SISARQ>'||
                                                   '<ASLC023>');

      -- Efetua loop sobre os registros do arquivo 023
      FOR r1 IN c1 (pr_idarquivo => r0.idarquivo) LOOP

/*        -- Gera os detalhes
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'SISARQ',pr_posicao => vr_contador, pr_tag_nova => 'Grupo_ASLC023_LiquidTranscCred', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartPrincipal', pr_tag_cont => to_char(r1.nrcnpjbase_principal), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartAdmtd', pr_tag_cont => to_char(r1.nrcnpjbase_administrado), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => 'NumCtrlIF', pr_tag_cont => to_char(r1.nrispb_devedor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => 'NULiquid', pr_tag_cont => to_char(r1.nrliquidacao), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC023_LiquidTranscCred',   pr_posicao => vr_contador, pr_tag_nova => 'CodOcorc', pr_tag_cont => to_char(r1.cdocorrencia), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;*/

      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     =>  '<Grupo_ASLC023_LiquidTranscCred>'||
                                                   '<IdentdPartPrincipal>'     || to_char(r1.nrcnpjbase_principal)     ||'</IdentdPartPrincipal>'||
                                                   '<IdentdPartAdmtd>'    || to_char(r1.nrcnpjbase_administrado)    ||'</IdentdPartAdmtd>'||
                                                   '<NumCtrlIF>'    || to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r1.idpdv,12,'0')  ||'</NumCtrlIF>'||
                                                   '<NULiquid>' || to_char(r1.nrliquidacao) ||'</NULiquid>'||
                                                   '<CodOcorc>'   || to_char(r1.cdocorrencia)  ||'</CodOcorc>'||
                                                   '</Grupo_ASLC023_LiquidTranscCred>');
      END LOOP;

      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</ASLC023></SISARQ></ASLCDOC>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      -- vr_retxml := xmltype(vr_clob);
      BEGIN
        vr_caminho := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO_SLC');
        IF substr(vr_caminho, length(vr_caminho)) != '/' then
          vr_caminho := vr_caminho ||'/'||'envia';
        ELSE
          vr_caminho := vr_caminho ||'envia';
        END IF;

        IF vr_database_name = 'AYLLOSD' THEN
          vr_caminho := '/usr/sistemas/SLC/envia';
        END IF;
        --vr_caminho := '/usr/sistemas/SLC/envia';
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao ler o caminho cadastrado na gene0001.fn_param_sistema'||SQLERRM;
           pc_gera_critica(pr_nomearq => vr_arquivo
                          ,pr_idcampo => 'Caminho'
                          ,pr_dscritic => vr_dscritic);
           RAISE vr_exc_saida;
      END;

      -- gera o arquivo no diretório padrão
      GENE0002.pc_XML_para_arquivo (pr_XML       => vr_clob    --> Instância do CLOB Type
                                   ,pr_caminho   => vr_caminho --> Diretório para saída
                                   ,pr_arquivo   => vr_arquivo --> Nome do arquivo de saída
                                   ,pr_des_erro  => vr_dscritic );
      IF vr_dscritic IS NOT NULL THEN
         pc_gera_critica(pr_nomearq => vr_arquivo
                        ,pr_idcampo => 'XML_Arquivo'
                        ,pr_dscritic => vr_dscritic);
         RAISE vr_exc_saida;
      END  IF;

      -- Atualiza arquivo origem com o nome do arquivo gerado.
      atualiza_nome_arquivo (pr_idtipoarquivo    => 1
                            ,pr_nomearqorigem    => r0.idarquivo
                            ,pr_nomearqatualizar => vr_nomarq
                            ,pr_dscritic         => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         pc_gera_critica(pr_nomearq => vr_arquivo
                        ,pr_idcampo => 'XML_Arquivo'
                        ,pr_dscritic => vr_dscritic);
         RAISE vr_exc_saida;
      END  IF;
    END LOOP;
    -- Gerar o commit do processo
    COMMIT;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 23'||SQLERRM;
        RETURN;
  END gera_arquivo_xml_23;

  PROCEDURE processa_arquivo_23RET(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2) IS

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq             VARCHAR2(80);
    vr_numctrlemis        VARCHAR2(80);
    vr_numctrldestor      VARCHAR2(20);
    vr_ispbemissor        VARCHAR2(08);
    vr_ispbdestinatario   VARCHAR2(08);
    vr_dthrarq            VARCHAR2(19);
    vr_dtref              VARCHAR2(10);

    -- VARIAVEIS TAB RETORNO ACEITO
    vr_identdpartprincipal     VARCHAR2(8);
    vr_identdpartadmtd         VARCHAR2(8);
    vr_numctrlifacto           VARCHAR2(20);
    vr_numctrlcipaceito        VARCHAR2(20);
    vr_nuliquid                VARCHAR2(21);
    vr_dthrmanut               VARCHAR2(19);

    -- VARIAVEIS TAB RETORNO RECUSADO
    vr_identdpartprincipalrec  VARCHAR2(30);
    vr_identdpartadmtdrec      VARCHAR2(30);
    vr_NumCtrlIF               VARCHAR2(30);
    vr_nuliquidrec             VARCHAR2(21);
    vr_codocorc                VARCHAR2(2) ;

    vr_idarquivo               NUMBER;
    vr_dscritic                VARCHAR2(32000);
    vr_contador                PLS_INTEGER;
    vr_contador_trs            PLS_INTEGER;
    vr_idcampo                 VARCHAR2(1000);
    vr_executado               VARCHAR2(01);
    vr_iderro                  NUMBER := 0;
    vr_iderro_ace              NUMBER := 0;
    vr_iderro_rej              NUMBER := 0;

    vr_nomarqorigem            VARCHAR2(1000);
    vr_dthorarejei             DATE;
    vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                VARCHAR2(4000);
    vr_erro                   VARCHAR2(100);
    vr_domDoc                 DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    -- Váriáveis controle de aceitos / rejeitados
    vr_fim_aceito             NUMBER(01) := 0;
    vr_fim_rejeitado          NUMBER(01) := 0;
    w_idloop                  NUMBER;
    w_dscampo                 VARCHAR2(1000);
    w_indice_cab              NUMBER;
    w_indice                  NUMBER;
    vr_exc_saida              EXCEPTION;

    -- Busca o nome do arquivo de origem para atualização do RET
    CURSOR c1 (pr_nomarq IN VARCHAR2) IS
      SELECT tla.nmarquivo_origem
        FROM tbdomic_liqtrans_arquivo  tla
       WHERE tla.nmarquivo_gerado = replace(pr_nomarq,'_RET','');
      r1 c1%ROWTYPE;

    CURSOR c2 (pr_nomarq IN VARCHAR2) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.dsocorrencia_retorno --||decode(tlp.dsocorrencia_retorno,null,null,' - ')||tme.dsmotivo_erro dsocorrencia_retorno
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
           ,tbdomic_liqtrans_arquivo tla
           --,tbdomic_liqtrans_motivo_erro tme
      WHERE tll.idlancto = tlc.idlancto
        AND tla.nmarquivo_retorno = pr_nomarq
        AND tlc.idcentraliza = tlp.idcentraliza
        AND nvl(tlp.cdocorrencia_retorno,0) IN ('00')
        AND tlp.dsocorrencia_retorno IS NOT NULL -- os pendentes e os com erro
        AND tll.idarquivo = tla.idarquivo;
        --AND tme.cderro(+) = trim(tlp.dsocorrencia_retorno);
  BEGIN

    -- Inicializa o contador de consultas
    vr_contador := 1;

    -- setar a data hora de rejeição para busca na criação do e-mail
    vr_dthorarejei := SYSDATE;

------------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      w_indice     := 1;                       -- Posiciona na primeira linha do arquivo XML

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
      IF vr_NumCtrlEmis IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlEmis';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      -- Verifica se existe dados na consulta
      IF NVL(vr_NumCtrlEmis,0) = 0 THEN
        RETURN;
      END  IF;

      vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
      IF vr_NumCtrlDestOr IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlDestOr';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
      IF vr_ISPBEmissor IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBEmissor';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
      IF vr_ISPBDestinatario IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBDestinatario';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
      IF vr_DtHrArq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtHrArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
      IF vr_DtRef IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtRef';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
         RAISE;
    END;

    -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
    insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                             ,pr_NumCtrlEmis      => vr_NumCtrlEmis
                             ,pr_NumCtrlDestOr    => vr_NumCtrlDestOr
                             ,pr_ISPBEmissor      => vr_ISPBEmissor
                             ,pr_ISPBDestinatario => vr_ISPBDestinatario
                             ,pr_DtHrArq          => vr_DtHrArq
                             ,pr_DtRef            => vr_DtRef
                             ,pr_idarquivo        => vr_idarquivo
                             ,pr_iderro           => vr_iderro
                             ,pr_dscritic         => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_fim_aceito := 0;
    vr_fim_rejeitado := 0;
    -- Inicializa o contador de consultas
    vr_contador_trs := 1;

    -- Posicionar o arquivo no inicio do arquivo XML
    BEGIN
      w_idloop := 0; -- controle de execução do loop

      w_indice := w_indice + 1;
      w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
      IF w_dscampo IS NULL THEN
        vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
        vr_idcampo := '<SISARQ';
        pc_gera_critica(pr_nomearq => vr_nomarq
                       ,pr_idcampo => vr_idcampo
                       ,pr_dscritic => vr_dscritic);
        vr_iderro := 1;
      ELSE
        IF w_dscampo <> 'OK' THEN
          w_idloop := 1;
          w_indice := w_indice - 1;
        END IF;
      END IF;
    END;

    LOOP
      vr_iderro_ace := 0;
      vr_fim_rejeitado := 0;
      vr_fim_aceito := 0;
      -- CARTÕES ACEITOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC023RET_LiquidTranscCredActo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC023RET_LiquidTranscCredActo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_aceito := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF nvl(vr_fim_aceito,0) = 0 THEN
        --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro_ace :=1;
        END IF;

        vr_numctrlifacto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIFActo','S');
        IF vr_numctrlifacto IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIFActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro_ace :=1;
        END IF;

        vr_numctrlcipaceito := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlCIPActo','S');
        IF vr_numctrlcipaceito IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlCIPActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro_ace :=1;
        END IF;

        vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
        IF vr_NULiquid IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NULiquid';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro_ace :=1;
        END IF;

        vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
        IF vr_DtHrManut IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrManut';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro_ace :=1;
        END  IF;

        -- processa o registro de aceite.
        processa_registro_23RET_aceito (pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                       ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                       ,pr_numctrlifacto       => vr_numctrlifacto
                                       ,pr_numctrlcipaceito    => vr_numctrlcipaceito
                                       ,pr_NULiquid            => vr_NULiquid
                                       ,pr_DtHrManut           => to_date(substr(vr_DtHrManut,1,10),'yyyy-mm-dd')
                                       ,pr_dscritic            => vr_dscritic ) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;
      END IF; -- CARTÕES ACEITOS

      -- CARTÕES REJEITADOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC023RET_LiquidTranscCredRecsdo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC023RET_LiquidTranscCredRecsdo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_rejeitado := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF nvl(vr_fim_rejeitado,0) = 0 THEN
        --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtdRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtdRec IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_NumCtrlIF := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIF','S');
        IF vr_NumCtrlIF IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIF';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_erro := null;

        -- Buscar NULiquid se ocorreu erro
        vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','N');
        IF vr_NULiquidRec IS NOT NULL THEN
          -- BUscar o erro que ocorreu no NULiquid
          vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','S');
          IF vr_erro IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid CodErro';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        ELSE
          -- Buscar NULiquid sem erro
          vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
          IF vr_NULiquidRec IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;

        -- Buscar CodOcorc se ocorreu erro
        vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','N');
        IF vr_codocorc IS NOT NULL THEN
          IF vr_erro IS NULL then
            vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','S');
            IF vr_erro IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodOcorc CodErro';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
            END IF;
          END IF;
        ELSE
          -- Buscar CodOcorc sem erro
          vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc','S');
          IF vr_codocorc IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodOcorc';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;

        -- Executa o comando insert dos Rejeitados
        processa_reg_23RET_rejeitado (pr_IdentdPartPrincipalRec => vr_IdentdPartPrincipalRec
                                     ,pr_IdentdPartAdmtdRec     => vr_IdentdPartAdmtdRec
                                     ,pr_NumCtrlIF              => vr_NumCtrlIF
                                     ,pr_NULiquidRec            => vr_NULiquidRec
                                     ,pr_codocorc               => vr_codocorc
                                     ,pr_erro                   => vr_erro
                                     ,pr_dscritic               => vr_dscritic
                                     ,pr_dthorarejei            => vr_dthorarejei) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq  => vr_nomarq
                          ,pr_idcampo  => vr_idcampo
                          ,pr_dscritic => vr_dscritic
                          ,pr_cdocorr  => vr_codocorc );
        END IF;
      END IF; -- CARTÕES REJEITADOS

      IF nvl(vr_fim_rejeitado,0) = 1 AND
         nvl(vr_fim_aceito,0) = 1 THEN
         EXIT;
      ELSE
         vr_contador_trs := vr_contador_trs + 1;
      END IF;
    END LOOP;
    --
    BEGIN
      -- busca o arquivo origem para atualizar o nome arquivo retornado
      OPEN c1 (vr_nomarq);
      FETCH c1 INTO r1;
      vr_nomarqorigem := r1.nmarquivo_origem;
      CLOSE C1;

      -- Atualiza arquivo origem com o nome do arquivo gerado.
      atualiza_nome_arquivo (pr_idtipoarquivo    => 2
                            ,pr_nomearqorigem    => vr_nomarqorigem
                            ,pr_nomearqatualizar => vr_nomarq
                            ,pr_dscritic         => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => 'XML_Arquivo'
                        ,pr_dscritic => vr_dscritic);
      END IF;
    END;
    BEGIN
    --vr_para     := 'roberto.holz@mouts.info';
    vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET23');
    vr_assunto  := 'Domicilio Bancario - Divergencias de retorno do arquivo '||vr_nomarq;
    vr_mensagem := NULL;
--    vr_mensagem := vr_mensagem||' CNPJ Cred              Num Liquidacao            Ocorrencia     Erro <br />';
--    vr_mensagem := vr_mensagem||' ----------------    ---------------------   ----------   ----------- ';

    -- monta o e-mail de envio das divergencias (rejeitados).
    FOR r2 IN c2 (vr_nomarq) LOOP
      IF vr_mensagem IS NULL THEN
         vr_mensagem := 'Abaixo a lista de registros com divergência após a execução do arquivo '||vr_nomarq||
                        ':<br /><br />';
      END IF;
           
      vr_mensagem := vr_mensagem ||'<br />'||
                 'Liquidação - '||lpad(r2.nrliquidacao,25,' ')||'<br /> '||
                 'Ocorrência - '||lpad(r2.cdocorrencia,11,' ')||'<br />'||
                 'Erro - '||lpad(r2.dsocorrencia_retorno,11,' ');
      IF length(vr_mensagem) > 3900 THEN
         pc_envia_email(pr_cdcooper   => 1
                       ,pr_dspara     => vr_para
                       ,pr_dsassunto  => vr_assunto
                       ,pr_dstexto    => vr_mensagem
                       ,pr_dscritic   => vr_dscritic);
         vr_mensagem := NULL;
      END IF;
    END LOOP;

    IF vr_mensagem IS NOT NULL THEN
      pc_envia_email(pr_cdcooper   => 1
                    ,pr_dspara     => vr_para
                    ,pr_dsassunto  => vr_assunto
                    ,pr_dstexto    => vr_mensagem
                    ,pr_dscritic   => vr_dscritic);
    END IF;
    END ;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 23RET '||SQLERRM;
        RETURN;
  END processa_arquivo_23RET;

  PROCEDURE processa_registro_23RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           ) IS
  vr_idpdv tbdomic_liqtrans_pdv.idpdv%TYPE;

  BEGIN
      vr_idpdv := to_number(substr(pr_numctrlifacto,11,10));
      UPDATE tbdomic_liqtrans_pdv d
         SET d.dhretorno = SYSDATE
       WHERE nrliquidacao = pr_nuliquid
         AND d.idpdv = vr_idpdv;  -- no caso de crédito pode estar retornando
                                  -- o registro de agendamento efetivado
                                  -- e então somente atualiza o que foi enviado
                                  -- pois vai existir mais de um registro
                                  -- para o mesmo numero de liquidacao
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_nuliquid||'. '||SQLERRM;
  END processa_registro_23RET_aceito ;

  PROCEDURE processa_reg_23RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF              IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2
                                         ,pr_dthorarejei            IN DATE DEFAULT NULL) IS
  BEGIN
      UPDATE tbdomic_liqtrans_pdv d
         SET d.cdocorrencia_retorno = pr_codocorc,
             d.dsocorrencia_retorno = pr_erro,
             d.dhretorno = pr_dthorarejei
       WHERE nrliquidacao = pr_NULiquidRec;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_NULiquidRec||'. '||SQLERRM;

  END processa_reg_23RET_rejeitado ;

  PROCEDURE processa_arquivo_23err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2) IS           --> Descricao do erro
    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq               VARCHAR2(1000);
    vr_numctrlemis          VARCHAR2(80);
    vr_numctrldestor        VARCHAR2(20);
    vr_ispbemissor          VARCHAR2(08);
    vr_ispbdestinatario     VARCHAR2(08);
    vr_dthrarq              VARCHAR2(19);
    vr_dtref                VARCHAR2(10);

    vr_para                 VARCHAR2(1000);
    vr_assunto              VARCHAR2(1000);
    vr_mensagem             VARCHAR2(32000);
    vr_idarquivo            NUMBER;
    vr_dscritic             VARCHAR2(32000);
    vr_iderro               NUMBER := 0;
    vr_executado            VARCHAR2(01);
    vr_erro                 VARCHAR2(100);
    vr_idcampo              VARCHAR2(1000);
    w_indice_cab            NUMBER;
    vr_exc_saida            EXCEPTION;

  BEGIN
------------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      vr_iderro    := 0;

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S','ERR');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'CodErro','S');
      IF vr_erro IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'CodErro';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro processo TAB. Arquivo 23ERR: '||SQLERRM;
         RAISE;
    END;

    IF vr_iderro = 0 THEN
      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                               ,pr_NumCtrlEmis      => NULL
                               ,pr_NumCtrlDestOr    => NULL
                               ,pr_ISPBEmissor      => NULL
                               ,pr_ISPBDestinatario => NULL
                               ,pr_DtHrArq          => NULL
                               ,pr_DtRef            => NULL
                               ,pr_idarquivo        => vr_idarquivo
                               ,pr_iderro           => vr_iderro
                               ,pr_dscritic         => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_iderro = 0 THEN
      BEGIN
        vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET23');
        vr_assunto  := 'Domicílio Bancário - arquivo '||vr_nomarq||' com erro';
        vr_mensagem := 'Erro no processamento do arquivo '||vr_nomarq||
                       ':<br /><br />'||
                       vr_erro;

        pc_envia_email(pr_cdcooper   => 1
                      ,pr_dspara     => vr_para
                      ,pr_dsassunto  => vr_assunto
                      ,pr_dstexto    => vr_mensagem
                      ,pr_dscritic   => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END ;
    END IF;
  EXCEPTION
  WHEN vr_exc_saida THEN
    pr_dscritic := vr_dscritic;
    RETURN;
  WHEN OTHERS THEN
    pr_dscritic := 'ERRO geral ao gerar o arquivo 23ERR '||SQLERRM;
    RETURN;
  END processa_arquivo_23err;

  PROCEDURE processa_arquivo_24(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                               ,pr_dscritic OUT VARCHAR2) IS
     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
     vr_nomarq               VARCHAR2(1000);
     vr_numctrlemis          VARCHAR2(80);
     vr_numctrldestor        VARCHAR2(20);
     vr_ispbemissor          VARCHAR2(08);
     vr_ispbdestinatario     VARCHAR2(08);
     vr_dthrarq              VARCHAR2(19);
     vr_dtref                VARCHAR2(10);

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_LANCTO
     vr_IdentdPartPrincipal  VARCHAR2(8);
     vr_IdentdPartAdmtd      VARCHAR2(8);
     vr_CNPJBaseCreddr       VARCHAR2(8);
     vr_CNPJCreddr           NUMBER(14);
     vr_ISPBIFDevdr          VARCHAR2(8);
     vr_ISPBIFCredr          VARCHAR2(8);
     vr_AgCreddr             NUMBER(4);
     vr_CtCreddr             NUMBER(13);
     vr_NomCreddr            VARCHAR2(80);

     vr_idlancto             NUMBER;

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_CENTRALIZA
     vr_TpPessoaCentrlz      VARCHAR2(01);
     vr_CNPJ_CPFCentrlz      NUMBER(14);
     vr_CodCentrlz           VARCHAR2(25);
     vr_TpCt                 VARCHAR2(02);
     vr_CtPgtoCentrlz        NUMBER(20);
     vr_AgCentrlz            NUMBER(13);
     vr_CtCentrlz            NUMBER(13);

     vr_idcentraliza         NUMBER;

     -- VARIAVEIS TAB TBDOMIC_LIQTRANS_PDV
     vr_nuliquid                VARCHAR2(21);
     vr_ispbifliquidpontovenda  VARCHAR2(08);
     vr_codpontovenda           VARCHAR2(25);
     vr_nomepontovenda          VARCHAR2(80);
     vr_tppessoapontovenda      VARCHAR2(01);
     vr_cnpj_cpfpontovenda      NUMBER(14);
     vr_codinstitdrarrajpgto    VARCHAR2(3);
     vr_tpprodliquiddeb         NUMBER(02) ;
     vr_indrformatransf         VARCHAR2(01);
     vr_codmoeda                NUMBER(03);
     vr_dtpgto                  VARCHAR2(10);
     vr_vlrpgto                 NUMBER(19,2);
     vr_dthrmanut               VARCHAR2(19);
     vr_codocorc                VARCHAR2(2) ;
     vr_numctrlifacto           VARCHAR2(20);
     vr_numctrlcipaceito        VARCHAR2(20);

     vr_idcampo      VARCHAR2(32000);
     vr_idpdv        NUMBER;
     vr_idarquivo    NUMBER;
     vr_dscritic     VARCHAR2(32000);
     vr_contador     PLS_INTEGER;
     vr_contador_lqd PLS_INTEGER;
     vr_contador_pve PLS_INTEGER;
     vr_contador_ctz PLS_INTEGER;

     vr_executado    VARCHAR2(01);
     vr_iderro       NUMBER;
     w_idloop        NUMBER;
     w_dscampo       VARCHAR2(100);
     w_indice_cab    NUMBER;
     w_indice        NUMBER;
     vr_exc_saida    EXCEPTION;

  BEGIN
    -- Inicializa o contador de consultas
    vr_contador := 1;
    LOOP

      vr_nomarq            := NULL;
      vr_NumCtrlEmis       := NULL;
      vr_NumCtrlDestOr     := NULL;
      vr_ISPBEmissor       := NULL;
      vr_ISPBDestinatario  := NULL;
      vr_DtHrArq           := NULL;
      vr_DtRef             := NULL;
      vr_iderro            := NULL;-------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------

      w_indice_cab         := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      w_indice             := 1;                       -- Posiciona na primeira linha do arquivo XML

      BEGIN
        -- Verifica se existe dados na consulta
        IF pr_table_of.count() = 0 THEN
          EXIT;
        END IF;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        --Busca os campos do detalhe da consulta
        vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
        IF vr_nomarq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        -- valida se o arquivo com esse nome já foi processado.

        vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

        IF vr_executado = 'S' THEN
           EXIT;
        END IF;

        vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
        IF vr_NumCtrlEmis IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlEmis';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
        IF vr_NumCtrlDestOr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlDestOr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
        IF vr_ISPBEmissor IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBEmissor';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
        IF vr_ISPBDestinatario IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBDestinatario';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
        IF vr_DtHrArq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
        IF vr_DtRef IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtRef';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
           RAISE;
      END;

      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao  (pr_nomarq           => vr_nomarq
                                ,pr_NumCtrlEmis      => vr_NumCtrlEmis
                                ,pr_NumCtrlDestOr    => vr_NumCtrlDestOr
                                ,pr_ISPBEmissor      => vr_ISPBEmissor
                                ,pr_ISPBDestinatario => vr_ISPBDestinatario
                                ,pr_DtHrArq          => vr_DtHrArq
                                ,pr_DtRef            => vr_DtRef
                                ,pr_idarquivo        => vr_idarquivo
                                ,pr_iderro           => vr_iderro
                                ,pr_dscritic         => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      ------ BUSCA DADOS DA TABELA TBDOMIC_LIQTRANS_LANCTO
      vr_contador_lqd := 1;

      -- Posicionar o arquivo no inicio do arquivo XML
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;

        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<SISARQ';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            w_idloop := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      LOOP
        vr_IdentdPartPrincipal  := NULL;
        vr_IdentdPartAdmtd      := NULL;
        vr_CNPJBaseCreddr       := NULL;
        vr_CNPJCreddr           := NULL;
        vr_ISPBIFDevdr          := NULL;
        vr_ISPBIFCredr          := NULL;
        vr_AgCreddr             := NULL;
        vr_CtCreddr             := NULL;
        vr_NomCreddr            := NULL;
        vr_iderro               := NULL;

        -- Posiciona na TAG de início do bloco
        BEGIN
          w_idloop := 0; -- controle de execução do loop
          w_indice := w_indice + 1;
          w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC024_LiquidTranscDeb','S');
          IF w_dscampo IS NULL THEN
            vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
            vr_idcampo := '<Grupo_ASLC024_LiquidTranscDeb';
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => vr_idcampo
                           ,pr_dscritic => vr_dscritic);
            vr_iderro := 1;
          ELSE
            IF w_dscampo <> 'OK' THEN
              w_idloop := 1;
              w_indice := w_indice - 1;
            END IF;
          END IF;
        END;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        vr_IdentdPartPrincipal := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartPrincipal','S');
        IF vr_IdentdPartPrincipal IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartPrincipal';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        -- Verifica se existe dados na consulta
        IF NVL(vr_IdentdPartPrincipal,0) = 0 THEN
           EXIT;
        END IF;

        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        vr_CNPJBaseCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJBaseCreddr','S');
        IF vr_CNPJBaseCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJBaseCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_CNPJCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJCreddr','S');
        IF vr_CNPJCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBIFDevdr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFDevdr','S');
        IF vr_ISPBIFDevdr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFDevdr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBIFCredr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFCredr','S');
        IF vr_ISPBIFCredr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFCredr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_AgCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCreddr','S');
        IF vr_AgCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'AgCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_CtCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCreddr','S');
        IF vr_CtCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CtCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_NomCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomCreddr','S');
        IF vr_NomCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

    --    dbms_output.put_line('liquida: '||to_char(SYSDATE,'HH24:MI:ss')||' '||vr_CtCreddr);

        -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
        insere_liquidacao_transacao (pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                    ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                    ,pr_CNPJBaseCreddr      => vr_CNPJBaseCreddr
                                    ,pr_CNPJCreddr          => vr_CNPJCreddr
                                    ,pr_ISPBIFDevdr         => vr_ISPBIFDevdr
                                    ,pr_ISPBIFCredr         => vr_ISPBIFCredr
                                    ,pr_AgCreddr            => vr_AgCreddr
                                    ,pr_CtCreddr            => vr_CtCreddr
                                    ,pr_NomCreddr           => vr_NomCreddr
                                    ,pr_idarquivo           => vr_idarquivo
                                    ,pr_idlancto            => vr_idlancto
                                    ,pr_iderro              => vr_iderro
                                    ,pr_dscritic            => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_CENTRALIZA
        vr_contador_ctz := 1;

        LOOP
          vr_TpPessoaCentrlz     := null;
          vr_CNPJ_CPFCentrlz     := null;
          vr_CodCentrlz          := null;
          vr_TpCt                := null;
          vr_CtPgtoCentrlz       := null;
          vr_AgCentrlz           := null;
          vr_CtCentrlz           := null;
          vr_iderro              := 0;

          -- Posiciona na TAG de final do bloco
          BEGIN
            w_idloop := 0; -- controle de execução do loop
            w_indice := w_indice + 1;
            w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC024_Centrlz','S');
            IF w_dscampo IS NULL THEN
              vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
              vr_idcampo := 'Grupo_ASLC024_Centrlz';
              pc_gera_critica(pr_nomearq => vr_nomarq
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              vr_iderro := 1;
            ELSE
              IF w_dscampo <> 'OK' THEN
                w_idloop := 1;
                w_indice := w_indice - 1;
              END IF;
            END IF;
          END;

          -- Controla a execução do loop
          IF w_idloop = 1 THEN
            w_idloop := 0;
            EXIT;
          END IF;

          vr_TpPessoaCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaCentrlz','S');
          IF vr_TpPessoaCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpPessoaCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_CNPJ_CPFCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFCentrlz','S');
          IF vr_CNPJ_CPFCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CNPJ_CPFCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          -- Verifica se existe dados na consulta
          IF nvl(vr_CNPJ_CPFCentrlz,0) = 0 THEN
             EXIT;
          END IF;

          vr_CodCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodCentrlz','S');
          IF vr_CodCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_TpCt := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpCt','S');
          IF vr_TpCt IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpCt';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_AgCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCentrlz','S');
          IF vr_AgCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'AgCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_CtCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCentrlz','S');
          IF vr_CtCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CtCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
          IF NVL(vr_iderro,0) = 1 THEN
             pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                        ,pr_dscritic  => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
                -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                NULL;
             END IF;
          END IF;

    --      dbms_output.put_line('central: '||to_char(SYSDATE,'HH24:MI:ss')||' '||vr_CtCentrlz);

          -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA INSERE_LIQ_TRN_CENTRAL
          insere_liq_trn_central(pr_TpPessoaCentrlz  => vr_TpPessoaCentrlz
                                ,pr_CNPJ_CPFCentrlz  => vr_CNPJ_CPFCentrlz
                                ,pr_CodCentrlz       => vr_CodCentrlz
                                ,pr_TpCt             => vr_TpCt
                                ,pr_CtPgtoCentrlz    => vr_CtPgtoCentrlz
                                ,pr_AgCentrlz        => vr_AgCentrlz
                                ,pr_CtCentrlz        => vr_CtCentrlz
                                ,pr_idlancto         => vr_idlancto
                                ,pr_idcentraliza     => vr_idcentraliza
                                ,pr_dscritic         => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_PDV
          vr_contador_pve := 1;

            LOOP
              vr_NULiquid                 := null;
              vr_ISPBIFLiquidPontoVenda   := null;
              vr_CodPontoVenda            := null;
              vr_NomePontoVenda           := null;
              vr_TpPessoaPontoVenda       := null;
              vr_CNPJ_CPFPontoVenda       := null;
              vr_CodInstitdrArrajPgto     := null;
              vr_TpProdLiquidDeb          := null;
              vr_IndrFormaTransf          := null;
              vr_CodMoeda                 := null;
              vr_DtPgto                   := null;
              vr_VlrPgto                  := null;
              vr_DtHrManut                := null;
              vr_codocorc                 := null;
              vr_numctrlifacto            := null;
              vr_numctrlcipaceito         := null;
              vr_iderro                   := 0;

              -- Posiciona na TAG de início do bloco
              BEGIN
                w_idloop := 0; -- controle de execução do loop
                w_indice := w_indice + 1;
                w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC024_PontoVenda','S');
                IF w_dscampo IS NULL THEN
                  vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                  vr_idcampo := 'Grupo_ASLC024_PontoVenda';
                  pc_gera_critica(pr_nomearq => vr_nomarq
                                 ,pr_idcampo => vr_idcampo
                                 ,pr_dscritic => vr_dscritic);
                  vr_iderro := 1;
                ELSE
                  IF w_dscampo <> 'OK' THEN
                    w_idloop := 1;
                    w_indice := w_indice - 1;
                  END IF;
                END IF;
              END;
              -- Controla a execução do loop
              IF w_idloop = 1 THEN
                w_idloop := 0;
                EXIT;
              END IF;

              vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
              IF vr_NULiquid IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'NULiquid';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              -- Verifica se existe dados na consulta
              IF nvl(vr_NULiquid,0) = 0 THEN
                 EXIT;
              END IF;

              vr_ISPBIFLiquidPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFLiquidPontoVenda','S');
              IF vr_ISPBIFLiquidPontoVenda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'ISPBIFLiquidPontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_CodPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodPontoVenda','S');
              IF vr_CodPontoVenda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'CodPontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_NomePontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomePontoVenda','S');
              IF vr_NomePontoVenda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'NomePontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_TpPessoaPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaPontoVenda','S');
              IF vr_TpPessoaPontoVenda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'TpPessoaPontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_CNPJ_CPFPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFPontoVenda','S');
              IF vr_CNPJ_CPFPontoVenda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'CNPJ_CPFPontoVenda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_CodInstitdrArrajPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodInstitdrArrajPgto','S');
              IF vr_CodInstitdrArrajPgto IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'CodInstitdrArrajPgto';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_TpProdLiquidDeb := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpProdLiquidDeb','S');
              IF vr_TpProdLiquidDeb IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'TpProdLiquidDeb';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_IndrFormaTransf := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IndrFormaTransf','S');
              IF vr_IndrFormaTransf IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'IndrFormaTransf';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_CodMoeda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodMoeda','S');
              IF vr_CodMoeda IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'CodMoeda';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_DtPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtPgto','S');
              IF vr_DtPgto IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'DtPgto';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_VlrPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'VlrPgto','S');
              IF vr_VlrPgto IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'VlrPgto';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
              IF vr_DtHrManut IS NULL THEN
                 vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                 vr_idcampo := 'DtHrManut';
                 pc_gera_critica(pr_nomearq => vr_nomarq
                                ,pr_idcampo => vr_idcampo
                                ,pr_dscritic => vr_dscritic);
                 vr_iderro := 1;
              END IF;

              -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
              IF NVL(vr_iderro,0) = 1 THEN
                 pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                            ,pr_dscritic  => vr_dscritic);
                 IF vr_dscritic IS NOT NULL THEN
                    -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                    NULL;
                 END IF;
              END IF;

              -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
              insere_liq_trn_cen_pve (pr_NULiquid                => vr_NULiquid
                                     ,pr_ISPBIFLiquidPontoVenda  => vr_ISPBIFLiquidPontoVenda
                                     ,pr_CodPontoVenda           => vr_CodPontoVenda
                                     ,pr_NomePontoVenda          => vr_NomePontoVenda
                                     ,pr_TpPessoaPontoVenda      => vr_TpPessoaPontoVenda
                                     ,pr_CNPJ_CPFPontoVenda      => vr_CNPJ_CPFPontoVenda
                                     ,pr_CodInstitdrArrajPgto    => vr_CodInstitdrArrajPgto
                                     ,pr_TpProdLiquidCred        => vr_TpProdLiquidDeb
                                     ,pr_IndrFormaTransf         => vr_IndrFormaTransf
                                     ,pr_CodMoeda                => vr_CodMoeda
                                     ,pr_DtPgto                  => vr_DtPgto
                                     ,pr_VlrPgto                 => vr_VlrPgto
                                     ,pr_DtHrManut               => vr_DtHrManut
                                     ,pr_codocorc                => vr_codocorc
                                     ,pr_numctrlifacto           => vr_numctrlifacto
                                     ,pr_numctrlcipaceito        => vr_numctrlcipaceito
                                     ,pr_idcentraliza            => vr_idcentraliza
                                     ,pr_idpdv                   => vr_idpdv
                                     ,pr_dscritic                => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            -- FIM TABELA   TBDOMIC_LIQ_TRN_CEN_PVE

            END LOOP;

            vr_contador_ctz := vr_contador_ctz + 1;
          -- FIM TABELA   TBDOMIC_LIQ_TRN_CENTRAL

           -- Posiciona na TAG de final do bloco
           BEGIN
             w_idloop := 0; -- controle de execução do loop
             w_indice := w_indice + 1;
             w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC024_Centrlz','S');
             IF w_dscampo IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := '/Grupo_ASLC024_Centrlz';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
             ELSE
               IF w_dscampo <> 'OK' THEN
                 w_idloop := 1;
                 w_indice := w_indice - 1;
               END IF;
             END IF;
           END;
         END LOOP;

         vr_contador_lqd := vr_contador_lqd + 1;
       -- FIM TABELA   TBDOMIC_LIQTRANS_LANCTO

         -- Posiciona na TAG de final do bloco
         BEGIN
           w_idloop := 0; -- controle de execução do loop
           w_indice := w_indice + 1;
           w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC024_LiquidTranscDeb','S');
           IF w_dscampo IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := '/Grupo_ASLC024_LiquidTranscDeb';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
           ELSE
             IF w_dscampo <> 'OK' THEN
               w_idloop := 1;
               w_indice := w_indice - 1;
             END IF;
           END IF;
         END;
       END LOOP;

        vr_contador := vr_contador + 1;
      --FIM TABELA  TBDOMIC_LIQTRANS_ARQUIVO

        -- Posiciona na TAG de final do bloco
        BEGIN
          w_idloop := 0; -- controle de execução do loop
          w_indice := w_indice + 1;
          w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/SISARQ','S');
          IF w_dscampo IS NULL THEN
            vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
            vr_idcampo := '/ASLC024';
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => vr_idcampo
                           ,pr_dscritic => vr_dscritic);
            vr_iderro := 1;
          ELSE
            IF w_dscampo <> 'OK' THEN
              w_idloop := 1;
              w_indice := w_indice - 1;
            ELSE
              w_idloop := 1;
            END IF;
          END IF;
        END;
      END LOOP;
    dbms_output.put_line('Número de linhas processadas do arquivo '||vr_nomarq||' = '||w_indice);
  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 24 '||SQLERRM;
        RETURN;
  END processa_arquivo_24;

  PROCEDURE gera_arquivo_xml_25 (pr_dscritic IN OUT VARCHAR2)  IS

    CURSOR c0 IS
      SELECT d.idarquivo
            ,d.nrispb_emissor
            ,nrcontrole_emissor
            ,nrcontrole_dest_original
            ,nrispb_destinatario
            ,d.dtreferencia
        FROM tbdomic_liqtrans_arquivo d
       WHERE SUBSTR(d.nmarquivo_origem,1,7) = 'ASLC024'
         AND ((to_date(substr(d.dharquivo_origem,1,10)||substr(d.dharquivo_origem,12,6),'YYYY-MM-DDHH24:MI:SS') BETWEEN to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_rec_25_1cicl,'ddmmyyyyhh24:mi') AND to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_rec_25_1cicl,'ddmmyyyyhh24:mi')
         AND sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_25_1cicl,'ddmmyyyyhh24:mi') and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_1cicl,'ddmmyyyyhh24:mi'))
          OR (to_date(substr(d.dharquivo_origem,1,10)||substr(d.dharquivo_origem, 12,6),'YYYY-MM-DDHH24:MI:SS') BETWEEN to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_rec_25_2cicl,'ddmmyyyyhh24:mi') AND to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_rec_25_2cicl,'ddmmyyyyhh24:mi')
         AND sysdate between to_date(to_char(sysdate,'ddmmyyyy')||vr_horini_25_2cicl,'ddmmyyyyhh24:mi') and to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_2cicl,'ddmmyyyyhh24:mi')))
         AND nmarquivo_gerado IS NULL
         AND EXISTS
             (SELECT 'S'
                FROM tbdomic_liqtrans_lancto tll
                    ,tbdomic_liqtrans_centraliza tlc
               WHERE tll.idlancto = tlc.idlancto
                 AND tll.idarquivo = d.idarquivo
                 AND tll.insituacao in (1));

    CURSOR c1 (pr_idarquivo IN NUMBER) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.idpdv
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
      WHERE tll.idlancto = tlc.idlancto
        AND tlc.idcentraliza = tlp.idcentraliza
        AND tll.idarquivo = pr_idarquivo
        AND tll.insituacao in (1); -- os pendentes e os com erro

   CURSOR c2 IS
     SELECT TO_NUMBER(LPAD(fn_sequence (pr_nmtabela => 'tbdomic_liqtrans_arquivo'
                                       ,pr_nmdcampo => 'TPARQUIVO'
                                       ,pr_dsdchave => 2),4,'0'))  seq
       FROM dual;
     r2 c2%ROWTYPE;

    vr_dscritic      VARCHAR2(32000);
    vr_contador      PLS_INTEGER := 0;
    vr_caminho       VARCHAR2(1000);
    vr_arquivo       VARCHAR2(1000);
    vr_retxml        XMLTYPE;
    vr_nrsequencia NUMBER;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nomarq  VARCHAR2(1000);

    vr_exc_saida         EXCEPTION;
  BEGIN

    FOR r0 IN c0 LOOP

      -- busca a sequencia para o nome do arquivo
      OPEN c2;
      FETCH c2 INTO r2;
      vr_nrsequencia := r2.seq;
      CLOSE c2;


      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?>');

      vr_nomarq := 'ASLC025_'||r0.nrispb_destinatario||'_'||to_char(sysdate,'YYYYMMDD')||'_'||lpad(vr_nrsequencia,5,'0');
      vr_arquivo :=  vr_nomarq ||'.XML';

/*      -- Cria o nó inicial do XML
      vr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><ASLC025/>');

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC025',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC025',pr_posicao => 0, pr_tag_nova => 'BCARQ', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => 0, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NomArq', pr_tag_cont => vr_arquivo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlEmis', pr_tag_cont => r0.nrcontrole_emissor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlDestOr', pr_tag_cont => r0.nrcontrole_dest_original, pr_des_erro => ll);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'ISPBDestinatario', pr_tag_cont => r0.nrispb_destinatario, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtHrArq', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd hh24:mi:ss'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtRef', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd'), pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC025',pr_posicao => 0, pr_tag_nova => 'SISARQ', pr_tag_cont => NULL, pr_des_erro =>   vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'SISARQ',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro =>   vr_dscritic);
*/

      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<ASLCDOC xmlns="http://www.cip-bancos.org.br/ARQ/ASLC025.xsd">'||
                                                   '<BCARQ>'||
                                                   '<NomArq>'     || vr_nomarq     ||'</NomArq>'||
                                                   '<NumCtrlEmis>'    || to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r0.idarquivo,12,'0')    ||'</NumCtrlEmis>'||
                                                --   '<NumCtrlDestOr>'    || r0.nrcontrole_dest_original  ||'</NumCtrlDestOr>'||
                                                   '<ISPBEmissor>' || r0.nrispb_destinatario ||'</ISPBEmissor>'||
                                                   '<ISPBDestinatario>' || r0.nrispb_emissor ||'</ISPBDestinatario>'||
                                                   '<DtHrArq>'   || to_char(SYSDATE,'yyyy-mm-dd')||'T'||to_char(SYSDATE,'hh24:mi:ss')   ||'</DtHrArq>'||
                                                   '<DtRef>'       || to_char(SYSDATE,'yyyy-mm-dd')     ||'</DtRef>'||
                                                   '</BCARQ>'||
                                                   '<SISARQ>'||
                                                   '<ASLC025>');
      -- Efetua loop sobre os registros do arquivo 023
      FOR r1 IN c1 (pr_idarquivo => r0.idarquivo) LOOP
        -- Gera os detalhes
/*        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'SISARQ',pr_posicao => 0, pr_tag_nova => 'Grupo_ASLC025_LiquidTranscDeb', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartPrincipal', pr_tag_cont => to_char(r1.nrcnpjbase_principal), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartAdmtd', pr_tag_cont => to_char(r1.nrcnpjbase_administrado), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => 'NumCtrlIF', pr_tag_cont => to_char(r1.nrispb_devedor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => 'NULiquid', pr_tag_cont => to_char(r1.nrliquidacao), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC025_LiquidTranscDeb',   pr_posicao => vr_contador, pr_tag_nova => 'CodOcorc', pr_tag_cont => to_char(r1.cdocorrencia), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;*/
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     =>  '<Grupo_ASLC025_LiquidTranscDeb>'||
                                                     '<IdentdPartPrincipal>'     || to_char(r1.nrcnpjbase_principal)     ||'</IdentdPartPrincipal>'||
                                                     '<IdentdPartAdmtd>'    || to_char(r1.nrcnpjbase_administrado)    ||'</IdentdPartAdmtd>'||
                                                     '<NumCtrlIF>'    ||  to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r1.idpdv,12,'0')  ||'</NumCtrlIF>'||
                                                     '<NULiquid>' || to_char(r1.nrliquidacao) ||'</NULiquid>'||
                                                     '<CodOcorc>'   || to_char(r1.cdocorrencia)  ||'</CodOcorc>'||
                                                     '</Grupo_ASLC025_LiquidTranscDeb>');

      END LOOP;
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</ASLC025></SISARQ></ASLCDOC>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      -- vr_retxml := xmltype(vr_clob);
      BEGIN
        vr_caminho := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO_SLC');
        IF substr(vr_caminho, length(vr_caminho)) != '/' then
          vr_caminho := vr_caminho ||'/'||'envia';
        ELSE
          vr_caminho := vr_caminho ||'envia';
        END IF;

        IF vr_database_name = 'AYLLOSD' THEN
          vr_caminho := '/usr/sistemas/SLC/envia';
        END IF;
        --vr_caminho := '/usr/sistemas/SLC/envia';

      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao ler o caminho cadastrado na gene0001.fn_pam_sistema'||SQLERRM;
           pc_gera_critica(pr_nomearq => vr_arquivo
                          ,pr_idcampo => 'Caminho'
                          ,pr_dscritic => vr_dscritic);
      END;

      -- gera o arquivo no diretório padrão
      GENE0002.pc_XML_para_arquivo (pr_XML       => vr_clob    --> Instância do CLOB Type
                                   ,pr_caminho   => vr_caminho --> Diretório para saída
                                   ,pr_arquivo   => vr_arquivo --> Nome do arquivo de saída
                                   ,pr_des_erro  => vr_dscritic );

      -- Atualiza arquivo origem com o nome do arquivo gerado.
      atualiza_nome_arquivo (pr_idtipoarquivo    => 1
                            ,pr_nomearqorigem    => r0.idarquivo
                            ,pr_nomearqatualizar => vr_nomarq
                            ,pr_dscritic         => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         pc_gera_critica(pr_nomearq => vr_arquivo
                        ,pr_idcampo => 'XML_Arquivo'
                        ,pr_dscritic => vr_dscritic);
      END  IF;
    END LOOP;

    COMMIT;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 25 '||SQLERRM;
        RETURN;
  END gera_arquivo_xml_25;

  PROCEDURE processa_arquivo_25RET(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2) IS             --> Descricao do erro

    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq                VARCHAR2(1000);
    vr_numctrlemis           VARCHAR2(80);
    vr_numctrldestor         VARCHAR2(20);
    vr_ispbemissor           VARCHAR2(08);
    vr_ispbdestinatario      VARCHAR2(08);
    vr_dthrarq               VARCHAR2(19);
    vr_dtref                 VARCHAR2(10);

    -- VARIAVEIS TAB RETORNO ACEITO
    vr_identdpartprincipal   VARCHAR2(8);
    vr_identdpartadmtd       VARCHAR2(8);
    vr_numctrlifacto         VARCHAR2(20);
    vr_numctrlcipaceito      VARCHAR2(20);
    vr_nuliquid              VARCHAR2(21);
    vr_dthrmanut             VARCHAR2(19);

     -- VARIAVEIS TAB RETORNO RECUSADO
    vr_identdpartprincipalrec VARCHAR2(30);
    vr_identdpartadmtdrec     VARCHAR2(30);
    vr_NumCtrlIF              VARCHAR2(30);
    vr_nuliquidrec            VARCHAR2(21);
    vr_codocorc               VARCHAR2(2) ;

    vr_idarquivo              NUMBER;
    vr_dscritic               VARCHAR2(32000);
    vr_contador               PLS_INTEGER;
    vr_contador_trs           PLS_INTEGER;
    vr_executado              VARCHAR2(01);
    vr_iderro                 NUMBER(01);
    -- Váriáveis controle de aceitos / rejeitados
    vr_fim_aceito             NUMBER(01) := 0;
    vr_fim_rejeitado          NUMBER(01) := 0;

    vr_nomarqorigem            VARCHAR2(1000);
    vr_erro                   VARCHAR2(100);
    vr_domDoc                 DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
    vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                VARCHAR2(4000);
    vr_idcampo                 VARCHAR2(100);
    w_idloop                   NUMBER;
    w_dscampo                  VARCHAR2(100);
    w_indice_cab               NUMBER;
    w_indice                   NUMBER;
    vr_exc_saida               EXCEPTION;


    -- Busca o nome do arquivo de origem para atualização do RET
    CURSOR c1 (pr_nomarq IN VARCHAR2) IS
      SELECT tla.nmarquivo_origem
        FROM tbdomic_liqtrans_arquivo  tla
       WHERE tla.nmarquivo_gerado = replace(pr_nomarq,'_RET','');
      r1 c1%ROWTYPE;

    CURSOR c2 (pr_nomarq IN VARCHAR2) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.dsocorrencia_retorno --||decode(tlp.dsocorrencia_retorno,null,null,' - ')||tme.dsmotivo_erro dsocorrencia_retorno
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
           ,tbdomic_liqtrans_arquivo tla
           --,tbdomic_liqtrans_motivo_erro tme
      WHERE tll.idlancto = tlc.idlancto
        AND tla.nmarquivo_retorno = pr_nomarq
        AND tlc.idcentraliza = tlp.idcentraliza
        AND nvl(tlp.cdocorrencia_retorno,0) IN ('00')
        AND tlp.dsocorrencia_retorno IS NOT NULL
        AND tll.idarquivo = tla.idarquivo;
        --AND tme.cderro(+) = tlp.dsocorrencia_retorno;
  BEGIN

    -- Inicializa o contador de consultas
    vr_contador := 1;

    -- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      w_indice     := 1;                       -- Posiciona na primeira linha do arquivo XML

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;


      vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
      IF vr_NumCtrlEmis IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlEmis';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      -- Verifica se existe dados na consulta
      IF NVL(vr_NumCtrlEmis,0) = 0 THEN
         RETURN;
      END  IF;

      vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
      IF vr_NumCtrlDestOr IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlDestOr';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
      IF vr_ISPBEmissor IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBEmissor';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
      IF vr_ISPBDestinatario IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBDestinatario';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
      IF vr_DtHrArq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtHrArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
      IF vr_DtRef IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtRef';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
        RAISE;
    END;

    -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
    insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                             ,pr_NumCtrlEmis      => vr_NumCtrlEmis
                             ,pr_NumCtrlDestOr    => vr_NumCtrlDestOr
                             ,pr_ISPBEmissor      => vr_ISPBEmissor
                             ,pr_ISPBDestinatario => vr_ISPBDestinatario
                             ,pr_DtHrArq          => vr_DtHrArq
                             ,pr_DtRef            => vr_DtRef
                             ,pr_idarquivo        => vr_idarquivo
                             ,pr_iderro           => vr_iderro
                             ,pr_dscritic         => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_fim_aceito := 0;
    vr_fim_rejeitado := 0;
    -- Inicializa o contador de consultas
    vr_contador_trs := 1;

    -- Posicionar o arquivo no inicio do arquivo XML
    BEGIN
      w_idloop := 0; -- controle de execução do loop

      w_indice := w_indice + 1;
      w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
      IF w_dscampo IS NULL THEN
        vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
        vr_idcampo := '<SISARQ';
        pc_gera_critica(pr_nomearq => vr_nomarq
                       ,pr_idcampo => vr_idcampo
                       ,pr_dscritic => vr_dscritic);
        vr_iderro := 1;
      ELSE
        IF w_dscampo <> 'OK' THEN
          w_idloop := 1;
          w_indice := w_indice - 1;
        END IF;
      END IF;
    END;

    LOOP
      vr_fim_rejeitado := 0;
      vr_fim_aceito := 0;

      -- CARTÕES ACEITOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC025RET_LiquidTranscDebActo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC025RET_LiquidTranscDebActo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_aceito := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF nvl(vr_fim_aceito,0) = 0 THEN
        --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_numctrlifacto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIFActo','S');
        IF vr_numctrlifacto IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIFActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_numctrlcipaceito := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlCIPActo','S');
        IF vr_numctrlcipaceito IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlCIPActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
        IF vr_NULiquid IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NULiquid';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
        IF vr_DtHrManut IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrManut';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END  IF;

        -- processa o registro de aceite.
        processa_registro_25RET_aceito (pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                       ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                       ,pr_numctrlifacto       => vr_numctrlifacto
                                       ,pr_numctrlcipaceito    => vr_numctrlcipaceito
                                       ,pr_NULiquid            => vr_NULiquid
                                       ,pr_DtHrManut           => to_date(substr(vr_DtHrManut,1,10),'yyyy-mm-dd')
                                       ,pr_dscritic            => vr_dscritic ) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => NULL
                          ,pr_dscritic => vr_dscritic);
        END IF;
      END IF;

      -- CARTÕES REJEITADOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC025RET_LiquidTranscDebRecsdo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC025RET_LiquidTranscDebRecsdo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_rejeitado := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF nvl(vr_fim_rejeitado,0) = 0 THEN
        --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtdRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtdRec IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_NumCtrlIF := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIF','S');
        IF vr_NumCtrlIF IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIF';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_erro := null;

        -- Buscar NULiquid se ocorreu erro
        vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','N');
        IF vr_NULiquidRec IS NOT NULL THEN
          -- BUscar o erro que ocorreu no NULiquid
          vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','S');
          IF vr_erro IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid CodErro';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        ELSE
          -- Buscar NULiquid sem erro
          vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
          IF vr_NULiquidRec IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;

        -- Buscar CodOcorc se ocorreu erro
        vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','N');
        IF vr_codocorc IS NOT NULL THEN
          IF vr_erro IS NULL then
            vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','S');
            IF vr_erro IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodOcorc CodErro';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
            END IF;
          END IF;
        ELSE
          -- Buscar CodOcorc sem erro
          vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc','S');
          IF vr_codocorc IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodOcorc';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;

        processa_reg_25RET_rejeitado (pr_IdentdPartPrincipalRec => vr_IdentdPartPrincipalRec
                                     ,pr_IdentdPartAdmtdRec     => vr_IdentdPartAdmtdRec
                                     ,pr_NumCtrlIF            => vr_NumCtrlIF
                                     ,pr_NULiquidRec            => vr_NULiquidRec
                                     ,pr_codocorc               => vr_codocorc
                                     ,pr_erro                   => vr_erro
                                     ,pr_dscritic               => vr_dscritic) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq  => vr_nomarq
                          ,pr_idcampo  => NULL
                          ,pr_dscritic => vr_dscritic
                          ,pr_cdocorr  => vr_codocorc );
        END IF;

      END IF;

      IF nvl(vr_fim_rejeitado,0) = 1 AND
         nvl(vr_fim_aceito,0) = 1 THEN
         EXIT;
      ELSE
         vr_contador_trs := vr_contador_trs + 1;
      END IF;
    END LOOP;
      BEGIN
        -- busca o arquivo origem para atualizar o nome arquivo retornado
        OPEN c1 (vr_nomarq);
        FETCH c1 INTO r1;
        vr_nomarqorigem := r1.nmarquivo_origem;
        CLOSE C1;

        -- Atualiza arquivo origem com o nome do arquivo gerado.
        atualiza_nome_arquivo (pr_idtipoarquivo    => 2
                              ,pr_nomearqorigem    => vr_nomarqorigem
                              ,pr_nomearqatualizar => vr_nomarq
                              ,pr_dscritic         => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => 'XML_Arquivo'
                          ,pr_dscritic => vr_dscritic);
        END IF;
      END;
      BEGIN

      --vr_para     := 'roberto.holz@mouts.info';
      vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET25');
      vr_assunto  := 'Domicilio Bancario - Divergencias de retorno do arquivo '||vr_nomarq;
      vr_mensagem := NULL;
--      vr_mensagem := vr_mensagem||' CNPJ Cred              Num Liquidacao            Ocorrencia     Erro <br />';
--      vr_mensagem := vr_mensagem||' ----------------    ---------------------   ----------   ----------- ';

      -- monta o e-mail de envio das divergencias (rejeitados).
      FOR r2 IN c2 (vr_nomarq) LOOP
        IF vr_mensagem IS NULL THEN
           vr_mensagem := 'Abaixo a lista de registros com divergência após a execução do arquivo '||vr_nomarq||
                          ':<br /><br />';
        END IF;
           
        vr_mensagem := vr_mensagem ||'<br />'||
                   'Liquidação - '||lpad(r2.nrliquidacao,25,' ')||'<br /> '||
                   'Ocorrência - '||lpad(r2.cdocorrencia,11,' ')||'<br />'||
                   'Erro - '||lpad(r2.dsocorrencia_retorno,11,' ');
        IF length(vr_mensagem) > 3900 THEN
           pc_envia_email(pr_cdcooper   => 1
                         ,pr_dspara     => vr_para
                         ,pr_dsassunto  => vr_assunto
                         ,pr_dstexto    => vr_mensagem
                         ,pr_dscritic   => vr_dscritic);
           vr_mensagem := NULL;
        END IF;
      END LOOP;

      IF vr_mensagem IS NOT NULL THEN
        pc_envia_email(pr_cdcooper   => 1
                      ,pr_dspara     => vr_para
                      ,pr_dsassunto  => vr_assunto
                      ,pr_dstexto    => vr_mensagem
                      ,pr_dscritic   => vr_dscritic);
      END IF;
      END ;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 25RET '||SQLERRM;
        RETURN;
  END processa_arquivo_25RET;

  PROCEDURE processa_registro_25RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           )  IS
  BEGIN
      UPDATE tbdomic_liqtrans_pdv d
         SET d.dhretorno = SYSDATE
       WHERE nrliquidacao = pr_nuliquid;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_nuliquid||'. '||SQLERRM;
  END processa_registro_25RET_aceito ;

  PROCEDURE processa_reg_25RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF            IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2) IS

  BEGIN
      UPDATE tbdomic_liqtrans_pdv d
         SET d.cdocorrencia_retorno = pr_codocorc,
             d.dsocorrencia_retorno = pr_erro,
             d.dhretorno = SYSDATE
       WHERE nrliquidacao = pr_NULiquidRec;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_NULiquidRec||'. '||SQLERRM;

  END processa_reg_25RET_rejeitado ;

  PROCEDURE processa_arquivo_25err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2) IS           --> Descricao do erro
    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq               VARCHAR2(1000);
    vr_numctrlemis          VARCHAR2(80);
    vr_numctrldestor        VARCHAR2(20);
    vr_ispbemissor          VARCHAR2(08);
    vr_ispbdestinatario     VARCHAR2(08);
    vr_dthrarq              VARCHAR2(19);
    vr_dtref                VARCHAR2(10);

    vr_para                 VARCHAR2(1000);
    vr_assunto              VARCHAR2(1000);
    vr_mensagem             VARCHAR2(32000);
    vr_idarquivo            NUMBER;
    vr_dscritic             VARCHAR2(32000);
    vr_iderro               NUMBER := 0;
    vr_executado            VARCHAR2(01);
    vr_erro                 VARCHAR2(100);
    vr_idcampo              VARCHAR2(1000);
    w_indice_cab            NUMBER;
    vr_exc_saida            EXCEPTION;

  BEGIN
------------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      vr_iderro    := 0;

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S','ERR');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'CodErro','S');
      IF vr_erro IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'CodErro';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro processo TAB. Arquivo 25ERR: '||SQLERRM;
         RAISE;
    END;

    IF vr_iderro = 0 THEN
      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                               ,pr_NumCtrlEmis      => NULL
                               ,pr_NumCtrlDestOr    => NULL
                               ,pr_ISPBEmissor      => NULL
                               ,pr_ISPBDestinatario => NULL
                               ,pr_DtHrArq          => NULL
                               ,pr_DtRef            => NULL
                               ,pr_idarquivo        => vr_idarquivo
                               ,pr_iderro           => vr_iderro
                               ,pr_dscritic         => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_iderro = 0 THEN
      BEGIN
        vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET25');
        vr_assunto  := 'Domicílio Bancário - arquivo '||vr_nomarq||' com erro';
        vr_mensagem := 'Erro no processamento do arquivo '||vr_nomarq||
                       ':<br /><br />'||
                       vr_erro;

        pc_envia_email(pr_cdcooper   => 1
                      ,pr_dspara     => vr_para
                      ,pr_dsassunto  => vr_assunto
                      ,pr_dstexto    => vr_mensagem
                      ,pr_dscritic   => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END ;
    END IF;
  EXCEPTION
  WHEN vr_exc_saida THEN
    pr_dscritic := vr_dscritic;
    RETURN;
  WHEN OTHERS THEN
    pr_dscritic := 'ERRO geral ao gerar o arquivo 25ERR '||SQLERRM;
    RETURN;
  END processa_arquivo_25err;

  PROCEDURE pc_gera_critica (pr_nomearq   IN VARCHAR2
                            ,pr_idcampo   IN VARCHAR2
                            ,pr_dscritic  IN OUT VARCHAR2
                            ,pr_cdocorr   IN NUMBER DEFAULT NULL) IS
    CURSOR c1 (pr_nomarq IN VARCHAR2) IS
      SELECT tla.idarquivo
        FROM tbdomic_liqtrans_arquivo  tla
       WHERE tla.nmarquivo_gerado = replace(pr_nomarq,'_RET','');
    r1       c1%ROWTYPE;

    vr_idarquivo                  tbdomic_liqtrans_arquivo.idarquivo%TYPE;
    vr_dscritic                   VARCHAR2(32000);
    vr_exc_saida                  EXCEPTION;

  BEGIN
      -- BUSCA ID DO ARQUIVO PARA INCLUSÃO NA TABELA
      OPEN c1 (pr_nomearq);
      FETCH c1 INTO r1;
      vr_idarquivo := r1.idarquivo;
      CLOSE C1;

      --
      IF vr_idarquivo IS NULL THEN
        -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
        insere_arq_liq_transacao  (pr_nomarq           => pr_nomearq,
                                   pr_NumCtrlEmis      => null,
                                   pr_NumCtrlDestOr    => null,
                                   pr_ISPBEmissor      => null,
                                   pr_ISPBDestinatario => null,
                                   pr_DtHrArq          => null,
                                   pr_DtRef            => null,
                                   pr_idarquivo        => vr_idarquivo,
                                   pr_iderro           => null,
                                   pr_dscritic         => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- INSERT NA TABELA TBDOMIC_CRITICA_LOG
      INSERT INTO tbdomic_liqtrans_critica
                 (idarquivo
                 ,dscampo
                 ,nrcontador
                 ,cdocorrencia
                 ,dscritica
                 ,dtcritica
                 ) VALUES
                 (vr_idarquivo
                 ,pr_idcampo
                 ,NULL
                 ,pr_cdocorr
                 ,substr(pr_dscritic,1,300)
                 ,SYSDATE
                 );

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo critica '||SQLERRM;
        RETURN;
  END;

  PROCEDURE processa_arquivo_32(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                               ,pr_dscritic OUT VARCHAR2) IS
    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq                 VARCHAR2(1000);
    vr_numctrlemis            VARCHAR2(80);
    vr_numctrldestor          VARCHAR2(20);
    vr_ispbemissor            VARCHAR2(08);
    vr_ispbdestinatario       VARCHAR2(08);
    vr_dthrarq                VARCHAR2(19);
    vr_dtref                  VARCHAR2(10);

    -- variaveis tab tbdomic_liqtrans_lancto
    vr_identdpartprincipal    VARCHAR2(8);
    vr_identdpartadmtd        VARCHAR2(8);
    vr_cnpjbasecreddr         VARCHAR2(8);
    vr_cnpjcreddr             NUMBER(14);
    vr_ispbifdevdr            VARCHAR2(8);
    vr_ispbifcredr            VARCHAR2(8);
    vr_agcreddr               NUMBER(4);
    vr_ctcreddr               NUMBER(13);
    vr_nomcreddr              VARCHAR2(80);

    vr_idlancto               NUMBER;

    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_CENTRALIZA
    vr_tppessoacentrlz        VARCHAR2(01);
    vr_cnpj_cpfcentrlz        NUMBER(14);
    vr_codcentrlz             VARCHAR2(25);
    vr_tpct                   VARCHAR2(02);
    vr_ctpgtocentrlz          NUMBER(20);
    vr_agcentrlz              NUMBER(13);
    vr_ctcentrlz              NUMBER(13);

    vr_idcentraliza           NUMBER;

    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_PDV
    vr_nuliquid               VARCHAR2(21);
    vr_ispbifliquidpontovenda VARCHAR2(08);
    vr_codpontovenda          VARCHAR2(25);
    vr_nomepontovenda         VARCHAR2(80);
    vr_tppessoapontovenda     VARCHAR2(01);
    vr_cnpj_cpfpontovenda     NUMBER(14);
    vr_codinstitdrarrajpgto   VARCHAR2(3);
    vr_tpprodliquidded        NUMBER(02) ;
    vr_indrformatransf        VARCHAR2(01);
    vr_codmoeda               NUMBER(03);
    vr_dtpgto                 VARCHAR2(10);
    vr_vlrpgto                NUMBER(19,2);
    vr_dthrmanut              VARCHAR2(19);
    vr_codocorc               VARCHAR2(2) ;
    vr_numctrlifacto          VARCHAR2(20);
    vr_numctrlcipaceito       VARCHAR2(20);

    vr_idcampo                VARCHAR2(1000);
    vr_idpdv                  NUMBER;
    vr_idarquivo              NUMBER;
    vr_dscritic               VARCHAR2(32000);
    vr_contador               PLS_INTEGER;
    vr_contador_lqd           PLS_INTEGER;
    vr_contador_pve           PLS_INTEGER;
    vr_contador_ctz           PLS_INTEGER;
    vr_iderro                 NUMBER(01);
    vr_executado              VARCHAR2(01);
    w_idloop                  NUMBER;
    w_dscampo                 VARCHAR2(1000);
    w_indice_cab              NUMBER;
    w_indice                  NUMBER;
    vr_exc_saida              EXCEPTION;

  BEGIN
    -- Inicializa o contador de consultas
    vr_contador := 1;
    w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
    w_indice     := 1;                       -- Posiciona na primeira linha do arquivo XML

    LOOP

      vr_nomarq             := NULL;
      vr_NumCtrlEmis        := NULL;
      vr_NumCtrlDestOr      := NULL;
      vr_ISPBEmissor        := NULL;
      vr_ISPBDestinatario   := NULL;
      vr_DtHrArq            := NULL;
      vr_DtRef              := NULL;
      vr_iderro             := NULL;


      -- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
      BEGIN
        -- Verifica se existe dados na consulta
        IF pr_table_of.count() = 0 THEN
          EXIT;
        END IF;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        --Busca os campos do detalhe da consulta
        vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
        IF vr_nomarq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        -- valida se o arquivo com esse nome já foi processado.
        vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

        IF vr_executado = 'S' THEN
           EXIT;
        END IF;

        vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
        IF vr_NumCtrlEmis IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlEmis';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
        IF vr_NumCtrlDestOr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlDestOr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
        IF vr_ISPBEmissor IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBEmissor';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
        IF vr_ISPBDestinatario IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBDestinatario';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
        IF vr_DtHrArq IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrArq';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
        IF vr_DtRef IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtRef';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
          RAISE;
      END;

      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                               ,pr_NumCtrlEmis      => vr_NumCtrlEmis
                               ,pr_NumCtrlDestOr    => vr_NumCtrlDestOr
                               ,pr_ISPBEmissor      => vr_ISPBEmissor
                               ,pr_ISPBDestinatario => vr_ISPBDestinatario
                               ,pr_DtHrArq          => vr_DtHrArq
                               ,pr_DtRef            => vr_DtRef
                               ,pr_idarquivo        => vr_idarquivo
                               ,pr_iderro           => vr_iderro
                               ,pr_dscritic         => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- BUSCA DADOS DA TABELA TBDOMIC_LIQTRANS_LANCTO
      vr_contador_lqd := 1;

      -- Posicionar o arquivo no inicio do arquivo XML
      BEGIN
        w_idloop := 0; -- controle de execução do loop

        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<SISARQ';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            w_idloop := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      LOOP

        vr_IdentdPartPrincipal  := NULL;
        vr_IdentdPartAdmtd      := NULL;
        vr_CNPJBaseCreddr       := NULL;
        vr_CNPJCreddr           := NULL;
        vr_ISPBIFDevdr          := NULL;
        vr_ISPBIFCredr          := NULL;
        vr_AgCreddr             := NULL;
        vr_CtCreddr             := NULL;
        vr_NomCreddr            := NULL;
        vr_iderro               := NULL;

        -- Posiciona na TAG de início do bloco
        BEGIN
          w_idloop := 0; -- controle de execução do loop
          w_indice := w_indice + 1;
          w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC032_LiquidTranscCarts','S');
          IF w_dscampo IS NULL THEN
            vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
            vr_idcampo := '<Grupo_ASLC032_LiquidTranscCarts';
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => vr_idcampo
                           ,pr_dscritic => vr_dscritic);
            vr_iderro := 1;
          ELSE
            IF w_dscampo <> 'OK' THEN
              w_idloop := 1;
              w_indice := w_indice - 1;
            END IF;
          END IF;
        END;

        -- Controla a execução do loop
        IF w_idloop = 1 THEN
          w_idloop := 0;
          EXIT;
        END IF;

        vr_IdentdPartPrincipal := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartPrincipal','S');
        IF vr_IdentdPartPrincipal IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartPrincipal';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        -- Verifica se existe dados na consulta
        IF NVL(vr_IdentdPartPrincipal,0) = 0 THEN
           EXIT;
        END  IF;

        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_CNPJBaseCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJBaseCreddr','S');
        IF vr_CNPJBaseCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJBaseCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_CNPJCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJCreddr','S');
        IF vr_CNPJCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CNPJCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBIFDevdr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFDevdr','S');
        IF vr_ISPBIFDevdr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFDevdr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_ISPBIFCredr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFCredr','S');
        IF vr_ISPBIFCredr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'ISPBIFCredr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_AgCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCreddr','S');
        IF vr_AgCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'AgCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_CtCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCreddr','S');
        IF vr_CtCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'CtCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END IF;

        vr_NomCreddr := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomCreddr','S');
        IF vr_NomCreddr IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NomCreddr';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
           vr_iderro := 1;
        END  IF;

        -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
        insere_liquidacao_transacao(pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                   ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                   ,pr_CNPJBaseCreddr      => vr_CNPJBaseCreddr
                                   ,pr_CNPJCreddr          => vr_CNPJCreddr
                                   ,pr_ISPBIFDevdr         => vr_ISPBIFDevdr
                                   ,pr_ISPBIFCredr         => vr_ISPBIFCredr
                                   ,pr_AgCreddr            => vr_AgCreddr
                                   ,pr_CtCreddr            => vr_CtCreddr
                                   ,pr_NomCreddr           => vr_NomCreddr
                                   ,pr_idarquivo           => vr_idarquivo
                                   ,pr_idlancto            => vr_idlancto
                                   ,pr_iderro              => vr_iderro
                                   ,pr_dscritic            => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_CENTRALIZA
        vr_contador_ctz := 1;

        LOOP

          vr_TpPessoaCentrlz     := null;
          vr_CNPJ_CPFCentrlz     := null;
          vr_CodCentrlz          := null;
          vr_TpCt                := null;
          vr_CtPgtoCentrlz       := null;
          vr_AgCentrlz           := null;
          vr_CtCentrlz           := null;
          vr_iderro              := 0;

          -- Posiciona na TAG de final do bloco
          BEGIN
            w_idloop := 0; -- controle de execução do loop
            w_indice := w_indice + 1;
            w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC032_Centrlz','S');
            IF w_dscampo IS NULL THEN
              vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
              vr_idcampo := 'Grupo_ASLC032_Centrlz';
              pc_gera_critica(pr_nomearq => vr_nomarq
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              vr_iderro := 1;
            ELSE
              IF w_dscampo <> 'OK' THEN
                w_idloop := 1;
                w_indice := w_indice - 1;
              END IF;
            END IF;
          END;

          -- Controla a execução do loop
          IF w_idloop = 1 THEN
            w_idloop := 0;
            EXIT;
          END IF;

          vr_TpPessoaCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaCentrlz','S');
          IF vr_TpPessoaCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpPessoaCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_CNPJ_CPFCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFCentrlz','S');
          IF vr_CNPJ_CPFCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CNPJ_CPFCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          -- Verifica se existe dados na consulta
          IF nvl(vr_CNPJ_CPFCentrlz,0) = 0 THEN
             EXIT;
          END IF;

          vr_CodCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodCentrlz','S');
          IF vr_CodCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_TpCt := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpCt','S');
          IF vr_TpCt IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'TpCt';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_AgCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'AgCentrlz','S');
          IF vr_AgCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'AgCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          vr_CtCentrlz := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CtCentrlz','S');
          IF vr_CtCentrlz IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CtCentrlz';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
             vr_iderro := 1;
          END IF;

          -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
          IF NVL(vr_iderro,0) = 1 THEN
             pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                        ,pr_dscritic  => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
                -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                NULL;
             END IF;
          END IF;

          -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
          insere_liq_trn_central( pr_TpPessoaCentrlz  => vr_TpPessoaCentrlz
                                 ,pr_CNPJ_CPFCentrlz  => vr_CNPJ_CPFCentrlz
                                 ,pr_CodCentrlz       => vr_CodCentrlz
                                 ,pr_TpCt             => vr_TpCt
                                 ,pr_CtPgtoCentrlz    => vr_CtPgtoCentrlz
                                 ,pr_AgCentrlz        => vr_AgCentrlz
                                 ,pr_CtCentrlz        => vr_CtCentrlz
                                 ,pr_idlancto         => vr_idlancto
                                 ,pr_idcentraliza     => vr_idcentraliza
                                 ,pr_dscritic         => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- BUSCA DADOS TABELA TBDOMIC_LIQTRANS_PDV
          vr_contador_pve := 1;

          LOOP

            vr_NULiquid                 := null;
            vr_ISPBIFLiquidPontoVenda   := null;
            vr_CodPontoVenda            := null;
            vr_NomePontoVenda           := null;
            vr_TpPessoaPontoVenda       := null;
            vr_CNPJ_CPFPontoVenda       := null;
            vr_CodInstitdrArrajPgto     := null;
            vr_TpProdLiquidDed          := null;
            vr_IndrFormaTransf          := null;
            vr_CodMoeda                 := null;
            vr_DtPgto                   := null;
            vr_VlrPgto                  := null;
            vr_DtHrManut                := null;
            vr_codocorc                 := null;
            vr_numctrlifacto            := null;
            vr_numctrlcipaceito         := null;
            vr_iderro                   := 0;

            -- Posiciona na TAG de início do bloco
            BEGIN
              w_idloop := 0; -- controle de execução do loop
              w_indice := w_indice + 1;
              w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC032_PontoVenda','S');
              IF w_dscampo IS NULL THEN
                vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
                vr_idcampo := 'Grupo_ASLC032_PontoVenda';
                pc_gera_critica(pr_nomearq => vr_nomarq
                               ,pr_idcampo => vr_idcampo
                               ,pr_dscritic => vr_dscritic);
                vr_iderro := 1;
              ELSE
                IF w_dscampo <> 'OK' THEN
                  w_idloop := 1;
                  w_indice := w_indice - 1;
                END IF;
              END IF;
            END;
            -- Controla a execução do loop
            IF w_idloop = 1 THEN
              w_idloop := 0;
              EXIT;
            END IF;

            vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
            IF vr_NULiquid IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'NULiquid';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            -- Verifica se existe dados na consulta
            IF nvl(vr_NULiquid,0) = 0 THEN
               EXIT;
            END IF;

            vr_ISPBIFLiquidPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'ISPBIFLiquidPontoVenda','S');
            IF vr_ISPBIFLiquidPontoVenda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'ISPBIFLiquidPontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_CodPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodPontoVenda','S');
            IF vr_CodPontoVenda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodPontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_NomePontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NomePontoVenda','S');
            IF vr_NomePontoVenda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'NomePontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_TpPessoaPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpPessoaPontoVenda','S');
            IF vr_TpPessoaPontoVenda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'TpPessoaPontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_CNPJ_CPFPontoVenda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CNPJ_CPFPontoVenda','S');
            IF vr_CNPJ_CPFPontoVenda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CNPJ_CPFPontoVenda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_CodInstitdrArrajPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodInstitdrArrajPgto','S');
            IF vr_CodInstitdrArrajPgto IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodInstitdrArrajPgto';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_TpProdLiquidDed := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'TpProdLiquidCarts','S');
            IF vr_TpProdLiquidDed IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'TpProdLiquidCarts';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_IndrFormaTransf := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IndrFormaTransf','S');
            IF vr_IndrFormaTransf IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'IndrFormaTransf';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_CodMoeda := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodMoeda','S');
            IF vr_CodMoeda IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodMoeda';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_DtPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtPgto','S');
            IF vr_DtPgto IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'DtPgto';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_VlrPgto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'VlrPgto','S');
            IF vr_VlrPgto IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'VlrPgto';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
            IF vr_DtHrManut IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'DtHrManut';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
               vr_iderro := 1;
            END IF;

            -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
            IF NVL(vr_iderro,0) = 1 THEN
               pc_atualiza_transacao_erro (pr_idlancto  => vr_idlancto
                                          ,pr_dscritic  => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                  -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                  NULL;
               END IF;
            END IF;

            -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
            insere_liq_trn_cen_pve (pr_NULiquid                => vr_NULiquid
                                   ,pr_ISPBIFLiquidPontoVenda  => vr_ISPBIFLiquidPontoVenda
                                   ,pr_CodPontoVenda           => vr_CodPontoVenda
                                   ,pr_NomePontoVenda          => vr_NomePontoVenda
                                   ,pr_TpPessoaPontoVenda      => vr_TpPessoaPontoVenda
                                   ,pr_CNPJ_CPFPontoVenda      => vr_CNPJ_CPFPontoVenda
                                   ,pr_CodInstitdrArrajPgto    => vr_CodInstitdrArrajPgto
                                   ,pr_TpProdLiquidCred        => vr_TpProdLiquidDed
                                   ,pr_IndrFormaTransf         => vr_IndrFormaTransf
                                   ,pr_CodMoeda                => vr_CodMoeda
                                   ,pr_DtPgto                  => vr_DtPgto
                                   ,pr_VlrPgto                 => vr_VlrPgto
                                   ,pr_DtHrManut               => vr_DtHrManut
                                   ,pr_codocorc                => vr_codocorc
                                   ,pr_numctrlifacto           => vr_numctrlifacto
                                   ,pr_numctrlcipaceito        => vr_numctrlcipaceito
                                   ,pr_idcentraliza            => vr_idcentraliza
                                   ,pr_idpdv                   => vr_idpdv
                                   ,pr_dscritic                => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            vr_contador_pve := vr_contador_pve + 1;
            -- FIM TABELA   TBDOMIC_LIQ_TRN_CEN_PVE
          END LOOP;

          vr_contador_ctz := vr_contador_ctz + 1;
          -- FIM TABELA   TBDOMIC_LIQ_TRN_CENTRAL

          -- Posiciona na TAG de final do bloco
          BEGIN
            w_idloop := 0; -- controle de execução do loop
            w_indice := w_indice + 1;
            w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC032_Centrlz','S');
            IF w_dscampo IS NULL THEN
              vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
              vr_idcampo := '/Grupo_ASLC032_Centrlz';
              pc_gera_critica(pr_nomearq => vr_nomarq
                             ,pr_idcampo => vr_idcampo
                             ,pr_dscritic => vr_dscritic);
              vr_iderro := 1;
            ELSE
              IF w_dscampo <> 'OK' THEN
                w_idloop := 1;
                w_indice := w_indice - 1;
              END IF;
            END IF;
          END;

        END LOOP;

        vr_contador_lqd := vr_contador_lqd + 1;
        -- FIM TABELA   TBDOMIC_LIQTRANS_LANCTO

        -- Posiciona na TAG de final do bloco
        BEGIN
          w_idloop := 0; -- controle de execução do loop
          w_indice := w_indice + 1;
          w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/Grupo_ASLC032_LiquidTranscCarts','S');
          IF w_dscampo IS NULL THEN
            vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
            vr_idcampo := '/Grupo_ASLC032_LiquidTranscCarts';
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => vr_idcampo
                           ,pr_dscritic => vr_dscritic);
            vr_iderro := 1;
          ELSE
            IF w_dscampo <> 'OK' THEN
              w_idloop := 1;
              w_indice := w_indice - 1;
            END IF;
          END IF;
        END;

      END LOOP;

      vr_contador := vr_contador + 1;
      --FIM TABELA  TBDOMIC_LIQTRANS_ARQUIVO

      -- Posiciona na TAG de final do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'/SISARQ','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '/SISARQ';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            w_idloop := 1;
            w_indice := w_indice - 1;
          ELSE
            w_idloop := 1;
          END IF;
        END IF;
      END;

    END LOOP;
    dbms_output.put_line('Número de linhas processadas do arquivo '||vr_nomarq||' = '||w_indice);
  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 32 '||SQLERRM;
        RETURN;

  END processa_arquivo_32;

  PROCEDURE gera_arquivo_xml_33 (pr_dscritic IN OUT VARCHAR2) IS

    CURSOR c0 IS
      SELECT d.idarquivo
            ,d.nrispb_emissor
            ,nrcontrole_emissor
            ,nrcontrole_dest_original
            ,nrispb_destinatario
            ,d.dtreferencia
        FROM tbdomic_liqtrans_arquivo d
       WHERE SUBSTR(d.nmarquivo_origem,1,7) = 'ASLC032'
         AND nmarquivo_gerado IS NULL
         AND EXISTS
             (select 'x'
                FROM tbdomic_liqtrans_lancto tll
                    ,tbdomic_liqtrans_centraliza tlc
                    ,tbdomic_liqtrans_pdv tlp
               WHERE tll.idlancto = tlc.idlancto
               AND tll.idarquivo = d.idarquivo
               AND tlc.idcentraliza = tlp.idcentraliza
               AND tll.insituacao in (1)); -- os pendentes e os com erro

    CURSOR c1 (pr_idarquivo IN NUMBER) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.idpdv
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
      WHERE tll.idlancto = tlc.idlancto
        AND tll.idarquivo = pr_idarquivo
        AND tlc.idcentraliza = tlp.idcentraliza
        AND tll.insituacao in (1); -- os pendentes e os com erro

    CURSOR c2 IS
      SELECT TO_NUMBER(LPAD(fn_sequence (pr_nmtabela => 'tbdomic_liqtrans_arquivo'
                                        ,pr_nmdcampo => 'TPARQUIVO'
                                        ,pr_dsdchave => 3),4,'0'))  seq
        FROM dual;
      r2 c2%ROWTYPE;

    vr_dscritic      VARCHAR2(32000);
    vr_contador      PLS_INTEGER := 0;
    vr_caminho       VARCHAR2(1000);
    vr_arquivo       VARCHAR2(1000);
    vr_retxml        XMLTYPE;
    vr_nrsequencia   NUMBER;
    vr_clob          CLOB;
    vr_xml_temp      VARCHAR2(32726) := '';

    vr_nomarq        VARCHAR2(1000);
    vr_exc_saida           EXCEPTION;
  BEGIN
    FOR r0 IN c0 LOOP
      -- busca a sequencia para o nome do arquivo
      OPEN c2;
      FETCH c2 INTO r2;
      vr_nrsequencia := r2.seq;
      CLOSE c2;

      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?>');


      vr_nomarq := 'ASLC033_'||r0.nrispb_destinatario||'_'||to_char(sysdate,'YYYYMMDD')||'_'||lpad(vr_nrsequencia,5,'0');
      vr_arquivo :=  vr_nomarq ||'.XML';
      -- Cria o nó inicial do XML
/*      vr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><ASLC033/>');
--
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC033',pr_posicao => 0, pr_tag_nova => NULL, pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC033',pr_posicao => 0, pr_tag_nova => 'BCARQ', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      -- Gera o cabeçalho do arquivo.
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NomArq', pr_tag_cont => vr_arquivo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlEmis', pr_tag_cont => r0.nrcontrole_emissor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'NumCtrlDestOr', pr_tag_cont => r0.nrcontrole_dest_original, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'ISPBDestinatario', pr_tag_cont => r0.nrispb_destinatario, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtHrArq', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd hh24:mi:ss'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'BCARQ',pr_posicao => 0, pr_tag_nova => 'DtRef', pr_tag_cont => to_char(SYSDATE,'yyyy-mm-dd'), pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'ASLC033',pr_posicao => 0, pr_tag_nova => 'SISARQ', pr_tag_cont => NULL, pr_des_erro =>   vr_dscritic);
*/
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<ASLCDOC xmlns="http://www.cip-bancos.org.br/ARQ/ASLC033.xsd">'||
                                                   '<BCARQ>'||
                                                   '<NomArq>'     || vr_nomarq     ||'</NomArq>'||
                                                   '<NumCtrlEmis>'    || to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r0.idarquivo,12,'0')    ||'</NumCtrlEmis>'||
                                                --   '<NumCtrlDestOr>'    || r0.nrcontrole_dest_original  ||'</NumCtrlDestOr>'||
                                                   '<ISPBEmissor>' || r0.nrispb_destinatario ||'</ISPBEmissor>'||
                                                   '<ISPBDestinatario>' || r0.nrispb_emissor ||'</ISPBDestinatario>'||
                                                   '<DtHrArq>'   || to_char(SYSDATE,'yyyy-mm-dd')||'T'||to_char(SYSDATE,'hh24:mi:ss')   ||'</DtHrArq>'||
                                                   '<DtRef>'       || to_char(SYSDATE,'yyyy-mm-dd')     ||'</DtRef>'||
                                                   '</BCARQ>'||
                                                   '<SISARQ>'||
                                                   '<ASLC033>');
      -- Efetua loop sobre os registros do arquivo 023
      FOR r1 IN c1 (pr_idarquivo => r0.idarquivo) LOOP
        -- Gera os detalhes
/*        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'SISARQ',pr_posicao => 0, pr_tag_nova => 'Grupo_ASLC033_LiquidTranscCarts', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC033_LiquidTranscCarts',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartPrincipal', pr_tag_cont => to_char(r1.nrcnpjbase_principal), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC033_LiquidTranscCarts',   pr_posicao => vr_contador, pr_tag_nova => 'IdentdPartAdmtd', pr_tag_cont => to_char(r1.nrcnpjbase_administrado), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC033_LiquidTranscCarts',   pr_posicao => vr_contador, pr_tag_nova => 'NumCtrlIF', pr_tag_cont => to_char(r1.nrispb_devedor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC033_LiquidTranscCarts',   pr_posicao => vr_contador, pr_tag_nova => 'NULiquid', pr_tag_cont => to_char(r1.nrliquidacao), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Grupo_ASLC033_LiquidTranscCarts',   pr_posicao => vr_contador, pr_tag_nova => 'CodOcorc', pr_tag_cont => to_char(r1.cdocorrencia), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;*/
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     =>  '<Grupo_ASLC033_LiquidTranscCarts>'||
                                                     '<IdentdPartPrincipal>'     || to_char(r1.nrcnpjbase_principal)     ||'</IdentdPartPrincipal>'||
                                                     '<IdentdPartAdmtd>'    || to_char(r1.nrcnpjbase_administrado)    ||'</IdentdPartAdmtd>'||
                                                     '<NumCtrlIF>'    ||   to_char(to_date(r0.dtreferencia,'yyyy-mm-dd'),'yyyymmdd')||lpad(r1.idpdv,12,'0')  ||'</NumCtrlIF>'||
                                                     '<NULiquid>' || to_char(r1.nrliquidacao) ||'</NULiquid>'||
                                                     '<CodOcorc>'   || to_char(r1.cdocorrencia)  ||'</CodOcorc>'||
                                                     '</Grupo_ASLC033_LiquidTranscCarts>');

      END LOOP;

      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</ASLC033></SISARQ></ASLCDOC>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      -- vr_retxml := xmltype(vr_clob);
      BEGIN
        vr_caminho := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO_SLC');
        IF substr(vr_caminho, length(vr_caminho)) != '/' then
          vr_caminho := vr_caminho ||'/'||'envia';
        ELSE
          vr_caminho := vr_caminho ||'envia';
        END IF;

        IF vr_database_name = 'AYLLOSD' THEN
          vr_caminho := '/usr/sistemas/SLC/envia';
        END IF;
        --vr_caminho := '/usr/sistemas/SLC/envia';

      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao ler o caminho cadastrado na gene0001.fn_pam_sistema'||SQLERRM;
           pc_gera_critica(pr_nomearq => vr_arquivo
                          ,pr_idcampo => 'Caminho'
                          ,pr_dscritic => vr_dscritic);
      END;

      -- gera o arquivo no diretório padrão
      GENE0002.pc_XML_para_arquivo (pr_XML       => vr_clob    --> Instância do CLOB Type
                                   ,pr_caminho   => vr_caminho --> Diretório para saída
                                   ,pr_arquivo   => vr_arquivo --> Nome do arquivo de saída
                                   ,pr_des_erro  => vr_dscritic );

      -- Atualiza arquivo origem com o nome do arquivo gerado.
      atualiza_nome_arquivo (pr_idtipoarquivo    => 1
                            ,pr_nomearqorigem    => r0.idarquivo
                            ,pr_nomearqatualizar => vr_nomarq
                            ,pr_dscritic         => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         pc_gera_critica(pr_nomearq => vr_arquivo
                        ,pr_idcampo => 'XML_Arquivo'
                        ,pr_dscritic => vr_dscritic);
      END  IF;

    END LOOP;
    COMMIT;

  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 33 '||SQLERRM;
        RETURN;

  END gera_arquivo_xml_33;

  PROCEDURE processa_arquivo_33RET(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2)              --> Descricao do erro
                                  IS

    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq                VARCHAR2(1000);
    vr_numctrlemis           VARCHAR2(80);
    vr_numctrldestor         VARCHAR2(20);
    vr_ispbemissor           VARCHAR2(08);
    vr_ispbdestinatario      VARCHAR2(08);
    vr_dthrarq               VARCHAR2(19);
    vr_dtref                 VARCHAR2(10);

    -- VARIAVEIS TAB RETORNO ACEITO
    vr_identdpartprincipal   VARCHAR2(30);
    vr_identdpartadmtd       VARCHAR2(30);
    vr_numctrlifacto         VARCHAR2(20);
    vr_numctrlcipaceito      VARCHAR2(20);
    vr_nuliquid              VARCHAR2(21);
    vr_dthrmanut             VARCHAR2(19);

     -- VARIAVEIS TAB RETORNO RECUSADO
    vr_identdpartprincipalrec VARCHAR2(30);
    vr_identdpartadmtdrec     VARCHAR2(30);
    vr_NumCtrlIF            VARCHAR2(30);
    vr_nuliquidrec            VARCHAR2(21);
    vr_codocorc               VARCHAR2(2) ;

    vr_idarquivo              NUMBER;
    vr_dscritic               VARCHAR2(32000);
    vr_contador               PLS_INTEGER;
    vr_contador_trs           PLS_INTEGER;
    vr_executado              VARCHAR2(01);
    vr_iderro                 NUMBER(01):=0;

    vr_nomarqorigem           VARCHAR2(1000);
    vr_erro                   VARCHAR2(100);
    vr_domDoc                 DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    -- Váriáveis controle de aceitos / rejeitados
    vr_fim_aceito             NUMBER(01) := 0;
    vr_fim_rejeitado          NUMBER(01) := 0;

    vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                VARCHAR2(4000);
    vr_idcampo                 VARCHAR2(1000);
    w_idloop                   NUMBER;
    w_dscampo                  VARCHAR2(2000);
    w_indice_cab               NUMBER;
    w_indice                   NUMBER;
    vr_exc_saida               EXCEPTION;

    -- Busca o nome do arquivo de origem para atualização do RET
    CURSOR c1 (pr_nomarq IN VARCHAR2) IS
      SELECT tla.nmarquivo_origem
        FROM tbdomic_liqtrans_arquivo  tla
       WHERE tla.nmarquivo_gerado = replace(pr_nomarq,'_RET','');
      r1 c1%ROWTYPE;

    CURSOR c2 (pr_nomarq IN VARCHAR2) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.dsocorrencia_retorno --||decode(tlp.dsocorrencia_retorno,null,null,' - ')||tme.dsmotivo_erro dsocorrencia_retorno
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
           ,tbdomic_liqtrans_arquivo tla
           --,tbdomic_liqtrans_motivo_erro tme
      WHERE tll.idlancto = tlc.idlancto
        AND tla.nmarquivo_retorno = pr_nomarq
        AND tlc.idcentraliza = tlp.idcentraliza
        AND tlp.cdocorrencia_retorno IS NOT NULL
        AND tlp.dsocorrencia_retorno IS NOT NULL
        AND tll.idarquivo = tla.idarquivo;
        --AND tme.cderro(+) = tlp.dsocorrencia_retorno;
  BEGIN

    -- Inicializa o contador de consultas
    vr_contador := 1;

    -- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      w_indice     := 1;                       -- Posiciona na primeira linha do arquivo XML

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      vr_NumCtrlEmis := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlEmis','S');
      IF vr_NumCtrlEmis IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlEmis';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      -- Verifica se existe dados na consulta
      IF NVL(vr_NumCtrlEmis,0) = 0 THEN
        RETURN;
      END  IF;

      vr_NumCtrlDestOr := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NumCtrlDestOr','S');
      IF vr_NumCtrlDestOr IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NumCtrlDestOr';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBEmissor := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBEmissor','S');
      IF vr_ISPBEmissor IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBEmissor';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_ISPBDestinatario := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'ISPBDestinatario','S');
      IF vr_ISPBDestinatario IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'ISPBDestinatario';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtHrArq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtHrArq','S');
      IF vr_DtHrArq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtHrArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

      vr_DtRef := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'DtRef','S');
      IF vr_DtRef IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'DtRef';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END  IF;

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro processo TAB. Arquivo Liquidação Transações de Crédito-'||vr_contador||': '||SQLERRM;
        RAISE;
    END;

    -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
    insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                             ,pr_NumCtrlEmis      => vr_NumCtrlEmis
                             ,pr_NumCtrlDestOr    => vr_NumCtrlDestOr
                             ,pr_ISPBEmissor      => vr_ISPBEmissor
                             ,pr_ISPBDestinatario => vr_ISPBDestinatario
                             ,pr_DtHrArq          => vr_DtHrArq
                             ,pr_DtRef            => vr_DtRef
                             ,pr_idarquivo        => vr_idarquivo
                             ,pr_iderro           => vr_iderro
                             ,pr_dscritic         => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_fim_aceito := 0;
    vr_fim_rejeitado := 0;
    -- Inicializa o contador de consultas
    vr_contador_trs := 1;

    -- Posicionar o arquivo no inicio do arquivo XML
    BEGIN
      w_idloop := 0; -- controle de execução do loop

      w_indice := w_indice + 1;
      w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<SISARQ','S');
      IF w_dscampo IS NULL THEN
        vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
        vr_idcampo := '<SISARQ';
        pc_gera_critica(pr_nomearq => vr_nomarq
                       ,pr_idcampo => vr_idcampo
                       ,pr_dscritic => vr_dscritic);
        vr_iderro := 1;
      ELSE
        IF w_dscampo <> 'OK' THEN
          w_idloop := 1;
          w_indice := w_indice - 1;
        END IF;
      END IF;
    END;

    LOOP
      vr_fim_rejeitado := 0;

      -- CARTÕES ACEITOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC033RET_LiquidTranscCartsActo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC033RET_LiquidTranscCartsActo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_aceito := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF vr_fim_aceito = 0 THEN
         --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtd := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtd IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_numctrlifacto := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIFActo','S');
        IF vr_numctrlifacto IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIFActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_numctrlcipaceito := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlCIPActo','S');
        IF vr_numctrlcipaceito IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlCIPActo';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_NULiquid := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
        IF vr_NULiquid IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NULiquid';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_DtHrManut := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'DtHrManut','S');
        IF vr_DtHrManut IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'DtHrManut';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END  IF;

        -- processa o registro de aceite.
        processa_registro_33RET_aceito (pr_IdentdPartPrincipal => vr_IdentdPartPrincipal
                                       ,pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd
                                       ,pr_numctrlifacto       => vr_numctrlifacto
                                       ,pr_numctrlcipaceito    => vr_numctrlcipaceito
                                       ,pr_NULiquid            => vr_NULiquid
                                       ,pr_DtHrManut           => to_date(substr(vr_DtHrManut,1,10),'yyyy-mm-dd')
                                       ,pr_dscritic            => vr_dscritic ) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => NULL
                          ,pr_dscritic => vr_dscritic);
        END IF;
      END IF;

      -- CARTÕES REJEITADOS
      -- Posiciona na TAG de início do bloco
      BEGIN
        w_idloop := 0; -- controle de execução do loop
        w_indice := w_indice + 1;
        w_dscampo := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'<Grupo_ASLC033RET_LiquidTranscCartsRecsdo','S');
        IF w_dscampo IS NULL THEN
          vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
          vr_idcampo := '<Grupo_ASLC033RET_LiquidTranscCartsRecsdo';
          pc_gera_critica(pr_nomearq => vr_nomarq
                         ,pr_idcampo => vr_idcampo
                         ,pr_dscritic => vr_dscritic);
          vr_iderro := 1;
        ELSE
          IF w_dscampo <> 'OK' THEN
            vr_fim_rejeitado := 1;
            w_indice := w_indice - 1;
          END IF;
        END IF;
      END;

      IF nvl(vr_fim_rejeitado,0) = 0 THEN
         --Busca os campos dos cartões aceitos
        --Busca os campos dos cartões aceitos
        vr_IdentdPartAdmtdRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'IdentdPartAdmtd','S');
        IF vr_IdentdPartAdmtdRec IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'IdentdPartAdmtd';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_NumCtrlIF := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NumCtrlIF','S');
        IF vr_NumCtrlIF IS NULL THEN
           vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
           vr_idcampo := 'NumCtrlIF';
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => vr_idcampo
                          ,pr_dscritic => vr_dscritic);
        END IF;

        vr_erro := null;

        -- Buscar NULiquid se ocorreu erro
        vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','N');
        IF vr_NULiquidRec IS NOT NULL THEN
          -- BUscar o erro que ocorreu no NULiquid
          vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid CodErro','S','S');
          IF vr_erro IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid CodErro';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        ELSE
          -- Buscar NULiquid sem erro
          vr_NULiquidRec := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'NULiquid','S');
          IF vr_NULiquidRec IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'NULiquid';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;

        -- Buscar CodOcorc se ocorreu erro
        vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','N');
        IF vr_codocorc IS NOT NULL THEN
          IF vr_erro IS NULL then
            vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc CodErro','S','S');
            IF vr_erro IS NULL THEN
               vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
               vr_idcampo := 'CodOcorc CodErro';
               pc_gera_critica(pr_nomearq => vr_nomarq
                              ,pr_idcampo => vr_idcampo
                              ,pr_dscritic => vr_dscritic);
            END IF;
          END IF;
        ELSE
          -- Buscar CodOcorc sem erro
          vr_codocorc := CCRD0006.fn_busca_valor(pr_table_of(w_indice).dslinha,'CodOcorc','S');
          IF vr_codocorc IS NULL THEN
             vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
             vr_idcampo := 'CodOcorc';
             pc_gera_critica(pr_nomearq => vr_nomarq
                            ,pr_idcampo => vr_idcampo
                            ,pr_dscritic => vr_dscritic);
          END IF;
        END IF;
        processa_reg_33RET_rejeitado (pr_IdentdPartPrincipalRec => vr_IdentdPartPrincipalRec
                                     ,pr_IdentdPartAdmtdRec     => vr_IdentdPartAdmtdRec
                                     ,pr_NumCtrlIF            => vr_NumCtrlIF
                                     ,pr_NULiquidRec            => vr_NULiquidRec
                                     ,pr_codocorc               => vr_codocorc
                                     ,pr_erro                   => vr_erro
                                     ,pr_dscritic               => vr_dscritic) ;
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq  => vr_nomarq
                          ,pr_idcampo  => NULL
                           ,pr_dscritic => vr_dscritic
                          ,pr_cdocorr  => vr_codocorc );
        END IF;
      END IF;

      IF nvl(vr_fim_rejeitado,0) = 1 AND
         nvl(vr_fim_aceito,0) = 1 THEN
         EXIT;
      ELSE
         vr_contador_trs := vr_contador_trs + 1;
      END IF;
    END LOOP;

      BEGIN
        -- busca o arquivo origem para atualizar o nome arquivo retornado
        OPEN c1 (vr_nomarq);
        FETCH c1 INTO r1;
        vr_nomarqorigem := r1.nmarquivo_origem;
        CLOSE C1;

        -- Atualiza arquivo origem com o nome do arquivo gerado.
        atualiza_nome_arquivo (pr_idtipoarquivo    => 2
                              ,pr_nomearqorigem    => vr_nomarqorigem
                              ,pr_nomearqatualizar => vr_nomarq
                              ,pr_dscritic         => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
           pc_gera_critica(pr_nomearq => vr_nomarq
                          ,pr_idcampo => 'XML_Arquivo'
                          ,pr_dscritic => vr_dscritic);
        END IF;
      END;
      BEGIN

        --vr_para     := 'roberto.holz@mouts.info';
        vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET33');
        vr_assunto  := 'Domicilio Bancario - Divergencias de retorno do arquivo '||vr_nomarq;
        vr_mensagem := NULL;

        -- monta o e-mail de envio das divergencias (rejeitados).
        FOR r2 IN c2 (vr_nomarq) LOOP
          IF vr_mensagem IS NULL THEN
             vr_mensagem := 'Abaixo a lista de registros com divergência após a execução do arquivo '||vr_nomarq||
                            ':<br /><br />';
          END IF;
           
          vr_mensagem := vr_mensagem ||'<br />'||
                     'Liquidação - '||lpad(r2.nrliquidacao,25,' ')||'<br /> '||
                     'Ocorrência - '||lpad(r2.cdocorrencia,11,' ')||'<br />'||
                     'Erro - '||lpad(r2.dsocorrencia_retorno,11,' ');
          IF length(vr_mensagem) > 3900 THEN
             pc_envia_email(pr_cdcooper   => 1
                           ,pr_dspara     => vr_para
                           ,pr_dsassunto  => vr_assunto
                           ,pr_dstexto    => vr_mensagem
                           ,pr_dscritic   => vr_dscritic);
             vr_mensagem := NULL;
          END IF;
           
        END LOOP;

        IF vr_mensagem IS NOT NULL THEN
           pc_envia_email(pr_cdcooper   => 1
                         ,pr_dspara     => vr_para
                         ,pr_dsassunto  => vr_assunto
                         ,pr_dstexto    => vr_mensagem
                         ,pr_dscritic   => vr_dscritic);
        END IF;

      END ;
  EXCEPTION
     WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        RETURN;
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 33RET'||SQLERRM;
        RETURN;
  END processa_arquivo_33RET;

  PROCEDURE processa_registro_33RET_aceito (pr_IdentdPartPrincipal IN VARCHAR2
                                           ,pr_IdentdPartAdmtd     IN VARCHAR2
                                           ,pr_numctrlifacto       IN VARCHAR2
                                           ,pr_numctrlcipaceito    IN VARCHAR2
                                           ,pr_NULiquid            IN VARCHAR2
                                           ,pr_DtHrManut           IN DATE
                                           ,pr_dscritic            IN OUT VARCHAR2
                                           )  IS
  BEGIN
      UPDATE tbdomic_liqtrans_pdv d
         SET d.dhretorno = SYSDATE
       WHERE nrliquidacao = pr_nuliquid;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_nuliquid||'. '||SQLERRM;
  END processa_registro_33RET_aceito ;

  PROCEDURE processa_reg_33RET_rejeitado (pr_IdentdPartPrincipalRec IN VARCHAR2
                                         ,pr_IdentdPartAdmtdRec     IN VARCHAR2
                                         ,pr_NumCtrlIF            IN VARCHAR2
                                         ,pr_NULiquidRec            IN VARCHAR2
                                         ,pr_codocorc               IN VARCHAR2
                                         ,pr_erro                   IN VARCHAR2
                                         ,pr_dscritic               IN OUT VARCHAR2) IS

  BEGIN
      UPDATE tbdomic_liqtrans_pdv d
         SET d.cdocorrencia_retorno = pr_codocorc,
             d.dsocorrencia_retorno = pr_erro,
             d.dhretorno = SYSDATE
       WHERE nrliquidacao = pr_NULiquidRec;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRo ao atualizar PDV Aceito. Nr Liquidação = '||pr_NULiquidRec||'. '||SQLERRM;

  END processa_reg_33RET_rejeitado ;

  PROCEDURE processa_arquivo_33err(pr_table_of IN GENE0002.typ_tab_tabela --> Tabela com os dados do arquivo XML
                                  ,pr_dscritic OUT VARCHAR2) IS           --> Descricao do erro
    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq               VARCHAR2(1000);
    vr_numctrlemis          VARCHAR2(80);
    vr_numctrldestor        VARCHAR2(20);
    vr_ispbemissor          VARCHAR2(08);
    vr_ispbdestinatario     VARCHAR2(08);
    vr_dthrarq              VARCHAR2(19);
    vr_dtref                VARCHAR2(10);

    vr_para                 VARCHAR2(1000);
    vr_assunto              VARCHAR2(1000);
    vr_mensagem             VARCHAR2(32000);
    vr_idarquivo            NUMBER;
    vr_dscritic             VARCHAR2(32000);
    vr_iderro               NUMBER := 0;
    vr_executado            VARCHAR2(01);
    vr_erro                 VARCHAR2(100);
    vr_idcampo              VARCHAR2(1000);
    w_indice_cab            NUMBER;
    vr_exc_saida            EXCEPTION;

  BEGIN
------------- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------
    BEGIN
      w_indice_cab := pr_table_of.count() - 1; -- Posiciona na TAG de cabeçalho do arquivo XML
      vr_iderro    := 0;

      -- Verifica se existe dados na consulta
      IF pr_table_of.count() = 0 THEN
        RETURN;
      END IF;

      --Busca os campos do detalhe da consulta
      vr_nomarq := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'NomArq','S','ERR');
      IF vr_nomarq IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'NomArq';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      vr_erro := CCRD0006.fn_busca_valor(pr_table_of(w_indice_cab).dslinha,'CodErro','S');
      IF vr_erro IS NULL THEN
         vr_dscritic:= vr_nomarq||' - Campo não encontrado no XML';
         vr_idcampo := 'CodErro';
         pc_gera_critica(pr_nomearq => vr_nomarq
                        ,pr_idcampo => vr_idcampo
                        ,pr_dscritic => vr_dscritic);
         vr_iderro := 1;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro processo TAB. Arquivo 33ERR: '||SQLERRM;
         RAISE;
    END;

    IF vr_iderro = 0 THEN
      -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
      insere_arq_liq_transacao (pr_nomarq           => vr_nomarq
                               ,pr_NumCtrlEmis      => NULL
                               ,pr_NumCtrlDestOr    => NULL
                               ,pr_ISPBEmissor      => NULL
                               ,pr_ISPBDestinatario => NULL
                               ,pr_DtHrArq          => NULL
                               ,pr_DtRef            => NULL
                               ,pr_idarquivo        => vr_idarquivo
                               ,pr_iderro           => vr_iderro
                               ,pr_dscritic         => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    IF vr_iderro = 0 THEN
      BEGIN
        vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET33');
        vr_assunto  := 'Domicílio Bancário - arquivo '||vr_nomarq||' com erro';
        vr_mensagem := 'Erro no processamento do arquivo '||vr_nomarq||
                       ':<br /><br />'||
                       vr_erro;

        pc_envia_email(pr_cdcooper   => 1
                      ,pr_dspara     => vr_para
                      ,pr_dsassunto  => vr_assunto
                      ,pr_dstexto    => vr_mensagem
                      ,pr_dscritic   => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END ;
    END IF;
  EXCEPTION
  WHEN vr_exc_saida THEN
    pr_dscritic := vr_dscritic;
    RETURN;
  WHEN OTHERS THEN
    pr_dscritic := 'ERRO geral ao gerar o arquivo 33ERR '||SQLERRM;
    RETURN;
  END processa_arquivo_33err;

  PROCEDURE pc_atualiza_transacao_erro (pr_idlancto     IN NUMBER
                                       ,pr_dscritic     IN OUT VARCHAR2) IS

  BEGIN
    UPDATE TBDOMIC_LIQTRANS_LANCTO
       SET insituacao = 3  --
     WHERE idlancto = pr_idlancto;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO ao Atualizar a situação para 2 no lancto - '||pr_idlancto||'. |'||SQLERRM;
        RETURN;

  END;

  PROCEDURE atualiza_nome_arquivo (pr_idtipoarquivo    IN NUMBER  -- 1- ARQUIVO ENVIO, 2- ARQUIVO RETORNO
                                  ,pr_nomearqorigem    IN VARCHAR2
                                  ,pr_nomearqatualizar IN VARCHAR2
                                  ,pr_dscritic         IN OUT VARCHAR2) IS
  BEGIN
    IF pr_idtipoarquivo = 1 THEN
      UPDATE tbdomic_liqtrans_arquivo a
         SET a.nmarquivo_gerado = pr_nomearqatualizar
            ,a.dharquivo_gerado = SYSDATE
       WHERE a.idarquivo = pr_nomearqorigem;
      --Elimina código e descrição de ocorrência de retorno para o caso de reprocessamento
      UPDATE tbdomic_liqtrans_pdv pdv
      SET pdv.cdocorrencia_retorno = null
         ,pdv.dsocorrencia_retorno = null
      WHERE pdv.idcentraliza IN
            (SELECT ctz.idcentraliza
               FROM tbdomic_liqtrans_centraliza ctz
              WHERE ctz.idlancto IN
                    (SELECT lct.idlancto
                       FROM tbdomic_liqtrans_lancto lct
                      WHERE lct.idarquivo IN
                            (SELECT arq.idarquivo
                               FROM tbdomic_liqtrans_arquivo arq
                              WHERE arq.idarquivo = pr_nomearqorigem)));
    ELSE
      UPDATE tbdomic_liqtrans_arquivo a
         SET a.nmarquivo_retorno= pr_nomearqatualizar
            ,a.dharquivo_retorno= SYSDATE
       WHERE a.nmarquivo_origem = pr_nomearqorigem;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
         pr_dscritic := 'ERRO ao atualizar nome arquivo!'||SQLERRM;
  END atualiza_nome_arquivo;

  PROCEDURE pc_envia_email(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                          ,pr_dspara      IN VARCHAR2
                          ,pr_dsassunto   IN VARCHAR2
                          ,pr_dstexto     IN VARCHAR2
                          ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                          ) IS                   --> Descrição do erro

    vr_emaildst    VARCHAR2(200);    --> Endereco do e-mail de destino
    vr_dscritic    VARCHAR2(32000);
    vr_exc_saida   EXCEPTION;
    vr_cdcritic    crapcri.cdcritic%TYPE;
   -- vr_mensagem VARCHAR2(10000);
  BEGIN

    gene0003.pc_solicita_email(pr_cdprogra        => 'CCRD0006'
                              ,pr_des_destino     => pr_dspara
                              ,pr_des_assunto     => pr_dsassunto
                              ,pr_des_corpo       => pr_dstexto
                              ,pr_des_anexo       => NULL
                              ,pr_des_erro        => vr_dscritic
                              ,pr_flg_enviar      => 'S');
    -- Caso encontre alguma critica no envio do email
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em pc_email_troca_pa: ' || SQLERRM;
  END pc_envia_email;
  -- Rotina para buscar os lançamentos que foram jogados na CRAPLAU e então
  -- dar a baixa , jogando para a CRAPLCM e no final gerar um arquivo
  -- de retorno confirmando o pagamento da liquidacao
  PROCEDURE pc_efetiva_agendamentos(pr_dtprocesso IN DATE
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   ,pr_dscritic OUT VARCHAR2) IS

    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- cursor sobre as cooperativas ativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
           AND cop.flgativo = 1
         ORDER BY cop.cdcooper;

      -- cursor para buscar os pagamentos agendados para gerar
      -- um arquivo fictício ASLC22 a fim de processar as baixas
      -- dos agendamentos
      CURSOR cr_craplau(pr_cdcooper   crapcop.cdcooper%TYPE
                       ,pr_dtprocesso crapdat.dtmvtolt%TYPE) IS
        SELECT substr(lau.cdseqtel,1,21) nr_liq
              ,arq.idarquivo
              ,arq.nmarquivo_origem
              ,arq.tparquivo
              ,arq.nrcontrole_emissor
              ,arq.nrcontrole_dest_original
              ,arq.nrispb_emissor
              ,arq.nrispb_destinatario
              ,arq.dharquivo_origem
              ,arq.dtreferencia
              ,arq.dhrecebimento
              ,lct.idlancto
              ,lct.nrcnpjbase_principal
              ,lct.nrcnpjbase_administrado
              ,lct.nrcnpj_credenciador
              ,lct.nrispb_devedor
              ,lct.nrispb_credor
              ,lct.cdagencia_credenciador
              ,lct.nrconta_credenciador
              ,lct.nmcredenciador
              ,ctz.idcentraliza
              ,ctz.tppessoa_centraliza
              ,ctz.nrcnpjcpf_centraliza
              ,ctz.cdcentraliza
              ,ctz.tpconta
              ,ctz.cdagencia_centraliza
              ,ctz.nrcta_centraliza
              ,ctz.nrcta_pgto_centraliza
              ,pdv.idpdv
              ,pdv.nrliquidacao
              ,pdv.nrispb_liquid_pdv
              ,pdv.cdpdv
              ,pdv.nmpdv
              ,pdv.tppessoa_pdv
              ,pdv.nrcnpjcpf_pdv
              ,pdv.cdinst_arranjo_pagamento
              ,pdv.tpproduto_credito
              ,pdv.tpforma_transf
              ,pdv.cdmoeda
              ,pdv.dtpagamento
              ,pdv.vlpagamento
              ,pdv.dhmanutencao
              ,pdv.nrcontrole_if
              ,pdv.nrcontrole_cip
          FROM craplau lau
              ,tbdomic_liqtrans_pdv pdv
              ,tbdomic_liqtrans_centraliza ctz
              ,tbdomic_liqtrans_lancto lct
              ,tbdomic_liqtrans_arquivo arq
         WHERE lau.cdcooper = pr_cdcooper
           AND lau.dtmvtopg = pr_dtprocesso
           AND lau.cdhistor in (2442,2443,2444,2445,2450,2453,2478)   -- crédito
           AND lau.dtdebito IS NULL
           AND lct.insituacao in (0,2)          --Alteração necessária para confirmar débito apenas quando retorna arquivo com confirmação
           AND pdv.nrliquidacao = substr(lau.cdseqtel,1,21)
           AND ctz.idcentraliza = pdv.idcentraliza
           AND lct.idlancto = ctz.idlancto
           AND arq.idarquivo = lct.idarquivo
           AND nvl(pdv.dserro,'X') <> 'Agendamento' --Alteração implementada para evitar gerar arquivo PGT em duplicidade
           ORDER BY arq.idarquivo,lct.idlancto,ctz.idcentraliza,pdv.idpdv;

      CURSOR cr_arquivo(pr_nmarquivo   tbdomic_liqtrans_arquivo.nmarquivo_origem%TYPE) IS
        SELECT 'S'
          FROM tbdomic_liqtrans_arquivo
         WHERE nmarquivo_origem = pr_nmarquivo;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;

    -- variaveis

    vr_idarquivo_ant      NUMBER := 0;
    vr_idlancto_ant       NUMBER := 0;
    vr_idcentraliza_ant   NUMBER := 0;
    vr_idpdv_ant          NUMBER := 0;

    vr_idarquivo_novo     NUMBER := 0;
    vr_idlancto_novo      NUMBER := 0;
    vr_idcentraliza_novo  NUMBER := 0;
    vr_idpdv_novo         NUMBER := 0;

    vr_arquivo            VARCHAR2(1000);
    vr_existe_arquivo     VARCHAR2(1) := 'N';
    vr_seq_arquivo        NUMBER := 0;
    vr_dtprocesso         crapdat.dtmvtolt%TYPE;
  BEGIN
    -- lendo cooperativas
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Busca a data da cooperativa
      -- foi incluido aqui pois pode existir contas transferidas
      OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      --Se for banco de desenvolvimento vai usar a data passada na pr_dtprocesso
      --IF vr_database_name != 'AYLLOSD' THEN
      --Alterado para utilizar a data do parâmetro, se for diferente de NULL
      IF pr_dtprocesso IS NULL THEN
        IF rw_crapdat.inproces > 1 THEN  -- Está executando cadeia
          vr_dtprocesso := rw_crapdat.dtmvtopr;
        ELSE
          vr_dtprocesso := rw_crapdat.dtmvtolt;
        END IF;
      ELSE
        vr_dtprocesso   := pr_dtprocesso;
      END IF;

      vr_arquivo := NULL;
      
      -- busca lancamentos agendados para serem efetivados
      FOR rw_craplau IN cr_craplau(rw_crapcop.cdcooper,vr_dtprocesso) LOOP
        -- na quebra de arquivo mudando o nome para ao inves de ter o
        -- sequencial estar com PGTO (ASLC022_05463212_20170808_PGTO)
        -- o IF é o mesmo que está lendo no cursor
        -- a data é a data do processo (vr_dtprocesso) só que no formato YYYYMMDD
        -- insert tbdomic_liqtrans_arquivo
        -- na quebra de lancamento
        -- insert tbdomic_liqtrans_lancto
        -- na quebra de centralizadora
        -- insert tbdomic_liqtrans_centraliza
        -- na quebra de ponto de venda
        -- insert tbdomic_liqtrans_pdv
        -- geração da tabela tbdomic_liqtrans_arquivo
          IF vr_idarquivo_ant != rw_craplau.idarquivo THEN
             vr_idarquivo_ant := rw_craplau.idarquivo;
             vr_seq_arquivo   := 1;
             vr_arquivo := rw_craplau.nmarquivo_origem||'_'||to_char(vr_seq_arquivo,'fm00000')||'_PGT';

             vr_existe_arquivo := 'S';
             LOOP
               OPEN cr_arquivo(vr_arquivo);
               FETCH cr_arquivo INTO vr_existe_arquivo;
               IF cr_arquivo%NOTFOUND THEN
                  vr_existe_arquivo := 'N';
               END  IF;
               CLOSE cr_arquivo;
               EXIT WHEN vr_existe_arquivo = 'N';
               vr_seq_arquivo := vr_seq_arquivo + 1;
               vr_arquivo     := rw_craplau.nmarquivo_origem||'_'||to_char(vr_seq_arquivo,'fm00000')||'_PGT';
             END LOOP;

             BEGIN
                INSERT INTO tbdomic_liqtrans_arquivo
                           (idarquivo
                           ,nmarquivo_origem
                           ,tparquivo
                           ,nrcontrole_emissor
                           ,nrcontrole_dest_original
                           ,nrispb_emissor
                           ,nrispb_destinatario
                           ,dharquivo_origem
                           ,dtreferencia
                           ,dhrecebimento
                           ,nmarquivo_gerado
                           ,dharquivo_gerado
                           ,nmarquivo_retorno
                           ,dharquivo_retorno
                           )
                    VALUES (0
                           ,vr_arquivo
                           ,rw_craplau.tparquivo
                           ,rw_craplau.nrcontrole_emissor
                           ,rw_craplau.nrcontrole_dest_original
                           ,rw_craplau.nrispb_emissor
                           ,rw_craplau.nrispb_destinatario
                           ,rw_craplau.dharquivo_origem
                           ,rw_craplau.dtreferencia
                           ,rw_craplau.dhrecebimento
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL ) RETURNING idarquivo INTO vr_idarquivo_novo;
             EXCEPTION
                -- Pode tentar gerar o mesmo arquivo PGT, devido ao loop da cooperativa
                -- Nesse caso simplesmente ignorar o erro de duplicação de registro
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
                WHEN OTHERS THEN
                    pr_dscritic := 'ERRO ao gerar a tabela tbdomic_liqtrans_arquivo '||SQLERRM;
                    RETURN;
             END;
          END IF;

          -- geração da tabela tbdomic_liqtrans_lancto
          IF vr_idlancto_ant != rw_craplau.idlancto THEN
             vr_idlancto_ant := rw_craplau.idlancto;
             BEGIN
               INSERT INTO tbdomic_liqtrans_lancto
                          (idlancto
                          ,idarquivo
                          ,nrcnpjbase_principal
                          ,nrcnpjbase_administrado
                          ,nrcnpj_credenciador
                          ,nrispb_devedor
                          ,nrispb_credor
                          ,cdagencia_credenciador
                          ,nrconta_credenciador
                          ,nmcredenciador
                          ,insituacao
                          ,dserro
                          ,dhinclusao
                          ,dhprocessamento
                          ,dhretorno
                          ,insituacao_retorno
                          ,dhconfirmacao_retorno
                          )
                    VALUES ( 0
                          ,vr_idarquivo_novo
                          ,rw_craplau.nrcnpjbase_principal
                          ,rw_craplau.nrcnpjbase_administrado
                          ,rw_craplau.nrcnpj_credenciador
                          ,rw_craplau.nrispb_devedor
                          ,rw_craplau.nrispb_credor
                          ,rw_craplau.cdagencia_credenciador
                          ,rw_craplau.nrconta_credenciador
                          ,rw_craplau.nmcredenciador
                          ,0
                          ,NULL
                          ,SYSDATE
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL ) RETURNING idlancto INTO vr_idlancto_novo;
             EXCEPTION
                WHEN OTHERS THEN
                    pr_dscritic := 'ERRO ao gerar a tabela tbdomic_liqtrans_lancto '||SQLERRM;
                    RETURN;
             END;
          END IF;

          -- geração da tabela tbdomic_liqtrans_centraliza
          IF vr_idcentraliza_ant != rw_craplau.idcentraliza THEN
             vr_idcentraliza_ant := rw_craplau.idcentraliza;
             BEGIN
               INSERT INTO tbdomic_liqtrans_centraliza
                          (idcentraliza
                          ,idlancto
                          ,tppessoa_centraliza
                          ,nrcnpjcpf_centraliza
                          ,cdcentraliza
                          ,tpconta
                          ,cdagencia_centraliza
                          ,nrcta_centraliza
                          ,nrcta_pgto_centraliza
                          )
                    VALUES ( 0
                          ,vr_idlancto_novo
                          ,rw_craplau.tppessoa_centraliza
                          ,rw_craplau.nrcnpjcpf_centraliza
                          ,rw_craplau.cdcentraliza
                          ,rw_craplau.tpconta
                          ,rw_craplau.cdagencia_centraliza
                          ,rw_craplau.nrcta_centraliza
                          ,rw_craplau.nrcta_pgto_centraliza) RETURNING idcentraliza INTO vr_idcentraliza_novo;
             EXCEPTION
                WHEN OTHERS THEN
                    pr_dscritic := 'ERRO ao gerar a tabela tbdomic_liqtrans_centraliza '||SQLERRM;
                    RETURN;
             END;
          END IF;

          -- geração da tabela tbdomic_liqtrans_centraliza
          IF vr_idpdv_ant != rw_craplau.idpdv THEN
             vr_idpdv_ant := rw_craplau.idpdv;
             BEGIN
               INSERT INTO tbdomic_liqtrans_pdv
                          (idpdv
                          ,idcentraliza
                          ,nrliquidacao
                          ,nrispb_liquid_pdv
                          ,cdpdv
                          ,nmpdv
                          ,tppessoa_pdv
                          ,nrcnpjcpf_pdv
                          ,cdinst_arranjo_pagamento
                          ,tpproduto_credito
                          ,tpforma_transf
                          ,cdmoeda
                          ,dtpagamento
                          ,vlpagamento
                          ,dhmanutencao
                          ,cdocorrencia
                          ,nrcontrole_if
                          ,nrcontrole_cip
                          ,dhretorno
                          ,cdocorrencia_retorno
                          ,dserro
                          )
                    VALUES ( 0
                          ,vr_idcentraliza_novo
                          ,rw_craplau.nrliquidacao
                          ,rw_craplau.nrispb_liquid_pdv
                          ,rw_craplau.cdpdv
                          ,rw_craplau.nmpdv
                          ,rw_craplau.tppessoa_pdv
                          ,rw_craplau.nrcnpjcpf_pdv
                          ,rw_craplau.cdinst_arranjo_pagamento
                          ,rw_craplau.tpproduto_credito
                          ,rw_craplau.tpforma_transf
                          ,rw_craplau.cdmoeda
                          ,rw_craplau.dtpagamento
                          ,rw_craplau.vlpagamento
                          ,rw_craplau.dhmanutencao
                          ,NULL
                          ,rw_craplau.nrcontrole_if
                          ,rw_craplau.nrcontrole_cip
                          ,NULL
                          ,NULL
                          ,NULL)  RETURNING idpdv INTO vr_idpdv_novo;

               --Alteração implementada para evitar gerar arquivo PGT em duplicidade
               UPDATE tbdomic_liqtrans_pdv
                  SET dserro = 'Agendamento'
                WHERE idpdv  = rw_craplau.idpdv;

             EXCEPTION
                WHEN OTHERS THEN
                    pr_dscritic := 'ERRO ao gerar a tabela tbdomic_liqtrans_pdv '||SQLERRM;
                    RETURN;
             END;
          END IF;


      END LOOP; -- buscando lancamentos

    END LOOP; -- lendo cooperativas

  COMMIT;

  END; -- pc_efetiva_agendamentos --

  -- Rotina para processar os lancamentos pendentes
  PROCEDURE pc_processa_reg_pendentes(pr_dtprocesso IN DATE
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2)  IS

    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor sobre os registros pendentes

    CURSOR cr_lancamento IS
      SELECT  arq.idarquivo
             ,lct.nrcnpj_credenciador
             ,lct.nrcnpjbase_principal
             ,arq.tparquivo
             ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
             ,lct.dhprocessamento
             ,lct.idlancto
             ,pdv.tpforma_transf
             ,sum(pdv.vlpagamento) vlpagamento
         FROM tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
        WHERE lct.idarquivo = arq.idarquivo
          AND ctz.idlancto = lct.idlancto
          AND pdv.idcentraliza = ctz.idcentraliza
          AND lct.insituacao = 0 -- Pendente
                                 -- No final será alterado a situacao para 1-Processado
     GROUP BY arq.idarquivo, lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, arq.tparquivo, to_date(arq.dtreferencia,'YYYY-MM-DD'), lct.dhprocessamento, lct.idlancto, pdv.tpforma_transf
     ORDER BY arq.tparquivo,lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, to_date(arq.dtreferencia,'YYYY-MM-DD');

    -- Cursor para informações dos lançamentos
    CURSOR cr_tabela(pr_idlancto tbdomic_liqtrans_lancto.idlancto%TYPE) IS
      SELECT pdv.nrliquidacao
            ,ctz.nrcnpjcpf_centraliza
            ,ctz.tppessoa_centraliza
            ,ctz.cdagencia_centraliza
            ,ctz.nrcta_centraliza
            ,pdv.vlpagamento
            ,to_date(pdv.dtpagamento,'YYYY-MM-DD') dtpagamento
            ,pdv.idpdv
        FROM tbdomic_liqtrans_centraliza ctz
            ,tbdomic_liqtrans_pdv pdv
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
       ORDER BY ctz.cdagencia_centraliza,ctz.nrcta_centraliza,to_date(pdv.dtpagamento,'YYYY-MM-DD');

    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper,
             cdagectl,
             nmrescop,
             flgativo
        FROM crapcop;

    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc,
             inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                       pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta,
             tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;

    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                nmrescop crapcop.nmrescop%TYPE,
                                flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop       typ_tab_crapcop;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;


    -- Variaveis gerais
    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100);         --> Variavel de erro
    vr_dserro_arq    VARCHAR2(100);         --> Variavel de erro do reg arquivo
    vr_cdocorr       VARCHAR2(2) := NULL;   --> Código de ocorrencia do pdv
    vr_cdocorr_arq   VARCHAR2(2) := NULL;   --> Código de ocorrencia do reg arquivo
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_qterros       PLS_INTEGER := 0;      --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0;      --> Quantidade de registros processados
    vr_inlctfut      VARCHAR2(01);          --> Indicador de lancamento futuro

    vr_coopdest      crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_cdcooper_lcm  craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_cdcooper_lau  craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_dtprocesso    crapdat.dtmvtolt%TYPE; --> Data da cooperativa

  BEGIN

    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;

    -- Efetua loop sobre os registros pendentes
    FOR rw_lancamento IN cr_lancamento LOOP

      -- Limpa variaveis de controle de quebra para gravacao da craplcm e craplau
      -- Como trata-se de um novo tipo de arquivo precisa-se limpar pois o numero
      -- do lote será alterado.
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;

      -- Limpa a variavel de erro
      vr_dserro_arq   := NULL;
      vr_cdocorr_arq  := NULL;
      -- Criticar tipo de arquivo.
      IF rw_lancamento.tparquivo NOT in (1,2,3) THEN
        vr_dserro_arq  := 'Tipo de arquivo ('||rw_lancamento.tparquivo||') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
      
      IF ((rw_lancamento.tparquivo <> 3) OR
--        (rw_lancamento.tparquivo = 3 AND ccrd0006.fn_valida_liquid_antecipacao(rw_lancamento.vlpagamento, rw_lancamento.nrcnpjbase_principal, rw_lancamento.dtreferencia, rw_lancamento.tpforma_transf) = 'S')) THEN
--       Incluída a validação da forma de transferência para validar apenas se for = 3 (SILOC)        
        (rw_lancamento.tparquivo = 3 AND rw_lancamento.tpforma_transf <> 3) OR
        (rw_lancamento.tparquivo = 3 AND rw_lancamento.tpforma_transf = 3 AND ccrd0006.fn_valida_liquid_antecipacao(rw_lancamento.vlpagamento, rw_lancamento.nrcnpjbase_principal, rw_lancamento.dtreferencia, rw_lancamento.tpforma_transf,'S') = 'S')) THEN
          
        FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto) LOOP
          -- Limpa a variavel de erro
          vr_dserro  := NULL;
          vr_cdocorr := NULL;

          -- Efetua todas as consistencias dentro deste BEGIN
          BEGIN
            -- se existe erro a nível de arquivo/lancamento jogará para todos os
            -- registros PDV este erro
            IF NVL(vr_cdocorr_arq,'00') <> '00' THEN
              vr_dserro  := vr_dserro_arq;
              vr_cdocorr := vr_cdocorr_arq;
              RAISE vr_erro;
            END IF;

            -- Atualiza o indicador de inpessoa
            IF rw_tabela.tppessoa_centraliza = 'F' THEN
              vr_inpessoa := 1;
            ELSIF rw_tabela.tppessoa_centraliza = 'J' THEN
              vr_inpessoa := 2;
            ELSE
              vr_dserro := 'Indicador de pessoa ('||rw_tabela.tppessoa_centraliza||') nao previsto.';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;

            -- Verifica se a agencia informada existe
            IF NOT vr_crapcop.exists(rw_tabela.cdagencia_centraliza) THEN
              vr_dserro := 'Agencia informada ('||rw_tabela.cdagencia_centraliza||') nao cadastrada.';
              vr_cdocorr := '08';
              RAISE vr_erro;
            END IF;

            IF rw_tabela.vlpagamento = 0 OR rw_tabela.vlpagamento < 0 THEN
              vr_dserro := 'Valor do lancamento zerado ou negativo';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;

            IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN

              OPEN cr_craptco (pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                               pr_nrctaant => rw_tabela.nrcta_centraliza);
              FETCH cr_craptco INTO rw_craptco;

              IF cr_craptco%FOUND THEN
                vr_nrdconta := rw_craptco.nrdconta;
                vr_coopdest := rw_craptco.cdcooper;
              ELSE
                vr_nrdconta := 0;
                vr_coopdest := 0;
              END IF;

              CLOSE cr_craptco;

            ELSE
              vr_nrdconta := rw_tabela.nrcta_centraliza;
              vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
            END IF;

            -- Busca a data da cooperativa
            -- foi incluido aqui pois pode existir contas transferidas
            OPEN btch0001.cr_crapdat(vr_coopdest);
            FETCH btch0001.cr_crapdat INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;

            --Alterado para utilizar a data do parâmetro, se for diferente de NULL
            --IF vr_database_name = 'AYLLOSD' THEN
            IF pr_dtprocesso IS NULL THEN
              IF rw_crapdat.inproces > 1 THEN  -- Está executando cadeia
                vr_dtprocesso := rw_crapdat.dtmvtopr;
              ELSE
                vr_dtprocesso := rw_crapdat.dtmvtolt;
              END IF;
            ELSE
              vr_dtprocesso   := pr_dtprocesso;
            END IF;

            -- Não pode processar data de pagamento anterior
            IF rw_tabela.dtpagamento < vr_dtprocesso THEN
              vr_dserro := 'Data de pagamento menor que a data da cooperativa';
              vr_cdocorr := '03';
              RAISE vr_erro;
            END IF;

            -- Busca os dados do associado
            OPEN cr_crapass(vr_coopdest, vr_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            IF cr_crapass%NOTFOUND THEN -- Se nao encontrar, deve-se gerar inconsistencia
              CLOSE cr_crapass;
              vr_dserro := 'Conta do associado ('||GENE0002.fn_mask_conta(rw_tabela.nrcta_centraliza)||') inexistente para a cooperativa '||
                           vr_crapcop(rw_tabela.cdagencia_centraliza).nmrescop||'.';
              vr_cdocorr := '10';
              RAISE vr_erro;
            END IF;
            CLOSE cr_crapass;

            -- Efetua consistencia sobre o associado
            IF rw_crapass.inpessoa <> vr_inpessoa THEN
              vr_dserro := 'Associado eh uma pessoa ';
              IF rw_crapass.inpessoa = 1 THEN
                vr_dserro := vr_dserro ||'fisica, porem foi enviado um ';
              ELSE
                vr_dserro := vr_dserro ||'juridica, porem foi enviado um ';
              END IF;
              IF vr_inpessoa = 1 THEN
                vr_dserro := vr_dserro ||'CPF.';
              ELSE
                vr_dserro := vr_dserro ||'CNPJ.';
              END IF;
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF rw_crapass.nrcpfcgc <> rw_tabela.nrcnpjcpf_centraliza AND rw_crapass.inpessoa = 1 THEN
              vr_dserro := 'CPF informado ('||GENE0002.fn_mask_cpf_cnpj(rw_tabela.nrcnpjcpf_centraliza,vr_inpessoa)||
                             ') difere do CPF do associado ('||GENE0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)||').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8) <> substr(lpad(rw_tabela.nrcnpjcpf_centraliza,14,0),1,8) AND rw_crapass.inpessoa = 2 then
              vr_dserro := 'CNPJ informado ('||substr(lpad(rw_tabela.nrcnpjcpf_centraliza,14,0),1,8)||
                           ') difere do CNPJ do associado ('||substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8)||').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            END IF;

          EXCEPTION
            WHEN vr_erro THEN
              NULL;
          END;

          IF nvl(vr_cdocorr,'00') <> '00' THEN
            vr_qterros := vr_qterros + 1;
          END IF;

          IF nvl(vr_cdocorr,'00') = '00' THEN
            IF rw_tabela.dtpagamento > vr_dtprocesso THEN
               IF rw_lancamento.tparquivo = 1 THEN    -- crédito
                  vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
               END IF;
            END IF;
          END IF;

          -- Efetua a atualizacao da tabela de liquidacao pdv
          BEGIN
            UPDATE tbdomic_liqtrans_pdv
               SET cdocorrencia = NVL(vr_cdocorr,'00')
                  ,dserro = vr_dserro
             WHERE idpdv = rw_tabela.idpdv;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_pdv: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END LOOP;  -- loop cr_tabela

        -- Efetua a atualizacao da situacao na tabela de lancamentos
        BEGIN
          UPDATE tbdomic_liqtrans_lancto
             SET insituacao = 1 -- Enviado para CIP/Aguardando Aprovação
                ,dhprocessamento = SYSDATE
           WHERE idlancto = rw_lancamento.idlancto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;
    END LOOP;  -- loop cr_lancamento

    -- Se possuir algum registro com erro ou processado
    IF vr_qtprocessados > 0 OR vr_qterros > 0 THEN
      -- Gera log de quantidade de registros processados
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                ,pr_ind_tipo_log => 1 -- Aviso
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                 || 'Registros processados com sucesso: '||vr_qtprocessados
                                                 || '. Registros com erro: '||vr_qterros||'.'
                                ,pr_nmarqlog => 'CONSLC');
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END; -- pc_processa_reg_pendentes --

  PROCEDURE pc_efetiva_reg_pendentes(pr_dtprocesso IN DATE
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT VARCHAR2)  IS

    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor sobre os registros pendentes

    CURSOR cr_lancamento IS
      SELECT  arq.idarquivo
             ,lct.nrcnpj_credenciador
             ,lct.nrcnpjbase_principal
             ,arq.tparquivo
             ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
             ,lct.dhprocessamento
             ,lct.idlancto
             ,pdv.tpforma_transf
             ,sum(pdv.vlpagamento) vlpagamento
         FROM tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
        WHERE lct.idarquivo = arq.idarquivo
          AND ctz.idlancto = lct.idlancto
          AND pdv.idcentraliza = ctz.idcentraliza
          AND lct.insituacao = 1 -- Registros enviados para CIP/Aguardando Aprovação
                                 -- No final será alterado a situacao para 2-Processado
     GROUP BY arq.idarquivo, lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, arq.tparquivo, to_date(arq.dtreferencia,'YYYY-MM-DD'), lct.dhprocessamento, lct.idlancto, pdv.tpforma_transf
     ORDER BY arq.tparquivo,lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, to_date(arq.dtreferencia,'YYYY-MM-DD');

    -- Cursor para informações dos lançamentos
    CURSOR cr_tabela(pr_idlancto tbdomic_liqtrans_lancto.idlancto%TYPE) IS
      SELECT pdv.nrliquidacao
            ,ctz.nrcnpjcpf_centraliza
            ,ctz.tppessoa_centraliza
            ,ctz.cdagencia_centraliza
            ,ctz.nrcta_centraliza
            ,pdv.vlpagamento
            ,to_date(pdv.dtpagamento,'YYYY-MM-DD') dtpagamento
            ,pdv.idpdv
            ,pdv.cdocorrencia
            ,pdv.cdocorrencia_retorno
            ,pdv.dserro
            ,pdv.dsocorrencia_retorno
        FROM tbdomic_liqtrans_centraliza ctz
            ,tbdomic_liqtrans_pdv pdv
            ,tbdomic_liqtrans_lancto lct
            ,tbdomic_liqtrans_arquivo arq
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND arq.nmarquivo_retorno IS NOT NULL
         AND (nvl(pdv.cdocorrencia_retorno,'00') = '00'  --Só vai atualizar os registros que não tiveram erro no processa_reg_pendentes
          OR (nvl(pdv.cdocorrencia_retorno,'00') = '01'
         AND arq.tparquivo = 1))
         AND pdv.dserro IS NULL                          --Só vai atualizar os registros que não retornaram com erro da CIP
         AND pdv.dsocorrencia_retorno IS NULL            --Só vai atualizar os registros que não retornaram com erro da CIP
       ORDER BY ctz.cdagencia_centraliza,ctz.nrcta_centraliza,to_date(pdv.dtpagamento,'YYYY-MM-DD');

    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper,
             cdagectl,
             nmrescop,
             flgativo
        FROM crapcop;

    CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                       pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta,
             tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;

    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                nmrescop crapcop.nmrescop%TYPE,
                                flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop       typ_tab_crapcop;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;


    -- Variaveis gerais
    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100);         --> Variavel de erro
    vr_dserro_arq    VARCHAR2(100);         --> Variavel de erro do reg arquivo
    vr_cdocorr       VARCHAR2(2) := NULL;   --> Código de ocorrencia do pdv
    vr_cdocorr_arq   VARCHAR2(2) := NULL;   --> Código de ocorrencia do reg arquivo
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_cdhistor      craphis.cdhistor%TYPE; --> Codigo do historico do lancamento
    vr_nrdolote      craplcm.nrdolote%TYPE; --> Numero do lote
    vr_qterros       PLS_INTEGER := 0;      --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0;      --> Quantidade de registros processados
    vr_qtfuturos     PLS_INTEGER := 0;      --> Quantidade de lancamentos futuros processados
    vr_inlctfut      VARCHAR2(01);          --> Indicador de lancamento futuro

    vr_coopdest      crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_cdcooper_lcm  craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_cdcooper_lau  craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_dtprocesso    crapdat.dtmvtolt%TYPE; --> Data da cooperativa
    vr_qtproclancto  PLS_INTEGER := 0;      --> Quantidade de registros lidos do lancamento
  BEGIN

    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;

    -- Efetua loop sobre os registros pendentes
    FOR rw_lancamento IN cr_lancamento LOOP

      -- Limpa variaveis de controle de quebra para gravacao da craplcm e craplau
      -- Como trata-se de um novo tipo de arquivo precisa-se limpar pois o numero
      -- do lote será alterado.
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;

      -- Limpa a variavel de erro
      vr_dserro_arq   := NULL;
      vr_cdocorr_arq  := NULL;
      -- Criticar tipo de arquivo.
      IF rw_lancamento.tparquivo NOT in (1,2,3) THEN
        vr_dserro_arq  := 'Tipo de arquivo ('||rw_lancamento.tparquivo||') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
      
--      IF ((rw_lancamento.tparquivo <> 3) OR
--        (rw_lancamento.tparquivo = 3 AND rw_lancamento.tpforma_transf <> 3) OR
--        (rw_lancamento.tparquivo = 3 AND rw_lancamento.tpforma_transf = 3 AND ccrd0006.fn_valida_liquid_antecipacao(rw_lancamento.vlpagamento, rw_lancamento.nrcnpjbase_principal, rw_lancamento.dtreferencia, rw_lancamento.tpforma_transf, 'S') = 'S')) THEN
        
        vr_qtproclancto := 0;
        FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto) LOOP
          -- Limpa a variavel de erro
          vr_dserro  := NULL;
          vr_cdocorr := NULL;
          vr_qtproclancto := vr_qtproclancto + 1;

          -- Efetua todas as consistencias dentro deste BEGIN
          BEGIN
            -- se existe erro a nível de arquivo/lancamento jogará para todos os
            -- registros PDV este erro
            IF NVL(vr_cdocorr_arq,'00') <> '00' THEN
              vr_dserro  := vr_dserro_arq;
              vr_cdocorr := vr_cdocorr_arq;
              RAISE vr_erro;
            END IF;

            IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN

              OPEN cr_craptco (pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                               pr_nrctaant => rw_tabela.nrcta_centraliza);
              FETCH cr_craptco INTO rw_craptco;

              IF cr_craptco%FOUND THEN
                vr_nrdconta := rw_craptco.nrdconta;
                vr_coopdest := rw_craptco.cdcooper;
              ELSE
                vr_nrdconta := 0;
                vr_coopdest := 0;
              END IF;

              CLOSE cr_craptco;

            ELSE
              vr_nrdconta := rw_tabela.nrcta_centraliza;
              vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
            END IF;

            -- Busca a data da cooperativa
            -- foi incluido aqui pois pode existir contas transferidas
            OPEN btch0001.cr_crapdat(vr_coopdest);
            FETCH btch0001.cr_crapdat INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;

            --Alterado para utilizar a data do parâmetro, se for diferente de NULL
            --IF vr_database_name = 'AYLLOSD' THEN
            IF pr_dtprocesso IS NULL THEN
              IF rw_crapdat.inproces > 1 THEN  -- Está executando cadeia
                vr_dtprocesso := rw_crapdat.dtmvtopr;
              ELSE
                vr_dtprocesso := rw_crapdat.dtmvtolt;
              END IF;
            ELSE
              vr_dtprocesso   := pr_dtprocesso;
            END IF;


          EXCEPTION
            WHEN vr_erro THEN
              NULL;
          END;

          vr_nrdolote := 1;  -- fixa 1 no número do lote

          -- Atualiza os historicos de lancamento
          IF rw_lancamento.tparquivo = 1 THEN    -- crédito
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2444;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2443;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2442;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2450;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2453;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2478;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2445;
             END IF;
          ELSIF rw_lancamento.tparquivo = 2 THEN -- débito
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2448;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2447;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2446;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2451;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2413;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2479;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2449;
             END IF;
          ELSE                                 -- antecipação
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2456;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2455;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2454;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2452;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2414;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2480;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2457;
             END IF;
         END IF;

          -- Se nao existir erro, insere o lancamento
          IF vr_cdocorr IS NULL AND
             rw_tabela.dtpagamento = vr_dtprocesso THEN -- Integrar na craplcm e atualizar
                                                        -- dtdebito se existir na craplau

            -- Atualiza a cooperativa
            vr_cdcooper := vr_coopdest;

            -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
            pr_cdcritic := null;
            vr_dscritic := null;
            vr_cdcooper_lcm := vr_cdcooper; -- salva a nova cooperativa para a quebra
            pc_procura_ultseq_craplcm (pr_cdcooper    => vr_cdcooper
                                      ,pr_dtmvtolt    => vr_dtprocesso
                                      ,pr_cdagenci    => 1
                                      ,pr_cdbccxlt    => 100
                                      ,pr_nrdolote    => vr_nrdolote
                                      ,pr_nrseqdiglcm => vr_nrseqdiglcm
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

            IF vr_dscritic is not null then
              RAISE vr_exc_saida;
            END IF;

            -- insere o registro na tabela de lancamentos
            BEGIN
              INSERT INTO craplcm
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 nrseqdig,
                 vllanmto,
                 nrdctabb,
                 nrdctitg,
                 cdcooper,
                 dtrefere,
                 cdoperad,
                 CDPESQBB)
              VALUES
                (vr_dtprocesso,                                     --dtmvtolt
                 1,                                                 --cdagenci
                 100,                                               --cdbccxlt
                 vr_nrdolote,                                       --nrdolote
                 vr_nrdconta,                                       --nrdconta
                 vr_nrseqdiglcm,                                    --nrdocmto
                 vr_cdhistor,                                       --cdhistor
                 vr_nrseqdiglcm,                                    --nrseqdig
                 rw_tabela.vlpagamento,                             --vllanmto
                 vr_nrdconta,                                       --nrdctabb
                 GENE0002.fn_mask(vr_nrdconta,'99999999'),          --nrdctitg
                 vr_cdcooper,                                       --cdcooper
                 rw_tabela.dtpagamento,                             --dtrefere
                 '1',                                               --cdoperad
                 rw_tabela.nrliquidacao);                           --CDPESQBB
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Atualiza data de débito na craplau
            BEGIN
              UPDATE craplau
                 SET dtdebito = vr_dtprocesso
               WHERE cdcooper = vr_cdcooper
                 AND dtmvtopg = rw_tabela.dtpagamento
                 AND nrdconta = vr_nrdconta
                 AND cdseqtel = rw_tabela.nrliquidacao;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela CRAPLAU - dtdebito : '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_qtprocessados := vr_qtprocessados + 1;

          END IF;


          IF vr_cdocorr IS NULL AND
             rw_tabela.dtpagamento > vr_dtprocesso THEN -- Integrar na craplau

            -- Atualiza a cooperativa
            vr_cdcooper := vr_coopdest;

            -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
            vr_cdcritic := null;
            vr_dscritic := null;
            vr_cdcooper_lau := vr_cdcooper;

            pc_procura_ultseq_craplau (pr_cdcooper    => vr_cdcooper
                                      ,pr_dtmvtolt    => vr_dtprocesso
                                      ,pr_cdagenci    => 1
                                      ,pr_cdbccxlt    => 100
                                      ,pr_nrdolote    => vr_nrdolote
                                      ,pr_nrseqdiglau => vr_nrseqdiglau
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

            IF vr_dscritic is not null then
              RAISE vr_exc_saida;
            END IF;

            -- insere o registro na tabela de lancamentos
            BEGIN
              INSERT INTO craplau
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 nrseqdig,
                 vllanaut,
                 nrdctabb,
                 nrdctitg,
                 cdcooper,
                 dtmvtopg,
  --               cdoperad,
                 cdseqtel,
                 dsorigem)
              VALUES
                (vr_dtprocesso,                                     --dtmvtolt
                 1,                                                 --cdagenci
                 100,                                               --cdbccxlt
                 vr_nrdolote,                                       --nrdolote
                 vr_nrdconta,                                       --nrdconta
                 vr_nrseqdiglau,                                    --nrdocmto
                 vr_cdhistor,                                       --cdhistor
                 vr_nrseqdiglau,                                    --nrseqdig
                 rw_tabela.vlpagamento,                             --vllanaut
                 vr_nrdconta,                                       --nrdctabb
                 GENE0002.fn_mask(vr_nrdconta,'99999999'),          --nrdctitg
                 vr_cdcooper,                                       --cdcooper
                 rw_tabela.dtpagamento,                             --dtrefere
  --               '1',                                               --cdoperad
                 rw_tabela.nrliquidacao,                            --cdseqtel
                 'DOMICILIO');                                      --dsorigem
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CRAPLAU: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_qtfuturos := vr_qtfuturos + 1;

          END IF;

          IF nvl(vr_cdocorr,'00') <> '00' THEN
            vr_qterros := vr_qterros + 1;
          END IF;

          IF nvl(vr_cdocorr,'00') = '00' THEN
            IF rw_tabela.dtpagamento > vr_dtprocesso THEN
               IF rw_lancamento.tparquivo = 1 THEN    -- crédito
                  vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
               END IF;
            END IF;
          END IF;

        END LOOP;  -- loop cr_tabela

        -- Efetua a atualizacao da situacao na tabela de lancamentos
        -- Se encontrar algum registro sem erro no lancto, atualiza situação para 1
        -- Com isso, se tiver apenas 1 PDV sem erro dentro de um lançamento considera todo o lançamento como processado
        IF vr_qtproclancto > 0 THEN
          BEGIN
            UPDATE tbdomic_liqtrans_lancto
               SET insituacao = 2 -- processado
                  ,dhprocessamento = SYSDATE
             WHERE idlancto = rw_lancamento.idlancto;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

      --END IF;
    END LOOP;  -- loop cr_lancamento

    -- Se possuir algum registro com erro ou processado
    IF vr_qtprocessados > 0 OR vr_qterros > 0 OR vr_qtfuturos > 0 THEN
      -- Gera log de quantidade de registros processados
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                ,pr_ind_tipo_log => 1 -- Aviso
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                 || 'Registros processados com sucesso: '||vr_qtprocessados
                                                 || '. Registros futuros processados com sucesso: '||vr_qtfuturos
                                                 || '. Registros com erro: '||vr_qterros||'.'
                                ,pr_nmarqlog => 'CONSLC');
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END; -- pc_processa_reg_pendentes --

  PROCEDURE pc_procura_ultseq_craplcm (pr_cdcooper IN  crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                      ,pr_cdagenci IN  craplcm.cdagenci%TYPE
                                      ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                                      ,pr_nrdolote IN  craplcm.nrdolote%TYPE
                                      ,pr_nrseqdiglcm OUT craplcm.nrseqdig%TYPE
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2)  IS

    -- Cursor para buscar ultimo documento

    CURSOR cr_ult_craplcm(pr_cdcooper IN  crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                         ,pr_cdagenci IN  craplcm.cdagenci%TYPE
                         ,pr_cdbccxlt IN  craplcm.cdbccxlt%TYPE
                         ,pr_nrdolote IN  craplcm.nrdolote%TYPE) IS
      SELECT  MAX(lcm.nrseqdig) nrseqdig
         FROM craplcm lcm
        WHERE lcm.cdcooper = pr_cdcooper
          AND lcm.dtmvtolt = pr_dtmvtolt
          AND lcm.cdagenci = pr_cdagenci
          AND lcm.cdbccxlt = pr_cdbccxlt
          AND lcm.nrdolote = pr_nrdolote;

     rw_ult_craplcm cr_ult_craplcm%ROWTYPE;

  BEGIN
    OPEN cr_ult_craplcm(pr_cdcooper, pr_dtmvtolt, pr_cdagenci, pr_cdbccxlt, pr_nrdolote);
    FETCH cr_ult_craplcm INTO rw_ult_craplcm;
    IF cr_ult_craplcm%NOTFOUND THEN
       pr_nrseqdiglcm := 1;
    ELSE
       pr_nrseqdiglcm := nvl(rw_ult_craplcm.nrseqdig,0) + 1;
    END IF;
    CLOSE cr_ult_craplcm;

  EXCEPTION
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
  END; --pc_procura_ultseq_craplcm

  PROCEDURE pc_procura_ultseq_craplau(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                     ,pr_dtmvtolt IN  craplau.dtmvtolt%TYPE
                                     ,pr_cdagenci IN  craplau.cdagenci%TYPE
                                     ,pr_cdbccxlt IN  craplau.cdbccxlt%TYPE
                                     ,pr_nrdolote IN  craplau.nrdolote%TYPE
                                     ,pr_nrseqdiglau OUT craplau.nrseqdig%TYPE
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2) IS

    -- Cursor para buscar ultimo documento

    CURSOR cr_ult_craplau(pr_cdcooper IN  crapcop.cdcooper%TYPE
                         ,pr_dtmvtolt IN  craplau.dtmvtolt%TYPE
                         ,pr_cdagenci IN  craplau.cdagenci%TYPE
                         ,pr_cdbccxlt IN  craplau.cdbccxlt%TYPE
                         ,pr_nrdolote IN  craplau.nrdolote%TYPE) IS
      SELECT  MAX(lau.nrseqdig) nrseqdig
         FROM craplau lau
        WHERE lau.cdcooper = pr_cdcooper
          AND lau.dtmvtolt = pr_dtmvtolt
          and lau.cdagenci = pr_cdagenci
          AND lau.cdbccxlt = pr_cdbccxlt
          AND lau.nrdolote = pr_nrdolote;

     rw_ult_craplau cr_ult_craplau%ROWTYPE;

  BEGIN
    OPEN cr_ult_craplau(pr_cdcooper, pr_dtmvtolt, pr_cdagenci, pr_cdbccxlt, pr_nrdolote);
    FETCH cr_ult_craplau INTO rw_ult_craplau;
    IF cr_ult_craplau%NOTFOUND THEN
       pr_nrseqdiglau := 1;
    ELSE
       pr_nrseqdiglau := nvl(rw_ult_craplau.nrseqdig,0) + 1;
    END IF;
    CLOSE cr_ult_craplau;

  EXCEPTION
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
  END; --pc_procura_ultseq_craplau

  -- Rotina que fará a conciliacao entre o que foi enviado nos movimentos LDL e LTR
  -- com o que foi lançado por conta na CRAPLCM pela procedure CCRD005.pc_processa_reg_pendente
  -- gera lancamento por cooperativa na CRAPLCM
  -- caso ocorra diferenca gera lançammento contábil
  -- gera relatório
  PROCEDURE pc_lancamentos_singulares(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                     ,pr_dscritic OUT VARCHAR2) IS
    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_lctos_pdv(pr_dtmvtolt  craplcm.dtmvtolt%TYPE) IS
      SELECT ctz.cdagencia_centraliza
             ,SUM(pdv.vlpagamento) vlpagamento_total
        FROM
              tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
       WHERE lct.idarquivo = arq.idarquivo
         AND lct.insituacao = 1 -- Processado (atualizado pelo pc_processo_reg_pendentes)
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND to_date(pdv.dtpagamento,'YYYY-MM-DD') = pr_dtmvtolt
         AND pdv.cdocorrencia = '00'  -- foram lançados na CRAPLCM
    GROUP BY ctz.cdagencia_centraliza;

    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper,
             cdagectl,
             nmrescop,
             flgativo,
             nrctactl
        FROM crapcop;

    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                nmrescop crapcop.nmrescop%TYPE,
                                flgativo crapcop.flgativo%TYPE,
                                nrctactl crapcop.nrctactl%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop       typ_tab_crapcop;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;


  BEGIN
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(3); -- Utiliza a cooperativa da Cecred
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
      vr_crapcop(rw_crapcop.cdagectl).nrctactl := rw_crapcop.nrctactl;
    END LOOP;


    FOR rw_lctos_pdv IN cr_lctos_pdv(rw_crapdat.dtmvtolt) LOOP

      IF NOT vr_crapcop.exists(rw_lctos_pdv.cdagencia_centraliza) THEN
          vr_dscritic := 'Agencia ('||rw_lctos_pdv.cdagencia_centraliza||') na tabela tbdomic_liqtrans_centraliza nao cadastrada.';
          RAISE vr_exc_saida;
      END IF;

      -- gera lancamento na craplcm para a cooperativa
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      pc_gerar_lcto_singulares(pr_cdcooper     => 3  -- gera lançamento na CECRED
                                                     -- passando conta da cooperativa dentro da CECRED
                              ,pr_nrdconta     => vr_crapcop(rw_lctos_pdv.cdagencia_centraliza).nrctactl
                              ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                              ,pr_vllancamento => rw_lctos_pdv.vlpagamento_total
                              ,pr_cdcritic     => vr_cdcritic
                              ,pr_dscritic     => vr_dscritic);
      -- critica se retornou com erro --
      IF vr_cdcritic IS NOT NULL OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END LOOP; -- final loop de cr_lctos_pdv

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END; -- procedure pc_lancamentos_singulares

  -- faz lançamento na craplcm
  PROCEDURE pc_gerar_lcto_singulares(pr_cdcooper     IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta     IN craplcm.nrdconta%TYPE
                                    ,pr_dtmvtolt     IN craplcm.dtmvtolt%TYPE
                                    ,pr_vllancamento IN craplcm.vllanmto%TYPE
                                    ,pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic    OUT VARCHAR2) IS

    -- Tratamento de erros
    vr_exc_volta     EXCEPTION;

    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrdolote      craplcm.nrdolote%TYPE;
    vr_cdhistor      craplcm.cdhistor%TYPE;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

  BEGIN

    -- o lançamento será a soma de crédito + débito + antecipações
    vr_nrdolote := 1;
    vr_cdhistor := 2441;

    pc_procura_ultseq_craplcm (pr_cdcooper    => pr_cdcooper
                              ,pr_dtmvtolt    => pr_dtmvtolt
                              ,pr_cdagenci    => 1
                              ,pr_cdbccxlt    => 100
                              ,pr_nrdolote    => vr_nrdolote
                              ,pr_nrseqdiglcm => vr_nrseqdiglcm
                              ,pr_cdcritic    => vr_cdcritic
                              ,pr_dscritic    => vr_dscritic);

    IF vr_dscritic is not null then
      RAISE vr_exc_volta;
    END IF;

    -- insere o registro na tabela de lancamentos
    BEGIN
      INSERT INTO craplcm
        (dtmvtolt,
         cdagenci,
         cdbccxlt,
         nrdolote,
         nrdconta,
         nrdocmto,
         cdhistor,
         nrseqdig,
         vllanmto,
         nrdctabb,
         nrdctitg,
         cdcooper,
         dtrefere,
         cdoperad)
      VALUES
        (pr_dtmvtolt,                                       --dtmvtolt
         1,                                                 --cdagenci
         100,                                               --cdbccxlt
         vr_nrdolote,                                       --nrdolote
         pr_nrdconta,                                       --nrdconta
         vr_nrseqdiglcm,                                    --nrdocmto
         vr_cdhistor,                                       --cdhistor
         vr_nrseqdiglcm,                                    --nrseqdig
         pr_vllancamento,                                   --vllanmto
         pr_nrdconta,                                       --nrdctabb
         GENE0002.fn_mask(pr_nrdconta,'99999999'),          --nrdctitg
         pr_cdcooper,                                       --cdcooper
         pr_dtmvtolt,                                       --dtrefere
         '1');                                              --cdoperad
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir CRAPLCM (pc_gerar_lcto_singulares): '||SQLERRM;
        RAISE vr_exc_volta;
      END;

    EXCEPTION
    WHEN vr_exc_volta THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END; -- procedure pc_gerar_lcto_singulares

  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_arquivos(pr_dtinicio IN VARCHAR2               --> Data inicial da consulta
                             ,pr_dtfinal  IN VARCHAR2               --> Data final da consulta
                             ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    -- Cursor sobre os arquivos processados
    CURSOR cr_tabela(pr_dtinicio DATE, pr_dtfinal DATE) IS
      SELECT  arq.nmarquivo_origem nmarquivo,
              case instr(upper(lct.nmcredenciador),'BANCOOB') when 0 then
                case instr(upper(lct.nmcredenciador),'ELAVON') when 0 then
                    case instr(upper(lct.nmcredenciador),'STONE') when 0 then
                          case instr(upper(lct.nmcredenciador),'BRADESCO') when 0 then
                               case instr(upper(lct.nmcredenciador),'SOROCRED') when 0 then
                                    upper(lct.nmcredenciador)
                               else 'SOROCRED' end
                          else 'BRADESCO' end
                    else 'STONE' end
                else 'ELAVON' end
              else 'BANCOOB' end AS nmcredenciador,
              to_char(to_date(substr(arq.dharquivo_origem,1,10),'YYYY-MM-DD'),'DD/MM/YYYY')||' '||substr(arq.dharquivo_origem,12,5) dtinclusao,
              substr(arq.dharquivo_origem,12,5) hrinclusao,
              to_char(to_date(substr(pdv.dtpagamento,1,10),'YYYY-MM-DD'),'DD/MM/YYYY') dtliquidacao,
              arq.nmarquivo_gerado,
              decode(arq.tparquivo, 1, 'CR', 2, 'DB', 3, 'AT')               tparquivo,
              to_char(arq.dharquivo_gerado,'DD/MM/YYYY HH24:MI')             dtgeracao,
              sum(decode(nvl(pdv.cdocorrencia,'XX'),'XX',0,1))               qtprocessados,
              sum(decode(nvl(pdv.cdocorrencia,'XX'),'XX',0,pdv.vlpagamento)) vlprocessados,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'00',decode(nvl(pdv.cdocorrencia_retorno,'00'),'00',1,0),0),0)) qtintegrados,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'00',decode(nvl(pdv.cdocorrencia_retorno,'00'),'00',pdv.vlpagamento,0),0),0)) vlintegrados,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'01',decode(arq.tparquivo,1,1,0),0),0)) qtagendados,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'01',decode(arq.tparquivo,1,pdv.vlpagamento,0),0),0)) vlagendados,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'00',decode(nvl(pdv.cdocorrencia_retorno,'00'),'00',decode(nvl(pdv.dsocorrencia_retorno,'XX'),'XX',0,1)),'01',decode(arq.tparquivo,1,0,1),'XX',decode(nvl(pdv.dsocorrencia_retorno,'XX'),'XX',0,1),1),0)) qterros,
              sum(decode(lct.insituacao,2,decode(nvl(pdv.cdocorrencia,'XX'),'00',decode(nvl(pdv.cdocorrencia_retorno,'00'),'00',decode(nvl(pdv.dsocorrencia_retorno,'XX'),'XX',0,pdv.vlpagamento)),'01',decode(arq.tparquivo,1,0,pdv.vlpagamento),'XX',decode(nvl(pdv.dsocorrencia_retorno,'XX'),'XX',0,pdv.vlpagamento),pdv.vlpagamento),0)) vlerros,
              count(1) over() qttotalreg
        FROM
              tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
       WHERE lct.idarquivo = arq.idarquivo
         AND lct.insituacao <> 3 -- não pegar arquivos que vieram com problema no XML
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND (to_date(substr(arq.dharquivo_origem,1,10),'YYYY-MM-DD') BETWEEN pr_dtinicio AND pr_dtfinal
         OR   trunc(arq.dharquivo_gerado) BETWEEN pr_dtinicio AND pr_dtfinal)
       GROUP BY  arq.nmarquivo_origem, lct.nmcredenciador,
                 to_char(to_date(substr(arq.dharquivo_origem,1,10),'YYYY-MM-DD'),'DD/MM/YYYY'),
                 substr(arq.dharquivo_origem,12,5),
                 arq.nmarquivo_gerado,
                 decode(arq.tparquivo, 1, 'CR', 2, 'DB', 3, 'AT'),
                 to_char(arq.dharquivo_gerado,'DD/MM/YYYY HH24:MI'),
                 to_char(to_date(substr(pdv.dtpagamento,1,10),'YYYY-MM-DD'),'DD/MM/YYYY')
       ORDER BY arq.nmarquivo_origem;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(32000);

      -- Variaveis gerais
      vr_dtinicio DATE;
      vr_dtfinal  DATE;

      vr_qt_tot_processados PLS_INTEGER := 0;
      vr_qt_tot_integrados  PLS_INTEGER := 0;
      vr_qt_tot_agendados   PLS_INTEGER := 0;
      vr_qt_tot_erros       PLS_INTEGER := 0;
      vr_vl_tot_processados NUMBER      := 0;
      vr_vl_tot_integrados  NUMBER      := 0;
      vr_vl_tot_agendados   NUMBER      := 0;
      vr_vl_tot_erros       NUMBER      := 0;
      vr_contador           PLS_INTEGER := 0;
      vt_qt_tot_reg         PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;


      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'CCRD0006');

      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><servico>');

      -- Popula a data de inicio
      IF TRIM(pr_dtinicio) IS NULL THEN
        vr_dtinicio := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtinicio := to_date(pr_dtinicio,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino
      IF TRIM(pr_dtfinal) IS NULL THEN
        vr_dtfinal := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfinal := to_date(pr_dtfinal,'dd/mm/yyyy');
      END IF;


      -- Loop sobre as versoes do questionario de microcredito
      FOR rw_tabela IN cr_tabela(vr_dtinicio, vr_dtfinal) LOOP

        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;

        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg AND
           vr_contador <  nvl(pr_nrregist,99999) THEN -- E enviados for menor que o solicitado

          -- Carrega os dados
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<inf>'||
                                                          '<nmarquivo>'       || rw_tabela.nmarquivo       ||'</nmarquivo>'||
                                                          '<tparquivo>'       || rw_tabela.tparquivo       ||'</tparquivo>'||
                                                          '<nmcredenciador>'  || rw_tabela.nmcredenciador  ||'</nmcredenciador>'||
                                                          '<dtinclusao>'      || rw_tabela.dtinclusao      ||'</dtinclusao>'||
                                                          '<hrinclusao>'      || rw_tabela.hrinclusao      ||'</hrinclusao>'||
                                                          '<dtliquidacao>'    || rw_tabela.dtliquidacao    ||'</dtliquidacao>'||
                                                          '<nmarquivo_gerado>'||rw_tabela.nmarquivo_gerado ||'</nmarquivo_gerado>'||
                                                          '<dtgeracao>'       ||rw_tabela.dtgeracao        ||'</dtgeracao>'||
                                                          '<qtprocessados>'   || rw_tabela.qtprocessados   ||'</qtprocessados>'||
                                                          '<vlprocessados>'   || rw_tabela.vlprocessados   ||'</vlprocessados>'||
                                                          '<qtintegrados>'    || rw_tabela.qtintegrados    ||'</qtintegrados>'||
                                                          '<vlintegrados>'    || rw_tabela.vlintegrados    ||'</vlintegrados>'||
                                                          '<qtagendados>'     || rw_tabela.qtagendados     ||'</qtagendados>'||
                                                          '<vlagendados>'     || rw_tabela.vlagendados     ||'</vlagendados>'||
                                                          '<qterros>'         || rw_tabela.qterros         ||'</qterros>'||
                                                          '<vlerros>'         || rw_tabela.vlerros         ||'</vlerros>'||
                                                       '</inf>');
          vr_contador := vr_contador + 1;
        END IF;

        -- Deve-se sair se o total de registros superar o total solicitado
        EXIT WHEN vr_contador >= nvl(pr_nrregist,99999);

        -- Incremente os totalizadores
        vr_qt_tot_processados := vr_qt_tot_processados + rw_tabela.qtprocessados;
        vr_qt_tot_integrados  := vr_qt_tot_integrados  + rw_tabela.qtintegrados;
        vr_qt_tot_agendados   := vr_qt_tot_agendados   + rw_tabela.qtagendados;
        vr_qt_tot_erros       := vr_qt_tot_erros       + rw_tabela.qterros;
        vr_vl_tot_processados := vr_vl_tot_processados + rw_tabela.vlprocessados;
        vr_vl_tot_integrados  := vr_vl_tot_integrados  + rw_tabela.vlintegrados;
        vr_vl_tot_agendados   := vr_vl_tot_agendados   + rw_tabela.vlagendados;
        vr_vl_tot_erros       := vr_vl_tot_erros       + rw_tabela.vlerros;
        vt_qt_tot_reg         := rw_tabela.qttotalreg;
      END LOOP;


      -- Encerrar a tag raiz
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</servico>'||
                                                   --'<qtregist>'       ||vr_contador ||'</qtregist>'||
                                                   '<qtregist>'         || vt_qt_tot_reg         ||'</qtregist>'||
                                                   '<tot_processados>'  || vr_qt_tot_processados ||'</tot_processados>'||
                                                   '<tot_integrados>'   || vr_qt_tot_integrados  ||'</tot_integrados>'||
                                                   '<tot_agendados>'    || vr_qt_tot_agendados   ||'</tot_agendados>'||
                                                   '<tot_erros>'        || vr_qt_tot_erros       ||'</tot_erros>'||
                                                   '<tot_vlprocessados>'|| vr_vl_tot_processados ||'</tot_vlprocessados>'||
                                                   '<tot_vlintegrados>' || vr_vl_tot_integrados  ||'</tot_vlintegrados>'||
                                                   '<tot_vlagendados>'  || vr_vl_tot_agendados   ||'</tot_vlagendados>'||
                                                   '<tot_vlerros>'      || vr_vl_tot_erros       ||'</tot_vlerros>'||
                                                   '</Dados>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_arquivos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_lista_arquivos;

  PROCEDURE pc_lista_contas(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_cddregio IN crapreg.cddregio%TYPE  --> Codigo da regional
                           ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                           ,pr_dtinicio IN VARCHAR2               --> Data inicial do lancamento da consulta
                           ,pr_dtfinal  IN VARCHAR2               --> Data final do lancamento da consulta
                           ,pr_dtiniarq IN VARCHAR2               --> Data inicial do arquivo da consulta
                           ,pr_dtfimarq IN VARCHAR2               --> Data final do arquivo da consulta
                           ,pr_insituac IN tbdomic_arq_lancto_cartoes.insituacao%TYPE --> Situacao do registro
                           ,pr_tplancto IN tbdomic_arq_lancto_cartoes.tplancamento%TYPE --> Tipo de lancamento
                           ,pr_nmarquiv IN tbdomic_arq_lancto_cartoes.nmarquivo%TYPE --> Nome do arquivo
                           ,pr_insaida  IN PLS_INTEGER            --> Indicador de saida dos dados (1-Xml, 2-Arquivo CSV)
                           ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                           ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela de associados que podem possuir contas duplicadas
      CURSOR cr_tabela(pr_dtinicio DATE, pr_dtfinal DATE,
                       pr_dtiniarq DATE, pr_dtfimarq DATE) IS
      SELECT   pdv.idpdv                   idlancamento
              ,pdv.nrliquidacao            nrseq_sicoob
              ,' '                         nmestabelecimento
              ,pdv.nrcnpjcpf_pdv           nrcpfcgc
              ,' '                         tppessoa
              ,ctz.cdagencia_centraliza    cdagectl
              ,ctz.nrcta_centraliza        nrdconta
              ,decode(arq.tparquivo,1,'CR',2,'DB',3,'AT','  ') tplancamento
              ,pdv.vlpagamento             vllancamento
              ,to_date(pdv.dtpagamento,'YYYY-MM-DD')           dtreferencia
              ,arq.nmarquivo_origem        nmarquivo
              ,pdv.cdocorrencia            insituacao
              ,decode(NVL(pdv.cdocorrencia,'XX'),'XX','Pendente','00',decode(nvl(pdv.cdocorrencia_retorno,'00'),'00',decode(lct.insituacao,1,'Não Efet.','Processado'),'Erro'),'01',decode(arq.tparquivo,1,'Agendado','Erro'),'Erro') dssituacao
              ,decode(NVL(pdv.cdocorrencia,'XX'),'XX',decode(arq.tparquivo,3,'Não recebemos a mensagem de liquidação LTR para pagamento da credenciadora.'),nvl(pdv.dserro,pdv.dsocorrencia_retorno||decode(pdv.dsocorrencia_retorno,null,null,' - ')||mte.dsmotivo_erro)) dserro
              ,0                           nrdolote
              ,0                           nrseqdig
              ,lct.dhinclusao              dhinclusao
              ,lct.dhprocessamento         dhprocessamento
        FROM
              tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
             ,tbdomic_liqtrans_motivo_erro mte
       WHERE lct.idarquivo = arq.idarquivo
         AND lct.insituacao <> 3 --in (0,1)
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND to_date(pdv.dtpagamento,'YYYY-MM-DD') BETWEEN pr_dtinicio AND pr_dtfinal
         AND trunc(lct.dhinclusao) BETWEEN pr_dtiniarq AND pr_dtfimarq
         AND (nvl(pr_insituac,9) = 9 OR -- pega todos
              decode(nvl(pdv.cdocorrencia,'XX'),'XX','XX',
                                               '00','00',
                                               '01','00',
                                               'ER') = decode(pr_insituac,0,'XX', 1,'00',2,'ER')
              )
         AND arq.tparquivo  = decode(nvl(pr_tplancto,'X'),'X',arq.tparquivo, decode(pr_tplancto,'CR',1,'DB',2,'AT',3))
         AND upper(arq.nmarquivo_origem) = nvl(upper(pr_nmarquiv),upper(arq.nmarquivo_origem))
         AND mte.cderro(+) = pdv.dsocorrencia_retorno;


      -- Cursor sobre os associados
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl,
               crapass.cdagenci,
               crapage.cddregio,
               crapass.inpessoa
          FROM crapage,
               crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci;
      rw_crapass cr_crapass%ROWTYPE;


      -- Cursor sobre as agencias
      CURSOR cr_crapcop IS
        SELECT cdcooper,
               cdagectl,
               nmrescop
          FROM crapcop;

      -- PL/Table para armazenar o resumo da listagem
      type typ_resumo IS RECORD (cdcooper crapass.cdcooper%TYPE,
                                 nmrescop crapcop.nmrescop%TYPE,
                                 cddregio crapreg.cddregio%TYPE,
                                 cdagenci crapage.cdagenci%TYPE,
                                 nrdconta VARCHAR2(20),
                                 nmprimtl tbdomic_arq_lancto_cartoes.nmestabelecimento%TYPE,
                                 nrcpfcgc VARCHAR2(50),
                                 tplancto tbdomic_arq_lancto_cartoes.tplancamento%TYPE,
                                 tpprodut tbdomic_arq_lancto_cartoes.tpproduto%TYPE,
                                 dtrefere DATE,
                                 dtinclus DATE,
                                 vllancto tbdomic_arq_lancto_cartoes.vllancamento%TYPE,
                                 dssituac VARCHAR2(10),
                                 dserro   tbdomic_arq_lancto_cartoes.dserro%TYPE);
      type typ_tab_resumo IS TABLE OF typ_resumo INDEX BY VARCHAR2(45);
      vr_resumo       typ_tab_resumo;
      -- O índice da pl/table é nmrescop(20)+cdregio(5)+cdagenci(5)+nrdconta(10)+sequencial(5)
      vr_indice       VARCHAR2(45);
      vr_nrseq        PLS_INTEGER := 0;

      -- PL/Table para armazenar as agencias
      type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                  nmrescop crapcop.nmrescop%TYPE);
      type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
      vr_crapcop       typ_tab_crapcop;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(32000);
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_des_reto       VARCHAR2(10);
      vr_typ_saida      VARCHAR2(3);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper_conectado NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);


      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_dtinicio DATE;
      vr_dtfinal  DATE;
      vr_dtiniarq DATE;
      vr_dtfimarq DATE;
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_nmrescop crapcop.nmrescop%TYPE;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_lancamento tbdomic_arq_lancto_cartoes.vllancamento%TYPE := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      vr_dserro   VARCHAR2(50);
      vr_dsdiretorio VARCHAR2(1000);      --> Local onde sera gerado o relatorio
      vr_nmarquivo   VARCHAR2(1000);      --> Nome do relatorio CSV

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'CCRD0006');

      -- Busca os dados do XML padrao
      gene0004.pc_extrai_dados(pr_xml => pr_retxml
                              ,pr_cdcooper => vr_cdcooper_conectado
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Popula a pl/table de agencia
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
        vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      END LOOP;

      -- Popula a data de inicio do lancamento
      IF TRIM(pr_dtinicio) IS NULL THEN
        vr_dtinicio := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtinicio := to_date(pr_dtinicio,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino do lancamento
      IF TRIM(pr_dtfinal) IS NULL THEN
        vr_dtfinal := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfinal := to_date(pr_dtfinal,'dd/mm/yyyy');
      END IF;

      -- Popula a data de inicio do arquivo
      IF TRIM(pr_dtiniarq) IS NULL THEN
        vr_dtiniarq := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtiniarq := to_date(pr_dtiniarq,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino do arquivo
      IF TRIM(pr_dtfimarq) IS NULL THEN
        vr_dtfimarq := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfimarq := to_date(pr_dtfimarq,'dd/mm/yyyy');
      END IF;

      FOR rw_tabela IN cr_tabela(vr_dtinicio, vr_dtfinal, vr_dtiniarq, vr_dtfimarq) LOOP
        -- Busca a cooperativa
        IF vr_crapcop.exists(rw_tabela.cdagectl) THEN
          vr_cdcooper := vr_crapcop(rw_tabela.cdagectl).cdcooper;
          vr_nmrescop := vr_crapcop(rw_tabela.cdagectl).nmrescop;
        ELSE
          vr_cdcooper := NULL;
          vr_nmrescop := NULL;
        END IF;

        -- Se foi colocado filtro por cooperativa
        IF nvl(pr_cdcooper,0) <> 0 THEN
          IF pr_cdcooper <> nvl(vr_cdcooper,0) THEN
            continue; -- Vai para o proximo registro
          END IF;
        END IF;

        -- Verifica se existe associado para o registro especifico
        OPEN cr_crapass(vr_cdcooper, rw_tabela.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Se nao possui associado, mas possui filtro de regional ou agencia, deve-se ignorar o registro
        IF rw_crapass.nmprimtl IS NULL AND
          (nvl(pr_cddregio,0) <> 0 OR
           nvl(pr_cdagenci,0) <> 0) THEN
          continue; -- Vai para o proximo registro
        END IF;

        -- Se existir associado
        IF rw_crapass.nmprimtl IS NOT NULL THEN
          -- Se a regional do parametro for diferente da regional do associado
          IF nvl(pr_cddregio,0) <> 0 AND pr_cddregio <> nvl(rw_crapass.cddregio,0) THEN
            continue; -- Vai para o proximo registro
          END IF;

          -- Se a agencia do parametro for diferente da agencia do associado
          IF nvl(pr_cdagenci,0) <> 0 AND pr_cdagenci <> rw_crapass.cdagenci THEN
            continue; -- Vai para o proximo registro
          END IF;
        END IF;

        -- Atualiza o indicador de pessoa
        vr_inpessoa := rw_crapass.inpessoa;

        -- Incrementa o sequencial do registro
        vr_nrseq := vr_nrseq + 1;
        vr_lancamento := vr_lancamento + rw_tabela.vllancamento;

        -- Insere o registro na Pl/Table, pois o mesmo passou pelos filtros
        vr_indice := rpad(nvl(vr_nmrescop,' '),20)||
                     lpad(nvl(rw_crapass.cddregio,0),5,'0')||
                     lpad(nvl(rw_crapass.cdagenci,0),5,'0')||
                     lpad(rw_tabela.nrdconta,10,0)||
                     lpad(vr_nrseq,5,'0');

        -- Atualiza a pl/table com o registro
        vr_resumo(vr_indice).cdcooper := vr_cdcooper;
        vr_resumo(vr_indice).nmrescop := vr_nmrescop;
        vr_resumo(vr_indice).cddregio := rw_crapass.cddregio;
        vr_resumo(vr_indice).cdagenci := rw_crapass.cdagenci;
        vr_resumo(vr_indice).nrdconta := GENE0002.fn_mask_conta(rw_tabela.nrdconta);
        vr_resumo(vr_indice).nmprimtl := nvl(rw_crapass.nmprimtl,rw_tabela.nmestabelecimento);
        vr_resumo(vr_indice).nrcpfcgc := GENE0002.fn_mask_cpf_cnpj(rw_tabela.nrcpfcgc,vr_inpessoa);
        vr_resumo(vr_indice).tplancto := rw_tabela.tplancamento;
        vr_resumo(vr_indice).dtrefere := rw_tabela.dtreferencia;
        vr_resumo(vr_indice).dtinclus := trunc(rw_tabela.dhinclusao);
        vr_resumo(vr_indice).vllancto := rw_tabela.vllancamento;
        vr_resumo(vr_indice).dssituac := rw_tabela.dssituacao;
        vr_resumo(vr_indice).dserro   := rw_tabela.dserro;

      END LOOP;

      -- Cria a variavel CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

      -- Se for para gerar a saida no XML
      IF pr_insaida = 1 THEN
        -- Criar cabeçalho do XML
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><servico>');

      ELSE -- Se for para gerar para arquivo CSV

        -- Busca o diretorio onde esta os arquivos Sicoob
        vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                    pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
        vr_nmarquivo := 'CONSLC_'||to_char(SYSDATE,'HHMISS')||'.csv';
        -- Criar cabeçalho do CSV
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => 'Cooperativa;Regional;PA;Conta;Nome;CPF/CNPJ;Lct;Prd;Data Lct;Data Arq;Valor;Situacao;Erro'||chr(10));
      END IF;

      -- inicializa o loop sobre a pl/table
      vr_indice := vr_resumo.first;

      -- Loop sobre a pl/table
      LOOP
        -- Se o indice for nulo, entao eh o final da pl/table
        IF vr_indice IS NULL THEN
          EXIT;
        END IF;

        -- Se for para gerar a saida no XML
        IF pr_insaida = 1 THEN

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Popula a variavel de erro
            IF vr_resumo(vr_indice).dserro IS NULL THEN
              vr_dserro := NULL;
            ELSE
              vr_dserro := substr(vr_resumo(vr_indice).dserro,1,30)||'...';
            END IF;

            -- Carrega os dados
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdcooper>' || vr_resumo(vr_indice).cdcooper ||'</cdcooper>'||
                                                            '<nmrescop>' || vr_resumo(vr_indice).nmrescop ||'</nmrescop>'||
                                                            '<cddregio>' || vr_resumo(vr_indice).cddregio ||'</cddregio>'||
                                                            '<cdagenci>' || vr_resumo(vr_indice).cdagenci ||'</cdagenci>'||
                                                            '<nrdconta>' || vr_resumo(vr_indice).nrdconta ||'</nrdconta>'||
                                                            '<nmprimtl>' || vr_resumo(vr_indice).nmprimtl ||'</nmprimtl>'||
                                                            '<nrcpfcgc>' || vr_resumo(vr_indice).nrcpfcgc ||'</nrcpfcgc>'||
                                                            '<tplancto>' || vr_resumo(vr_indice).tplancto ||'</tplancto>'||
                                                            '<dtrefere>' || to_char(vr_resumo(vr_indice).dtrefere,'DD/MM/YYYY')||'</dtrefere>'||
                                                            '<dtinclus>' || to_char(vr_resumo(vr_indice).dtinclus,'DD/MM/YYYY')||'</dtinclus>'||
                                                            '<vllancto>' || to_char(vr_resumo(vr_indice).vllancto,'fm999g999g990D00')||'</vllancto>'||
                                                            '<dssituac>' || vr_resumo(vr_indice).dssituac ||'</dssituac>'||
                                                            '<dserro>'   || vr_dserro ||'</dserro>'  ||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador >= nvl(pr_nrregist,99999);

        ELSE -- Se for para gerar no CSV
          -- Carrega os dados
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => vr_resumo(vr_indice).nmrescop  ||';'||
                                                       vr_resumo(vr_indice).cddregio ||';'||
                                                       vr_resumo(vr_indice).cdagenci ||';'||
                                                       vr_resumo(vr_indice).nrdconta ||';'||
                                                       vr_resumo(vr_indice).nmprimtl ||';'||
                                                       vr_resumo(vr_indice).nrcpfcgc ||';'||
                                                       vr_resumo(vr_indice).tplancto ||';'||
                                                       to_char(vr_resumo(vr_indice).dtrefere,'DD/MM/YYYY') ||';'||
                                                       to_char(vr_resumo(vr_indice).dtinclus,'DD/MM/YYYY') ||';'||
                                                       to_char(vr_resumo(vr_indice).vllancto,'fm999999990D00')||';'||
                                                       vr_resumo(vr_indice).dssituac ||';'||
                                                       vr_resumo(vr_indice).dserro||chr(10));
        END IF;

        -- Vai para o proximo registro
        vr_indice := vr_resumo.next(vr_indice);

      END LOOP;

      -- Se for para gerar a saida no XML
      IF pr_insaida = 1 THEN

        -- Encerrar a tag raiz
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</servico>'||
                                                     '<qtregist>'||vr_nrseq||'</qtregist>'||
                                                     '<vltotal>'||to_char(vr_lancamento,'fm999G999G990D00')||'</vltotal>'||
                                                     '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

      ELSE

        -- Encerrar o Clob
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => ' '
                               ,pr_fecha_xml      => TRUE);

        -- Gera o relatorio
        GENE0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                      pr_caminho => vr_dsdiretorio,
                                      pr_arquivo => vr_nmarquivo,
                                      pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- copia contrato pdf do diretorio da cooperativa para servidor web
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper_conectado
                                   , pr_cdagenci => NULL
                                   , pr_nrdcaixa => NULL
                                   , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro
                                   );

        -- caso apresente erro na operação
        IF nvl(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_saida; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se retornou erro
        IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_saida; -- encerra programa
        END IF;

        -- Criar XML de retorno para uso na Web
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');

      END IF;

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_contas: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_lista_contas;

  PROCEDURE pc_lista_regional(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da regional
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      -- Cursor sobre a tabela de regionais
      CURSOR cr_crapreg IS
        SELECT cddregio,
               dsdregio
          FROM crapreg
         WHERE cdcooper = pr_cdcooper
           AND cddregio = decode(nvl(pr_cddregio,0),0,cddregio,pr_cddregio)
         ORDER BY cddregio;
      rw_crapreg cr_crapreg%ROWTYPE;

      -- Variaveis gerais
      vr_ind PLS_INTEGER := -1; -- Contador de registros

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(32000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

      -- Loop sobre a tabela de regional
      FOR rw_crapreg IN cr_crapreg LOOP
        vr_ind := vr_ind + 1;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'      , pr_posicao => 0, pr_tag_nova => 'regionais', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'regionais',   pr_posicao => vr_ind, pr_tag_nova => 'cddregio', pr_tag_cont => rw_crapreg.cddregio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'regionais',   pr_posicao => vr_ind, pr_tag_nova => 'dsdregio', pr_tag_cont => rw_crapreg.dsdregio, pr_des_erro => vr_dscritic);

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_regional: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

    PROCEDURE processa_arquivo_erro(pr_retxml    IN OUT NOCOPY XMLType   --> Nome do arquivo
                                   ,pr_dscritic  IN OUT VARCHAR2) IS

    -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
    vr_nomarq                VARCHAR2(80);
    vr_numctrlemis           VARCHAR2(80);
    vr_numctrldestor         VARCHAR2(20);
    vr_ispbemissor           VARCHAR2(08);
    vr_ispbdestinatario      VARCHAR2(08);
    vr_dthrarq               VARCHAR2(19);
    vr_dtref                 VARCHAR2(10);

    vr_executado             VARCHAR2(01);
    vr_dscritic               VARCHAR2(32000);
    vr_nomarqorigem           VARCHAR2(1000);
    -- Váriáveis controle de aceitos / rejeitados
    vr_fim_aceito             NUMBER(01) := 0;
    vr_fim_rejeitado          NUMBER(01) := 0;
    vr_erro                   VARCHAR2(100);
    vr_domDoc                 DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    -- Busca o nome do arquivo de origem para atualização do RET
    CURSOR c1 (pr_nomarq IN VARCHAR2) IS
      SELECT tla.nmarquivo_origem
        FROM tbdomic_liqtrans_arquivo  tla
       WHERE tla.nmarquivo_retorno = replace(pr_nomarq,'_ERR');
      r1 c1%ROWTYPE;
  BEGIN

    -- Inicializa o contador de consultas

    -- BUSCA OS DADOS DA TAB TBDOMIC_LIQTRANS_ARQUIVO -------------

      --Busca os campos do detalhe da consulta
      pc_busca_conteudo_campo(pr_retxml, '//ASLCDOC/BCARQ/NomArq',  'S',vr_nomarq, vr_dscritic);

      -- valida se o arquivo com esse nome já foi processado.
      vr_executado := valida_arquivo_processado (pr_nomarq  => vr_nomarq);

      IF vr_executado = 'S' THEN
         RETURN;
      END  IF;

      -- busca o atributo CodErro
      BEGIN
        -- Cria o documento DOM com base no XML enviado
        vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_retxml);

        vr_erro := gene0007.fn_valor_atributo(pr_xml      => vr_domDoc     --> XML que irá receber o novo atributo
                                             ,pr_tag      => 'NomArq'                             --> Nome da TAG XML
                                             ,pr_atrib    => 'CodErro'     --> Nome do atributo
                                             ,pr_numva    => 0) ;

        dbms_xmldom.freeDocument(vr_domDoc);

      END;

      BEGIN
         -- busca o arquivo origem para atualizar o nome arquivo retornado
         OPEN c1 (vr_nomarq);
         FETCH c1 INTO r1;
         vr_nomarqorigem := r1.nmarquivo_origem;
         CLOSE C1;

         -- Atualiza arquivo origem com o nome do arquivo gerado.
    --     UPDATE tbdomic_liqtrans_arquivo
    --        SET erro = vr_erro
    --      WHERE nm_arquivo_origem = vr_nomarqorigem;
    --     IF vr_dscritic IS NOT NULL THEN
    --        pc_gera_critica(pr_nomearq => vr_nomarq
    --                       ,pr_idcampo => 'XML_Arquivo'
    --                       ,pr_dscritic => vr_dscritic);
    --     END IF;
      END;
      -- atualizar todos os pdvs do arquivo origem com o código do erro do arquivo ERR
      BEGIN
        UPDATE TBDOMIC_LIQTRANS_PDV tlp
           SET tlp.dsocorrencia_retorno = vr_erro
         WHERE tlp.idcentraliza IN (SELECT tlc.idcentraliza
                                      FROM tbdomic_liqtrans_centraliza tlc
                                     WHERE tlc.idlancto IN (SELECT idlancto
                                                              FROM tbdomic_liqtrans_lancto tll
                                                             WHERE tll.idarquivo IN (SELECT idarquivo
                                                                                       FROM tbdomic_liqtrans_arquivo tla
                                                                                      WHERE tla.nmarquivo_origem = vr_nomarqorigem)));
      EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela LIQTRANS_PDV '||SQLERRM;
            pc_gera_critica(pr_nomearq => vr_nomarq
                           ,pr_idcampo => 'Atualização vr_erro nos PDV´s'
                           ,pr_dscritic => vr_dscritic);
      END;
   END processa_arquivo_erro;


   PROCEDURE teste IS
       CURSOR c2 (pr_nomarq IN VARCHAR2) IS
      SELECT tll.nrcnpjbase_principal
            ,tll.nrcnpjbase_administrado
            ,tll.nrcnpj_credenciador
            ,tll.nrispb_devedor
            ,tlp.nrliquidacao
            ,tlp.cdocorrencia
            ,tlp.dsocorrencia_retorno
       FROM tbdomic_liqtrans_lancto tll
           ,tbdomic_liqtrans_centraliza tlc
           ,tbdomic_liqtrans_pdv tlp
           ,tbdomic_liqtrans_arquivo tla
      WHERE tll.idlancto = tlc.idlancto
        AND tla.nmarquivo_origem = 'ASLC022_05463212_20170815_00007'
        AND tlc.idcentraliza = tlp.idcentraliza
        AND ROWNUM <25;

   vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                LONG;
  vr_nomarq VARCHAR2(100) := 'ASLC022_05463212_20170815_00007';
  vr_dscritic  VARCHAR2(32000);
  BEGIN

      BEGIN

      --vr_para     := 'roberto.holz@mouts.info';
      vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET23');
      vr_assunto  := 'Domicilio Bancario - Divergencias de retorno do arquivo '||vr_nomarq;
      vr_mensagem := 'Abaixo a lista de registros com divergência após a execução do arquivo '||vr_nomarq||
                     ':<br /><br />';
--      vr_mensagem := vr_mensagem||' CNPJ Cred              Num Liquidacao            Ocorrencia     Erro <br />';
--      vr_mensagem := vr_mensagem||' ----------------    ---------------------   ----------   ----------- ';

      -- monta o e-mail de envio das divergencias (rejeitados).
      FOR r2 IN c2 (vr_nomarq) LOOP
         vr_mensagem := vr_mensagem ||'<br />'||
                    'Liquidação - '||lpad(r2.nrliquidacao,25,' ')||'<br /> '||
                    'Ocorrência - '||lpad(r2.cdocorrencia,11,' ')||'<br />'||
                    'Erro - '||lpad(r2.dsocorrencia_retorno,11,' ');
      END LOOP;

      pc_envia_email(pr_cdcooper   => 1
                    ,pr_dspara     => vr_para
                    ,pr_dsassunto  => vr_assunto
                    ,pr_dstexto    => vr_mensagem
                    ,pr_dscritic   => vr_dscritic);

      END ;


   END;

   -- Retorna o valor da TAG do XML
   FUNCTION fn_busca_valor(pr_dslinha  IN VARCHAR2
                          ,pr_dscampo  IN VARCHAR2
                          ,pr_indcampo IN VARCHAR2
                          ,pr_tppesqu  IN VARCHAR2 DEFAULT NULL -- Pesquisa especial para os arquivos *_RET (NULiquid CodErro)
                          )        RETURN VARCHAR2 IS
     w_dsvalor VARCHAR2(1000);
   BEGIN
     IF instr(pr_dslinha,pr_dscampo,1) = 0 then
       IF instr(pr_dscampo,'/',1) > 0
       OR instr(pr_dscampo,'<',1) > 0
       THEN
         w_dsvalor := 'NOK';
       ELSE
         w_dsvalor := null;
       END IF;
     ELSE
       IF instr(pr_dscampo,'/',1) > 0
       OR instr(pr_dscampo,'<',1) > 0
       THEN
         w_dsvalor := 'OK';
       ELSE
         IF NVL(pr_tppesqu,'S') = 'S' then
           w_dsvalor := substr(pr_dslinha
                              ,instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2
                              ,(instr(pr_dslinha,'"',instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2)) -
                               (instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2 ));
         ELSIF NVL(pr_tppesqu,'S') = 'ERR' then
           w_dsvalor := substr(pr_dslinha
                              ,instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2
                              ,(instr(pr_dslinha,'</',instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2)) -
                               (instr(pr_dslinha,pr_dscampo,1)+length(pr_dscampo)+2 ));
         ELSE
           w_dsvalor := substr(pr_dslinha
                              ,instr(pr_dslinha,'">',1,2)+2
                              ,(instr(pr_dslinha,'</',1)) -
                               (instr(pr_dslinha,'">',1,2)+2));
         END IF;
         --
         IF w_dsvalor IS NOT NULL THEN
           IF pr_indcampo = 'D' THEN -- Se o tipo de dado for Data, transformar para data
             -- Se for tudo zeros, desconsiderar
             IF w_dsvalor IN ('00000000','0','')  THEN
               w_dsvalor := NULL;
             ELSE
               w_dsvalor := to_date(w_dsvalor,'yyyymmdd');
             END  IF;
           ELSE
             w_dsvalor := replace(w_dsvalor,'.',',');
           END  IF;
         END IF;
       END IF;
     END IF;

     RETURN(w_dsvalor);

   END fn_busca_valor;

  PROCEDURE lista_arquivos (pnm_diretorio IN VARCHAR2) IS

    vr_dsdiretorio     VARCHAR2(100);
    vr_listaarq        VARCHAR2(32000);     --> Lista de arquivos

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

-- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp       GENE0002.typ_split;

    -- PL/Table que vai armazenar os linhas do arquivo XML
    wpr_table_of       GENE0002.typ_tab_tabela;


    vr_indice          INTEGER;

    wpr_retxml         XMLTYPE;
    vr_ok_nok          VARCHAR2(10);
    vr_arquivo         VARCHAR2(1000);
    vr_final           VARCHAR2(100);
    vr_tipo_saida      VARCHAR2(100);
    vr_arquivo_erro    NUMBER:=0;
    vr_idcampo         VARCHAR2(1000);
    vr_nmarqtemp       VARCHAR2(1000);
    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
  BEGIN

    -- Busca o diretorio onde estao os arquivos Sicoob
    vr_dsdiretorio := pnm_diretorio;
    -- Listar arquivos
    gene0001.pc_lista_arquivos( pr_path     => vr_dsdiretorio
                               ,pr_pesq     => '%.XML'
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => vr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF vr_dscritic IS NOT NULL THEN
      -- RAISE vr_exc_saida;
       NULL;
    END  IF;

      -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN
       dbms_output.put_line(vr_listaarq);
    END IF;
    
   END;

  PROCEDURE pc_insere_msg_domicilio (pr_vlrlancto    IN NUMBER
                                    ,pr_cnpjliqdant  IN VARCHAR2
                                    ,pr_dscritic     OUT VARCHAR2) IS

  BEGIN
    INSERT INTO TBDOMIC_LIQTRANS_MENSAGEM
    (DHEXECUCAO, VLLIQUIDACAO, NRCNPJCPF_CRENTRALIZA, INSITUACAO)
    VALUES
    (SYSDATE, PR_VLRLANCTO, PR_CNPJLIQDANT, 0);
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO ao tentar incluir registro na tabela TBDOMIC_LIQTRANS_MENSAGEM: '||SQLERRM;
        RETURN;

  END;

  FUNCTION fn_valida_liquid_antecipacao (pr_vlrlancto     IN NUMBER
                                        ,pr_cnpjliqdant   IN VARCHAR2
                                        ,pr_dtreferencia  IN DATE
                                        ,pr_tpformatransf IN VARCHAR2
                                        ,pr_idatualiza    IN VARCHAR2)
  RETURN VARCHAR2 IS

  CURSOR cr_msg IS
      SELECT 'S' id_existe_liquid
             ,msg.rowid
         FROM tbdomic_liqtrans_mensagem msg
        WHERE (substr(msg.nrcnpjcpf_crentraliza,1,8) = pr_cnpjliqdant
           OR msg.nrcnpjcpf_crentraliza IS NULL)
          AND msg.insituacao = 0
          AND msg.vlliquidacao = pr_vlrlancto
          AND TRUNC(msg.dhexecucao) = pr_dtreferencia
          AND pr_tpformatransf = 3;
/* Essa validação está suspensa por enquanto.
   Está comentada porque pode voltar a ser necessária após a implantação em 23/10/2017
     UNION ALL
     SELECT 'S' id_existe_liquid
            ,lmt.rowid
       FROM craplmt lmt
      WHERE lmt.dttransa = pr_dtreferencia
        AND lmt.nrispbif = to_number(pr_cnpjliqdant)
        AND lmt.vldocmto = pr_vlrlancto
        AND pr_tpformatransf <> 3;
*/        
     rw_msg               cr_msg%ROWTYPE;
  BEGIN
    -- Verifica se existe informação de liquidação
    --vr_sum_vl_pagamento := 0;
    OPEN cr_msg;
    FETCH cr_msg INTO rw_msg;
    IF cr_msg%NOTFOUND THEN
      rw_msg.id_existe_liquid := 'N';
    ELSE
      IF pr_idatualiza = 'S' THEN
        IF pr_tpformatransf = 3 THEN
          UPDATE tbdomic_liqtrans_mensagem
             SET insituacao = 1
            WHERE rowid = rw_msg.rowid;
        END IF;
      END IF;
    END IF;
    CLOSE cr_msg;

    RETURN(rw_msg.id_existe_liquid);
  END fn_valida_liquid_antecipacao;

  PROCEDURE teste2 (pr_cmd    IN VARCHAR2) IS

  BEGIN
    EXECUTE IMMEDIATE pr_cmd;
    commit;

  END;
  
  PROCEDURE pc_verif_arq_antecip_nproc (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2)  IS
    
    CURSOR cr_antecip IS
      SELECT  distinct arq.nmarquivo_origem
             ,lct.nrcnpj_credenciador
             ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
             ,substr(arq.dharquivo_origem,1,10)||' '||substr(arq.dharquivo_origem,12) dharquivo_origem
         FROM tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
        WHERE lct.idarquivo = arq.idarquivo
          AND ctz.idlancto = lct.idlancto
          AND pdv.idcentraliza = ctz.idcentraliza
          AND lct.insituacao = 0 
          AND arq.tparquivo  = 3
          AND to_date(substr(arq.dharquivo_origem,1,10)||substr(arq.dharquivo_origem,12),'YYYY-MM-DDHH24:MI:SS') < SYSDATE-1/24*1
          AND to_date(substr(arq.dharquivo_origem,1,10),'YYYY-MM-DD') = trunc(sysdate)
        ORDER BY 4;
    rw_antecip cr_antecip%ROWTYPE;

    vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                VARCHAR2(4000);
    vr_dscritic                VARCHAR2(32000);
    vr_exc_saida               EXCEPTION;
    x number;

  BEGIN
    vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET33');
    vr_assunto  := 'Domicilio Bancario - Arquivos de antecipação não processados há mais de 1 hora ';
    vr_mensagem := NULL;

    -- monta o e-mail de envio das divergencias (rejeitados).
    FOR rw_antecip IN cr_antecip LOOP
      IF vr_mensagem IS NULL THEN
        vr_mensagem := 'Abaixo a lista de arquivos de antecipação aguardando liberação LTR há mais de 1 hora'||
                       ':<br /><br />';
      END IF;
           
      vr_mensagem := vr_mensagem ||'<br />'||
                 'Arquivo - '||lpad(rw_antecip.nmarquivo_origem,100,' ')||'<br /> '||
                 'Credenciador - '||lpad(rw_antecip.nrcnpj_credenciador,14,' ')||'<br />'||
                 'Data Ref. - '||lpad(rw_antecip.dtreferencia,10,' ')||'<br />'||
                 'Data/Hora Arq. - '||lpad(rw_antecip.dharquivo_origem,20,' ');
      x := length(vr_mensagem);
      IF length(vr_mensagem) > 3800 THEN
         pc_envia_email(pr_cdcooper   => 1
                       ,pr_dspara     => vr_para
                       ,pr_dsassunto  => vr_assunto
                       ,pr_dstexto    => vr_mensagem
                       ,pr_dscritic   => vr_dscritic);
         vr_mensagem := NULL;
      END IF;
           
    END LOOP;

    IF vr_mensagem IS NOT NULL THEN
       pc_envia_email(pr_cdcooper   => 1
                     ,pr_dspara     => vr_para
                     ,pr_dsassunto  => vr_assunto
                     ,pr_dstexto    => vr_mensagem
                     ,pr_dscritic   => vr_dscritic);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO ao tentar enviar lista de arquivos de antecipação em atraso: '||SQLERRM;
        RETURN;

  END;

  PROCEDURE pc_verif_arq_nao_enviados (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2)  IS
    
    CURSOR cr_cred IS
      SELECT count(*)
        FROM tbdomic_liqtrans_arquivo a
       WHERE to_date(substr(a.dharquivo_origem,1,10),'YYYY-MM-DD') = trunc(sysdate)
         AND substr(a.nmarquivo_origem,1,7) = 'ASLC022';

    CURSOR cr_deb IS
      SELECT count(*)
        FROM tbdomic_liqtrans_arquivo a
       WHERE to_date(substr(a.dharquivo_origem,1,10),'YYYY-MM-DD') = trunc(sysdate)
         AND substr(a.nmarquivo_origem,1,7) = 'ASLC024';

    CURSOR cr_ant IS
      SELECT count(*)
        FROM tbdomic_liqtrans_arquivo a
       WHERE to_date(substr(a.dharquivo_origem,1,10),'YYYY-MM-DD') = trunc(sysdate)
         AND substr(a.nmarquivo_origem,1,7) = 'ASLC032';

    vr_qt_arq                  NUMBER;
    vr_para                    VARCHAR2(1000);
    vr_assunto                 VARCHAR2(1000);
    vr_mensagem                VARCHAR2(32000);
    vr_dscritic                VARCHAR2(32000);
    vr_exc_saida               EXCEPTION;

  BEGIN
    vr_para     := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'EMAIL_DIVERGENCIAS_RET33');
    vr_assunto  := 'Domicilio Bancario - Arquivos SILOC não recebidos';
    vr_mensagem := NULL;

    -- monta o e-mail de envio dos arquivos não enviados.
    IF sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_23_2cicl,'ddmmyyyyhh24:mi') THEN
      OPEN cr_cred;
      FETCH cr_cred INTO vr_qt_arq;
      IF cr_cred%NOTFOUND THEN
        vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de crédito no dia de hoje. <br /><br />';
      ELSIF vr_qt_arq = 0 THEN
           vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de crédito no dia de hoje. <br /><br />';
      END IF;
      CLOSE cr_cred;
    END IF;

    IF sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_25_2cicl,'ddmmyyyyhh24:mi') THEN
      OPEN cr_deb;
      FETCH cr_deb INTO vr_qt_arq;
      IF cr_deb%NOTFOUND THEN
        vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de débito no dia de hoje. <br /><br />';
      ELSIF vr_qt_arq = 0 THEN
           vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de débito no dia de hoje. <br /><br />';
      END IF;
      CLOSE cr_deb;
    END IF;
    
    IF sysdate > to_date(to_char(sysdate,'ddmmyyyy')||vr_horfim_33,'ddmmyyyyhh24:mi') THEN
      OPEN cr_ant;
      FETCH cr_ant INTO vr_qt_arq;
      IF cr_ant%NOTFOUND THEN
        vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de antecipação no dia de hoje. <br /><br />';
      ELSIF vr_qt_arq = 0 THEN
           vr_mensagem := vr_mensagem || 'Não foram recebidos arquivos de antecipação no dia de hoje. <br /><br />';
      END IF;
      CLOSE cr_ant;
    END IF;
    
    IF vr_mensagem IS NOT NULL THEN
       pc_envia_email(pr_cdcooper   => 1
                     ,pr_dspara     => vr_para
                     ,pr_dsassunto  => vr_assunto
                     ,pr_dstexto    => vr_mensagem
                     ,pr_dscritic   => vr_dscritic);
    END IF;
    
    UPDATE crapprm
       SET dsvlrprm = to_char(sysdate,'DD/MM/YYYY')
     WHERE nmsistem = 'CRED'
       AND cdcooper = 0
       AND cdacesso = 'DATA_ULT_ENVIO_EMAIL_SLC';

    COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
        pr_dscritic := 'ERRO ao tentar enviar lista de arquivos de antecipação em atraso: '||SQLERRM;
        RETURN;

  END;
  
  PROCEDURE pc_processa_reg_pendentes_orig(pr_dtprocesso IN DATE
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                          ,pr_dscritic OUT VARCHAR2)  IS

    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor sobre os registros pendentes

    CURSOR cr_lancamento IS
      SELECT  arq.idarquivo
             ,lct.nrcnpj_credenciador
             ,lct.nrcnpjbase_principal
             ,arq.tparquivo
             ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
             ,lct.dhprocessamento
             ,lct.idlancto
             ,pdv.tpforma_transf
             ,sum(pdv.vlpagamento) vlpagamento
         FROM tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
        WHERE lct.idarquivo = arq.idarquivo
          AND ctz.idlancto = lct.idlancto
          AND pdv.idcentraliza = ctz.idcentraliza
          AND lct.insituacao = 0 -- Pendente
                                 -- No final será alterado a situacao para 1-Processado
     GROUP BY arq.idarquivo, lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, arq.tparquivo, to_date(arq.dtreferencia,'YYYY-MM-DD'), lct.dhprocessamento, lct.idlancto, pdv.tpforma_transf
     ORDER BY arq.tparquivo,lct.nrcnpj_credenciador, lct.nrcnpjbase_principal, to_date(arq.dtreferencia,'YYYY-MM-DD');

    -- Cursor para informações dos lançamentos
    CURSOR cr_tabela(pr_idlancto tbdomic_liqtrans_lancto.idlancto%TYPE) IS
      SELECT pdv.nrliquidacao
            ,ctz.nrcnpjcpf_centraliza
            ,ctz.tppessoa_centraliza
            ,ctz.cdagencia_centraliza
            ,ctz.nrcta_centraliza
            ,pdv.vlpagamento
            ,to_date(pdv.dtpagamento,'YYYY-MM-DD') dtpagamento
            ,pdv.idpdv
        FROM tbdomic_liqtrans_centraliza ctz
            ,tbdomic_liqtrans_pdv pdv
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
       ORDER BY ctz.cdagencia_centraliza,ctz.nrcta_centraliza,to_date(pdv.dtpagamento,'YYYY-MM-DD');

    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper,
             cdagectl,
             nmrescop,
             flgativo
        FROM crapcop;

    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc,
             inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                       pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta,
             tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;

    CURSOR cr_antecip IS
      SELECT  distinct arq.idarquivo
             ,lct.nrcnpj_credenciador
             ,to_date(arq.dtreferencia,'YYYY-MM-DD') dtreferencia
             ,substr(arq.dharquivo_origem,1,10)||' '||substr(arq.dharquivo_origem,12) dharquivo_origem
         FROM tbdomic_liqtrans_lancto lct
             ,tbdomic_liqtrans_arquivo arq
             ,tbdomic_liqtrans_centraliza ctz
             ,tbdomic_liqtrans_pdv pdv
        WHERE lct.idarquivo = arq.idarquivo
          AND ctz.idlancto = lct.idlancto
          AND pdv.idcentraliza = ctz.idcentraliza
          AND lct.insituacao = 0 
          AND arq.tparquivo  = 3
          AND to_date(substr(arq.dharquivo_origem,1,10)||substr(arq.dharquivo_origem,12),'YYYY-MM-DDHH24:MI:SS') < SYSDATE-1/24*1
        ORDER BY 4;

    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                nmrescop crapcop.nmrescop%TYPE,
                                flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop       typ_tab_crapcop;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(32000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;


    -- Variaveis gerais
    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100);         --> Variavel de erro
    vr_dserro_arq    VARCHAR2(100);         --> Variavel de erro do reg arquivo
    vr_cdocorr       VARCHAR2(2) := NULL;   --> Código de ocorrencia do pdv
    vr_cdocorr_arq   VARCHAR2(2) := NULL;   --> Código de ocorrencia do reg arquivo
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_cdhistor      craphis.cdhistor%TYPE; --> Codigo do historico do lancamento
    vr_nrdolote      craplcm.nrdolote%TYPE; --> Numero do lote
    vr_qterros       PLS_INTEGER := 0;      --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0;      --> Quantidade de registros processados
    vr_qtfuturos     PLS_INTEGER := 0;      --> Quantidade de lancamentos futuros processados
    vr_inlctfut      VARCHAR2(01);          --> Indicador de lancamento futuro

    vr_coopdest      crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_cdcooper_lcm  craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_cdcooper_lau  craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_dtprocesso    crapdat.dtmvtolt%TYPE; --> Data da cooperativa

  BEGIN

    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;

    -- Efetua loop sobre os registros pendentes
    FOR rw_lancamento IN cr_lancamento LOOP

      -- Limpa variaveis de controle de quebra para gravacao da craplcm e craplau
      -- Como trata-se de um novo tipo de arquivo precisa-se limpar pois o numero
      -- do lote será alterado.
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;

      -- Limpa a variavel de erro
      vr_dserro_arq   := NULL;
      vr_cdocorr_arq  := NULL;
      -- Criticar tipo de arquivo.
      IF rw_lancamento.tparquivo NOT in (1,2,3) THEN
        vr_dserro_arq  := 'Tipo de arquivo ('||rw_lancamento.tparquivo||') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
      
      IF ((rw_lancamento.tparquivo <> 3) OR
        (rw_lancamento.tparquivo = 3 AND ccrd0006.fn_valida_liquid_antecipacao(rw_lancamento.vlpagamento, rw_lancamento.nrcnpjbase_principal, rw_lancamento.dtreferencia, rw_lancamento.tpforma_transf, 'S') = 'S')) THEN
          
        FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto) LOOP
          -- Limpa a variavel de erro
          vr_dserro  := NULL;
          vr_cdocorr := NULL;

          -- Efetua todas as consistencias dentro deste BEGIN
          BEGIN
            -- se existe erro a nível de arquivo/lancamento jogará para todos os
            -- registros PDV este erro
            IF NVL(vr_cdocorr_arq,'00') <> '00' THEN
              vr_dserro  := vr_dserro_arq;
              vr_cdocorr := vr_cdocorr_arq;
              RAISE vr_erro;
            END IF;

            -- Atualiza o indicador de inpessoa
            IF rw_tabela.tppessoa_centraliza = 'F' THEN
              vr_inpessoa := 1;
            ELSIF rw_tabela.tppessoa_centraliza = 'J' THEN
              vr_inpessoa := 2;
            ELSE
              vr_dserro := 'Indicador de pessoa ('||rw_tabela.tppessoa_centraliza||') nao previsto.';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;

            -- Verifica se a agencia informada existe
            IF NOT vr_crapcop.exists(rw_tabela.cdagencia_centraliza) THEN
              vr_dserro := 'Agencia informada ('||rw_tabela.cdagencia_centraliza||') nao cadastrada.';
              vr_cdocorr := '08';
              RAISE vr_erro;
            END IF;

            IF rw_tabela.vlpagamento = 0 OR rw_tabela.vlpagamento < 0 THEN
              vr_dserro := 'Valor do lancamento zerado ou negativo';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;

            IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN

              OPEN cr_craptco (pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                               pr_nrctaant => rw_tabela.nrcta_centraliza);
              FETCH cr_craptco INTO rw_craptco;

              IF cr_craptco%FOUND THEN
                vr_nrdconta := rw_craptco.nrdconta;
                vr_coopdest := rw_craptco.cdcooper;
              ELSE
                vr_nrdconta := 0;
                vr_coopdest := 0;
              END IF;

              CLOSE cr_craptco;

            ELSE
              vr_nrdconta := rw_tabela.nrcta_centraliza;
              vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
            END IF;

            -- Busca a data da cooperativa
            -- foi incluido aqui pois pode existir contas transferidas
            OPEN btch0001.cr_crapdat(vr_coopdest);
            FETCH btch0001.cr_crapdat INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;

            --Alterado para utilizar a data do parâmetro, se for diferente de NULL
            --IF vr_database_name = 'AYLLOSD' THEN
            IF pr_dtprocesso IS NULL THEN
              IF rw_crapdat.inproces > 1 THEN  -- Está executando cadeia
                vr_dtprocesso := rw_crapdat.dtmvtopr;
              ELSE
                vr_dtprocesso := rw_crapdat.dtmvtolt;
              END IF;
            ELSE
              vr_dtprocesso   := pr_dtprocesso;
            END IF;

            -- Não pode processar data de pagamento anterior
            IF rw_tabela.dtpagamento < vr_dtprocesso THEN
              vr_dserro := 'Data de pagamento menor que a data da cooperativa';
              vr_cdocorr := '03';
              RAISE vr_erro;
            END IF;

            -- Busca os dados do associado
            OPEN cr_crapass(vr_coopdest, vr_nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            IF cr_crapass%NOTFOUND THEN -- Se nao encontrar, deve-se gerar inconsistencia
              CLOSE cr_crapass;
              vr_dserro := 'Conta do associado ('||GENE0002.fn_mask_conta(rw_tabela.nrcta_centraliza)||') inexistente para a cooperativa '||
                           vr_crapcop(rw_tabela.cdagencia_centraliza).nmrescop||'.';
              vr_cdocorr := '10';
              RAISE vr_erro;
            END IF;
            CLOSE cr_crapass;

            -- Efetua consistencia sobre o associado
            IF rw_crapass.inpessoa <> vr_inpessoa THEN
              vr_dserro := 'Associado eh uma pessoa ';
              IF rw_crapass.inpessoa = 1 THEN
                vr_dserro := vr_dserro ||'fisica, porem foi enviado um ';
              ELSE
                vr_dserro := vr_dserro ||'juridica, porem foi enviado um ';
              END IF;
              IF vr_inpessoa = 1 THEN
                vr_dserro := vr_dserro ||'CPF.';
              ELSE
                vr_dserro := vr_dserro ||'CNPJ.';
              END IF;
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF rw_crapass.nrcpfcgc <> rw_tabela.nrcnpjcpf_centraliza AND rw_crapass.inpessoa = 1 THEN
              vr_dserro := 'CPF informado ('||GENE0002.fn_mask_cpf_cnpj(rw_tabela.nrcnpjcpf_centraliza,vr_inpessoa)||
                             ') difere do CPF do associado ('||GENE0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)||').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8) <> substr(lpad(rw_tabela.nrcnpjcpf_centraliza,14,0),1,8) AND rw_crapass.inpessoa = 2 then
              vr_dserro := 'CNPJ informado ('||substr(lpad(rw_tabela.nrcnpjcpf_centraliza,14,0),1,8)||
                           ') difere do CNPJ do associado ('||substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8)||').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            END IF;

          EXCEPTION
            WHEN vr_erro THEN
              NULL;
          END;

          vr_nrdolote := 1;  -- fixa 1 no número do lote

          -- Atualiza os historicos de lancamento
          IF rw_lancamento.tparquivo = 1 THEN    -- crédito
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2444;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2443;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2442;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2450;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2453;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2478;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2445;
             END IF;
          ELSIF rw_lancamento.tparquivo = 2 THEN -- débito
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2448;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2447;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2446;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2451;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2413;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2479;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2449;
             END IF;
          ELSE                                 -- antecipação
             IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN -- BRADESCO
               vr_cdhistor := 2456;
             ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN -- SIPAG
               vr_cdhistor := 2455;
             ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN -- REDECARD
               vr_cdhistor := 2454;
             ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN -- STONE
               vr_cdhistor := 2452;
             ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN -- ELAVON
               vr_cdhistor := 2414;
             ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN -- BANRISUL
               vr_cdhistor := 2480;
             ELSE  -- OUTROS CREDENCIADORES
               vr_cdhistor := 2457;
             END IF;
         END IF;

          -- Se nao existir erro, insere o lancamento
          IF vr_cdocorr IS NULL AND
             rw_tabela.dtpagamento = vr_dtprocesso THEN -- Integrar na craplcm e atualizar
                                                        -- dtdebito se existir na craplau

            -- Atualiza a cooperativa
            vr_cdcooper := vr_coopdest;

            -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
            pr_cdcritic := null;
            vr_dscritic := null;
            vr_cdcooper_lcm := vr_cdcooper; -- salva a nova cooperativa para a quebra
            pc_procura_ultseq_craplcm (pr_cdcooper    => vr_cdcooper
                                      ,pr_dtmvtolt    => vr_dtprocesso
                                      ,pr_cdagenci    => 1
                                      ,pr_cdbccxlt    => 100
                                      ,pr_nrdolote    => vr_nrdolote
                                      ,pr_nrseqdiglcm => vr_nrseqdiglcm
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

            IF vr_dscritic is not null then
              RAISE vr_exc_saida;
            END IF;

            -- insere o registro na tabela de lancamentos
            BEGIN
              INSERT INTO craplcm
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 nrseqdig,
                 vllanmto,
                 nrdctabb,
                 nrdctitg,
                 cdcooper,
                 dtrefere,
                 cdoperad,
                 CDPESQBB)
              VALUES
                (vr_dtprocesso,                                     --dtmvtolt
                 1,                                                 --cdagenci
                 100,                                               --cdbccxlt
                 vr_nrdolote,                                       --nrdolote
                 vr_nrdconta,                                       --nrdconta
                 vr_nrseqdiglcm,                                    --nrdocmto
                 vr_cdhistor,                                       --cdhistor
                 vr_nrseqdiglcm,                                    --nrseqdig
                 rw_tabela.vlpagamento,                             --vllanmto
                 vr_nrdconta,                                       --nrdctabb
                 GENE0002.fn_mask(vr_nrdconta,'99999999'),          --nrdctitg
                 vr_cdcooper,                                       --cdcooper
                 rw_tabela.dtpagamento,                             --dtrefere
                 '1',                                               --cdoperad
                 rw_tabela.nrliquidacao);                           --CDPESQBB
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Atualiza data de débito na craplau
            BEGIN
              UPDATE craplau
                 SET dtdebito = vr_dtprocesso
               WHERE cdcooper = vr_cdcooper
                 AND dtmvtopg = rw_tabela.dtpagamento
                 AND nrdconta = vr_nrdconta
                 AND cdseqtel = rw_tabela.nrliquidacao;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela CRAPLAU - dtdebito : '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_qtprocessados := vr_qtprocessados + 1;

          END IF;


          IF vr_cdocorr IS NULL AND
             rw_tabela.dtpagamento > vr_dtprocesso THEN -- Integrar na craplau

            -- Atualiza a cooperativa
            vr_cdcooper := vr_coopdest;

            -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
            vr_cdcritic := null;
            vr_dscritic := null;
            vr_cdcooper_lau := vr_cdcooper;

            pc_procura_ultseq_craplau (pr_cdcooper    => vr_cdcooper
                                      ,pr_dtmvtolt    => vr_dtprocesso
                                      ,pr_cdagenci    => 1
                                      ,pr_cdbccxlt    => 100
                                      ,pr_nrdolote    => vr_nrdolote
                                      ,pr_nrseqdiglau => vr_nrseqdiglau
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

            IF vr_dscritic is not null then
              RAISE vr_exc_saida;
            END IF;

            -- insere o registro na tabela de lancamentos
            BEGIN
              INSERT INTO craplau
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdconta,
                 nrdocmto,
                 cdhistor,
                 nrseqdig,
                 vllanaut,
                 nrdctabb,
                 nrdctitg,
                 cdcooper,
                 dtmvtopg,
  --               cdoperad,
                 cdseqtel,
                 dsorigem)
              VALUES
                (vr_dtprocesso,                                     --dtmvtolt
                 1,                                                 --cdagenci
                 100,                                               --cdbccxlt
                 vr_nrdolote,                                       --nrdolote
                 vr_nrdconta,                                       --nrdconta
                 vr_nrseqdiglau,                                    --nrdocmto
                 vr_cdhistor,                                       --cdhistor
                 vr_nrseqdiglau,                                    --nrseqdig
                 rw_tabela.vlpagamento,                             --vllanaut
                 vr_nrdconta,                                       --nrdctabb
                 GENE0002.fn_mask(vr_nrdconta,'99999999'),          --nrdctitg
                 vr_cdcooper,                                       --cdcooper
                 rw_tabela.dtpagamento,                             --dtrefere
  --               '1',                                               --cdoperad
                 rw_tabela.nrliquidacao,                            --cdseqtel
                 'DOMICILIO');                                      --dsorigem
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CRAPLAU: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_qtfuturos := vr_qtfuturos + 1;

          END IF;

          IF nvl(vr_cdocorr,'00') <> '00' THEN
            vr_qterros := vr_qterros + 1;
          END IF;

          IF nvl(vr_cdocorr,'00') = '00' THEN
            IF rw_tabela.dtpagamento > vr_dtprocesso THEN
               IF rw_lancamento.tparquivo = 1 THEN    -- crédito
                  vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
               END IF;
            END IF;
          END IF;

          -- Efetua a atualizacao da tabela de liquidacao pdv

          BEGIN
            UPDATE tbdomic_liqtrans_pdv
               SET cdocorrencia = NVL(vr_cdocorr,'00')
                  ,dserro = vr_dserro
             WHERE idpdv = rw_tabela.idpdv;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_pdv: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END LOOP;  -- loop cr_tabela

        -- Efetua a atualizacao da situacao na tabela de lancamentos
        BEGIN
          UPDATE tbdomic_liqtrans_lancto
             SET insituacao = 1 -- processado
                ,dhprocessamento = SYSDATE
           WHERE idlancto = rw_lancamento.idlancto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;
    END LOOP;  -- loop cr_lancamento

    -- Se possuir algum registro com erro ou processado
    IF vr_qtprocessados > 0 OR vr_qterros > 0 OR vr_qtfuturos > 0 THEN
      -- Gera log de quantidade de registros processados
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                ,pr_ind_tipo_log => 1 -- Aviso
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                 || 'Registros processados com sucesso: '||vr_qtprocessados
                                                 || '. Registros futuros processados com sucesso: '||vr_qtfuturos
                                                 || '. Registros com erro: '||vr_qterros||'.'
                                ,pr_nmarqlog => 'CONSLC');
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END; -- pc_processa_reg_pendentes --

END CCRD0006;
/
