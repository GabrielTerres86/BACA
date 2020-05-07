/*
PRB0043070 - Retirar garantia de propostas que estão com ID inconsistente.
07/05/2020 - Paulo Martins
*/
declare

  cursor c1 is
  select e.cdcooper,e.nrdconta,e.nrctremp
    from crawepr e,
         tbgar_cobertura_operacao c
   where e.idcobope = c.idcobertura   
     and e.nrctremp <> c.nrcontrato     
     and e.idcobope in (24114,24688,15011,801,21619,25187,26205,8723,23831,7870,
                        6003,992,19803,18957,25455,19365,16092,7266,7360,22364,
                        23735,18198,21726,22041) order by e.idcobope; 
                      
begin
  for r1 in c1 loop
    update crawepr p
       set p.idcobope = 0,
           p.idcobefe = 0
     where p.cdcooper = r1.cdcooper
       and p.nrdconta = r1.nrdconta
       and p.nrctremp = r1.nrctremp;
  end loop;
  Commit;
exception
  when others then
    dbms_output.put_line('Erro Script PRB0043070 '||sqlerrm);
    rollback;
end;
/
