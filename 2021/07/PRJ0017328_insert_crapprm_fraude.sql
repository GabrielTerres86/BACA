begin
  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values ('CRED', 0, 'EMAIL_RISCOFRAUDE_ADM', 'E-mail de destino dos riscos de fraude na admiss�o', 'prev.fraudes03@ailos.coop.br');
  
  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values ('CRED', 0, 'PERC_ALTO_FRAUDE_ADM', 'Porcentagem que define risco alto de fraude na admiss�o', '71');
  
  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values ('CRED', 0, 'PERC_MEDIO_FRAUDE_ADM', 'Porcentagem que define risco m�dio de fraude na admiss�o', '41');
  
  commit;
end;
