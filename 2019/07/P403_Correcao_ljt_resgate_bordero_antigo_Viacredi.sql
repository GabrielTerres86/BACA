BEGIN
  FOR r_ljt IN (SELECT ljt.rowid, ljt.vldjuros, ljt.vlrestit, ljt.progress_recid
                  FROM craptdb tdb
                 INNER JOIN crapbdt bdt ON bdt.cdcooper = tdb.cdcooper
                                       AND bdt.nrborder = tdb.nrborder
                 INNER JOIN crapljt ljt ON ljt.nrdconta = tdb.nrdconta
                                       AND ljt.nrborder = tdb.nrborder
                                       AND ljt.cdcooper = tdb.cdcooper
                                       AND ljt.cdbandoc = tdb.cdbandoc
                                       AND ljt.nrdctabb = tdb.nrdctabb
                                       AND ljt.nrcnvcob = tdb.nrcnvcob
                                       AND ljt.nrdocmto = tdb.nrdocmto
                 WHERE bdt.flverbor = 0
                   AND tdb.cdcooper = 1
                   AND tdb.insittit = 1
                   AND tdb.dtresgat >= to_date('16/01/2019','DD/MM/RRRR')
                   AND ljt.dtrefere > last_day(tdb.dtresgat)
                   AND ljt.vldjuros > 0
                UNION ALL
                SELECT ljt.rowid, ljt.vldjuros, ljt.vlrestit, ljt.progress_recid
                  FROM craptdb tdb
                 INNER JOIN crapbdt bdt ON bdt.cdcooper = tdb.cdcooper
                                       AND bdt.nrborder = tdb.nrborder
                 INNER JOIN crapljt ljt ON ljt.nrdconta = tdb.nrdconta
                                       AND ljt.nrborder = tdb.nrborder
                                       AND ljt.cdcooper = tdb.cdcooper
                                       AND ljt.cdbandoc = tdb.cdbandoc
                                       AND ljt.nrdctabb = tdb.nrdctabb
                                       AND ljt.nrcnvcob = tdb.nrcnvcob
                                       AND ljt.nrdocmto = tdb.nrdocmto
                 WHERE bdt.flverbor = 0
                   AND tdb.cdcooper = 1
                   AND tdb.insittit = 1
                   AND tdb.dtresgat >= to_date('16/01/2019','DD/MM/RRRR')
                   AND ljt.dtrefere = last_day(tdb.dtresgat)
                   AND ljt.vldjuros = 0
                ORDER BY progress_recid )
  LOOP
    UPDATE crapljt ljt
       SET vldjuros = r_ljt.vlrestit
          ,vlrestit = r_ljt.vldjuros
     WHERE ljt.rowid = r_ljt.rowid;
  END LOOP;
  
  COMMIT;
END;
