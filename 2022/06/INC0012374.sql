begin
  
  update tbcadast_pessoa_atualiza
     set insit_atualiza = 2
     where insit_atualiza = 1;
    
  commit;
    
exception
  when others then
    raise_application_error(-20000, 'ERRO: ' || SQLERRM);
end;
