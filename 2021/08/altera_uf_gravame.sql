begin

update crawepr    epr
set epr.flgdocdg=1
where epr.cdcooper=1
and   epr.nrdconta = 6814190
and   epr.nrctremp = 4259627;

update crawepr    epr
set epr.flgdocdg=1
where epr.cdcooper=1
and   epr.nrdconta = 11187387
and   epr.nrctremp = 4259631;
                            
commit;
end;
/
