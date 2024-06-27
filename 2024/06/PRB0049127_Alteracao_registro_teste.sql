                           
begin
  update craptit set nrautdoc = 0
   where progress_recid in (231720376, 231720379, 231720377, 231720378);
  --
  update crapaut set dslitera = ' '
   where progress_recid in (1084809975, 1084809978, 1084809976, 1084809977);
  commit;
exception
  when others then
    null;
end;