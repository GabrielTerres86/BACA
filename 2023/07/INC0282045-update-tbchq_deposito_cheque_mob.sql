begin
  
update cecred.tbchq_deposito_cheque_mob mob
   set mob.insituacao = 4
where mob.dtdeposito <= to_date('14/07/2023','dd/mm/yyyy')
    and mob.insituacao = 1
    and mob.idseqdeposito >= 156824
    and mob.idseqdeposito <= 168803;

commit;
end;










