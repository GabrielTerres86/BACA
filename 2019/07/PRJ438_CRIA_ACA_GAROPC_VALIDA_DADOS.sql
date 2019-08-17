-- PRJ 438
-- Mateus Zimmermann (Mouts)
  
  begin

    INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
                  VALUES('GAROPC_VALIDA_DADOS','TELA_GAROPC','PC_VALIDA_DADOS','pr_nmdatela,pr_tipaber,pr_nrdconta,pr_nrctater,pr_lintpctr,pr_vlropera,pr_permingr,pr_inresper,pr_diatrper,pr_tpctrato,pr_inaplpro,pr_vlaplpro,pr_inpoupro,pr_vlpoupro,pr_inresaut,pr_inaplter,pr_vlaplter,pr_inpouter,pr_vlpouter',
                         (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_GAROPC'));
       
    COMMIT;
  end;
