DECLARE

  vr_dtrefere     cecred.crapdat.dtmvtolt%TYPE := to_date('30/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ant cecred.crapdat.dtmvtolt%TYPE := to_date('28/09/2023', 'DD/MM/RRRR');
  
  pr_cdcooper NUMBER := 14;
  vr_nrdconta NUMBER := 30422;
  vr_nrctremp NUMBER := 25750;
  vr_vlarrasto NUMBER := 130;

  vr_exc_erro   EXCEPTION;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(4000);
  vr_des_erro   VARCHAR2(4000);
  vr_cdprograma VARCHAR2(25) := 'atualiza_crapris_BNDES';
  
  vr_inrisco_inclusao tbrisco_central_ocr.inrisco_inclusao%TYPE;
  vr_inrisco_rating   tbrisco_central_ocr.inrisco_rating%TYPE;
  vr_inrisco_atraso   tbrisco_central_ocr.inrisco_atraso%TYPE;
  vr_inrisco_agravado tbrisco_central_ocr.inrisco_agravado%TYPE;
  vr_inrisco_melhora  tbrisco_central_ocr.inrisco_melhora%TYPE;
  vr_inrisco_refin    tbrisco_central_ocr.inrisco_refin%TYPE;
  vr_inrisco_operacao tbrisco_central_ocr.inrisco_operacao%TYPE;
  vr_inrisco_final    tbrisco_central_ocr.inrisco_final%TYPE;
      
  vr_diasvenc     NUMBER;
  vr_cdvencto     NUMBER;
  vr_qtdiaatr     NUMBER := 0;
  vr_qtdias_atr   NUMBER := 0;
  vr_qtdiaatr_ori NUMBER := 0;
  vr_flarrasto    NUMBER := 0;
  vr_nrseqctr    NUMBER := 0;
  vr_dtdrisco     DATE;
  vr_index_crapris          PLS_INTEGER;
  
  
  TYPE typ_tab_vlparcel IS TABLE OF NUMBER
       INDEX BY PLS_INTEGER;
  vr_tab_vlavence typ_tab_vlparcel;
  
  TYPE typ_tab_ddparcel IS TABLE OF PLS_INTEGER
       INDEX BY PLS_INTEGER;
  vr_tab_ddavence typ_tab_ddparcel;
  
  CURSOR cr_crapris_arrasto_last(pr_cdcooper crapris.cdcooper%TYPE
                                ,pr_nrdconta NUMBER
                                ,pr_nrctremp NUMBER
                                ,pr_cdmodali NUMBER
                                ,pr_dtrefere crapris.dtrefere%TYPE) IS
     SELECT r.cdcooper
          , r.nrdconta
          , r.nrctremp
          , r.dtrefere
          , r.innivris
          , r.dtdrisco
          , r.cdmodali
          , r.cdorigem
      FROM crapris r
          ,crapass ass
     WHERE r.cdcooper = ass.cdcooper
       AND r.nrdconta = ass.nrdconta
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND r.cdmodali = pr_cdmodali
       AND r.inddocto = 1 
     ORDER BY r.dtrefere DESC 
            , r.innivris DESC 
            , r.dtdrisco DESC;
            
  rw_crapris_arrasto_last cr_crapris_arrasto_last%ROWTYPE;
  
  CURSOR cr_crapris_nrseqctr(pr_cdcooper crapris.cdcooper%TYPE
                            ,pr_nrdconta NUMBER
                            ,pr_nrctremp NUMBER
                            ,pr_cdmodali NUMBER
                            ,pr_dtrefere crapris.dtrefere%TYPE) IS
     SELECT MAX(r.nrseqctr) nrseqctr
      FROM crapris r
          ,crapass ass
     WHERE r.cdcooper = ass.cdcooper
       AND r.nrdconta = ass.nrdconta
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp
       AND r.cdmodali = pr_cdmodali; 
  
  
  CURSOR cr_crapcop(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND (c.cdcooper = pr_cdcooper OR pr_cdcooper = 0);
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_contratos_bndes(pr_cdcooper IN cecred.crapris.cdcooper%TYPE,
                            pr_nrdconta IN NUMBER,
                            pr_nrctremp IN NUMBER) IS
    SELECT ebn.nrctremp
          ,ebn.nrdconta
          ,ass.cdagenci
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ebn.dtinictr
          ,ebn.vlsdeved
          ,ebn.dtvctpro
          ,ebn.dtfimctr
          ,ebn.dtppvenc
          ,ebn.vlparepr
          ,ebn.insitctr
          ,ebn.qtparctr
          ,ebn.vlprac48
          ,ebn.vlprej48
          ,ebn.vlprej12
          ,ebn.vlvac540
          ,ebn.vlven540
          ,ebn.vlven360
          ,ebn.vlven300
          ,ebn.vlven240
          ,ebn.vlven180
          ,ebn.vlven150
          ,ebn.vlven120
          ,ebn.vlvenc90
          ,ebn.vlvenc60
          ,ebn.vlvenc30
          ,ebn.vlav5400
          ,ebn.vlaa5400
          ,ebn.vlav1800
          ,ebn.vlav1440
          ,ebn.vlav1080
          ,ebn.vlave720
          ,ebn.vlave360
          ,ebn.vlave180
          ,ebn.vlaven90
          ,ebn.vlaven60
          ,ebn.vlaven30
          ,ebn.vlvenc14
          ,ebn.vlaat180
          ,ebn.vlasu360
          ,ebn.vlveat60
          ,ebn.vlvenc61
          ,ebn.vlven181
          ,ebn.vlvsu360
      FROM crapebn ebn,
           crapass ass
     WHERE ebn.cdcooper = pr_cdcooper
       AND ebn.nrdconta = pr_nrdconta
       AND ebn.nrctremp = pr_nrctremp
       AND ebn.cdcooper = ass.cdcooper
       AND ebn.nrdconta = ass.nrdconta       
       AND ebn.insitctr IN('N','A','P');
  rw_contratos_bndes cr_contratos_bndes%ROWTYPE;
  
  FUNCTION fn_retorna_datarisco(pr_cdcooper IN crapris.cdcooper%TYPE
                               ,pr_nrdconta IN crapris.nrdconta%TYPE
                               ,pr_nrctremp IN crapris.nrctremp%TYPE
                               ,pr_cdmodali IN crapris.cdmodali%TYPE
                               ,pr_cdorigem IN crapris.cdorigem%TYPE
                               ,pr_innivris IN crapris.innivris%TYPE) RETURN DATE IS
                               
    vr_dtdrisco crapris.dtdrisco%TYPE;
  BEGIN    
    
    rw_crapris_arrasto_last := NULL;
    OPEN cr_crapris_arrasto_last (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_cdmodali => pr_cdmodali
                                 ,pr_dtrefere => vr_dtrefere_ant);
    FETCH cr_crapris_arrasto_last INTO rw_crapris_arrasto_last;
    CLOSE cr_crapris_arrasto_last;
    
    IF rw_crapris_arrasto_last.innivris IS NOT NULL THEN
      IF (rw_crapris_arrasto_last.innivris <> pr_innivris) AND pr_innivris <> -1 THEN      
        vr_dtdrisco := vr_dtrefere;
      ELSE      
        IF rw_crapris_arrasto_last.dtdrisco IS NULL THEN
          vr_dtdrisco := vr_dtrefere;
        ELSE
      
          vr_dtdrisco := rw_crapris_arrasto_last.dtdrisco;
        END IF;
      END IF;
    ELSE
      
      vr_dtdrisco := vr_dtrefere;
    END IF;

    RETURN vr_dtdrisco;
    
  END fn_retorna_datarisco; 
  
  PROCEDURE pc_grava_crapris( pr_nrdconta crapris.nrdconta%TYPE,    
                              pr_dtrefere crapris.dtrefere%TYPE,    
                              pr_innivris crapris.innivris%TYPE,    
                              pr_qtdiaatr crapris.qtdiaatr%TYPE,    
                              pr_vldivida crapris.vldivida%TYPE,    
                              pr_vlvec180 crapris.vlvec180%TYPE,    
                              pr_vlvec360 crapris.vlvec360%TYPE,    
                              pr_vlvec999 crapris.vlvec999%TYPE,    
                              pr_vldiv060 crapris.vldiv060%TYPE,    
                              pr_vldiv180 crapris.vldiv180%TYPE,    
                              pr_vldiv360 crapris.vldiv360%TYPE,    
                              pr_vldiv999 crapris.vldiv999%TYPE,    
                              pr_vlprjano crapris.vlprjano%TYPE,    
                              pr_vlprjaan crapris.vlprjaan%TYPE,    
                              pr_inpessoa crapris.inpessoa%TYPE,    
                              pr_nrcpfcgc crapris.nrcpfcgc%TYPE,    
                              pr_vlprjant crapris.vlprjant%TYPE,    
                              pr_inddocto crapris.inddocto%TYPE,    
                              pr_cdmodali crapris.cdmodali%TYPE,    
                              pr_nrctremp crapris.nrctremp%TYPE,    
                              pr_nrseqctr crapris.nrseqctr%TYPE,    
                              pr_dtinictr crapris.dtinictr%TYPE,    
                              pr_cdorigem crapris.cdorigem%TYPE,    
                              pr_cdagenci crapris.cdagenci%TYPE,    
                              pr_innivori crapris.innivori%TYPE,    
                              pr_cdcooper crapris.cdcooper%TYPE,    
                              pr_vlmrapar60 crapris.vlmrapar60%TYPE,
                              pr_vljuremu60 crapris.vljuremu60%TYPE,
                              pr_vljurcor60 crapris.vljurcor60%TYPE,
                              pr_vlprjm60 crapris.vlprjm60%TYPE,    
                              pr_dtdrisco crapris.dtdrisco%TYPE,    
                              pr_qtdriclq crapris.qtdriclq%TYPE,    
                              pr_nrdgrupo crapris.nrdgrupo%TYPE,    
                              pr_vljura60 crapris.vljura60%TYPE,    
                              pr_inindris crapris.inindris%TYPE,    
                              pr_cdinfadi crapris.cdinfadi%TYPE,    
                              pr_nrctrnov crapris.nrctrnov%TYPE,    
                              pr_flgindiv crapris.flgindiv%TYPE,    
                              pr_dsinfaux crapris.dsinfaux%TYPE,    
                              pr_dtprxpar crapris.dtprxpar%TYPE,    
                              pr_vlprxpar crapris.vlprxpar%TYPE,    
                              pr_qtparcel crapris.qtparcel%TYPE,    
                              pr_dtvencop crapris.dtvencop%TYPE,    
                              pr_vlsld59d crapris.vlsld59d%TYPE DEFAULT 0,
                              pr_vljurantpp crapris.vljurantpp%TYPE,
                              pr_vljurparpp crapris.vljurparpp%TYPE,
                              pr_vljurmorpp crapris.vljurmorpp%TYPE,
                              pr_vljurmulpp crapris.vljurmulpp%TYPE,
                              pr_vljuriofpp crapris.vljuriofpp%TYPE,
                              pr_vljurcorpp crapris.vljurcorpp%TYPE,
                              pr_inespecie  crapris.inespecie%TYPE DEFAULT 0, 
                              pr_qtdiaatr_ori  crapris.qtdiaatr%TYPE,         
                              pr_nracordo      NUMBER,                        
                              pr_flarrasto     NUMBER DEFAULT 1,              
                              pr_des_erro      OUT VARCHAR2,
                              pr_index_crapris OUT PLS_INTEGER
                              ) IS

    vr_dttrfprj DATE := NULL;
    
    TYPE typ_tab_crapris IS TABLE OF crapris%ROWTYPE INDEX BY PLS_INTEGER;
    vr_tab_crapris typ_tab_crapris;

  BEGIN

    vr_index_crapris:= vr_tab_crapris.count+1;

    vr_tab_crapris(vr_index_crapris).nrdconta   := pr_nrdconta;
    vr_tab_crapris(vr_index_crapris).dtrefere   := pr_dtrefere;
    vr_tab_crapris(vr_index_crapris).innivris   := pr_innivris;
    vr_tab_crapris(vr_index_crapris).qtdiaatr   := pr_qtdiaatr;
    vr_tab_crapris(vr_index_crapris).vldivida   := pr_vldivida;
    vr_tab_crapris(vr_index_crapris).vlsld59d   := NVL(pr_vlsld59d,0);
    vr_tab_crapris(vr_index_crapris).vlvec180   := pr_vlvec180;
    vr_tab_crapris(vr_index_crapris).vlvec360   := pr_vlvec360;
    vr_tab_crapris(vr_index_crapris).vlvec999   := pr_vlvec999;
    vr_tab_crapris(vr_index_crapris).vldiv060   := pr_vldiv060;
    vr_tab_crapris(vr_index_crapris).vldiv180   := pr_vldiv180;
    vr_tab_crapris(vr_index_crapris).vldiv360   := pr_vldiv360;
    vr_tab_crapris(vr_index_crapris).vldiv999   := pr_vldiv999;
    vr_tab_crapris(vr_index_crapris).vlprjano   := pr_vlprjano;
    vr_tab_crapris(vr_index_crapris).vlprjaan   := pr_vlprjaan;
    vr_tab_crapris(vr_index_crapris).inpessoa   := pr_inpessoa;
    vr_tab_crapris(vr_index_crapris).nrcpfcgc   := pr_nrcpfcgc;
    vr_tab_crapris(vr_index_crapris).vlprjant   := pr_vlprjant;
    vr_tab_crapris(vr_index_crapris).inddocto   := pr_inddocto;
    vr_tab_crapris(vr_index_crapris).cdmodali   := pr_cdmodali;
    vr_tab_crapris(vr_index_crapris).nrctremp   := pr_nrctremp;
    vr_tab_crapris(vr_index_crapris).nrseqctr   := pr_nrseqctr;
    vr_tab_crapris(vr_index_crapris).dtinictr   := pr_dtinictr;
    vr_tab_crapris(vr_index_crapris).cdorigem   := pr_cdorigem;
    vr_tab_crapris(vr_index_crapris).cdagenci   := pr_cdagenci;
    vr_tab_crapris(vr_index_crapris).innivori   := pr_innivori;
    vr_tab_crapris(vr_index_crapris).cdcooper   := pr_cdcooper;
    vr_tab_crapris(vr_index_crapris).vlmrapar60 := pr_vlmrapar60; 
    vr_tab_crapris(vr_index_crapris).vljuremu60 := pr_vljuremu60; 
    vr_tab_crapris(vr_index_crapris).vljurcor60 := pr_vljurcor60; 
    vr_tab_crapris(vr_index_crapris).vlprjm60   := pr_vlprjm60;
    vr_tab_crapris(vr_index_crapris).dtdrisco   := pr_dtdrisco;
    vr_tab_crapris(vr_index_crapris).qtdriclq   := pr_qtdriclq;
    vr_tab_crapris(vr_index_crapris).nrdgrupo   := pr_nrdgrupo;
    vr_tab_crapris(vr_index_crapris).vljura60   := pr_vljura60;
    vr_tab_crapris(vr_index_crapris).inindris   := pr_inindris;
    vr_tab_crapris(vr_index_crapris).cdinfadi   := pr_cdinfadi;
    vr_tab_crapris(vr_index_crapris).nrctrnov   := pr_nrctrnov;
    vr_tab_crapris(vr_index_crapris).flgindiv   := pr_flgindiv;
    vr_tab_crapris(vr_index_crapris).dsinfaux   := pr_dsinfaux;
    vr_tab_crapris(vr_index_crapris).dtprxpar   := pr_dtprxpar;
    vr_tab_crapris(vr_index_crapris).vlprxpar   := pr_vlprxpar;
    vr_tab_crapris(vr_index_crapris).qtparcel   := pr_qtparcel;
    vr_tab_crapris(vr_index_crapris).dtvencop   := pr_dtvencop;
    vr_tab_crapris(vr_index_crapris).vljurantpp := pr_vljurantpp;
    vr_tab_crapris(vr_index_crapris).vljurparpp := pr_vljurparpp;
    vr_tab_crapris(vr_index_crapris).vljurmorpp := pr_vljurmorpp;
    vr_tab_crapris(vr_index_crapris).vljurmulpp := pr_vljurmulpp;
    vr_tab_crapris(vr_index_crapris).vljuriofpp := pr_vljuriofpp;
    vr_tab_crapris(vr_index_crapris).vljurcorpp := pr_vljurcorpp;
    vr_tab_crapris(vr_index_crapris).inespecie := pr_inespecie;
    vr_tab_crapris(vr_index_crapris).qtdiaatr_ori := pr_qtdiaatr_ori;
    vr_tab_crapris(vr_index_crapris).nracordo     := pr_nracordo;
    vr_tab_crapris(vr_index_crapris).flarrasto     := pr_flarrasto;

    pr_index_crapris := vr_index_crapris;
    
    IF pr_flarrasto = 0 AND pr_innivris >= 9 THEN
      vr_dttrfprj := PREJ0001.fn_regra_dtprevisao_prejuizo(pr_cdcooper,
                                                           pr_innivris,
                                                           pr_qtdiaatr,
                                                           pr_dtdrisco);
      vr_tab_crapris(vr_index_crapris).dttrfprj     := vr_dttrfprj;
    END IF;
    

    FOR idx IN vr_tab_crapris.first..vr_tab_crapris.last LOOP
      INSERT INTO crapris
               (  nrdconta,
                  dtrefere,
                  innivris,
                  qtdiaatr,
                  vldivida,
                  vlsld59d,
                  vlvec180,
                  vlvec360,
                  vlvec999,
                  vldiv060,
                  vldiv180,
                  vldiv360,
                  vldiv999,
                  vlprjano,
                  vlprjaan,
                  inpessoa,
                  nrcpfcgc,
                  vlprjant,
                  inddocto,
                  cdmodali,
                  nrctremp,
                  nrseqctr,
                  dtinictr,
                  cdorigem,
                  cdagenci,
                  innivori,
                  cdcooper,
                  vlprjm60,
                  dtdrisco,
                  qtdriclq,
                  nrdgrupo,
                  vljura60,
                  inindris,
                  cdinfadi,
                  nrctrnov,
                  flgindiv,
                  dsinfaux,
                  dtprxpar,
                  vlprxpar,
                  qtparcel,
                  dtvencop,
                  vlmrapar60, 
                  vljuremu60, 
                  vljurcor60, 
                  vljurantpp,
                  vljurparpp,
                  vljurmorpp,
                  vljurmulpp,
                  vljuriofpp,
                  vljurcorpp,
                  inespecie,
                  qtdiaatr_ori,
                  nracordo,
                  flarrasto,
                  dttrfprj
                  )
          VALUES (vr_tab_crapris(idx).nrdconta,
                  vr_tab_crapris(idx).dtrefere,
                  vr_tab_crapris(idx).innivris,
                  vr_tab_crapris(idx).qtdiaatr,
                  vr_tab_crapris(idx).vldivida,
                  vr_tab_crapris(idx).vlsld59d,
                  vr_tab_crapris(idx).vlvec180,
                  vr_tab_crapris(idx).vlvec360,
                  vr_tab_crapris(idx).vlvec999,
                  vr_tab_crapris(idx).vldiv060,
                  vr_tab_crapris(idx).vldiv180,
                  vr_tab_crapris(idx).vldiv360,
                  vr_tab_crapris(idx).vldiv999,
                  vr_tab_crapris(idx).vlprjano,
                  vr_tab_crapris(idx).vlprjaan,
                  vr_tab_crapris(idx).inpessoa,
                  vr_tab_crapris(idx).nrcpfcgc,
                  vr_tab_crapris(idx).vlprjant,
                  vr_tab_crapris(idx).inddocto,
                  vr_tab_crapris(idx).cdmodali,
                  vr_tab_crapris(idx).nrctremp,
                  vr_tab_crapris(idx).nrseqctr,
                  vr_tab_crapris(idx).dtinictr,
                  vr_tab_crapris(idx).cdorigem,
                  vr_tab_crapris(idx).cdagenci,
                  vr_tab_crapris(idx).innivori,
                  vr_tab_crapris(idx).cdcooper,
                  vr_tab_crapris(idx).vlprjm60,
                  vr_tab_crapris(idx).dtdrisco,
                  vr_tab_crapris(idx).qtdriclq,
                  vr_tab_crapris(idx).nrdgrupo,
                  vr_tab_crapris(idx).vljura60,
                  vr_tab_crapris(idx).inindris,
                  vr_tab_crapris(idx).cdinfadi,
                  vr_tab_crapris(idx).nrctrnov,
                  vr_tab_crapris(idx).flgindiv,
                  vr_tab_crapris(idx).dsinfaux,
                  vr_tab_crapris(idx).dtprxpar,
                  vr_tab_crapris(idx).vlprxpar,
                  vr_tab_crapris(idx).qtparcel,
                  vr_tab_crapris(idx).dtvencop,
                  vr_tab_crapris(idx).vlmrapar60, 
                  vr_tab_crapris(idx).vljuremu60, 
                  vr_tab_crapris(idx).vljurcor60, 

                  vr_tab_crapris(idx).vljurantpp,
                  vr_tab_crapris(idx).vljurparpp,
                  vr_tab_crapris(idx).vljurmorpp,
                  vr_tab_crapris(idx).vljurmulpp,
                  vr_tab_crapris(idx).vljuriofpp,
                  vr_tab_crapris(idx).vljurcorpp,

                  vr_tab_crapris(idx).inespecie,
                  vr_tab_crapris(idx).qtdiaatr_ori,
                  vr_tab_crapris(idx).nracordo,
                  vr_tab_crapris(idx).flarrasto,
                  vr_tab_crapris(idx).dttrfprj
                  );
    END LOOP;
    
    vr_tab_crapris.delete;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_des_erro := 'pc_grava_crapris -> Erro ao incluir na crapris.'|| sqlerrm;
  END pc_grava_crapris;

  
BEGIN
  vr_tab_ddavence(1) := 30;
  vr_tab_ddavence(2) := 60;
  vr_tab_ddavence(3) := 90;
  vr_tab_ddavence(4) := 180;
  vr_tab_ddavence(5) := 360;
  vr_tab_ddavence(6) := 720;
  vr_tab_ddavence(7) := 1080;
  vr_tab_ddavence(8) := 1440;
  vr_tab_ddavence(9) := 1800;
  vr_tab_ddavence(10) := 5400;
  vr_tab_ddavence(11) := 9999;
  vr_tab_ddavence(11) := 5401;
  vr_tab_ddavence(12) := -14;
  vr_tab_ddavence(13) := -30;
  vr_tab_ddavence(14) := -60;
  vr_tab_ddavence(15) := -90;
  vr_tab_ddavence(16) := -120;
  vr_tab_ddavence(17) := -150;
  vr_tab_ddavence(18) := -180;
  vr_tab_ddavence(19) := -240;
  vr_tab_ddavence(20) := -300;
  vr_tab_ddavence(21) := -360;
  vr_tab_ddavence(22) := -540;
  vr_tab_ddavence(23) := -541;

  FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP
    
    dbms_output.put_line('cdcooper;nrdconta;nrctremp;vlsdeved');
    
    FOR rw_contratos_bndes IN cr_contratos_bndes(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_nrctremp => vr_nrctremp ) LOOP
      
      
      vr_inrisco_inclusao := NULL;
      vr_inrisco_atraso   := NULL;
      vr_inrisco_agravado := NULL;
      vr_inrisco_melhora  := NULL;
      vr_inrisco_refin    := NULL;
      vr_inrisco_operacao := NULL;
      vr_inrisco_final    := NULL;
      vr_inrisco_rating   := 2;

      IF rw_contratos_bndes.insitctr IN ('A','P') THEN
        vr_qtdiaatr := to_char(vr_dtrefere - rw_contratos_bndes.dtppvenc);
        IF rw_contratos_bndes.vlprac48 <> 0 OR rw_contratos_bndes.vlprej48 <> 0 OR rw_contratos_bndes.vlprej12 <> 0  THEN
          vr_inrisco_atraso := 10;
        ELSIF rw_contratos_bndes.vlvac540 <> 0 OR rw_contratos_bndes.vlven540 <> 0
           OR rw_contratos_bndes.vlven360 <> 0 OR rw_contratos_bndes.vlven300 <> 0 OR rw_contratos_bndes.vlven240 <> 0 THEN
          vr_inrisco_atraso := 9;
        ELSIF rw_contratos_bndes.vlven180 <> 0 THEN
          vr_inrisco_atraso := 8;
        ELSIF rw_contratos_bndes.vlven150 <> 0 THEN
          vr_inrisco_atraso := 7;
        ELSIF rw_contratos_bndes.vlven120 <> 0 THEN
          vr_inrisco_atraso := 6;
        ELSIF rw_contratos_bndes.vlvenc90 <> 0 THEN
          vr_inrisco_atraso := 5;
        ELSIF rw_contratos_bndes.vlvenc60 <> 0 THEN
          vr_inrisco_atraso := 4;
        ELSIF rw_contratos_bndes.vlvenc30 <> 0 THEN
          vr_inrisco_atraso := 3;
        ELSIF rw_contratos_bndes.vlvenc14 <> 0 THEN
          vr_inrisco_atraso := 2;
        ELSE
          vr_inrisco_atraso := 1;
        END IF;
      ELSE
        vr_qtdiaatr := 0;
        vr_inrisco_atraso := 2;
      END IF;

      vr_qtdias_atr   := vr_qtdiaatr;
      vr_qtdiaatr_ori := vr_qtdiaatr;

      
      vr_inrisco_inclusao := 2;
      
      vr_inrisco_final := greatest(NVL(vr_inrisco_inclusao,2)
                                  ,NVL(vr_inrisco_atraso  ,2)
                                  ,NVL(vr_inrisco_rating  ,2));
      
      IF  vr_inrisco_rating   = 1
      AND vr_inrisco_inclusao = 1
      AND vr_inrisco_final    = 2
      AND vr_qtdias_atr       = 0 THEN

        vr_inrisco_final := 1;
      END IF;
      
      vr_flarrasto := 1;
      vr_dtdrisco  := NULL;
      IF vr_vlarrasto > rw_contratos_bndes.vlsdeved THEN
        vr_flarrasto := 0;
        vr_dtdrisco := fn_retorna_datarisco(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_nrdconta => rw_contratos_bndes.nrdconta
                                           ,pr_nrctremp => rw_contratos_bndes.nrctremp
                                           ,pr_cdmodali => 0499
                                           ,pr_cdorigem => 3
                                           ,pr_innivris => vr_inrisco_final);
      END IF;

      vr_nrseqctr := 0;
      OPEN cr_crapris_nrseqctr (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrdconta => rw_contratos_bndes.nrdconta
                               ,pr_nrctremp => rw_contratos_bndes.nrctremp
                               ,pr_cdmodali => 0499
                               ,pr_dtrefere => vr_dtrefere);
                               
      FETCH cr_crapris_nrseqctr INTO vr_nrseqctr;
      CLOSE cr_crapris_nrseqctr;
      
      vr_nrseqctr := nvl(vr_nrseqctr,0) + 1;
      
      pc_grava_crapris(  pr_nrdconta => rw_contratos_bndes.nrdconta
                        ,pr_dtrefere => vr_dtrefere
                        ,pr_innivris => vr_inrisco_final
                        ,pr_qtdiaatr => vr_qtdiaatr
                        ,pr_vldivida => rw_contratos_bndes.vlsdeved
                        ,pr_vlvec180 => rw_contratos_bndes.vlaat180
                        ,pr_vlvec360 => rw_contratos_bndes.vlaat180 + rw_contratos_bndes.vlave360
                        ,pr_vlvec999 => rw_contratos_bndes.vlasu360
                        ,pr_vldiv060 => rw_contratos_bndes.vlveat60
                        ,pr_vldiv180 => rw_contratos_bndes.vlveat60 + rw_contratos_bndes.vlvenc61
                        ,pr_vldiv360 => rw_contratos_bndes.vlveat60 + rw_contratos_bndes.vlvenc61 + rw_contratos_bndes.vlven181
                        ,pr_vldiv999 => rw_contratos_bndes.vlvsu360
                        ,pr_vlprjano => rw_contratos_bndes.vlprej12
                        ,pr_vlprjaan => rw_contratos_bndes.vlprej48
                        ,pr_inpessoa => rw_contratos_bndes.inpessoa
                        ,pr_nrcpfcgc => rw_contratos_bndes.nrcpfcgc
                        ,pr_vlprjant => rw_contratos_bndes.vlprac48
                        ,pr_inddocto => 1          
                        ,pr_cdmodali => 0499
                        ,pr_nrctremp => rw_contratos_bndes.nrctremp
                        ,pr_nrseqctr => vr_nrseqctr
                        ,pr_dtinictr => rw_contratos_bndes.dtinictr
                        ,pr_cdorigem => 3
                        ,pr_cdagenci => rw_contratos_bndes.cdagenci
                        ,pr_innivori => 0
                        ,pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_vlmrapar60 => 0 
                        ,pr_vljuremu60 => 0 
                        ,pr_vljurcor60 => 0 
                        ,pr_vlprjm60 => 0
                        ,pr_dtdrisco => vr_dtdrisco
                        ,pr_qtdriclq => 0
                        ,pr_nrdgrupo => 0
                        ,pr_vljura60 => 0
                        ,pr_inindris => vr_inrisco_final
                        ,pr_cdinfadi => ' '
                        ,pr_nrctrnov => 0
                        ,pr_flgindiv => 0
                        ,pr_dsinfaux => 'BNDES'
                        ,pr_dtprxpar => rw_contratos_bndes.dtvctpro
                        ,pr_vlprxpar => rw_contratos_bndes.vlparepr
                        ,pr_qtparcel => rw_contratos_bndes.qtparctr
                        ,pr_dtvencop => rw_contratos_bndes.dtfimctr
                        ,pr_vljurantpp => 0
                        ,pr_vljurparpp => 0
                        ,pr_vljurmorpp => 0
                        ,pr_vljurmulpp => 0
                        ,pr_vljuriofpp => 0
                        ,pr_vljurcorpp => 0
                        ,pr_qtdiaatr_ori => vr_qtdiaatr_ori
                        ,pr_nracordo     => 0
                        ,pr_flarrasto    => vr_flarrasto
                        ,pr_des_erro => vr_des_erro
                        ,pr_index_crapris => vr_index_crapris);

      IF vr_des_erro IS NOT NULL THEN
        vr_des_erro := 'Erro ao inserir Risco (CRAPRIS) - Conta:'||rw_contratos_bndes.nrdconta||', Dcto 3020 - Modal 0499(Desconto Duplicatas). Detalhes: ' || vr_des_erro;
        RAISE vr_exc_erro;
      END IF;     
      
      dbms_output.put_line(rw_crapcop.cdcooper||';'||rw_contratos_bndes.nrdconta||';'||rw_contratos_bndes.nrctremp||';'||rw_contratos_bndes.vlsdeved);
      
      vr_tab_vlavence(1) := rw_contratos_bndes.vlaven30;  
      vr_tab_vlavence(2) := rw_contratos_bndes.vlaven60;  
      vr_tab_vlavence(3) := rw_contratos_bndes.vlaven90;  
      vr_tab_vlavence(4) := rw_contratos_bndes.vlave180;  
      vr_tab_vlavence(5) := rw_contratos_bndes.vlave360;  
      vr_tab_vlavence(6) := rw_contratos_bndes.vlave720;   
      vr_tab_vlavence(7) := rw_contratos_bndes.vlav1080;  
      vr_tab_vlavence(8) := rw_contratos_bndes.vlav1440;  
      vr_tab_vlavence(9) := rw_contratos_bndes.vlav1800;  
      vr_tab_vlavence(10) := rw_contratos_bndes.vlav5400; 
      vr_tab_vlavence(11) := rw_contratos_bndes.vlaa5400; 
      vr_tab_vlavence(12) := rw_contratos_bndes.vlvenc14; 
      vr_tab_vlavence(13) := rw_contratos_bndes.vlvenc30; 
      vr_tab_vlavence(14) := rw_contratos_bndes.vlvenc60; 
      vr_tab_vlavence(15) := rw_contratos_bndes.vlvenc90; 
      vr_tab_vlavence(16) := rw_contratos_bndes.vlven120; 
      vr_tab_vlavence(17) := rw_contratos_bndes.vlven150;  
      vr_tab_vlavence(18) := rw_contratos_bndes.vlven180; 
      vr_tab_vlavence(19) := rw_contratos_bndes.vlven240; 
      vr_tab_vlavence(20) := rw_contratos_bndes.vlven300; 
      vr_tab_vlavence(21) := rw_contratos_bndes.vlven360; 
      vr_tab_vlavence(22) := rw_contratos_bndes.vlven540; 
      vr_tab_vlavence(23) := rw_contratos_bndes.vlvac540; 
      
      FOR vr_ind IN vr_tab_vlavence.FIRST..vr_tab_vlavence.LAST LOOP
        IF NOT vr_tab_vlavence.EXISTS(vr_ind) OR vr_tab_vlavence(vr_ind) = 0  THEN
          CONTINUE;
        END IF;
        vr_diasvenc := vr_tab_ddavence(vr_ind);
        vr_cdvencto := GESTAODERISCO.calcularCodigoVencimento(pr_diasvenc => vr_diasvenc);
        
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, vr_inrisco_final,
                  0499, rw_contratos_bndes.nrctremp, vr_nrseqctr, vr_cdvencto, vr_tab_vlavence(vr_ind));
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('1 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END LOOP;
      
      IF rw_contratos_bndes.vlprej12 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, vr_inrisco_final,
                  0499, rw_contratos_bndes.nrctremp, vr_nrseqctr, 310, rw_contratos_bndes.vlprej12);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('2 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
      IF rw_contratos_bndes.vlprej48 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, vr_inrisco_final,
                  0499, rw_contratos_bndes.nrctremp, vr_nrseqctr, 320, rw_contratos_bndes.vlprej48);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('3 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
      IF rw_contratos_bndes.vlprac48 <> 0 THEN
        BEGIN
          INSERT INTO cecred.crapvri(cdcooper, nrdconta, dtrefere, innivris, 
                                     cdmodali, nrctremp, nrseqctr, cdvencto, vldivida)
          VALUES (rw_crapcop.cdcooper, rw_contratos_bndes.nrdconta, vr_dtrefere, vr_inrisco_final,
                  0499, rw_contratos_bndes.nrctremp, vr_nrseqctr, 330, rw_contratos_bndes.vlprac48);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('4 - Erro ao inserir vri - Cooper: ' || rw_crapcop.cdcooper || ' Conta: ' || rw_contratos_bndes.nrdconta || ' Contrato: ' || rw_contratos_bndes.nrctremp || ' Vencimento: ' || vr_cdvencto || ' - ' || SQLERRM);
        END;
      END IF;
      
    END LOOP;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
  
    IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := obterCritica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    sistema.Gravarlogprograma(pr_cdcooper      => 3,
                              pr_ind_tipo_log  => 3,
                              pr_des_log       => vr_cdprograma||' -> PROGRAMA COM ERRO ' || vr_dscritic,
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);      
  
  
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_cdcooper => 3, 
                           pr_compleme => SQLERRM);
                           
    ROLLBACK;
                               
    sistema.Gravarlogprograma(pr_cdcooper      => 3,
                              pr_ind_tipo_log  => 3,
                              pr_des_log       => vr_cdprograma||' -> PROGRAMA COM ERRO ' || SQLERRM,
                              pr_cdprograma    => vr_cdprograma,
                              pr_tpexecucao    => 1);    
        
END;
