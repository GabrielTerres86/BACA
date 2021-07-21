begin


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

----realiza o insert na tabela TBCONSOR_SIMULANCE dos dados da simulacao de aquisicao
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'GRAVA_SIMU_LANCE',
   'CNSO0002',
   'pc_cadastra_simu_lance',
   'pr_nrdconta
   ,pr_idsegmento
,pr_prtgmseguro
,pr_vlcnso
,pr_prazo
,pr_txadm
,pr_fundoreserva
,pr_utilizacarta
,pr_slddevedorlance
,pr_rcrsproprio
,pr_embutidovlcarta
,pr_prcntlanceofertado
,pr_coopusarcarta
,pr_nvsaldo
,pr_antescontemp
,pr_aposcontemp
,pr_reduzirprazo
,pr_comissaolance'
   , 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));    

-----imprime simulacao de Lance
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'IMP_SIMU_LANCE',
   'CNSO0002',
   'pc_imp_simulador_lance_web',
   'pr_id', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
            
   
COMMIT;
end;