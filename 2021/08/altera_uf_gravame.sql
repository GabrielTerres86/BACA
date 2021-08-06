begin

update crapbpr
set  UFLICENC= 'RN'
where cdcooper = 1
and   nrdconta = 11079789
and   nrctrpro in (4259619);

update crawepr    epr
set epr.flgdocdg=1
       where epr.cdcooper=1
         and epr.nrdconta=11187387
         and epr.nrctremp=4259622;

                            
commit;
end;
/
