update crapaca a 
set a.lstparam = a.lstparam||',pr_nrcheque'
where
a.nmdeacao = 'CONSULTACOMPEN';
commit;
