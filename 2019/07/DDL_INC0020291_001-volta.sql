/*
INC0020291 - Ajustar cadastro para VIP
Ana - 12/07/2019

Joice solicitou script para inclusão de VIP:
Coop    Conta    Contrato
1    886521    775619
2    157929    238695
16    1864254  2344
13    270270    32138

select * from crapcyc WHERE 
    (crapcyc.cdcooper = 1 AND crapcyc.nrdconta = 886521 AND crapcyc.nrctremp = 775619)
or (crapcyc.cdcooper = 2 AND crapcyc.nrdconta = 157929 AND crapcyc.nrctremp = 238695)
or (crapcyc.cdcooper = 13 AND crapcyc.nrdconta = 270270 AND crapcyc.nrctremp = 32138)
or (crapcyc.cdcooper = 16 AND crapcyc.nrdconta = 1864254 AND crapcyc.nrctremp = 2344);

*/

begin
  UPDATE crapcyc
  SET    flgehvip = 0
        ,cdmotcin = 0
  WHERE (crapcyc.cdcooper = 1 AND crapcyc.nrdconta = 886521 AND crapcyc.nrctremp = 775619)
  or (crapcyc.cdcooper = 2 AND crapcyc.nrdconta = 157929 AND crapcyc.nrctremp = 238695)
  or (crapcyc.cdcooper = 13 AND crapcyc.nrdconta = 270270 AND crapcyc.nrctremp = 32138)
  or (crapcyc.cdcooper = 16 AND crapcyc.nrdconta = 1864254 AND crapcyc.nrctremp = 2344);

  commit;
exception
  when others then
    rollback;  
end;
