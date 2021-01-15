begin
  update crapass c
     set c.cdsitdct = 5
   where c.nrdconta = 11830166
     and c.cdcooper = 1;
  commit;
end;
