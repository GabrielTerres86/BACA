-- 16/05/2019 - inc0014378 endereços duplicados para serem excluídos (Carlos)
DELETE FROM crapenc WHERE progress_recid IN (423802,1111806);
COMMIT;
