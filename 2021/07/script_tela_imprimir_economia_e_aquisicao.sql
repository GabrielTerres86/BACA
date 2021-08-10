begin

delete from crapaca where NMDEACAO in ('GRAVA_SIMU_ECONOMIA','IMP_SIMU_ECO','GRAVA_SIMU_AQUISICAO','IMP_SIMU_AQUI');

----realiza o insert na tabela TBCONSOR_SIMUECONOMIA dos dados da simulacao de economia
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

-----imprime simulacao de economia
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'IMP_SIMU_ECO',
   'CNSO0002',
   'pc_imp_simulador_economia_web',
   'pr_id', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
        
----realiza o insert na tabela TBCONSOR_SIMUAQUISICAO dos dados da simulacao de aquisicao
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'GRAVA_SIMU_AQUISICAO',
   'CNSO0002',
   'pc_cadastra_simu_aquisicao',
   'pr_nrdconta
,pr_idsegmento
,pr_anomodelo
,pr_sldevetoratual
,pr_vlavaliacao 
,pr_cilindradas
,pr_vlgarantiaatual
,pr_vlantecipacao', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));   

-----imprime simulacao de aquisicao
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'IMP_SIMU_AQUI',
   'CNSO0002',
   'pc_imp_simulador_aquisicao_web',
   'pr_id', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
    
   
COMMIT;
end;