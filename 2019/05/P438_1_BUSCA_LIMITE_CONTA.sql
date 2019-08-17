INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)              
              VALUES('BUSCA_LIMITE_CONTA','LIMI0001','pc_busca_limite_conta','pr_nrdconta',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'ATENDA'));
COMMIT;
INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)              
              VALUES('BUSCA_DADOS_LIM_PF','LIMI0001','pc_busca_dados_lim_pf','pr_nrdconta',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'ATENDA'));
COMMIT;
INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)              
              VALUES('BUSCA_DADOS_LIM_PJ','LIMI0001','pc_busca_dados_lim_pj','pr_nrdconta',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'ATENDA'));
COMMIT;