BEGIN
  --Permissões da tela PARINV
  INSERT INTO CRAPACE
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,IDAMBACE)
    SELECT 'PARINV'
          ,'C'
          ,'f0033330'
          ,' '
          ,3
          ,2
      FROM dual
     WHERE NOT EXISTS (SELECT 1
              FROM CRAPACE
             WHERE NMDATELA = 'PARINV'
               AND CDDOPCAO = 'C'
               AND CDOPERAD = 'f0033330');

  INSERT INTO CRAPACE
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,IDAMBACE)
    SELECT 'PARINV'
          ,'A'
          ,'f0033330'
          ,' '
          ,3
          ,2
      FROM dual
     WHERE NOT EXISTS (SELECT 1
              FROM CRAPACE
             WHERE NMDATELA = 'PARINV'
               AND CDDOPCAO = 'A'
               AND CDOPERAD = 'f0033330');
  COMMIT;
END;
