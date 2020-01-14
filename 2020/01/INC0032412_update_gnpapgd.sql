--INC0032412 - Alterando o ano da agenda progrid da cooperativa Credicomin

update gnpapgd
   set dtanoage = 2019
 where progress_recid = 2500;
 
   commit;