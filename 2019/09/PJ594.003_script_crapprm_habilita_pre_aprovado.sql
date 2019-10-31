DECLARE
    CURSOR cr_crapcop IS
        SELECT cdcooper
              ,flgativo
          FROM crapcop
         WHERE cdcooper <> 3
         ORDER BY cdcooper DESC;

BEGIN

    --Limpa registros
    DELETE FROM crapprm prm WHERE prm.cdacesso = 'HABILITAPREAPROV';

    FOR rw_crapcop IN cr_crapcop LOOP
    
        INSERT INTO crapprm
            (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'HABILITAPREAPROV'
            ,'Ativar/Desativar opcao de pre aprovado na cooperativa (0 - desativada e 1 - ativada)'
            ,rw_crapcop.flgativo);
    
    END LOOP;

    COMMIT;
END;

