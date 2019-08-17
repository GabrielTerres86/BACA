INSERT INTO craprdr (nmprogra, dtsolici)
              VALUES('TELA_AUTCTD',SYSDATE);
              
INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)              
              VALUES('VER_CARTAO_MAG','TELA_AUTCTD','PC_VER_CARTAO_MAG','pr_nrdconta,pr_tpcontrato,pr_nrcontrato,pr_vlcontrato',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'TELA_AUTCTD'));
COMMIT;
