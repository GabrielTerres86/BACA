begin  
  --#######################################################################################################################################
  --
  -- Script de ajuste de cartao"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de ajuste de cartao';
    begin
		---- ajuste cartao 5127070272881590
		update crawcrd a
		   set a.cdadmcrd = 12, 
			   a.dddebito = 11
		 where a.cdcooper = 1
		   and a.nrdconta = 8076588
		   and a.nrcrcard = 5127070272881590;
		   
		update crapcrd a
		   set a.cdadmcrd = 12, 
			   a.dddebito = 11
		 where a.cdcooper = 1
		   and a.nrdconta = 8076588
		   and a.nrcrcard = 5127070272881590;
		   
		   ---- ajuste cartao 6042034015772730
		update crawcrd a
		   set a.cdadmcrd = 11, 
			   a.dddebito = 19
		 where a.cdcooper = 1
		   and a.nrdconta = 8076588
		   and a.nrcrcard = 6042034015772730;
		   
		update crapcrd a
		   set a.cdadmcrd = 11, 
			   a.dddebito = 19
		 where a.cdcooper = 1
		   and a.nrdconta = 8076588
		   and a.nrcrcard = 6042034015772730;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

