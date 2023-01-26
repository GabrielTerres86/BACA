begin
  
update cecred.tbchq_deposito_cheque_mob mob
   set mob.insituacao = 4
where mob.dtdeposito <= to_date('23/01/2023','dd/mm/yyyy')
      and mob.insituacao = 1;

commit;
end;
