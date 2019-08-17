/******************************************************************************************************** 
  Baca para inserir valores na tabela de parametros crapprm
  -----------------
   Autor: Anderson-Alan (Supero)                                 Data: 16/01/2019
  -----------------
*********************************************************************************************************/

DECLARE

    CURSOR cr_crapprm IS
        SELECT *
          FROM crapprm
         WHERE crapprm.cdacesso = 'COBEMP_VLR_MIN_PP';
    rw_crapprm cr_crapprm%ROWTYPE;

BEGIN

    FOR rw_crapprm IN cr_crapprm LOOP
      INSERT INTO crapprm
                (nmsistem
                ,cdcooper
                ,cdacesso
                ,dstexprm
                ,dsvlrprm)
            VALUES
                (rw_crapprm.nmsistem
                ,rw_crapprm.cdcooper
                ,'COBEMP_VLR_MIN_POS'
                ,'Valor minimo do boleto para contratos POS'
                ,rw_crapprm.dsvlrprm);
                
    END LOOP;

    dbms_output.put_line('FIM');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Erro: ' || SQLERRM);
        ROLLBACK;
END;
