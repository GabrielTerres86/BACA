-- TELA_CONSIG
INSERT INTO 
       craprdr (NRSEQRDR, NMPROGRA, DTSOLICI)
VALUES (
       SEQRDR_NRSEQRDR.NEXTVAL,
       'TELA_CONSIG',
       SYSDATE);

-- OBTEM_DADOS_EMP_CONSIGNADO
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'OBTEM_DADOS_EMP_CONSIGNADO', -- nmdeacao
  'TELA_CONSIG', -- nmpackag
  'pc_busca_empr_consig_web', -- nmproced
  'pr_nmextemp,pr_nmresemp,pr_cdempres,pr_cddopcao,pr_nriniseq,pr_nrregist', -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONSIG')); -- nrseqrdr

-- DESABILITAR_EMPR_CONSIG
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'DESABILITAR_EMPR_CONSIG', -- nmdeacao
  'TELA_CONSIG', -- nmpackag
  'pc_desabilitar_empr_consig_web', -- nmproced
  'pr_cdempres', -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONSIG')); -- nrseqrdr

-- HABILITAR_EMPR_CONSIG
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'HABILITAR_EMPR_CONSIG', -- nmdeacao
  'TELA_CONSIG', -- nmpackag
  'pc_habilitar_empr_consig_web', -- nmproced
  '', -- lstparam 
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONSIG')); -- nrseqrdr

-- ALTERAR_EMPR_CONSIG
INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL, -- nrseqaca
  'ALTERAR_EMPR_CONSIG', -- nmdeacao
  'TELA_CONSIG', -- nmpackag
  'pc_alterar_empr_consig_web', --nmproced
  '', -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONSIG')); -- nrseqrdr

COMMIT;