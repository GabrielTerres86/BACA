begin  
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de BACA do INC0047990';
    begin
		 UPDATE crawcrd w 
			SET w.nrcpftit = 67459706949    
		 WHERE w.nrcctitg = 47318046
		   AND w.nrdconta = 3093
		   AND w.cdcooper = 5;
		   
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;