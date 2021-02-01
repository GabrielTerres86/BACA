update crapaca
   set lstparam = lstparam || ',pr_flgdonobem'
 where upper(nmdeacao) = 'GRAVA_ADT_TP5'
   and upper(NMPACKAG)= 'TELA_ADITIV';
COMMIT;