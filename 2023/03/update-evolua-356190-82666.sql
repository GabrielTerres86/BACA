BEGIN

  UPDATE tbepr_renegociacao_craplem
     SET vllanmto = 0.2
   WHERE progress_recid = 330273211;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
