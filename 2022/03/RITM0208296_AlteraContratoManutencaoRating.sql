BEGIN

  UPDATE tbrisco_operacoes o
     SET o.flintegrar_sas = 1
   WHERE o.cdcooper = 9
     AND o.nrdconta = 230790
     AND o.nrctremp = 48541;
  COMMIT;

END;
