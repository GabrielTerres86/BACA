UPDATE gncontr g
   SET dtmvtolt = to_date('07/02/2019','dd/mm/rrrr')
 WHERE g.dtmvtolt = to_date('08/02/2019','dd/mm/rrrr')
   AND g.tpdcontr = 4;   
