BEGIN
  declare 
    vr_literal  VARCHAR2(100);    
    vr_exc_erro EXCEPTION;      

  begin    
    vr_literal:= NULL;
    BEGIN
      UPDATE crapaut 
         SET crapaut.dslitera = vr_literal
       WHERE progress_recid = 1084809820;
     
       COMMIT;
    EXCEPTION
       WHEN Others THEN
       RAISE vr_exc_erro;
	  END;  
  end;
END;	