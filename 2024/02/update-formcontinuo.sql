  
begin
update cecred.craptab b
  set b.dstextab = '20000'  
where b.cdacesso like '%FORMCONTINUO%'; 
  
commit;
end;  
