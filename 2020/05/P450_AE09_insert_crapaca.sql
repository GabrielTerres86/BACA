INSERT INTO craprdr (NRSEQRDR, NMPROGRA, DTSOLICI)
VALUES (SEQRDR_NRSEQRDR.NEXTVAL,'PREJ0006', SYSDATE)
/
commit
/
INSERT INTO  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES (SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
       'VERIFICA_PREJU_CONTA',   -- nmdeacao
       'PREJ0006',               -- nmpackag
       'pc_verifica_preju_conta_web', -- nmproced
       'pr_nrdconta',                 -- lstparam
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'PREJ0006'))
/
commit
/

