DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);
  vr_cpf_titular NUMBER(20);

BEGIN

  -- Cooperativa de destino do cartão
  vr_cooperativa := 6;
  -- Conta de destino do cartão
  vr_conta := 194646;

-- Numero do cartão que precisamos ajustar
vr_cartao := 5588190184171591; -- Topaz
  
  -- Verificar se a conta possui algum outro cartão para buscar o CPF do Titular
  FOR cartao IN (select distinct a.nrcpftit
                  from crawcrd a
                 where a.cdcooper = vr_cooperativa
                   and a.nrdconta = vr_conta
                   and a.insitcrd = 4 -- Apenas cartão ativo
                 ) LOOP
    -- carregar o CPF da conta
    vr_cpf_titular := cartao.nrcpftit;

  END LOOP;
  
  IF vr_cpf_titular IS NULL THEN
  -- Se não tem CPF tem que buscar o CPF do titular da conta
    FOR titular IN (select a.nrcpfcgc
                      from crapttl a
                     where a.cdcooper = vr_cooperativa
                       and a.nrdconta = vr_conta
                       and a.idseqttl = 1 -- CPF do primeiro titular do cartão
                   ) LOOP
      -- carregar o CPF da conta
      vr_cpf_titular := titular.nrcpfcgc;

    END LOOP;

  END IF;

  IF vr_cpf_titular IS NULL THEN
    -- Se não tem CPF para o processo
    RETURN;
  END IF;

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
        ,card.nrctrcrd = card.nrctrcrd + 1
   WHERE card.nrcrcard = vr_cartao;

  COMMIT;

END;
