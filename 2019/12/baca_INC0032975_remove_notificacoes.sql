begin
  --#######################################################################################################################################
  --
  -- delete de notificações de cartão
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'delete de notificações de cartão';
    begin
	
		delete tbgen_notif_push a where a.cdnotificacao in(select a.cdnotificacao from cecred.tbgen_notificacao a where a.cdmensagem in (1128,1129,1130,1131,1132,1133));
		dbms_output.put_line('Sucesso ao executar delete de registros de PUSH da "tbgen_notif_push" ');
		delete cecred.tbgen_notificacao a where a.cdmensagem in (1128,1129,1130,1131,1132,1133);   
		dbms_output.put_line('Sucesso ao executar delete de registros de Notificação da "tbgen_notificacao" ');
		
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;