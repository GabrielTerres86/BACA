begin
  
update  cecred.tbchq_deposito_cheque_mob m
   set m.insituacao = 4
where  m.insituacao = 1
  and  m.dtdeposito < to_date('08/07/2024','DD/MM/YYYY');

commit;
end;
