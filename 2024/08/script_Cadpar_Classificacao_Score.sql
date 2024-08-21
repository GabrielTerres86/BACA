DECLARE
    CURSOR cr_crapbat(pr_cdbattar IN cecred.crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM cecred.crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat cr_crapbat%ROWTYPE;
  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;
BEGIN

  OPEN cr_crapbat('NOVOCRORERATING');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM cecred.crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM cecred.crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM cecred.crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;
  COMMIT;
  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM cecred.crappat;

  aux_cdpartar_add :=  aux_cdpartar_add + 1;

  insert into cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Habilita|Desabilita Classificação Score Rating', 2, 13);

  insert into cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('NOVOCRORERATING', 'Habilita|Desabilita Classificação Score Rating', 0, 2, aux_cdpartar_add);

  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)  
  values (aux_cdpartar_add, 5,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9,  '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '1');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '1');
  
  COMMIT;
 
END;
