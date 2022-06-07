begin
  
  update crapass a
    set a.cdtipcta = 21
  where a.nrdconta in (14688867, 14689723, 14690918, 14691485)
    and a.cdcooper = 1;
    
  commit;
    
exception
  when others then
    raise_application_error(-20000, 'ERRO: ' || SQLERRM);
end;
