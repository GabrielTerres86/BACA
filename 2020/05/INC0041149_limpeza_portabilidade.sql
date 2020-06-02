-- Portabilidade de salario INC0039845
begin
  --
  update  tbcc_portabilidade_envia t
     set t.dsdemail = null
   where t.idsituacao = 1
     and t.dtsolicitacao >= to_date('17022020','ddmmyyyy')
     and nvl(length(trim(t.dsdemail)),0) > 0 and nvl(length(trim(t.dsdemail)),0) < 6;
  --
  commit;
  --
end;