DECLARE
  CURSOR cr_crapcop IS
    SELECT a.cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
     ORDER BY a.cdcooper;
BEGIN
  DELETE 
    FROM cecred.crapaca a
   WHERE a.nmdeacao IN ('TAB089_CONSULTAR_ACORDO', 'TAB089_ALTERAR_ACORDO')
     AND a.nmpackag = 'TELA_TAB089';

  DELETE 
    FROM cecred.crapprm a
   WHERE a.cdacesso IN ('FL_ATIVAR_ACORDO_MOBILE', 
                        'FL_ATIVAR_ACORDO_CNTONL', 
                        'QT_CARENCI_ACORDO_MOBILE',
                        'QT_CARENC_ACORDO_DIGITAL');

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('TAB089_CONSULTAR_ACORDO'
    ,'TELA_TAB089'
    ,'pc_consultar_acordo'
    ,NULL
    ,1084);

  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('TAB089_ALTERAR_ACORDO'
    ,'TELA_TAB089'
    ,'pc_alterar_acordo'
    ,'pr_flatmobi,pr_flatconl,pr_qtdiacar'
    ,1084);

  FOR rw_crapcop IN cr_crapcop LOOP
    INSERT INTO cecred.crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,rw_crapcop.cdcooper
      ,'FL_ATIVAR_ACORDO_MOBILE'
      ,'Ativar Mobile - Acordo Digital'
      ,'0');
  
    INSERT INTO cecred.crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,rw_crapcop.cdcooper
      ,'FL_ATIVAR_ACORDO_CNTONL'
      ,'Ativar Conta Online - Acordo Digital'
      ,'0');
  
    INSERT INTO cecred.crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,rw_crapcop.cdcooper
      ,'QT_CARENC_ACORDO_DIGITAL'
      ,'Dias Carência Venc. Inicial - Acordo Digital'
      ,'0');
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
