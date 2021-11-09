BEGIN
  
  INSERT INTO tbcadast_dominio_campo
                  (nmdominio
                  ,cddominio
                  ,dscodigo)
           VALUES ('STATUS_MENSAGEM'
                  ,1
                  ,'PENDENTE');

  INSERT INTO tbcadast_dominio_campo
                  (nmdominio
                  ,cddominio
                  ,dscodigo)
           VALUES ('STATUS_MENSAGEM'
                  ,2
                  ,'PROCESSADA');

  INSERT INTO tbcadast_dominio_campo
                  (nmdominio
                  ,cddominio
                  ,dscodigo)
           VALUES ('STATUS_MENSAGEM'
                  ,3
                  ,'ERRO');

  COMMIT;

END;
