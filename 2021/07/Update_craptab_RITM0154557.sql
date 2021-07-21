update craptab craptab 
  set craptab.dstextab = '02730 0 17:00'
WHERE craptab.cdcooper = 3 
  AND craptab.nmsistem = 'CRED'           
  AND craptab.tptabela = 'GENERI'         
  AND craptab.cdempres = 00               
  AND craptab.cdacesso = 'NRARQRTSER'     
  AND craptab.tpregist = 002;
commit;
