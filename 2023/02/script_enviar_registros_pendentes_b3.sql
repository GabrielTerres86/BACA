PL/SQL Developer Test script 3.0
1513
DECLARE
    vr_dtmvto2a DATE;

    CURSOR cr_crapcop IS
      SELECT cdcooper, nmrescop
        FROM cecred.crapcop
       WHERE cdcooper <> 3
         AND flgativo = 1;

    vr_dtinictd DATE;
    vr_vlinictd NUMBER;

    rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
      
    vr_exc_sai_lan_arq_1_S        EXCEPTION; 
    vr_exc_sai_LanArq_LopCop_S    EXCEPTION; 
    vr_exc_sai_LanArq_LopCop_1    EXCEPTION; 
    vr_exc_sai_LanArq_LopLct_2_A  EXCEPTION; 
    vr_exc_sai_LanArq_LopRgt_2_B  EXCEPTION; 
    vr_exc_sai_LanArq_LopWh1_2C   EXCEPTION; 
    vr_exc_sai_LanArqLopWh1Wh2_2C EXCEPTION; 
      
    vr_nmproint1               VARCHAR2  (100) := 'pc_verifi_lanctos_custodia';      
    vr_dssqlerrm               VARCHAR2 (4000) := NULL;
    vr_dsparlp1                VARCHAR2 (4000) := NULL;
    vr_dsparlp2                VARCHAR2 (4000) := NULL;
    vr_dsparlp3                VARCHAR2 (4000) := NULL;
    vr_dsparesp                VARCHAR2 (4000) := NULL;
    vr_qtlimerr                NUMBER      (9);
    vr_flenvreg VARCHAR2(1); 
    vr_flenvrgt VARCHAR2(1); 
    vr_cdacesso     cecred.crapprm.cdacesso%TYPE;
    vr_idcritic  NUMBER;
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(32767);
    vr_nmaction    VARCHAR2    (32);
    vr_dsdaviso VARCHAR2(32767);
    vr_qtftcota CONSTANT  NUMBER(3,2) := 0.01;
    vr_ctcritic    NUMBER       (9) := 0;
    vr_ctcri_ant   NUMBER       (9) := 0;
    vr_dspro002        VARCHAR2(4000) := 'Envio dos Lançamentos a B3';
    vr_dspro002_E      VARCHAR2(4000) := 'Iniciando Proc. Busca de Eventos para Criação de Registros e Operações a enviar.';
    vr_dscarque CONSTANT VARCHAR2(30) := chr(10)||chr(13);
    
    CURSOR cr_lctos(pr_cdcooper NUMBER
                   ,pr_dtmvtoan DATE
                   ,pr_dtmvtolt DATE
                   ,pr_dtinictd DATE
                   ,pr_vlminctd NUMBER) IS
      SELECT rda.rowid rowid_apl
            ,lap.rowid rowid_lct
            ,hst.tpaplicacao tpaplrdc
            ,lap.dtmvtolt
            ,lap.cdhistor
            ,lap.vllanmto
            ,hst.idtipo_arquivo
            ,hst.idtipo_lancto
            ,hst.cdoperacao_b3
            ,rda.nrdconta nrdconta
            ,rda.nraplica nraplica
            ,0            cdprodut
        FROM cecred.craplap lap
            ,cecred.craprda rda
            ,cecred.crapdtc dtc
            ,cecred.vw_capt_histor_operac hst
       WHERE rda.cdcooper = dtc.cdcooper
         AND rda.tpaplica = dtc.tpaplica
         AND lap.cdcooper = rda.cdcooper
         AND lap.nrdconta = rda.nrdconta
         AND lap.nraplica = rda.nraplica
         AND lap.cdcooper = pr_cdcooper  
         AND hst.idtipo_arquivo = 1
         AND hst.tpaplicacao = dtc.tpaplrdc
         AND hst.cdhistorico = lap.cdhistor
         AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
         AND lap.dtmvtolt < '10/02/2023'
         AND nvl(rda.idaplcus,0) = 0
         AND nvl(lap.idlctcus,0) = 0
         AND lap.vllanmto >= nvl(pr_vlminctd,0)
      UNION
      SELECT rac.rowid
            ,lac.rowid
            ,hst.tpaplicacao
            ,lac.dtmvtolt
            ,lac.cdhistor
            ,lac.vllanmto
            ,hst.idtipo_arquivo
            ,hst.idtipo_lancto
            ,hst.cdoperacao_b3
            ,rac.nrdconta nrdconta
            ,rac.nraplica nraplica
            ,rac.cdprodut cdprodut
        FROM cecred.craplac lac
            ,cecred.craprac rac
            ,cecred.vw_capt_histor_operac hst
       WHERE rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND lac.cdcooper = pr_cdcooper   
         AND hst.idtipo_arquivo = 1
         AND hst.tpaplicacao in(3,4)
         AND hst.cdprodut    = rac.cdprodut
         AND hst.cdhistorico = lac.cdhistor
         AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
         AND lac.dtmvtolt < '10/02/2023'
         AND nvl(rac.idaplcus,0) = 0
         AND nvl(lac.idlctcus,0) = 0
         AND lac.vllanmto >= nvl(pr_vlminctd,0);

    CURSOR cr_lctos_rgt(pr_cdcooper NUMBER
                       ,pr_dtmvtoan DATE
                       ,pr_dtmvtolt DATE
                       ,pr_dtinictd DATE) IS
      SELECT *
        FROM (SELECT rda.idaplcus
                    ,lap.rowid rowid_lct
                    ,hst.tpaplicacao tpaplrdc
                    ,lap.nrdconta
                    ,lap.nraplica
                    ,0 cdprodut
                    ,lap.dtmvtolt
                    ,lap.cdhistor
                    ,lap.vllanmto
                    ,hst.idtipo_arquivo
                    ,hst.idtipo_lancto
                    ,hst.cdoperacao_b3
                    ,capl.qtcotas
                    ,capl.vlpreco_registro
                    ,rda.dtmvtolt dtmvtapl
                    ,decode(capl.tpaplicacao,1,rda.qtdiaapl,rda.qtdiauti) qtdiacar
                    ,lap.progress_recid
                    ,lap.vlpvlrgt valorbase
                    ,hst.cdhistorico
                    ,rda.insaqtot idsaqtot
                    ,his.indebcre
                    ,capl.dscodigo_b3
                FROM cecred.craplap lap
                    ,cecred.craprda rda
                    ,cecred.crapdtc dtc
                    ,cecred.tbcapt_custodia_aplicacao capl
                    ,cecred.vw_capt_histor_operac hst
                    ,cecred.craphis his
               WHERE rda.cdcooper = dtc.cdcooper
                 AND rda.tpaplica = dtc.tpaplica
                 AND lap.cdcooper = rda.cdcooper
                 AND lap.nrdconta = rda.nrdconta  
                 AND lap.nraplica = rda.nraplica
                 AND lap.cdcooper = pr_cdcooper
                 AND rda.idaplcus = capl.idaplicacao
                 AND his.cdcooper = lap.cdcooper
                 AND his.cdhistor = lap.cdhistor
                 AND ( lap.dtmvtolt < rda.dtvencto)
                 AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                 AND lap.dtmvtolt < '10/02/2023'
                 AND hst.idtipo_arquivo = 2 
                 AND hst.tpaplicacao = dtc.tpaplrdc
                 AND hst.cdhistorico = lap.cdhistor
                 AND nvl(lap.idlctcus,0) = 0
                 AND nvl(rda.idaplcus,0) > 0
                 AND capl.dscodigo_b3 IS NOT NULL
              UNION
              SELECT rac.idaplcus
                    ,lac.rowid
                    ,hst.tpaplicacao
                    ,lac.nrdconta
                    ,lac.nraplica
                    ,rac.cdprodut
                    ,lac.dtmvtolt
                    ,lac.cdhistor
                    ,lac.vllanmto
                    ,hst.idtipo_arquivo
                    ,hst.idtipo_lancto
                    ,hst.cdoperacao_b3
                    ,capl.qtcotas
                    ,capl.vlpreco_registro
                    ,rac.dtmvtolt dtmvtapl
                    ,rac.qtdiacar
                    ,lac.progress_recid
                    ,lac.vlbasren valorbase
                    ,hst.cdhistorico
                    ,rac.idsaqtot
                    ,his.indebcre
                    ,capl.dscodigo_b3
                FROM cecred.craplac lac
                    ,cecred.craprac rac
                    ,cecred.tbcapt_custodia_aplicacao capl
                    ,cecred.vw_capt_histor_operac hst
                    ,cecred.craphis his
               WHERE rac.cdcooper = lac.cdcooper
                 AND rac.nrdconta = lac.nrdconta  
                 AND rac.nraplica = lac.nraplica
                 AND lac.cdcooper = pr_cdcooper
                 AND rac.idaplcus = capl.idaplicacao
                 AND his.cdcooper = lac.cdcooper
                 AND his.cdhistor = lac.cdhistor
                 AND ( lac.dtmvtolt < rac.dtvencto OR hst.idtipo_lancto = 3 )
                 AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                 AND lac.dtmvtolt < '10/02/2023'
                 AND hst.idtipo_arquivo = 2
                 AND hst.tpaplicacao IN(3,4)
                 AND hst.cdprodut    = rac.cdprodut
                 AND hst.cdhistorico = lac.cdhistor
                 AND nvl(lac.idlctcus,0) = 0
                 AND nvl(rac.idaplcus,0) > 0
                 AND capl.dscodigo_b3 IS NOT NULL) lct
       ORDER BY lct.dtmvtolt
               ,lct.nrdconta
               ,lct.nraplica
               ,lct.idtipo_lancto 
               ,lct.vllanmto desc;
                 
    rw_lcto_rgt cr_lctos_rgt%ROWTYPE; 

    CURSOR cr_resgat(pr_cdcooper cecred.crapcop.cdcooper%TYPE     
                    ,pr_nrdconta cecred.craprda.nrdconta%TYPE     
                    ,pr_nraplica cecred.craprda.nraplica%TYPE     
                    ,pr_tpaplrdc cecred.craprda.tpaplica%TYPE     
                    ,pr_dtmvtolt cecred.crapdat.dtmvtolt%TYPE) IS 
      SELECT sum(nvl(lct.vllanmto,0))
        FROM (SELECT lap.vllanmto
                FROM cecred.craplap lap
                    ,cecred.vw_capt_histor_operac hst
               WHERE lap.cdcooper = pr_cdcooper
                 AND lap.nrdconta = pr_nrdconta
                 AND lap.nraplica = pr_nraplica
                 AND lap.dtmvtolt = pr_dtmvtolt
                 AND hst.idtipo_arquivo = 2 
                 AND hst.tpaplicacao = pr_tpaplrdc
                 AND hst.cdhistorico = lap.cdhistor
                 AND hst.idtipo_lancto = 2
              UNION
              SELECT lac.vllanmto
                FROM cecred.craplac lac
                    ,cecred.vw_capt_histor_operac hst
               WHERE lac.cdcooper = pr_cdcooper
                 AND lac.nrdconta = pr_nrdconta
                 AND lac.nraplica = pr_nraplica
                 AND lac.dtmvtolt = pr_dtmvtolt
                 AND hst.idtipo_arquivo = 2 
                 AND hst.tpaplicacao = pr_tpaplrdc
                 AND hst.cdhistorico = lac.cdhistor
                 AND hst.idtipo_lancto = 2 
               ) lct;

    CURSOR cr_craplap(pr_cdcooper cecred.crapcop.cdcooper%TYPE     
                     ,pr_nrdconta cecred.craprda.nrdconta%TYPE     
                     ,pr_nraplica cecred.craprda.nraplica%TYPE     
                     ,pr_dtmvtolt cecred.crapdat.dtmvtolt%TYPE) IS 
     SELECT 1 tem
       FROM cecred.craplap lap
      WHERE lap.cdcooper = pr_cdcooper
        AND lap.nrdconta = pr_nrdconta
        AND lap.nraplica = pr_nraplica
        AND lap.dtmvtolt > pr_dtmvtolt;
    rw_craplap cr_craplap%ROWTYPE;
          
    CURSOR cr_craplac(pr_cdcooper cecred.crapcop.cdcooper%TYPE     
                     ,pr_nrdconta cecred.craprac.nrdconta%TYPE     
                     ,pr_nraplica cecred.craprac.nraplica%TYPE     
                     ,pr_dtmvtolt cecred.crapdat.dtmvtolt%TYPE) IS 
     SELECT 1 tem
       FROM cecred.craplac lac
      WHERE lac.cdcooper = pr_cdcooper
        AND lac.nrdconta = pr_nrdconta
        AND lac.nraplica = pr_nraplica
        AND lac.dtmvtolt > pr_dtmvtolt;

    rw_craplac cr_craplac%ROWTYPE; 
    
    TYPE typ_tab_reg_lanctos IS
      TABLE OF cr_lctos_rgt%ROWTYPE
      INDEX BY PLS_INTEGER;
                
    TYPE typ_reg_aplicacao IS
      TABLE OF typ_tab_reg_lanctos
      INDEX BY VARCHAR(028);
    
    TYPE typ_reg_ultimo_rgt IS
      TABLE OF PLS_INTEGER
      INDEX BY VARCHAR(028);
        
    vr_tab_reg_aplicacao  typ_reg_aplicacao;
    vr_tab_reg_ultimo_rgt typ_reg_ultimo_rgt;
    vr_idx_aplic         VARCHAR(028);
    vr_idx               pls_integer;
    vr_tipo_lancto       cecred.tbcapt_custodia_lanctos.idtipo_lancto%TYPE;
    vr_aplicacao         cecred.tbcapt_custodia_aplicacao.idaplicacao%TYPE;
                   
    vr_qtcotas      cecred.tbcapt_custodia_aplicacao.qtcotas%TYPE;

    vr_idaplicacao  cecred.tbcapt_custodia_aplicacao.idaplicacao%TYPE;
    vr_idlancamento cecred.tbcapt_custodia_lanctos.idlancamento%TYPE;

    vr_dtmvtolt       DATE;
    vr_dtmvtolt_dat   DATE;
    vr_dtmvtoan_dat   DATE;
    vr_dtmvtoan_2_dat DATE;
    vr_nrdconta       cecred.craprda.nrdconta%TYPE;
    vr_nraplica       cecred.craprda.nraplica%TYPE;

    vr_sldaplic     cecred.craprda.vlsdrdca%TYPE;
    vr_vlpreco_unit NUMBER(38,30);
    vr_qtcotas_resg cecred.tbcapt_custodia_aplicacao.qtcotas%TYPE;

    vr_qtregrgt NUMBER := 0;
    vr_qtregreg NUMBER := 0;


   TYPE typ_reg_tbcapt_custodia_aplicacao_det IS
   RECORD (idaplicacao cecred.tbcapt_custodia_aplicacao.idaplicacao%TYPE
          ,tpaplicacao cecred.tbcapt_custodia_aplicacao.tpaplicacao%TYPE
          ,vlregistro  cecred.tbcapt_custodia_aplicacao.vlregistro%TYPE
          ,qtcotas     cecred.tbcapt_custodia_aplicacao.qtcotas%TYPE
          ,vlpreco_registro cecred.tbcapt_custodia_aplicacao.vlpreco_registro%TYPE
          ,vlpreco_unitario cecred.tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE
          ,vr_rowid VARCHAR2(30));

     
   TYPE typ_tab_tbcapt_custodia_aplicacao_det IS
     TABLE OF typ_reg_tbcapt_custodia_aplicacao_det
     INDEX BY PLS_INTEGER;
           
   TYPE typ_reg_tbcapt_custodia_lanctos_det IS
   RECORD (idlancamento     cecred.tbcapt_custodia_lanctos.idlancamento%TYPE
          ,idaplicacao      cecred.tbcapt_custodia_lanctos.idaplicacao%TYPE
          ,idtipo_arquivo   cecred.tbcapt_custodia_lanctos.idtipo_arquivo%TYPE
          ,idtipo_lancto    cecred.tbcapt_custodia_lanctos.idtipo_lancto%TYPE
          ,cdhistorico      cecred.tbcapt_custodia_lanctos.cdhistorico%TYPE
          ,cdoperacao_b3    cecred.tbcapt_custodia_lanctos.cdoperacao_b3%TYPE
          ,vlregistro       cecred.tbcapt_custodia_lanctos.vlregistro%TYPE
          ,qtcotas          cecred.tbcapt_custodia_lanctos.qtcotas%TYPE    
          ,vlpreco_unitario cecred.tbcapt_custodia_lanctos.vlpreco_unitario%TYPE 
          ,idsituacao       cecred.tbcapt_custodia_lanctos.idsituacao%TYPE 
          ,dtregistro       cecred.tbcapt_custodia_lanctos.dtregistro%TYPE                                
          ,vr_rowid VARCHAR2(30));

   TYPE typ_tab_tbcapt_custodia_lanctos_det IS
     TABLE OF typ_reg_tbcapt_custodia_lanctos_det
     INDEX BY PLS_INTEGER;       

  TYPE typ_tab_produt_ipca IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER; 
    vr_tab_produto_ipca typ_tab_produt_ipca;
  
  TYPE typ_rec_craprac IS RECORD(idaplcus   cecred.craprac.idaplcus%TYPE
                              ,vr_rowid VARCHAR2(30));    
  TYPE typ_tab_craprac IS TABLE OF typ_rec_craprac INDEX BY PLS_INTEGER; 
  vr_tab_craprac typ_tab_craprac;
    
  
  TYPE typ_rec_craplac IS RECORD(idlctcus   cecred.craplac.idlctcus%TYPE
                              ,vr_rowid VARCHAR2(30));    
  TYPE typ_tab_craplac IS TABLE OF typ_rec_craplac INDEX BY PLS_INTEGER; 
  vr_tab_craplac typ_tab_craplac;
  

  TYPE typ_rec_craprda IS RECORD(idaplcus   cecred.craprda.idaplcus%TYPE
                              ,vr_rowid VARCHAR2(30));    
  TYPE typ_tab_craprda IS TABLE OF typ_rec_craprda INDEX BY PLS_INTEGER; 
  vr_tab_craprda typ_tab_craprda;  
  

  TYPE typ_rec_craplap IS RECORD(idlctcus   cecred.craplap.idlctcus%TYPE
                              ,vr_rowid VARCHAR2(30));    
  TYPE typ_tab_craplap IS TABLE OF typ_rec_craplap INDEX BY PLS_INTEGER; 
  vr_tab_craplap typ_tab_craplap; 
            
 vr_tab_tbcapt_custodia_aplicacao  typ_tab_tbcapt_custodia_aplicacao_det;
 vr_tab_tbcapt_custodia_lanctos    typ_tab_tbcapt_custodia_lanctos_det;

  FUNCTION fn_get_time_char RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(sysdate,'DD/MM/RRRR hh24:mi:ss - ');
  END;

  PROCEDURE pc_carrega_produtos_diferen
  IS
    CURSOR cr_crapcpc IS
     SELECT cpc.cdprodut      
       FROM cecred.crapcpc cpc
      WHERE cpc.indanive = 1;
  BEGIN
    FOR rw_crapcpc IN cr_crapcpc LOOP
      vr_tab_produto_ipca(rw_crapcpc.cdprodut) := 0;
    END LOOP;    
  END pc_carrega_produtos_diferen;

  PROCEDURE pc_finaliza
    IS 
  BEGIN
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := cecred.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                         ' ' || vr_dssqlerrm ||
                         ' ' || vr_nmaction  ||
                         ' ' || vr_nmproint1 ||
                         ' ' || vr_dsparlp1  ||
                         ' ' || vr_dsparlp2  ||
                         ' ' || vr_dsparlp3  ||
                         ' ' || vr_dsparesp;   
                         
      dbms_output.put_line(vr_dscritic);
      
      cecred.apli0007.pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic
            ,pr_cdcricid => vr_idcritic);          
      ROLLBACK; 
  END pc_finaliza;

  PROCEDURE pc_critica_loop
    IS 
  BEGIN 
          vr_cdcritic := NVL(vr_cdcritic,0);
          vr_dscritic := cecred.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic) ||
                         ' ' || vr_dssqlerrm ||
                         ' ' || vr_nmaction  ||
                         ' ' || vr_nmproint1 ||
                         ' ' || vr_dsparlp1  ||
                         ' ' || vr_dsparlp2  ||
                         ' ' || vr_dsparlp3  ||
                         ' ' || vr_dsparesp;  
          dbms_output.put_line(vr_dscritic);                    

          cecred.apli0007.pc_log(pr_cdcritic => vr_cdcritic
                ,pr_dscrilog => vr_dscritic
                ,pr_cdcricid => vr_idcritic); 
  END pc_critica_loop;
 
 FUNCTION fn_converte_valor_em_cota(pr_vllancto IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN nvl(pr_vllancto,0) / vr_qtftcota;
 END;
 
 FUNCTION fn_eh_pcapta(pr_tpaplica IN cecred.tbcapt_custodia_aplicacao.tpaplicacao%TYPE) RETURN BOOLEAN IS
  BEGIN
     IF pr_tpaplica IN(3,4) THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
  END;
 
 FUNCTION fn_busca_qtcotas_atualizado(pr_idaplicacao cecred.tbcapt_custodia_aplicacao.idaplicacao%TYPE) RETURN cecred.tbcapt_custodia_aplicacao.qtcotas%TYPE IS

   CURSOR cr_tbcapt_custodia_aplicacao(pr_idaplicacao cecred.tbcapt_custodia_aplicacao.idaplicacao%TYPE) IS
   SELECT tbcapt_custodia_aplicacao.qtcotas
     FROM cecred.tbcapt_custodia_aplicacao
    WHERE tbcapt_custodia_aplicacao.idaplicacao = pr_idaplicacao;
      
  vr_qtcotas cecred.tbcapt_custodia_aplicacao.qtcotas%TYPE;
    
 BEGIN
   OPEN cr_tbcapt_custodia_aplicacao(pr_idaplicacao => pr_idaplicacao);
   FETCH cr_tbcapt_custodia_aplicacao INTO vr_qtcotas;
   CLOSE cr_tbcapt_custodia_aplicacao;
   RETURN nvl(vr_qtcotas,0);
 END;
 
   FUNCTION fn_valida_histor_rendim(pr_tpaplica IN NUMBER
                                  ,pr_cdprodut IN NUMBER
                                  ,pr_cdhistor IN NUMBER) RETURN BOOLEAN IS

    CURSOR cr_hiscapt IS
      SELECT 1
        FROM cecred.crapcpc cpc
       WHERE cpc.cdprodut = pr_cdprodut
         AND pr_cdhistor in(cpc.cdhsprap,cpc.cdhsrdap);
    vr_id_exist NUMBER := 0;
  BEGIN
    IF pr_tpaplica IN(3,4) THEN

      OPEN cr_hiscapt;
      FETCH cr_hiscapt
       INTO vr_id_exist;
      CLOSE cr_hiscapt;

      IF vr_id_exist = 1 THEN
        RETURN TRUE;
      END IF;
    ELSE
      IF pr_cdhistor IN(474,475,529,532,3096,3098,3104,3106) THEN 
         RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  END;
 
 PROCEDURE pc_busca_saldo_anterior(pr_cdcooper  IN cecred.craprda.cdcooper%TYPE                  
                                   ,pr_nrdconta  IN cecred.craprda.nrdconta%TYPE                 
                                   ,pr_nraplica  IN cecred.craprda.nraplica%TYPE                 
                                   ,pr_tpaplica  IN cecred.crapdtc.tpaplica%TYPE                 
                                   ,pr_cdprodut  IN cecred.craprac.cdprodut%TYPE                 
                                   ,pr_dtmvtolt  IN cecred.craprda.dtmvtolt%TYPE                 
                                   ,pr_dtmvtsld  IN cecred.craprda.dtmvtolt%TYPE                 
                                   ,pr_tpconsul  IN VARCHAR2                              
                                   ,pr_sldaplic OUT cecred.craprda.vlsdrdca%TYPE                 
                                   ,pr_idcritic OUT NUMBER                                
                                   ,pr_dssqlerr OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER                                
                                   ,pr_dscritic OUT VARCHAR2) IS                          
  BEGIN
    DECLARE
      vr_tbsaldo_rdca     cecred.APLI0001.typ_tab_saldo_rdca;
      vr_tab_extrato_rdca cecred.APLI0002.typ_tab_extrato_rdca;
      vr_tab_extrato      cecred.apli0005.typ_tab_extrato;
      vr_tab_erro  cecred.gene0001.typ_tab_erro;
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_txacumul NUMBER;                  
      vr_txacumes NUMBER;                  
      vr_percirrf NUMBER;
      vr_vlsldapl NUMBER;
      vr_dtmvtsld cecred.crapdat.dtmvtolt%TYPE := pr_dtmvtsld;
      vr_cdagenci cecred.crapage.cdagenci%TYPE := 1;
      vr_index_extrato_rdca PLS_INTEGER;
      vr_nmproint1               VARCHAR2 (100) := 'pc_busca_saldo_anterior';
      vr_des_reto                VARCHAR2 (100);
      vr_exc_saida_bus_sal_ant_1 EXCEPTION;
      
    BEGIN
      
      pr_sldaplic := 0;
      vr_tbsaldo_rdca.DELETE();

      IF pr_tpaplica > 2 THEN
        cecred.APLI0008.pc_lista_aplicacoes_progr(pr_cdcooper   => pr_cdcooper   
                                    ,pr_cdoperad   => '1'                 
                                    ,pr_nmdatela   => 'CUSAPL'            
                                    ,pr_idorigem   => 5                   
                                    ,pr_nrdcaixa   => 1                   
                                    ,pr_nrdconta   => pr_nrdconta         
                                    ,pr_idseqttl   => 1                   
                                    ,pr_cdagenci   => 1                   
                                    ,pr_cdprogra   => 'CUSAPL'            
                                    ,pr_nraplica   => pr_nraplica         
                                    ,pr_cdprodut   => pr_cdprodut         
                                    ,pr_dtmvtolt   => pr_dtmvtolt         
                                    ,pr_idconsul   => 5                   
                                    ,pr_idgerlog   => 0                   
                                    ,pr_tpaplica   => 2                   
                                    ,pr_cdcritic   => vr_cdcritic         
                                    ,pr_dscritic   => vr_dscritic         
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca);   

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida_bus_sal_ant_1;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;
          RAISE vr_exc_saida_bus_sal_ant_1;
        END IF;
      ELSE
        cecred.APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   
                                       ,pr_cdagenci   => 1             
                                       ,pr_nrdcaixa   => 1             
                                       ,pr_nrdconta   => pr_nrdconta   
                                       ,pr_nraplica   => pr_nraplica   
                                       ,pr_tpaplica   => 0             
                                       ,pr_dtinicio   => pr_dtmvtsld   
                                       ,pr_dtfim      => pr_dtmvtolt   
                                       ,pr_cdprogra   => 'CUSAPL'      
                                       ,pr_nrorigem   => 5             
                                       ,pr_saldo_rdca => vr_tbsaldo_rdca 
                                       ,pr_des_reto   => vr_des_reto   
                                       ,pr_tab_erro   => vr_tab_erro); 
        IF vr_des_reto = 'NOK' THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida_bus_sal_ant_1;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;
          RAISE vr_exc_saida_bus_sal_ant_1;
        END IF;
      END IF;
      
      cecred.GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

      IF vr_tbsaldo_rdca.exists(vr_tbsaldo_rdca.FIRST) THEN
        pr_sldaplic := vr_tbsaldo_rdca(vr_tbsaldo_rdca.FIRST).VLSDRDAD;
      ELSE
        pr_sldaplic := 0;
      END IF;

      IF pr_tpconsul = 'R' AND pr_dtmvtsld IS NOT NULL THEN
        FOR vr_idx IN vr_tbsaldo_rdca.FIRST..vr_tbsaldo_rdca.LAST LOOP
          IF vr_tbsaldo_rdca.exists(vr_idx) THEN
            vr_tab_extrato_rdca.DELETE;
            IF vr_tbsaldo_rdca(vr_idx).idtipapl = 'N' THEN
              cecred.APLI0005.pc_busca_extrato_aplicacao(pr_cdcooper => pr_cdcooper       
                                                 ,pr_cdoperad => '1'               
                                                 ,pr_nmdatela => 'EXTRDA'          
                                                 ,pr_idorigem => 5                 
                                                 ,pr_nrdconta => pr_nrdconta       
                                                 ,pr_idseqttl => 1                 
                                                 ,pr_dtmvtolt => pr_dtmvtolt       
                                                 ,pr_nraplica => vr_tbsaldo_rdca(vr_idx).nraplica  
                                                 ,pr_idlstdhs => 1                
                                                 ,pr_idgerlog => 0                
                                                 ,pr_tab_extrato => vr_tab_extrato
                                                 ,pr_vlresgat => vr_vlresgat      
                                                 ,pr_vlrendim => vr_vlrendim      
                                                 ,pr_vldoirrf => vr_vldoirrf      
                                                 ,pr_txacumul => vr_txacumul      
                                                 ,pr_txacumes => vr_txacumes      
                                                 ,pr_percirrf => vr_percirrf      
                                                 ,pr_cdcritic => vr_cdcritic      
                                                 ,pr_dscritic => vr_dscritic);    

              IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida_bus_sal_ant_1;
              ELSE
                cecred.GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

                IF vr_tab_extrato.COUNT > 0 THEN
                  FOR vr_contador IN vr_tab_extrato.FIRST..vr_tab_extrato.LAST LOOP
                    vr_index_extrato_rdca:= vr_tab_extrato_rdca.COUNT + 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt := vr_tab_extrato(vr_contador).DTMVTOLT;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dshistor := vr_tab_extrato(vr_contador).DSHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).nrdocmto := vr_tab_extrato(vr_contador).NRDOCMTO;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).indebcre := vr_tab_extrato(vr_contador).INDEBCRE;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vllanmto := NVL(vr_tab_extrato(vr_contador).VLLANMTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl := NVL(vr_tab_extrato(vr_contador).VLSLDTOT,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).txaplica := NVL(vr_tab_extrato(vr_contador).TXLANCTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsaplica := vr_tbsaldo_rdca(vr_idx).DSAPLICA;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdagenci := vr_cdagenci;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlpvlrgt := vr_vlresgat;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor := vr_tab_extrato(vr_contador).CDHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).tpaplrdc := 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsextrat := vr_tab_extrato(vr_contador).DSEXTRAT;
                  END LOOP;
                END IF;
              END IF;
              IF vr_tab_produto_ipca.exists(pr_cdprodut) THEN
                vr_dtmvtsld := vr_dtmvtsld - 1;
              END IF;
            ELSE
              cecred.APLI0002.pc_consulta_extrato_rdca (pr_cdcooper    => pr_cdcooper      
                                                ,pr_cdageope    => 1                
                                                ,pr_nrcxaope    => 1                
                                                ,pr_cdoperad    => '1'              
                                                ,pr_nmdatela    => 'IMPRES'         
                                                ,pr_nrdconta    => pr_nrdconta      
                                                ,pr_idseqttl    => 1                
                                                ,pr_dtmvtolt    => pr_dtmvtolt      
                                                ,pr_nraplica    => vr_tbsaldo_rdca(vr_idx).nraplica
                                                ,pr_tpaplica    => 0                
                                                ,pr_vlsdrdca    => vr_vlsldapl      
                                                ,pr_dtiniper    => NULL             
                                                ,pr_dtfimper    => NULL             
                                                ,pr_cdprogra    => 'IMPRES'         
                                                ,pr_idorigem    => 5                
                                                ,pr_flgerlog    => FALSE            
                                                ,pr_tab_extrato_rdca => vr_tab_extrato_rdca 
                                                ,pr_des_reto     => vr_des_reto        
                                                ,pr_tab_erro     => vr_tab_erro);      
              IF vr_des_reto = 'NOK' THEN
                IF vr_tab_erro.COUNT > 0 THEN
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  vr_cdcritic:= 1494;
                END IF;
                RAISE vr_exc_saida_bus_sal_ant_1;
              END IF;
              cecred.GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

            END IF;

            vr_index_extrato_rdca:= vr_tab_extrato_rdca.FIRST;
            WHILE vr_index_extrato_rdca IS NOT NULL LOOP
              IF vr_index_extrato_rdca = vr_tab_extrato_rdca.last
              OR vr_tab_extrato_rdca(vr_tab_extrato_rdca.next(vr_index_extrato_rdca)).dtmvtolt > vr_dtmvtsld
              OR (vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt = vr_dtmvtsld AND fn_valida_histor_rendim(pr_tpaplica,pr_cdprodut,vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor)) THEN
                pr_sldaplic := vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl;
                vr_index_extrato_rdca := vr_tab_extrato_rdca.last;
              END IF;
              vr_index_extrato_rdca:= vr_tab_extrato_rdca.NEXT(vr_index_extrato_rdca);
            END LOOP;
          END IF;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida_bus_sal_ant_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := ' ' || vr_nmproint1 ||
                       ' ' || vr_dscritic;
        pr_idcritic := 1; 
        pr_dssqlerr := NULL; 
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;  
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        vr_cdcritic := 9999;
        vr_dscritic := ' ' || vr_nmproint1; 
        pr_dssqlerr := SQLERRM;
        pr_idcritic := 2; 
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;    
        vr_cdcritic := NULL;
        vr_dscritic := NULL;

    END;
  END;
      
  BEGIN 
      
    vr_dsparlp1  := NULL;
    vr_dsparlp2  := NULL;   
    vr_dsparlp3  := NULL;
    vr_dsparesp  := NULL;
    vr_dssqlerrm := NULL;      
    vr_cdcritic  := NULL;
    vr_dscritic  := NULL;
                
    vr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro002_E;
    vr_qtlimerr := cecred.gene0001.fn_param_sistema('CRED',0,'LIMERRO_ENV_REG_CTD_B3');
    vr_flenvreg := cecred.gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3');
    vr_flenvrgt := cecred.gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3');
      
    pc_carrega_produtos_diferen;
    
    vr_qtlimerr := NVL(vr_qtlimerr,0);         
    cecred.apli0007.pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                          ' Inicio ' || vr_nmaction  ||
                          ' ' || vr_nmproint1 ||
                          ', vr_qtlimerr:'    || vr_qtlimerr
          ,pr_dstiplog => 'O' 
          ,pr_tpocorre => 4   
          ,pr_cdcricid => 0   
          ); 
    
    vr_dtmvto2a := to_date('06/02/2023');
    
    FOR rw_cop IN cr_crapcop LOOP
    BEGIN
          
      vr_dsparlp1  := ', cdcooper ' || rw_cop.cdcooper;
      vr_dsparlp2  := NULL;   
      vr_dsparlp3  := NULL;
      vr_dsparesp  := NULL;
      vr_dssqlerrm := NULL;                
      
      OPEN cecred.BTCH0001.cr_crapdat(pr_cdcooper => rw_cop.cdcooper);
        FETCH cecred.BTCH0001.cr_crapdat INTO rw_crapdat;
        IF cecred.BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE cecred.BTCH0001.cr_crapdat;
          vr_cdcritic := 1;
          vr_idcritic := 1; -- Media    
          RAISE vr_exc_sai_LanArq_LopCop_1;
        ELSE
          CLOSE cecred.BTCH0001.cr_crapdat;
        END IF;
        
      vr_dtmvtolt_dat := rw_crapdat.dtmvtolt;
      
      vr_dtinictd := to_date(cecred.gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'INIC_CUSTODIA_APLICA_B3'),'dd/mm/rrrr');
      vr_vlinictd := to_number(cecred.gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'VLMIN_CUSTOD_APLICA_B3'),'FM999999990D00');
      cecred.GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
        
      IF vr_flenvreg = 'S' THEN
        vr_tab_craprac.delete();          
        vr_tab_craplac.delete();
        vr_tab_craprda.delete();          
        vr_tab_craplap.delete();          
        vr_tab_tbcapt_custodia_lanctos.delete();
        vr_tab_tbcapt_custodia_aplicacao.delete();

        FOR rw_lcto IN cr_lctos(rw_cop.cdcooper,vr_dtmvto2a,vr_dtmvtolt_dat,vr_dtinictd,vr_vlinictd) LOOP
        BEGIN
          vr_qtregreg := vr_qtregreg + 1;
          vr_dsparlp2 :=  ',L2A rw_lcto, cdhistor:'   || rw_lcto.cdhistor       ||
                          ', pr_nrdconta:'    || rw_lcto.nrdconta       ||
                          ', pr_nraplica:'    || rw_lcto.nraplica       ||
                          ', pr_tpaplica:'    || rw_lcto.tpaplrdc       ||
                          ', pr_cdprodut:'    || rw_lcto.cdprodut       ||
                          ', cdoperacao_b3:'  || rw_lcto.cdoperacao_b3  ||
                          ', idtipo_arquivo:' || rw_lcto.idtipo_arquivo ||
                          ', idtipo_lancto:'  || rw_lcto.idtipo_lancto  ||
                          ', cdhistor:'       || rw_lcto.cdhistor       ||
                          ', dtmvtolt:'       || rw_lcto.dtmvtolt       ||
                          ', vllanmto:'       || rw_lcto.vllanmto       ||
                          ', vr_qtregreg:'    || vr_qtregreg;
          vr_dsparlp3  := NULL;
          vr_dsparesp  := NULL;
          vr_dssqlerrm := NULL;
                
          vr_qtcotas := fn_converte_valor_em_cota(rw_lcto.vllanmto);
            
          select cecred.tbcapt_custodia_aplicacao_seq.nextval into vr_idaplicacao from dual;
    
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).idaplicacao          := vr_idaplicacao;
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).tpaplicacao          := rw_lcto.tpaplrdc;
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).vlregistro           := rw_lcto.vllanmto;
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).qtcotas              := vr_qtcotas;
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).vlpreco_registro     := vr_qtftcota;           
            vr_tab_tbcapt_custodia_aplicacao(vr_idaplicacao).vlpreco_unitario     := vr_qtftcota;  
                                     

            select cecred.tbcapt_custodia_lanctos_seq.nextval into vr_idlancamento from dual;
                             
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idlancamento      := vr_idlancamento;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idaplicacao       := vr_idaplicacao;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idtipo_arquivo    := rw_lcto.idtipo_arquivo;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idtipo_lancto     := rw_lcto.idtipo_lancto;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).cdhistorico       := rw_lcto.cdhistor;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).cdoperacao_b3     := rw_lcto.cdoperacao_b3;                                         
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).vlregistro        := rw_lcto.vllanmto;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).qtcotas           := vr_qtcotas;
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).vlpreco_unitario  := vr_qtftcota;                                
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idsituacao        := 0; 
            vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).dtregistro        := rw_lcto.dtmvtolt; 


        IF rw_lcto.tpaplrdc IN(3,4) THEN
             vr_tab_craprac(vr_idaplicacao).idaplcus     := vr_idaplicacao;
             vr_tab_craprac(vr_idaplicacao).vr_rowid     := rw_lcto.rowid_apl;
            vr_tab_craplac(vr_idaplicacao).idlctcus     := vr_idlancamento;
            vr_tab_craplac(vr_idaplicacao).vr_rowid     := rw_lcto.rowid_lct;
         ELSE   
            vr_tab_craprda(vr_idaplicacao).idaplcus     := vr_idaplicacao;
            vr_tab_craprda(vr_idaplicacao).vr_rowid     := rw_lcto.rowid_apl;
            vr_tab_craplap(vr_idaplicacao).idlctcus     := vr_idlancamento;   
            vr_tab_craplap(vr_idaplicacao).vr_rowid     := rw_lcto.rowid_lct;  
         END IF;

        EXCEPTION
          WHEN vr_exc_sai_LanArq_LopLct_2_A THEN
            pc_critica_loop;         
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_sai_LanArq_LopCop_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;        
            END IF;  
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => 3);
            vr_cdcritic  := 9999;
            vr_dssqlerrm := SQLERRM;
            vr_idcritic  := 2;
            pc_critica_loop;                  
            IF vr_ctcritic > vr_qtlimerr THEN
              RAISE vr_exc_sai_LanArq_LopCop_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;        
            END IF;
        END;          
        END LOOP;
      END IF;
        
      BEGIN
        FORALL idx IN INDICES OF vr_tab_tbcapt_custodia_aplicacao SAVE EXCEPTIONS
          INSERT INTO cecred.TBCAPT_CUSTODIA_APLICACAO
                 (idaplicacao
                 ,tpaplicacao
                 ,vlregistro
                 ,qtcotas
                 ,vlpreco_registro
                 ,vlpreco_unitario)
          VALUES (vr_tab_tbcapt_custodia_aplicacao(idx).idaplicacao
                 ,vr_tab_tbcapt_custodia_aplicacao(idx).tpaplicacao
                 ,vr_tab_tbcapt_custodia_aplicacao(idx).vlregistro
                 ,vr_tab_tbcapt_custodia_aplicacao(idx).qtcotas
                 ,vr_tab_tbcapt_custodia_aplicacao(idx).vlpreco_registro
                 ,vr_tab_tbcapt_custodia_aplicacao(idx).vlpreco_unitario);       
      EXCEPTION
        WHEN OTHERS THEN

           FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               CECRED.pc_internal_exception(pr_cdcooper => 3);
               vr_cdcritic  := 1034;                 
               vr_dssqlerrm := SQLERRM;
               vr_idcritic  := 2;
               vr_dsparesp  := ', tabela: tbcapt_custodia_aplicacao' ||
                               ', qtcotas: '          || vr_tab_tbcapt_custodia_aplicacao(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).qtcotas ||
                               ', vlpreco_registro: ' || vr_tab_tbcapt_custodia_aplicacao(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlpreco_registro  ||
                               ', vlpreco_unitario: ' || vr_tab_tbcapt_custodia_aplicacao(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlpreco_unitario ;
                   RAISE vr_exc_sai_LanArq_LopLct_2_A;
                                                                                
           END LOOP;
      END;
               
      BEGIN
        FORALL idx IN INDICES OF vr_tab_tbcapt_custodia_lanctos SAVE EXCEPTIONS
          INSERT INTO cecred.TBCAPT_CUSTODIA_LANCTOS
                (idlancamento
                ,idaplicacao
                ,idtipo_arquivo
                ,idtipo_lancto
                ,cdhistorico
                ,cdoperacao_b3
                ,vlregistro
                ,qtcotas
                ,vlpreco_unitario
                ,idsituacao
                ,dtregistro)
          VALUES (vr_tab_tbcapt_custodia_lanctos(idx).idlancamento
                 ,vr_tab_tbcapt_custodia_lanctos(idx).idaplicacao 
                 ,vr_tab_tbcapt_custodia_lanctos(idx).idtipo_arquivo
                 ,vr_tab_tbcapt_custodia_lanctos(idx).idtipo_lancto
                 ,vr_tab_tbcapt_custodia_lanctos(idx).cdhistorico
                 ,vr_tab_tbcapt_custodia_lanctos(idx).cdoperacao_b3
                 ,vr_tab_tbcapt_custodia_lanctos(idx).vlregistro
                 ,vr_tab_tbcapt_custodia_lanctos(idx).qtcotas
                 ,vr_tab_tbcapt_custodia_lanctos(idx).vlpreco_unitario
                 ,0
                 ,vr_tab_tbcapt_custodia_lanctos(idx).dtregistro);      
      EXCEPTION
        WHEN OTHERS THEN

           FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               CECRED.pc_internal_exception(pr_cdcooper => 3);
               vr_cdcritic  := 1034;                 
               vr_dssqlerrm := SQLERRM;
               vr_idcritic  := 2;
               vr_dsparesp  := ', tabela: TBCAPT_CUSTODIA_LANCTOS' ||
                               ', idaplicacao: ' || vr_tab_tbcapt_custodia_lanctos(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idaplicacao ||
                               ', qtcotas:     ' || vr_tab_tbcapt_custodia_lanctos(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).qtcotas  ||
                               ', vlpreco_unitario: ' || vr_tab_tbcapt_custodia_lanctos(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlpreco_unitario ||
                               ', idsituacao: 0';
                   RAISE vr_exc_sai_LanArq_LopLct_2_A;
                                                                                
           END LOOP;                                   
      END;               

      BEGIN
               
        FORALL idx IN INDICES OF vr_tab_craprac SAVE EXCEPTIONS
            UPDATE cecred.craprac
               SET idaplcus = vr_tab_craprac(idx).idaplcus 
             WHERE ROWID    = vr_tab_craprac(idx).vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
           FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                vr_cdcritic  := 1035;                 
                vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                vr_idcritic  := 2;
                vr_dsparesp  := ', tabela: craprac'     ||
                                ', idaplcus:' || vr_tab_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idaplcus ||
                                ', ROWID:'    || vr_tab_craprac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
             RAISE vr_exc_sai_LanArq_LopLct_2_A;                    
           END LOOP;
      END;
        
      BEGIN
               
        FORALL idx IN INDICES OF vr_tab_craplac SAVE EXCEPTIONS                
          UPDATE cecred.craplac
             SET idlctcus = vr_tab_craplac(idx).idlctcus
           WHERE ROWID    = vr_tab_craplac(idx).vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
           FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                vr_cdcritic  := 1035;                 
                vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                vr_idcritic  := 2;
                vr_dsparesp  := ', tabela: craplac'     ||
                                ', idaplcus:' || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idlctcus ||
                                ', ROWID:'    || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
             RAISE vr_exc_sai_LanArq_LopLct_2_A;                    
           END LOOP;                  
      END;
         
      BEGIN    
              
        FORALL idx IN INDICES OF vr_tab_craprda SAVE EXCEPTIONS 
            UPDATE cecred.craprda
               SET idaplcus =  vr_tab_craprda(idx).idaplcus
             WHERE ROWID    =  vr_tab_craprda(idx).vr_rowid;
          EXCEPTION
            WHEN OTHERS THEN
             FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                  vr_idcritic  := 2; 
                  vr_dsparesp  := ', tabela: craprda'     ||
                                  ', idaplcus:' || vr_tab_craprda(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idaplcus ||
                                  ', ROWID:'    || vr_tab_craprda(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
               RAISE vr_exc_sai_LanArq_LopLct_2_A;                    
             END LOOP;                     
      END;
          
      BEGIN
                
        FORALL idx IN INDICES OF vr_tab_craplap SAVE EXCEPTIONS  
          UPDATE cecred.craplap
             SET idlctcus = vr_tab_craplap(idx).idlctcus 
           WHERE ROWID    = vr_tab_craplap(idx).vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
           FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                vr_cdcritic  := 1035;                 
                vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                vr_idcritic  := 2;   
                vr_dsparesp  := ', tabela: craplap'     ||
                                ', idlctcus:' || vr_tab_craplap(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idlctcus ||
                                ', ROWID:'    || vr_tab_craplap(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
             RAISE vr_exc_sai_LanArq_LopLct_2_A;                    
           END LOOP;                   
      END;                       
        
      COMMIT;
               
      IF vr_flenvrgt = 'S' THEN
        vr_dtmvtolt := to_date('01011900','ddmmrrrr');
        vr_nrdconta := 0;
        vr_nraplica := 0;
        vr_qtcotas  := 0;
        vr_sldaplic := 0;          
          
        vr_idx_aplic   := '';
        vr_idx         := 0;
        vr_tipo_lancto := 0;
        vr_aplicacao   := 0;
        vr_tab_reg_aplicacao.delete();

        vr_tab_craprac.delete();          
        vr_tab_craplac.delete();
        vr_tab_craprda.delete();          
        vr_tab_craplap.delete();          
        vr_tab_tbcapt_custodia_lanctos.delete();
        vr_tab_tbcapt_custodia_aplicacao.delete();
          
        FOR rw_lcto IN cr_lctos_rgt(rw_cop.cdcooper,vr_dtmvto2a,vr_dtmvtolt_dat,vr_dtinictd) LOOP
        BEGIN

          vr_qtregrgt := vr_qtregrgt + 1;
              
          vr_dsparlp2 :=  ', cr_lctos_rgt, cdhistor:'   || rw_lcto.cdhistor       ||
                          ', pr_nrdconta:'    || rw_lcto.nrdconta       ||
                          ', pr_nraplica:'    || rw_lcto.nraplica       ||
                          ', pr_tpaplica:'    || rw_lcto.tpaplrdc       ||
                          ', pr_cdprodut:'    || rw_lcto.cdprodut       ||
                          ', cdoperacao_b3:'  || rw_lcto.cdoperacao_b3  ||
                          ', idtipo_arquivo:' || rw_lcto.idtipo_arquivo ||
                          ', idtipo_lancto:'  || rw_lcto.idtipo_lancto  ||
                          ', cdhistor:'       || rw_lcto.cdhistor       ||
                          ', dtmvtolt:'       || rw_lcto.dtmvtolt       ||
                          ', vllanmto:'       || rw_lcto.vllanmto       ||
                          ', vr_qtregrgt:'    || vr_qtregrgt;    
          vr_dsparlp3  := NULL;                                                                                            
          vr_dsparesp  := NULL;
          vr_dssqlerrm := NULL;          
                                         
           IF vr_aplicacao   <> rw_lcto.idaplcus or 
              vr_dtmvtolt    <> rw_lcto.dtmvtolt or 
              vr_tipo_lancto <> rw_lcto.idtipo_lancto THEN
              vr_idx := 0;
           END IF;
               
           vr_idx_aplic := lpad(rw_lcto.idaplcus,20,'0') || to_char(trunc(rw_lcto.dtmvtolt),'rrrrmmdd');
             
           IF rw_lcto.idtipo_lancto = 2 THEN
              vr_idx := vr_idx + 1;
              vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx) := rw_lcto;
              vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := rw_lcto.vllanmto;
              vr_tab_reg_ultimo_rgt(vr_idx_aplic) := vr_idx;
                      
           ELSIF rw_lcto.idtipo_lancto = 3 THEN
             vr_idx := vr_idx + 1;
             IF vr_tab_reg_aplicacao.exists(vr_idx_aplic) THEN
               IF vr_tab_reg_aplicacao(vr_idx_aplic).exists(vr_idx) THEN
                 vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase + rw_lcto.vllanmto;
               END IF;
             END IF;
           ELSIF rw_lcto.idtipo_lancto = 4 THEN
             vr_idx := vr_idx + 1;
             IF vr_tab_reg_aplicacao.exists(vr_idx_aplic) THEN
               IF vr_tab_reg_aplicacao(vr_idx_aplic).exists(vr_idx) THEN
                 IF rw_lcto.indebcre = 'D' THEN
                   rw_lcto.vllanmto := rw_lcto.vllanmto * -1;
                 END IF;
                 vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase - rw_lcto.vllanmto;
               END IF;
             END IF;
           END IF;             
           vr_aplicacao   := rw_lcto.idaplcus;
           vr_tipo_lancto := rw_lcto.idtipo_lancto;
           vr_dtmvtolt    := rw_lcto.dtmvtolt;

        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => 3);
            vr_cdcritic  := 9999;
            vr_dssqlerrm := SQLERRM;
            vr_idcritic  := 2; 
            pc_critica_loop;                  
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_sai_LanArq_LopCop_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            END IF;
        END;         
        END LOOP; 
          
        vr_idx_aplic:= vr_tab_reg_aplicacao.FIRST;
        WHILE vr_idx_aplic IS NOT NULL LOOP              
          BEGIN            
            vr_idx       := vr_tab_reg_aplicacao(vr_idx_aplic).FIRST;   
            vr_dsparlp2  := ', WHILE 01, vr_idx_aplic:' || vr_idx_aplic ||
                            ', vr_idx:'                 || vr_idx;       
            vr_dsparlp3  := NULL;
            vr_dsparesp  := NULL;
            vr_dssqlerrm := NULL;
            
            WHILE vr_idx IS NOT NULL LOOP            
              BEGIN
            
                rw_lcto_rgt  := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx); 
                vr_dsparlp3  := ', WHILE 01, vr_idx:' || vr_idx ||
                                ', dtmvtolt: '      || rw_lcto_rgt.dtmvtolt      ||
                                ', nrdconta: '      || rw_lcto_rgt.nrdconta      ||
                                ', nraplica: '      || rw_lcto_rgt.nraplica      ||
                                ', idtipo_lancto: ' || rw_lcto_rgt.idtipo_lancto ||
                                ', vllanmto: '         || rw_lcto_rgt.vllanmto   ||
                                ', vlpreco_registro: ' || rw_lcto_rgt.vlpreco_registro ||
                                ', idaplcus        : ' || rw_lcto_rgt.idaplcus         ||
                                ', tpaplrdc        : ' || rw_lcto_rgt.tpaplrdc         ||
                                ', cdprodut        : ' || rw_lcto_rgt.cdprodut         ||
                                ', cdhistor        : ' || rw_lcto_rgt.cdhistor         ||
                                ', idtipo_arquivo  : ' || rw_lcto_rgt.idtipo_arquivo   ||
                                ', cdoperacao_b3   : ' || rw_lcto_rgt.cdoperacao_b3    ||
                                ', qtcotas         : ' || rw_lcto_rgt.qtcotas          ||
                                ', dtmvtapl        : ' || rw_lcto_rgt.dtmvtapl         ||
                                ', qtdiacar        : ' || rw_lcto_rgt.qtdiacar         ||
                                ', progress_recid  : ' || rw_lcto_rgt.progress_recid   ||
                                ', valorbase       : ' || rw_lcto_rgt.valorbase        ||
                                ', cdhistorico     : ' || rw_lcto_rgt.cdhistorico;
                vr_dsparesp  := NULL;
                vr_dssqlerrm := NULL;
                
                IF vr_idx = 1 THEN

                  vr_qtcotas := rw_lcto_rgt.qtcotas;
                  IF cecred.apli0007.fn_tem_carencia(pr_dtmvtapl => rw_lcto_rgt.dtmvtapl
                                    ,pr_qtdiacar => rw_lcto_rgt.qtdiacar
                                    ,pr_dtmvtres => rw_lcto_rgt.dtmvtolt) = 'N' THEN
                    vr_sldaplic := 0;
                    pc_busca_saldo_anterior(pr_cdcooper  => rw_cop.cdcooper         
                                           ,pr_nrdconta  => rw_lcto_rgt.nrdconta    
                                           ,pr_nraplica  => rw_lcto_rgt.nraplica    
                                           ,pr_tpaplica  => rw_lcto_rgt.tpaplrdc    
                                           ,pr_cdprodut  => rw_lcto_rgt.cdprodut    
                                           ,pr_dtmvtolt  => vr_dtmvtolt_dat         
                                           ,pr_dtmvtsld  => rw_lcto_rgt.dtmvtolt    
                                           ,pr_tpconsul  => 'R'                     
                                           ,pr_sldaplic  => vr_sldaplic             
                                           ,pr_idcritic  => vr_idcritic             
                                           ,pr_dssqlerr  => vr_dssqlerrm
                                           ,pr_cdcritic  => vr_cdcritic             
                                           ,pr_dscritic  => vr_dsparesp);           
                    IF vr_dsparesp IS NOT NULL OR 
                       vr_cdcritic IS NOT NULL   THEN
                      vr_idcritic  := vr_idcritic;
                      RAISE vr_exc_sai_LanArqLopWh1Wh2_2C;
                    END IF;                                      
                    vr_dssqlerrm := NULL;
                    vr_cdcritic  := NULL;
                    vr_dsparesp  := NULL;
                    IF vr_sldaplic = 0 THEN
                      OPEN cr_resgat(pr_cdcooper  => rw_cop.cdcooper    
                                    ,pr_nrdconta  => rw_lcto_rgt.nrdconta
                                    ,pr_nraplica  => rw_lcto_rgt.nraplica
                                    ,pr_tpaplrdc  => rw_lcto_rgt.tpaplrdc
                                    ,pr_dtmvtolt  => rw_lcto_rgt.dtmvtolt);

                      FETCH cr_resgat
                       INTO vr_sldaplic;
                      CLOSE cr_resgat;
                    END IF;
                    IF vr_sldaplic = 0 THEN
                      vr_sldaplic := rw_lcto_rgt.vllanmto;
                    END IF;
                    IF vr_qtcotas = 0 THEN
                                              
                      vr_cdcritic := NULL;
                      vr_dscritic := NULL;

                      vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);                    
                      CONTINUE;
                                                               
                    ELSE
                      vr_vlpreco_unit := vr_sldaplic / vr_qtcotas;
                    END IF;                  
                      
                  ELSE
                    vr_vlpreco_unit := rw_lcto_rgt.vlpreco_registro;
                  END IF;
                  
                END IF;
              
                vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto_rgt.valorbase);            
          
                IF vr_tab_reg_ultimo_rgt.exists(vr_idx_aplic) THEN
                  IF rw_lcto_rgt.idsaqtot = 1 AND vr_tab_reg_ultimo_rgt(vr_idx_aplic) = vr_idx THEN
                                          
                    IF fn_eh_pcapta(rw_lcto_rgt.tpaplrdc) THEN
                      OPEN cr_craplac(pr_cdcooper => rw_cop.cdcooper
                                     ,pr_nrdconta => rw_lcto_rgt.nrdconta
                                     ,pr_nraplica => rw_lcto_rgt.nraplica
                                     ,pr_dtmvtolt => rw_lcto_rgt.dtmvtolt);
                      FETCH cr_craplac INTO rw_craplac;
                      IF NOT cr_craplac%FOUND THEN
                        vr_qtcotas_resg := fn_busca_qtcotas_atualizado(rw_lcto_rgt.idaplcus);
                          
                        cecred.apli0007.pc_log(pr_cdcritic => 1201
                              ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                              ' - '     || ' Cotas atualizadas - ' ||
                                              'cdcooper ' || rw_cop.cdcooper      || ' - ' ||
                                              'nrdconta ' || rw_lcto_rgt.nrdconta || ' - ' ||
                                              'nraplica ' || rw_lcto_rgt.nraplica || ' - ' ||
                                              'de: ' || fn_converte_valor_em_cota(rw_lcto_rgt.valorbase)|| ' ' ||
                                              'para: '|| vr_qtcotas_resg
                              ,pr_dstiplog => 'O'
                              ,pr_tpocorre => 4  
                              ,pr_cdcricid => 0  
                              );
                          
                      END IF;
                      CLOSE cr_craplac;
                    ELSE
                      OPEN cr_craplap(pr_cdcooper => rw_cop.cdcooper
                                     ,pr_nrdconta => rw_lcto_rgt.nrdconta
                                     ,pr_nraplica => rw_lcto_rgt.nraplica
                                     ,pr_dtmvtolt => rw_lcto_rgt.dtmvtolt);
                      FETCH cr_craplap INTO rw_craplap;
                      IF NOT cr_craplap%FOUND THEN
                        vr_qtcotas_resg := fn_busca_qtcotas_atualizado(rw_lcto_rgt.idaplcus);
                          
                       cecred.apli0007.pc_log(pr_cdcritic => 1201
                              ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                              ' - '     || ' Cotas atualizadas - ' ||
                                              'cdcooper ' || rw_cop.cdcooper      || ' - ' ||
                                              'nrdconta ' || rw_lcto_rgt.nrdconta || ' - ' ||
                                              'nraplica ' || rw_lcto_rgt.nraplica || ' - ' ||
                                              'de: ' || fn_converte_valor_em_cota(rw_lcto_rgt.valorbase)|| ' ' ||
                                              'para: '|| vr_qtcotas_resg
                              ,pr_dstiplog => 'O'
                              ,pr_tpocorre => 4  
                              ,pr_cdcricid => 0  
                              );
                                
                      END IF;
                      CLOSE cr_craplap;
                    END IF;
                  END IF;
                END IF;

              select cecred.tbcapt_custodia_lanctos_seq.nextval into vr_idlancamento from dual;   
               
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idlancamento      := vr_idlancamento;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idaplicacao       := rw_lcto_rgt.idaplcus;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idtipo_arquivo    := rw_lcto_rgt.idtipo_arquivo;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idtipo_lancto     := rw_lcto_rgt.idtipo_lancto;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).cdhistorico       := rw_lcto_rgt.cdhistor;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).cdoperacao_b3     := rw_lcto_rgt.cdoperacao_b3;                                         
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).vlregistro        := rw_lcto_rgt.vllanmto;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).qtcotas           := vr_qtcotas_resg;
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).vlpreco_unitario  := vr_vlpreco_unit;                                
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).idsituacao        := 0; 
              vr_tab_tbcapt_custodia_lanctos(vr_idlancamento).dtregistro        := rw_lcto_rgt.dtmvtolt; 
                              
              IF rw_lcto_rgt.tpaplrdc in(3,4) THEN   
                vr_tab_craplac(vr_idlancamento).idlctcus     := vr_idlancamento;
                vr_tab_craplac(vr_idlancamento).vr_rowid     := rw_lcto_rgt.rowid_lct;
              ELSE  
                vr_tab_craplap(vr_idlancamento).idlctcus     := vr_idlancamento;  
                vr_tab_craplap(vr_idlancamento).vr_rowid     := rw_lcto_rgt.rowid_lct; 
              END IF; 
                
              vr_tab_tbcapt_custodia_aplicacao(vr_idlancamento).qtcotas           := vr_qtcotas_resg;
              vr_tab_tbcapt_custodia_aplicacao(vr_idlancamento).vlpreco_unitario  := vr_vlpreco_unit;  
              vr_tab_tbcapt_custodia_aplicacao(vr_idlancamento).idaplicacao       := rw_lcto_rgt.idaplcus;                      

              vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);      
                  
              EXCEPTION
                WHEN vr_exc_sai_LanArqLopWh1Wh2_2C THEN
                  pc_critica_loop;         
                  IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                    RAISE vr_exc_sai_LanArq_LopCop_S;
                  ELSE               
                    vr_cdcritic := NULL;
                    vr_dscritic := NULL;
                      vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);
                  END IF;  
                WHEN OTHERS THEN
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  vr_cdcritic  := 9999;
                  vr_dssqlerrm := SQLERRM;
                  vr_idcritic  := 2;
                  pc_critica_loop;                  

                  IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                    RAISE vr_exc_sai_LanArq_LopCop_S;
                  ELSE               
                    vr_cdcritic := NULL;
                    vr_dscritic := NULL;
                    vr_idx      := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);
                  END IF;
              END;            
            END LOOP;
            
            vr_idx_aplic:= vr_tab_reg_aplicacao.NEXT(vr_idx_aplic);

          EXCEPTION
            WHEN vr_exc_sai_LanArq_LopWh1_2C THEN
              pc_critica_loop;         
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_LanArq_LopCop_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
                vr_idx_aplic:= vr_tab_reg_aplicacao.NEXT(vr_idx_aplic);
              END IF;  
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => 3);
              vr_cdcritic  := 9999;
              vr_dssqlerrm := SQLERRM;
              vr_idcritic  := 2; 
              pc_critica_loop;                  

              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_LanArq_LopCop_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
                vr_idx_aplic:= vr_tab_reg_aplicacao.NEXT(vr_idx_aplic);
              END IF;
          END;
        END LOOP;
          
        BEGIN               
          FORALL idx IN INDICES OF vr_tab_tbcapt_custodia_lanctos SAVE EXCEPTIONS                    
            INSERT INTO cecred.TBCAPT_CUSTODIA_LANCTOS
                     (idlancamento
                     ,idaplicacao
                     ,idtipo_arquivo
                     ,idtipo_lancto
                     ,cdhistorico
                     ,cdoperacao_b3
                     ,vlregistro
                     ,qtcotas
                     ,vlpreco_unitario
                     ,idsituacao
                     ,dtregistro)
               VALUES(vr_tab_tbcapt_custodia_lanctos(idx).idlancamento
                     ,vr_tab_tbcapt_custodia_lanctos(idx).idaplicacao
                     ,vr_tab_tbcapt_custodia_lanctos(idx).idtipo_arquivo
                     ,vr_tab_tbcapt_custodia_lanctos(idx).idtipo_lancto
                     ,vr_tab_tbcapt_custodia_lanctos(idx).cdhistorico
                     ,vr_tab_tbcapt_custodia_lanctos(idx).cdoperacao_b3
                     ,vr_tab_tbcapt_custodia_lanctos(idx).vlregistro
                     ,vr_tab_tbcapt_custodia_lanctos(idx).qtcotas
                     ,vr_tab_tbcapt_custodia_lanctos(idx).vlpreco_unitario
                     ,vr_tab_tbcapt_custodia_lanctos(idx).idsituacao
                     ,vr_tab_tbcapt_custodia_lanctos(idx).dtregistro);
        EXCEPTION
          WHEN OTHERS THEN

          FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
              CECRED.pc_internal_exception(pr_cdcooper => 3);
              vr_cdcritic  := 1034;                 
              vr_dssqlerrm := SQLERRM;
              vr_idcritic  := 2;
              vr_dsparesp  := ', tabela: TBCAPT_CUSTODIA_LANCTOS' ||
                              ', qtcotas:     ' || vr_tab_tbcapt_custodia_lanctos(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).qtcotas  ||
                              ', vlpreco_unitario: ' || vr_tab_tbcapt_custodia_lanctos(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlpreco_unitario ||
                              ', idsituacao: 0';
                  RAISE vr_exc_sai_LanArqLopWh1Wh2_2C;
          END LOOP;           
        END;
                  
        BEGIN                
          FORALL idx IN INDICES OF vr_tab_craplac SAVE EXCEPTIONS                
            UPDATE cecred.craplac
               SET idlctcus = vr_tab_craplac(idx).idlctcus
             WHERE ROWID =  vr_tab_craplac(idx).vr_rowid; 
        EXCEPTION
          WHEN OTHERS THEN
             FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                  vr_idcritic  := 2;
                  vr_dsparesp  := ', tabela: craplac'     ||
                                  ', idaplcus:' || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idlctcus ||
                                  ', ROWID:'    || vr_tab_craplac(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
               RAISE vr_exc_sai_LanArqLopWh1Wh2_2C;                    
             END LOOP;                  
        END;
                    
        BEGIN                
          FORALL idx IN INDICES OF vr_tab_craplap SAVE EXCEPTIONS  
            UPDATE cecred.craplap
               SET idlctcus = vr_tab_craplap(idx).idlctcus 
             WHERE ROWID    = vr_tab_craplap(idx).vr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
             FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
                  vr_idcritic  := 2;
                  vr_dsparesp  := ', tabela: craplap'     ||
                                  ', idlctcus:' || vr_tab_craplap(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).idlctcus ||
                                  ', ROWID:'    || vr_tab_craplap(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vr_rowid;
               RAISE vr_exc_sai_LanArqLopWh1Wh2_2C;                    
             END LOOP;                   
        END;   
                
        BEGIN                   
            FORALL idx IN INDICES OF vr_tab_tbcapt_custodia_aplicacao SAVE EXCEPTIONS
            UPDATE cecred.tbcapt_custodia_aplicacao apl
               SET apl.qtcotas =  greatest(0,apl.qtcotas-vr_tab_tbcapt_custodia_aplicacao(idx).qtcotas) 
                  ,apl.vlpreco_unitario = vr_tab_tbcapt_custodia_aplicacao(idx).vlpreco_unitario
             WHERE apl.idaplicacao      =  vr_tab_tbcapt_custodia_aplicacao(idx).idaplicacao;
                  
          EXCEPTION
            WHEN OTHERS THEN                    
                      
                FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                    vr_cdcritic  := 1035;                 
                    vr_dssqlerrm := SQLERRM;
                    vr_idcritic  := 2;
                    vr_dsparesp  := ', tabela: tbcapt_custodia_aplicacao' ||
                                    ', qtcotas_resg: '    || vr_tab_tbcapt_custodia_aplicacao(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).qtcotas ||
                                    ', vr_vlpreco_unit: ' || vr_tab_tbcapt_custodia_aplicacao(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlpreco_unitario ;
                        RAISE vr_exc_sai_LanArqLopWh1Wh2_2C;
                                                                                    
                END LOOP;                                
        END; 
      END IF;

    EXCEPTION
        WHEN vr_exc_sai_LanArq_LopCop_S THEN
          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_sai_lan_arq_1_S;
          ELSE               
            vr_cdcritic := NULL;
            vr_dscritic := NULL;        
          END IF;            
        WHEN vr_exc_sai_LanArq_LopCop_1 THEN
          pc_critica_loop;         
          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_sai_lan_arq_1_S;
          ELSE               
            vr_cdcritic := NULL;
            vr_dscritic := NULL;        
          END IF;  
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => 3);
          vr_cdcritic  := 9999;
          vr_dssqlerrm := SQLERRM;
          vr_idcritic  := 2;
          pc_critica_loop;                  

          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_sai_lan_arq_1_S;
          ELSE               
            vr_cdcritic := NULL;
            vr_dscritic := NULL;        
          END IF;
    END;

    COMMIT;
      
    END LOOP;

    IF vr_flenvreg <> 'S' THEN
      vr_dsdaviso := vr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro será criado pois a opção está Desativada!';
    ELSE
      vr_dsdaviso := vr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Registros de Aplicação Gerados: '||vr_qtregreg;
    END IF;

    IF vr_flenvreg <> 'S' THEN
      vr_dsdaviso := vr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro de Operação será criado pois a opção está Desativada!';
    ELSE
      vr_dsdaviso := vr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Operações em Aplicação Gerados: '||vr_qtregrgt;
    END IF;
    
    dbms_output.put_line(vr_dsdaviso);
    
    cecred.apli0007.pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                          '. Finalizado' ||
                          ' '      || vr_nmaction  ||
                          ' '      || vr_nmproint1
          ,pr_dstiplog => 'O' 
          ,pr_tpocorre => 4   
          ,pr_cdcricid => 0   
          ); 

  EXCEPTION
    WHEN vr_exc_sai_lan_arq_1_S THEN 
      ROLLBACK; 
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      vr_cdcritic  := 9999;
      vr_idcritic  := 2;
      vr_dssqlerrm := SQLERRM;
      pc_finaliza;
  END;
0
0
