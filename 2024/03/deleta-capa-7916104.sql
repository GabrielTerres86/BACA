BEGIN
  DELETE FROM CECRED.crawepr
   WHERE cdcooper = 1
         AND nrdconta = 12421332
         AND nrctremp = 7916104;

  DELETE FROM CECRED.crapprp
   WHERE cdcooper = 1
         AND nrdconta = 12421332
         AND nrctrato = 7916104;

  DELETE FROM CECRED.tbepr_renegociacao
   WHERE cdcooper = 1
         AND nrdconta = 12421332
         AND nrctremp = 7916104;

  DELETE FROM CECRED.tbepr_renegociacao_contrato
   WHERE cdcooper = 1
         AND nrdconta = 12421332
         AND nrctremp = 7916104;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
