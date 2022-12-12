BEGIN

  UPDATE CECRED.tbepr_renegociacao_contrato
     SET nrversao = 1
   WHERE cdcooper = 1 
   AND nrdconta = 12366854 
   AND nrctrepr = 5402552;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
