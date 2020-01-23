begin
  --#######################################################################################################################################
  --
  -- Script de Ajuste INC0031516"
  --
  declare
		-- nome da rotina
		wk_rotina varchar2(200) := 'Script de Ajuste INC0031516';
  begin
	begin
		update crawcrd c 
		   set c.cdgraupr = 5, c.vllimcrd = 0
		 where c.cdcooper = 11 and c.nrdconta = 368091 and c.nrcrcard = 6393500081900160;
	exception
		when others then
		  dbms_output.put_line(wk_rotina||' -> Erro atualizacao Wcartao 6393500081900160 '||sqlerrm);
	end;
	--
	begin
		update crawcrd c 
		   set c.cdgraupr = 5, c.vllimcrd = 4000, c.cdlimcrd = 26, c.dddebito = 11, c.dtsolici = '07/03/2019', 
		       c.nrcctitg = 7564438022332
		 where c.cdcooper = 11 and c.nrdconta = 368091 and c.nrcrcard = 5474080107530253;
	exception
		when others then
		  dbms_output.put_line(wk_rotina||' -> Erro atualizacao Wcartao 5474080107530253 '||sqlerrm);
	end;
		--
	begin
		update crapcrd c 
		   set c.cdlimcrd = 26, c.dddebito = 11
		 where c.cdcooper = 11 and c.nrdconta = 368091 and c.nrcrcard = 5474080107530253;
	exception
		when others then
		  dbms_output.put_line(wk_rotina||' -> Erro atualizacao Pcartao 5474080107530253 '||sqlerrm);
	end;
		--
	begin
		update tbcrd_conta_cartao t
		   set t.vllimite_global = 0
		 where t.cdcooper = 11
		   and t.nrdconta = 368091 
		   and t.nrconta_cartao = 7564438018255;
	exception
		when others then
		  dbms_output.put_line(wk_rotina||' -> Erro atualizacao tbcrd_conta_cartao 7564438018255 '||sqlerrm);
	end;
	--
	begin
		update tbcrd_conta_cartao t
		   set t.vllimite_global = 4000
		 where t.cdcooper = 11
		   and t.nrdconta = 368091 
		   and t.nrconta_cartao = 7564438022332;
		--
	exception
		when others then
		  dbms_output.put_line(wk_rotina||' -> Erro atualizacao tbcrd_conta_cartao 7564438022332 '||sqlerrm);
	end;
	commit;
	dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  end;
end;