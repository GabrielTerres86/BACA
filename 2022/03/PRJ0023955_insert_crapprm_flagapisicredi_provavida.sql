BEGIN
    INSERT INTO crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES ('CRED', 0, 'FLG_UTL_API_PV_SICREDI', 'Ativar/Desativar a execu��o atrav�s do SOA para renova��o da prova de vida.(S - ativada e N - desativada)', 'S');
    COMMIT;
END;
