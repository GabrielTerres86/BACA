
DELETE
  from craplim
 where cdcooper = 1
   and nrdconta = 3605329 ;
   
UPDATE crapepr   
   SET inliquid = 1
 WHERE cdcooper = 1
   AND nrdconta = 3559238
   AND nrctremp = 804907;
   

commit;
