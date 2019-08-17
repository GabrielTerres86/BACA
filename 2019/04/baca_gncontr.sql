UPDATE gncontr g
   SET dtmvtolt = to_date('02/04/2019','dd/mm/rrrr')
 WHERE g.dtmvtolt = to_date('03/04/2019','dd/mm/rrrr')
   AND g.tpdcontr = 4;   
