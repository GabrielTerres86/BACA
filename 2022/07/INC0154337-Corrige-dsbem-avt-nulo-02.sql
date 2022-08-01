declare
  CURSOR cr_crapavt is
    select nrdconta
      , cdcooper
      , a.nrdctato
      , tpctrato
      , nrctremp
      , nrcpfcgc
      , a.dsrelbem##1
      , a.dsrelbem##2
      , a.dsrelbem##3 
      , a.dsrelbem##4 
      , a.dsrelbem##5 
      , a.dsrelbem##6
    from cecred.crapavt a
    where a.dsrelbem##1 is null 
      or a.dsrelbem##2 is null 
      or a.dsrelbem##3 is null 
      or a.dsrelbem##4 is null 
      or a.dsrelbem##5 is null 
      or a.dsrelbem##6 is null
    order by cdcooper, nrdconta;
  rw_crapavt cr_crapavt%ROWTYPE;
  
  vr_contador number;
  vr_dscritic varchar2(2000);
  vr_exception exception;
begin
  
  vr_contador := 0;
  open cr_crapavt;
  
  loop
    fetch cr_crapavt into rw_crapavt;
    exit when cr_crapavt%notfound;
    
    vr_contador := vr_contador +1;
    
    if rw_crapavt.dsrelbem##1 is null then
      
      update cecred.crapavt
        set dsrelbem##1 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##1 [' || rw_crapavt.dsrelbem##1 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
    if rw_crapavt.dsrelbem##2 is null then
      
      update cecred.crapavt
        set dsrelbem##2 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##2 [' || rw_crapavt.dsrelbem##2 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
    if rw_crapavt.dsrelbem##3 is null then
      
      update cecred.crapavt
        set dsrelbem##3 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##3 [' || rw_crapavt.dsrelbem##3 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
    if rw_crapavt.dsrelbem##4 is null then
      
      update cecred.crapavt
        set dsrelbem##4 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##4 [' || rw_crapavt.dsrelbem##4 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
    if rw_crapavt.dsrelbem##5 is null then
      
      update cecred.crapavt
        set dsrelbem##5 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##5 [' || rw_crapavt.dsrelbem##5 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
    if rw_crapavt.dsrelbem##6 is null then
      
      update cecred.crapavt
        set dsrelbem##6 = ' '
      where cdcooper = rw_crapavt.cdcooper
        and nrdconta = rw_crapavt.nrdconta
        and nrdctato = rw_crapavt.nrdctato
        and tpctrato = rw_crapavt.tpctrato
        and nrctremp = rw_crapavt.nrctremp
        and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
      if SQL%ROWCOUNT <> 1 then
        
        vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                       || ') - dsrelbem##6 [' || rw_crapavt.dsrelbem##6 || ']';
        raise vr_exception;
        
      end if;
        
    end if;
    
  end loop;
  
  close cr_crapavt;
  
  commit;
  
exception
  when vr_exception then
    raise_application_error(-20000, 'Quantidade incorreta de regs. atualizados - ' || vr_dscritic);
  when others then
    raise_application_error(-20000, 'erro: ' || sqlerrm);
end;
