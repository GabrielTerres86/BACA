begin
  update crapprm p
     set p.dsvlrprm = 'S'
   where p.cdacesso = 'UTILIZA_REGRAS_SEGPRE';
  commit;
exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
end;
/
