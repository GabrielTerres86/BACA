DECLARE
    CURSOR cr_crapcop IS
        SELECT cdcooper
              ,flgativo
          FROM crapcop
         WHERE cdcooper <> 3
         ORDER BY cdcooper DESC;

BEGIN

    --Limpa registros
    DELETE FROM crapprm prm WHERE prm.cdacesso = 'CRD_PZ_EXP_NOTI_CANAIS';

    FOR rw_crapcop IN cr_crapcop LOOP
        dbms_output.put_line(rw_crapcop.cdcooper);
        
      INSERT INTO crapprm
             (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
        VALUES
            ('CRED'
            ,rw_crapcop.cdcooper
            ,'CRD_PZ_EXP_NOTI_CANAIS'
            ,'Prazo em quantidade de dias para que as notificações (Transaçõies Pendentes) e propostas expirem - Aprovação por Canais'
            ,'10');
    END LOOP;
    COMMIT;
END;
