DECLARE
  aux_cdpartar_add  crappat.cdpartar%TYPE;
BEGIN
  SELECT MAX(cdpartar)+1 INTO aux_cdpartar_add FROM crappat;
  insert into CECRED.crappat(cdpartar,nmpartar,tpdedado,cdprodut) values (aux_cdpartar_add,'UF_LICENCIAMENTO',2,13);
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, 'SC,PR,RS');
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, 'SC,PR,RS');        
  insert into CECRED.crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, 'SC,PR,RS');                       
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN 
   NULL;  
END;
