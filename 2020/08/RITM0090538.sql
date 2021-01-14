UPDATE crawepr SET nrctremp = 6080 where cdcooper = 8 and nrdconta = 44377 and nrctremp = 7181;
UPDATE crapavl SET nrctravd = 6080 where cdcooper = 8 and nrctaavd = 44377 and nrctravd = 7181;
UPDATE crapbpr SET nrctrpro = 6080 where cdcooper = 8 and nrdconta = 44377 and nrctrpro = 7181;
UPDATE crapprp SET nrctrato = 6080 where cdcooper = 8 and nrdconta = 44377 and nrctrato = 7181;
UPDATE crappep SET nrctremp = 6080 where cdcooper = 8 and nrdconta = 44377 and nrctremp = 7181;

delete from tbrisco_operacoes where cdcooper = 8 and nrdconta = 44377 and nrctremp = 6080 and tpctrato = 90;
UPDATE tbrisco_operacoes SET nrctremp = 6080 where cdcooper = 8 and nrdconta = 44377 and nrctremp = 7181 and tpctrato = 90;

commit;
