declare

  vr_cooperativa INTEGER;
  vr_conta INTEGER;

begin

  -- Cooperativa de destino do cartão
  vr_cooperativa := 6;
  -- Conta de destino do cartão
  vr_conta := 107131;

  -- Atualizar os dados do cartão
  UPDATE crapcrd
     SET crapcrd.cdcooper = vr_cooperativa
        ,crapcrd.nrdconta = vr_conta
        ,crapcrd.nrcpftit = 00885360923
   WHERE crapcrd.nrcrcard = 5127070161674411;

  UPDATE crawcrd
     SET crawcrd.cdcooper = vr_cooperativa
        ,crawcrd.nrdconta = vr_conta
        ,crawcrd.nrcpftit = 00885360923
   WHERE crawcrd.nrcrcard = 5127070161674411;

  -- Atualizar os dados do cartão
  UPDATE crapcrd
     SET crapcrd.cdcooper = vr_cooperativa
        ,crapcrd.nrdconta = vr_conta
        ,crapcrd.nrcpftit = 86721410915
   WHERE crapcrd.nrcrcard = 5127070320149719;

  UPDATE crawcrd
     SET crawcrd.cdcooper = vr_cooperativa
        ,crawcrd.nrdconta = vr_conta
        ,crawcrd.nrcpftit = 86721410915
   WHERE crawcrd.nrcrcard = 5127070320149719;

  COMMIT;

end;
