BEGIN

  DELETE CECRED.tbepr_renegociacao where cdcooper = 5 and nrdconta = 117358 and nrctremp = 80131;
  DELETE CECRED.tbepr_renegociacao_contrato where cdcooper = 5 and nrdconta = 117358 and nrctremp = 80131;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
