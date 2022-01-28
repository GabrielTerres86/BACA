DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat cr_crapbat%ROWTYPE;
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1; 

  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;

BEGIN

  -- VERIFICAR SE JA EXISTE, E APAGAR
  OPEN cr_crapbat('RISCOJUR60ADP');
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

  -- ----- Ativa��o ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Calculo de risco - Define se deve realizar calculo de juros 60 usando tabela de hist. ou lan�amentos,  Historico(1) ou lcm(2)', 1, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('RISCOJUR60ADP', 'Calculo de risco - Define se deve realizar calculo de juros 60 usando tabela de hist. ou lan�amentos', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 0, '1');
  
-----------------------------

  COMMIT;

END;
