begin
update crapbpr
set UFLICENC = 'RN'
where cdcooper = 1
and   nrdconta = 12340871
and   NRCTRPRO = 4236244;

commit;
end;
/
