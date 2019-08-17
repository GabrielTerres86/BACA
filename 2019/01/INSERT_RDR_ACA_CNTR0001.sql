INSERT INTO craprdr (nmprogra, dtsolici)
              VALUES('CNTR0001',SYSDATE);

INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('GERA_PROTOCOLO_CTD_PF','CNTR0001','PC_GERA_PROTOCOLO_CTD_PF','pr_nrdconta,pr_cdtippro,pr_nrcontrato,pr_vlcontrato,pr_dscomplemento',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CNTR0001'));

INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('CRIA_TRANS_PEND_CTD','CNTR0001','PC_CRIA_TRANS_PEND_CTD','pr_nrdconta,pr_tpcontrato,pr_nrcontrato,pr_vlcontrato,pr_cdrecid_crapcdc,pr_contas_digitadas',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CNTR0001'));

INSERT INTO crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr)
              VALUES('GERA_PROTOCOLO_CTD_PJ','CNTR0001','PC_GERA_PROTOCOLO_CTD_PJ','pr_nrdconta,pr_cdtippro,pr_dhcontrato,pr_nrcontrato,pr_vlcontrato,pr_cdtransacao_pendente,pr_contas_digitadas,pc_cdcooper_tel,pr_dscomplemento',
                     (SELECT r.nrseqrdr FROM craprdr r WHERE r.nmprogra = 'CNTR0001'));
					 
COMMIT;

