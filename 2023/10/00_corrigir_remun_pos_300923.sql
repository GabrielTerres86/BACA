DECLARE
  vr_dtrefere DATE := to_date('30/09/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT a.cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                     ,pr_dtrefere IN cecred.crapdat.dtmvtolt%TYPE) IS
    SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.vljurparpp
      FROM cecred.crapris r
          ,GESTAODERISCO.tbrisco_juros_emprestimo j
          ,cecred.crapepr e
     WHERE r.cdcooper = j.cdcooper
       AND r.nrdconta = j.nrdconta
       AND r.nrctremp = j.nrctremp
       AND r.dtrefere = j.dtrefere
       AND e.cdcooper = r.cdcooper 
       AND e.nrdconta = r.nrdconta 
       AND e.nrctremp = r.nrctremp 
       AND e.tpemprst = 2
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.vljurparpp > 0
       AND r.vljurparpp <> j.vljurparpp;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtrefere => vr_dtrefere) LOOP
      BEGIN
        UPDATE GESTAODERISCO.tbrisco_juros_emprestimo j
           SET vljurparpp = rw_principal.vljurparpp
         WHERE cdcooper = rw_principal.cdcooper
           AND nrdconta = rw_principal.nrdconta
           AND nrctremp = rw_principal.nrctremp
           AND dtrefere = vr_dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar conta: ' || rw_principal.nrdconta || ' contrato: ' || rw_principal.nrctremp || ' - ' || SQLERRM);
      END;
    END LOOP;
    
    COMMIT;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
