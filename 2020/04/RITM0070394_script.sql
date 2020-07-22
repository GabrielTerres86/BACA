begin  
  --#######################################################################################################################################
  --
  -- 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de parametro de ambiente';
    begin
		insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
		values ('CRED', 3, 'AMBIENTE', 'Definicao de ambiente para mapemento de diretorios; ex: coopd1, coopd2, coopd3, coopd4, cooph1, cooph2, cooph6...', 'coopl', null);
		commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

