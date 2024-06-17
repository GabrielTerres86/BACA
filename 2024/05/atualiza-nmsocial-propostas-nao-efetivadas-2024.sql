DECLARE
 CURSOR cr_crapttl(pr_cdcooper IN cecred.crapttl.cdcooper%TYPE,
                   pr_nrdconta IN cecred.crapttl.nrdconta%TYPE) IS
   SELECT UPPER(TRIM(t.nmsocial)) nmsocial
     FROM cecred.crapttl t
    WHERE t.cdcooper = pr_cdcooper
      AND t.nrdconta = pr_nrdconta
      AND trim(t.nmsocial) IS NOT NULL; 
 rw_crapttl cr_crapttl%ROWTYPE;
 
 CURSOR cr_crawseg IS
   SELECT w.cdcooper, w.nrdconta, w.nrctrseg, w.nrctrato 
    FROM cecred.crawseg w,
         cecred.crawepr e
   WHERE w.tpseguro = 4
     AND w.cdcooper = e.cdcooper
     AND w.nrdconta = e.nrdconta
     AND w.nrctrato = e.nrctremp
     AND to_char(w.dtinivig,'yyyy') = '2024'
     AND NOT EXISTS (SELECT 1
                       FROM cecred.crapseg s
                      WHERE s.cdcooper = w.cdcooper
                        AND s.nrdconta = w.nrdconta
                        AND s.nrctrseg = w.nrctrseg)
   ORDER BY 1,2;  
 vr_count NUMBER := 0;                    
BEGIN                     
   FOR rw_crawseg IN cr_crawseg LOOP
     
     OPEN cr_crapttl(rw_crawseg.cdcooper,
                     rw_crawseg.nrdconta);
     FETCH cr_crapttl
       INTO rw_crapttl;
     IF cr_crapttl%FOUND THEN       
     
       vr_count := vr_count + 1;  
        
        UPDATE cecred.crawseg w
           SET w.nmsocial_segurado = rw_crapttl.nmsocial
         WHERE w.cdcooper = rw_crawseg.cdcooper
           AND w.nrdconta = rw_crawseg.nrdconta
           AND w.nrctrseg = rw_crawseg.nrctrseg
           AND w.nrctrato = rw_crawseg.nrctrato;
        
       IF vr_count = 1000 THEN
        vr_count := 0;
        COMMIT;
      END IF;
     
     END IF;
     CLOSE cr_crapttl; 
    
  END LOOP;
 COMMIT;
END;
