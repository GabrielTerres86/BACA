DECLARE
  CURSOR cr_crapprm(pr_cdcooper IN cecred.crapprm.cdcooper%TYPE) IS
    SELECT a.cdcooper
          ,a.dsvlrprm
      FROM cecred.crapprm a
     WHERE a.cdacesso = 'ACORDO_NRCONVEN'
       AND a.cdcooper = pr_cdcooper
     ORDER BY 1;
  rw_crapprm cr_crapprm%ROWTYPE;

  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 3;
  vr_nrdctaat cecred.crapass.nrdconta%TYPE := 850004;
  vr_nrdctanv cecred.crapass.nrdconta%TYPE;
  vr_dsvlrprm cecred.crapprm.dsvlrprm%TYPE;
  vr_dsdchave cecred.crapsqu.dsdchave%TYPE;
  vr_qtregdel NUMBER;
  vr_qtregins NUMBER;
BEGIN
  SELECT b.nrdconta
    INTO vr_nrdctanv
    FROM cecred.crapass b
   WHERE b.cdcooper = vr_cdcooper
     AND b.nrcadast = vr_nrdctaat;

  UPDATE cecred.crapprm a
     SET a.dsvlrprm = vr_nrdctanv
   WHERE a.cdacesso = 'COBEMP_NRDCONTA_BNF'
     AND a.cdcooper = 9
  RETURNING a.dsvlrprm INTO vr_dsvlrprm;
  COMMIT;

  OPEN cr_crapprm(pr_cdcooper => 9);
  FETCH cr_crapprm
    INTO rw_crapprm;
  CLOSE cr_crapprm;

  UPDATE cecred.crapsqu b
     SET b.dsdchave = rw_crapprm.cdcooper || ';' || 
                      vr_nrdctanv         || ';' || 
                      rw_crapprm.dsvlrprm || ';' ||
                      rw_crapprm.dsvlrprm || ';85'
   WHERE b.nmtabela = 'CRAPCOB'
     AND b.nmdcampo = 'NRDOCMTO'
     AND b.dsdchave LIKE rw_crapprm.cdcooper || ';%;' || 
                         rw_crapprm.dsvlrprm || ';' || 
                         rw_crapprm.dsvlrprm || ';85'
  RETURNING b.dsdchave INTO vr_dsdchave;
  COMMIT;

  DELETE FROM cecred.crapsqu a
   WHERE a.nmtabela = 'CRAPNEG'
     AND a.nmdcampo = 'NRSEQDIG'
     AND a.dsdchave LIKE 9 || ';%';
  vr_qtregdel := SQL%ROWCOUNT;
  COMMIT;

  INSERT INTO cecred.crapsqu
    (SELECT 'CRAPNEG' nmtabela
           ,'NRSEQDIG' nmdcampo
           ,a.cdcooper || ';' || a.nrdconta dsdchave
           ,MAX(a.nrseqdig) nrseqatu
       FROM crapneg a
      WHERE a.cdcooper = 9
      GROUP BY a.cdcooper
              ,a.nrdconta);
  vr_qtregins := SQL%ROWCOUNT;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
