/* 
Solicita��o: INC0018355
Objetivo   : Apagar feriado do dia 24/06/2019 na cidade de S�o Jo�o Batista em fun��o da troca de feriado para o dia 21/06/2019
Autor      : Edmar
*/


DELETE CRAPFSF FSF
WHERE FSF.PROGRESS_RECID in ( 177936, 174012);
COMMIT;