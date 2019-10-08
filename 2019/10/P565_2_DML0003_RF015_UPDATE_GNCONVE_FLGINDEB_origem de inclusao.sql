--RF015
declare
 vr_atualizado number := 0 ;
begin
  
  --Verificar se o script já foi executado, NÃO PODE RODAR DUAS VEZES
  select distinct 1
    into vr_atualizado  
    from gnconve t
   where cdconven in(15,30,82)
     and flgindeb = 3;
     
  if vr_atualizado = 0 then
       
    --3 - Misto
    /*begin      
      update gnconve t
         set flgindeb = 3
       where cdconven in(15,30,82);
       dbms_output.put_line('Convênio 15 Vivo, 30 Celesc e 82 WBT passaram a ser 3 - Misto ' );   
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 3 - Misto. '|| sqlerrm); 
    end; 
    --
    commit;
    --2 - Empresa Conveniada
    begin      
      update gnconve t
         set flgindeb = 2
       where flgindeb = 1;
       dbms_output.put_line('Inc.Deb = 1 passou a ser 2 - Empresa Conveniada '); 
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 2 - Empresa Conveniada. '|| sqlerrm); 
    end;
    --
    commit;
    --1 - Cooperativa
    begin      
      update gnconve t
         set flgindeb = 1
       where flgindeb = 0;
       dbms_output.put_line('Inc.Deb = 0 passou a ser 1 - Cooperativa ');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa . '|| sqlerrm); 
    end;
    --
    commit;     
    --*/ 
	
	--Popular campo novo INORIGEM_INCLUSAO
	--3 - Misto
    begin      
      update gnconve t
         set inorigem_inclusao = 3
       where cdconven in(15,30,82);
       dbms_output.put_line('Convênio 15 Vivo, 30 Celesc e 82 WBT passaram a ser 3 - Misto no campo Origem de Inclusão' );   
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 3 - Misto. '|| sqlerrm); 
    end; 
    --
    commit;
    --2 - Empresa Conveniada
    begin      
      update gnconve t
         set inorigem_inclusao = 2
       where flgindeb = 1;
       dbms_output.put_line('Inc.Deb = 1 passou a ser 2 - Empresa Conveniada no campo Origem de Inclusão'); 
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 2 - Empresa Conveniada. '|| sqlerrm); 
    end;
    --
    commit;
    --1 - Cooperativa
    begin      
      update gnconve t
         set inorigem_inclusao = 1
       where flgindeb = 0;
       dbms_output.put_line('Inc.Deb = 0 passou a ser 1 - Cooperativa ');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa no campo Origem de Inclusão. '|| sqlerrm); 
    end;
    --
    commit; 
	
  else
    dbms_output.put_line('Script já foi executado uma vez, não deve rodar novamente. '); 
	begin      
      update gnconve t
         set inorigem_inclusao = flgindeb;
       
       dbms_output.put_line('Origem de Inclusão recebeu o mesmo valor do campo Inc.Deb');    
    exception
      when others then
        dbms_output.put_line('Erro ao atualizar o campo gnconve.flgindeb para 1 - Cooperativa . '|| sqlerrm); 
    end;
	commit;
  end if;  
end;     
