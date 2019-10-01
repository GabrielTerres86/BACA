--Baca para adicionar novo parametro no Ayllos e Web 
DECLARE
  
  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
     
BEGIN
  
  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP

    BEGIN
     INSERT INTO crapprm (
        nmsistem
        , cdcooper
        , cdacesso
        , dstexprm
        , dsvlrprm
        ) values (
				'CRED'
        ,rw_crapcop.cdcooper
        ,'REAGEND_JOB_UTLZ_CRD_EML'
        ,'Salvar email de notificacao de reagendamento do JOB jbcrd_importa_utlz_cartao'
        ,'guilherme.cervo@supero.com.br'
				);
      
    EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Erro ao criar Parametrizacao: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao criar Parametrizacao: '||SQLERRM);
    END;
    
  END LOOP;
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Parametrizacao criada com sucesso');
  
END;
