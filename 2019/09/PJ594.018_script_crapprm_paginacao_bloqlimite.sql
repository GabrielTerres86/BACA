DECLARE
    CURSOR cr_crapcop IS
        SELECT cdcooper
              ,flgativo
          FROM crapcop
         WHERE cdcooper <> 3
         ORDER BY cdcooper DESC;

BEGIN

    --Limpa registros
    DELETE FROM crapprm prm WHERE prm.cdacesso = 'PAGINACAOHISTBLOQ';

    FOR rw_crapcop IN cr_crapcop LOOP
        
      INSERT INTO crapprm
             (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'PAGINACAOHISTBLOQ'
            ,'Defini a quantidade de registros apresentados na pagina de historicos'
            ,'10');
    END LOOP;
    COMMIT;
END;
