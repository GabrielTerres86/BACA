begin

update cecred.craptab b
  set b.dstextab = 'srvp003kofax01 Fsr#@de3652d7f21' 
where b.nmsistem = 'CRED'
  and b.tptabela = 'GENERI'
  and b.Cdempres = 0
  and b.cdacesso = 'TRUNCAGEM'
  and B.CDCOOPER = 3;
  
commit;
end;
  
