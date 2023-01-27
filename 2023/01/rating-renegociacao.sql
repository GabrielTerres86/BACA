declare 
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
  vr_cdcooper cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta cecred.crawepr.nrdconta%TYPE;
  vr_nrctremp cecred.crawepr.nrctremp%TYPE;
  vr_innivris cecred.crawepr.dsnivori%TYPE;
  vr_progress cecred.crapass.progress_recid%TYPE;
begin
  
  vr_cdcooper := 9;
  vr_nrdconta := 311995;
  vr_nrctremp := 78729;
  vr_innivris := 'C';
  vr_progress := 1199536;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 9;
  vr_nrdconta := 554944;
  vr_nrctremp := 78884;
  vr_innivris := 'D';
  vr_progress := 1802941;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 9;
  vr_nrdconta := 354490;
  vr_nrctremp := 79563;
  vr_innivris := 'A';
  vr_progress := 1303118;

  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 5;
  vr_nrdconta := 79820;
  vr_nrctremp := 96969;
  vr_innivris := 'C';
  vr_progress := 767148;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  END IF;
  CLOSE cr_crapass;
  
  vr_cdcooper := 2;
  vr_nrdconta := 506133;
  vr_nrctremp := 427252;
  vr_innivris := 'D';
  vr_progress := 798032;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_progress => vr_progress);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    UPDATE cecred.tbrisco_operacoes a 
       SET a.inrisco_rating = risc0004.fn_traduz_nivel_risco(vr_innivris)
     WHERE a.cdcooper = vr_cdcooper
       AND a.nrdconta = rw_crapass.nrdconta
       AND a.nrctremp = vr_nrctremp
       AND a.tpctrato = 90;
             
    UPDATE cecred.crawepr e
       SET e.dsnivori = vr_innivris
     WHERE e.cdcooper = vr_cdcooper
       AND e.nrdconta = rw_crapass.nrdconta 
       AND e.nrctremp = vr_nrctremp;
  END IF;
  CLOSE cr_crapass;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20510,SQLERRM);
END;
