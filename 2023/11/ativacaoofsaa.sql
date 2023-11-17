begin
  update crapprm set dsvlrprm = 1 where  cdacesso = 'ENVIAR_TRANSF_AILOS_MAIS';
  commit;
end;