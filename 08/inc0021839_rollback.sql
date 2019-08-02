begin
  -- ROLLBACK de maracar recebido CIP para poder baixar o boleto
  Update crapcob b
     set B.ININSCIP = 1
   where b.cdcooper = 1
     and b.nrdconta = 9798250
     and b.nrdocmto = 675;
     commit;
exception
  when others then
    dbms_output.put_line('Erro ao atualizar CIP: ' || sqlerrm);
end;
