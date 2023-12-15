begin
  
update cecred.tbchq_deposito_cheque_mob mob
   set mob.insituacao = 1
where mob.dtdeposito < trunc(sysdate)
      and mob.insituacao = 4
      and mob.idseqdeposito in (193333,194941,195419,195760,195759,196848,197075);
commit;
end;
