begin
  update cecred.crapprm p 
     set p.dsvlrprm = 4 
   where p.cdacesso in ('COVID_QTDE_PARCELA_PAGAR')
     and p.cdcooper = 1;
commit;
end;   
