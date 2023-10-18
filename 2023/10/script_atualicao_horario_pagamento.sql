begin
UPDATE crapprm prm 
   SET prm.dsvlrprm = '86100'
 WHERE prm.NMSISTEM = 'CRED'
   AND prm.CDACESSO IN ('HRFIM_ENV_RET_RFB');
commit;
end;