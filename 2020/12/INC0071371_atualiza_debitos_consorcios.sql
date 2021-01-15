begin
  update craplau u 
     set u.dtmvtopg = to_date('14/12/2020','DD/MM/RRRR')
   where u.dtmvtopg = '12/12/2020'
     and cdhistor in (1230,1231,1232,1233,1234,2027) 
     and insitlau = 1;
     commit;
exception
  when others then
    dbms_output.put_line('Erro ao atualizar crapcns');
end;
