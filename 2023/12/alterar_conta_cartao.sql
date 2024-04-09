DECLARE
  vr_cooperativa INTEGER := 9;
  vr_conta       INTEGER := 82665451;
  vr_cartao      NUMBER(25) := 5588190184171591;
  vr_nrctrcrd    INTEGER := 990999;
  vr_cpf_titular NUMBER(20);
  
BEGIN

  FOR cartao IN (SELECT DISTINCT a.nrcpftit
                   FROM crawcrd a
                  WHERE a.cdcooper = vr_cooperativa
                    AND a.nrdconta = vr_conta
                    AND a.insitcrd = 4) LOOP
    vr_cpf_titular := cartao.nrcpftit;
  END LOOP;
  IF vr_cpf_titular IS NULL THEN
    FOR titular IN (SELECT a.nrcpfcgc
                      FROM crapttl a
                     WHERE a.cdcooper = vr_cooperativa
                       AND a.nrdconta = vr_conta
                       AND a.idseqttl = 1) LOOP
      vr_cpf_titular := titular.nrcpfcgc;
    END LOOP;
  END IF;

  IF vr_cpf_titular IS NULL THEN
    RETURN;
  END IF;

  UPDATE crapcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.qtsenerr = 0
        ,card.inacetaa = 1
        ,card.cdadmcrd = 15
        ,card.NRCTRCRD = vr_nrctrcrd
   WHERE card.nrcrcard = vr_cartao;

  UPDATE crawcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.NRCTRCRD = vr_nrctrcrd
        ,card.cdadmcrd = 15
   WHERE card.nrcrcard = vr_cartao;

  COMMIT;
END;
