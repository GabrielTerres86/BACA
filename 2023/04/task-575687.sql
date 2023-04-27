BEGIN

	INSERT INTO cecred.crapaca
		(nmdeacao
		,nmpackag
		,nmproced
		,lstparam
		,nrseqrdr)
	VALUES
		('OBTER_LINK_AILOSR'
		,NULL
		,'gestaoderisco.OBTER_LINK_AILOSR'
		,'pr_tela'
		,(SELECT NRSEQRDR
			 FROM craprdr
			WHERE upper(nmprogra) = 'ATENDA'));
	
	insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'AIMARO_AILOSR_RATMOV','Redirecionamento do Aimaro para o Ailos+ da tela RatMov','/home/application/riscocredito/rating' );

	insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'AIMARO_AILOSR_CADRIS','Redirecionamento do Aimaro para o Ailos+ da tela CadRis','/home/application/riscocredito/risco-credito' );

	insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'AIMARO_AILOSR_GRUPECON','Redirecionamento do Aimaro para o Ailos+ da tela Grupo Economico','/home/application/riscocredito/grupo-economico' );

	insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'AIMARO_AILOSR_RISCOS','Redirecionamento do Aimaro para o Ailos+ da tela Riscos','/home/application/riscocredito/risco-credito' );

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		RAISE_application_error(-20500, SQLERRM);
		ROLLBACK;
END;