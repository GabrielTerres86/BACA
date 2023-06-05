DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cop.cdcooper
                       FROM cecred.crapcop cop
                      WHERE cop.flgativo = 1) LOOP
    UPDATE cecred.craptel tel
       SET tel.cdopptel = tel.cdopptel || ',NP'
          ,tel.lsopptel = tel.lsopptel || ',ALTERAR NR PORTAB'
     WHERE tel.cdcooper = rw_crapcop.cdcooper
       AND UPPER(tel.nmdatela) = 'ATENDA'
       AND UPPER(tel.nmrotina) = 'EMPRESTIMOS';
  END LOOP;

  INSERT INTO cecred.crapace
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,NRMODULO
    ,IDEVENTO
    ,IDAMBACE)
    (SELECT 'ATENDA'
           ,'NP'
           ,ope.cdoperad
           ,'EMPRESTIMOS'
           ,cop.cdcooper
           ,1
           ,0
           ,2
       FROM cecred.crapcop cop
      INNER JOIN (SELECT CASE LEVEL
                          WHEN 1 THEN
                           'F0033479'
                          WHEN 2 THEN
                           'F0033754'
                          WHEN 3 THEN
                           'F0033078'
                          WHEN 4 THEN
                           'F0034370'
                          WHEN 5 THEN
                           'F0034361'
                          WHEN 6 THEN
                           'f0034476'
                        END AS cdoperad
                   FROM DUAL
                 CONNECT BY LEVEL IN (1, 2, 3, 4, 5, 6)) ope
         ON 1 = 1
      WHERE cop.flgativo = 1);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('ATUALIZA_NR_PORTAB'
    ,NULL
    ,'credito.atualizarNrPortabWeb'
    ,'pr_nrdconta,pr_nrctremp,pr_nrunico_portabilidade'
    ,71);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
