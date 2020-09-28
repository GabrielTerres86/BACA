begin
  for i in (select ass.cdcooper,
                   ass.nrdconta,
                   ass.nmprimtl,
                   his.dsvalor_anterior,
                   his.dsvalor_novo,
                   his.dhalteracao
              from crapass ass
              join tbcadast_pessoa pes
                on pes.nrcpfcgc = ass.nrcpfcgc
              left join tbcadast_pessoa_historico his
                on his.idpessoa = pes.idpessoa
             where ass.dtnasctl is null
               and ass.dtdemiss is null
               and his.idcampo = 41
             order by dhalteracao) loop
    if i.dsvalor_anterior is not null then
      update crapass c
         set c.dtnasctl = to_date(i.dsvalor_anterior, 'dd/mm/yyyy')
       where c.nrdconta = i.nrdconta
         and c.cdcooper = i.cdcooper;
    
      update crapttl t
         set t.dtnasttl = to_date(i.dsvalor_anterior, 'dd/mm/yyyy')
       where t.nrdconta = i.nrdconta
         and t.cdcooper = i.cdcooper
         and t.idseqttl = 1;
    end if;
  end loop;

  commit;
end;
