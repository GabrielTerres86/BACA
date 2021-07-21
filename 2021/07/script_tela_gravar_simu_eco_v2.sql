BEGIN
DELETE FROM crapaca WHERE NMDEACAO = 'GRAVA_SIMU_ECONOMIA';
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'GRAVA_SIMU_ECONOMIA',
   'CNSO0002',
   'pc_cadastra_simu_economia',
   'pr_nrdconta
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
,pr_vltotaproxempr', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));
COMMIT;
END;   