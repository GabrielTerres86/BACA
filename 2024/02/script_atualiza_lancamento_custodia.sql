begin
  update craplcm set progress_recid = progress_recid + 1000000000 
               where cdcooper = 1
                 and cdhistor = 21
                 and cdpesqbb like '%-600-%'
                 and dtmvtolt = '16/10/2023'
                 and progress_recid >= 2065048856 ;
  commit;
end;
