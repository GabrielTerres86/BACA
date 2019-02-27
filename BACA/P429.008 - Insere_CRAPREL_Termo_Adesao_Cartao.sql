BEGIN
    
	insert into TBGEN_VERSAO_TERMO (CDCOOPER, DSCHAVE_VERSAO, DTINICIO_VIGENCIA, DTFIM_VIGENCIA, DSNOME_JASPER, DTCADASTRO, DSDESCRICAO)
	values (1, 'TERMO ADESAO CDC PF V1', to_date('28-02-2019', 'dd-mm-yyyy'), null, 'termo_adesao_pf_novo.jasper', to_date('28-02-2019', 'dd-mm-yyyy'), 'Termo de adesão de cartão de Crédito AILOS para pessoa física em novo layout.');

	insert into TBGEN_VERSAO_TERMO (CDCOOPER, DSCHAVE_VERSAO, DTINICIO_VIGENCIA, DTFIM_VIGENCIA, DSNOME_JASPER, DTCADASTRO, DSDESCRICAO)
	values (1, 'TERMO ADESAO CDC PJ V1', to_date('28-02-2019', 'dd-mm-yyyy'), null, 'termo_adesao_pj_novo.jasper', to_date('28-02-2019', 'dd-mm-yyyy'), 'Termo de adesão de cartão de Crédito AILOS para pessoa jurídica em novo layout.');
	 

  commit;

END;