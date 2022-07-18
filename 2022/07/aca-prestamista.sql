BEGIN
  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 0
   WHERE p.cdcooper = 5
     AND p.cdacesso = 'TPCUSTEI_PADRAO';

  UPDATE cecred.craplcr SET tpcuspr = 0 WHERE cdcooper = 5;

  INSERT INTO cecred.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 5, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario', '14/07/2022');

  COMMIT;
END;
/
