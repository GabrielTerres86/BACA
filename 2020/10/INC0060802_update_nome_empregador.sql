begin
  update tbcc_portabilidade_envia t
     set t.dsnome_empregador = 'COMANDO DA AERONAUTICA'
   where t.nrdconta = 176290
     and t.cdcooper = 7
     and t.nrcnpj_empregador = 394429008276;
  commit;
end;

