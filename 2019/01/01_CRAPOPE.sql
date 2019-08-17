/*
	Projeto 339 - Implantação Rightnow
	Autor: Rubens Lima - Mout'saque
	Data : 12/02/2019
*/

COMMENT ON COLUMN crapope.inutlcrm 
   IS 'Indicador de utilizacao de CRM (0-Somente pelo Aimaro; 1-Somente CRM; 2-Aimaro e CRM; 3-PA)';
   
ALTER TABLE crapope
  ADD insaqdes number(1) not null default 0;
 
COMMENT ON COLUMN crapope.insaqdes
   IS 'Indicador de saque parcial e desligamento pelo Aimaro';