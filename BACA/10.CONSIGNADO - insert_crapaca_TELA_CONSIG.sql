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
    ,'pc_excluir_param_consig_web'
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
    ,'pc_replicar_param_consig_web'
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
    ,'pc_busca_param_consig_web'
    ,'pr_cdempres'
    ,v_nrseqrdr);   
   
  INSERT INTO CRAPACA
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VAL_COOPER_CONSIGNADO'
    ,'TELA_CONSIG'
    ,'pc_val_cooper_consignado_web',
    ,'pr_cdcooper'
    ,v_nrseqrdr);
-------------------------------------------------------------------------
	
  INSERT INTO CRAPPRM
    (nmsistem 
    ,cdcooper 
    ,cdacesso 
    ,dstexprm 
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,13
    ,'COOPER_CONSIGNADO'
    ,'Cooperativas que podem utilizar o consignado e suas validações'
    ,'S');	
    
  COMMIT;             
END; 
