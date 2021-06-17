UPDATE crapprm prm
  set prm.dsvlrprm = '00410;1'
 WHERE prm.nmsistem = 'CRED'
   AND prm.cdcooper = 0
   AND prm.cdacesso = 'SAQUE_PAGUE_ITENS_MENU8';
   
commit;    
