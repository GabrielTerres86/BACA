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
  
  
  vr_nmdireto    VARCHAR2(100);
  vr_nmarqbkp    VARCHAR2(50) := 'ROLLBACK_bens.sql';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_texto_completo  VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha   INTEGER := 0;  
  vr_crapalt_progress_recid  VARCHAR2(30);
  vr_ind_arquiv      utl_file.file_type;  
  
  vr_contador number;
  vr_dscritic varchar2(2000);
  vr_exception exception;
begin
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0204275/';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);

  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_contador := 0;
  open cr_crapavt;
  
  loop
    fetch cr_crapavt into rw_crapavt;
    exit when cr_crapavt%notfound;
    
    vr_contador := vr_contador +1;
    
    update cecred.crapavt
      set dsrelbem##1 = NVL(rw_crapavt.dsrelbem##1, ' ')
        , dsrelbem##2 = NVL(rw_crapavt.dsrelbem##2, ' ')
        , dsrelbem##3 = NVL(rw_crapavt.dsrelbem##3, ' ')
        , dsrelbem##4 = NVL(rw_crapavt.dsrelbem##4, ' ')
        , dsrelbem##5 = NVL(rw_crapavt.dsrelbem##5, ' ')
        , dsrelbem##6 = NVL(rw_crapavt.dsrelbem##6, ' ')
    where cdcooper = rw_crapavt.cdcooper
      and nrdconta = rw_crapavt.nrdconta
      and nrdctato = rw_crapavt.nrdctato
      and tpctrato = rw_crapavt.tpctrato
      and nrctremp = rw_crapavt.nrctremp
      and nrcpfcgc = rw_crapavt.nrcpfcgc;
        
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv
            , ' UPDATE CECRED.crapavt a ' ||
                 'SET a.dsrelbem##1 = ' || CASE WHEN rw_crapavt.dsrelbem##1 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##1 || ''' ' END ||
                  ' , a.dsrelbem##2 = ' || CASE WHEN rw_crapavt.dsrelbem##2 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##2 || ''' ' END ||
                  ' , a.dsrelbem##3 = ' || CASE WHEN rw_crapavt.dsrelbem##3 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##3 || ''' ' END ||
                  ' , a.dsrelbem##4 = ' || CASE WHEN rw_crapavt.dsrelbem##4 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##4 || ''' ' END ||
                  ' , a.dsrelbem##5 = ' || CASE WHEN rw_crapavt.dsrelbem##5 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##5 || ''' ' END ||
                  ' , a.dsrelbem##6 = ' || CASE WHEN rw_crapavt.dsrelbem##6 IS NULL THEN 'NULL' ELSE ' ''' || rw_crapavt.dsrelbem##6 || ''' ' END ||
              ' WHERE a.cdcooper = '      || rw_crapavt.cdcooper ||
                ' AND a.nrdconta = '      || rw_crapavt.nrdconta    ||
                ' AND a.nrdctato = '      || rw_crapavt.nrdctato ||
                ' AND a.tpctrato = '      || rw_crapavt.tpctrato ||
                ' AND a.nrctremp = '      || rw_crapavt.nrctremp ||
                ' AND a.nrcpfcgc = '      || rw_crapavt.nrcpfcgc || ' ;'
          );
    
    if SQL%ROWCOUNT <> 1 then
        
      vr_dscritic := 'Eror ao atualizar conta ' || rw_crapavt.nrdconta || '(' || rw_crapavt.cdcooper 
                     || ') - dsrelbem##1 [' || rw_crapavt.dsrelbem##1 || ']';
      raise vr_exception;
        
    end if;
    
  end loop;
  
  close cr_crapavt;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  commit;
  
exception
  when vr_exception then
    raise_application_error(-20000, 'Quantidade incorreta de regs. atualizados - ' || vr_dscritic);
    rollback;
  when others then
    raise_application_error(-20000, 'erro: ' || sqlerrm);
    rollback;
end;
