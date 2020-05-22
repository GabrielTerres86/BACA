begin
  begin
    update crapcrd c
     set c.dtcancel = '13/12/2019', c.cdmotivo = 10
   where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127070022492524;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao cartao 5127070022492524 '||sqlerrm);
  end;

  begin
    update crawcrd c 
       set c.dddebito = 11, c.cdgraupr = 5, c.dtentreg = '12/12/2019', c.dtvalida = '31/03/2025'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127070226092104 and c.nrcctitg = 7563239107030;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Wcartao 5127070226092104 '||sqlerrm);
  end;

  begin
    update crapcrd c
       set c.dddebito = 11, c.dtvalida = '31/03/2025'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127070226092104;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Pcartao 5127070226092104 '||sqlerrm);
  end;
  --
  begin
    update crawcrd c 
       set c.dddebito = 11, c.cdgraupr = 5, c.dtvalida = '31/05/2025', c.dtsolici = '19/12/2019'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127070251755617 and c.nrcctitg = 7563239107030;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Wcartao 5127070251755617 '||sqlerrm);
  end;

  begin
    update crapcrd c
       set c.dddebito = 11, c.dtvalida = '31/05/2025'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127070251755617;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Pcartao 5127070251755617 '||sqlerrm);
  end;
 --
  begin
    update crawcrd c 
       set c.dddebito = 11, c.cdgraupr = 5, c.dtentreg = '20/12/2019', c.dtvalida = '31/10/2021', c.dtsolici = '27/11/2019'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127077302238550 and c.nrcctitg = 7563239107030;
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Wcartao 5127077302238550 '||sqlerrm);
  end;

  begin
    update crapcrd c
       set c.dddebito = 11, c.dtvalida = '31/10/2021'
     where c.cdcooper = 1 and c.nrdconta = 6063683 and c.nrcrcard = 5127077302238550;  
  exception
    when others then
      dbms_output.put_line('Erro atualizacao Pcartao 5127077302238550 '||sqlerrm);
  end;
  dbms_output.put_line('Script executado com sucesso.');
  commit;
end;
