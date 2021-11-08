declare
begin 
INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 0, 'MONIT_EMAIL_FRAUDE_INT', 'Email de destino dos monitoramentos.', 'ifraude@ailos.coop.br');
commit;
end;
/