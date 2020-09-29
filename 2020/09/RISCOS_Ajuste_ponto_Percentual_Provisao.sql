UPDATE craptab t
   SET t.dstextab = REPLACE(t.dstextab,'.',',')
 WHERE t.cdacesso = 'PROVISAOCL'
   AND SUBSTR(t.dstextab,4,1) = '.';
;
COMMIT;