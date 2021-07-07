BEGIN
  DELETE FROM credito.tbepr_renegociacao_contrato_simula WHERE idsimula = 999;
  DELETE FROM credito.tbepr_renegociacao_simula WHERE idsimula = 999;
  DELETE FROM cecred.crawepr WHERE cdcooper = 13 AND nrdconta = 533564 AND nrctremp = 126678;
  DELETE FROM cecred.crapprp WHERE cdcooper = 13 AND nrdconta = 533564 AND nrctrato = 126678;
  DELETE FROM cecred.tbepr_renegociacao WHERE cdcooper = 13 AND nrdconta = 533564 AND nrctremp = 126678;
  DELETE FROM cecred.tbepr_renegociacao_contrato WHERE cdcooper = 13 AND nrdconta = 533564 AND nrctremp = 126678;
  
  COMMIT;
END;
