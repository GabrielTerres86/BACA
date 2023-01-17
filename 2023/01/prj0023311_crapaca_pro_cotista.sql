BEGIN
	UPDATE crapaca a
	SET a.nmdeacao = 'PROCESSA_ARQ_FUND_COTISTA'
	   ,a.lstparam = 'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados,pr_tpprocesso'
       ,a.nmproced = 'pc_processar_arq_funding_cotista'	   
	WHERE a.nmdeacao LIKE  'PROCESSA_ARQ_F%'
	AND a.nmpackag = 'EMPR0025';

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 1, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '710');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 16, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central','728');

   
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
