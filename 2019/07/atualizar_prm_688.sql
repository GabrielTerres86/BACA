update crapprm m
   set m.dsvlrprm = '15/07/2019#2'
 where m.cdacesso = 'CTRL_CRPS688_EXEC'
   and m.cdcooper = 1;

commit;
