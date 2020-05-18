begin  
  --#######################################################################################################################################
  --
  -- 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Atualização de dados da CRAPTEL';
    begin
      
		update craptel a
		   set a.cdopptel = '@,C,A', a.lsopptel = 'ACESSO,CONSULTAR,ALTERAR'
		 where a.nmdatela = 'CARCRD'
		   and a.nmrotina = 'LOPCRD';
 
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

