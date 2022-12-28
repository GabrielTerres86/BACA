BEGIN
  
  INSERT INTO cecred.tbcadast_dominio_campo
                   (nmdominio
                   ,cddominio
                   ,dscodigo)
            VALUES ('TPREGIME_TRIBUTACAO'
                   ,6
                   ,'Isento');

  COMMIT;

END;
