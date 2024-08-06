begin
  
update cecred.craptab
  set craptab.tpregist = 82921288
WHERE craptab.cdcooper = 12
  AND UPPER(craptab.nmsistem) = 'CRED'
  AND UPPER(craptab.tptabela) = 'GENERI'
  AND craptab.cdempres = 0
  AND UPPER(craptab.cdacesso) = 'BUSCADEVOLU';

commit;
end;
