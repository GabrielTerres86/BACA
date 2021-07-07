begin
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'IMP_SIMU_ECO',
   'CNSO0002',
   'pc_imp_simulador_economia_web',
   'pr_id', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'SIMCON'));          
        
      
   
COMMIT;
end;