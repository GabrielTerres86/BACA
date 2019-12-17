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
      delete cecred.tbgen_notificacao a where a.cdmensagem in (1128,1129,1130,1131,1132,1133);   
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;