-- Created on 26/06/2024 by F0034564 
BEGIN
  declare 
    -- Local variables here
    vr_literal  VARCHAR2(100);
    
    --Variaveis Excecao
    vr_exc_erro EXCEPTION;      

  begin
    -- Test statements here 
    vr_literal:= NULL;
    BEGIN
      UPDATE crapaut 
         SET crapaut.dslitera = vr_literal
       WHERE progress_recid = 1084809820;
     
       COMMIT;
    EXCEPTION
       WHEN Others THEN  
       --Levantar Excecao
       RAISE vr_exc_erro;
	  END;  
  end;
END;	