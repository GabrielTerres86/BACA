update crapprg 
   set crapprg.dsprogra##1 = 'Centralizacao Contabil PAGFOR'
      ,crapprg.cdrelato##1 = 0
 where upper(crapprg.cdprogra) = 'CRPS266';
commit;
