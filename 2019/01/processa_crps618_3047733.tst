PL/SQL Developer Test script 3.0
42
-- Created on 18/01/2019 by F0030367 
declare 

  vr_cdcritic integer;
  vr_dscritic varchar2(5000);
begin
    
  -- Alterar data de emissão para registrar os boletos
  update crapcob b 
     set b.dtmvtolt = trunc(sysdate)
   where b.cdcooper = 1
     and b.nrdconta = 3047733
     and b.dtmvtolt = '17/12/2018'
     and b.nrcnvcob = 10131
     and b.nrdocmto between 46435 and 46446
     and b.incobran = 0;
     
  -- Alterar data de emissão para registrar os boletos
  update crapcob b 
     set b.dtmvtolt = trunc(sysdate)   
   where cdcooper = 1
     and nrdconta = 3047733
     and dtmvtolt = '17/12/2018'
     and nrcnvcob = 10131
     and nrdocmto between 46411 and 46422
     and b.incobran = 0;     

  dbms_output.put_line('Inicio da execução do CRPS618');
  -- Test statements here
  cecred.pc_crps618(pr_cdcooper => 1
                   ,pr_nrdconta => 3047733
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);
                   
  if nvl(vr_cdcritic,0) <> 0 or vr_dscritic is not null then
    dbms_output.put_line('Erro ao processar CRPS618. '||vr_dscritic);
  end if;
  
  dbms_output.put_line('Fim da execução do CRPS618');
  
  commit;
end;
0
0
