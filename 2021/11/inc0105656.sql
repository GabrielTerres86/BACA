BEGIN 
  UPDATE crapvri v
     SET v.vlempres = v.vlempres - 200.21,
         v.vldivida = v.vldivida - 200.21
   WHERE v.cdcooper = 11
     AND v.nrdconta = 42560
     AND v.nrctremp = 95700
     AND v.dtrefere = '31/08/2021'
     AND v.cdvencto = 210;
  COMMIT;
END;
