BEGIN
  UPDATE crapaut aut 
     SET aut.dtmvtolt = to_date('10/01/2022','dd/mm/yyyy'),
         aut.nrsequen = 202856,
         aut.vldocmto = 2319.90
   WHERE aut.cdcooper = 1 
     AND aut.nrdcaixa = 900 
     AND aut.cdagenci = 90 
     AND aut.vldocmto = 231990.00
     AND aut.dtmvtolt = to_date('06/01/2022','dd/mm/yyyy');
     
     COMMIT;
END;