begin
  update crapcot c
     set c.vlirfrdc##9 = c.vlirfrdc##9 - 1336.31
   where c.cdcooper = 8
     and c.nrdconta = 41173;

  commit;
end;