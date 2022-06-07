begin

  update crapjur set natjurid = 3999 where cdcooper = 1 and nrdconta = 13933914;
  update crapjur set natjurid = 0 where cdcooper = 1 and nrdconta = 11332999;

  commit;

end;