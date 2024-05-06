BEGIN
   
 INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'CHAVE_LIGA_NOVO_AJUSTE_IBRATAN'
    ,1
    ,0);
        
  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'CHAVE_LIGA_NOVO_AJUSTE_IBRATAN')
    ,3
    ,1);

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;