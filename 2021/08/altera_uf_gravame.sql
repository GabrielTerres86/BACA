begin

update crapbpr
set  UFLICENC= 'RN'
where cdcooper = 1
and   nrdconta = 11079789
and   nrctrpro in (4259619);

commit;
end;
/
