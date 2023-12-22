begin
   delete from craplcm 
   WHERE NRDCONTA in (99969505,82665990) AND CDPESQBB = 'teste deposito varejista';
   commit;
 end;