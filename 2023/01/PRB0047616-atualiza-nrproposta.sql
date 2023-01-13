BEGIN
  
DECLARE
  
   vr_nrproposta      CECRED.tbseg_prestamista.nrproposta%TYPE ;
   vr_seq             NUMBER;
   vr_str_seq         VARCHAR2(10);
   vr_exc_erro        EXCEPTION;
   vr_ativa           BOOLEAN := false;
   vr_idseqtra        CECRED.tbseg_prestamista.idseqtra%TYPE := 0;
   vr_progress_recid  CECRED.crawseg.progress_recid%TYPE := 0;
   vr_sitnull         BOOLEAN := false;
   
   vr_ind_arq        utl_file.file_type;
   vr_linha          VARCHAR2(32767);
   vr_dscritic       VARCHAR2(2000);
   vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/PRB0047616';
   vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_tbseg_prestamista.sql';
   vr_nmarq_crawseg  VARCHAR2(100)  := 'ROLLBACK_crawseg.sql';
   vr_exc_saida      EXCEPTION;
   
  CURSOR cr_tbseg_prestamista IS
    SELECT t.nrproposta, COUNT(*) qtde
      FROM CECRED.tbseg_prestamista t  
     WHERE t.nrproposta IS NOT NULL
     GROUP BY t.nrproposta
    HAVING COUNT(*)>1;

  CURSOR cr_crawseg IS
    SELECT w.nrproposta, COUNT(*) qtde
      FROM CECRED.crawseg w  
     WHERE w.nrproposta IS NOT NULL
     GROUP BY w.nrproposta
    HAVING COUNT(*)>1;
    
  CURSOR cr_duplicados_tbseg(pr_nrproposta tbseg_prestamista.nrproposta%TYPE) IS
    SELECT t.* 
      FROM CECRED.tbseg_prestamista t 
     WHERE t.nrproposta = pr_nrproposta
     ORDER BY t.idseqtra;       
  rw_duplicados_tbseg cr_duplicados_tbseg%ROWTYPE;
  
  CURSOR cr_duplicados_crawseg(pr_nrproposta crawseg.nrproposta%TYPE) IS
    SELECT w.*, s.cdsitseg 
      FROM CECRED.crawseg w,
           CECRED.crapseg s 
     WHERE w.nrproposta = pr_nrproposta
       AND w.cdcooper = s.cdcooper(+)
       AND w.nrdconta = s.nrdconta(+)
       AND w.nrctrseg = s.nrctrseg(+)
       AND w.tpseguro = s.tpseguro(+)
     ORDER BY w.dtinivig ASC, w.dtmvtolt ASC, w.progress_recid;       
  rw_duplicados_crawseg cr_duplicados_crawseg%ROWTYPE;

