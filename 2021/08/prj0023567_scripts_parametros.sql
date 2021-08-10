-- project/prj0023567 / parametros - Segunda subida para test
BEGIN
        
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTA_PREAPV_CADPRE'
    ,'LPRV0001'
    ,'pc_consulta_preapv_cadpre'
    ,'pr_inpessoa,pr_tpprodut'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'LPRV0001'
        AND ROWNUM = 1));  
        
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('ALTERA_PREAPV_CADPRE'
    ,'LPRV0001'
    ,'pc_altera_preapv_cadpre'
    ,'pr_inpessoa,pr_tpprodut,pr_loadpas,pr_loadseg'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'LPRV0001'
        AND ROWNUM = 1));              

  COMMIT;
  
END;
