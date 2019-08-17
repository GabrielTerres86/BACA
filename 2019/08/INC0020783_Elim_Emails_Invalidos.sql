/* 
Solicitação: INC0020783
Objetivo   : Manter apenas um registro na tabela de 
             “Controle de emissão de extratos” CRAPCEX.
Autor      : Jackson
*/

delete crapcex
 where cdcooper = 1
   and nrdconta = 2713136
   and tpextrat = 3
   and progress_recid not in (5964);

COMMIT; 



