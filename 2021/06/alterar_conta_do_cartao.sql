DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);
  vr_cpf_titular NUMBER(20);

BEGIN

  -- Cooperativa de destino do cart�o
  vr_cooperativa := 1;
  -- Conta de destino do cart�o
  vr_conta := 5282;

  -- Numero do cart�o que precisamos ajustar
--  vr_cartao := 5127070162667067; -- Jeff
--  vr_cartao := 5127070162667935; -- XV
  vr_cartao := 5127070161674411; -- Luis
--  vr_cartao := 5127070320149719; -- Luis 2
--  vr_cartao := 5158940000000188; -- Matheus(saque & pague)
--  vr_cartao := 5156010019676523; -- SeP - PF
--  vr_cartao := 5127070340534221; -- Paty
--  vr_cartao := 5161620000587872; -- Djonata
--  vr_cartao := 5127070162666663; -- Matheus barros
--  vr_cartao := 5588190184171591; -- Topaz
--  vr_cartao := 5161620000264183; -- Poliane 

  
  vr_cpf_titular := 30924138904;

  IF vr_cpf_titular IS NULL THEN
    -- Se n�o tem CPF para o processo
    RETURN;
  END IF;

  -- Atualizar os dados do cart�o
  UPDATE crapcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.qtsenerr = 0
        ,card.inacetaa = 1
   WHERE card.nrcrcard = vr_cartao;

  UPDATE crawcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
   WHERE card.nrcrcard = vr_cartao;



  COMMIT;

END;
