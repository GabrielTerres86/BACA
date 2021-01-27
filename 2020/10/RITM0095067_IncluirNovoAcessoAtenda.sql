DECLARE 

  -- Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT t.cdcooper
      FROM crapcop t 
     WHERE t.flgativo = 1;
     
BEGIN

  FOR rg_crapcop IN cr_crapcop LOOP
    
    INSERT INTO CECRED.CRAPTEL
      (NMDATELA
      ,NRMODULO
      ,CDOPPTEL
      ,TLDATELA
      ,TLRESTEL
      ,FLGTELDF
      ,FLGTELBL
      ,NMROTINA
      ,LSOPPTEL
      ,INACESSO
      ,CDCOOPER
      ,IDSISTEM
      ,IDEVENTO
      ,NRORDROT
      ,NRDNIVEL
      ,NMROTPAI
      ,IDAMBTEL)
    VALUES
      ('ATENDA'
      ,5
      ,'@'
      ,'Revisão Cadastral'
      ,'Revisão Cadastral'
      ,0
      ,1
      ,'REVISAO_CADASTRAL'
      ,'ACESSO'
      ,2
      ,rg_crapcop.cdcooper
      ,1
      ,0
      ,60
      ,1
      ,' '
      ,2);

  END LOOP;
  
  -- 
  COMMIT;

END;
