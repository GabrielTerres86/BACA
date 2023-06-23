DECLARE 
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
  vr_progress  cecred.crapass.progress_recid%TYPE;
  vr_cdcooper  cecred.crapcop.cdcooper%TYPE;
BEGIN

  vr_cdcooper := 1;
  vr_progress := 1045843;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  vr_progress := 1151052;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  vr_progress := 1295283;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  vr_progress := 1354039;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  vr_progress := 1361681;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  vr_progress := 1399276;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;  
  
  vr_progress := 1466819;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0
          ,vljuprej = 0
          ,vljur60_ctneg = 0
          ,vljur60_lcred = 0
          ,dtliquidacao = NULL
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = rw_crapass.nrdconta;
  
    UPDATE cecred.crapsld sld
       SET vlblqprj = 0
     WHERE sld.cdcooper = vr_cdcooper
       AND sld.nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;  
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: ' || SUBSTR(SQLERRM, 1, 255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    raise_application_error(-20002, 'Erro Geral no Script. Erro: ' || SUBSTR(SQLERRM, 1, 255));
END;
