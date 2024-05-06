DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM crapbat
     WHERE cdbattar = pr_cdbattar;
     
  rw_crapbat cr_crapbat%ROWTYPE;
  
  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;
  
BEGIN
  
  OPEN cr_crapbat('RITM0360379');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;
  
  COMMIT;
  
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM crappat;

  aux_cdpartar_add :=  aux_cdpartar_add + 1;

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'RITM0360379 - Linhas de credito que nao permitem financiar IOF/Tarifa', 2, 0);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('RITM0360379', 'RITM0360379 - Linhas de credito que nao permitem financiar IOF/Tarifa', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9,  '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '2600|2610');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '2600|2610');

  COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    ROLLBACK;
		RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;
