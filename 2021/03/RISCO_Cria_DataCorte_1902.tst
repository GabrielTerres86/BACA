PL/SQL Developer Test script 3.0
83
DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat cr_crapbat%ROWTYPE;

  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;

BEGIN


-----------------------------
  -- VERIFICAR SE JA EXISTE, E APAGAR
  OPEN cr_crapbat('DATACORTE_1902');
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

  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Carta Circular 4062 - Limite 1902', 4, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DATACORTE_1902', 'INFORMA DATA DE CORTE PARA LIMITE 1902', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '30/04/2021');
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, '30/04/2021');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '30/04/2021');
-----------------------------
COMMIT;


END;
0
1
aux_cdpartar_add
