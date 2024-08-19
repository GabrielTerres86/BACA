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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
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
     319
     , 16
     , 'https://www.viacredialtovale.coop.br/wp-content/uploads/2023/07/Guia-dos-Investimentos-Ailos-1.pdf'
  );
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro no script de inser crappco: ' || SQLERRM);
    ROLLBACK;
END;
