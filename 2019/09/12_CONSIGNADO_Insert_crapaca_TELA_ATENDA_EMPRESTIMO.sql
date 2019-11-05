DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_ATENDA_EMPRESTIMO';
  
  --Incluir a ação VALIDAR_INF_CADASTRAIS 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VALIDAR_INF_CADASTRAIS'
    ,'TELA_ATENDA_EMPRESTIMO'
    ,'pc_validar_inf_cadastrais_web'
    ,'pr_nrdconta'
    ,v_nrseqrdr);
    
  COMMIT;             
END; 
