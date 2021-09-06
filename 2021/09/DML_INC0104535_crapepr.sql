BEGIN
  -- Menos de 3 segundos
  UPDATE crapepr epr
     SET epr.dtdpagto = to_date('28/' || to_char(epr.dtdpagto, 'MM/RRRR'), 'DD/MM/RRRR')
   WHERE epr.progress_recid IN
         (SELECT x.progress_recid
            FROM crapepr x
                ,crapass a
           WHERE x.cdcooper = 9
             AND x.cdcooper = a.cdcooper
             AND x.nrdconta = a.nrdconta
             AND a.cdagenci = 28
             AND to_char(x.dtdpagto, 'DD') > 28);

  -- Menos de 2 segundos
  UPDATE crawepr wpr
     SET wpr.dtdpagto = to_date('28/' || to_char(wpr.dtdpagto, 'MM/RRRR'), 'DD/MM/RRRR')
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
             AND to_char(e.dtdpagto, 'DD') > 28);

  COMMIT;

  -- Menos de 2 segundos
  UPDATE crappep pep
     SET pep.dtvencto = to_date('28/' || to_char(pep.dtvencto, 'MM/RRRR'), 'DD/MM/RRRR')
   WHERE pep.progress_recid IN
         (SELECT e.progress_recid
            FROM crapepr x
                ,crapass a
                ,crawepr e
                ,crappep p 
           WHERE x.cdcooper = 9
             AND x.cdcooper = a.cdcooper
             AND x.nrdconta = a.nrdconta
             AND x.cdcooper = e.cdcooper
             AND x.nrdconta = e.nrdconta
             AND x.nrctremp = e.nrctremp
             AND p.cdcooper = e.cdcooper
             AND p.nrdconta = e.nrdconta
             AND p.nrctremp = e.nrctremp
             AND p.inliquid = 0
             AND a.cdagenci = 28
             AND to_char(p.dtvencto, 'DD') > 28);

  COMMIT;

END;
