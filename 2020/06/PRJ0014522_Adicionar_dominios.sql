BEGIN 
  
  /* ADICIONAR DOMINIOS SITUAÇÃO CPF */
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('SITUACAO_RECEITA_FEDERAL'
                                    ,'1'
                                    ,'Regular');

  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('SITUACAO_RECEITA_FEDERAL'
                                    ,'2'
                                    ,'Pendente');
  
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('SITUACAO_RECEITA_FEDERAL'  
                                    ,'3'
                                    ,'Cancelado');
  
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('SITUACAO_RECEITA_FEDERAL'
                                    ,'4'
                                    ,'Irregular');
  
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('SITUACAO_RECEITA_FEDERAL'
                                    ,'5'
                                    ,'Suspenso');
  
  /* ADICIONAR DOMINIOS DE TIPO DE DOCUMENTO */
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'CI'
                                    ,'Carteira de Identidade');
                                    
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'CN'
                                    ,'Certidão de Nascimento');
                                    
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'CH'
                                    ,'Carteira de Habilitação');
                                    
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'RE'
                                    ,'Registro Nacional de Estrangeiro');
                                    
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'PP'
                                    ,'Passaporte');
                                    
  INSERT INTO TBCADAST_DOMINIO_CAMPO(nmdominio
                                    ,cddominio
                                    ,dscodigo)
                             VALUES ('TIPO_DOC_IDENTIFICACAO'
                                    ,'CT'
                                    ,'Carteira de Trabalho');
                                    
                       
  COMMIT;
END;
