begin  
  --#######################################################################################################################################
  --
  -- 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de baca';
    begin
		update tbdomic_liqtrans_msg_ltrstr a 
		 set a.insituacao = 1
		 where a.idmensagem = 38393;
		   
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;