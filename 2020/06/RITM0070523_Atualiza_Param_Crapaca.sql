update crapaca a
   set a.lstparam = a.lstparam || ',pr_titinvestigado'
 where a.nmdeacao = 'QBRSIG_QUEBRA_SIGILO';
commit;
