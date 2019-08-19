--INC0011702
--Ana Lúcia Volles - 04/04/2019
--Alterar Situação do gravames para o bem Trator para a conta 115550, contrato 38289

UPDATE crapbpr a SET a.cdsitgrv = 4
WHERE a.cdcooper = 13
AND a.nrdconta = 115550 AND a.nrctrpro = 38289 AND a.cdsitgrv = 3 AND NVL(a.vlmerbem,0) <> 0;


COMMIT;
