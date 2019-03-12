INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('ENVIO_CARTAO_COOP_PA'
    ,'TELA_ATENDA_CARTAOCREDITO'
    ,'pc_verifica_cooperativa_pa_web'
    ,'pr_nrdconta'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA_CRD'));

INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('BUSCA_ENDERECOS_CRD'
    ,'TELA_ATENDA_CARTAOCREDITO'
    ,'pc_busca_enderecos_crd'
    ,'pr_cdcooper,pr_nrdconta'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA_CRD'));

    COMMIT;