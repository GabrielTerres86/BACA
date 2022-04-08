begin
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (162, 'Bloquear debito de emprestimo consignado pelo debitador', 1,0);
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (162, 3, '0');
  
  commit;
end;
