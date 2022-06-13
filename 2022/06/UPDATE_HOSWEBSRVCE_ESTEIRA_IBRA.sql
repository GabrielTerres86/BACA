BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'https://wsesteiracreditocdc.ailoshml.coop.br'
   WHERE prm.cdacesso = 'HOSWEBSRVCE_ESTEIRA_IBRA' 
     AND prm.nmsistem = 'CRED';

  COMMIT;
	
END;