DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);
  vr_cpf_titular NUMBER(20);

BEGIN

  vr_cooperativa := 1;
  vr_conta := 329;
  vr_cartao := 5588190184171591;
  vr_cpf_titular := 03032094968;

  UPDATE crapcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.qtsenerr = 0
        ,card.inacetaa = 1
        ,card.NRCTRCRD = 99999998
   WHERE card.nrcrcard = vr_cartao;

  UPDATE crawcrd card
     SET card.cdcooper = vr_cooperativa
        ,card.nrdconta = vr_conta
        ,card.nrcpftit = vr_cpf_titular
        ,card.NRCTRCRD = 99999998
   WHERE card.nrcrcard = vr_cartao;

  COMMIT;
END;
