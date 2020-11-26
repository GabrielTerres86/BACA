PL/SQL Developer Test script 3.0
82
-- Created on 26/11/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
  
  CURSOR cr_crapcop  IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.cdagesic
          FROM crapcop
          WHERE crapcop.cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;  
  
  CURSOR cr_crapatr (pr_cdcooper IN crapatr.cdcooper%TYPE) IS
        SELECT crapatr.*
        FROM   crapatr, crapass
        WHERE crapass.cdcooper = crapatr.cdcooper
          AND crapass.nrdconta = crapatr.nrdconta
          AND crapatr.cdcooper = pr_cdcooper
          AND crapatr.cdhistor = 3292
          AND crapatr.dtfimatr is null
          AND crapatr.dtultdeb is null;
  rw_crapatr cr_crapatr%ROWTYPE;


  CURSOR cr_craplau (pr_cdcooper  IN crapatr.cdcooper%TYPE,
                     pr_nrdconta  IN crapatr.nrdconta%TYPE,
                     pr_cdrefere  IN crapatr.cdrefere%TYPE,
                     pr_cdempres  IN crapatr.cdempres%TYPE) IS
        SELECT *
        FROM   craplau
        WHERE craplau.cdcooper = pr_cdcooper
          AND craplau.nrdconta = pr_nrdconta
          AND craplau.dtmvtolt >= '23/09/2020'
          AND craplau.cdhistor = 3292
          AND craplau.cdempres = pr_cdempres
          AND craplau.nrcrcard = pr_cdrefere;  
  rw_craplau cr_craplau%ROWTYPE;
  
begin
  -- Test statements here
  FOR rw_crapcop IN cr_crapcop LOOP
   
      dbms_output.put_line('Criando na coop: -> '||rw_crapcop.cdcooper);  
      
      FOR rw_crapatr IN cr_crapatr ( pr_cdcooper => rw_crapcop.cdcooper) LOOP

          OPEN cr_craplau(rw_crapatr.cdcooper, rw_crapatr.nrdconta, rw_crapatr.cdrefere, rw_crapatr.cdempres);
               
          FETCH cr_craplau INTO rw_craplau;
               
          IF cr_craplau%NOTFOUND THEN

             BEGIN
               UPDATE crapatr
                  SET crapatr.cdopeexc = '997',
                      crapatr.dtiniatr = '26/11/2020'
                WHERE crapatr.cdcooper = rw_crapatr.cdcooper
                  AND crapatr.nrdconta = rw_crapatr.nrdconta
                  AND crapatr.cdrefere = rw_crapatr.cdrefere
                  AND crapatr.cdhistor = 3292
                  AND crapatr.cdempcon = rw_crapatr.cdempcon
                  AND crapatr.cdsegmto = rw_crapatr.cdsegmto
                  AND crapatr.dtfimatr is null
                  AND crapatr.dtultdeb is null;
              EXCEPTION
                  WHEN others THEN
                       dbms_output.put_line('Nao foi possivel alterar o ATR : '|| rw_crapatr.cdcooper ||' '||
                           rw_crapatr.nrdconta ||' '||rw_crapatr.cdempres ||' '||rw_crapatr.cdrefere ||' -> '||SQLERRM);
              END; 
    
          END IF;
       
          CLOSE cr_craplau;
              
      END LOOP;   

      COMMIT;
          
  END LOOP; -- Crapcop

end;
0
0
