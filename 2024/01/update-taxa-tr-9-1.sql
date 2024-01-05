BEGIN

  UPDATE cecred.crapepr SET txmensal = 1.57, txjuremp = 0.0005194 WHERE progress_recid = 924882;

  UPDATE cecred.crapepr SET txmensal = 1.69, txjuremp = 0.0005588 WHERE progress_recid = 1106594;

  UPDATE cecred.crapepr SET txmensal = 1.69, txjuremp = 0.0005588 WHERE progress_recid = 1104876;

  UPDATE cecred.crapepr SET txmensal = 1.22, txjuremp = 0.0004043 WHERE progress_recid = 798985;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
