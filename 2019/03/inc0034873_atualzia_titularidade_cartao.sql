-- inc0034873 - Atualziar titularidade dos cartoes
begin
  update crawcrd d
     set d.flgprcrd = 1
   where d.flgprcrd = 0
     and d.insitcrd = 4
     and d.nrcrcard > 0
     and d.cdadmcrd between 10 and 80
     and d.flgdebcc = 1
     and d.dtpropos >= '01/01/2018'
     and d.cdadmcrd not in (16, 17)
     and d.dtcancel is null
     and not exists (select 1
            from crawcrd a
           where a.cdcooper = d.cdcooper
             and a.nrdconta = d.nrdconta
             and a.nrcpftit <> d.nrcpftit
             and a.nrcrcard > 0);
  commit;
exception
  when others then
    dbms_output.put_line('Erro ao atualizar crawcrd: ' || sqlerrm);
end;


