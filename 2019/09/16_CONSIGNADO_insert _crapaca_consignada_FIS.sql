DECLARE
  v_nrseqrdr cecred.craprdr.nrseqrdr%type; 
BEGIN

  SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_CONSIG';
  
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
    , null
    ,v_nrseqrdr);


------------------------

SELECT nrseqrdr 
    INTO v_nrseqrdr
    FROM cecred.craprdr  
   WHERE nmprogra = 'TELA_CADEMP';
       
  --Incluir a ação BUSCA_CONSIG 
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCA_CONSIG'
    ,'TELA_CADEMP'
    ,'pc_busca_dados_consig_fis'
    , null
    ,v_nrseqrdr);
   
 
commit;

END;
/

