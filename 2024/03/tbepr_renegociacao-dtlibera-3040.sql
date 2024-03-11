BEGIN
  UPDATE cecred.tbepr_renegociacao a
     SET a.dtlibera = to_date('05/03/2024', 'dd/mm/yyyy')
   WHERE cdcooper = 1
         AND nrdconta = 6997791
         AND nrctremp = 7949533;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
