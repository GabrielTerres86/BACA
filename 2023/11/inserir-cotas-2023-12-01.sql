begin
  
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta in ( 89796870, 89823958, 89796845 )
    and cdcooper = 1;
    
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta = 99494850
    and cdcooper = 16;
    
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta = 99312646
    and cdcooper = 2;
  
    
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta = 99893100
    and cdcooper = 14;
  
  commit;
  
exception
  when others then
    raise_application_error(-20000, 'erro ao inserir cota: ' || sqlerrm);
end;
