DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);

  vr_cpf_titular NUMBER(20);

BEGIN

  -- Cooperativa de destino do cartão
  vr_cooperativa := 6;
  -- Conta de destino do cartão
  vr_conta := 14010;

  -- Numero do cartão que precisamos ajustar
  --vr_cartao := 5158940000000188; -- Matheus
  vr_cartao := 5588190184171591; -- Wilsom

  -- carregar o CPF da conta
  vr_cpf_titular := 2657908918;

  -- Atualizar os dados do cartão
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
