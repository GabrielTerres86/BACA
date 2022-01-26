BEGIN
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 0, 'FLG_UTL_API_PV_SICREDI', 'Ativar/Desativar a execução através do SOA para renovação da prova de vida.(S - ativada e N - desativada)', 'S');
    COMMIT;
END;
