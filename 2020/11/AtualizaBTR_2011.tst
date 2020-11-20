PL/SQL Developer Test script 3.0
285
-- Created on 20/11/2020 by T0032500 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
      BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402065842476
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 2268760
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('2268760 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 9104040891010
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 3073360
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null
            AND crapatr.progress_recid = 1480408;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('3073360 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 49935035852972
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 3998819
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('3998819 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402032867457
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 6412327
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('6412327 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402065007895
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 7045328
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('7045328 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402036153904
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 7049170
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('7049170 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 123456789100
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 7384351
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('7384351 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402053156119
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 7537913
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('7537913 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      

    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 2002647
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 7841175
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('7841175 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 5097519946101
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 8299595
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8299595 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 11147434233
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 8851000
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8851000 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 402085062396
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 8892725
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('8892725 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      

    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 9126945636015
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 9069224
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('9069224 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 7101207171
          WHERE crapatr.cdcooper = 1
            AND crapatr.nrdconta = 11799552
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('11799552 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 8211095180
          WHERE crapatr.cdcooper = 14
            AND crapatr.nrdconta = 60682
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('60682 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
    BEGIN
         UPDATE crapatr
            SET crapatr.cdopeexc = '1',
                crapatr.dtiniatr = '20/11/2020',
                crapatr.cdrefere = 522789007
          WHERE crapatr.cdcooper = 16
            AND crapatr.nrdconta = 461326
            AND crapatr.dtiniatr = '19/11/2020'
            AND crapatr.cdhistor = 3292
            AND crapatr.cdempcon = 157
            AND crapatr.cdsegmto = 4
            AND crapatr.dtfimatr is null;
        EXCEPTION
            WHEN others THEN
                 dbms_output.put_line('461326 - Nao foi possivel alterar o ATR : '||SQLERRM);
      END;
      
      COMMIT;

end;
0
0
