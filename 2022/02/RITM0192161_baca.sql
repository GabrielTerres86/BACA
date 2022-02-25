UPDATE craptab 
   SET craptab.DSTEXTAB = '43200'
 WHERE craptab.nmsistem = 'CRED'         
   AND craptab.tptabela = 'GENERI'       
   AND craptab.cdempres = 0              
   AND craptab.cdacesso = 'HORLIMABBC'  
   AND craptab.tpregist = 0;
      
COMMIT;   
