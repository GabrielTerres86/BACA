BEGIN
  --
  UPDATE craptit t
     SET t.dtdpagto = to_date('01/07/2021','dd/mm/yyyy'),
         t.dtmvtolt = to_date('01/07/2021','dd/mm/yyyy'),
         t.flgenvio = 0,
         t.cdbcoenv = 0
  WHERE t.cdcooper IN (6,13,16)
       AND t.dtdpagto = to_date('20/05/2021','dd/mm/yyyy')
       AND t.insittit = 4
       AND t.cdagenci = 91;
  

COMMIT;

END;       
