begin
  
FOR rw_crapcop IN (SELECT cdcooper FROM crapcop) LOOP 

insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
values ('SEGEMP', 3, 'C,A', 'Parâmetros Segmento Empréstimo', 'Parâmetros Segmento Empréstimo', 0, 1, ' ', 'CONSULTA,ALTERACAO', 0, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);

END LOOP;

  COMMIT;
end;