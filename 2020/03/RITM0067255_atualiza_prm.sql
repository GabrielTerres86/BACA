UPDATE crapprm p
   SET p.dsvlrprm = '31/10/2019,30/06/2020' 
 WHERE p.cdcooper = 3 
   AND UPPER(p.cdacesso) = UPPER('CRD_VALIDADE_EXTENDIDA')
   AND UPPER(p.nmsistem) = UPPER('CRED');

COMMIT;
      
