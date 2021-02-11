DECLARE
  aux_cdpartar_add  crappat.cdpartar%TYPE;
BEGIN
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM crappat;
  aux_cdpartar_add :=  aux_cdpartar_add + 1;
  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Valor Endividamento grupo crps627  - Ativo (1) ou Desativado (0)', 1, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('VLRINDIVGRU', 'VALOR INDIVIDAMENTO GRUPO RELATORIO 628', 'CRPS627', 1, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '0');
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, '0');
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, '0');
    
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, '0');  
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, '0');
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, '0');
   
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, '0');   

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, '0');    

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '0');
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '0');  

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '0');  

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '0');  
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, '0'); 
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '0');
       
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 17, '0');

  COMMIT;  

  
END;
