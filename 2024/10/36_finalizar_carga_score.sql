DECLARE
  vr_dscritic VARCHAR2(4000);
  
begin
  
  begin
    UPDATE cecred.tbcrd_score c
       SET c.tppessoa = nvl((SELECT MAX(ass.inpessoa) FROM crapass ass WHERE ass.nrcpfcnpj_base = c.nrcpfcnpjbase), c.tppessoa)
     WHERE c.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
       AND c.cdmodelo = 3
       AND c.nrcpfcnpjbase NOT IN (27396908,50760050,5405017,27845990,39477932);

    commit;
    
    update cecred.tbcrd_score_exclusao e
       SET e.tppessoa = nvl((SELECT MAX(ass.inpessoa) FROM crapass ass WHERE ass.nrcpfcnpj_base = e.nrcpfcnpjbase), e.tppessoa)
     WHERE e.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
       AND e.cdmodelo = 3
       AND e.nrcpfcnpjbase NOT IN (27396908,50760050,5405017,27845990,39477932);
    
    commit;
    
  exception
    when others then
      rollback;
      raise_application_error(-20000, sqlerrm);
  end;
  
  commit;
  
exception
  when others then
    rollback;
    raise_application_error(-20000, sqlerrm);
end;
