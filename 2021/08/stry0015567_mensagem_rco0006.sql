begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO06_CODMSG_POUPANCA', 'Codigo da mensagem RCO Consulta Cumprimento Compulsório', 'RCO0006');
  
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_CODMOD_POUPANCA', 'Codigo CODMOD Poupanca', '4');

  COMMIT;
end;