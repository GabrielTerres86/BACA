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
    ,'gestaoderisco.obterLinkAilosR'
    ,'pr_nmdetela'
    ,(SELECT NRSEQRDR
       FROM craprdr
      WHERE upper(nmprogra) = 'ATENDA'));

    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'URL_BASE_AILOSR_DEV','URL base do Front Ailos+ DEV','https://frontailosmais-dev.ailos.coop.br');
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'URL_BASE_AILOSR_HOMOL','URL base do Front Ailos+ HML','https://frontailosmais-hml.ailos.coop.br');
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'URL_BASE_AILOSR_PROD','URL base do Front Ailos+ PRD','https://frontailosmais.ailos.coop.br');

    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'DIR_RISCO_CRED_AILOSR','Diretorio de risco no Front Ailos+ DEV/HML/PRD','/application/riscocredito/');

    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'ATENDA_OCR_AILOSR','Redirecionamento do Aimaro para o Ailos+ da tela Ocorrencias Riscos','risco' );
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'CADRIS_AILOSR','Redirecionamento do Aimaro para o Ailos+ da tela CadRis','risco' );
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'CONTAS_GECO_AILOSR','Redirecionamento do Aimaro para o Ailos+ da tela CONTAS - Grupo Economico','grupo-economico' );
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'RATMOV_AILOSR','Redirecionamento do Aimaro para o Ailos+ da tela RatMov','rating' );
    insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM ,DSVLRPRM ) values ('CRED',0,'ATENDA_GECO_OCR_AILOSR','Redirecionamento do Aimaro para o Ailos+ da tela Ocorrencias Grupo Economico','grupo-economico' );
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		RAISE_application_error(-20500, SQLERRM);
		ROLLBACK;
END;