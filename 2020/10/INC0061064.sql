begin

update cecred.crapblj
   set dtblqfim = '16/05/2018'
 where nrdconta = 149861
   and cdcooper = 7
   and nroficio = 2018000285803700002
   and dtblqfim is null;

commit;

end;