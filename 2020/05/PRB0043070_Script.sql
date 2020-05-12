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
     and e.idcobope in (801,992,21619,23831,26680)
   order by e.idcobope; 
                      
begin
  for r1 in c1 loop
    update crawepr p
       set p.idcobope = 0,
           p.idcobefe = 0
     where p.cdcooper = r1.cdcooper
       and p.nrdconta = r1.nrdconta
       and p.nrctremp = r1.nrctremp;
  end loop;
  -- 
  /*7870*/
  update tbgar_cobertura_operacao tb
     set tb.nrcontrato = 221887
   where tb.idcobertura = 7870 ;
  --
  update crawepr p
     set p.idcobope = 0,
         p.idcobefe = 0
   where p.cdcooper = 6
     and p.nrdconta = 30791
     and p.nrctremp = 221888;   
  /*21726*/ 
  update tbgar_cobertura_operacao tb
     set tb.nrcontrato = 31900
   where tb.idcobertura = 21726 ;
  -- 
  update crawepr p
     set p.idcobope = 0,
         p.idcobefe = 0
   where p.cdcooper = 7
     and p.nrdconta = 38768
     and p.nrctremp = 31803;   
  Commit;
exception
  when others then
    dbms_output.put_line('Erro Script PRB0043070 '||sqlerrm);
    rollback;
end;
