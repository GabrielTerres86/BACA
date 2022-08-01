BEGIN

   UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'A'
   WHERE prm.cdcooper IN (7,8)
     AND prm.cdacesso IN ('FLG_PAG_FGTS','FLG_PAG_FGTS_CXON')
     AND prm.nmsistem = 'CRED';	 

  COMMIT;
	
END;