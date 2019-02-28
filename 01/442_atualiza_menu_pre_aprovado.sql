DECLARE
  idx PLS_INTEGER := 1;
  
BEGIN
  dbms_output.put_line('Inicializando...');

  UPDATE craptel
  SET tldatela = 'Pre Aprovado'
     ,tlrestel = 'Pre Aprovado'
     ,nmrotina = 'PRE APROVADO'
  WHERE UPPER(nmdatela) LIKE UPPER('atenda')
     AND nrmodulo = 1
     AND UPPER(tlrestel) LIKE UPPER('Desabilitar Operacoes');
  
  dbms_output.put_line('Contador => ' || SQL%ROWCOUNT);
  
  IF SQL%ROWCOUNT = 0 THEN
    WHILE idx <= 17 LOOP
      
      dbms_output.put_line('INSERT => ' || idx);
    
      INSERT INTO craptel(nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina,lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, nrdnivel, idambtel)
         VALUES('ATENDA', 1, '@,A', 'Pre Aprovado', 'Pre Aprovado', 0, 1, 'PRE APROVADO', 'ACESSO,ALTERACAO', 2, idx, 1, 0, 33, 1, 2);
    
      idx := idx + 1;
    END LOOP;
  END IF;
  
  dbms_output.put_line('... finalizando!');
     
  COMMIT;
END;
