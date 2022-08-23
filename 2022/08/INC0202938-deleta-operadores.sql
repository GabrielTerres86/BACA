begin
  delete cecred.crapopi 
    where nrdconta = 14672146 and nrcpfope in 
    (239863011
    ,83454713072
    ,305730096
    ,96894776091
    ,69908982087
    ,160489032)
    and cdcooper = 1;
  commit;
end;
