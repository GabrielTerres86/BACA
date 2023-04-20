BEGIN
  UPDATE cecred.craprda
     SET insaqtot = 1
   WHERE cdcooper = 1
     AND nrdconta = 91315212
     AND nraplica = 1;
  COMMIT;
WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0265670');
    ROLLBACK;    
END;     
