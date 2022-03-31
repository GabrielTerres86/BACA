BEGIN
	update crapaca a 
	   set a.lstparam = 'pr_nrdconta,pr_tpcustei,pr_flggarad,pr_nrregist,pr_nriniseq'  
	 where a.nmdeacao='BUSCA_CONTRATOS_PRESTAMISTA'; 
	 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/

