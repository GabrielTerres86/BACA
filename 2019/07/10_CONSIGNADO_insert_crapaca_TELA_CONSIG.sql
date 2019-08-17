DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_CONSIG';
  
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
    ,'pc_val_cooper_consignado_web'
    ,'pr_cdcooper'
    ,v_nrseqrdr);
	
  --Incluir a ação BUSCA_EMPRESA
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCA_EMPRESA'
    ,'TELA_CONSIG'
    ,'pc_busca_dados_emp_fis'
    ,''
    ,v_nrseqrdr);	
    
  COMMIT;             
END; 
/
