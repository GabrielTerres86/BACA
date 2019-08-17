DECLARE
  idx PLS_INTEGER := 1;
  
BEGIN
  WHILE idx <= 17 LOOP
    INSERT INTO craptel(nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina,lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, nrdnivel, idambtel)
        VALUES('ATENDA', 1, '@,A', 'Pre Aprovado', 'Pre Aprovado', 0, 1, 'PRE APROVADO', 'ACESSO,ALTERACAO', 2, idx, 1, 0, 33, 1, 2);
  
    idx := idx + 1;
  END LOOP;
  
  FOR rw_ope IN (SELECT ope.cdcooper
                       ,ope.cdoperad 
                   FROM crapope ope 
                 WHERE ope.cdsitope = 1) LOOP
    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    values ('ATENDA', '@', rw_ope.cdoperad, 'PRE APROVADO', rw_ope.cdcooper, 1, 0, 2);

    INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    values ('ATENDA', 'A', rw_ope.cdoperad, 'PRE APROVADO', rw_ope.cdcooper, 1, 0, 2);
  END LOOP;
  
  COMMIT;
END;
