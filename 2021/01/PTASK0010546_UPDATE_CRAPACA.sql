BEGIN
	UPDATE crapaca c
	   SET c.lstparam = 'pr_dsdlista,pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3,pr_qtdemtel'
	 WHERE c.nmdeacao = 'CUSAPL_SOLIC_REENVIO'
	   AND c.nmpackag = 'TELA_CUSAPL';
	COMMIT;
END;