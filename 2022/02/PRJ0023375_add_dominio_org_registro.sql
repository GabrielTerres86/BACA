BEGIN
 
  INSERT INTO tbcadast_dominio_campo(nmdominio
                                    ,cddominio
                                    ,dscodigo)  
                              VALUES('ORG_REGISTRO_JUR'
                                    ,'1'
                                    ,'JUNTA COMERC');
 
  INSERT INTO tbcadast_dominio_campo(nmdominio
                                    ,cddominio
                                    ,dscodigo)  
                              VALUES('ORG_REGISTRO_JUR'
                                    ,'2'
                                    ,'OAB');
 
  INSERT INTO tbcadast_dominio_campo(nmdominio
                                    ,cddominio
                                    ,dscodigo)  
                              VALUES('ORG_REGISTRO_JUR'
                                    ,'3'
                                    ,'CART TIT DOC');
 
  INSERT INTO tbcadast_dominio_campo(nmdominio
                                    ,cddominio
                                    ,dscodigo)  
                              VALUES('ORG_REGISTRO_JUR'
                                    ,'4'
                                    ,'REG CIVIL PJ');

  COMMIT;
  
END;
