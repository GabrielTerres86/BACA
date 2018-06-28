-- Task 6933
update craphis a set INTRANSF_CRED_PREJUIZO=0
where cdhistor in (1998,1999,2000,2277,2278,2279);
commit;
