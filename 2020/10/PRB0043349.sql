--PRB0043349
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('IMPRES_CAR_WEB', 'EXTR0002', 'pc_gera_impressao_car_web', 'pr_cdcooper,pr_cdagenci,pr_nrdcaixa,pr_idorigem,pr_nmdatela,pr_dtmvtolt,pr_dtmvtopr,pr_cdprogra,pr_inproces,pr_cdoperad,pr_dsiduser,pr_flgrodar,pr_nrdconta,pr_idseqttl,pr_tpextrat,pr_dtrefere,pr_dtreffim,pr_flgtarif,pr_inrelext,pr_inselext,pr_nrctremp,pr_nraplica,pr_nranoref,pr_flgerlog,pr_intpextr,pr_tpinform,pr_nrperiod', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
commit;