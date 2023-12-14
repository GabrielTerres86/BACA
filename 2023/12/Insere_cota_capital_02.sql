begin
  
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta in (17703204)
    and cdcooper = 1;
    
  commit;
  
exception
  when others then
    raise_application_error(-20000, 'erro ao inserir cota: ' || sqlerrm);
end;