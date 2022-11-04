BEGIN
	update crapprm 
	   set DSVLRPRM = '1'
    where NMSISTEM = 'CRED'
	  and CDACESSO = 'ENVIAR_TRANSF_AILOS_MAIS';
	COMMIT;
END;	
/