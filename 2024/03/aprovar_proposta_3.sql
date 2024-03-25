BEGIN
  UPDATE crawepr SET insitapr = 1, insitest = 3 WHERE cdcooper = 14 AND nrdconta = 99760380 AND nrctremp = 133136;
  UPDATE tbrisco_operacoes SET nrctremp = 99760380 WHERE cdcooper = 14 AND nrdconta = 99760380 AND nrctremp = 239550;
  COMMIT;
END;
