BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'A'
   WHERE prm.cdcooper = 7
     AND prm.cdacesso = 'FLG_PAG_FGTS' 
     AND prm.nmsistem = 'CRED';

  COMMIT;
	
END;