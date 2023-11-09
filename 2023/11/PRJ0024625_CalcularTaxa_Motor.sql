DECLARE
    CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat cr_crapbat%ROWTYPE;
  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;
BEGIN

  OPEN cr_crapbat('CALCULARTAXA_7');
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
  values (aux_cdpartar_add, 'CALCULARTAXA_7 - Renegociacao ', 2, 13);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('CALCULARTAXA_7', 'CALCULARTAXA_7 - Renegociacao', 0, 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3,  '0');

  COMMIT;
  
  OPEN cr_crapbat('CALCULARTAXA_8');
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
  values (aux_cdpartar_add, 'CALCULARTAXA_8 - Consignado', 2, 13);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('CALCULARTAXA_8', 'CALCULARTAXA_8 - Consignado', 0, 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3,  '0');

  COMMIT;
  
  OPEN cr_crapbat('CALCULARTAXA_9');
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
  values (aux_cdpartar_add, 'CALCULARTAXA_9 - Imobiliario', 2, 13);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('CALCULARTAXA_9', 'CALCULARTAXA_9 - Imobiliario', 0, 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3,  '0');

  COMMIT;
 
END;
