DECLARE
  vr_dtrefere CECRED.crapdat.dtmvtolt%TYPE := to_date('30/11/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM CECRED.crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE
                     ,pr_dtrefere IN CECRED.crapdat.dtmvtolt%TYPE) IS
    SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.dtrefere, r.vljurparpp
      FROM GESTAODERISCO.tbrisco_juros_emprestimo j 
          ,CECRED.crapepr e
          ,CECRED.crapris r
     WHERE e.cdcooper = j.cdcooper
       AND e.nrdconta = j.nrdconta
       AND e.nrctremp = j.nrctremp
       AND r.cdcooper = j.cdcooper
       AND r.nrdconta = j.nrdconta
       AND r.nrctremp = j.nrctremp
       AND r.dtrefere = j.dtrefere
       AND j.cdcooper = pr_cdcooper
       AND j.dtrefere = pr_dtrefere
       AND e.tpemprst = 2
       AND r.cdmodali = 299
       AND r.inddocto = 1
       AND r.vljurparpp <> j.vljurparpp;
  rw_principal cr_principal%ROWTYPE;
BEGIN
  
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = '',.''';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtrefere => vr_dtrefere) LOOP
      BEGIN 
        UPDATE GESTAODERISCO.tbrisco_juros_emprestimo
           SET vljurparpp = rw_principal.vljurparpp
         WHERE cdcooper = rw_principal.cdcooper
           AND nrdconta = rw_principal.nrdconta
           AND nrctremp = rw_principal.nrctremp
           AND dtrefere = rw_principal.dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          CONTINUE;
      END;
    END LOOP;
  COMMIT;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
