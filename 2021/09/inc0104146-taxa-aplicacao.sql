begin
 update craplap
   set txaplmes = 111
 where progress_recid in (202897976, 201997623, 202921134,
                          192800509, 192608253, 192738047);
                          
 commit;
end;
