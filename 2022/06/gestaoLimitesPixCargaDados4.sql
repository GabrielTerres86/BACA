DECLARE
BEGIN

	MERGE INTO PIX.TBPIX_LIMITE_COOPERADO t1
	USING (
		SELECT crapsnh.CDCOOPER, crapsnh.NRDCONTA, crapsnh.IDSEQTTL, crapsnh.VLLIMITE_PIX_COOPERADO, crapsnh.VLLIMITE_PIX, terminal.VLLIMITE_SAQUE
		FROM crapsnh crapsnh
		LEFT JOIN CECRED.TBTAA_LIMITES terminal ON crapsnh.CDCOOPER = terminal.CDCOOPER AND crapsnh.NRDCONTA = terminal.NRDCONTA
		WHERE TPDSENHA = 1 AND CDSITSNH = 1
	) t2
	ON (t1.CDCOOPER = t2.CDCOOPER AND t1.NRDCONTA = t2.NRDCONTA AND t1.IDSEQTTL = t2.IDSEQTTL AND t1.IDTIPO_LIMITE = 2 AND t1.IDPERIODO = 1 AND t1.FLPOR_TRANSACAO = 0 AND t1.CDSITUACAO = 1)
	WHEN NOT MATCHED THEN
		INSERT (t1.CDCOOPER, t1.NRDCONTA, t1.IDSEQTTL, t1.IDTIPO_LIMITE, t1.IDPERIODO, t1.FLPOR_TRANSACAO, t1.DHREGISTRO, t1.DHEFETIVACAO, t1.CDSITUACAO, t1.VLLIMITE)
		VALUES(t2.CDCOOPER, t2.NRDCONTA, t2.IDSEQTTL, 2, 1, 0, sysdate, sysdate, 1, (SELECT CASE WHEN COALESCE(t2.VLLIMITE_SAQUE,0) > 500 THEN 500 WHEN COALESCE(t2.VLLIMITE_SAQUE,0) < 100 THEN 100 ELSE COALESCE(t2.VLLIMITE_SAQUE,0) END FROM dual));

	MERGE INTO PIX.TBPIX_LIMITE_COOPERADO t1
	USING (
		SELECT CDCOOPER, NRDCONTA, IDSEQTTL, IDTIPO_LIMITE, IDPERIODO, FLPOR_TRANSACAO, VLLIMITE
		FROM PIX.TBPIX_LIMITE_COOPERADO
		WHERE IDTIPO_LIMITE = 2 AND IDPERIODO = 1 AND FLPOR_TRANSACAO = 0 AND CDSITUACAO = 1
	) t2
	ON (t1.CDCOOPER = t2.CDCOOPER AND t1.NRDCONTA = t2.NRDCONTA AND t1.IDSEQTTL = t2.IDSEQTTL AND t1.IDTIPO_LIMITE = t2.IDTIPO_LIMITE AND t1.IDPERIODO = 1 AND t1.FLPOR_TRANSACAO = 1 AND t1.CDSITUACAO = 1)
	WHEN NOT MATCHED THEN
		INSERT (t1.CDCOOPER, t1.NRDCONTA, t1.IDSEQTTL, t1.IDTIPO_LIMITE, t1.IDPERIODO, t1.FLPOR_TRANSACAO, t1.DHREGISTRO, t1.DHEFETIVACAO, t1.CDSITUACAO, t1.VLLIMITE)
		VALUES(t2.CDCOOPER, t2.NRDCONTA, t2.IDSEQTTL, t2.IDTIPO_LIMITE, 1, 1, sysdate, sysdate, 1, t2.VLLIMITE);	
	
	MERGE INTO PIX.TBPIX_LIMITE_COOPERADO t1
	USING (
		SELECT CDCOOPER, NRDCONTA, IDSEQTTL, IDTIPO_LIMITE, IDPERIODO, FLPOR_TRANSACAO, VLLIMITE
		FROM PIX.TBPIX_LIMITE_COOPERADO
		WHERE IDTIPO_LIMITE = 2 AND IDPERIODO = 1 AND FLPOR_TRANSACAO = 0 AND CDSITUACAO = 1
	) t2
	ON (t1.CDCOOPER = t2.CDCOOPER AND t1.NRDCONTA = t2.NRDCONTA AND t1.IDSEQTTL = t2.IDSEQTTL AND t1.IDTIPO_LIMITE = t2.IDTIPO_LIMITE AND t1.IDPERIODO = 2 AND t1.FLPOR_TRANSACAO = 0 AND t1.CDSITUACAO = 1)
	WHEN NOT MATCHED THEN
		INSERT (t1.CDCOOPER, t1.NRDCONTA, t1.IDSEQTTL, t1.IDTIPO_LIMITE, t1.IDPERIODO, t1.FLPOR_TRANSACAO, t1.DHREGISTRO, t1.DHEFETIVACAO, t1.CDSITUACAO, t1.VLLIMITE)
		VALUES(t2.CDCOOPER, t2.NRDCONTA, t2.IDSEQTTL, t2.IDTIPO_LIMITE, 2, 0, sysdate, sysdate, 1, 100);	
	
	MERGE INTO PIX.TBPIX_LIMITE_COOPERADO t1
	USING (
		SELECT CDCOOPER, NRDCONTA, IDSEQTTL, IDTIPO_LIMITE, IDPERIODO, FLPOR_TRANSACAO, VLLIMITE
		FROM PIX.TBPIX_LIMITE_COOPERADO
		WHERE IDTIPO_LIMITE = 2 AND IDPERIODO = 1 AND FLPOR_TRANSACAO = 0 AND CDSITUACAO = 1
	) t2
	ON (t1.CDCOOPER = t2.CDCOOPER AND t1.NRDCONTA = t2.NRDCONTA AND t1.IDSEQTTL = t2.IDSEQTTL AND t1.IDTIPO_LIMITE = t2.IDTIPO_LIMITE AND t1.IDPERIODO = 2 AND t1.FLPOR_TRANSACAO = 1 AND t1.CDSITUACAO = 1)
	WHEN NOT MATCHED THEN
		INSERT (t1.CDCOOPER, t1.NRDCONTA, t1.IDSEQTTL, t1.IDTIPO_LIMITE, t1.IDPERIODO, t1.FLPOR_TRANSACAO, t1.DHREGISTRO, t1.DHEFETIVACAO, t1.CDSITUACAO, t1.VLLIMITE)
		VALUES(t2.CDCOOPER, t2.NRDCONTA, t2.IDSEQTTL, t2.IDTIPO_LIMITE, 2, 1, sysdate, sysdate, 1, 100);
	commit;
END;