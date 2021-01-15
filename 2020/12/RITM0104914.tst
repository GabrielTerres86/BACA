PL/SQL Developer Test script 3.0
23
-- Created on 22/12/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
      BEGIN

         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtfimatr = null,
                crapatr.dtiniatr = trunc(sysdate)
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 1330
            AND crapatr.cdsegmto = 2;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
      COMMIT;

end;
0
0
