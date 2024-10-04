begin
  
delete cecred.crappro p
where PROGRESS_RECID in (775829145,775988367,786650121);

commit;
end;
