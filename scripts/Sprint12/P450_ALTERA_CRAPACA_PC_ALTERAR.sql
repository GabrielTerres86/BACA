UPDATE crapaca c
   SET c.lstparam = 'pr_prtlmult,pr_prestorn,pr_prpropos,pr_vlempres,pr_pzmaxepr,pr_vlmaxest,pr_pcaltpar,pr_pctaxpre,pr_vltolemp,pr_qtdpaimo,pr_qtdpaaut,pr_qtdpaava,pr_qtdpaapl,pr_qtdpasem,pr_qtdibaut,pr_qtdibapl,pr_qtdibsem,pr_qtdictcc'  
 WHERE c.nmpackag = 'TELA_TAB089'
   and c.nmproced = 'pc_alterar';