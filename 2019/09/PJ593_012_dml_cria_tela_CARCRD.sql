--Baca para adicionar nova tela no Ayllos e Web 
DECLARE
  
  aux_rsprogra  VARCHAR2(50) := 'OFERTA E CONTRATACAO DO CARTAO';
  aux_nmdatela  VARCHAR2(50) := 'CARCRD';
  aux_dsprogra  VARCHAR2(50) := 'OFERTA E CONTRATACAO DO CARTAO';
  aux_cdopcoes  VARCHAR2(50) := '@,C';
  aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';

  aux_nrordprg  NUMBER;
  
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
     
BEGIN
  
  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP

    BEGIN
      SELECT NVL(MAX(prg.nrordprg),0) + 1 
        INTO aux_nrordprg
        FROM crapprg prg
       WHERE prg.cdcooper = rw_crapcop.cdcooper
         AND prg.nrsolici = 50;
    EXCEPTION
      WHEN no_data_found THEN  -- Se o select n o encontrar registros
        aux_nrordprg := 1;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000,'Erro ao buscar NRORDPRG: '||SQLERRM);
    END;
         
    -- Inserir a tela PARECC na tabela de programas
    BEGIN
      INSERT INTO crapprg(cdcooper
                         ,cdprogra
                         ,dsprogra##1
                         ,inctrprg
                         ,inlibprg
                         ,nmsistem
                         ,nrordprg
                         ,nrsolici)
                   VALUES(rw_crapcop.cdcooper
                         ,aux_nmdatela
                         ,aux_dsprogra
                         ,1 /* nao executado */
                         ,1 /* liberado */
                         ,'CRED'
                         ,aux_nrordprg
                         ,50);
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Programa j  cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPPRG: '||SQLERRM);
    END;
    
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
                         ,idsistem)
                  VALUES (rw_crapcop.cdcooper
                         ,aux_nmdatela
                         ,aux_cdopcoes
                         ,aux_dsopcoes
                         ,aux_dsprogra
                         ,aux_rsprogra
                         ,5
                         ,0
                         ,1
                         ,1
                         ,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
                         ,2    /* 0 - todos , 1 - ayllos , 2 - web */
                         ,1);  /* 1 - ayllos, 2 - progrid */ 
      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Tela j  cadastrada: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPTEL: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Tela '||aux_nmdatela||' criado com sucesso!');
  
END;
