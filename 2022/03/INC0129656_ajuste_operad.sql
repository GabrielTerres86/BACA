BEGIN

	create unique index cecred.CRAPOPE_RDM0043934_PK on CRAPOPE_RDM0043934 (cdcooper, cdoperad) nologging;
	
	update cecred.crapope set inutlcrm = 
	  (select CRAPOPE_RDM0043934.Inutlcrm from cecred.CRAPOPE_RDM0043934
	where cecred.CRAPOPE_RDM0043934.Cdcooper = cecred.crapope.cdcooper
	and cecred.CRAPOPE_RDM0043934.Cdoperad = cecred.crapope.cdoperad);
	
	drop index cecred.CRAPOPE_RDM0043934_PK;

  
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
