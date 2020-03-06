/*
	Chamado : 
	Autor   : Gabriel Fronza Marcos - Mout'S
	Data    : 03/03/2020
	--> 270 segundos no H6
*/

declare 

  cursor cr_crapcti is
  select rowid
    from crapcti;

  -- Tabela temporaria do bulk collect
  type typ_dados_cursor is table of cr_crapcti%rowtype;
  vr_dados_cursor typ_dados_cursor;
  vr_int BINARY_INTEGER;
  
  vr_contador integer := 0;

begin
  
  -- Loop nos cooperados aptos a estarem na assembleia
  open cr_crapcti;
    
  loop 
      
    fetch cr_crapcti bulk collect into vr_dados_cursor limit 200;
    exit when vr_dados_cursor.count = 0;
    
    for vr_int in 1 .. vr_dados_cursor.count loop
            
      update crapcti set inenvted = 1 where rowid = vr_dados_cursor(vr_int).rowid;
      
      vr_contador := vr_contador + 1;
      
      if MOD(vr_contador,200) = 0 then
        commit;
      end if;
    
    end loop;

  end loop;
    
  commit;
  
  dbms_output.put_line('Sucesso! '||sqlerrm);

exception
  when others then
    -- No caso de erro de programa gravar tabela especifica de log
    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
    dbms_output.put_line('Erro: '||sqlerrm);                 
    ROLLBACK;
end;