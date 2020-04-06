begin  
  --#######################################################################################################################################
  --
  -- Ajuste de conta cartão na proposta do cooperado
  --
  begin
    declare 
    
    begin
		-- Alteração de conta cartão
		update crawcrd
		   set nrcctitg = 7563239042149
		 where cdcooper = 1
		   and nrdconta = 1871366
		   and nrseqcrd = 152559
		   and nrcctitg = 7563239145979;
		commit;
		dbms_output.put_line('Alteração efetuada com sucesso. Quantidade de registros alterados: ' || sql%rowcount);
    exception
      when others then
      dbms_output.put_line('Erro ao executar alteração --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
end;

