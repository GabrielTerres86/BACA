/* INC0122627 - Ajustar tipo de pessoa para um pagador*/
BEGIN

  UPDATE crapsab sab
     SET sab.cdtpinsc = 1 /* Pessoa Fisica */
   WHERE sab.cdcooper = 1
     AND sab.cdtpinsc = 2 /* Pessoa Juridica */
     AND sab.nrdconta = 8905886     
     AND sab.nrinssac = 38065096972;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
  
END;
