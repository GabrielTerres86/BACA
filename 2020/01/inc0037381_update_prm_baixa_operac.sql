/*
Atualizar parâmetro BAIXA_OPERAC_TEMP_LIM para limitar o tempo de execução da baixa operacional para contornar uma falha de programação no package NPCB0002.
*/
begin
  update crapprm
     set dsvlrprm = '660'
   where cdacesso = 'BAIXA_OPERAC_TEMP_LIM';
  commit;
exception
  when others then
    pc_internal_exception;
end;
