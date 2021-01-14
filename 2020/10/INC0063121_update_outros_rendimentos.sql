begin
  update crapttl t 
     set t.tpdrendi##1 = nvl(t.tpdrendi##1, 0)
       , t.tpdrendi##2 = nvl(t.tpdrendi##2, 0)
       , t.tpdrendi##3 = nvl(t.tpdrendi##3, 0)
       , t.tpdrendi##4 = nvl(t.tpdrendi##4, 0)
       , t.tpdrendi##5 = nvl(t.tpdrendi##5, 0)
       , t.tpdrendi##6 = nvl(t.tpdrendi##6, 0)
       , t.vldrendi##1 = nvl(t.vldrendi##1, 0.00)
       , t.vldrendi##2 = nvl(t.vldrendi##2, 0.00)
       , t.vldrendi##3 = nvl(t.vldrendi##3, 0.00)
       , t.vldrendi##4 = nvl(t.vldrendi##4, 0.00)
       , t.vldrendi##5 = nvl(t.vldrendi##5, 0.00)
       , t.vldrendi##6 = nvl(t.vldrendi##6, 0.00)
   where t.nrdconta = 358312
     and t.cdcooper = 9;
   commit;
end;
