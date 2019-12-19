begin
  for creg in (select cdcooper, nrpedido 
            from crapfdc a 
            where  a.dtconchq in ('04/12/2019' , '05/12/2019') and 
                   dtemschq is  null 
            group by cdcooper, nrpedido) loop
     update tbchq_seguranca_cheque a
     set a.idstatus_atualizacao_hsm = 2
     where a.cdcooper = creg.cdcooper
       and a.nrpedido = creg.nrpedido;
  end loop;
  commit;
end;
