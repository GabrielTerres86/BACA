begin  
  --#######################################################################################################################################
  --
  -- 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'REVERT de parametro de ambiente';
    begin
		delete crapprm a where a.cdcooper = 3 and a.cdacesso = 'AMBIENTE';
		commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

