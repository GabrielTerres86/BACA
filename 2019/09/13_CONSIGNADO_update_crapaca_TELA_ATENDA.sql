update crapaca 
   set lstparam = lstparam||',pr_vlrdoiof' 
 where  nmdeacao = 'CALC_IOF_EPR' 
   and nmpackag = 'TIOF0001';
 commit;