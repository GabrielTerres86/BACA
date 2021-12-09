BEGIN
  UPDATE tbrisco_operacoes o
     SET o.flintegrar_sas = 1
       , o.flencerrado = 0
   WHERE o.cdcooper = 13
     AND o.nrdconta = 299944
     AND o.nrctremp = 299944
     AND o.tpctrato = 11;
  COMMIT;
END;
