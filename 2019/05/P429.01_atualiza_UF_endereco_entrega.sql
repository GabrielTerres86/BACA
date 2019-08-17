begin

  update tbcrd_endereco_entrega a
     set a.cdufende = 'SC'
   where a.cdcooper = 6;

  commit;
end;
