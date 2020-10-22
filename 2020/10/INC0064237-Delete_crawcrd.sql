begin

  begin
    delete crawcrd
     where cdcooper = 1
       and nrdconta = 8112070
       and nrctrcrd = 1872822;
  exception
    when others then
      dbms_output.put_line('Erro no delete 01 - ' || sqlerrm);
  end;

  begin
    delete crawcrd
     where cdcooper = 1
       and nrdconta = 11788496
       and nrctrcrd = 1876546;
  exception
    when others then
      dbms_output.put_line('Erro no delete 02 - ' || sqlerrm);
  end;

  begin
    delete crawcrd
     where cdcooper = 1
       and nrdconta = 11838655
       and nrctrcrd = 1889921;
  exception
    when others then
      dbms_output.put_line('Erro no delete 03 - ' || sqlerrm);
  end;

  begin
    delete crawcrd
     where cdcooper = 2
       and nrdconta = 861103
       and nrctrcrd = 132275;
  exception
    when others then
      dbms_output.put_line('Erro no delete 04 - ' || sqlerrm);
  end;

  begin
    delete crawcrd
     where cdcooper = 2
       and nrdconta = 882712
       and nrctrcrd = 132769;
  exception
    when others then
      dbms_output.put_line('Erro no delete 05 - ' || sqlerrm);
  end;

  begin
    delete crawcrd
     where cdcooper = 10
       and nrdconta = 161691
       and nrctrcrd = 27739;
  exception
    when others then
      dbms_output.put_line('Erro no delete 06 - ' || sqlerrm);
  end;

  dbms_output.put_line('Registros excluídos com sucesso!');
  commit;
  
end;
