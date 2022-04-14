begin
  
update cecred.tbchq_deposito_cheque_mob mob
  set mob.insituacao = 4
where mob.insituacao = 1
  and mob.dtdeposito <= to_date('13/04/2022','DD/MM/YYYY');

commit;
end;
  
