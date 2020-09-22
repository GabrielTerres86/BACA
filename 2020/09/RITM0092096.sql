begin
	update crapprm set
		   dsvlrprm = 0
	where cdacesso = 'COVID_QTDE_PARCELA_ADIAR' 
	and cdcooper = 9;
	
	commit;
exception
  when others then
    rollback;
end;