DECLARE 
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0135694';  
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0135694.sql';   
  vr_exc_saida  EXCEPTION; 
   
  CURSOR cr_prestamista IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.nrctrseg,
           p.nrctremp,
           p.tpregist,
           p.nrproposta,
           p.dtdevend,
           p.dtinivig,
           p.dtrefcob,
           p.dtdenvio,
           e.dtmvtolt
      FROM crapepr e,
           tbseg_prestamista p
     WHERE p.cdcooper IN (1,2,5,6,7,11,13,16)
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.nrproposta IN ('770613024352',
                            '770613024336',
                            '770613024344',
                            '770613024425',
                            '770613024379',
                            '770613024395',
                            '770613024387',
                            '770613024417',
                            '770613024409',
                            '770613024360',
                            '770613024220',
                            '770613024042',
                            '770613024026',
                            '770613024255',
                            '770613023623',
                            '770613023682',
                            '770613023658',
                            '770613023631',
                            '770613023607',
                            '770613023712',
                            '770613023615',
                            '770613024247',
                            '770613023984',
                            '770613023739',
                            '770613023879',
                            '770613023755',
                            '770613023674',
                            '770613023933',
                            '770613023909',
                            '770613024166',
                            '770613023810',
                            '770613023747',
                            '770613023925',
                            '770613024212',
                            '770613023968',
                            '770613024107',
                            '770613024182',
                            '770613023895',
                            '770613024204',
                            '770613024301',
                            '770613023780',
                            '770613023640',
                            '770613024000',
                            '770613024123',
                            '770613024077',
                            '770613023801',
                            '770613024468',
                            '770613024450',
                            '770613024433');
  rw_prestamista cr_prestamista%ROWTYPE;
  
  CURSOR cr_crapseg(pr_cdcooper IN crapseg.cdcooper%TYPE,
                    pr_nrdconta IN crapseg.nrdconta%TYPE,
                    pr_nrctrseg IN crapseg.nrctrseg%TYPE) IS
    SELECT s.dtinivig,
           s.dtmvtolt,
           s.dtdebito,
           s.dtiniseg,
           s.dtultpag,
           s.dtprideb,
           s.dtinsori
      FROM crapseg s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrctrseg = pr_nrctrseg
       AND s.tpseguro = 4;
  rw_crapseg cr_crapseg%ROWTYPE;
       
  CURSOR cr_crawseg(pr_cdcooper IN crapseg.cdcooper%TYPE,
                    pr_nrdconta IN crapseg.nrdconta%TYPE,
                    pr_nrctrseg IN crapseg.nrctrseg%TYPE) IS
    SELECT w.dtmvtolt,
           w.dtinivig,
           w.dtdebito,
           w.dtiniseg,
           w.dtprideb
      FROM crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctrseg = pr_nrctrseg;
  rw_crawseg cr_crawseg%ROWTYPE;
  
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
                            
      FOR rw_prestamista IN cr_prestamista LOOP 
        vr_linha := '';
        
        OPEN cr_crapseg(pr_cdcooper => rw_prestamista.cdcooper,
                        pr_nrdconta => rw_prestamista.nrdconta,
                        pr_nrctrseg => rw_prestamista.nrctrseg);
          FETCH cr_crapseg INTO rw_crapseg;
            IF cr_crapseg%FOUND THEN
              vr_linha :=   'UPDATE crapseg '
                          ||'   SET dtinivig = TO_DATE('''||rw_crapseg.dtinivig||''',''DD/MM/YYYY'' ) , '
                          ||'       dtmvtolt = TO_DATE('''||rw_crapseg.dtmvtolt||''',''DD/MM/YYYY'' ) , '
                          ||'       dtdebito = TO_DATE('''||rw_crapseg.dtdebito||''',''DD/MM/YYYY'' ) , '
                          ||'       dtiniseg = TO_DATE('''||rw_crapseg.dtiniseg||''',''DD/MM/YYYY'' ) , '
                          ||'       dtultpag = TO_DATE('''||rw_crapseg.dtultpag||''',''DD/MM/YYYY'' ) , '
                          ||'       dtprideb = TO_DATE('''||rw_crapseg.dtprideb||''',''DD/MM/YYYY'' ) , '
                          ||'       dtinsori = TO_DATE('''||rw_crapseg.dtinsori||''',''DD/MM/YYYY'' )   '
                          ||' WHERE cdcooper = '||rw_prestamista.cdcooper
                          ||'   AND nrdconta = '||rw_prestamista.nrdconta
                          ||'   AND nrctrseg = '||rw_prestamista.nrctrseg
                          ||'   AND tpseguro = 4; ';
                          
              GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            END IF;
        CLOSE cr_crapseg;
                    
        vr_linha :='';
        
        OPEN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper,
                        pr_nrdconta => rw_prestamista.nrdconta,
                        pr_nrctrseg => rw_prestamista.nrctrseg);
          FETCH cr_crawseg INTO rw_crawseg;
            IF cr_crawseg%FOUND THEN
              vr_linha :=   'UPDATE crawseg '
                          ||'   SET dtmvtolt = TO_DATE('''||rw_crawseg.dtmvtolt||''',''DD/MM/YYYY'' ) , '              
                          ||'       dtinivig = TO_DATE('''||rw_crawseg.dtinivig||''',''DD/MM/YYYY'' ) , ' 
                          ||'       dtdebito = TO_DATE('''||rw_crawseg.dtdebito||''',''DD/MM/YYYY'' ) , ' 
                          ||'       dtiniseg = TO_DATE('''||rw_crawseg.dtiniseg||''',''DD/MM/YYYY'' ) , ' 
                          ||'       dtprideb = TO_DATE('''||rw_crawseg.dtprideb||''',''DD/MM/YYYY'' )   '
                          ||' WHERE cdcooper = '||rw_prestamista.cdcooper
                          ||'   AND nrdconta = '||rw_prestamista.nrdconta  
                          ||'   AND nrctrseg = '||rw_prestamista.nrctrseg ||' ; ';
                          
              GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            END IF;
        CLOSE cr_crawseg;
        
        vr_linha :=   'UPDATE tbseg_prestamista '
                    ||'   SET dtdevend = TO_DATE('''||rw_prestamista.dtdevend||''',''DD/MM/YYYY'' ) , '
                    ||'       dtinivig = TO_DATE('''||rw_prestamista.dtinivig||''',''DD/MM/YYYY'' ) , '
                    ||'       dtrefcob = TO_DATE('''||rw_prestamista.dtrefcob||''',''DD/MM/YYYY'' ) , '
                    ||'       dtdenvio = TO_DATE('''||rw_prestamista.dtdenvio||''',''DD/MM/YYYY'' ) , '
                    ||'       tpregist = ' || rw_prestamista.tpregist
                    ||' WHERE cdcooper = '||rw_prestamista.cdcooper
                    ||'   AND nrdconta = '||rw_prestamista.nrdconta
                    ||'   AND nrctrseg = '||rw_prestamista.nrctrseg ||' ; ';
                          
        GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
        
        UPDATE crapseg
           SET crapseg.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtmvtolt = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtdebito = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtiniseg = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtultpag = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtprideb = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crapseg.dtinsori = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR HH24:MI:SS')
         WHERE crapseg.cdcooper = rw_prestamista.cdcooper
           AND crapseg.nrdconta = rw_prestamista.nrdconta
           AND crapseg.nrctrseg = rw_prestamista.nrctrseg
           AND crapseg.tpseguro = 4;
        
        UPDATE crawseg
           SET crawseg.dtmvtolt = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crawseg.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crawseg.dtdebito = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crawseg.dtiniseg = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,crawseg.dtprideb = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
         WHERE crawseg.cdcooper = rw_prestamista.cdcooper
           AND crawseg.nrdconta = rw_prestamista.nrdconta
           AND crawseg.nrctrseg = rw_prestamista.nrctrseg;
        
        UPDATE tbseg_prestamista 
           SET tbseg_prestamista.dtdevend = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,tbseg_prestamista.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,tbseg_prestamista.dtrefcob = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,tbseg_prestamista.dtdenvio = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
              ,tbseg_prestamista.tpregist = 1
        WHERE tbseg_prestamista.cdcooper = rw_prestamista.cdcooper
          AND tbseg_prestamista.nrdconta = rw_prestamista.nrdconta
          AND tbseg_prestamista.nrctrseg = rw_prestamista.nrctrseg;
          
        COMMIT;
      END LOOP;
      
      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
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