BEGIN
  
  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                 ,pr_nmarquiv => vr_nmarq
                                 ,pr_tipabert => 'W'
                                 ,pr_utlfileh => vr_ind_arq
                                 ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
     RAISE vr_exc_saida;
  END IF;

  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

  FOR rw_tbseg IN cr_tbseg_prestamista LOOP
    vr_nrproposta := 0;
    vr_seq := 0;
    vr_ativa := FALSE;
    vr_idseqtra := 0;
    
    FOR rw_duplicados_tbseg IN cr_duplicados_tbseg(pr_nrproposta => rw_tbseg.nrproposta) LOOP
      vr_linha := '';
      IF vr_nrproposta = 0 THEN 
        vr_nrproposta := rw_duplicados_tbseg.nrproposta;
        
        IF rw_duplicados_tbseg.tpregist IN (1,3) THEN 
          
          vr_ativa := TRUE;
          CONTINUE;
        ELSE    
          vr_idseqtra := rw_duplicados_tbseg.idseqtra;
          CONTINUE;
        END IF;          
      ELSIF vr_nrproposta = rw_duplicados_tbseg.nrproposta THEN 
       
        vr_seq := vr_seq + 1;
        vr_str_seq := lpad(vr_seq,2,0);
      
        IF vr_ativa = TRUE THEN 
          
          vr_linha := 'UPDATE CECRED.tbseg_prestamista SET nrproposta = ''' || rw_duplicados_tbseg.nrproposta || ''' WHERE idseqtra = ' || rw_duplicados_tbseg.idseqtra || ';';
                  
          UPDATE CECRED.tbseg_prestamista t 
             SET t.nrproposta = t.nrproposta || 'A' || vr_str_seq 
           WHERE t.idseqtra = rw_duplicados_tbseg.idseqtra;
        ELSE 
          IF rw_duplicados_tbseg.tpregist IN (1,3) THEN 
          
            vr_linha := 'UPDATE CECRED.tbseg_prestamista SET nrproposta = ''' || rw_duplicados_tbseg.nrproposta || ''' WHERE idseqtra = ' || vr_idseqtra || ';';
          
            UPDATE CECRED.tbseg_prestamista t 
               SET t.nrproposta = t.nrproposta || 'A' || vr_str_seq 
             WHERE t.idseqtra = vr_idseqtra;
            vr_ativa := TRUE;
          
          ELSE
            
            vr_linha := 'UPDATE CECRED.tbseg_prestamista SET nrproposta = ''' || rw_duplicados_tbseg.nrproposta || ''' WHERE idseqtra = ' || rw_duplicados_tbseg.idseqtra || ';';
          
            UPDATE CECRED.tbseg_prestamista t 
               SET t.nrproposta = t.nrproposta || 'A' || vr_str_seq 
             WHERE t.idseqtra = rw_duplicados_tbseg.idseqtra;
          
          END IF;
        END IF;
        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      END IF;        
    END LOOP; 
    COMMIT;   
  END LOOP;
  
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
  CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
  
  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                 ,pr_nmarquiv => vr_nmarq_crawseg
                                 ,pr_tipabert => 'W'
                                 ,pr_utlfileh => vr_ind_arq
                                 ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq_crawseg;
     RAISE vr_exc_saida;
  END IF;
  
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
  
  
  FOR rw_crawseg IN cr_crawseg LOOP
    vr_nrproposta := 0;
    vr_seq := 0;
    vr_ativa := FALSE;
    vr_progress_recid := 0;
    vr_sitnull := FALSE;
    
    FOR rw_duplicados_crawseg IN cr_duplicados_crawseg(pr_nrproposta => rw_crawseg.nrproposta) LOOP
      vr_linha := '';
      IF vr_nrproposta = 0 THEN
        vr_nrproposta := rw_duplicados_crawseg.nrproposta;
        
        IF rw_duplicados_crawseg.cdsitseg = 1 THEN
          vr_ativa := TRUE;
          CONTINUE;
        ELSE    
          IF rw_duplicados_crawseg.cdsitseg IS NULL THEN  
            vr_sitnull := TRUE;    
          END IF;
          vr_progress_recid := rw_duplicados_crawseg.progress_recid;
          CONTINUE;
        END IF;
      ELSIF vr_nrproposta = rw_duplicados_crawseg.nrproposta THEN
        vr_seq := vr_seq + 1;
        vr_str_seq := lpad(vr_seq,2,0);
        
        IF vr_ativa = TRUE THEN 
            
          vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || rw_duplicados_crawseg.progress_recid || ';';
        
          UPDATE CECRED.crawseg 
             SET nrproposta = nrproposta || 'A' || vr_str_seq 
           WHERE progress_recid = rw_duplicados_crawseg.progress_recid;
           
        ELSE 
          IF rw_duplicados_crawseg.cdsitseg = 1 THEN 
          
            vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || vr_progress_recid || ';';
          
            UPDATE CECRED.crawseg 
               SET nrproposta = nrproposta || 'A' || vr_str_seq 
             WHERE progress_recid = vr_progress_recid;
            vr_ativa := TRUE;
          
          ELSE
            
            IF vr_sitnull = TRUE THEN
              
              IF rw_duplicados_crawseg.cdsitseg IS NULL THEN
              
                vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || rw_duplicados_crawseg.progress_recid || ';';  
              
                UPDATE CECRED.crawseg 
                   SET nrproposta = nrproposta || 'A' || vr_str_seq 
                 WHERE progress_recid = rw_duplicados_crawseg.progress_recid;
              ELSE
                IF vr_seq > 1 THEN
                
                  vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || rw_duplicados_crawseg.progress_recid || ';';  
                
                  UPDATE CECRED.crawseg 
                     SET nrproposta = nrproposta || 'A' || vr_str_seq 
                   WHERE progress_recid = rw_duplicados_crawseg.progress_recid;
                ELSE
                
                  vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || vr_progress_recid || ';';  
                
                  UPDATE CECRED.crawseg 
                     SET nrproposta = nrproposta || 'A' || vr_str_seq 
                   WHERE progress_recid = vr_progress_recid;
                END IF;
              END IF;        
            ELSE  
            
              vr_linha := 'UPDATE CECRED.crawseg SET nrproposta = ''' || rw_duplicados_crawseg.nrproposta || ''' WHERE progress_recid = ' || rw_duplicados_crawseg.progress_recid || ';';   
                    
              UPDATE CECRED.crawseg 
               SET nrproposta = nrproposta || 'A' || vr_str_seq 
             WHERE progress_recid = rw_duplicados_crawseg.progress_recid;
            END IF;
          END IF;
        END IF; 
        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha); 
        COMMIT;
      END IF;        
    END LOOP;    
  END LOOP;
  
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
  CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
  
EXCEPTION
   WHEN vr_exc_saida THEN
        vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        dbms_output.put_line(vr_dscritic);
        ROLLBACK;
   WHEN OTHERS THEN
        vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        dbms_output.put_line(vr_dscritic);
        ROLLBACK;
END;
END;
