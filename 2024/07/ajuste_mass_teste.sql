begin

update crapass set cdsitdct = 4
   where cdcooper =1
     and progress_recid in (783152,
                            1077442,
                            1088739,
                            1159765,
                            1211264,
                            1245240,
                            1273936,
                            1275900,
                            1277610);
							
							
commit;
end;