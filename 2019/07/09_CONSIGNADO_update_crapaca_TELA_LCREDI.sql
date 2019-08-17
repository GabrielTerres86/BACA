update crapaca a
  set a.lstparam = a.lstparam||',pr_tpmodcon'
where a.nmpackag = 'TELA_LCREDI'
  and a.nmdeacao in ('ALTLINHA','INCLINHA');
commit;
