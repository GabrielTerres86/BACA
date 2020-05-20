DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'ATENDA';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
BEGIN
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('CONSULTA_HISTORICO_RENEGOCIACAO', 'empr0021', 'pc_busca_hist_reneg_web', 'pr_nrdconta,pr_nrctremp', vr_nrseqrdr);
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('VALIDA_LINHA_CREDITO', 'empr0021', 'pc_valida_linha_cred_web', 'pr_cdlcremp,pr_dtdpagto', vr_nrseqrdr);
  
  
  
  COMMIT;
END;