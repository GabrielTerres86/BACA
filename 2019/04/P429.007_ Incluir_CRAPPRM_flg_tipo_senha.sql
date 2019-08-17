DECLARE
    CURSOR cr_crapcop IS
        SELECT cdcooper
              ,flgativo
          FROM crapcop
         WHERE cdcooper <> 3
         ORDER BY cdcooper DESC;

BEGIN

    --Limpa registros
    DELETE FROM crapprm prm WHERE prm.cdacesso = 'SENHA_SUPERVISOR_CRD';

    FOR rw_crapcop IN cr_crapcop LOOP
        dbms_output.put_line(rw_crapcop.cdcooper);
    
        INSERT INTO crapprm
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'SENHA_SUPERVISOR_CRD'
            ,'Ativar/Desativar a senha do supervisor na criacao de proposta de cartão de credito. (o - desativada e 1 - ativada)'
            ,rw_crapcop.flgativo);
    
    END LOOP;

    COMMIT;
END;
