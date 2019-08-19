UPDATE gncontr g
   SET dtmvtolt = to_date('11/06/2019','dd/mm/rrrr')
 WHERE g.dtmvtolt = to_date('12/06/2019','dd/mm/rrrr')
   AND g.tpdcontr = 4;   
