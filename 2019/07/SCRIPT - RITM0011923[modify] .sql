declare
begin
    update crapprm set
  dsvlrprm = 'C'
  where cdacesso = 'LIMITE_APLIC_MANUAIS';
  update crapprm set
  dsvlrprm = 'D'
  where cdacesso = 'LIMITE_APLIC_MANUAIS' and
        cdcooper in (2, 7, 13);
        
  update crapprm set
  dsvlrprm = 'C'
  where cdacesso = 'LIMITE_APLIC_AGENDADAS';
  update crapprm set
  dsvlrprm = 'D'
  where cdacesso = 'LIMITE_APLIC_AGENDADAS' and
        cdcooper in (2, 6, 7, 13);
        
  update crapprm set
  dsvlrprm = 'C'
  where cdacesso = 'LIMITE_APLIC_PLANO_COTAS';
  update crapprm set
  dsvlrprm = 'D'
  where cdacesso = 'LIMITE_APLIC_PLANO_COTAS' and
        cdcooper in (6, 7, 9, 10, 12, 13, 16);
  commit;
  exception
  when others then
       dbms_output.put_line(sqlerrm);
       rollback;
  end;
