BEGIN
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 0
   WHERE p.cdcooper = 11
     AND p.cdacesso = 'TPCUSTEI_PADRAO';

  UPDATE cecred.craplcr SET tpcuspr = 0 WHERE cdcooper = 11;

  COMMIT;
END;
/

BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 9, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativa��o das linhas de credito contributario', '25/04/2022');
    
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 13, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativa��o das linhas de credito contributario', '25/04/2022');
  
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 11, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativa��o das linhas de credito contributario', TO_CHAR(SYSDATE,'DD/MM/YYYY'));
    
  COMMIT;
END;
/
