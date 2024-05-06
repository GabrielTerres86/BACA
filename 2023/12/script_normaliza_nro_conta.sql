begin
  
  update gestaoderisco.tbcc_historico_juros_adp his
     set his.nrdconta = 89505832
   where his.cdcooper = 1 
     and his.nrdconta = 10494103;
     
  commit;
  
exception
  when others then
    rollback;
  
end;
