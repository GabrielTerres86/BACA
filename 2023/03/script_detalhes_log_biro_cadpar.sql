BEGIN
 
  INSERT INTO crappat
  (CDPARTAR
  ,NMPARTAR
  ,TPDEDADO
  ,CDPRODUT)
  VALUES
  ((SELECT MAX(cdpartar) + 1 FROM crappat)
  ,'HABDESDETLOGBIRO - Habilitar/Desabilitar detalhes de erros de consultas biro'
  ,2
  ,0);
       
  INSERT INTO crappco
  (CDPARTAR
  ,CDCOOPER
  ,DSCONTEU)
  VALUES
  ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HABDESDETLOGBIRO%')
  ,3
  ,'S');                 
                        
  COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;  

   
