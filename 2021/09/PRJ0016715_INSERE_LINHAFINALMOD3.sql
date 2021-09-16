BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDFINEMP_PP_MOD3', 'Finalidade modelo acordo 3 PP',600);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDLCREMP_PP_EMPRESTIMO', 'Linha credito PP emprestimo',6000);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDLCREMP_PP_FINACIAMEN', 'Linha credito PP financiamento',5997);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDFINEMP_POS_MOD3', 'Finalidade modelo acordo 3 POS',601);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDLCREMP_POS_EMPRESTIMO', 'Linha credito POS emprestimo',5998);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', 0, 'CDLCREMP_POS_FINACIAMEN', 'Linha credito POS financiamento',5999);
  COMMIT;
END;
