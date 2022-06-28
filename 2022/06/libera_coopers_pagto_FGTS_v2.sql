BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'A'
   WHERE prm.cdacesso = 'FLG_PAG_FGTS' 
     AND prm.nmsistem = 'CRED';

  COMMIT;
	
END;