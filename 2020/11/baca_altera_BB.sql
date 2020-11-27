DELETE 
  FROM crapprm p
 WHERE p.nmsistem = 'CRED'
   AND p.cdcooper = 1
   AND p.cdacesso = 'HORLIMPROC_JOB';

UPDATE craptab 
   SET craptab.DSTEXTAB = '3600'
 WHERE UPPER(craptab.nmsistem) = UPPER('CRED')           
   AND UPPER(craptab.tptabela) = UPPER('USUARI')         
   AND craptab.cdempres = 11               
   AND UPPER(craptab.cdacesso) = UPPER('HORLIMPROC')
   AND craptab.cdcooper = 1;    
    
UPDATE craptab 
   SET craptab.DSTEXTAB = '16200'
 WHERE UPPER(craptab.nmsistem) = UPPER('CRED')           
   AND UPPER(craptab.tptabela) = UPPER('USUARI')         
   AND craptab.cdempres = 11               
   AND UPPER(craptab.cdacesso) = UPPER('HORLIMPROC')
   AND craptab.cdcooper NOT IN (1,3);    
   
UPDATE CRAPPRG p
   SET p.NRSOLICI = 9999
      ,p.INLIBPRG = 2
 WHERE p.CDPROGRA = 'CRPS323';
 
COMMIT;   
