BEGIN
	INSERT INTO crapaca(nmdeacao
										 ,nmpackag
										 ,nmproced
										 ,lstparam
										 ,nrseqrdr
										 ) 
							 VALUES('BUSCA_C_HIST_FORMA_PAGTO'
										 ,NULL
										 ,'CREDITO.obterHitoricoFormaPagtoWeb'
										 ,'pr_nrdconta,pr_nrcontrato'
										 ,1045
										 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
