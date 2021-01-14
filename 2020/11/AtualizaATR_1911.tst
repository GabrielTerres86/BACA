PL/SQL Developer Test script 3.0
161
-- Created on 18/11/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
      -- 8460002 (TeleRS Fixa RS)   
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 2
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 10;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460002 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
      COMMIT;


      -- 8460079 (Vivo RS)    
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 79
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 11;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460079 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8460080 (Vivo SP)    
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 80
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 11;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460080 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8460313 (OI BRTEL CEL)   
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 313
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 12;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460313 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8460430 (Hughes Brasil)    
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 430
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 25;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460430 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8360078 (Cergal SC)    
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 78
            AND crapatr.cdsegmto = 3
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 18;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8360078 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8260097 (Sabesp)   
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 97
            AND crapatr.cdsegmto = 2
            AND crapatr.dtfimatr is null
        AND length(crapatr.cdrefere) < 10;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8260097 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 8261330 (Tubarão)  
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 1330
            AND crapatr.cdsegmto = 2
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8460002 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;

      -- 296 (NET)  
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '19/11/2020'
          WHERE crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 296
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
      AND crapatr.dtiniatr >= '23/09/2020'
      AND crapatr.dtiniatr <= '29/09/2020';
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('296 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;

      COMMIT;
  
end;
0
0
