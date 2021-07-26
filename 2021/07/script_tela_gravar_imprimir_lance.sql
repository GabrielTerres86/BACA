begin
----realiza o insert na tabela TBCONSOR_SIMULANCE dos dados da simulacao de lance
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