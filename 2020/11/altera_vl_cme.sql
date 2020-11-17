UPDATE cecred.craptab
   SET dstextab = '2000,01'
 WHERE craptab.cdcooper = 11
   AND craptab.nmsistem = 'CRED'
   AND craptab.tptabela = 'GENERI'
   AND craptab.cdempres = 0
   AND craptab.cdacesso = 'VLCTRMVESP'
   AND craptab.tpregist = 0;
COMMIT;