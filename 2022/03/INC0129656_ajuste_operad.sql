BEGIN

	create unique index CRAPOPE_RDM0043934_PK on CRAPOPE_RDM0043934 (cdcooper, cdoperad) nologging;
	
	update crapope set inutlcrm = 
	  (select CRAPOPE_RDM0043934.Inutlcrm from cecred.CRAPOPE_RDM0043934
	where CRAPOPE_RDM0043934.Cdcooper = crapope.cdcooper
	and CRAPOPE_RDM0043934.Cdoperad = crapope.cdoperad);
	
	drop index CRAPOPE_RDM0043934_PK;

  
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
