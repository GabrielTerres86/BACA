-- INC0081071 - Removera 2 linhas do contrato de débito e crédito;
DELETE FROM craplem lem
 WHERE lem.cdcooper = 16
   AND lem.nrdconta = 350052
   AND lem.nrctremp = 132801
   AND lem.dtmvtolt = '02/03/2021'
   AND lem.vllanmto = 156.08;
-- INC0081071 - Removera 2 linhas do contrato de débito e crédito;

-- INC0083798 - Removerá 2 linhas do contrato de débito e crédito;
DELETE FROM craplem lem
 WHERE lem.cdcooper = 1
   AND lem.nrdconta = 10644725
   AND lem.nrctremp = 2236769
   AND lem.dtmvtolt = '10/02/2021'
   AND lem.vllanmto = 72.18;
-- INC0083798 - Removerá 2 linhas do contrato de débito e crédito;

COMMIT;

