begin
  update crapprm
  set dsvlrprm = '2'
  where nmsistem = 'CRED'
    and cdacesso = 'COOP_PILOTO_POUPANCA_PF'
    and dsvlrprm = '1';
  commit;
end;
 
