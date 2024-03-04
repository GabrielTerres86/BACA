Declare
begin    
    update cecred.tbseg_nrproposta p set p.dhseguro = sysdate where p.dhseguro is null and p.tpcustei = 1; 
     commit;
  
  UPDATE cecred.crapprm p 
     SET p.dsvlrprm = 0
   WHERE p.cdacesso = 'TPCUSTEI_PADRAO' 
     AND p.cdcooper = 7;
     
  INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 7, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario',  to_char(to_date('04/03/2024','dd/mm/yyyy'),'dd/mm/yyyy'));

  UPDATE cecred.craplcr l    
   SET l.tpcuspr = 0
   WHERE l.cdcooper = 7
   AND l.cdlcremp NOT IN (100,300,301,800,900,2600,2610,2700,6901,6902,6903,6904,6905,26014,76014);
  
  UPDATE cecred.craplcr l    
   SET l.flgsegpr = 1
   WHERE l.cdcooper = 7
   AND l.cdlcremp NOT IN (100,300,301,800,900,2600,2610,2700,6901,6902,6903,6904,6905,26014,76014)
   AND l.flgsegpr = 0;
  
  update cecred.crapprm p set p.DSVLRPRM = 'S' where p.CDCOOPER = 7 and p.cdacesso = 'PROPOSTA_API_ICATU';    
  
  COMMIT; 
	 
exception
  when others then   
    null;
end;
