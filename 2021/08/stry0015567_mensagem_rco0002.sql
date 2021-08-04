begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_CODITEM_7001', 'Codigo Item Base Incidencia', '7001');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_CODITEM_7005', 'Codigo Item Base Incidencia', '7005');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_CODMSG_POUPANCA', 'Codigo da mensagem RCO Informa Demonstrativo', 'RCO0002');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_CODRCO_POUPANCA', 'Codigo CODRCO Poupanca', '7');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCO02_ISPB_POUPANCA', 'Codigo do ISPB IF Poupanca', '05463212');

  COMMIT;
end;