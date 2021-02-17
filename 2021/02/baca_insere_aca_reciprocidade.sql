BEGIN
	INSERT INTO crapaca(nmdeacao
										 ,nmpackag
										 ,nmproced
										 ,lstparam
										 ,nrseqrdr
										 ) 
							 VALUES('BUSCA_RECIPROCIDADE_CREDITO'
										 ,NULL
										 ,'CREDITO.obterReciprocidadeContratoWeb'
										 ,'pr_nrdconta,pr_nrcontrato'
										 ,1045
										 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
