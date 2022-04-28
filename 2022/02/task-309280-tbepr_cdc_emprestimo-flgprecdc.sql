BEGIN
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('SINALIZA_PRE_APROVADO_CDC'
    ,'EMPR0012'
    ,'pc_sinalizar_pre_aprovado_cdc_web'
    ,'pr_cdcooper,pr_nrdconta, pr_nrctremp, pr_flgprecdc'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0012'
        AND ROWNUM = 1));  
COMMIT;        
END;