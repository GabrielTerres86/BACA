update crapaca set lstparam = lstparam||',pr_inddebitador'  where upper(nmdeacao) = 'DESABILITAR_EMPR_CONSIG';
commit;
