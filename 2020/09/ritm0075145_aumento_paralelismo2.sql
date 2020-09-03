--ritm0075145_aumento_paralelismo2 (Carlos)
UPDATE crapprm set dsvlrprm = 30 where crapprm.cdacesso = 'QTD_PARALE_CRPS720';
UPDATE crapprm set dsvlrprm = 30 where crapprm.cdacesso = 'QTD_PARALE_CRPS724';
UPDATE tbgen_batch_param SET qtparalelo = 20 WHERE cdprograma = 'CRPS736';
UPDATE tbgen_batch_param SET qtparalelo = 40 WHERE cdprograma = 'CRPS753';
COMMIT;
