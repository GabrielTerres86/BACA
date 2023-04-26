BEGIN

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('LISTA_BENS_IMOBILIARIO'
    ,'EMPR0025'
    ,'pc_listar_bens'
    ,'pr_nrdconta,pr_nrctremp,pr_idseq_bem'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));
		
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('ALTERAR_BENS_IMOBILIARIO'
    ,'EMPR0025'
    ,'pc_alterar_bens'
    ,'pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));		
        
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
