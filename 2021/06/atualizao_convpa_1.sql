update CECRED.creacrapaca set  LSTPARAM = 'pr_cddopcao,pr_cdcooper,pr_cdsegmto,pr_flagbarr,pr_vllimite,pr_hrlimite,pr_vhlimite,pr_hrlimitefim' 
WHERE nmpackag = 'TELA_CONVPA' 
and nmdeacao = 'GRAVAR_SEGMTO_LIMITE';
commit; 

