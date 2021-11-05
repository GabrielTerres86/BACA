BEGIN
  --parcelas que estao pagas na credcorreios e nao pagas no aimaro
  update crappep a
     set a.dtultpag = to_date('10/04/2018','dd/mm/yyyy') --null
        ,a.vlpagpar = 255.75 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --2194.84
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --117.63
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 6
  ;
  --
  update crappep a
     set a.dtultpag = to_date('07/05/2018','dd/mm/yyyy') --null
        ,a.vlpagpar = 257.44 --0
        ,a.vlsdvpar = 0 --225.14
        ,a.vlsdvatu = 0 --2100.32
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --115.39
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 7
  ;
  --
  update crappep a
     set a.dtultpag = to_date('05/07/2018','dd/mm/yyyy') --null
        ,a.vlpagpar = 259.33 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --2009.88
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --113.08
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 8
  ;
  --
  update crappep a
     set a.dtultpag = to_date('04/10/2018','dd/mm/yyyy') --null
        ,a.vlpagpar = 230.93 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --1840.50
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --108.52
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 10
  ;
  --
  update crappep a
     set a.dtultpag = to_date('07/01/2019','dd/mm/yyyy') --null
        ,a.vlpagpar = 230.85 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --1685.41
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --103.96
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 12
  ;
  --
  update crappep a
     set a.dtultpag = to_date('04/04/2019','dd/mm/yyyy') --null
        ,a.vlpagpar = 230.57 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --1543.38
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --99.41
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 14
  ;
  --
  update crappep a
     set a.dtultpag = to_date('04/06/2019','dd/mm/yyyy') --null
        ,a.vlpagpar = 229.75 --0
        ,a.vlsdvpar = 0 --255.14
        ,a.vlsdvatu = 0 --1413.32
        ,a.vlsdvsji = 0 --225.14
        ,a.vlmtapar = 0 --4.50
        ,a.vlmrapar = 0 --94.78
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 16
  ;
  --
  --parcelas que somente os valores estavam errados
  update crappep a
     set a.vlpagpar = 254.24 --167.50
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 5
  ;
  --
  update crappep a
     set a.vlpagpar = 232.18 --41.53
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 9
  ;
  --
  update crappep a
     set a.vlpagpar = 231.81 --12.74
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 11
  ;
  --
  update crappep a
     set a.vlpagpar = 233.42 --14.27
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 13
  ;
  --
  update crappep a
     set a.vlpagpar = 234.20 --18.20
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 15
  ;
  --
  update crappep a
     set a.vlpagpar = 534.24 --126.39
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 17
  ;
  --
  update crappep a
     set a.vlpagpar = 752.30 --250.00
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 18
  ;
  --
  update crappep a
     set a.vlpagpar = 292.05 --260.00
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 19
  ;
  --
  update crappep a
     set a.vlpagpar = 289.36 --280.00
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 20
  ;
  --
  update crappep a
     set a.vlpagpar = 689.34 --28.42
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 515663
     and a.nrctremp = 16000908
     and a.nrparepr = 21
  ;
  --
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('OK');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;