BEGIN

  UPDATE cecred.crapepr
     SET txmensal = 1.22, txjuremp = 0.0004043
   WHERE progress_recid = 798985;

  UPDATE cecred.crawepr
     SET txminima = 1.22, txbaspre = 1.22, txdiaria = 0.0004043
   WHERE progress_recid = 810876;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
