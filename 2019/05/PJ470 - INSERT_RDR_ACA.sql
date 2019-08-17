INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('NOVO_NUM_CNT_LIMITE','CNTR0001','PC_NOVO_NUM_CNT_LIMITE','pr_nrdconta',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CNTR0001'));
COMMIT;

