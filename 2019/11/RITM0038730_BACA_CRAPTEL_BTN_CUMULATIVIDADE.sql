--Baca para adicionar nova tela no Ayllos e Web 
DECLARE
  
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
     
BEGIN
  
  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP
       
    -- Inserir a tela CRAPTEL na tabela de programas
    BEGIN
         UPDATE craptel t 
            SET t.cdopptel = t.cdopptel || ',T', t.lsopptel = t.lsopptel || ',CUMULATIVIDADE'
          WHERE t.cdcooper = rw_crapcop.cdcooper 
            AND t.nmdatela = 'CONTAS' 
            AND t.nmrotina = 'GRUPO ECONOMICO';
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Tela PRMCRD cadastrada: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir PRMCRD: '||SQLERRM);
    END;

  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Tela CONTAS alterada com sucesso!');
  
END;
