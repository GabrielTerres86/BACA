begin 

update cecred.tbchq_deposito_cheque_mob mob
   set mob.insituacao = 4
 where mob.dtdeposito < trunc(sysdate)
   and mob.insituacao = 1;
commit;   
   
end;


