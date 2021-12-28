BEGIN
	INSERT INTO CECRED.crapaca (
	  NRSEQACA,
	  NMDEACAO,
	  NMPACKAG,
	  NMPROCED,
	  LSTPARAM,
	  NRSEQRDR
	)
	VALUES (
	  (SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),
	  'OBTER_CONTAS_COMPARTILHADAS',
	  NULL,
	  'INTERNETBANKING.obterCtasCompartMensageria',
	  'pr_cdcooper,pr_nrdconta,pr_nrcpfusuario,pr_idseqttl,pr_insituacao,pr_nrregist,pr_cdorigem',
	  884
	);

	INSERT INTO CECRED.crapaca (
	  NRSEQACA,
	  NMDEACAO,
	  NMPACKAG,
	  NMPROCED,
	  LSTPARAM,
	  NRSEQRDR
	)
	VALUES (
	  (SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),
	  'OBTER_OPERADORES_CTA_COMPART',
	  NULL,
	  'INTERNETBANKING.obterOperadCtaCompartMsg',
	  'pr_cdcooper_adm,pr_nrdconta_adm,pr_cdcooper_cedente,pr_nrdconta_cedente',
	  884
	);
	COMMIT;
END;