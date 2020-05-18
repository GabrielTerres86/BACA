/*
Atualizar par�metro BAIXA_OPERAC_TEMP_LIM para limitar o tempo de execu��o da baixa operacional para contornar uma falha de programa��o no package NPCB0002.
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
