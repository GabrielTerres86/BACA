begin
  --
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'TAB089_CONSULTAR_RENEG', 'TELA_TAB089', 'pc_consultar_reneg', '', (select nrseqrdr from craprdr where nmprogra = 'TELA_TAB089'));
  --
  insert into crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values ((select max(nrseqaca)+1 from crapaca), 'TAB089_ALTERAR_RENEG'  , 'TELA_TAB089', 'pc_alterar_reneg'  , 'pr_flatmobi,pr_flatconl,pr_qtdiamin,pr_qtdiamax,pr_cdfincan,pr_cdlcrcpp,pr_cdlcrpos,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr,pr_flgcores,pr_nrmxreca,pr_vlmxremo,pr_vlmxreon,pr_vlmxreca,pr_nrmxcoca,pr_qtvalsim,pr_qtvalpro,pr_vlmxassi,pr_flatchib,pr_cdviscnt,pr_qtminatr,pr_qtmaxatr', (select nrseqrdr from craprdr where nmprogra = 'TELA_TAB089'));  
  --
  UPDATE crapaca SET lstparam = trim(replace(replace(replace(lstparam,' ',''),',pr_qtdiamin,pr_qtdiamax,pr_cdfincan,pr_cdlcrcpp,pr_cdlcrpos,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr,pr_flgcores,pr_nrmxreca,pr_nrmxcoca,pr_qtvalsim,pr_flatmobi,pr_flatconl,pr_vlmxremo,pr_vlmxreon,pr_vlmxreca,pr_qtvalpro',''),',pr_vlmxassi,pr_flatchib,pr_cdviscnt,pr_qtminatr,pr_qtmaxatr',''))
  WHERE  nmdeacao             = 'TAB089_ALTERAR';
  --
  commit;
  --
end;
