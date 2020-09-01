begin  
  --#######################################################################################################################################
  --
  -- Script da RITM0091242
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'script da RITM0091242';
    begin
		update crapprm p set
		       p.dsvlrprm = 'cartoes@ailos.coop.br,tesouraria@ailos.coop.br'
		 where p.cdacesso = 'CRD_MONITORAMENTO';
				   
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;