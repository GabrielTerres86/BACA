BEGIN
  --
  DELETE FROM crapace c WHERE c.nmdatela = 'PARDBT' AND c.cddopcao = '@';

  FOR rec_cooperativa IN (SELECT DISTINCT a.cdcooper cooperativa                          
                            FROM crapace a
                           WHERE a.nmdatela = 'ATENDA'
                             AND a.idevento = 0
                             AND a.idambace = 2
                             AND a.cdcooper = 3) LOOP
    FOR rec_user IN (SELECT 'f0030400' usuario FROM dual UNION ALL
                     SELECT 'f0030250' usuario FROM dual UNION ALL
                     SELECT 'f0030344' usuario FROM dual UNION ALL
                     SELECT 'f0030463' usuario FROM dual) LOOP
      
      FOR rec_acoes IN (SELECT 'I' acao FROM dual UNION ALL
                        SELECT 'A' acao FROM dual UNION ALL
                        SELECT 'C' acao FROM dual UNION ALL
                        SELECT 'E' acao FROM dual) LOOP
          INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
               VALUES ('PARDBT', rec_acoes.acao, rec_user.usuario, ' ', rec_cooperativa.cooperativa, 12, 0, 2);
      END LOOP;      
    END LOOP;  
  END LOOP;
  COMMIT;
END;  
