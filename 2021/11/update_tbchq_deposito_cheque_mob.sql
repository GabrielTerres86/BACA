begin
  
update tbchq_deposito_cheque_mob mob
  set mob.insituacao = 4 
where mob.dtdeposito <= to_date('12/11/2021','DD/MM/YYYY') 
  and mob.insituacao = 1; 

commit;
end;
