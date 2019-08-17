begin 
  update crapprm m 
     set m.dsvlrprm = 'projetoailos@mdsinsure.com;seguros@ailos.coop.br;ailos.ftpchubb@mdsinsure.com'
   where m.nmsistem = 'CRED'
     and m.cdacesso = 'CRRL226_MAIL_GENER';
  commit;     
exception
  when others then
    dbms_output.put_line('Erro ao atualizar Email dos seguros. '||sqlerrm);
end;


