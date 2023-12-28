BEGIN 
  UPDATE cecred.crapprm p 
     SET p.dsvlrprm = 1
   WHERE p.cdacesso = 'TPCUSTEI_PADRAO' 
     AND p.cdcooper = 7;
     
  DELETE FROM cecred.crapprm 
   WHERE cdcooper = 7 
     AND cdacesso = 'DIA_ATIVA_CONTRB_SEGPRE';

  UPDATE cecred.craplcr l    
	 SET l.tpcuspr = 1
   WHERE l.cdcooper = 7
	 AND l.cdlcremp NOT IN (100,300,301,800,900,2600,2610,2700,6901,6902,6903,6904,6905,26014,76014);
	 
  UPDATE cecred.craplcr l    
	 SET l.flgsegpr = 0
   WHERE l.cdcooper = 7
	 AND l.cdlcremp IN (666,3716,3717,3718,8888,58001,90002,95002);	 

 COMMIT;
END;   
     
