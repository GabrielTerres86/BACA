PL/SQL Developer Test script 3.0
396
-- Created on 14/05/2020 by F0030344 
DECLARE  
  -- Local variables here
  vr_erro EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_nmdcampo VARCHAR2(400);
  vr_des_erro VARCHAR2(4000);
  
  CURSOR cr_crapdat(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT *
      FROM crapdat d
     WHERE d.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
BEGIN 
  
--INC0042802

  OPEN cr_crapdat(pr_cdcooper => 10);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 35904;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 10
                                          , pr_nrdconta => 35904
                                          , pr_vldcotas => 54.94
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 5
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = '09/01/2015'
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 35904;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;

--INC0042432 
OPEN cr_crapdat(pr_cdcooper => 5);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 11835;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 5
                                          , pr_nrdconta => 11835
                                          , pr_vldcotas => 0
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 1
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = rw_crapdat.dtmvtolt
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 11835;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END; 
  
--INC0042414
  --ACENTRA
  --13293

  OPEN cr_crapdat(pr_cdcooper => 5);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 13293;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 5
                                          , pr_nrdconta => 13293
                                          , pr_vldcotas => 0
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 1
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = TO_DATE('26/04/2002','DD/MM/RRRR')
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 13293;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;

--INC0042141
--43141 e 80403
--CREDICOMIN

  OPEN cr_crapdat(pr_cdcooper => 10);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 43141;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 10
                                          , pr_nrdconta => 43141
                                          , pr_vldcotas => 0
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 5
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = '06/04/2017'
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 43141;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;

  BEGIN
    DELETE 
      FROM tbtaa_limite_saque s
     WHERE s.cdcooper = 10
       AND s.nrdconta = 43141;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_erro;
  END;

  OPEN cr_crapdat(pr_cdcooper => 10);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 80403;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 10
                                          , pr_nrdconta => 80403
                                          , pr_vldcotas => 0
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 5
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = '07/03/2019'
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 10
       AND a.nrdconta = 80403;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;

  BEGIN
    DELETE 
      FROM tbtaa_limite_saque s
     WHERE s.cdcooper = 10
       AND s.nrdconta = 80403;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_erro;
  END;
 
  
--5 ACENTRA 
--64955
--INC0042258
  
  OPEN cr_crapdat(pr_cdcooper => 5);
  FETCH cr_crapdat INTO rw_crapdat;
  
  IF cr_crapdat%NOTFOUND THEN
     CLOSE cr_crapdat;
     RAISE vr_erro;
  END IF;
  
  CLOSE cr_crapdat;


  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = NULL --09/01/2015
          ,a.cdsitdct = 1 --4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 64955;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;  
  
  cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => 5
                                          , pr_nrdconta => 64955
                                          , pr_vldcotas => 0
                                          , pr_formadev => 1
                                          , pr_qtdparce => 1
                                          , pr_datadevo => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_mtdemiss => 2
                                          , pr_dtdemiss => TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') 
                                          , pr_idorigem => 1
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 100
                                          , pr_nmdatela => 'ATENDA'
                                          , pr_cdagenci => 1
                                          , pr_oporigem => 1 --Desligar
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic
                                          , pr_nmdcampo => vr_nmdcampo 
                                          , pr_des_erro => vr_des_erro);



  BEGIN
    UPDATE crapass a
       SET a.dtdemiss = TO_DATE('06/07/2017','DD/MM/RRRR')
          ,a.cdsitdct = 4
     WHERE a.cdcooper = 5
       AND a.nrdconta = 64955;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE vr_erro;
  END;
  
  BEGIN
    DELETE 
      FROM tbtaa_limite_saque s
     WHERE s.cdcooper = 5
       AND s.nrdconta = 64955;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_erro;
  END;

  COMMIT;
  
EXCEPTION
  WHEN vr_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
      
END;
0
0
