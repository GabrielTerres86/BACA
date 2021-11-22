begin
dbms_scheduler.disable(name=>'CREDITO.JBEPR_PROCESSA_TED_IMOB');
dbms_scheduler.disable(name=>'CREDITO.JBEPR_PROCESSA_PAG_IMOB');
dbms_scheduler.disable(name=>'CREDITO.JBEPR_PROCESSA_RET_IMOB');
dbms_scheduler.disable(name=>'CREDITO.JBEPR_IMOB_IMP_CONTRATO');
commit;
exception
 when others then
  null;
end;