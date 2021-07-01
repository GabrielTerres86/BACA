begin
  --
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'TAB089_CONSULTAR_RENEG', 'TELA_TAB089', 'pc_consultar_reneg', '', (select nrseqrdr from craprdr where nmprogra = 'TELA_TAB089'));
  --
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'TAB089_ALTERAR_RENEG'  , 'TELA_TAB089', 'pc_alterar_reneg'  , 'pr_flatmobi,pr_flatconl,pr_qtdiamin,pr_qtdiamax,pr_cdfincan,pr_cdlcrcpp,pr_cdlcrpos,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr,pr_flgcores,pr_nrmxreca,pr_vlmxremo,pr_vlmxreon,pr_vlmxreca,pr_nrmxcoca,pr_qtvalsim,pr_qtvalpro,pr_vlmxassi,pr_flatchib,pr_cdviscnt,pr_qtminatr,pr_qtmaxatr', (select nrseqrdr from craprdr where nmprogra = 'TELA_TAB089'));  
  --
  UPDATE crapaca SET lstparam = 'pr_prtlmult,pr_prestorn,pr_prpropos,pr_vlempres,pr_pzmaxepr,pr_vlmaxest,pr_pcaltpar,pr_vltolemp,pr_qtdpaimo,pr_qtdpaaut,pr_qtdpaava,pr_qtdpaapl,pr_qtdpasem,pr_qtdpameq,pr_qtdibaut,pr_qtdibapl,pr_qtdibsem,pr_qtditava,pr_qtditapl,pr_qtditsem,pr_pctaxpre,pr_qtdictcc,pr_avtperda,pr_vlperavt,pr_vlmaxdst,pr_inpreapv,pr_vlmincnt,pr_nrmxrene,pr_nrmxcore,pr_pcalttax,pr_nrperccc,pr_preapvhib,pr_vlmaxhibfis,pr_vlmaxhibjur'
  WHERE  nmdeacao             = 'TAB089_ALTERAR';
  --
  commit;
  --
end;
