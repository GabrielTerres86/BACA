BEGIN
  INSERT INTO cecred.crapfer(dtferiad,
                             cdcooper,
                             tpferiad,
                             dsferiad)
                     VALUES (to_Date('02/01/2024','dd/mm/yyyy')
                            ,8
                            ,1
                            ,'feriado testes');
  
  COMMIT;
  
END;
