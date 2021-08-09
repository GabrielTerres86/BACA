declare 
  
cursor c_coop is
 SELECT cop.cdcooper
 FROM crapcop cop
 order by cop.cdcooper;
 
cursor c_lac(p_cooper number) is 
select sum(vllanmto) as vllanmto
      ,cdcooper
      ,nrdconta 
 from craplac lac 
 where cdhistor = 2749 
 and dtmvtolt between '01/01/2021' and '31/12/2021'
 and cdcooper = p_cooper
group by cdcooper, nrdconta;

begin
  
   for r_coop in c_coop loop
     for r_lac in c_lac(r_coop.cdcooper) loop
        begin
          update crapcot lac
            set vlrenrpp = vlrenrpp - r_lac.vllanmto
          where cdcooper = lac.cdcooper
            and nrdconta = lac.nrdconta
            and cdcooper = r_lac.cdcooper
            and nrdconta = r_lac.nrdconta;            
        end;
     end loop; 
   end loop;
  commit;
end;
/
