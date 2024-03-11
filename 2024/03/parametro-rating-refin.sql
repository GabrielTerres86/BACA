DECLARE
  aux_cdpartar_add  crappat.cdpartar%TYPE;
BEGIN
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM crappat;
 
  aux_cdpartar_add :=  aux_cdpartar_add + 1;
 
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'RATING - Utiliza regra de refin para RATING do motor (0-Desligado/1-Ligado)', 2, 13);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('RATING', 'RATING - Utiliza regra de refin para RATING do motor (0-Desligado/1-Ligado)', ' ', 2, aux_cdpartar_add);
           
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3,  '1');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
