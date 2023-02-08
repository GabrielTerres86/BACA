BEGIN

   INSERT INTO CECRED.crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	VALUES('CADFRA_DESBLOQ_SENHA_INTERNET', 'TELA_CADFRA', 'pc_desbloquear_senha_internet', 'pr_cdcooper,pr_nrdconta', (SELECT NRSEQRDR FROM CECRED.craprdr WHERE NMPROGRA = 'TELA_CADFRA'));

  COMMIT;
	
END;