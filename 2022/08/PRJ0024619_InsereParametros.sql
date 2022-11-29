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
                        'TP_DESC_AVISTA_ACORDO',
                        'TP_DESC_PARCEL_ACORDO');

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
    ,'pr_flatmobi,pr_flatconl,pr_tpdavist,pr_tpdparce'
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
      ,'TP_DESC_AVISTA_ACORDO'
      ,'Considerar Desconto à Vista Tipo Acordo - Acordo Digital'
      ,'1');
  
    INSERT INTO cecred.crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,rw_crapcop.cdcooper
      ,'TP_DESC_PARCEL_ACORDO'
      ,'Considerar Desconto Parcelado Tipo Acordo - Acordo Digital'
      ,'1');
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
