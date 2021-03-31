-- atualiza  saldo devedor para 0(vlsdeved), de contratos ja liquidados - CRAPLEM
declare

cursor cr_cntrs_jrem is
select distinct epr.*
  from craplem lem
      ,crapepr epr
      ,craphis his
      ,crapcop coop
 where lem.cdcooper = epr.cdcooper
   and lem.nrdconta = epr.nrdconta
   and lem.nrctremp = epr.nrctremp
   and lem.cdcooper = his.cdcooper
   and lem.cdhistor = his.cdhistor
   and lem.cdcooper = coop.cdcooper
   and epr.vlsdeved > 0
   and epr.inliquid = 1
   and epr.inprejuz = 0
   and lem.dtmvtolt > epr.dtliquid;
   
   cts_jrem cr_cntrs_jrem%rowtype;
   linhas number;  

begin
  
linhas := 0;
  
for cts_jrem in cr_cntrs_jrem loop

    update crapepr
    set vlsdeved = 0
    where cdcooper = cts_jrem.cdcooper
     and  nrdconta = cts_jrem.nrdconta
     and  nrctremp = cts_jrem.nrctremp;
     
linhas := linhas + sql%rowcount;
      

end loop;

dbms_output.put_line('Linhas atualizadas: ' || linhas);

commit;

exception
    when others then
      rollback;

end;

