declare
begin 
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'PERC_ALTO_MONIT', 'Porcentagem que define risco alto de fraude no monitoramento de chaves', '91');
commit;
end;
/