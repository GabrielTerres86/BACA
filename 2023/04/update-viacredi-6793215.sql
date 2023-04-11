BEGIN

  UPDATE CECRED.tbepr_renegociacao_contrato
     SET nrversao = 1
   WHERE cdcooper = 1
         AND nrdconta = 3779815
         AND nrctremp = 6793215;

  DELETE FROM CECRED.tbepr_renegociacao
   WHERE cdcooper = 1
         AND nrdconta = 3779815
         AND nrctremp IN (6793217, 6793219);

  DELETE FROM CECRED.tbepr_renegociacao_contrato
   WHERE cdcooper = 1
         AND nrdconta = 3779815
         AND nrctremp IN (6793217, 6793219);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
