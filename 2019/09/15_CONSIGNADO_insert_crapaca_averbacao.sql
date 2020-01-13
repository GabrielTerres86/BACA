DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'EMPR0014';
  
  --Incluir a ação VALIDA_AVERBACAO 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VALIDA_AVERBACAO'
    ,'EMPR0014'
    ,'pc_valida_averbacao'
    ,'pr_nrdconta,pr_nrctremp'
    ,v_nrseqrdr);
commit;
END;

