begin

update cecred.tbchq_seguranca_cheque e
   set e.idstatus_atualizacao_hsm = 2
where  e.cdcooper = 5
  and  e.nrdconta = 84476834
  and  e.idstatus_atualizacao_hsm = 0;
  
commit;
end;  
