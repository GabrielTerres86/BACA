begin  
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de atualização de permissão tela PARBCB';
    begin

    -- Adicionar opcao C na tela PARBCB devido ao erro de consulta, opcao nao cadastrada.
	  UPDATE craptel t
		 SET t.cdopptel = t.cdopptel || ',C', t.lsopptel = t.lsopptel || ',Consulta'
	   WHERE t.nmdatela = 'PARBCB';

	  INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
	  SELECT nmdatela,
			 'C',
			 cdoperad,
			 nmrotina,
			 3,
			 nrmodulo,
			 idevento,
			 idambace
	  FROM crapace
	  WHERE nmdatela = 'PARBCB'
		AND cdcooper = 3;
           
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;
