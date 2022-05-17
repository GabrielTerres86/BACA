declare
  vr_aux_ambiente INTEGER       := 3;                
  vr_aux_diretor  VARCHAR2(100) := 'INC0133492';     
  vr_aux_arquivo  VARCHAR2(100) := 'rollback.txt'; 
  vr_nmarq_carga  VARCHAR2(200);
  vr_dscritic     VARCHAR2(2000);  
  vr_update       varchar(10000);  
  vr_contador     INTEGER       := 0;

  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE; 

  
  cursor cr_crappep (pr_cdcooper in crappep.cdcooper%type) is
  select pep.DTVENCTO, pep.cdcooper, pep.nrdconta, pep.NRCTREMP, pep.vlsdvpar , pep.INLIQUID, pep.NRPAREPR
    from cecred.crapepr epr, cecred.crappep pep
   where epr.cdcooper = pep.CDCOOPER
     and epr.nrdconta = pep.NRDCONTA
     and epr.NRCTREMP = pep.NRCTREMP
     and epr.TPDESCTO = 2
     and epr.TPEMPRST = 1
     and pep.INLIQUID = 1
     and pep.vlsdvpar > 0
     and pep.cdcooper = pr_cdcooper
     and pep.DTVENCTO >= to_date('01/01/2020','DD/MM/YYYY')
     and pep.DTVENCTO <= to_date('31/12/2021','DD/MM/YYYY');
   rw_crappep cr_crappep%rowtype;  

begin
  IF vr_aux_ambiente = 1 THEN     
    vr_nmarq_carga    := '/progress/f0033450/micros/cpd/bacas/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo;   
  ELSIF vr_aux_ambiente = 2 THEN      
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo; 
  ELSIF vr_aux_ambiente = 3 THEN 
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo;  
  END IF;  
  
  GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_handle_log
                          ,pr_des_erro => vr_dscritic);    
                          
 for rw_crapcop in (select CDCOOPER from crapcop where flgativo = 1 order by cdcooper) LOOP
  
  FOR rw_crappep IN cr_crappep(pr_cdcooper => rw_crapcop.CDCOOPER) LOOP
    vr_contador := vr_contador +1;  
    
      UPDATE CECRED.crappep 
         SET vlsdvpar = 0 
       where cdcooper = rw_crappep.cdcooper
         and nrdconta = rw_crappep.nrdconta
         and NRCTREMP = rw_crappep.NRCTREMP
         and NRPAREPR = rw_crappep.nrparepr;

    vr_update := 'UPDATE CECRED.crappep SET vlsdvpar = ' || trim(to_char(rw_crappep.vlsdvpar,'999999990.00')) ||
                                    ' WHERE cdcooper = ' || rw_crappep.CDCOOPER ||
                                      ' AND nrdconta = ' || rw_crappep.nrdconta || 
                                      ' AND NRCTREMP = ' || rw_crappep.nrctremp || 
                                      ' AND NRPAREPR = ' || rw_crappep.nrparepr || ';';
                                  
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => vr_update);
                                  
    if vr_contador >= 500 then
      commit;
      vr_contador := 0;
    end if;                                                                
    
    end loop;
  end loop; 
  commit;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;   
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log); 
 end;
