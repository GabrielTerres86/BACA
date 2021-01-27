UPDATE crapaca
   SET lstparam = 'pr_cddopcao, pr_cdprodut, pr_nmprodut, pr_idsitpro, pr_cddindex, pr_idtippro, pr_idtxfixa, pr_idacumul, pr_indplano, pr_indanive'
 WHERE nmdeacao = 'MANPRO'
   AND nmpackag = 'apli0003';

update crapaca set lstparam = 'pr_cddopcao,pr_cdprodut,pr_cdhscacc,pr_cdhsvrcc,pr_cdhsraap,pr_cdhsnrap,pr_cdhsprap,pr_cdhsrvap,pr_cdhsrdap,pr_cdhsrnap,pr_cdhsirap,pr_cdhsrgap,pr_cdhsvtap'
where nmdeacao = 'MANHISPRO';

COMMIT;

