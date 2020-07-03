update crapaca a
set a.lstparam =   'pr_cdcooper_usr,pr_cdcooper,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_cdestado,pr_cartorio,pr_flcustas'
where a.nmpackag = 'TELA_MANPRT'
and   a.nmproced = 'pc_exporta_consulta_custas';

commit;

