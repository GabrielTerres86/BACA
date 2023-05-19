begin
  
update cecred.tbchq_deposito_cheque_mob mob
   set mob.insituacao = 4
where mob.dtdeposito < to_date(sysdate,'dd/mm/yyyy')
      and mob.insituacao = 1;

commit;
end;










