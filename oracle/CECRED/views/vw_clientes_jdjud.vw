CREATE OR REPLACE FORCE VIEW CECRED.VW_CLIENTES_JDJUD AS
SELECT CASE WHEN ass.inpessoa = 1 THEN 'F'
ELSE 'J' END TP_PESSOA,
ass.nrcpfcgc AS CPFCNPJ_PESSOA,
ass.nmprimtl AS NM_PESSOA,
cop.nrdocnpj AS CNPJ_COOP
FROM crapass ass, crapcop cop
WHERE ass.dtdemiss IS NULL
AND ass.cdcooper = cop.cdcooper;

