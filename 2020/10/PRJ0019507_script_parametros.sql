UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'INCLINHA'
AND a.nmpackag = 'TELA_LCREDI';

UPDATE crapaca a
SET a.lstparam = a.lstparam||',pr_flgrepro'
where a.nmdeacao = 'ALTLINHA'
AND a.nmpackag = 'TELA_LCREDI';

commit;