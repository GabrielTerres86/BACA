CREATE OR REPLACE PROCEDURE CECRED.pc_crps711 IS
  /* .............................................................................

     Programa: pc_crps711 (Fontes/crps711.p)
     Sistema : Baixas Operacionais DDA0108R2 - LAUTOM
     Sigla   : CRED
     Autor   : Ricardo Linhares
     Data    : Dezembro/2016                     Ultima atualizacao: 02/01/2018

     Dados referentes ao programa:

     Frequencia: Executado via Job - A cada 1h
     Objetivo  : Efetuar as baixas operacionais

     Alteracoes: 01/08/2017 - Incluido rotina para enviar titulos pagos em contigencia
                              para a JD-CIP. PRJ340-NPC (Odirlei-AMcom)
     
     08/08/2017 - Ajustado data de credito do boleto em funçao da data de 
                  movimento do sistema. (Rafael)

     31/10/2017 - Utilizar data do cash para registro de movimento da baixa operacional (Rafael).
     
     02/01/2017 - #778808 Filtro das cooperativas ativas para não gerar logs desnecessários (Carlos)

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS711';
  vr_cdcooper   NUMBER;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  TYPE tt_tbcobran_baixa_operac IS TABLE OF tbcobran_baixa_operac%ROWTYPE INDEX BY PLS_INTEGER;
  vr_baixa_operac tt_tbcobran_baixa_operac;
  
  -- PL/Table para armazenar os borderôs
  type typ_tot_baixa_por_coop IS record (vr_tot_qtd_baixas_opera NUMBER,
                                         vr_tot_vlr_baixas_opera NUMBER,
                                         vr_tot_qtd_cancelamentos NUMBER,
                                         vr_tot_vlr_cancelamentos NUMBER);

  type typ_tab_tot_baixas is table of typ_tot_baixa_por_coop index BY PLS_INTEGER;
  vr_tab_tot_baixas typ_tab_tot_baixas;  
  
  vr_inicio_job DATE;
  vr_fim_job DATE;
  
  ------------------------------- CURSORES ---------------------------------
  -- Cursor de leitura de boletos
  CURSOR cr_crapcob (pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrcnvcob IN crapcco.nrconven%TYPE
                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
                    
		SELECT cob.cdcooper
          ,cob.nrdconta
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.nrdctabb
          ,cob.cdbandoc 
      FROM crapcob cob, crapcco cco, crapcop cop
		 WHERE cco.nrconven = pr_nrcnvcob
		   AND cob.cdcooper = cco.cdcooper
		   AND cob.nrcnvcob = cco.nrconven		   
		   AND cob.nrdconta = pr_nrdconta
		   AND cob.nrdocmto = pr_nrdocmto
		   AND cob.nrdctabb = cco.nrdctabb
		   AND cob.cdbandoc = cco.cddbanco
		   AND cop.cdcooper = cco.cdcooper
		   AND cop.flgativo = 1;
  rw_crapcob cr_crapcob%ROWTYPE;             
  
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;  
   
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  vr_index PLS_INTEGER;

  -- Flag para verificar se o título ja foi descontado
  vr_titulo_descontado BOOLEAN := FALSE;
  

  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBCOBRAN_BAIXA_OPERACIONAL';
  vr_flgerlog    BOOLEAN := FALSE;
  
  -- Envia e-mail de erro para Cobranca@cecred.coop.br
  PROCEDURE pc_enviar_email_erro (pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_dscritic IN VARCHAR2) IS
    
  BEGIN
    
    DECLARE
      vr_dscritic VARCHAR2(4000);
    
    BEGIN
       gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                 ,pr_cdprogra        => 'CRPS711'
                                 ,pr_des_destino     => 'cobranca@cecred.coop.br'
                                 ,pr_des_assunto     => 'Erro CRPS711'
                                 ,pr_des_corpo       => pr_dscritic
                                 ,pr_des_anexo       => NULL
                                 ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                 ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                 ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                 ,pr_des_erro        => vr_dscritic);                                 
    END;
    
  END pc_enviar_email_erro;
  
  -- Gera log de erro por cooperativa
  PROCEDURE pc_gera_log_erro (pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_dscritic IN VARCHAR2) IS
    
  BEGIN
    DECLARE
      vr_dsdireto VARCHAR2(400);
    BEGIN
       vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => 'log');

       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2
                                 ,pr_dsdirlog     => vr_dsdireto
                                 ,pr_flfinmsg     => 'N'                                 
                                 ,pr_nmarqlog     => 'pc_crps711'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss')||' - Erro: ' || pr_dscritic);                                       
                                 
    END;
    
  END pc_gera_log_erro;
  
  PROCEDURE pc_inicializa_contador_baixas(pr_totbaixas IN OUT typ_tab_tot_baixas) IS
  BEGIN
    DECLARE
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3
           AND flgativo = 1
         ORDER BY cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;     
    
    BEGIN
         FOR rw_crapcop IN cr_crapcop LOOP
           pr_totbaixas(rw_crapcop.cdcooper).vr_tot_qtd_baixas_opera := 0;
           pr_totbaixas(rw_crapcop.cdcooper).vr_tot_vlr_baixas_opera := 0;
           pr_totbaixas(rw_crapcop.cdcooper).vr_tot_qtd_cancelamentos := 0;
           pr_totbaixas(rw_crapcop.cdcooper).vr_tot_vlr_cancelamentos := 0;
         END LOOP;
    END;
      
  END pc_inicializa_contador_baixas;
   
  -- Gera log da execução por cooperativa
  PROCEDURE pc_gera_log_execucao(pr_iniciojob IN DATE
                                ,pr_fimjob    IN DATE
                                ,pr_totbaixas IN typ_tab_tot_baixas) IS
  BEGIN
    DECLARE
 
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3
           AND flgativo = 1
         ORDER BY cdcooper;

     rw_crapcop cr_crapcop%ROWTYPE;     
     vr_dsdireto VARCHAR2(400);
   
    BEGIN

     FOR rw_crapcop IN cr_crapcop LOOP

       vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_nmsubdir => 'log');

       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                 ,pr_ind_tipo_log => 1
                                 ,pr_dsdirlog     => vr_dsdireto
                                 ,pr_flfinmsg     => 'N'
                                 ,pr_nmarqlog     => 'pc_crps711'
                                 ,pr_des_log      => to_char(pr_iniciojob,'DD/MM/YYYY hh24:mi:ss')||' - Inicio;');

       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                 ,pr_ind_tipo_log => 1
                                 ,pr_dsdirlog     => vr_dsdireto
                                 ,pr_flfinmsg     => 'N'                                 
                                 ,pr_nmarqlog     => 'pc_crps711'                                 
                                 ,pr_des_log      => to_char(pr_iniciojob,'DD/MM/YYYY hh24:mi:ss')
                                                  || ' - Baixas operacionais: <Qtd> (' || pr_totbaixas(rw_crapcop.cdcooper).vr_tot_qtd_baixas_opera || ')'
                                                  || ', <Valor> (' || pr_totbaixas(rw_crapcop.cdcooper).vr_tot_vlr_baixas_opera || ')');
                                                  
       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                 ,pr_ind_tipo_log => 1
                                 ,pr_dsdirlog     => vr_dsdireto
                                 ,pr_flfinmsg     => 'N'                                 
                                 ,pr_nmarqlog     => 'pc_crps711'                                 
                                 ,pr_des_log      => to_char(pr_iniciojob,'DD/MM/YYYY hh24:mi:ss')
                                                  || ' - Cancelamentos: <Qtd> (' || pr_totbaixas(rw_crapcop.cdcooper).vr_tot_qtd_cancelamentos || ')'
                                                  || ', <Valor> (' || pr_totbaixas(rw_crapcop.cdcooper).vr_tot_vlr_cancelamentos || ')');                                                  

       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                 ,pr_ind_tipo_log => 1
                                 ,pr_dsdirlog     => vr_dsdireto
                                 ,pr_flfinmsg     => 'N'                                 
                                 ,pr_nmarqlog     => 'pc_crps711'                                                                  
                                 ,pr_des_log      => to_char(pr_fimjob,'DD/MM/YYYY hh24:mi:ss')||' - Fim;');

     END LOOP;

    END;

  END pc_gera_log_execucao;

  -- Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    -- Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 0    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;
  
  -- Verifica a data de desconto de título com base no float
  FUNCTION fn_verifica_desconto_titulo(pr_cdcooper IN craptdb.cdcooper%TYPE
                                       ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                       ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                                       ,pr_nrdocmto IN craptdb.nrdocmto%TYPE
                                       ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                                       ,pr_cdbandoc IN craptdb.cdbandoc%TYPE) RETURN BOOLEAN IS
  BEGIN
    
    DECLARE
      vr_possui_desconto number;
    BEGIN
                       
      SELECT COUNT(*)
        INTO vr_possui_desconto
        FROM craptdb tdb
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrdconta = pr_nrdconta
         AND tdb.nrcnvcob = pr_nrcnvcob
         AND tdb.nrdocmto = pr_nrdocmto
         AND tdb.nrdctabb = pr_nrdctabb
         AND tdb.cdbandoc = pr_cdbandoc
         AND tdb.insittit = 4; 

      IF vr_possui_desconto > 0 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END;

  END fn_verifica_desconto_titulo;
  
  -- Copia os registros da Cabine JD (SQL Server) para um Temp Table
  PROCEDURE pc_copiar_regsitros_jd (pr_baixa_operac IN OUT tt_tbcobran_baixa_operac
                                   ,pr_data_filtro IN crapdat.dtmvtoan%TYPE)  IS
  BEGIN
    DECLARE
       -- Cursor de leitura de dados da JD
       CURSOR cr_jd (pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
           SELECT rownum,
                  ctrl."CdLeg" cdleg,
                  optit."IdOpLeg" idopleg,
                  ctrl."IdTituloLeg" idtituloleg,
                  ctrl."IdOpJD" idopjd,
                  optit."NumIdentcTit" numidentctit,
                  optit."DtHrOpJD" dthropjd,
                  optit."TpOpJD" tpopjd,
                  optit."NumIdentcBaixaOperac" numidentcbaixaoperac,
                  optit."TpBaixaOperac" tpbaixaoperac,
                  optit."ISPBPartRecbdrBaixaOperac" ispbpartrecbdrbaixaoperac,
                  optit."CodPartRecbdrBaixaOperac" codpartrecbdrbaixaoperac,
                  optit."TpPessoaPort" tppessoaport,
                  optit."CNPJ_CPFPort" cnpj_cpfport,
                  optit."DtProcBaixaOperac" dtprocbaixaoperac,
                  optit."VlrBaixaOperacTit" vlrbaixaoperactit,
                  optit."NumCodBarrasBaixaOperac" numcodbarrasbaixaoperac,
                  optit."CanPgto" canpgto,
                  optit."MeioPgto" meiopgto,
                  optit."SitTitPgto" sittitpgto,
                  cob.cdcooper,
                  cob.nrdconta,
                  cob.nrcnvcob,                  
                  cob.nrdocmto
--                  TO_NUMBER(TRIM(SUBSTR(optit."NumCodBarrasBaixaOperac",20,6))) nrcnvcob, -- numero do convenio
--                  TO_NUMBER(TRIM(SUBSTR(optit."NumCodBarrasBaixaOperac",26,8))) nrdconta, -- numero da conta do cooperado
--                  TO_NUMBER(TRIM(SUBSTR(optit."NumCodBarrasBaixaOperac",34,9))) nrdocmto -- numero do boleto           
             FROM TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl@jdnpcbisql ctrl
       INNER JOIN TBJDNPCDSTLEG_JD2LG_OpTit@jdnpcbisql optit
               ON optit."CdLeg" = ctrl."CdLeg"
              AND optit."IdTituloLeg" = ctrl."IdTituloLeg"
              AND optit."IdOpJD" = ctrl."IdOpJD"
       INNER JOIN crapcob cob
               ON cob.idtitleg = ctrl."IdTituloLeg"
            WHERE optit."TpOpJD" IN ('BO','CB')
              AND TO_DATE(optit."DtHrOpJD",'YYYYMMDDhh24miss') >= pr_dtmvtoan;
         rw_jd cr_jd%ROWTYPE;         
    
    BEGIN
      
    FOR rw_jd IN cr_jd (pr_dtmvtoan => pr_data_filtro) LOOP
       pr_baixa_operac(rw_jd.rownum).cdcooper := rw_jd.cdcooper;
       pr_baixa_operac(rw_jd.rownum).dtmvtolt := rw_crapdat.dtmvtocd;
       pr_baixa_operac(rw_jd.rownum).nrtit_legado := rw_jd.idtituloleg;
       pr_baixa_operac(rw_jd.rownum).nroperac_legado := nvl(rw_jd.idopleg,0);
       pr_baixa_operac(rw_jd.rownum).nroperac_jd := rw_jd.idopjd;
       pr_baixa_operac(rw_jd.rownum).nrdconta := rw_jd.nrdconta;
       pr_baixa_operac(rw_jd.rownum).nrcnvcob := rw_jd.nrcnvcob;
       pr_baixa_operac(rw_jd.rownum).nrdocmto := rw_jd.nrdocmto;
       pr_baixa_operac(rw_jd.rownum).nrdident := rw_jd.numidentctit;
       pr_baixa_operac(rw_jd.rownum).dhoperac_jd := TO_DATE(rw_jd.dthropjd,'YYYYMMDDhh24miss');
       pr_baixa_operac(rw_jd.rownum).tpoperac_jd := rw_jd.tpopjd;
       pr_baixa_operac(rw_jd.rownum).nrbaixa_operac := rw_jd.numidentcbaixaoperac;
       pr_baixa_operac(rw_jd.rownum).tpbxoper := rw_jd.tpbaixaoperac;
       pr_baixa_operac(rw_jd.rownum).nrispbif := rw_jd.ispbpartrecbdrbaixaoperac;
       pr_baixa_operac(rw_jd.rownum).cddbanco := rw_jd.codpartrecbdrbaixaoperac;
       pr_baixa_operac(rw_jd.rownum).inpessoa := CASE rw_jd.tppessoaport WHEN 'F' THEN 1 ELSE 2 END;
       pr_baixa_operac(rw_jd.rownum).nrcpfcgc := rw_jd.cnpj_cpfport;
       pr_baixa_operac(rw_jd.rownum).dtproc_baixa := TO_DATE(rw_jd.dtprocbaixaoperac,'YYYYMMDDhh24miss');
       pr_baixa_operac(rw_jd.rownum).vlbaixa := rw_jd.vlrbaixaoperactit;
       pr_baixa_operac(rw_jd.rownum).dscodbar := rw_jd.numcodbarrasbaixaoperac;
       pr_baixa_operac(rw_jd.rownum).tpcanal_pag := rw_jd.canpgto;
       pr_baixa_operac(rw_jd.rownum).tpmeio_pag := rw_jd.meiopgto;
       pr_baixa_operac(rw_jd.rownum).insitpag := rw_jd.sittitpgto;
    END LOOP;    
    
    END;

  END pc_copiar_regsitros_jd;
  
  -- Salva os registros lidos da Cabine JD que estão na Temp Table para tabela no Oracle
  PROCEDURE pc_salvar_registros (pr_tab_baixa_operac IN tt_tbcobran_baixa_operac
                                ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic     OUT crapcri.dscritic%TYPE ) IS
  BEGIN
  
    FORALL idx IN INDICES OF pr_tab_baixa_operac SAVE EXCEPTIONS 
      INSERT INTO tbcobran_baixa_operac
          ( cdcooper
           ,dtmvtolt 
           ,dtcredito
           ,nrtit_legado
           ,nroperac_legado
           ,nroperac_jd
           ,nrdconta
           ,nrcnvcob
           ,nrdocmto
           ,nrdident
           ,dhoperac_jd
           ,tpoperac_jd
           ,nrbaixa_operac
           ,tpbxoper
           ,nrispbif
           ,cddbanco
           ,inpessoa
           ,nrcpfcgc
           ,dtproc_baixa
           ,vlbaixa
           ,dscodbar
           ,tpcanal_pag
           ,tpmeio_pag
           ,insitpag) 
      VALUES 
          ( pr_tab_baixa_operac(idx).cdcooper
           ,pr_tab_baixa_operac(idx).dtmvtolt
           ,pr_tab_baixa_operac(idx).dtcredito
           ,pr_tab_baixa_operac(idx).nrtit_legado
           ,pr_tab_baixa_operac(idx).nroperac_legado
           ,pr_tab_baixa_operac(idx).nroperac_jd
           ,pr_tab_baixa_operac(idx).nrdconta
           ,pr_tab_baixa_operac(idx).nrcnvcob
           ,pr_tab_baixa_operac(idx).nrdocmto
           ,pr_tab_baixa_operac(idx).nrdident
           ,pr_tab_baixa_operac(idx).dhoperac_jd
           ,pr_tab_baixa_operac(idx).tpoperac_jd
           ,pr_tab_baixa_operac(idx).nrbaixa_operac
           ,pr_tab_baixa_operac(idx).tpbxoper
           ,pr_tab_baixa_operac(idx).nrispbif
           ,pr_tab_baixa_operac(idx).cddbanco
           ,pr_tab_baixa_operac(idx).inpessoa
           ,pr_tab_baixa_operac(idx).nrcpfcgc
           ,pr_tab_baixa_operac(idx).dtproc_baixa
           ,pr_tab_baixa_operac(idx).vlbaixa
           ,pr_tab_baixa_operac(idx).dscodbar
           ,pr_tab_baixa_operac(idx).tpcanal_pag
           ,pr_tab_baixa_operac(idx).tpmeio_pag
           ,pr_tab_baixa_operac(idx).insitpag);
      
  EXCEPTION
    WHEN others THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao inserir na tabela crapris. '||
                      SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
      RAISE vr_exc_saida;
  END pc_salvar_registros;

  -- Exclui os registros lido diretamente na tabela da Cabine JD
  PROCEDURE pc_excluir_registros_jd (pr_tab_baixa_operac IN tt_tbcobran_baixa_operac
                                    ,pr_cdcritic     OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_index PLS_INTEGER;
      vr_idtitleg VARCHAR2(25);
      BEGIN
        FOR vr_index IN pr_tab_baixa_operac.FIRST..pr_tab_baixa_operac.LAST LOOP
          vr_idtitleg := to_char(pr_tab_baixa_operac(vr_index).NRTIT_LEGADO);
          DELETE TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl@jdnpcbisql ctrl
           WHERE ctrl."IdTituloLeg"  = vr_idtitleg;
        END LOOP;
        
      EXCEPTION
        WHEN others THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro excluir da tabela TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl@jdnpcsql ctrl: '|| SQLERRM;
          RAISE vr_exc_saida;        
      END;
  
  END pc_excluir_registros_jd;
      
  -- Função para calcular a data de crédito
  FUNCTION fn_calcular_data_credito(pr_cdcooper IN crapcob.cdcooper%TYPE
                                   ,pr_nrdconta IN crapcob.nrdconta%TYPE
                                   ,pr_nrconven IN crapcob.nrcnvcob%TYPE
                                   ,pr_vlbaixa  IN tbcobran_baixa_operac.vlbaixa%TYPE
                                   ,pr_dtprbaix IN tbcobran_baixa_operac.dtproc_baixa%TYPE) RETURN DATE IS
    
  BEGIN
    
    DECLARE
    
      --Cursor para buscar o Float
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT ceb.qtdfloat
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = pr_nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;          
      vr_dtcredit DATE := pr_dtprbaix;
      vr_float NUMBER := 0;
    
    BEGIN
      
       OPEN cr_crapceb (pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrconven => pr_nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      
      IF cr_crapceb%NOTFOUND THEN
        CLOSE cr_crapceb;
      ELSE
        vr_float := rw_crapceb.qtdfloat;
        CLOSE cr_crapceb;
      END IF;
      
      -- A partir do Float calcula a data de crédito
      IF vr_float > 0 AND pr_vlbaixa < 250000 THEN
        
        FOR i IN 1..vr_float LOOP
          vr_dtcredit := vr_dtcredit + 1;  
          vr_dtcredit := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_dtcredit
                                                     ,pr_tipo =>  'P'
                                                     ,pr_excultdia => TRUE);
        END LOOP;

      END IF;
    
      RETURN vr_dtcredit;
      
    END;
    
  END fn_calcular_data_credito;

  BEGIN

  --------------- VALIDACOES INICIAIS -----------------

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
                            
  -- Log de início da execução
  pc_controla_log_batch('I');                            
  
  pc_inicializa_contador_baixas(pr_totbaixas => vr_tab_tot_baixas);

  vr_inicio_job := SYSDATE;

  ----------------- INICIO DO PROGRAMA -------------------                            

   vr_cdcooper := 3;

   OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
   FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
   IF BTCH0001.cr_crapdat%NOTFOUND THEN     
     CLOSE BTCH0001.cr_crapdat;
     vr_cdcritic:= 1;
     vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
     RAISE vr_exc_saida;
   ELSE
     CLOSE BTCH0001.cr_crapdat;
   END IF;    
                 
   -- Copia os registros da cabine JD para uma Temp Table
   pc_copiar_regsitros_jd(vr_baixa_operac, rw_crapdat.dtmvtoan);
   
   vr_index := vr_baixa_operac.FIRST;
   
   IF vr_index IS NOT NULL THEN
   
     FOR vr_index IN vr_baixa_operac.FIRST..vr_baixa_operac.LAST LOOP
     
         OPEN cr_crapcob (pr_nrdconta => vr_baixa_operac(vr_index).nrdconta
                         ,pr_nrcnvcob => vr_baixa_operac(vr_index).nrcnvcob
                         ,pr_nrdocmto => vr_baixa_operac(vr_index).nrdocmto);
        FETCH cr_crapcob INTO rw_crapcob;
        
        IF cr_crapcob%NOTFOUND THEN
          CLOSE cr_crapcob;
          CONTINUE;
        END IF;

        CLOSE cr_crapcob;
        
        vr_cdcooper := rw_crapcob.cdcooper;
        
        -- Pega data da cooperativa específica
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        IF BTCH0001.cr_crapdat%NOTFOUND THEN     
          CLOSE BTCH0001.cr_crapdat;
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          CLOSE BTCH0001.cr_crapdat;
        END IF;          
        
        -- Atribui a cooperativa a partir do boleto
        vr_baixa_operac(vr_index).cdcooper := vr_cdcooper;      
        vr_baixa_operac(vr_index).dtmvtolt := rw_crapdat.dtmvtocd;
        
        -- Totalizacao para os Logs
        IF vr_baixa_operac(vr_index).tpoperac_jd = 'BO' THEN
          vr_tab_tot_baixas(vr_cdcooper).vr_tot_qtd_baixas_opera := vr_tab_tot_baixas(vr_cdcooper).vr_tot_qtd_baixas_opera + 1;
          vr_tab_tot_baixas(vr_cdcooper).vr_tot_vlr_baixas_opera := vr_tab_tot_baixas(vr_cdcooper).vr_tot_vlr_baixas_opera + vr_baixa_operac(vr_index).vlbaixa;
        ELSE
          vr_tab_tot_baixas(vr_cdcooper).vr_tot_qtd_cancelamentos := vr_tab_tot_baixas(vr_cdcooper).vr_tot_qtd_cancelamentos + 1;
          vr_tab_tot_baixas(vr_cdcooper).vr_tot_vlr_cancelamentos := vr_tab_tot_baixas(vr_cdcooper).vr_tot_vlr_cancelamentos + vr_baixa_operac(vr_index).vlbaixa;
        END IF;

        -- Verifica se possui titulo descontado
        vr_titulo_descontado := fn_verifica_desconto_titulo(pr_cdcooper => vr_cdcooper
                                                           ,pr_nrdconta => rw_crapcob.nrdconta
                                                           ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                                           ,pr_nrdocmto => rw_crapcob.nrdocmto
                                                           ,pr_nrdctabb => rw_crapcob.nrdctabb
                                                           ,pr_cdbandoc => rw_crapcob.cdbandoc);
        -- Se já possui desconto então ignora
        IF vr_titulo_descontado = TRUE THEN
          CONTINUE;
        END IF;
        
        -- Cacula a data para crédito
        vr_baixa_operac(vr_index).dtcredito := fn_calcular_data_credito(pr_cdcooper => vr_cdcooper
                                                                       ,pr_nrdconta => rw_crapcob.nrdconta
                                                                       ,pr_nrconven => rw_crapcob.nrcnvcob
                                                                       ,pr_vlbaixa  => vr_baixa_operac(vr_index).vlbaixa
                                                                       ,pr_dtprbaix => rw_crapdat.dtmvtocd);
        
     END LOOP;
   
   END IF;
   -- se não existir registros na JD apenas gera log
   IF vr_baixa_operac.count = 0 THEN
     vr_cdcritic:= 0;
     vr_dscritic:= 'Não há registros na cabine JD para serem importados';
     
     pc_gera_log_erro(pr_cdcooper => vr_cdcooper
                      ,pr_dscritic => vr_dscritic);
                      
     vr_dscritic := NULL;
          
   ELSE
   
   -- Salva os registros na tabela do Oracle
   pc_salvar_registros (pr_tab_baixa_operac => vr_baixa_operac
                       ,pr_cdcritic         => vr_cdcritic
                       ,pr_dscritic         => vr_dscritic);   
                        
   -- Exclui os registros importados da Cabine JD
   pc_excluir_registros_jd(pr_tab_baixa_operac => vr_baixa_operac
                          ,pr_cdcritic         => vr_cdcritic
                          ,pr_dscritic         => vr_dscritic);  
                          
   END IF;
   
   --> Verificar se possui titulos pagos em contigencia pendentes de envio para a JD  
   NPCB0002.pc_proc_tit_contigencia(pr_cdcooper   => 0                   --> Codigo da cooperativa
                                   ,pr_dtmvtolt   => rw_crapdat.dtmvtocd --> Numer da conta do cooperado
                                   ,pr_cdcritic   => vr_cdcritic         --> Codigo da critico
                                   ,pr_dscritic   => vr_dscritic);       --> Descrição da critica
   IF nvl(vr_cdcritic,0) > 0 OR
      TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_saida; 
   END IF;   
  
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------
 
  vr_fim_job := SYSDATE;

  -- Gera o Log por cooperativa
  pc_gera_log_execucao(pr_iniciojob => vr_inicio_job
                      ,pr_fimjob    => vr_fim_job
                      ,pr_totbaixas => vr_tab_tot_baixas);

  -- Log de fim da execução
  pc_controla_log_batch('F');

  COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      pc_gera_log_erro(pr_cdcooper => vr_cdcooper
                      ,pr_dscritic => vr_dscritic);

      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := sqlerrm;
      vr_flgerlog := TRUE;
      pc_controla_log_batch('E', vr_dscritic);

      pc_gera_log_erro(pr_cdcooper => vr_cdcooper
                      ,pr_dscritic => vr_dscritic);    
                      
      pc_enviar_email_erro(pr_cdcooper => vr_cdcooper
                          ,pr_dscritic => vr_dscritic);
                        
      ROLLBACK;

END pc_crps711;
/
