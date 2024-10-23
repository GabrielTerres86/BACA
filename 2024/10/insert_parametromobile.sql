BEGIN
  INSERT INTO CECRED.PARAMETROMOBILE (PARAMETROMOBILEID, NOME, DESCRICAO, VALOR, SISTEMA) VALUES (61, 'GravarLogEstatisticaMobile', 'Flag que determina se deve ocorrer a gravação de log da estatisticamobile', 1, 1);
  COMMIT;   
END;