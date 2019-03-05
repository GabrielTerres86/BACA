DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_CONSIG';
  
  --Incluir a ação INC_ALT_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('INC_ALT_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_alt_empr_consig_param_web'
    ,'pr_idemprconsigparam,pr_cdempres,pr_dtinclpropostade,pr_dtinclpropostaate,pr_dtenvioarquivo,pr_dtvencimento'
    ,v_nrseqrdr);
    
  --Incluir a ação EXCLUIR_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('EXCLUIR_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_excluir_empr_consig_param_web'
    ,'pr_idemprconsigparam,pr_cdempres'
    ,v_nrseqrdr);
    
  --Incluir a ação REPLICAR_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('REPLICAR_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_replicar_empr_consig_param_web'
    ,'pr_idemprconsigparam,pr_cdempres,pr_dtinclpropostade,pr_dtinclpropostaate,pr_dtenvioarquivo,pr_dtvencimento'
    ,v_nrseqrdr); 
    
  --Incluir a ação BUSCAR_VENC_PARCELA 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCAR_VENC_PARCELA'
    ,'TELA_CONSIG'
    ,'pc_buscar_empr_consig_param_web'
    ,'pr_idemprconsigparam,pr_cdempres'
    ,v_nrseqrdr);    
    
  COMMIT;             
END; 
