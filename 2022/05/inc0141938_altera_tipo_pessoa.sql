BEGIN

  UPDATE crapsab sab
     SET sab.cdtpinsc = 1, sab.nrinssac = '92888569000'
   WHERE sab.cdcooper = 7
     AND sab.cdtpinsc = 2 
     AND sab.nrdconta = 161187     
     AND sab.nrinssac = '124385966,00';
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_compleme => 'INC0141938');
    raise_application_error(-20500, SQLERRM);
  
END;