begin  
  --#######################################################################################################################################
  --
  -- Criação de parametro - Intervalo de dias de execução do job para geração dos relatórios 593 e 594
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de parametro - Intervalo de dias de execução do job para geração dos relatórios 593 e 594';
    begin
		insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
		values ('CRED', 0, 'JOB_INTERV_CARTOES', 'Intervalo de dias de execução do job para geração dos relatórios 593 e 594', '15');
		commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;




