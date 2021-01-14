begin

update cecred.crapblj
   set dtblqfim = to_date('16/05/2018', 'dd/mm/rrrr')
 where nrdconta = 149861
   and cdcooper = 7
   and nroficio = 2018000285803700002
   and progress_recid in (31914, 32085)
   and dtblqfim is null;

commit;

end;