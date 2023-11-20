begin
delete
  from crapseg p
 where p.progress_recid in (
1476639,
1480485,
1485088
);
commit;
end;
/
