begin
  update crapsle c
     set c.dsendere = 'base2-erika.andrade@ailos.coop.br', 
         c.flenviad = 'N'
   where c.cdprogra = 'JB_ARQPRST'
     and c.nrseqsol = 26107684;
  commit;
end;
/
