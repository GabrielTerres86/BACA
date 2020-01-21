DECLARE
  
  -- Cursor para percorrer todas as cooperativas
  CURSOR cr_crapcop IS
    SELECT t.cdcooper
      FROM crapcop t
     WHERE t.flgativo = 1
     ORDER BY t.cdcooper;
  
BEGIN
  
  -- Percorrer as cooperativas para atualizar uma por vez
  FOR rg_coop IN cr_crapcop LOOP
    
    BEGIN
      UPDATE crapass t 
         SET t.incadpos = 2 -- Autorizado
       WHERE (t.cdsitdct <> 4 OR t.dtdemiss IS NULL)
         AND t.cdcooper = rg_coop.cdcooper;
    EXCEPTION 
      WHEN OTHERS THEN
        raise_application_error(-20000,'Erro ao atualizar cooperativa: '||rg_coop.cdcooper||' - '||SQLERRM);
    END;
    
  --  dbms_output.put_line( to_char(SYSDATE,'HH24:MI:SS') || ' - Atualizado '||SQL%ROWCOUNT||' registros da cooperativa: '||rg_coop.cdcooper);
    
    COMMIT;
    
  END LOOP;


END;
 
