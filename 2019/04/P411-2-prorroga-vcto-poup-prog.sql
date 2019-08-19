
/* Prorroga em 1 ano o vencimento dos planos de poupanca programada que vencem este ano,
   para dar tempo de realizar a migracao para aplicacao programada */

update craprpp 
   set dtvctopp = to_date(extract(day from dtvctopp)|| '/' ||extract(month from dtvctopp)|| '/' || ( extract(year from dtvctopp) + 1), 'dd/mm/rrrr')
 where cdsitrpp <> 5 /* Vencido */
   and cdcooper in (1,2,3,5,6,7,8,9,10,11,12,13,14,16) /* Cooperativas ativas */
   and dtvctopp between '01/01/2019' and '31/12/2019';

commit;
