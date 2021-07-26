DECLARE
  aux_cdpartar_add  crappat.cdpartar%TYPE;
BEGIN
  SELECT MAX(cdpartar)+1 INTO aux_cdpartar_add FROM crappat;
  insert into crappat(cdpartar,nmpartar,tpdedado,cdprodut) values (aux_cdpartar_add,'LINFIN_IMOBILIARIO',2,13);
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '10000,100');
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '10000,100');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
   NULL;
END;
