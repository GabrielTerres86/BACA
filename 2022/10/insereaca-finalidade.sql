BEGIN
  INSERT INTO CECRED.crapaca(nmdeacao
						    ,nmpackag
							,nmproced
							,lstparam
							,nrseqrdr
							) 
					VALUES('VALIDA_FINALIDADES'
							,null
							,'CREDITO.obterFinalidadeSemFinanciarPrestamistaWeb'
							,'pr_cdcooper,pr_cdfinemp'
							,504
							);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
