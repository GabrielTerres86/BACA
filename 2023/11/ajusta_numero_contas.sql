BEGIN
	UPDATE 
	(SELECT pes.nrdconta AS anterior, ass.NRDCONTA AS novo 
		FROM CECRED.crapass ass
		INNER JOIN CECRED.TBSITE_COOPERADO_CDC cdc ON cdc.NRDCONTA = ass.NRDCONTA AND cdc.CDCOOPER = ass.CDCOOPER 
		INNER JOIN CECRED.TBCADAST_PESSOA pes ON pes.NRCPFCGC = ass.NRCPFCGC AND pes.CDCOOPER = ass.CDCOOPER AND pes.NRDCONTA <> ass.NRDCONTA 
	) tb
	SET tb.anterior= tb.novo
	WHERE tb.anterior <> tb.novo;

	COMMIT;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
END;