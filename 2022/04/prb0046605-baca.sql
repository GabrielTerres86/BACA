declare
  vr_aux_ambiente INTEGER       := 3;                
  vr_aux_diretor  VARCHAR2(100) := 'PRB0046605';     
  vr_aux_arquivo  VARCHAR2(100) := 'rollback.txt'; 
  vr_nmarq_carga  VARCHAR2(200);
  vr_dscritic     VARCHAR2(2000);  
  vr_update        varchar(10000);  

  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE; 

  
  cursor cr_preaprovado (pr_cdcooper in tbepr_carga_pre_aprv.cdcooper%type) is
  select idcarga, cdcooper, dtcalculo, indsituacao_carga, flgcarga_bloqueada, tpcarga, dtfinal_vigencia
    from tbepr_carga_pre_aprv
   where indsituacao_carga = 2
     and flgcarga_bloqueada = 0
     and tpcarga = 1
     and dtfinal_vigencia <= trunc(sysdate)
     AND cdcooper = pr_cdcooper;
   rw_preaprovado cr_preaprovado%rowtype;  
   
begin
  IF vr_aux_ambiente = 1 THEN     
    vr_nmarq_carga    := '/progress/f0033450/micros/cpd/bacas/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo;   
  ELSIF vr_aux_ambiente = 2 THEN      
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo; 
  ELSIF vr_aux_ambiente = 3 THEN 
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo;  
  END IF;  
  
  GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_handle_log
                          ,pr_des_erro => vr_dscritic);    
                          
 for rw_crapcop in (select CDCOOPER from crapcop where flgativo = 1 order by cdcooper) LOOP
  
  FOR rw_preaprovado IN cr_preaprovado(pr_cdcooper => rw_crapcop.CDCOOPER) LOOP

      UPDATE tbepr_carga_pre_aprv 
         SET INDSITUACAO_CARGA = 4, FLGCARGA_BLOQUEADA = 1 
         WHERE INDSITUACAO_CARGA = 2
           AND FLGCARGA_BLOQUEADA = 0 
           AND TPCARGA = 1 
           AND DTFINAL_VIGENCIA <= TRUNC(SYSDATE)
           AND CDCOOPER = rw_preaprovado.CDCOOPER 
           AND idcarga = rw_preaprovado.idcarga;
    
    vr_update := 'UPDATE tbepr_carga_pre_aprv SET INDSITUACAO_CARGA = 2, FLGCARGA_BLOQUEADA = 0 '|| 
                                  'WHERE CDCOOPER = ' || rw_preaprovado.CDCOOPER || ' AND idcarga = ' || rw_preaprovado.idcarga || ' AND TPCARGA = 1;';
                                  
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => vr_update);
                                  
                                                                    
    commit;
    end loop;
  end loop; 
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
  EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;   
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log); 
 end;
