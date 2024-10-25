BEGIN
  INSERT INTO CECRED.PARAMETROMOBILE (NOME, DESCRICAO, VALOR, SISTEMA) VALUES ('GravarLogEstatisticaMobile', 'Flag que determina se deve ocorrer a gravação de log da estatisticamobile', 1, 1);
  COMMIT;   
END;