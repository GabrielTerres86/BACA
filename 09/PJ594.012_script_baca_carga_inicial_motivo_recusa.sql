-- Cargas dos dominios de endereco para envio do cartao do cooperado
INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
VALUES ('MOTNAOAUTORIZACAO', '1', 'Limite divergente da solicitação', 1);

INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
VALUES ('MOTNAOAUTORIZACAO', '2', 'Modalidade do cartão divergente da solicitação', 1);

INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
VALUES ('MOTNAOAUTORIZACAO', '3', 'Desinteresse da solicitação do cartão', 1);

INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
VALUES ('MOTNAOAUTORIZACAO', '4', 'Endereço divergente do solicitado', 1);

INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
VALUES ('MOTNAOAUTORIZACAO', '5', 'Prazo de autorização excedido', 1);

-- Cargas na tabela generica de parametros
