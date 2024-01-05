BEGIN

  UPDATE cecred.crapepr
     SET txmensal = 1.57, txjuremp = 0.0005194
   WHERE progress_recid = 924882;

  UPDATE cecred.crapepr
     SET txmensal = 1.69, txjuremp = 0.0005588
   WHERE progress_recid = 1106594;

  UPDATE cecred.crapepr
     SET txmensal = 1.69, txjuremp = 0.0005588
   WHERE progress_recid = 1104876;

  UPDATE cecred.crapepr
     SET txmensal = 1.22, txjuremp = 0.0004043
   WHERE progress_recid = 798985;

  UPDATE cecred.crawepr
     SET txminima = 1.57, txbaspre = 1.57, txdiaria = 0.0005194
   WHERE progress_recid = 942193;

  UPDATE cecred.crawepr
     SET txminima = 1.69, txbaspre = 1.69, txdiaria = 0.0005588
   WHERE progress_recid = 1163958;

  UPDATE cecred.crawepr
     SET txminima = 1.69, txbaspre = 1.69, txdiaria = 0.0005588
   WHERE progress_recid = 1164732;

  UPDATE cecred.crawepr
     SET txminima = 1.22, txbaspre = 1.22, txdiaria = 0.0004043
   WHERE progress_recid = 810876;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
