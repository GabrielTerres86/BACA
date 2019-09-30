INSERT INTO 
  crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES 
  (
  SEQACA_NRSEQACA.NEXTVAL,    -- nrseqaca
  'SIMULA_VALIDA_CONSIGNADO', -- nmdeacao
  'TELA_ATENDA_SIMULACAO',    -- nmpackag
  'pc_valida_simul_consig',   -- nmproced
  'pr_nrdconta,pr_cdlcremp',              -- lstparam
  (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_SIMULACAO'))
/
commit
/
UPDATE  crapaca  a
set a.lstparam = a.lstparam||',pr_vlparepr,pr_vliofepr'
where a.nmpackag = 'TELA_ATENDA_SIMULACAO'
AND A.NMDEACAO = 'SIMULA_GRAVA_SIMULACAO'
/
commit
/
