begin

  /* Cooperativa => 1 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 1, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 2 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 2, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 5 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 5, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 6 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 6, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 7 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 7, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 8 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 8, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 9 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 9, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 10 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 10, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 11 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 11, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 12 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 12, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 13 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 13, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 14 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 14, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  /* Cooperativa => 16 */  
  INSERT INTO CRAPTEL (nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrdnivel, nmrotpai, idambtel)
  SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, 16, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
  FROM craptel tel
  WHERE tel.cdcooper = 3
  AND UPPER(tel.nmdatela) = 'MANPRT';

  commit;

end;

/*
SELECT tel.nmdatela, tel.nrmodulo, tel.cdopptel, tel.tldatela, tel.tlrestel, tel.flgteldf, tel.flgtelbl, tel.nmrotina, tel.lsopptel, tel.inacesso, tel.cdcooper, tel.idsistem, tel.idevento, tel.nrdnivel, tel.nmrotpai, tel.idambtel
FROM craptel tel
WHERE tel.cdcooper >= 0
AND UPPER(tel.nmdatela) = 'MANPRT' 
for update*/
