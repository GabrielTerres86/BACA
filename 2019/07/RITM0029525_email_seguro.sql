
begin
  update crapprm m
     set m.dsvlrprm = 'seguroseconsorcios@ailos.coop.br;integracao_ailos@sicredi.com.br'
   where m.cdacesso = 'AUTO_DEST_FIM_PROC'; 
   
   commit;
exception
  when others then
    dbms_output.put_line('Erro ao atualizar AUTO_DEST_FIM_PROC. ' || sqlerrm);
end;
 

