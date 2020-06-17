UPDATE crapprm prm
   SET prm.dsvlrprm = '1600,1601,1602'
 WHERE prm.nmsistem = 'CRED'  
   AND prm.cdcooper = 13
   AND prm.cdacesso = 'LINHA_FOLHA_PGTO_BNDES';
   
COMMIT;   
