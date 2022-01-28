-- project/prj0023567 / parametros
BEGIN
  INSERT INTO craprdr
    (NMPROGRA
    ,DTSOLICI)
  VALUES
    ('LPRV0001'
    ,TRUNC(SYSDATE));
  
  COMMIT;  

  UPDATE crapaca a
     SET a.lstparam = a.lstparam || ',pr_tpctrlim'
   WHERE a.nmdeacao = 'EXEC_CARGA_MANUAL';

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('LISTA_DETALHE_CARGAS_PRECDC'
    ,'LPRV0001'
    ,'pc_lista_hist_cargas_precdc'
    ,'pr_cdcooper,pr_idcarga,pr_tppreapr,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_dtliberafim,pr_dtvigencia,pr_dtvigenciafim,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq'
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

  INSERT INTO tbgen_dominio_campo
    (NMDOMINIO
    ,CDDOMINIO
    ,DSCODIGO)
  VALUES
    ('TP_PRE_APROVADO'
    ,1
    ,'Pre-Aprovado CDC');

  COMMIT;
  
END;