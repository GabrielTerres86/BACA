DECLARE 
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0103760';  
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0103760.sql';   
  vr_exc_saida  EXCEPTION; 
   
  CURSOR cr_crapseg IS
   SELECT cp.cdcooper
         ,cp.nrdconta
         ,cp.nrctrseg
         ,cp.tpseguro
         ,cp.dtfimvig
         ,cp.dtcancel
         ,cp.cdsitseg
         ,cp.cdopeexc
         ,cp.cdageexc
         ,cp.dtinsexc
         ,cp.cdopecnl
         ,p.nrctremp
         ,p.situacao
         ,p.dtrecusa
         ,p.tprecusa
         ,p.cdmotrec
         ,p.tpregist
         ,p.dtfimvig dtfimvig_prest
    FROM tbseg_prestamista p,
         crawseg c,
         crapseg cp
   WHERE p.cdcooper = 1
     AND p.nrcpfcgc IN ('80431410968','63461544949')
     AND p.cdcooper = c.cdcooper
     AND p.nrdconta = c.nrdconta
     AND p.nrctrseg = c.nrctrseg
     AND c.nrctrato = p.nrctremp
     AND p.cdcooper = cp.cdcooper
     AND p.nrdconta = cp.nrdconta
     AND p.nrctrseg = cp.nrctrseg
     AND cp.tpseguro = 4
     AND cp.cdsitseg = 5;
  rw_crapseg cr_crapseg%ROWTYPE;
  
  BEGIN
    BEGIN
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir 
                              ,pr_nmarquiv => vr_nmarq                
                              ,pr_tipabert => 'W'                    
                              ,pr_utlfileh => vr_ind_arq             
                              ,pr_des_erro => vr_dscritic);          
      IF vr_dscritic IS NOT NULL THEN         
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;     
         RAISE vr_exc_saida;
      END IF;
      
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
                            
      FOR rw_crapseg IN cr_crapseg LOOP 
        vr_linha := '';
        
        vr_linha :=   'UPDATE crapseg '
                    ||'   SET dtfimvig = to_date('''||rw_crapseg.dtfimvig||''',''DD/MM/YYYY'' ) , '
                    ||'       dtcancel = to_date('''||rw_crapseg.dtcancel||''',''DD/MM/YYYY'' ) , ' 
                    ||'       cdsitseg = '||nvl(trim(TO_CHAR( rw_crapseg.cdsitseg)),'NULL')  ||', '
                    ||'       cdopeexc = '||nvl(trim(TO_CHAR( rw_crapseg.cdopeexc)),''' ''')  ||', '
                    ||'       cdageexc = '||nvl(trim(TO_CHAR( rw_crapseg.cdageexc)),''' ''')  ||', '
                    ||'       dtinsexc = to_date('''||rw_crapseg.dtinsexc||''',''DD/MM/YYYY'' ) , ' 
                    ||'       cdopecnl = '||nvl(trim(TO_CHAR(  rw_crapseg.cdopecnl)),'NULL') 
                    ||' WHERE nrctrseg = '||rw_crapseg.nrctrseg  
                    ||'   AND nrdconta = '||rw_crapseg.nrdconta  
                    ||'   AND cdcooper = '||rw_crapseg.cdcooper  
                    ||'   AND tpseguro = '||rw_crapseg.tpseguro||' ; ';
        GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                    
        vr_linha :='';
        
        vr_linha :=  ' UPDATE tbseg_prestamista SET situacao = '|| nvl(TO_CHAR(rw_crapseg.situacao),'NULL')
                   ||', dtrecusa = to_date('''|| rw_crapseg.dtrecusa ||''',''DD/MM/YYYY'' ) '
                   ||', tprecusa = '||nvl(trim(TO_CHAR(rw_crapseg.tprecusa)),'NULL')
                   ||', cdmotrec = '||nvl(trim(TO_CHAR(rw_crapseg.cdmotrec)),'NULL')
                   ||', tpregist = '||nvl(trim(TO_CHAR(rw_crapseg.tpregist)),'NULL')
                   ||' WHERE nrctrseg = '||rw_crapseg.nrctrseg  
                   ||'   AND nrdconta = '||rw_crapseg.nrdconta  
                   ||'   AND cdcooper = '||rw_crapseg.cdcooper  
                   ||'   AND nrctremp = '||rw_crapseg.nrctremp||' ; ';
        GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
        
        UPDATE TBSEG_PRESTAMISTA 
           SET situacao = 1 -- ATIVO
              ,dtrecusa= NULL
              ,tprecusa= NULL
              ,cdmotrec= NULL
              ,tpregist= 3 -- ENDOSSO    
        WHERE nrctrseg = rw_crapseg.nrctrseg
          AND nrdconta = rw_crapseg.nrdconta
          AND cdcooper = rw_crapseg.cdcooper
          AND nrctremp = rw_crapseg.nrctremp;
          
        UPDATE crapseg
           SET crapseg.dtfimvig = TO_DATE(rw_crapseg.dtfimvig_prest,'DD/MM/RRRR')
              ,crapseg.dtcancel = NULL
              ,crapseg.cdsitseg = 1 -- ATIVO
              ,crapseg.cdopeexc = ' '
              ,crapseg.cdageexc = 0
              ,crapseg.dtinsexc = NULL
              ,crapseg.cdopecnl = '9999'
         WHERE crapseg.nrctrseg = rw_crapseg.nrctrseg  
           AND crapseg.nrdconta = rw_crapseg.nrdconta   
           AND crapseg.cdcooper = rw_crapseg.cdcooper   
           AND crapseg.tpseguro = 4;   
        COMMIT;
      END LOOP;
      
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' EXCEPTION ');                    
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'  WHEN OTHERS THEN ');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'   ROLLBACK;');                    
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');                 
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');                                     
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
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
/
