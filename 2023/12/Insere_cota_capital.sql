begin
  
  UPDATE crapcot
    SET vldcotas = 1000
  WHERE nrdconta in (
      17699169,
      17699096,
      17702984,
      17702992,
      17703000,
      17703018,
      17703026,
      17703034,
      17703042,
      17701511,
      17700043,
      17700027,
      17699550
    )
    and cdcooper = 1;
    
  commit;
  
exception
  when others then
    raise_application_error(-20000, 'erro ao inserir cota: ' || sqlerrm);
end;
