begin

update crapbpr
set  UFLICENC= 'RN'
where cdcooper = 1
and   nrdconta = 6814190
and   nrctrpro = 4259627;
                            
commit;
end;
/
