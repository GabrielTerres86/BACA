BEGIN

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('BUSCAR_PARCELAS_ADIAR_PRONAMPE'
    ,''
    ,'CREDITO.obterAdiamentoParcPronampeWeb'
    ,'pr_nrdconta,pr_nrctremp'
    ,1984);
  
  COMMIT;
END;
