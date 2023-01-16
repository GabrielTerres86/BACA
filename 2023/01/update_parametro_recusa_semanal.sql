begin
update crapprm  p set p.dsvlrprm = 'AILOS_CONTRIBUTARIO_AILOS_ddmmaaaa_Relatorio_STATUS.txt' where  p.cdacesso ='RECUSA_SEG_CONTR_SEMANAL';
commit;
end;
  
