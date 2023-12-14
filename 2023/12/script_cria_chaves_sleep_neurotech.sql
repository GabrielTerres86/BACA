BEGIN
  DELETE FROM crappco WHERE CDPARTAR IN (SELECT cdpartar FROM CREDITO.crappat WHERE nmpartar IN ('CHAVE_LIGA_SLEEP_RETORNO_NEURO','CHAVE_VALOR_SLEEP_RETORNO_NEURO'));
  DELETE FROM crappat WHERE NMPARTAR IN ('CHAVE_LIGA_SLEEP_RETORNO_NEURO','CHAVE_VALOR_SLEEP_RETORNO_NEURO');
COMMIT;

  INSERT INTO crappat
      (CDPARTAR
      ,NMPARTAR
      ,TPDEDADO
      ,CDPRODUT)
    VALUES
      ((SELECT MAX(cdpartar) + 1 FROM crappat)
      ,'CHAVE_LIGA_SLEEP_RETORNO_NEURO'
      ,2
      ,0);

  COMMIT;
    
    INSERT INTO crappco
      (CDPARTAR
      ,CDCOOPER
      ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'CHAVE_LIGA_SLEEP_RETORNO_NEURO')
      ,3
      ,'S');
	  
  COMMIT;
 
     INSERT INTO crappat
      (CDPARTAR
      ,NMPARTAR
      ,TPDEDADO
      ,CDPRODUT)
    VALUES
      ((SELECT MAX(cdpartar) + 1 FROM crappat)
      ,'CHAVE_VALOR_SLEEP_RETORNO_NEURO'
      ,1
      ,0);

  COMMIT;
     
    INSERT INTO crappco
      (CDPARTAR
      ,CDCOOPER
      ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'CHAVE_VALOR_SLEEP_RETORNO_NEURO')
      ,3
      ,1);  
	  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;