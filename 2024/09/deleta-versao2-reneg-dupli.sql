BEGIN

  DELETE FROM cecred.tbepr_renegociacao_crapepr
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 7566571
         AND nrversao = 2;

  DELETE FROM cecred.tbepr_renegociacao_crawepr
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 7566571
         AND nrversao = 2;

  DELETE FROM cecred.tbepr_renegociacao_craplem
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 7566571
         AND nrversao = 2;

  DELETE FROM cecred.tbepr_renegociacao_crappep
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 7566571
         AND nrversao = 2;

  DELETE FROM cecred.tbepr_renegociacao
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 8579589;

  DELETE FROM cecred.tbepr_renegociacao_contrato
   WHERE cdcooper = 1
         AND nrdconta = 11520655
         AND nrctremp = 8579589;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
