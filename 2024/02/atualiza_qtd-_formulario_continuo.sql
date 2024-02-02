begin

update  cecred.craptab
  set craptab.dstextab = '60000' 
WHERE craptab.cdcooper = 1 
  AND craptab.nmsistem = 'CRED' 
  AND craptab.tptabela = 'GENERI'
  AND craptab.cdempres = 0 
  AND craptab.cdacesso = 'FORMCONTINUO'
  AND craptab.tpregist = 0;
  
commit;
end;  
