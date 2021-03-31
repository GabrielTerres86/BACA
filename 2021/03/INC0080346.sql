-- atualiza  saldo devedor para 0(vlsdeved), de contratos ja liquidados - CRAPLEM
declare

cursor cr_cntrs_jrem is
select epr.cdcooper
       ,epr.nrdconta
       ,epr.nrctremp
  from crapepr epr
 where epr.tpemprst = 1
   AND epr.inliquid = 1
   AND epr.inprejuz = 0
   AND epr.vlsdeved > 0;
   
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

