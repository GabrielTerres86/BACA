 begin
   delete from craplcm a
   WHERE a.cdcooper = 8
   AND a.nrdconta = 99969505
   and a.cdpesqbb = '000092435138;000000009999888;00000045;991172';
   commit;
 
 end;
