/* 
SCRIPT DE ROLLBACK
Objetivo   : Apaga os registros de municípios de abrangência da cooperativa CREDIFIESC (tabela tbgen_cid_atuacao_coop) para voltar o estado original desta incidência.
Autor: Edmar
*/

DELETE tbgen_cid_atuacao_coop  CM
WHERE CM.CDCOOPER = 6 /* CREDIFIESC */ ;
COMMIT;
