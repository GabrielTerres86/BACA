delete
  FROM crapavt a
 WHERE cdcooper = 1 
   AND nrdconta IN  ( 6961843, 10946411, 2021269, 6914586, 7260970 )
   and tpctrato = 6
   and dtvalida <= trunc( sysdate ) ;
 

 
delete
  FROM crapavt a
 WHERE cdcooper = 2
   AND nrdconta IN  ( 749818, 592579, 816817 )
   and tpctrato = 6
   and dtvalida <= trunc( sysdate ) ;  
   
   
   commit;