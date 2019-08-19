-- TELA_CADEMP
INSERT INTO 
       craprdr (NRSEQRDR, NMPROGRA, DTSOLICI)
VALUES (
       SEQRDR_NRSEQRDR.NEXTVAL,
       'TELA_CADEMP',
       SYSDATE);

-- OBTEM_DADOS_EMPRESA
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'OBTEM_DADOS_EMPRESA', -- nmdeacao
  'TELA_CADEMP', -- nmpackag
  'pc_busca_empresa_web', -- nmproced
  'pr_nmextemp,pr_nmresemp,pr_nrdocnpj,pr_cdempres,pr_cddopcao,pr_nriniseq,pr_nrregist', -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADEMP')); -- nrseqrdr
  
-- BUSCA_CONSIG
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'BUSCA_CONSIG', -- nmdeacao
  'TELA_CADEMP', -- nmpackag
  'pc_busca_dados_consig_fis', -- nmproced
  '', -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADEMP')); -- nrseqrdr  

COMMIT;