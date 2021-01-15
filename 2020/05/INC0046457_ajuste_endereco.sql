--INC0046457 - Erro ao atualizar endereço pela tela CONTAS
begin
  update crapenc enc
     set enc.dsendere = 'RUA PEDRO REIG',
         enc.nrendere = 2730,
         enc.nmbairro = 'PEREQUE',
         enc.nmcidade = 'PORTO BELO',
         enc.complend = ' ',
         enc.nrcepend = 89210000
   where enc.cdcooper = 1
     and enc.nrdconta = 3043410
     and enc.tpendass = 10;

  commit;
end;