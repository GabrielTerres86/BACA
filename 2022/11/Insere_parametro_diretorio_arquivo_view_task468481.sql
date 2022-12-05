BEGIN
  INSERT INTO cecred.crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'Diretorio integracao sistema de repasses VCS (View)'
    ,2 
    ,0);
    
  INSERT INTO cecred.crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar = 'Diretorio integracao sistema de repasses VCS (View)')
    ,3
    ,'/usr/sistemas/Repasses/View/');            
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
