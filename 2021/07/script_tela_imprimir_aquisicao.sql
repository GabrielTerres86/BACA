begin
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