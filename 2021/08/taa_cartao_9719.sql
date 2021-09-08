declare

 

  vr_cooperativa INTEGER;
  vr_conta INTEGER;
  vr_cartao NUMBER(25);
  vr_cpf_titular NUMBER(20);

 

begin

 

  -- Cooperativa de destino do cartão
  vr_cooperativa := 1;
  -- Conta de destino do cartão
  vr_conta := 5282;

 

  -- Atualizar os dados do cartão
  UPDATE crapcrd
     SET crapcrd.cdcooper = vr_cooperativa
        ,crapcrd.nrdconta = vr_conta
        ,crapcrd.nrcpftit = 47502681949 
   WHERE crapcrd.nrcrcard = 5127070320149719;

 

  UPDATE crawcrd
     SET crawcrd.cdcooper = vr_cooperativa
        ,crawcrd.nrdconta = vr_conta
        ,crawcrd.nrcpftit = 47502681949 
   WHERE crawcrd.nrcrcard = 5127070320149719;

 

  COMMIT;

 

end;