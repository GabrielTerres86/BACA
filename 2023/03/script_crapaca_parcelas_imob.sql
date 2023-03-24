BEGIN

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('LISTA_PARCELAS_IMOBILIARIO'
    ,'EMPR0025'
    ,'pc_listagem_parcelas'
    ,'pr_filtrocoop,pr_filtroconta,pr_filtrocontrato,pr_filtroDtVencInicio,pr_filtroDtVencFim,pr_filtroStatusParcela,pr_nriniseq,pr_nrregist'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));
               
  INSERT INTO cecred.crapaca 
    (NMDEACAO
    , NMPACKAG
    , NMPROCED
    , LSTPARAM
    , NRSEQRDR)
  VALUES ('ALTERAR_PARCELAS'
    , 'EMPR0025'
    , 'pc_alterar_parcelas'
    , 'pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));

	UPDATE crapaca a
	   SET a.lstparam = 'pr_tipo_arq, pr_dtleitura_ini,pr_dtleitura_fim'
   WHERE a.nmdeacao = 'BUSCAR_LOGS_ARQ_IMB';      
        
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
