-- RITM0077902 - TELA DE PARÂMETRO PARA SIMULAÇÃO DE EMPRÉSTIMOS/ FINANCIAMENTOS.

--------------------- Permissoes ---------------------
DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',R'
          ,t.lsopptel = t.lsopptel || ',RISCO SIMULACAO'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'LCREDI';
  
               
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'LCREDI'
            ,'R'
            ,ope.cdoperad
            ,' '
            ,ope.cdcooper
            ,1
            ,1
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'LCREDI'
         AND UPPER(ace.cddopcao) = 'A'
         AND UPPER(ace.nmrotina) = ' '
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;

  END LOOP;
COMMIT;
END;


