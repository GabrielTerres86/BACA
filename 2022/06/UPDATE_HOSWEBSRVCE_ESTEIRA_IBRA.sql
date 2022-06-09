BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'https://wsesteiracredito.ailoshml.coop.br'
   WHERE prm.cdacesso = 'HOSWEBSRVCE_ESTEIRA_IBRA' 
     AND prm.nmsistem = 'CRED';

  COMMIT;
	
END;