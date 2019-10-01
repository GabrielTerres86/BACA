BEGIN

	UPDATE gncdntj SET flentpub = 1 WHERE cdnatjur IN (
	1031 --Órgão Público do Poder Executivo Municipal
	,1066 --Órgão Público do Poder Legislativo Municipal
	,1120 --Autarquia Municipal
	,1155 --Fundação Pública de Direito Público Municipal
	,1180 --Órgão Público Autônomo Municipal
	,1244 --Município
	,1279 --Fundação Pública de Direito Privado Municipal
	,1309 --Fundo Público da Administração Indireta Municipal
	,1333 --Fundo Público da Administração Direta Municipal
	);
	
	COMMIT;

END;