UPDATE crapbpr b
   SET b.dscorbem = 'CINZA METALICA'
 WHERE b.cdoperad = 'AUTOCDC'
   AND b.dscorbem = 'cinza metÃ¡lica';
   
UPDATE crapbpr b
   SET b.dscorbem = 'PRATA METALICA'
 WHERE b.cdoperad = 'AUTOCDC'
   AND b.dscorbem = 'prata metÃ¡lica';
   
UPDATE crapbpr b
   SET b.dscorbem = 'PRATA METALICA'
 WHERE b.cdoperad = 'AUTOCDC'
   AND b.dscorbem LIKE 'PRATA METÃ%LICA';  
   
COMMIT;