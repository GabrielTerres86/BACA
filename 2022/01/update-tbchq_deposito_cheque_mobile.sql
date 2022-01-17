begin
  
update tbchq_deposito_cheque_mob mob
  set mob.insituacao = 4
where  mob.dtdeposito < to_date('14/01/2022','DD/MM/YYYY')
  and  mob.insituacao = 1;
  
commit;
end;   
