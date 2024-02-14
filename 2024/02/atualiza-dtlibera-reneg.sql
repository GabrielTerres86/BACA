BEGIN

  UPDATE cecred.tbepr_renegociacao a
     SET a.dtlibera = to_date('11/12/2023', 'dd/mm/yyyy')
   WHERE cdcooper = 1
         AND nrdconta = 3024253
         AND nrctremp = 7584420;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
