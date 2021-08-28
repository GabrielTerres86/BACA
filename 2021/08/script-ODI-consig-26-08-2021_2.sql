begin

update CRAPPEP
set vlmrapar = 15.89
where nrdconta = 117412
and nrparepr = 10 
and cdcooper = 13 ;

commit;

end;