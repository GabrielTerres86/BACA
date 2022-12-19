BEGIN
	UPDATE credito.tbcred_repasse_contrato
	   SET vliof              = 8.5
		  ,vltarifa           = 9.5
		  ,qtparcelas_pagas   = 2
		  ,qtmeses_decorridos = 1
		  ,vliof_atraso       = 8.5
		  ,vltaxa_ao_ano      = 1.5
		  ,vlatraso           = 409.18
		  ,qtdias_atraso      = 30
		  ,vlmulta_atraso     = 10.75
	 WHERE idrepasse_contrato = 1;
	 
	 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;