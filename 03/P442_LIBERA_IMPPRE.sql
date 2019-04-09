DECLARE
  idx PLS_INTEGER := 1;
  
BEGIN
  WHILE idx <= 17 LOOP
    IF idx <> 3 THEN
      INSERT INTO craptel(nmdatela
                         ,nrmodulo
                         ,cdopptel
                         ,tldatela
                         ,tlrestel
                         ,flgteldf
                         ,flgtelbl
                         ,lsopptel
                         ,inacesso
                         ,cdcooper
                         ,idsistem
                         ,idevento
                         ,nrordrot
                         ,nrdnivel
                         ,idambtel)
         VALUES('IMPPRE'
                ,6
                ,'I,M,E,D'
                ,'CRIACAO E IMPORTACAO DE CARGAS MANUAIS'
                ,'CRI/IMP DE CARGAS MANU.'
                ,0
                ,1
                ,'IMP.SAS,IMP.MAN,EXCLUIR,DETALHES'
                ,1
                ,idx
                ,1
                ,0
                ,1
                ,1
                ,2);
    END IF;
    
    idx := idx + 1;
  END LOOP;
  
  FOR rw_ope IN (SELECT ope.cdcooper
                       ,ope.cdoperad 
                   FROM crapope ope 
                 WHERE ope.cdsitope = 1) LOOP
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('IMPPRE', 'E', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('IMPPRE', 'M', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('IMPPRE', 'D', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
    
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES ('IMPPRE', 'C', rw_ope.cdoperad, rw_ope.cdcooper, 1, 0, 2);
  END LOOP;
  
  COMMIT;
END;
