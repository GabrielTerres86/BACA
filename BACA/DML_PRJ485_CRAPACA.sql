INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('BUSCA_BANCOS_FOLHA'
    ,'TELA_ATENDA_PORTAB'
    ,'pc_busca_bancos_folha'
    ,''
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('SOLICITA_PORTABILIDADE'
    ,'TELA_ATENDA_PORTAB'
    ,'pc_solicita_portabilidade'
    ,'pr_nrdconta,pr_cdbccxlt,pr_nrispbif,pr_nrcnpjif'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('BUSCA_MOTIVOS_CANCELAMENTO'
    ,'TELA_ATENDA_PORTAB'
    ,'pc_busca_motivos_cancelamento'
    ,''
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('CANCELA_PORTABILIDADE'
    ,'TELA_ATENDA_PORTAB'
    ,'pc_cancela_portabilidade'
    ,'pr_nrdconta,pr_cdmotivo'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('IMPRIMIR_TERMO_PORTAB'
    ,'TELA_ATENDA_PORTAB'
    ,'pc_imprimir_termo_portab'
    ,'pr_dsrowid'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
	
COMMIT;