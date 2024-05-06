begin

update cecred.crapprm p
   set p.dsvlrprm = '16/10/2023'
 where p.cdcooper = 7
   and p.cdacesso = 'DIA_ATIVA_CONTRB_SEGPRE';
   
commit;
end;   