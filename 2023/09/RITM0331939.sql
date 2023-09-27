BEGIN
    INSERT INTO cecred.menumobile 
    (menumobileid, menupaiid, nome, sequencia, habilitado, autorizacao, versaominimaapp) 
    VALUES 
    (1052, 40, 'Preciso de ajuda', 3, 1, 0, '2.55.11');
    COMMIT;
END;