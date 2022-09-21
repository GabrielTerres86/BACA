BEGIN
  UPDATE cecred.tbrisco_operacoes SET flintegrar_sas = 1 WHERE cdcooper = 9 AND nrdconta = 247332 AND nrctremp = 50561;
  UPDATE cecred.tbrisco_operacoes SET flintegrar_sas = 1 WHERE cdcooper = 9 AND nrdconta = 320331 AND nrctremp = 53063;
  UPDATE cecred.tbrisco_operacoes SET flintegrar_sas = 1 WHERE cdcooper = 9 AND nrdconta = 320331 AND nrctremp = 52646;
  UPDATE cecred.tbrisco_operacoes SET flintegrar_sas = 1 WHERE cdcooper = 9 AND nrdconta = 320331 AND nrctremp = 24929;

  COMMIT;
END;
