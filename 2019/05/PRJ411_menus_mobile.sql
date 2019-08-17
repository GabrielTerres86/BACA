-- Aplicação Programada
INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (604,600,'Aplicações',1,1,0,'2.0.0.0',NULL);

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (605,600,'Aplicação Programada',2,1,0,'2.2.0.0',NULL);

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (606,605,'Incluir',1,1,1,'2.2.0.0',NULL);

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (607,605,'Resgatar',2,1,1,'2.2.0.0',NULL);

UPDATE menumobile SET menupaiid = 604 WHERE menumobileid IN (602, 603);

-- Reformulação Cadastral
INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1003,40,'Reformulação Cadastral',2,1,1,'2.2.0.0',NULL);
