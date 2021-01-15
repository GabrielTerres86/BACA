PL/SQL Developer Test script 3.0
16
-- Created on 14/10/2020 by T0032500 
begin
  -- Test statements here
  BEGIN
    UPDATE crapprm
       SET crapprm.dsvlrprm = '2'
     WHERE crapprm.cdcooper = 16
       AND crapprm.cdacesso = 'CONTINGENCIA_PA_REM_BCB';
    EXCEPTION
     WHEN others THEN
          dbms_output.put_line('Nao foi possivel alterar a PRM : '||SQLERRM);
          rollback;
  END;
  
  COMMIT;      
end;
0
0
