begin
   update cecred.tbseg_parametros_prst p set p.dtctrmista = to_date('06/11/2023','dd/mm/yyyy') where p.idseqpar = 1000;
   update cecred.tbseg_parametros_prst p set p.dtfimvigencia = to_date('04/11/2023','dd/mm/yyyy') where p.idseqpar = 4;
   commit;
end;
