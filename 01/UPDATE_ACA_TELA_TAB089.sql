/* Baca precisa ser revisto na libera��o (confer�ncia dos parametros da procedure)*/
UPDATE crapaca c
   SET c.lstparam = 'pr_prtlmult,pr_prestorn,pr_prpropos,pr_vlempres,pr_pzmaxepr,pr_vlmaxest,pr_pcaltpar,pr_vltolemp,pr_qtdpaimo,pr_qtdpaaut,pr_qtdpaava,pr_qtdpaapl,pr_qtdpasem,pr_qtdpameq,pr_qtdibaut,pr_qtdibapl,pr_qtdibsem,pr_qtditava,pr_qtditapl,pr_qtditsem,pr_pctaxpre,pr_qtdictcc,pr_inpreapv,pr_vlmincnt'
 WHERE upper(c.nmpackag) = 'TELA_TAB089' and upper(c.nmproced) = 'PC_ALTERAR';

COMMIT;
