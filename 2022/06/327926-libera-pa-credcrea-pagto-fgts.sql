BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = '7'
   WHERE prm.cdcooper = 7
     AND prm.cdacesso IN ('FLG_PAG_FGTS','FLG_PAG_FGTS_CXON')
     AND prm.nmsistem = 'CRED';	 

  COMMIT;
	
END;