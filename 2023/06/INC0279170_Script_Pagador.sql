BEGIN

  UPDATE cecred.crapsab s
     SET s.cdtpinsc = 1
   WHERE s.cdcooper = 2
     AND s.nrdconta = 16734882
     AND s.nrinssac = 29223113920;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => SQLERRM);
END;
