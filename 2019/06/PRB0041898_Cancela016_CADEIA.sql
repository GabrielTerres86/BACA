/* 
Solicitação: PRB0041898
Objetivo   : Desabilitar execução do programa CRPS016 da cadeia noturna.
             crapprg.inlibprg igual a 2, indica o bloqueio.
             Além deste bloqueio, será alterado o valor do campo crapprg.inlibprg de 11 para 999.
             E o valor do campo crapprg.nrordprg de 1 para 1210, para respeitar a regra da Unique Key.
Autor      : Jackson
*/

UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 109;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 1134;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 2174;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 3220;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 4241;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 5263;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 6286;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 7308;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 8331;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 9354;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 10376;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 11396;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 12418;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 13440;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 14462;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 15484;
UPDATE crapprg SET nrsolici = 999,  nrordprg = 1210, inlibprg = 2 WHERE progress_recid = 16507;

COMMIT;





