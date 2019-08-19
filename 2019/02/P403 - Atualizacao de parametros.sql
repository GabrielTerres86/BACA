
UPDATE crapaca SET lstparam ='pr_nrdconta,pr_nrctrlim,pr_chave' WHERE nmdeacao ='SOLICITA_BIRO_BORDERO' AND nmpackag = 'TELA_ATENDA_DSCTO_TIT' AND nmproced = 'pc_solicita_biro_bordero_web';

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR) values ('SOLICITA_ANALISE_PAGADOR', 'TELA_ATENDA_DSCTO_TIT', 'pc_analise_pagador_web', 'pr_nrdconta,pr_nrctrlim,pr_chave', 724);

UPDATE crapaca SET lstparam = 'pr_nrdconta , pr_idseqttl , pr_nrctrlim, pr_cddlinha' WHERE nmdeacao='RENOVA_LIMITE_TIT' AND nmpackag = 'TELA_ATENDA_DSCTO_TIT';
