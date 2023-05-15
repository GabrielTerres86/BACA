BEGIN      
    INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VALIDA_EMPR_CONSIG'
    ,''
    ,'credito.obterEmpresaConsigWeb'
    ,''
    ,1805);
    
  COMMIT;
EXCEPTION    
  WHEN OTHERS THEN 
  ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END;
