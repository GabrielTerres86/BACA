/* 
Solicitação: INC0017079
Objetivo   : Desabilitar execução do programa CRPS318 da cadeia noturna.
             crapprg.inlibprg igual a 2, indica o bloqueio.
             Além deste bloqueio, será alterado o valor do campo crapprg.inlibprg para 999.
             E o valor do campo crapprg.nrordprg para 1209, para respeitar a regra da Unique Key.
Autor      : Jackson
*/

UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 389;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 1414;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 2453;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 3500;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 4521;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 5543;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 6566;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 7588;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 8611;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 9634;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 10656;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 11676;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 12698;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 13720;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 14742;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 15764;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1209, inlibprg = 2 WHERE progress_recid = 16787;

COMMIT;





