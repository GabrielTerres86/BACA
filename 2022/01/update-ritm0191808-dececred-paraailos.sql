BEGIN
update craptab
   set dstextab = REPLACE(dstextab,'cecred','ailos')
 where nmsistem = 'CRED'
   and tptabela = 'GENERI'
   and cdempres = 0
   and cdacesso = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
END;

