begin
  update cecred.crapprm p 
     set p.dsvlrprm = 12 
   where p.cdacesso in ('COVID_QTDE_PARCELA_PAGAR')
     and p.cdcooper = 9;
commit;
end;   
