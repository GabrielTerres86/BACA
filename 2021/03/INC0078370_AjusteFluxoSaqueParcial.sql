
-- Retira o registro de controle de saque parcial da conta 3669700 da Alto Vale.
BEGIN
  --
  delete from tbcotas_saque_controle where cdcooper = 16 and nrdconta = 3669700 and tpsaque = 1;
  --
  COMMIT;
  --
END;