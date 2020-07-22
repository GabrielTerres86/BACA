UPDATE craptab
   SET craptab.dstextab = '0'||SUBSTR(craptab.dstextab,2,LENGTH(craptab.dstextab)-1) 
 WHERE  craptab.nmsistem = 'CRED'       AND
        craptab.tptabela = 'USUARI'     AND
        craptab.cdempres = 11           AND
        craptab.cdacesso = 'RISCOBACEN' AND
        craptab.tpregist = 000          AND
        craptab.cdcooper IN (2,6,7,9,10,12,13,14,16);  
        
COMMIT;
