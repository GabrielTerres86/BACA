DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);

  vr_cpf_titular NUMBER(20);

BEGIN

  -- Cooperativa de destino do cartão
  vr_cooperativa := 6;
  -- Conta de destino do cartão
  vr_conta := 101630  ;

  -- Numero do cartão que precisamos ajustar
--  vr_cartao := 5127070162667067; -- Jeff
--  vr_cartao := 5127070162667935; -- XV
-- vr_cartao := 5127070161674411; -- Luis
--  vr_cartao := 5158940000000188; -- Matheus(saque & pague)
--  vr_cartao := 5156010019676523; -- SeP - PF
--  vr_cartao := 5127070340534221; -- Paty
--  vr_cartao := 5588190184171591; -- Topaz
  vr_cartao := 6393500069948041; -- Dudu
  
  vr_cpf_titular := 94426406072;

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
