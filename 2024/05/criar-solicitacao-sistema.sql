BEGIN
  INSERT INTO crapsol(nrsolici,
                      dtrefere,
                      nrseqsol,
                      cdcooper)       
               VALUES(9
                     ,to_date('13/05/2024','dd/mm/yyyy')
                     ,3
                     ,10);
  
  COMMIT;
END;
