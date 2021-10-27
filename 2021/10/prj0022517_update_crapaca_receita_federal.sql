BEGIN

  UPDATE cecred.crapaca aca
     SET aca.lstparam = 'pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoreproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist'
   WHERE aca.nmdeacao = 'TAB057_REMESSAS_RECEITA_FEDERAL';

  UPDATE cecred.crapaca aca 
     SET aca.lstparam = 'pr_idremessa,pr_dtiniper,pr_dtfimper,pr_cdempres,pr_status1perna,pr_status2perna,pr_enviadoreproces,pr_tlcooper,pr_nrdconta,pr_tlagenci,pr_nmarquivo,pr_textopesquisa,pr_orderby,pr_nriniseq,pr_nrregist'
   WHERE aca.nmdeacao = 'TAB057_REGISTROS_REMESSAS_RFB';
   
   COMMIT;

END;   
