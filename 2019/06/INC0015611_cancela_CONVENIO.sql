/* 
Solicitação: INC0015611
Objetivo   : Atribuir a data atual aos campos CRAPATR.DTFIMATR e CRAPATR.DTINSEXC 
             para o cooperado 3686213 da Cooperativa 1.
             Estes campos preenchidos indicam a data em que o convênio foi cancelado.
Autor      : Jackson
*/

update crapatr set dtfimatr = trunc(sysdate), dtinsexc = trunc(sysdate) WHERE crapatr.progress_recid = 71141;

COMMIT;





