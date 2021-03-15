PL/SQL Developer Test script 3.0
57
-- Created on 10/02/2021 by F0032948 
declare
  -- Local variables here

  CURSOR cr_craplem is
    select l.*
      from craplem l
     inner join crapepr c
        on c.cdcooper = l.cdcooper
       and c.nrdconta = l.nrdconta
       and c.nrctremp = l.nrctremp
       and c.tpdescto = 2
       and c.tpemprst = 1
       and c.cdempres = 9999
       and c.inliquid = 0
     where l.dtmvtolt = '10/02/2021'
     order by cdhistor;

  rw_craplem cr_craplem%ROWTYPE;
begin

 
  FOR rw_craplem IN cr_craplem LOOP
   
   delete from craplcm x
     where x.cdcooper = rw_craplem.cdcooper
       and x.nrdconta = rw_craplem.nrdconta
       and trim(replace(x.cdpesqbb, '.', '')) = rw_craplem.nrctremp
       and x.vllanmto = rw_craplem.vllanmto
       and x.dtmvtolt = '10/02/2021'
       and x.cdhistor = 108;
  
    update crappep x
       set x.inliquid = 0
     where x.cdcooper = rw_craplem.cdcooper
       and x.nrdconta = rw_craplem.nrdconta
       and x.nrctremp = rw_craplem.nrctremp
       and x.nrparepr = rw_craplem.nrparepr;
  
    delete from craplem l
     where rw_craplem.cdcooper = l.cdcooper
       and rw_craplem.nrdconta = l.nrdconta
       and rw_craplem.nrctremp = l.nrctremp
       and rw_craplem.progress_recid = l.progress_recid
       and l.cdhistor in (1037, 1044)
       and l.dtmvtolt = '10/02/2021';
  
  END LOOP;

  commit;

exception
  when others then
    :vr_dscritic := 'ERRO ' || sqlerrm;
    rollback;
  
end;
1
vr_dscritic
0
5
0
