  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script da RITM0040688';
    begin
      UPDATE crapprm p 
	   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
	 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET25';

	UPDATE crapprm p 
	   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
	 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET23';
	 
	UPDATE crapprm p 
	   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
	 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET33'; 
	 commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;