begin

update crapaca set crapaca.lstparam = 'pr_tlcooper,pr_dtiniper,pr_cdempres,pr_nriniseq,pr_nrregist'
  where crapaca.nmpackag = 'TELA_TAB057' and crapaca.nmdeacao = 'TAB057_CONTAB_CENTRAL';

commit;
end;