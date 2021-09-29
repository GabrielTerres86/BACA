BEGIN
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, PROGRESS_RECID, CDPRODUT)
  values (124, 'ENVIO SMS TOKEN CREDITO DIGITAL', 1, 2215, 0);
    
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 1, '0', 3423);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 2, '0', 3424);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 3, '0', 3425);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 5, '0', 3426);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 6, '0', 3427);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 7, '0', 3428);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 8, '0', 3429);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 9, '0', 3430);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 10, '0', 3431);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 11, '0', 3432);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 12, '0', 3433);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 13, '0', 3434);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 14, '0', 3435);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU, PROGRESS_RECID)
  values (124, 16, '0', 3436);  
  
  commit;
  EXCEPTION
    WHEN OTHERS THEN
     RAISE_application_error(-20500,SQLERRM);
     rollback;
END;
