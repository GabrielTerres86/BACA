BEGIN 
  UPDATE cecred.crapprm p 
     SET p.dsvlrprm = 0
   WHERE p.cdacesso = 'TPCUSTEI_PADRAO' 
     AND p.cdcooper = 7;
     
  INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 7, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario', '21/01/2024');

  UPDATE cecred.craplcr l    
	 SET l.tpcuspr = 0
   WHERE l.cdcooper = 7
	 AND l.cdlcremp NOT IN (100,300,301,800,900,2600,2610,2700,6901,6902,6903,6904,6905,26014,76014);
	
  UPDATE cecred.craplcr l    
	 SET l.flgsegpr = 1
   WHERE l.cdcooper = 7
	 AND l.cdlcremp NOT IN (100,300,301,800,900,2600,2610,2700,6901,6902,6903,6904,6905,26014,76014)
	 AND l.flgsegpr = 0;
	
 COMMIT;
END;   
     
