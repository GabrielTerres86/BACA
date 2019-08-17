/* 
Solicitação: INC0011570 (Filhos: INC0011158 - INC0012468 - INC0012958)
Objetivo   : Efetua a alteração na tabela CRAPRPP (Cadastro de poupanca programada) do produtos que atualmente 
             estão como suspensos ou cancelados tipo 4, para cancelados tipo 3.
             Esta alteração de dará para:
                Cooperativa 1 e Conta 8813850 (progress_recid = 475413)
                Cooperativa 2 e Conta 473162 (progress_recid = 502289)
                Cooperativa 16 e Conta 264938 (progress_recid = 480610)
Autor      : Jackson
*/
UPDATE craprpp
   SET cdsitrpp = 3 /*3=Cancelado*/
 WHERE progress_recid in (475413, 502289, 480610);
COMMIT;
/*
--Efetua o Rollback, voltando a Situação para o tipo 2-Suspenso
UPDATE craprpp
   SET cdsitrpp = 2 
 WHERE progress_recid in (475413, 502289, 480610);
COMMIT;
*/
