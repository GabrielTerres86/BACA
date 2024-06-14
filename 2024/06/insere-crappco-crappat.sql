BEGIN
  
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (305, 'IFRS9 - Exibir Produto TR', 1, 0);

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (306, 'IFRS9 - Habilitar nova contabilizacao TOPAZ', 1, 0);

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (307, 'IFRS9 - Produtos habilitados TOPAZ', 2, 0);

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (308, 'IFRS9 - Habilitar convivencia dos produtos no TOPAZ', 1, 0);

  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (310, 'IFRS9 - Produto TOPAZ para emprestimo', 2, 0);
  
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 7, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 16, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 12, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 6, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 9, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 1, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 2, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 13, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 3, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 10, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 14, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 5, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 8, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (305, 11, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (306, 3, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (307, 3, ' ');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 16, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 10, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 1, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 5, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 11, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 9, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 8, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 7, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 2, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 3, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 14, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 13, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 12, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (308, 6, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (310, 3, '600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629');


  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;

