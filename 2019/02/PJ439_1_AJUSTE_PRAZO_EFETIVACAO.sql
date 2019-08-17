declare
begin
  update crapprm set dsvlrprm='60' where cdacesso='PRAZO_EFETIVA_CDC';
  commit;
end;