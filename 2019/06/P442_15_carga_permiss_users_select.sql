BEGIN
  /* Carga de permissões para usuários selecionados na CADMOT. */
  FOR rw_ope IN (SELECT ope.cdoperad
                FROM crapope ope 
                WHERE ope.cdsitope = 1
                  AND ope.cdcooper = 3
                  AND ope.cdoperad IN ('f0030835'
                                      ,'f0030567'
                                      ,'f0031401'
                                      ,'f0030689'
                                      ,'f0032069'
                                      ,'f0030516'
                                      ,'f0032113'
                                      ,'f0020517'
                                      ,'f0032631')) LOOP
    BEGIN
      INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
        VALUES('CADMOT', '@', rw_ope.cdoperad, ' ', 3, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
        VALUES('CADMOT', 'A', rw_ope.cdoperad, ' ', 3, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
        VALUES('CADMOT', 'I', rw_ope.cdoperad, ' ', 3, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  
  /* Carga de permissões para usuários selecionados na CADPRE */
  DELETE crapace ace
  WHERE ace.nmdatela = 'CADPRE'
    AND ace.cdoperad IN ('f0030835'
                        ,'f0030567'
                        ,'f0031401'
                        ,'f0030689'
                        ,'f0032069'
                        ,'f0030516'
                        ,'f0032113'
                        ,'f0020517'
                        ,'f0032631');
  
  FOR rw_ope IN (SELECT ope.cdoperad
                       ,ope.cdcooper
                FROM crapope ope 
                WHERE ope.cdsitope = 1
                  AND ope.cdoperad IN ('f0030835'
                                      ,'f0030567'
                                      ,'f0031401'
                                      ,'f0030689'
                                      ,'f0032069'
                                      ,'f0030516'
                                      ,'f0032113'
                                      ,'f0020517'
                                      ,'f0032631')) LOOP
    BEGIN
      INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
        VALUES('CADPRE', 'C', rw_ope.cdoperad, ' ', rw_ope.cdcooper, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
        VALUES('CADPRE', 'A', rw_ope.cdoperad, ' ', rw_ope.cdcooper, 1, 0, 2);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
  
  COMMIT;
END;