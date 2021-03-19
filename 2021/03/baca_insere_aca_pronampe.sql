BEGIN
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr
                     ) 
               VALUES('GERA_POSTERGACAO_PRONAMPE'
                     ,''
                     ,'CREDITO.geraPostergacaoPronampeWeb'
                     ,'pr_nrdconta,pr_nrctremp,pr_dtdpagto,pr_qtpreemp'
                     ,1984
                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
