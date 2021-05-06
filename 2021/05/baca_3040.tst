PL/SQL Developer Test script 3.0
61
-- Created on 05/05/2021 by F0032990 
declare 
   CURSOR cr_crapvri IS 
   SELECT e.cdcooper, e.nrdconta, e.nrctremp, e.vlsdeved, r.vljura60, r.vljurantpp,r.innivris ,p.vlsdvatu, p.dtvencto, (e.vlsdeved - r.vljura60) vlempres
      FROM crapepr e, 
           crapris r,
           (select t.cdcooper, t.nrdconta, t.nrctremp, t.dtvencto, count(t.nrparepr), SUM(t.vlsdvatu) vlsdvatu
            from crappep t
            WHERE 
            (t.cdcooper = 1 AND t.nrdconta = 7384726 AND t.nrctremp = 2400528  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 6875688 AND t.nrctremp = 2265715  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 10828753 AND t.nrctremp = 2277017 AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 4084160 AND t.nrctremp = 2351756  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 1563041 AND t.nrctremp = 2238255  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 9413430 AND t.nrctremp = 2327043  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 8017263 AND t.nrctremp = 2396550  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 9923519 AND t.nrctremp = 2957659  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 9060324 AND t.nrctremp = 2291104  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 7254261 AND t.nrctremp = 2380010  AND t.inliquid = 0) or
            (t.cdcooper = 1 AND t.nrdconta = 10297189 AND t.nrctremp = 2357540 AND t.inliquid = 0) 
            GROUP BY t.cdcooper, t.nrdconta, t.nrctremp, t.dtvencto
            ) p
      WHERE e.cdcooper = r.cdcooper
        AND e.nrdconta = r.nrdconta 
        AND e.nrctremp = r.nrctremp
        AND e.cdcooper = p.cdcooper
        AND e.nrdconta = p.nrdconta 
        AND e.nrctremp = p.nrctremp
        AND r.dtrefere = to_date('30/04/2021', 'DD/MM/YYYY');
begin
   
   -- Ajustes dos contratos POS, que tiveram o seu juros +60 maior que saldo devedor do contrato.     
   FOR rw_cravri IN cr_crapvri LOOP
     BEGIN
       UPDATE crapvri r 
          SET r.vlempres = rw_cravri.vlempres
        WHERE r.cdcooper = rw_cravri.cdcooper
          AND r.nrdconta = rw_cravri.nrdconta
          AND r.nrctremp = rw_cravri.nrctremp
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('30/04/2021', 'DD/MM/YYYY');
     END;
   END LOOP;
   
   -- Ajuste do contrato PP que ficou com saldo devedor negativo no contrato
   BEGIN
     UPDATE crapris ris
        SET ris.vldivida = 0
           ,ris.vlvec180 = 0
      WHERE ris.cdcooper = 1
        AND ris.nrdconta = 2328933
        AND ris.nrctremp = 1136856
        AND ris.cdmodali IN (299,499)
        AND ris.dtrefere = to_date('30/04/2021', 'DD/MM/YYYY');
   END;
   COMMIT;
   
exception
  when others then
    ROLLBACK;  
end;
0
0
