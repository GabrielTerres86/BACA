DECLARE

  CURSOR cr_crawseg IS
    SELECT cdcooper, nrdconta, nrctrseg, nrctrato
      FROM cecred.crawseg w 
     WHERE LENGTH(TRIM(TRANSLATE(w.nrcpfcgc, '0123456789',' '))) <> 0;
  rw_crawseg cr_crawseg%ROWTYPE;
  
  CURSOR cr_crapttl(p_cdcooper IN cecred.crapttl.cdcooper%TYPE,
                    p_nrdconta IN cecred.crapttl.nrdconta%TYPE) IS
    SELECT t.nrcpfcgc
      FROM cecred.crapttl t
     WHERE t.cdcooper = p_cdcooper
       AND t.nrdconta = p_nrdconta;
  rw_crapttl cr_crapttl%ROWTYPE;
  
  CURSOR cr_crapass(p_cdcooper IN cecred.crapass.cdcooper%TYPE,
                    p_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT p.nrcpfcgc
      FROM cecred.crapass p
     WHERE p.cdcooper = p_cdcooper
       AND p.nrdconta = p_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  
  FOR rw_crawseg IN cr_crawseg LOOP

    OPEN cr_crapttl(p_cdcooper => rw_crawseg.cdcooper,
                    p_nrdconta => rw_crawseg.nrdconta);
    FETCH cr_crapttl INTO rw_crapttl;
    IF cr_crapttl%FOUND THEN
      
      UPDATE cecred.crawseg 
         SET nrcpfcgc = rw_crapttl.nrcpfcgc
       WHERE cdcooper = rw_crawseg.cdcooper
         AND nrdconta = rw_crawseg.nrdconta
         AND nrctrseg = rw_crawseg.nrctrseg
         AND nrctrato = rw_crawseg.nrctrato; 
    
    ELSE
      
      OPEN cr_crapass(p_cdcooper => rw_crawseg.cdcooper,
                      p_nrdconta => rw_crawseg.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        
        UPDATE cecred.crawseg 
           SET nrcpfcgc = rw_crapass.nrcpfcgc
         WHERE cdcooper = rw_crawseg.cdcooper
           AND nrdconta = rw_crawseg.nrdconta
           AND nrctrseg = rw_crawseg.nrctrseg
           AND nrctrato = rw_crawseg.nrctrato;
    
      END IF;
      CLOSE cr_crapass;
    END IF;  
    CLOSE cr_crapttl;    
  
  END LOOP;
  COMMIT;
END;
