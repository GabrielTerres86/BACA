DECLARE
BEGIN

  FOR rw_crapcop IN ( SELECT * FROM crapcop )LOOP
 
      insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
      values ('TELUNI', 5, 'C', 'Tela Única de Análise', 'Tela Única de Análise', 0, 1, ' ', 'CONSULTAR', 1, rw_crapcop.cdcooper, 1, 0, 1, 1, ' ', 2);
      
      insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER)
      values ('CRED', 'TELUNI', 'Tela Única de Análise', ' ', ' ', ' ', 50, (SELECT MAX(g.nrordprg)+1 FROM crapprg g WHERE g.cdcooper = rw_crapcop.cdcooper AND g.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, rw_crapcop.cdcooper);
      
  END LOOP;
  
  COMMIT;
END;