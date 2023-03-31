DECLARE
  
  TYPE typ_reg_principal IS
  RECORD( cdcooper  crappep.cdcooper%TYPE
         ,nrdconta  crappep.nrdconta%TYPE
         ,nrctremp  crappep.nrctremp%TYPE
         ,qtdiaatr  crapris.qtdiaatr%TYPE
         ,inprejuz  crapepr.inprejuz%TYPE
         ,dtrefere  crapris.dtrefere%TYPE     
         ,vljura60  crapris.vljura60%TYPE 
         ,vlmrapar60 crapris.vlmrapar60%TYPE 
         ,vljuremu60 crapris.vljuremu60%TYPE 
         ,vljurcor60 crapris.vljurcor60%TYPE 
         ,vljurantpp crapris.vljurantpp%TYPE 
         ,vljurparpp crapris.vljurparpp%TYPE 
         ,vljurmorpp crapris.vljurmorpp%TYPE 
         ,vljurmulpp crapris.vljurmulpp%TYPE 
         ,vljurcorpp crapris.vljurcorpp%TYPE 
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
          ,e.inprejuz
          ,r.dtrefere
          ,r.vljura60
          ,r.vlmrapar60
          ,r.vljuremu60
          ,r.vljurcor60
          ,r.vljurantpp
          ,r.vljurparpp
          ,r.vljurmorpp
          ,r.vljurmulpp
          ,r.vljurcorpp,
           (SELECT SUM(vlempres) 
              FROM crapvri v 
             WHERE v.cdcooper = r.cdcooper 
               AND v.nrdconta = r.nrdconta 
               AND v.nrctremp = r.nrctremp 
               AND v.dtrefere = r.dtrefere
           ) as vlempres
      FROM cecred.crapris r
          ,cecred.crapdat d
          ,cecred.crapepr e
          ,cecred.crapcop c
     WHERE d.cdcooper = r.cdcooper
       AND r.dtrefere = d.dtmvcentral
       AND e.cdcooper = r.cdcooper
       AND e.nrdconta = r.nrdconta
       AND e.nrctremp = r.nrctremp
       AND c.flgativo = 1
       AND r.cdcooper = c.cdcooper
       AND r.cdmodali IN (299,499)
       AND r.inddocto = 1
       AND r.cdorigem = 3
       AND c.flgativo = 1;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
 
 DELETE FROM gestaoderisco.tbrisco_juros_emprestimo;
 
 vr_tab_cr_principal_bulk.DELETE;
 OPEN cr_principal;
 FETCH cr_principal BULK COLLECT INTO vr_tab_cr_principal_bulk;
 CLOSE cr_principal;
 
 IF vr_tab_cr_principal_bulk.count > 0 THEN 
  BEGIN
  FORALL idx in vr_tab_cr_principal_bulk.first .. vr_tab_cr_principal_bulk.last SAVE EXCEPTIONS  
        INSERT INTO gestaoderisco.tbrisco_juros_emprestimo(cdcooper,
                                                           nrdconta,
                                                           nrctremp,
                                                           dtrefere,
                                                           qtdiaatr,
                                                           tpprejuz,
                                                           vljura60,
                                                           vlmrapar60,
                                                           vljuremu60,
                                                           vljurcor60,
                                                           vljurantpp,
                                                           vljurparpp,
                                                           vljurmorpp,
                                                           vljurmulpp,
                                                           vljurcorpp,
                                                           vlemprst)
                                                   VALUES (vr_tab_cr_principal_bulk(idx).cdcooper,
                                                           vr_tab_cr_principal_bulk(idx).nrdconta,
                                                           vr_tab_cr_principal_bulk(idx).nrctremp,
                                                           vr_tab_cr_principal_bulk(idx).dtrefere,
                                                           vr_tab_cr_principal_bulk(idx).qtdiaatr,
                                                           vr_tab_cr_principal_bulk(idx).inprejuz,
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljura60,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vlmrapar60,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljuremu60,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurcor60,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurantpp,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurparpp,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurmorpp,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurmulpp,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vljurcorpp,0),
                                                           nvl(vr_tab_cr_principal_bulk(idx).vlempres,0)
                                                           );
    EXCEPTION
    WHEN OTHERS 
    THEN
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
    LOOP
       dbms_output.put_line('Erro ao inserir registro - Cooper: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).cdcooper || ' Conta: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrdconta || ' Contrato: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrctremp);
    END LOOP;
  END;
 END IF;
 COMMIT;
  
END;
