PL/SQL Developer Test script 3.0
66
-- Created on 18/02/2019 by T0031667 
declare 
  CURSOR cr_contas IS
  SELECT nrdconta
       , cdagenci
       , cdbccxlt
       , nrdocmto
       , vllanmto
       , dtmvtolt
    FROM craplcm lcm
   WHERE lcm.cdcooper = 1
     AND lcm.dtmvtolt = to_date('17/01/2019', 'DD/MM/YYYY')
     AND lcm.cdpesqbb LIKE 'CRAP51%'
     AND lcm.nrdolote = 11006
     AND lcm.nrdconta IN (
           10084878,
           7655924,
           9685642,
           7284462,
           9779477,
           6289525,
           6732089,
           2079550,
           6798713,
           6187064,
           6929818
         );
  rw_contas cr_contas%ROWTYPE;  
     
  vr_nrseqdig NUMBER := 1;
begin
  FOR rw_contas IN cr_contas LOOP
    INSERT INTO craplcm (
        cdcooper
      , nrdconta
      , dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , cdhistor
      , nrseqdig
      , vllanmto
      , nrdctabb
      , cdoperad
      , nrdocmto
    )
    VALUES (
        1
      , rw_contas.nrdconta
      , rw_contas.dtmvtolt
      , rw_contas.cdagenci
      , rw_contas.cdbccxlt
      , 706
      , 2947
      , vr_nrseqdig
      , rw_contas.vllanmto
      , rw_contas.nrdconta
      , '1'
      , '9' || rw_contas.nrdocmto
    );
    
    vr_nrseqdig := vr_nrseqdig + 1;
  END LOOP;
  
  COMMIT;  
end;
0
0
