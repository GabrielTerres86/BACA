BEGIN
	UPDATE crapaca a
	SET a.nmdeacao = 'PROCESSA_ARQ_FUND_COTISTA'
	   ,a.lstparam = 'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados,pr_tpprocesso'
       ,a.nmproced = 'pc_processar_arq_funding_cotista'	   
	WHERE a.nmdeacao LIKE  'PROCESSA_ARQ_F%'
	AND a.nmpackag = 'EMPR0025';
   
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
