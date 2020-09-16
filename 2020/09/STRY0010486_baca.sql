begin  
  --#######################################################################################################################################
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Script de BACA ';
    begin
		
		--criação dos registros de limite para a modalidade
		--TPLIMCRD : 0 = concessão
		--TPLIMCRD : 1 = alteração de limite 
		--TPLIMCRD : 2 = pré-aprovado
		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (1, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (1, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (1, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (2, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (2, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (2, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (3, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (3, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (3, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (5, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (5, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (5, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (6, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (6, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (6, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (7, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (7, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (7, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (8, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (8, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (8, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (9, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (9, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (9, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (10, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (10, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (10, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (11, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (11, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (11, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (12, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (12, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (12, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (13, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (13, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (13, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (14, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (14, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (14, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (16, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (16, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (16, 18, 500, 100000, '3,7,11,19,22', 2);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (17, 18, 500, 100000, '3,7,11,19,22', 0);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (17, 18, 0, 100000, '3,7,11,19,22', 1);

		insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)
		values (17, 18, 500, 100000, '3,7,11,19,22', 2);

		   
      commit;
	  
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;