begin
  
FOR rw_crapcop IN (SELECT cdcooper FROM crapcop) LOOP 

insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
values ('RCONSI', 3, 'C,R', 'Controle dos erros de Consignado', 'Controle dos erros de Consignado', 0, 1, ' ', 'CONSULTA,REENVIO', 0, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);

END LOOP;

  COMMIT;
end;