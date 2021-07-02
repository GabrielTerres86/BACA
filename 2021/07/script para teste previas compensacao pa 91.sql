BEGIN
  --
  UPDATE craptit t
     SET t.dtdpagto = to_date('02/07/2021','dd/mm/yyyy'),
         t.dtmvtolt = to_date('02/07/2021','dd/mm/yyyy'),
         t.flgenvio = 0,
         t.cdbcoenv = 0
  WHERE t.cdcooper = 16
       AND t.dtdpagto = to_date('18/05/2021','dd/mm/yyyy')
       AND t.insittit = 4
       AND t.cdagenci = 91;
  

COMMIT;

END;       
