PL/SQL Developer Test script 3.0
23
-- Created on 30/10/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
        BEGIN

         UPDATE crapatr
            SET crapatr.cdempcon = 162,
                crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '03/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 163
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
      COMMIT;
end;
0
0
