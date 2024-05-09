DECLARE
  CURSOR cr_crapass(pr_cdcooper cecred.crapass.cdcooper%TYPE
                   ,pr_nrcadast cecred.crapass.nrcadast%TYPE) IS
    SELECT b.nrdconta
      FROM cecred.crapass b
     WHERE b.cdcooper = pr_cdcooper
       AND b.nrcadast = pr_nrcadast;
  rw_crapass cr_crapass%ROWTYPE;

  CURSOR cr_crapcop IS
    SELECT a.cdcooper
      FROM crapcop a
     WHERE a.flgativo = 1
     ORDER BY a.cdcooper;

  CURSOR cr_crapprm(pr_cdcooper IN cecred.crapprm.cdcooper%TYPE) IS
    SELECT a.cdcooper
          ,a.dsvlrprm
      FROM cecred.crapprm a
     WHERE a.cdacesso = 'ACORDO_NRCONVEN'
       AND a.cdcooper = pr_cdcooper
     ORDER BY 1;
  rw_crapprm cr_crapprm%ROWTYPE;

  CURSOR cr_crapneg(pr_cdcooper IN cecred.crapneg.cdcooper%TYPE) IS
    SELECT 'CRAPNEG'  nmtabela
          ,'NRSEQDIG' nmdcampo
          ,a.cdcooper || ';' || a.nrdconta dsdchave
          ,MAX(a.nrseqdig) nrseqatu
      FROM crapneg a
     WHERE a.cdcooper = pr_cdcooper
     GROUP BY a.cdcooper
             ,a.nrdconta;

  TYPE typ_crapneg IS TABLE OF cr_crapneg%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapneg typ_crapneg;

  vr_cdcooper cecred.crapass.cdcooper%TYPE := 3;
  vr_nrctaant cecred.crapass.nrdconta%TYPE := 850004;
  vr_nrctanov cecred.crapass.nrdconta%TYPE;
BEGIN    
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrcadast => vr_nrctaant);
  FETCH cr_crapass
    INTO rw_crapass;

  IF cr_crapass%FOUND THEN
    vr_nrctanov := rw_crapass.nrdconta;
  
    UPDATE cecred.crapprm a
       SET a.dsvlrprm = vr_nrctanov
     WHERE a.cdacesso = 'COBEMP_NRDCONTA_BNF';
    COMMIT;
  
    FOR rw_crapcop IN cr_crapcop LOOP
      OPEN cr_crapprm(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH cr_crapprm
        INTO rw_crapprm;
    
      IF cr_crapprm%FOUND THEN
        UPDATE cecred.crapsqu b
           SET b.dsdchave = rw_crapprm.cdcooper || ';' || 
                            vr_nrctanov         || ';' || 
                            rw_crapprm.dsvlrprm || ';' ||
                            rw_crapprm.dsvlrprm || ';85'
         WHERE UPPER(b.nmtabela) = 'CRAPCOB'
           AND UPPER(b.nmdcampo) = 'NRDOCMTO'
           AND UPPER(b.dsdchave) = rw_crapprm.cdcooper || ';' || 
                                   vr_nrctaant         || ';' ||
                                   rw_crapprm.dsvlrprm || ';' || 
                                   rw_crapprm.dsvlrprm || ';85';
        COMMIT;
      END IF;
      CLOSE cr_crapprm;
    END LOOP;
  
    FOR rw_crapcop IN cr_crapcop LOOP
      OPEN cr_crapneg(pr_cdcooper => rw_crapcop.cdcooper);
      LOOP
        FETCH cr_crapneg BULK COLLECT
          INTO vr_tab_crapneg LIMIT 5000;
        EXIT WHEN vr_tab_crapneg.count = 0;
      
        FORALL vr_nrindice IN INDICES OF vr_tab_crapneg
          MERGE INTO cecred.crapsqu des
          USING (SELECT vr_tab_crapneg(vr_nrindice).nmtabela nmtabela
                       ,vr_tab_crapneg(vr_nrindice).nmdcampo nmdcampo
                       ,vr_tab_crapneg(vr_nrindice).dsdchave dsdchave
                   FROM dual) ori
          ON (UPPER(des.nmtabela) = ori.nmtabela 
          AND UPPER(des.nmdcampo) = ori.nmdcampo 
          AND UPPER(des.dsdchave) = ori.dsdchave)
          
          WHEN MATCHED THEN
            UPDATE
               SET nrseqatu = vr_tab_crapneg(vr_nrindice).nrseqatu
          WHEN NOT MATCHED THEN
            INSERT
              (nmtabela
              ,nmdcampo
              ,dsdchave
              ,nrseqatu)
            VALUES
              (vr_tab_crapneg(vr_nrindice).nmtabela
              ,vr_tab_crapneg(vr_nrindice).nmdcampo
              ,vr_tab_crapneg(vr_nrindice).dsdchave
              ,vr_tab_crapneg(vr_nrindice).nrseqatu);
        COMMIT;
      END LOOP;
      CLOSE cr_crapneg;
    END LOOP;
  END IF;
  CLOSE cr_crapass;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
