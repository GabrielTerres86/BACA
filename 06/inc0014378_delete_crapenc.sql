-- 16/05/2019 - inc0014378 endere�os duplicados para serem exclu�dos (Carlos)
DELETE FROM crapenc WHERE progress_recid IN (423802,1111806);
COMMIT;
