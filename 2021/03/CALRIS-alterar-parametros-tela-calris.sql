DECLARE

BEGIN

UPDATE cecred.crapaca
   SET lstparam = 'pr_dtinicio,pr_dtfim,pr_status,pr_tppessoa,pr_nriniseq,pr_nrregist,pr_cdclasrisco'
 WHERE nmdeacao = 'BUSCA_TANQUE'
   AND nmpackag = 'TELA_CALRIS'
   AND nmproced = 'pc_busca_tanque';
COMMIT;
EXCEPTION
WHEN OTHERS THEN
	NULL;
END;
/