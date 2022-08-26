BEGIN

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 0
   WHERE p.cdcooper = 8
     AND p.cdacesso = 'TPCUSTEI_PADRAO';

  UPDATE cecred.craplcr SET tpcuspr = 0 WHERE cdcooper = 8 and flgsegpr = 1;

  INSERT INTO cecred.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 8, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario', '20/07/2022');

  COMMIT;
END;
/
