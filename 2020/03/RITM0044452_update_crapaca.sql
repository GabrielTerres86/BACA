update crapaca
   set crapaca.lstparam = crapaca.lstparam || ',pr_tpuniate'
 where crapaca.nmdeacao = 'CADPAC_GRAVA';
 
 commit;
