BEGIN
  
  INSERT INTO tbcadast_dominio_campo(nmdominio,
                                     cddominio,
                                     dscodigo)
                             VALUES ('TPPREFERATENDIMENTO'
                                    ,'1'
                                    ,'PA');
                                      
  INSERT INTO tbcadast_dominio_campo(nmdominio,
                                     cddominio,
                                     dscodigo)
                             VALUES ('TPPREFERATENDIMENTO'
                                    ,'2'
                                    ,'Visita');
                                      
  INSERT INTO tbcadast_dominio_campo(nmdominio,
                                     cddominio,
                                     dscodigo)
                             VALUES ('TPPREFERATENDIMENTO'
                                    ,'3'
                                    ,'Digital');
                                    
  COMMIT;
  
END;
