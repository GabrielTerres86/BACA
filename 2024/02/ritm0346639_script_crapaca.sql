BEGIN
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('DEBITAR_PARCELA'
    ,'EMPR0025'
    ,'pc_debitar_imobiliario_web'
    ,'pr_cdcooper_parcela,pr_idparcela'
    ,(SELECT a.nrseqrdr
        FROM craprdr a
       WHERE a.nmprogra = 'EMPR0025'
         AND ROWNUM = 1));
         
  COMMIT;

EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END; 
