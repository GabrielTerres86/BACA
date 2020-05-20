insert into crapaca
  (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ('TAB057_REMESSAS_PAGFOR',
   'TELA_TAB057',
   'pc_busca_remessas_pagfor',
   'pr_cdcooper,pr_cdstatus,pr_flgocorr,pr_dtiniper,pr_dtfimper,pr_nriniseq,pr_nrregist',
   1184);
   
insert into crapaca
  (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ('TAB057_DET_REMESSA_PAGFOR',
   'TELA_TAB057',
   'pc_detalhar_remessa_pagfor',
   'pr_cdcooper,pr_idremess,pr_cdstatus,pr_vlrpagto,pr_cdcoptel,pr_nrdconta,pr_nriniseq,pr_nrregist',
   1184);   
   
commit;
