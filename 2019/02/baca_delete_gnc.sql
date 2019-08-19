DELETE gncontr 
 WHERE tpdcontr = 4
   AND dtmvtolt = '03/04/2019';
   
DELETE gncvuni 
 WHERE tpdcontr = 2
   AND flgproce = 0
   AND dtmvtolt = '03/04/2019';
   
COMMIT;
