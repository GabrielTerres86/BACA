--Baca para adicionar nova tela no Ayllos e Web 
DECLARE
  
  aux_rsprogra  VARCHAR2(50) := 'Parametros do cartao';
  aux_nmdatela  VARCHAR2(50) := 'CARCRD';
  aux_dsprogra  VARCHAR2(50) := 'Parametros do cartao';
  aux_cdopcoes  VARCHAR2(50) := '@,C';
  aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
  aux_nmrotina  VARCHAR2(90) := 'PRMCRD';
  aux_nrmodulo  NUMBER       := 5;

  aux_nrordprg  NUMBER;
  
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
      INSERT INTO craptel(cdcooper
                         ,nmdatela
                         ,cdopptel
                         ,lsopptel
                         ,tldatela
                         ,tlrestel
                         ,nrmodulo
                         ,inacesso
                         ,nrordrot
                         ,nrdnivel
                         ,idevento
                         ,idambtel
                         ,idsistem
                         ,nmrotina)
                  VALUES (rw_crapcop.cdcooper
                         ,aux_nmdatela
                         ,aux_cdopcoes
                         ,aux_dsopcoes
                         ,aux_dsprogra
                         ,aux_rsprogra
                         ,aux_nrmodulo
                         ,0
                         ,1
                         ,1
                         ,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
                         ,2    /* 0 - todos , 1 - ayllos , 2 - web */
                         ,1    /* 1 - ayllos, 2 - progrid */ 
                         ,aux_nmrotina);  
      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Tela PRMCRD cadastrada: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir PRMCRD: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Tela '||aux_nmdatela||' criado com sucesso!');
  
END;
