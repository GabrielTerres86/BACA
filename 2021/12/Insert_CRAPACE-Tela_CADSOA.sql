BEGIN
  --Permissões da tela CADSOA
  INSERT INTO CRAPACE
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,IDAMBACE)
    SELECT 'CADSOA'
          ,'C'
          ,'f0033330'
          ,' '
          ,3
          ,2
      FROM dual
     WHERE NOT EXISTS (SELECT 1
              FROM CRAPACE
             WHERE NMDATELA = 'CADSOA'
               AND CDDOPCAO = 'C'
               AND CDOPERAD = 'f0033330');

  INSERT INTO CRAPACE
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,IDAMBACE)
    SELECT 'CADSOA'
          ,'A'
          ,'f0033330'
          ,' '
          ,3
          ,2
      FROM dual
     WHERE NOT EXISTS (SELECT 1
              FROM CRAPACE
             WHERE NMDATELA = 'CADSOA'
               AND CDDOPCAO = 'A'
               AND CDOPERAD = 'f0033330');
  COMMIT;
END;
