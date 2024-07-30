begin
  update cecred.crawepr c
    set  c.flgdocdg = 1
  where c.cdcooper = 1
  and c.nrdconta = 92416454
  and c.nrctremp = 8149903;

  commit;
end;