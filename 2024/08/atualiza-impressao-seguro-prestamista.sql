DECLARE
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT p.nrcpfcgc
      FROM cecred.crapass p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta;
 
  rw_crapass cr_crapass%ROWTYPE;
BEGIN                      
    FOR rw_crapttl IN (SELECT ct.progress_recid, ct.cdcooper, ct.nrdconta
                         FROM cecred.crapttl ct
                        WHERE ct.cdcooper = 1
                          AND ct.nrdconta = 91189896) LOOP
      OPEN cr_crapass(rw_crapttl.cdcooper,
                      rw_crapttl.nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%FOUND THEN        
        UPDATE cecred.crapttl ct
           SET ct.nrcpfcgc = rw_crapass.nrcpfcgc
         WHERE ct.progress_recid = rw_crapttl.progress_recid;
         UPDATE cecred.crawseg w
           SET w.nrcpfcgc = rw_crapass.nrcpfcgc
         WHERE w.cdcooper = rw_crapttl.cdcooper
           AND w.nrdconta = rw_crapttl.nrdconta;
          UPDATE cecred.tbseg_prestamista p
           SET p.nrcpfcgc = rw_crapass.nrcpfcgc
         WHERE p.cdcooper = rw_crapttl.cdcooper
           AND p.nrdconta = rw_crapttl.nrdconta;
      END IF;
      CLOSE cr_crapass;
  END LOOP;
  COMMIT;
END;
