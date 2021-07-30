DECLARE
 
  CURSOR cr_crapprm is 
    select nmsistem, 
		   cdcooper, 
		   cdacesso, 
		   dstexprm, 
		   dsvlrprm 
	from crapprm
	where cdacesso in ( 'CONTIGENCIA_ESTEIRA_CRD',
		  'ANALISE_OBRIG_MOTOR_CRD',
		  'REGRA_ANL_IBRA_CRD',
          'REGRA_ANL_IBRA_CRD_PJ',
          'TIME_RESP_MOTOR_CRD',
          'QTD_MES_HIST_DEVCHQ_CRD',
          'QTD_MES_HIST_DCH_A11_CRD',
          'QTD_MES_HIST_DCH_A12_CRD',
          'QTD_MES_HIST_EST_CRD',
          'QTD_MES_HIST_EMPRES_CRD');
  
  rg_crapprm cr_crapprm%rowtype;
  
BEGIN

  OPEN cr_crapprm;
  LOOP
    FETCH cr_crapprm INTO rg_crapprm;
    EXIT WHEN cr_crapprm%NOTFOUND;

	if(rg_crapprm.cdacesso = 'CONTIGENCIA_ESTEIRA_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'CONTIGENCIA_ESTEIRA_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'ANALISE_OBRIG_MOTOR_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'ANALISE_OBRIG_MOTOR_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'REGRA_ANL_IBRA_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'REGRA_ANL_IBRA_VISA', rg_crapprm.dstexprm, 'PoliticaCartaoCreditoVisaPF');
	
	end if;
	
	if(rg_crapprm.cdacesso = 'REGRA_ANL_IBRA_CRD_PJ') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'REGRA_ANL_IBRA_PJ_VISA', rg_crapprm.dstexprm, 'PoliticaCartaoCreditoVisaPJ');
	
	end if;
	
	if(rg_crapprm.cdacesso = 'TIME_RESP_MOTOR_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'TIME_RESP_MOTOR_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'QTD_MES_HIST_DEVCHQ_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'QTD_MES_HIST_DEVCHQ_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'QTD_MES_HIST_DCH_A11_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'QTD_MES_HIST_DCHA11_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'QTD_MES_HIST_DCH_A12_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'QTD_MES_HIST_DCHA12_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'QTD_MES_HIST_EST_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'QTD_MES_HIST_EST_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;
	
	if(rg_crapprm.cdacesso = 'QTD_MES_HIST_EMPRES_CRD') then
	
		insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
							(rg_crapprm.nmsistem, rg_crapprm.cdcooper, 'QTD_MES_HIST_EMPRES_VISA', rg_crapprm.dstexprm, rg_crapprm.dsvlrprm);
	
	end if;

  END LOOP;
  CLOSE cr_crapprm;
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;