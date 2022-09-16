begin

UPDATE CRAPACA SET LSTPARAM='pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,r_enviadoReproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist'
WHERE NMDEACAO='TAB057_REMESSAS_RECEITA_FEDERAL';

UPDATE CRAPACA SET LSTPARAM='pr_idremessa,pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoReproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist'
WHERE NMDEACAO='TAB057_REGISTROS_REMESSAS_RFB';

commit;

end;