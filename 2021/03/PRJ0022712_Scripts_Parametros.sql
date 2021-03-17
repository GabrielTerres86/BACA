-- PRJ0022712

--crapaca
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('LISTA_CARGAS_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_lista_cargas_limite'
  ,'pr_nrregist,pr_nriniseq,pr_tpctrlim'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));
     
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('EXEC_CARGA_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_proc_carga_limite'
  ,'pr_idcarga,pr_tpctrlim,pr_cddopcao,pr_dsrejeicao'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));

      
INSERT INTO crapaca
  (nmdeacao
  ,nmpackag
  ,nmproced
  ,lstparam
  ,nrseqrdr)
VALUES
  ('LISTA_DETALHE_CARGAS_LIMITE'
  ,'TELA_IMPPRE'
  ,'pc_lista_hist_cargas_limite'
  ,'pr_cdcooper,pr_idcarga,pr_tpctrlim,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_dtliberafim,pr_dtvigencia,pr_dtvigenciafim,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq'
  ,(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'TELA_IMPPRE'
      AND ROWNUM = 1));       
     

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpprodut'
 WHERE a.nmdeacao = 'BUSCA_CRAPPRE';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpprodut'
 WHERE a.nmdeacao = 'GRAVA_CRAPPRE';
 
UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_BLOQ_CARGA';

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_EXCLU_MANUAL';
 
COMMIT;
