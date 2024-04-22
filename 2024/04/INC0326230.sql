begin  
  update autorizador.proposta  
  set id_analista = 0
  where id = 7269404;
  commit;  
end;