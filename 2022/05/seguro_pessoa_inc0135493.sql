DECLARE
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0135493';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0135493.sql';
  vr_exc_saida  EXCEPTION;
  vcount        NUMBER;

  CURSOR cr_crawseg(pr_cdcooper crawseg.cdcooper%TYPE,
                    pr_nrdconta crawseg.nrdconta%TYPE,
                    pr_nrctrseg crawseg.nrctrseg%TYPE) IS
    SELECT w.dtinivig,
           w.dtfimvig
      FROM crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctrseg = pr_nrctrseg;
       
  CURSOR cr_crapseg(pr_cdcooper crapseg.cdcooper%TYPE,
                    pr_nrdconta crapseg.nrdconta%TYPE,
                    pr_nrctrseg crapseg.nrctrseg%TYPE) IS
    SELECT p.dtinivig,
           p.dtfimvig
      FROM crapseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.tpseguro = 4
       AND p.nrctrseg = pr_nrctrseg;

  CURSOR cr_prestamista(pr_cdcooper tbseg_prestamista.cdcooper%TYPE,
                        pr_dtmvtolt tbseg_prestamista.dtfimvig%TYPE) IS
    SELECT p.nrdconta,
           p.nrctrseg,
           p.nrctremp,
           p.dtinivig,
           p.dtfimvig,
           e.dtmvtolt,
           (SELECT MAX(pe.dtvencto) 
              FROM crappep pe
             WHERE p.cdcooper = pe.cdcooper
               AND p.nrdconta = pe.nrdconta
               AND p.nrctremp = pe.nrctremp) dtvencto
      FROM crapseg s,
           crawepr e,
           tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND s.cdsitseg = 1
       AND p.tpregist IN (1,3)
       AND p.dtfimvig < pr_dtmvtolt
       AND e.flgreneg = 1;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM crapcop c,
           crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

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

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';
        
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_dtmvtolt => rw_crapcop.dtmvtolt) LOOP
                                            
          vr_linha :=   'UPDATE tbseg_prestamista '
                      ||'   SET dtinivig = ''' || rw_prestamista.dtinivig || ','''
                      ||'       dtfimvig = ''' || rw_prestamista.dtfimvig || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                      ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

          GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE tbseg_prestamista p
             SET p.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
                ,p.dtfimvig = TO_DATE(rw_prestamista.dtvencto,'DD/MM/RRRR')
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_prestamista.nrdconta
             AND p.nrctrseg = rw_prestamista.nrctrseg;
             
          FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_nrdconta => rw_prestamista.nrdconta
                                      ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP
                                      
            vr_linha :=   'UPDATE crawseg '
                        ||'   SET dtinivig = ''' || rw_crawseg.dtinivig || ','''
                        ||'       dtfimvig = ''' || rw_crawseg.dtfimvig || ''''
                        ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                        ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                        ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

            GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            UPDATE crawseg w
               SET w.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
                  ,w.dtfimvig = TO_DATE(rw_prestamista.dtvencto,'DD/MM/RRRR')
             WHERE w.cdcooper = rw_crapcop.cdcooper
               AND w.nrdconta = rw_prestamista.nrdconta
               AND w.nrctrseg = rw_prestamista.nrctrseg;             
          END LOOP;
          
          FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_nrdconta => rw_prestamista.nrdconta
                                      ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP
                                      
          vr_linha :=   'UPDATE crapseg '
                      ||'   SET dtinivig = ''' || rw_crapseg.dtinivig || ','''
                      ||'       dtfimvig = ''' || rw_crapseg.dtfimvig || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_prestamista.nrdconta
                      ||'   AND nrctrseg = ' || rw_prestamista.nrctrseg ||' ; ';

          GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE crapseg p
             SET p.dtinivig = TO_DATE(rw_prestamista.dtmvtolt,'DD/MM/RRRR')
                ,p.dtfimvig = TO_DATE(rw_prestamista.dtvencto,'DD/MM/RRRR')
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_prestamista.nrdconta
             AND p.nrctrseg = rw_prestamista.nrctrseg;
          END LOOP;
          
          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;
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
