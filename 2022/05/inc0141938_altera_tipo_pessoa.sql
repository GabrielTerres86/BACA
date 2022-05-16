BEGIN

  UPDATE crapsab sab
     SET sab.cdtpinsc = 1 /* Pessoa Fisica */
   WHERE sab.cdcooper = 7
     AND sab.cdtpinsc = 2 /* Pessoa Juridica */
     AND sab.nrdconta = 161187     
     AND sab.nrinssac = 92888569000;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
  
END;
