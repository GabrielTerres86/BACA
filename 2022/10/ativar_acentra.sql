BEGIN

	INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES ('CRED', 5,'DIA_ATIVA_CONTRB_SEGPRE','Dia da ativação das linhas de credito contributario', to_char(TRUNC(SYSDATE)-1,'dd/mm/yyyy'));
    
	UPDATE CECRED.crapprm p
       SET p.dsvlrprm = 0
	 WHERE p.cdcooper = 5
       AND p.cdacesso = 'TPCUSTEI_PADRAO';
	   
	UPDATE CECRED.craplcr l
       SET l.tpcuspr = 0
     WHERE l.flgsegpr = 1
       AND (l.cdcooper, l.cdlcremp) IN
           ((5,400)
           ,(5,401)
           ,(5,703)
           ,(5,712));   

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/