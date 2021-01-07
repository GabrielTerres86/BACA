BEGIN

 INSERT INTO crapace(nmdatela,
                cddopcao,
                cdoperad,
                nmrotina,
                cdcooper,
                nrmodulo,
                idevento,
                idambace)
        (SELECT DISTINCT 
                'ATENDA'
              , '@'
              , UPPER(t.cdoperad)
              , 'REVISAO_CADASTRAL'
              , t.cdcooper
              , 1
              , 0
              , 2
           FROM crapace t
          WHERE t.nmdatela = 'CONTAS'
            AND NOT EXISTS (SELECT 1
                              FROM crapace x
                             WHERE x.cdcooper = t.cdcooper
                               AND UPPER(x.cdoperad) = UPPER(t.cdoperad)
                               AND x.nmdatela = 'ATENDA'
                               AND x.nmrotina = 'REVISAO_CADASTRAL'));

  COMMIT;
  
END;
