DECLARE

  vr_cooperativa INTEGER;
  vr_conta       INTEGER;
  vr_cartao      NUMBER(25);

BEGIN

  -- Cooperativa de destino do cartão
  vr_cooperativa := 6;
  -- Conta de destino do cartão
  vr_conta := 508632;
  -- Numero do cartão que precisamos ajustar
  vr_cartao := 5127070161674411;

	UPDATE crapcrd
	SET crapcrd.cdcooper = vr_cooperativa
	,crapcrd.nrdconta = vr_conta
	,crapcrd.nrcpftit = 00904280993
	,crapcrd.cdadmcrd = 15
	WHERE crapcrd.nrcrcard = vr_cartao;

	 
	UPDATE crawcrd
	SET crawcrd.cdcooper = vr_cooperativa
	,crawcrd.nrdconta = vr_conta
	,crawcrd.nrcpftit = 00904280993
	,crawcrd.cdadmcrd = 15
	WHERE crawcrd.nrcrcard = vr_cartao;

	COMMIT;
END;