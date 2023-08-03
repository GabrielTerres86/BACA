BEGIN

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 1, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '157');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 2, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '156');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 5, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '160');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 6, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '161');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 7, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '162');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 8, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '163');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 9, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '164');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 10, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '165');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 11, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '166');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 12, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '167');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 13, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '168');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 14, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '169');

    INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 16, 'CRED_PERFIL_SMARTSHARE', 'Configuração de acesso por cooperativa na pasta agilidade no smartshare', '171');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;