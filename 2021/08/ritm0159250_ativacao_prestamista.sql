DECLARE 
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/RITM0159250';  
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_RITM0159250.sql';   
  vr_exc_saida  EXCEPTION; 
   
  CURSOR cr_tbseg_prst IS 
    SELECT nrproposta,
           cdcooper,
           nrctrseg,
           nrdconta,
           dtrecusa,
           situacao,
           tprecusa,
           cdmotrec,
           tpregist,
           dtfimvig
      FROM tbseg_prestamista a
     WHERE nrproposta IN (770352308439,770352474592,770352362565,770352225010,770352260053,770352148512,770352513393,770352390852,770351925922,770351319070,770351674822
                         ,770351027045,770351690070,770351520442,770351656255,770350899456,770351893532,770352002399,770351027002,770351405112,770352127906,770352007668
                         ,770352007706,770351043601,770353082108,770352263877,770351826002,770351758961,770352481890,770352574406)
     ORDER BY 1;
  rw_tbseg cr_tbseg_prst%ROWTYPE ;

  CURSOR cr_crapseg(pr_cdcooper crapseg.cdcooper%TYPE,   
                    pr_nrdconta crapseg.nrdconta%TYPE,
                    pr_nrctrseg crapseg.nrctrseg%TYPE) IS
    SELECT cdcooper
          ,nrdconta
          ,nrctrseg
          ,tpseguro
          ,dtfimvig
          ,dtcancel
          ,cdsitseg
          ,cdopeexc
          ,cdageexc
          ,dtinsexc
          ,cdopecnl 
      FROM crapseg
     WHERE crapseg.nrctrseg = pr_nrctrseg  
       AND crapseg.nrdconta = pr_nrdconta  
       AND crapseg.cdcooper = pr_cdcooper  
       AND crapseg.tpseguro = 4; 
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
                            
      FOR rw_tbseg IN cr_tbseg_prst LOOP 
        vr_linha := '';
       
        OPEN cr_crapseg(rw_tbseg.cdcooper
                       ,rw_tbseg.nrdconta
                       ,rw_tbseg.nrctrseg);
          FETCH cr_crapseg INTO rw_crapseg;
          
        IF cr_crapseg%NOTFOUND THEN  
           CLOSE cr_crapseg;      
           CONTINUE; 
        ELSE 
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
        END IF;
        
        vr_linha :='';
        
        CLOSE cr_crapseg;
        
        vr_linha :=  ' UPDATE tbseg_prestamista SET situacao = '|| nvl(TO_CHAR(rw_tbseg.situacao),'NULL')
                   ||', dtrecusa = to_date('''|| rw_tbseg.dtrecusa ||''',''DD/MM/YYYY'' ) '
                   ||', tprecusa = '||nvl(trim(TO_CHAR(rw_tbseg.tprecusa)),'NULL')
                   ||', cdmotrec = '||nvl(trim(TO_CHAR(rw_tbseg.cdmotrec)),'NULL')
                   ||', tpregist = '||nvl(trim(TO_CHAR(rw_tbseg.tpregist)),'NULL')
                   ||' WHERE nrproposta = '||rw_tbseg.nrproposta||'; ';
        GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);                    
        
        
        UPDATE TBSEG_PRESTAMISTA 
           SET situacao = 1 -- ATIVO
              ,dtrecusa= NULL
              ,tprecusa= NULL
              ,cdmotrec= NULL
              ,tpregist= 3 -- ENDOSSO    
        WHERE nrproposta = rw_tbseg.nrproposta; 
          
        UPDATE crapseg
           SET crapseg.dtfimvig = TO_DATE(rw_tbseg.dtfimvig,'DD/MM/RRRR')
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
