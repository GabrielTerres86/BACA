BEGIN
    
	UPDATE CECRED.crapprm p
       SET p.dsvlrprm = 0
	 WHERE p.cdcooper = 6
       AND p.cdacesso = 'TPCUSTEI_PADRAO';
	   
	INSERT INTO CECRED.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES ('CRED', 6,'DIA_ATIVA_CONTRB_SEGPRE','Dia da ativação das linhas de credito contributario', to_char(TRUNC(SYSDATE)-10,'dd/mm/yyyy'));   

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/