BEGIN
  INSERT INTO CECRED.crappat
  (
     CDPARTAR
     , NMPARTAR
     , TPDEDADO
     , CDPRODUT
  )
  VALUES
  (
     312
     , 'GUIA_INVESTIMENTO'
     , 2
     , 0
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 1
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 2
     , 'https://www.acredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 3
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 5
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 6
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 7
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 8
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 9
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 10
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 11
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 12
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 13
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 14
     , 'https://www.viacredi.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     312
     , 16
     , 'https://www.viacredialtovale.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro no script de teste de ajuste do ano bissexto no plano de cotas: ' || SQLERRM);
    ROLLBACK;
END;
