begin
update crapaca set crapaca.lstparam = 'pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoReproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist'
where crapaca.nmpackag like '%TAB057%' and crapaca.nrseqaca = 4956
commit;

end;