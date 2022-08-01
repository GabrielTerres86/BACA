BEGIN
	update crapprm 
	   set DSVLRPRM = '0'
    where NMSISTEM = 'CRED'
	  and CDACESSO = 'ENVIAR_TRANSF_AILOS_MAIS';
	COMMIT;
END;	
/