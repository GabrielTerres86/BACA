UPDATE cecred.craptab
   SET dstextab = '10000,00'
 WHERE craptab.nmsistem = 'CRED'
   AND craptab.tptabela = 'GENERI'
   AND craptab.cdempres = 0
   AND craptab.cdacesso = 'VLCTRMVESP'
   AND craptab.tpregist = 0;
COMMIT;