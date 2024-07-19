begin
  
update cecred.tbchq_deposito_cheque_mob m
  set  m.insituacao = 4
where  m.dtdeposito < trunc(sysdate)
  and  m.insituacao = 1;

commit;
end;
