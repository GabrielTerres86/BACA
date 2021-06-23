DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);

  vr_cpf_titular NUMBER(20);

BEGIN

  -- Cooperativa de destino do cartão
  vr_cooperativa := 1;
  -- Conta de destino do cartão
  vr_conta := 8075620;

  -- Numero do cartão que precisamos ajustar
--  vr_cartao := 5127070162667067; -- Jeff
--  vr_cartao := 5127070162667935; -- XV
--  vr_cartao := 5127070161674411; -- Luis
--  vr_cartao := 5158940000000188; -- Matheus
  vr_cartao := 5156010019676523; -- SeP - PF

  -- Verificar se a conta possui algum outro cartão para buscar o CPF do Titular
  FOR cartao IN (SELECT DISTINCT a.nrcpftit
                   FROM crawcrd a
                  WHERE a.cdcooper = vr_cooperativa
                    AND a.nrdconta = vr_conta
                    AND a.insitcrd = 4 -- Apenas cartão ativo
                 ) LOOP
    -- carregar o CPF da conta
    vr_cpf_titular := cartao.nrcpftit;
  
  END LOOP;

  IF vr_cpf_titular IS NULL THEN
    -- Se não tem CPF tem que buscar o CPF do titular da conta
    FOR titular IN (SELECT a.nrcpfcgc
                      FROM crapttl a
                     WHERE a.cdcooper = vr_cooperativa
                       AND a.nrdconta = vr_conta
                       AND a.idseqttl = 1 -- CPF do primeiro titular do cartão
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
        ,card.cdadmcrd = 15
        ,card.qtsenerr = 0
        ,card.inacetaa = 1
   WHERE card.nrcrcard = vr_cartao;

  UPDATE crawcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.cdadmcrd = 15
   WHERE card.nrcrcard = vr_cartao;

  COMMIT;

END;
