begin
  update cecred.crapavt avt
  set avt.nrdctato = 0
  where avt.nrdconta = 84817445
    and avt.cdcooper = 1;
  commit;
end;
