-- DMND0001414 -  Migrar convênios de arrecadação com Sicredi para o Bancoob.
-- Mateus Z (Mouts)

insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values (SEQACA_NRSEQACA.NEXTVAL, 'BUSCA_CONVENIOS_BANCOOB', 'TELA_AUTORI', 'pc_busca_convenios_bancoob', 'pr_cdhistor,pr_dshistor,pr_nrregist,pr_nriniseq', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'AUTORI'));

COMMIT;
