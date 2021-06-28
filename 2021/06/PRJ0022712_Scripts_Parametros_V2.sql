-- PRJ0022712 - Parte 2

INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('EFETIVA_PROPOSTA_LIM_PREAPRV'
  ,'LIMI0004'
  ,'pc_efetivar_limite_web'
  ,'pr_nrdconta,pr_nrctrlim,pr_tpctrlim'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'LIMI0004'
      AND ROWNUM = 1)); 
