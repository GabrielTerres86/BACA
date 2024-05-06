begin

update cecred.tbchq_seguranca_cheque e
  set  e.idstatus_atualizacao_hsm = 2, 
       e.cdseguranca = 5242673
where  e.cdcooper = 1
  and  e.nrdconta in (83218181, 83218360)
  and  e.idstatus_atualizacao_hsm = 0;
  
commit;
end;  

