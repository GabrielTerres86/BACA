INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
    ('BUSCA_DOMINIO_EPR'
    ,'EMPR9999'
    ,'pc_busca_dominio'
    ,'pr_nmdominio'
    ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'EMPR9999'));
   
COMMIT;
