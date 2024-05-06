BEGIN 
  UPDATE cecred.crapprm p 
     SET p.dsvlrprm = 0
   WHERE p.cdacesso = 'TPCUSTEI_PADRAO' 
     AND p.cdcooper = 12;
     
  INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 12, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario', '23/10/2023');

  UPDATE cecred.craplcr l    
	 SET l.tpcuspr = 0
   WHERE l.flgstlcr = 1
	 AND l.flgsegpr = 1
	 AND l.cdcooper = 12
	 AND l.cdlcremp NOT IN (313,314);
	
  UPDATE cecred.craplcr l    
	 SET l.flgsegpr = 0
   WHERE l.cdcooper = 12
	 AND l.cdlcremp IN (313,314);
	
 COMMIT;
END;   
     
