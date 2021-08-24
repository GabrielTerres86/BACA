begin

update crawepr    epr
set epr.flgdocdg=1
where epr.cdcooper=1
and   epr.nrdconta = 6419771
and   epr.nrctremp = 4259674;

update crawepr    epr
set epr.flgdocdg=1
where epr.cdcooper=1
and   epr.nrdconta = 12340871
and   epr.nrctremp = 4259673;

commit;
end;
/
