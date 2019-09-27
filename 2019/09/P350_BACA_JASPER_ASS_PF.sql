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
        insert into CECRED.CRAPREL (
                cdrelato
                , nrviadef
                , nrviamax
                , nmrelato
                , nrmodulo
                , nmdestin
                , nmformul
                , indaudit
                , cdcooper
                , periodic
                , tprelato
                , inimprel
                , ingerpdf
                , dsdemail
                , cdfilrel
                , nrseqpri ) values (
                782
                , 1
                , 1
                , 'CADA ASSINATURA PF'
                , 5
                , ' '
                , '80col'
                , 0
                , rw_crapcop.cdcooper
                , 'Online'
                , 1
                , 1
                , 1
                , ' '
                , null
                , null 
        );
 
      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Relatorio cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir relatorio: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Relatorio adicionado com sucesso.');
  
END;