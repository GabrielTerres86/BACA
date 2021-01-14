PL/SQL Developer Test script 3.0
18
declare
begin
 update tbepr_cdc_emprestimo c 
    set flgrepasse = 1 
  where c.flgrepasse = 0 
        and exists (select 1 
                      from crapepr e 
                     where e.cdcooper = c.cdcooper 
                           and e.nrdconta = c.nrdconta 
                           and c.nrctremp = e.nrctremp 
                           and e.cdfinemp in (58,59) 
                           and dtmvtolt >= to_date('01/12/2020','DD/MM/YYYY')
                    );
 commit;
 exception when others then       
   rollback; 
   cecred.pc_internal_exception(pr_compleme => 'Erro Script ajuste 438.5 repasse cdc');  
end;
0
0
