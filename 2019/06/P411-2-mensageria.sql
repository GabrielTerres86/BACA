
insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values
(null, 'REATIVA_APL_PROG','APLI0008','pc_reativar_apl_prog_web','pr_nrdconta,pr_idseqttl,pr_nrctrrpp,pr_dtmvtolt,pr_flgerlog',(select nrseqrdr from craprdr where nmprogra = 'APLI0008'));

commit;