declare
begin

update crapprm prm 
   set prm.dsvlrprm = 'A' 
 where prm.cdcooper = 7 
   and prm.nmsistem = 'CRED' 
   and prm.cdacesso = 'FLG_PAG_FGTS';

commit;
end;
/