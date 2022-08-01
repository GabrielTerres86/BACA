begin
  update crapprm p
     set p.dsvlrprm = 'S'
   where p.cdacesso = 'PROPOSTA_API_ICATU'
     and p.cdcooper = 9;
  commit;
end;
/
