update crapcyb c 
   set c.dtdbaixa = NULL
 where c.dtdbaixa = '30/10/2018'
   and c.dtdbaixa is not null;
   
commit;
