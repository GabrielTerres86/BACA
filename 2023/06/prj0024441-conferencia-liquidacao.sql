DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17);
  
  pr_cdcooper INTEGER;

BEGIN

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);

    INSERT INTO craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, 
                           IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    VALUES ('PCRCMP', 5, 'C,A,M', 'CONCILIACAO ACMP', 'CONCILIACAO ACMP', 0, 1, ' ', 'CONSULTAR,ALTERAR,MANUTENCAO', 1, pr_cdcooper, 1, 0, 1, 1, ' ', 2);
    
    
    
    INSERT INTO crapace(nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
    VALUES ('PCRCMP', 'C', 't0034369', ' ', pr_cdcooper, 1, 0, 2);
  
  END LOOP;
    
  INSERT INTO crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, 
                       NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  VALUES ('CRED', 'PCRCMP', 'Conciliação ACMP', null, null, null, 1, 998, 1, 0, 0, 0, 0, 0, 0, 3, null);

  
  INSERT INTO craprdr (nmprogra, dtsolici)
       VALUES ('TELA_PCRCMP',SYSDATE);

  INSERT INTO crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
       VALUES ('LISTA_CONCILIACAO', 'TELA_PCRCMP', 'pc_lista_conciliacao', 'pr_dtmovimento', (select nrseqrdr from craprdr where nmprogra = 'TELA_PCRCMP'));

  COMMIT;
END;