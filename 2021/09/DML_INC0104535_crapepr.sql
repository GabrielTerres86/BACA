BEGIN
  
  UPDATE crapepr epr
     SET epr.dtdpagto = to_date('10/' || to_char(epr.dtdpagto, 'MM/RRRR'), 'DD/MM/RRRR')
   WHERE epr.progress_recid IN
         (SELECT x.progress_recid
            FROM crapepr x
                ,crapass a
           WHERE x.cdcooper = 9
             AND x.cdcooper = a.cdcooper
             AND x.nrdconta = a.nrdconta
             AND a.cdagenci = 28
             AND to_char(x.dtdpagto, 'DD') <> 10
             AND (x.inliquid = 0 OR (x.inprejuz = 1 AND x.vlsdprej > 0)));

  UPDATE crawepr wpr
     SET wpr.dtdpagto = to_date('10/' || to_char(wpr.dtdpagto, 'MM/RRRR'), 'DD/MM/RRRR')
   WHERE wpr.progress_recid IN
         (SELECT e.progress_recid
            FROM crapepr x
                ,crapass a
                ,crawepr e
           WHERE x.cdcooper = 9
             AND x.cdcooper = a.cdcooper
             AND x.nrdconta = a.nrdconta
             AND x.cdcooper = e.cdcooper
             AND x.nrdconta = e.nrdconta
             AND x.nrctremp = e.nrctremp
             AND e.dtdpagto IS NOT NULL
             AND a.cdagenci = 28
             AND to_char(e.dtdpagto, 'DD') <> 10
             AND (x.inliquid = 0 OR (x.inprejuz = 1 AND x.vlsdprej > 0)));

  COMMIT;
             
END;           
