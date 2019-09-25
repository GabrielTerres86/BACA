--RF015
begin
  --3 - Misto
  begin      
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
  -- 
end;     
