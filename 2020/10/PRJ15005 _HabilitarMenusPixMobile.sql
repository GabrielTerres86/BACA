INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1016,1009,'Lista de Pagamentos Pix',1,0,1,'2.12.1.0',NULL);

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1017,1009,'Pix Copia e Cola',1,0,1,'2.12.1.0',NULL);

UPDATE menumobile SET habilitado = 1 WHERE menumobileid = 1011;
UPDATE menumobile SET habilitado = 1 WHERE menumobileid = 1012;
UPDATE menumobile SET habilitado = 0 WHERE menumobileid = 1014;
    
COMMIT;