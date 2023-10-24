BEGIN
  
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao, pr_cdbloqueio_origem'
   WHERE NMPROCED = 'CREDITO.adicionarBloqueioDebito'
     AND NMDEACAO = 'EFETUA_BLOQ_DEBITO_OP_CREDITO';
     
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsobservacao, pr_cdbloqueio_origem'
	 WHERE NMPROCED = 'CREDITO.alterarBloqueioDebito'
	   AND NMDEACAO = 'ALTERA_BLOQ_DEBITO_OP_CREDITO';
     
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp, pr_cdoperad'
   WHERE NMPROCED = 'CREDITO.obterBloqueioDebito'
     AND NMDEACAO = 'CONSULTA_BLOQ_DEBITO_OP_CREDITO';
     
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_dtinicio,pr_dtafinal,pr_cdcooper, pr_cdoperad'
   WHERE NMPROCED = 'pc_salva_blq_ope_cred_csv'
     AND NMDEACAO = 'BLQJUD_SALVAR_CSV_OPE_CRED';          

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	RAISE_application_error(-20500, SQLERRM);
END;
     
