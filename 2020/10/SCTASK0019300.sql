BEGIN
  INSERT INTO crapprm (nmsistem,
                       cdcooper,
                       cdacesso,
                       dstexprm,
                       dsvlrprm)
    VALUES ('CRED', 3, 'HABILITA_LOG_CARTAO', 'Habilita LOG Cart�o via trigger - TBCRD_LOG_CARTAO (1 - Ativado / 2 - Desativado)', 0);
  COMMIT;
END;
