BEGIN
  
  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0255410');
    ROLLBACK; 
    
END;    
