BEGIN
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
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
     325
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
     325
     , 3
     , 'https://www.ailos.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 5
     , 'https://www.acentra.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 6
     , 'https://www.unilos.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 7
     , 'https://www.credcrea.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 8
     , 'https://www.credelesc.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 9
     , 'https://www.transpocred.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 10
     , 'https://www.credicomin.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 11
     , 'https://www.credifoz.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 12
     , 'https://www.crevisc.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 13
     , 'https://www.civia.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 14
     , 'https://www.evolua.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  INSERT INTO CECRED.crappco
  (
     CDPARTAR
     , CDCOOPER
     , DSCONTEU
  )
  VALUES
  (
     325
     , 16
     , 'https://www.viacredialtovale.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro no script de inser crappco: ' || SQLERRM);
    ROLLBACK;
END;
