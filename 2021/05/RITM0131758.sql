begin
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('VERLOG_EXPORTA_CSV', 'TELA_VERLOG', 'pc_gera_csv', 'pr_dtopeini,pr_dtopefin,pr_cdcooper,pr_nrdconta,pr_idseqttl,pr_cdoperad,pr_dsorigem,pr_dstransa', 1946);

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('VERLOG_EXPORTA_PDF', 'TELA_VERLOG', 'pc_gera_pdf', 'pr_dtopeini,pr_dtopefin,pr_cdcooper,pr_nrdconta,pr_idseqttl,pr_cdoperad,pr_dsorigem,pr_dstransa', 1946);

commit;

end;