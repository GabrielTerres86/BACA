PL/SQL Developer Test script 3.0
67
-- Created on 19/11/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
  
    CURSOR cr_crapatr IS
        SELECT *
        FROM   crapatr
         WHERE crapatr.cdempcon = 157
          AND crapatr.cdsegmto = 4
          AND crapatr.cdhistor = 3292
          AND crapatr.dtfimatr is null;  
  rw_crapatr cr_crapatr%ROWTYPE;


  CURSOR cr_craplau IS
        SELECT *
        FROM   craplau
        WHERE craplau.cdcooper = rw_crapatr.cdcooper
          AND craplau.nrdconta = rw_crapatr.nrdconta
          AND craplau.dtmvtolt >= '23/09/2020'
          AND craplau.cdhistor = 3292
          AND craplau.nrcrcard = rw_crapatr.cdrefere;  
  rw_craplau cr_craplau%ROWTYPE;

  
  -- VARIAVEIS DE EXCECAO
  vr_exc_erro EXCEPTION;  
  vr_cdrefere varchar2(1000);
begin
  -- Test statements here
     
  FOR rw_crapatr IN cr_crapatr LOOP

      OPEN cr_craplau;
               
      FETCH cr_craplau INTO rw_craplau;
               
      IF cr_craplau%NOTFOUND THEN

          BEGIN
               UPDATE crapatr
                  SET crapatr.cdopeexc = '1',
                      crapatr.dtiniatr = '19/11/2020',
                      crapatr.cdrefere = vr_cdrefere
                WHERE crapatr.cdcooper = rw_crapatr.cdcooper
                  AND crapatr.nrdconta = rw_crapatr.nrdconta
                  AND crapatr.cdrefere = rw_crapatr.cdrefere
                  AND crapatr.cdhistor = 3292
                  AND crapatr.cdempcon = 157
                  AND crapatr.cdsegmto = 4
                  AND crapatr.dtfimatr is null;
              EXCEPTION
                  WHEN others THEN
                       dbms_output.put_line('Nao foi possivel alterar o ATR : '||SQLERRM);
            END;

     
     END IF;
       
     CLOSE cr_craplau;
              
   END LOOP;   

   COMMIT;
  
end;
0
0
