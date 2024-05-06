BEGIN
  UPDATE crawepr SET insitapr = 1, insitest = 3 WHERE cdcooper = 14 AND nrdconta = 99791234 AND nrctremp = 133140;
  UPDATE tbrisco_operacoes SET nrctremp = 99791234 WHERE cdcooper = 14 AND nrdconta = 99791234 AND nrctremp = 208701;
  COMMIT;
END;
