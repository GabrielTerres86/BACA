update crapaca aca
set aca.lstparam = 'pr_cdcooper, pr_cdoperad, pr_prz_baixa_cip, pr_vlvrboleto, pr_vlcontig_cip, pr_sit_pag_divergente, pr_pag_a_menor, pr_pag_a_maior, pr_tip_tolerancia, pr_vl_tolerancia, pr_dt_vld_benef'
where aca.nmpackag = 'TELA_TAB098'
and   aca.nmproced = 'pc_atualizar';

commit;
