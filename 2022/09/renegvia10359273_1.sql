BEGIN

   UPDATE CECRED.tbepr_renegociacao
     SET DTLIBERA = to_date('12-09-2022', 'dd-mm-yyyy')
    WHERE CDCOOPER = 1
      AND NRDCONTA = 10359273
      AND NRCTREMP = 6048117;
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;