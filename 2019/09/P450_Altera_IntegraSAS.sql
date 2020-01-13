UPDATE tbrisco_operacoes t
   SET t.flintegrar_sas = 0
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2815389
   AND t.nrctremp = 52017
   AND t.tpctrato = 90;

commit;