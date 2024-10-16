
begin
  update cecred.tbchq_deposito_cheque_mob m
     set m.insituacao = 4
   where m.insituacao = 1;
   commit;
end;


--select * from tbchq_deposito_cheque_mob where insituacao = 1 for update
