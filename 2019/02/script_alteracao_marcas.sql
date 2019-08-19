
-- Mudanças de Marcas
-- SCRCRED para CIVIA, a RODOCREDITO para EVOLUA e a CECRISACRED para ACENTRA
-- Alteração marcas 

/*SCRCRED*/   
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'SCRCRED','CIVIA')
 where p.cdcooper = 13
   and p.cdacesso = 'IMG_LOGO_COOP';
--Emails
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'scrcred','civia')
 where p.cdcooper = 13
   and p.dsvlrprm like '%@scrcred%';

/*RODOCREDITO*/   
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'RODOCREDITO','EVOLUA')
 where p.cdcooper = 14
   and p.cdacesso = 'IMG_LOGO_COOP';
--Emails
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'rodocredito','evolua')
 where p.cdcooper = 14
   and p.dsvlrprm like '%@rodocredito%';   
    
/*CECRISACRED*/   
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'CECRISACRED','ACENTRA')
 where p.cdcooper = 5
   and p.cdacesso = 'IMG_LOGO_COOP';
--Emails
update crapprm p
   set p.dsvlrprm = replace(p.dsvlrprm,'cecrisacred','acentra')
 where p.cdcooper = 14
   and p.dsvlrprm like '%@cecrisacred%';  
commit;
