BEGIN
  INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM crappat)
         ,'HISTORICOS_CONTRATO_CRED/GARANTIDO/PF/PJ/01F,02F,07F,11F,14F,16F,01G,02G,07G,11G,14G,16G'
         ,2
         ,0);
  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_CONTRATO_CRED/GARANTIDO/%')
      ,3
      ,'4263');

  COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 