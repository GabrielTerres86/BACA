BEGIN

  UPDATE cecred.crapepr
     SET dtliquid = to_date('20/07/2023', 'DD/MM/YYYY')
   WHERE cdcooper = 1
         AND nrdconta = 8353948
         AND nrctremp = 2230465;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
