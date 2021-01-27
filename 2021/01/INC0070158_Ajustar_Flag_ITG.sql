BEGIN
  
  -- Remover o flag de enviada de todas as contas que n�o tem c�digo de ITG gerado
  UPDATE crapass t
     SET t.flgctitg = 3 -- Inativar 
       , t.nrdctitg = ' ' 
   WHERE t.flgctitg = 1
     AND TRIM(t.nrdctitg) IS NULL ;
     
  COMMIT;
 
END;
