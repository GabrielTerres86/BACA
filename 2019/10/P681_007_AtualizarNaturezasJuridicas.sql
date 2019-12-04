BEGIN

	UPDATE gncdntj 
	   SET flentpub = 1
		  ,cdgrpnat = 2
	WHERE cdnatjur IN (
	1031 --Órgão Público do Poder Executivo Municipal
	,1066 --Órgão Público do Poder Legislativo Municipal
	,1120 --Autarquia Municipal
	,1155 --Fundação Pública de Direito Público Municipal (Fundacao Municipal )
	,1180 --Órgão Público Autônomo Municipal
	,1244 --Município
	,1279 --Fundação Pública de Direito Privado Municipal
	,1309 --Fundo Público da Administração Indireta Municipal
	,1333 --Fundo Público da Administração Direta Municipal
	);
	
	INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1244, 'Municipio', 'MUNICIPIO', 0, 1, 1);
	INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1279, 'Fundacao Publica de Direito Privado Municipal', 'FUND PB.PV.MUN', 0, 1, 2);
	INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1309, 'Fundo Publico da Administracao Indireta Municipal', 'FUNDO ADM IND', 0, 1, 2);
	INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1333, 'Fundo Publico da Administracao Direta Municipal', 'FUNDO ADM DIR', 0, 1, 2);
	
	COMMIT;

END;