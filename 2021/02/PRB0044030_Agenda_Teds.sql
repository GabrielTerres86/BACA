/* Ajustar horarios e intervalos JOBs TEDS */

BEGIN

UPDATE craptab
   SET craptab.dstextab = '0637;1130;0100;'
 WHERE craptab.cdcooper = 0
   AND craptab.nmsistem = 'CRED'
   AND craptab.tptabela = 'GENERI'
   AND craptab.cdempres = 0
   AND craptab.cdacesso = 'HRAGENDEBTED'
   AND craptab.tpregist = 0;
  
  COMMIT;
END;  
