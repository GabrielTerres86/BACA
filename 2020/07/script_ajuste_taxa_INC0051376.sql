declare
  --
  cursor cr01 is
    select epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.txjuremp
          ,wpr.txdiaria
      from crapepr epr
          ,crawepr wpr
     where epr.cdcooper = wpr.cdcooper
       and epr.nrdconta = wpr.nrdconta
       and epr.nrctremp = wpr.nrctremp
       and epr.inliquid = 0
       and epr.txjuremp = 0
       and (epr.vlsdeved > 0
         or epr.vlsdprej > 0);
  --
  rw01 cr01%rowtype;
  --
begin
  --
  open cr01;
  --
  loop
    --
    fetch cr01 into rw01;
    exit when cr01%notfound;
    --
    update crapepr epr
       set epr.txjuremp = rw01.txdiaria
     where epr.cdcooper = rw01.cdcooper
       and epr.nrdconta = rw01.nrdconta
       and epr.nrctremp = rw01.nrctremp;
    --
    commit;
    --
  end loop;
  --
  close cr01;
  --
exception
  when others then
    dbms_output.put_line('Erro: ' || sqlerrm);
end;
