DECLARE
  
  TYPE typ_reg_principal IS
  RECORD( cdcooper  crappep.cdcooper%TYPE
         ,nrdconta  crappep.nrdconta%TYPE
         ,nrctremp  crappep.nrctremp%TYPE
         ,qtdiaatr  crapris.qtdiaatr%TYPE
         ,dtrefere  crapris.dtrefere%TYPE     
         ,vlempres  crapvri.vlempres%TYPE 
         );
  TYPE typ_tab_principal_bulk IS TABLE OF typ_reg_principal INDEX BY PLS_INTEGER;
  TYPE typ_tab_cr_principal IS TABLE OF typ_reg_principal INDEX BY VARCHAR2(25); 
  vr_tab_cr_principal typ_tab_cr_principal;
  vr_tab_cr_principal_bulk typ_tab_principal_bulk;
  idx_principal VARCHAR2(25);
  
  CURSOR cr_principal IS
    SELECT r.cdcooper
          ,r.nrdconta
          ,r.nrctremp
          ,r.qtdiaatr
          ,r.dtrefere
          ,(SELECT DECODE(SUM(vlempres),0,SUM(v.vldivida),SUM(vlempres))
              FROM crapvri v 
             WHERE v.cdcooper = r.cdcooper 
               AND v.nrdconta = r.nrdconta 
               AND v.nrctremp = r.nrctremp 
               AND v.dtrefere = r.dtrefere
           ) as vlempres
      FROM cecred.crapris r
          ,cecred.crapdat d
          ,cecred.crapcop c
          ,gestaoderisco.tbrisco_juros_emprestimo j
     WHERE d.cdcooper = r.cdcooper
       AND r.dtrefere = d.dtmvcentral
       AND r.cdcooper = c.cdcooper
       AND r.cdmodali IN (299,499)
       AND r.inddocto = 1
       AND r.cdorigem = 3
       AND c.cdcooper = 5
       AND j.cdcooper = r.cdcooper
       AND j.nrdconta = r.nrdconta
       AND j.nrctremp = r.nrctremp
       AND j.dtrefere = r.dtrefere
       AND j.vlemprst = 0;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN

 vr_tab_cr_principal_bulk.DELETE;
 OPEN cr_principal;
 FETCH cr_principal BULK COLLECT INTO vr_tab_cr_principal_bulk;
 CLOSE cr_principal;

 IF vr_tab_cr_principal_bulk.count > 0 THEN 
  BEGIN
    FORALL idx in vr_tab_cr_principal_bulk.first .. vr_tab_cr_principal_bulk.last SAVE EXCEPTIONS  
      UPDATE gestaoderisco.tbrisco_juros_emprestimo
         SET vlemprst = nvl(vr_tab_cr_principal_bulk(idx).vlempres,0)
       WHERE cdcooper = vr_tab_cr_principal_bulk(idx).cdcooper
         AND nrdconta = vr_tab_cr_principal_bulk(idx).nrdconta
         AND nrctremp = vr_tab_cr_principal_bulk(idx).nrctremp
         AND dtrefere = vr_tab_cr_principal_bulk(idx).dtrefere;
    EXCEPTION
    WHEN OTHERS 
    THEN
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
    LOOP
       dbms_output.put_line('Erro ao atualizar registro - Cooper: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).cdcooper || ' Conta: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrdconta || ' Contrato: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrctremp);
    END LOOP;
  END;
 END IF;
 COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
