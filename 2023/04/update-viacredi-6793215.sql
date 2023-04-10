BEGIN

  UPDATE CECRED.tbepr_renegociacao_contrato
     SET nrversao = 1
   WHERE cdcooper = 1
         AND nrdconta = 3779815
         AND nrctremp = 6793215;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
