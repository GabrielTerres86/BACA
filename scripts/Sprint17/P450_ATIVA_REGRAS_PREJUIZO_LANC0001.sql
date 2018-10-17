UPDATE crapprm prm
   set prm.dsvlrprm = 'N'
 WHERE prm.cdcooper = 0
   AND prm.nmsistem = 'CRED'
   AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU'
;

UPDATE crapprm prm
   set prm.dsvlrprm = 'S'
 WHERE prm.cdcooper = 11 
   AND prm.nmsistem = 'CRED'
   AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU'
;

COMMIT;

