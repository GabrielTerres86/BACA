 begin
   delete from craplcm a
    where a.progress_recid in
          (2094766199, 2094766200, 2094764905, 2094764904);
   commit;
 
 end;
