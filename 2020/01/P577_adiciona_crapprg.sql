--Baca para adicionar nova tela no Ayllos e Web 
DECLARE
  
  aux_nmdatela  VARCHAR2(50) := 'RENEG';
  aux_dsprogra  VARCHAR2(50) := 'RENEGOCIACAO FACILITADA';

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
      WHEN no_data_found THEN  -- Se o select nAo encontrar registros
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
        RAISE_APPLICATION_ERROR(-20001,'Programa ja cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPPRG: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Programa '||aux_nmdatela||' criado com sucesso!');
  
END;
