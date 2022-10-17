DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM cecred.crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat        cr_crapbat%ROWTYPE;
  aux_cdpartar_add  cecred.crappat.cdpartar%TYPE;
  aux_cdpartar_del  cecred.crappat.cdpartar%TYPE;
BEGIN
  OPEN cr_crapbat('CONTAAILOSCERC');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM cecred.crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM cecred.crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM cecred.crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;
  COMMIT;
 
  aux_cdpartar_add :=  193;
 
  insert into cecred.crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'CONTAAILOSCERC - Numero da conta de pagamento ailos cerc', 2, 13);

  insert into cecred.crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('CONTAAILOSCERC', 'Numero da conta de pagamento ailos cerc ', ' ', 2, aux_cdpartar_add);
           
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9,  '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '12345-6');
  insert into cecred.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '12345-6');
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,SQLERRM);
 
END;


