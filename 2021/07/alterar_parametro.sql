BEGIN
UPDATE crapaca SET LSTPARAM = 'pr_nrdconta
,pr_idsegmento
,pr_nrprazo
,pr_vlcarta
,pr_vltaxaadm 
,pr_vltxfundores
,pr_vltaxaseguro
,pr_vlparcela
,pr_vlsaldodev
,pr_vlcustotcoop
,pr_vlfundoresarre
,pr_vlemprestimo
,pr_vltxjuroempre
,pr_nrprazoemprest
,pr_vlparcemprest
,pr_vltotaproxempr' WHERE NMPROCED = 'pc_cadastra_simu_economia';
COMMIT;
END;