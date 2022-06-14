BEGIN

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_DEB_CANCELA_ADM_SFH'
    ,2
    ,0);

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_DEB_CANCELA_ADM_SFI'
    ,2
    ,0);
    
  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_DEB_CANCELA_ADM_SFH')
    ,3
    ,'3884');

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_DEB_CANCELA_ADM_SFI')
    ,3
    ,'3885');    
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    ROLLBACK;
END;
