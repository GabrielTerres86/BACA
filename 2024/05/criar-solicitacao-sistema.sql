BEGIN
  INSERT INTO crapsol(nrsolici,
                      dtrefere,
                      nrseqsol,
                      cdcooper)       
               VALUES(9
                     ,to_date('05/04/2024','dd/mm/yyyy')
                     ,1
                     ,1);
  
  COMMIT;
END;
