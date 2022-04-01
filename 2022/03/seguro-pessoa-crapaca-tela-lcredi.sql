BEGIN
	UPDATE crapaca a 
	   SET a.lstparam = 'pr_nrdconta,pr_tpcustei,pr_flggarad,pr_nrregist,pr_nriniseq'  
	 WHERE a.nmdeacao='BUSCA_CONTRATOS_PRESTAMISTA'; 
	
	UPDATE craplcr SET tpcuspr = 0 WHERE cdcooper IN (9,13);
	
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/

