-- INC0084564 - Removerá 4 linhas do contrato de débito e crédito;
DELETE FROM craplem lem
 WHERE lem.cdcooper = 16
   AND lem.nrdconta = 350052
   AND lem.nrctremp = 132801
   AND lem.dtmvtolt = TO_DATE('05/04/2021', 'DD/MM/YYYY')
   AND lem.vllanmto = 156.20;

DELETE FROM craplem lem
 WHERE lem.cdcooper = 16
   AND lem.nrdconta = 350052
   AND lem.nrctremp = 132801
   AND lem.dtmvtolt = TO_DATE('03/05/2021', 'DD/MM/YYYY')
   AND lem.vllanmto = 160.48;
-- INC0084564 - Removerá 2 linhas do contrato de débito e crédito;

COMMIT;