PL/SQL Developer Test script 3.0
77
declare 
   CURSOR cr_crapvri IS 
     SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.vldivida FROM crapvri r 
      WHERE r.cdcooper = 1 
         AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY')
         AND r.cdmodali IN (299,499)
         AND ((r.nrdconta = 1563041  and r.nrctremp = 2238255) or
              (r.nrdconta = 2394634  and r.nrctremp = 2477279) or
              (r.nrdconta = 3923762  and r.nrctremp = 2560625) or
              (r.nrdconta = 4084160  and r.nrctremp = 2351756) or
              (r.nrdconta = 6875688  and r.nrctremp = 2265715) or
              (r.nrdconta = 7384726  and r.nrctremp = 2400528) or
              (r.nrdconta = 7765967  and r.nrctremp = 2395547) or
              (r.nrdconta = 8017263  and r.nrctremp = 2396550) or
              (r.nrdconta = 9060324  and r.nrctremp = 2291104) or
              (r.nrdconta = 9413430  and r.nrctremp = 2327043) or
              (r.nrdconta = 9923519  and r.nrctremp = 2957659) or
              (r.nrdconta = 10297189 and r.nrctremp = 2357540));

begin
   
   -- Ajustes dos contratos POS, que tiveram o seu juros +60 maior que saldo devedor do contrato.    
   -- nesse caso o vlempress e o mesmo que o vldivida (nesses casos, so existe uma unica parcela restante)
   FOR rw_cravri IN cr_crapvri LOOP
     BEGIN
       UPDATE crapvri r 
          SET r.vlempres = rw_cravri.vldivida
        WHERE r.cdcooper = rw_cravri.cdcooper
          AND r.nrdconta = rw_cravri.nrdconta
          AND r.nrctremp = rw_cravri.nrctremp
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY');
     END;
   END LOOP;
   
  -- Atualizacao de contratos de cessao de cartao que estao com o valor da divida incorreto.
  BEGIN 
    UPDATE crapvri r 
          SET r.vldivida = 0.02
        WHERE r.cdcooper = 1
          AND r.nrdconta = 10860029
          AND r.nrctremp = 2599852
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY');
   
   UPDATE crapvri r 
          SET r.vldivida = 0.12
            , r.vlempres = 0.12
        WHERE r.cdcooper = 1
          AND r.nrdconta = 8660948
          AND r.nrctremp = 2599881
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY');
    
    UPDATE crapvri r 
          SET r.vldivida = 0.01
        WHERE r.cdcooper = 1
          AND r.nrdconta = 9598340
          AND r.nrctremp = 2599857
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY');
    
    UPDATE crapvri r 
          SET r.vldivida = 930.85
        WHERE r.cdcooper = 1
          AND r.nrdconta = 6574599
          AND r.nrctremp = 1190587
          AND r.cdmodali IN (299,499)
          AND r.dtrefere = to_date('31/05/2021', 'DD/MM/YYYY');
  END;
   
  COMMIT;
   
exception
  when others then
    ROLLBACK;  
end;
0
0
