--Baca para adicionar nova tela no Ayllos e Web 
DECLARE

  aux_nmdatela VARCHAR2(50) := 'ATENDA';
  aux_tlrestel VARCHAR2(50) := 'Deposito Varejista';
  aux_nmrotina VARCHAR2(50) := 'DEPOSITO_VAREJISTA';
  aux_tldatela VARCHAR2(50) := 'Deposito Varejista';
  aux_cdopptel VARCHAR2(50) := '@,C,I,A,E';
  aux_lsopptel VARCHAR2(90) := 'ACESSO,CONSULTA,INCLUSAO,ALTERACAO,CANCELAR';
  aux_nrordrot NUMBER := 0;

  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT * FROM crapcop cop WHERE cop.flgativo = 1;

  -- Buscar registro maior numero da posicao no menu da tela atenda do elemento.
  CURSOR cr_craptel IS
    SELECT max(t.nrordrot) FROM craptel t WHERE t.nmdatela = 'ATENDA';

BEGIN

  -- Buscar nrordrot
  OPEN cr_craptel;
  FETCH cr_craptel
    INTO aux_nrordrot;
  IF cr_craptel%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro, Numero de indice nã encontrado: nrordrot' ||
                            SQLERRM);
  ELSE
    aux_nrordrot := aux_nrordrot + 1;
  END IF;
  CLOSE cr_craptel;

  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP
  
    -- Inserir a tela na tabela CRAPTEL
    BEGIN
      INSERT INTO craptel
        (cdcooper,
         nmdatela,
         nmrotina,
         cdopptel,
         lsopptel,
         tldatela,
         tlrestel,
         nrmodulo,
         inacesso,
         nrordrot,
         nrdnivel,
         idevento,
         idambtel,
         idsistem,
         flgteldf,
         flgtelbl)
      VALUES
        (rw_crapcop.cdcooper,
         aux_nmdatela,
         aux_nmrotina,
         aux_cdopptel,
         aux_lsopptel,
         aux_tldatela,
         aux_tlrestel,
         5,
         2,
         aux_nrordrot,
         1,
         0 /* 0 - na    , 1 - progrid, 2 - assemb */,
         2 /* 0 - todos , 1 - ayllos , 2 - web */,
         1 /* 1 - ayllos, 2 - progrid */,
         0,
         1);
    
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001, 'Tela ja cadastrada: ' || SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,
                                'Erro ao inserir CRAPTEL: ' || SQLERRM);
    END;
  
  END LOOP;

  COMMIT;

  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Tela ' || aux_nmdatela || ' > ' || aux_tlrestel || 'criado com sucesso!');

END;
