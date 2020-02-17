--Baca para adicionar Data de corte ao novo termo de adesao Cartao 
DECLARE
  
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
     
BEGIN

  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP
    
    BEGIN
      
      
      insert into CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri)
      values (795, 1, 1, 'TERMO ABERTURA CONTA ENTE PUBLICO', 5, ' ', '132col', 0, rw_crapcop.cdcooper, 'Online', 1, 1, 1, ' ', null, null);
      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Item ja cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir TBGEN_VERSAO_TERMO: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Registos criados com sucesso!');
  
END;
