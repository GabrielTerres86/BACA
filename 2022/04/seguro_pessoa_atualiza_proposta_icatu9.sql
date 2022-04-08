begin
  update tbseg_nrproposta p
     set p.tpcustei = 0
   where p.dhseguro is null
     and p.tpcustei = 1
     and rownum between 1 and 8000;
  commit;
end;
/
