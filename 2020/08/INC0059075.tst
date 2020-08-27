PL/SQL Developer Test script 3.0
197
declare
  vr_cdcritic number;
  vr_dscritic varchar2(4000);  
  vr_exc_erro exception;
begin
  
  begin
    --1 Call the procedure
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                           pr_dtmvtolt => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_cdagenci => 90,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => 90,--Posto Atendimento/agendia
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600005,
                                           pr_nrdconta => 11252260,
                                           pr_cdhistor => 1036,--LIBER.DO CRED
                                           pr_nrctremp => 2868181,
                                           pr_vllanmto => 2500.00,
                                           pr_dtpagemp => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_txjurepr => 0.0594841,
                                           pr_vlpreemp => 180.25,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 0,
                                           pr_flgincre => true,
                                           pr_flgcredi => true,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 3,--INTERNET
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic); 
    --Se ocorreu erro
    if vr_cdcritic is not null or vr_dscritic is not null then
      rollback;                                    
      dbms_output.put_line(vr_dscritic);
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic); 
    end if;
    --                                                                                                                                                           
    commit;
    --
  exception       
    when others then      
      rollback; 
  end;
  
  begin
    --2 Call the procedure
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                           pr_dtmvtolt => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_cdagenci => 90,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => 90,--Posto Atendimento/agendia
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600005,
                                           pr_nrdconta => 7694210,
                                           pr_cdhistor => 1036,--LIBER.DO CRED
                                           pr_nrctremp => 2868190,
                                           pr_vllanmto => 3000.00,
                                           pr_dtpagemp => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_txjurepr => 0.0594841,
                                           pr_vlpreemp => 178.99,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 0,
                                           pr_flgincre => true,
                                           pr_flgcredi => true,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 3,--INTERNET
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);                                                                                                                   
    --Se ocorreu erro
    if vr_cdcritic is not null or vr_dscritic is not null then
      rollback;                                    
      dbms_output.put_line(vr_dscritic);
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic);
    end if;
    --                                                                                                                                                           
    commit;
    --
  exception       
    when others then      
      rollback;                                    
  end;
  
  begin    
    --3 Call the procedure
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                           pr_dtmvtolt => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_cdagenci => 90,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => 90,--Posto Atendimento/agendia
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600005,
                                           pr_nrdconta => 7828926,
                                           pr_cdhistor => 1036,--LIBER.DO CRED
                                           pr_nrctremp => 2868189,
                                           pr_vllanmto => 6500.00,
                                           pr_dtpagemp => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_txjurepr => 0.0643951,
                                           pr_vlpreemp => 208.55,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 0,
                                           pr_flgincre => true,
                                           pr_flgcredi => true,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 3,--INTERNET
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
    --Se ocorreu erro
    if vr_cdcritic is not null or vr_dscritic is not null then
      rollback;                                    
      dbms_output.put_line(vr_dscritic);
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic);
    end if;
    --                                                                                                                                                           
    commit;
    --
  exception       
    when vr_exc_erro then      
      rollback; 
  end;
  
  begin                                         
    --4 pagamento parcela
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                           pr_dtmvtolt => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_cdagenci => 90,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => 90,--Posto Atendimento/agendia
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600012,
                                           pr_nrdconta => 10109340,
                                           pr_cdhistor => 1044,--PAGAM.PARCELA
                                           pr_nrctremp => 2858139,
                                           pr_vllanmto => 265.92,
                                           pr_dtpagemp => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_txjurepr => 0.0594841,
                                           pr_vlpreemp => 279.04,
                                           pr_nrsequni => 3,
                                           pr_nrparepr => 3,
                                           pr_flgincre => true,
                                           pr_flgcredi => true,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 3,--INTERNET
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);    
    --Se ocorreu erro
    if vr_cdcritic is not null or vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
                                           
    --4 desconto parcela
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => 1,
                                           pr_dtmvtolt => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_cdagenci => 90,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => 90,--Posto Atendimento/agendia
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600016,
                                           pr_nrdconta => 10109340,
                                           pr_cdhistor => 1048,--DESC.ANT.EMP
                                           pr_nrctremp => 2858139,
                                           pr_vllanmto => 13.12,
                                           pr_dtpagemp => to_date('19/08/2020','dd/mm/yyyy'),
                                           pr_txjurepr => 0.0594841,
                                           pr_vlpreemp => 279.04,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 3,
                                           pr_flgincre => true,
                                           pr_flgcredi => true,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 3,--INTERNET
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);                                                                                         
                                                                                      
       --Se ocorreu erro
    if vr_cdcritic is not null or vr_dscritic is not null then
      raise vr_exc_erro;
    end if;
    --                                                                                                                                                           
    commit;
    --
  exception       
    when vr_exc_erro then      
      rollback;                                    
      dbms_output.put_line(vr_dscritic);
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic);
  end;
exception       
  when others then      
    rollback;                                    
    dbms_output.put_line(vr_dscritic);
    cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic);
end;
0
0
