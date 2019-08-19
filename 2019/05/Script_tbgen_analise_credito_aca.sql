declare

 vr_nrseqrdr number;
 vr_nrseqaca number;

begin
  
    select max(nrseqrdr)+1 
      into vr_nrseqrdr 
      from craprdr;
      
    insert into craprdr(nrseqrdr, 
                        nmprogra, 
                        dtsolici)
                 values(vr_nrseqrdr,
                        'TELA_ANALISE_CREDITO',
                        sysdate);

    commit;                        
      
    select max(nrseqaca)+1
      into vr_nrseqaca
      from crapaca;

    insert into crapaca(nrseqaca, 
                        nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                values (vr_nrseqaca,
                        'GERA_TOKEN_IBRATAN',
                        'TELA_ANALISE_CREDITO',
                        'PC_GERA_TOKEN_IBRATAN',
                        'pr_cdcooper,pr_cdoperad,pr_cdagenci,pr_fltoken',
                        vr_nrseqrdr);
    commit;
    
    select max(nrseqaca)+1
      into vr_nrseqaca
      from crapaca;

    insert into crapaca(nrseqaca, 
                        nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                values (vr_nrseqaca,
                        'CONSULTA_XML',
                        'TELA_ANALISE_CREDITO',
                        'pc_consulta_analise_creditoweb',
                        'pr_nrdconta,pr_tpproduto,pr_nrcontrato',
                        vr_nrseqrdr);
    commit;            
end;


