INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1015,30,'Prevcoop',1,1,1,'2.14.0.0',NULL);

UPDATE menumobile SET versaominimaapp = '2.14.0.0' where menumobileid = 1004;
    
COMMIT;