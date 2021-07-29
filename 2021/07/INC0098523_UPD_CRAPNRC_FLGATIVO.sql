/*
Objetivo.......:Apresentar o contrato 211025 da conta 8.6 na tela de consulta a ratings
Programador....:Amanda Days Ramos Novo
Data...........: 29/07/2021
REF............: INC0098523
*/

BEGIN
    update crapnrc a set a.flgativo = 1 where a.cdcooper=3 and a.nrdconta = 86 and a.nrctrrat = 211025;
    commit;
END;
