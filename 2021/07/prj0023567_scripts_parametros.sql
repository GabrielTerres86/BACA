-- project/prj0023567 / parametros

insert into craprdr ( NMPROGRA, DTSOLICI)
values ( 'LPRV0001', TRUNC(SYSDATE));
/
commit;
/

UPDATE crapaca a
   SET a.lstparam = a.lstparam || ',pr_tpctrlim'
 WHERE a.nmdeacao = 'EXEC_CARGA_MANUAL';
/
 
COMMIT;
/
insert into crapaca 
(nmdeacao, 
nmpackag, 
nmproced, 
lstparam, 
nrseqrdr)
values 
('LISTA_DETALHE_CARGAS_PRECDC', 
'LPRV0001', 
'pc_lista_hist_cargas_precdc', 
'pr_cdcooper,pr_idcarga,pr_tppreapr,pr_tpcarga,pr_indsitua,pr_dtlibera,pr_dtliberafim,pr_dtvigencia,pr_dtvigenciafim,pr_skcarga,pr_dscarga,pr_tpretorn,pr_nrregist,pr_nriniseq',
(SELECT a.nrseqrdr
     FROM craprdr a
    WHERE a.nmprogra = 'LPRV0001'
      AND ROWNUM = 1)
) ;
/
commit;
/

insert into tbgen_dominio_campo (NMDOMINIO,CDDOMINIO,DSCODIGO)
values ('TP_PRE_APROVADO'	,1,	'Pre-Aprovado CDC');
/
commit;
/

insert into crappre
  (cdcooper, tpprodut, inpessoa, cdfinemp)
values
  (1, 2, 1, 2);
/ 
commit
/