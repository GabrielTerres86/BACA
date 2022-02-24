PL/SQL Developer Test script 3.0
54
declare 
  cursor op_adps is
    select o.rowid 
      from crapdat d, tbrisco_operacoes o
     where (o.tpctrato = 11)
       and o.cdcooper = d.cdcooper
       and (o.dtvencto_rating < d.dtmvtolt OR o.inrisco_rating IS NULL)
       and not exists (select 1
                         from crawlim l
                        where l.cdcooper = o.cdcooper
                          and l.nrdconta = o.nrdconta
                          and l.tpctrlim = 1
                         and l.insitlim = 2)
       and not exists (select 1
                         from crapris r
                        where r.cdcooper = o.cdcooper
                          and r.nrdconta = o.nrdconta
                          and r.nrctremp = o.nrdconta
                          and r.dtrefere = d.dtmvtoan
                          and r.cdmodali = 101);

 type  typ_lista is table of rowid index by pls_integer;
 lista typ_lista;
 i     pls_integer := 0;
 total pls_integer := 0;

begin

  for adp in op_adps loop
    lista(i) := adp.rowid;
    i := i + 1;
  end loop;
  dbms_output.put_line('Carregou da lista: ' || lista.count());

  for i in 0 .. lista.count()-1 loop
    delete from tbrisco_operacoes o where o.rowid = lista(i);
    total := total + 1;
    if (total > 1000) then
      commit;
      total := 0;
    end if;
  end loop;

  commit;
  dbms_output.put_line('Removeu da tabela: ' || lista.count());

  delete from tbrisco_operacoes o where o.tpctrato = -1 and o.cdcooper <> 1;
  commit;

  delete from tbrisco_operacoes o where o.tpctrato = -1 and o.cdcooper = 1;
  commit;

  dbms_output.put_line('Removeu da tabela produto inválido.');
end;
0
0
