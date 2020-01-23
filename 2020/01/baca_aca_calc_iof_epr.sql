declare
begin
  update crapaca
     set lstparam = lstparam || ',pr_flgreneg'
   where nmdeacao='CALC_IOF_EPR';
   commit;
end;
