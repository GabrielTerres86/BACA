UPDATE crapepr e
    SET e.vltariof = e.vliofepr
  WHERE e.vltariof = 0
    AND e.vliofepr > 0
    AND e.tpemprst = 1
    AND e.cdfinemp = 68
    AND e.cdorigem IN (3, 4)
    AND ((e.cdcooper = 1 AND e.cdlcremp IN (7002, 7003, 7011, 7113)) OR
        (e.cdcooper = 2 AND e.cdlcremp IN (834, 7003, 7000, 7001)) OR
        (e.cdcooper = 5 AND
        e.cdlcremp IN (304, 7000, 305, 302, 635, 7000, 7001)) OR
        (e.cdcooper = 6 AND e.cdlcremp IN (7000, 44, 7001)) OR
        (e.cdcooper = 7 AND e.cdlcremp IN (7000, 7001, 3696, 3697)) OR
        (e.cdcooper = 8 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 9 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 10 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 10 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 11 AND
        e.cdlcremp IN (281, 7000, 7001, 336, 335, 283, 345)) OR
        (e.cdcooper = 12 AND e.cdlcremp IN (7000, 7001, 116, 118)) OR
        (e.cdcooper = 13 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 14 AND e.cdlcremp IN (7000, 7001)) OR
        (e.cdcooper = 16 AND
        e.cdlcremp IN (7000, 7001, 1025, 1002, 2002, 2025)));

