BEGIN
  UPDATE cecred.craplau
     SET cdcritic = 739,
         dtdebito = to_date('23/08/2024', 'dd/mm/yyyy'),
         insitlau = 3
   WHERE progress_recid IN (SELECT a.progress_recid
                              FROM cecred.craplau a, cecred.gnconve g
                             WHERE a.insitlau = 1
                               AND a.dtmvtopg = to_date('23/08/2024', 'dd/mm/yyyy')
                               AND g.cdhisdeb = a.cdhistor
                               AND g.cdcooper = 3);
  COMMIT;
END;