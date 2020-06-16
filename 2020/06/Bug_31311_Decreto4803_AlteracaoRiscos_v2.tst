PL/SQL Developer Test script 3.0
23
BEGIN
  UPDATE tbrisco_operacoes o SET o.inrisco_inclusao = 4 ,o.inrisco_rating = 4 ,o.inorigem_rating = 8 ,o.innivel_rating = 0 ,o.inpontos_rating = 0 ,o.insegmento_rating = '' WHERE o.cdcooper = 6 AND o.nrdconta = 47848 AND o.nrctremp = 228846 AND o.tpctrato = 90;
  UPDATE crawepr w SET w.dsnivris = 'C' ,w.dsnivori = 'C' WHERE w.cdcooper = 6 AND w.nrdconta = 47848 AND w.nrctremp = 228846;
  risc0003.obterDecretoRiscosLog(pr_cdcooper => 6,pr_nrdconta => 47848,pr_nrctremp => 228846,pr_tiporisco => 'RAT',pr_risco_atual => 5,pr_risco_atualizado => 4,pr_registrar_verlog => 1);

  UPDATE tbrisco_operacoes o SET o.inrisco_inclusao = 2 ,o.inrisco_rating = 2 ,o.inorigem_rating = 8 ,o.innivel_rating = 0 ,o.inpontos_rating = 0 ,o.insegmento_rating = '' WHERE o.cdcooper = 6 AND o.nrdconta = 58408 AND o.nrctremp = 229104 AND o.tpctrato = 90;
  UPDATE crawepr w SET w.dsnivris = 'A' ,w.dsnivori = 'A' WHERE w.cdcooper = 6 AND w.nrdconta = 58408 AND w.nrctremp = 229104;
  risc0003.obterDecretoRiscosLog(pr_cdcooper => 6,pr_nrdconta => 58408,pr_nrctremp => 229104,pr_tiporisco => 'RAT',pr_risco_atual => 5,pr_risco_atualizado => 2,pr_registrar_verlog => 1);

  UPDATE tbrisco_operacoes o SET o.inrisco_inclusao = 2 ,o.inrisco_rating = 2 ,o.inorigem_rating = 8 ,o.innivel_rating = 0 ,o.inpontos_rating = 0 ,o.insegmento_rating = '' WHERE o.cdcooper = 6 AND o.nrdconta = 67857 AND o.nrctremp = 229095 AND o.tpctrato = 90;
  UPDATE crawepr w SET w.dsnivris = 'A' ,w.dsnivori = 'A' WHERE w.cdcooper = 6 AND w.nrdconta = 67857 AND w.nrctremp = 229095;
  risc0003.obterDecretoRiscosLog(pr_cdcooper => 6,pr_nrdconta => 67857,pr_nrctremp => 229095,pr_tiporisco => 'RAT',pr_risco_atual => 3,pr_risco_atualizado => 2,pr_registrar_verlog => 1);

  UPDATE tbrisco_operacoes o SET o.inrisco_inclusao = 3 ,o.inrisco_rating = 3 ,o.inorigem_rating = 8 ,o.innivel_rating = 0 ,o.inpontos_rating = 0 ,o.insegmento_rating = '' WHERE o.cdcooper = 6 AND o.nrdconta = 147273 AND o.nrctremp = 230532 AND o.tpctrato = 90;
  UPDATE crawepr w SET w.dsnivris = 'B' ,w.dsnivori = 'B' WHERE w.cdcooper = 6 AND w.nrdconta = 147273 AND w.nrctremp = 230532;
  risc0003.obterDecretoRiscosLog(pr_cdcooper => 6,pr_nrdconta => 147273,pr_nrctremp => 230532,pr_tiporisco => 'RAT',pr_risco_atual => 6,pr_risco_atualizado => 3,pr_registrar_verlog => 1);

  UPDATE tbrisco_operacoes o SET o.inrisco_inclusao = 3 ,o.inrisco_rating = 3 ,o.inorigem_rating = 8 ,o.innivel_rating = 0 ,o.inpontos_rating = 0 ,o.insegmento_rating = '' WHERE o.cdcooper = 6 AND o.nrdconta = 155748 AND o.nrctremp = 229120 AND o.tpctrato = 90;
  UPDATE crawepr w SET w.dsnivris = 'B' ,w.dsnivori = 'B' WHERE w.cdcooper = 6 AND w.nrdconta = 155748 AND w.nrctremp = 229120;
  risc0003.obterDecretoRiscosLog(pr_cdcooper => 6,pr_nrdconta => 155748,pr_nrctremp => 229120,pr_tiporisco => 'RAT',pr_risco_atual => 5,pr_risco_atualizado => 3,pr_registrar_verlog => 1);

  COMMIT;
END;
0
0
