DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP
  
    --Adicionar novo tipo de permissao - importacao manual Limite de credito
    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',X'
          ,t.lsopptel = t.lsopptel || ',IMP. MAN LIM'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'IMPPRE';
  
    -- Replicar permissoes de acesso 
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'IMPPRE'
            ,'X'
            ,ope.cdoperad
            ,' '
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND UPPER(ace.nmdatela) = 'IMPPRE'
         AND UPPER(ace.cddopcao) = 'L'
         AND ope.cdsitope = 1
         AND ace.cdcooper = rw_crapcop.cdcooper;
  
  END LOOP;
  
  UPDATE crapaca a
     SET a.lstparam = a.lstparam || ',pr_tpctrlim'
   WHERE a.nmpackag = 'TELA_IMPPRE'
     AND a.nmdeacao = 'EXEC_CARGA_MANUAL';

  COMMIT;

END;
