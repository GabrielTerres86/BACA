/* RITM0011698 - Remover emails das cooperativas 2 e 13 conforme solicita��o */
update crapprm prm
  set prm.dsvlrprm = null
where prm.cdacesso = 'EMAIL_SOL_CRED_AUTO'
  and prm.cdcooper in (2,13); 
  
commit;  
  
