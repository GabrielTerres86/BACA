/*
   Script para cancelar agendamentos gerados de forma incorreta.

*/

--Atualiza
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331836';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331861';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331885';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331906';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331928';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331954';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331975';
update craplau set insitlau = 4, dtdebito = '16/04/19' where progress_recid = '26331997';


/*
--BACKUP
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331836';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331861';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331885';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331906';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331928';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331954';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331975';
update craplau set insitlau = 1, dtdebito = ''  where progress_recid = '26331997';
*/

COMMIT;
