DECLARE 
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0130631';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0130631.sql';
  vr_exc_saida  EXCEPTION;
  vcount        NUMBER;

  CURSOR cr_crawseg(pr_cdcooper tbseg_prestamista.cdcooper%TYPE) IS
    SELECT w.nrdconta,
           w.nrctrseg,
           w.dtfimvig,
           p.dtfimvig as dtfim_prestamista
      FROM crawseg w,
           tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND p.nrctremp = w.nrctrato
       AND w.tpseguro = 4
       AND w.dtfimvig IS NULL
       AND p.tpregist IN (1,3);
       
  CURSOR cr_crapseg(pr_cdcooper tbseg_prestamista.cdcooper%TYPE) IS
    SELECT w.nrdconta,
           w.nrctrseg,
           w.dtfimvig,
           p.dtfimvig as dtfim_prestamista
      FROM crapseg w,
           tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND w.tpseguro = 4
       AND w.dtfimvig IS NULL
       AND p.tpregist IN (1,3);

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;

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

        FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP          
          vr_linha :=   'UPDATE crawseg '
                      ||'   SET dtfimvig = ''' || rw_crawseg.dtfimvig || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_crawseg.nrdconta
                      ||'   AND nrctrseg = ' || rw_crawseg.nrctrseg ||' ; ';

          GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE crawseg
             SET crawseg.dtfimvig = TO_DATE(rw_crawseg.dtfim_prestamista,'DD/MM/RRRR')
           WHERE crawseg.cdcooper = rw_crapcop.cdcooper
             AND crawseg.nrdconta = rw_crawseg.nrdconta
             AND crawseg.nrctrseg = rw_crawseg.nrctrseg;
           
           IF vcount = 1000 THEN
             COMMIT;
           ELSE
             vcount := vcount + 1;
           END IF;          
        END LOOP;
        
        COMMIT;
        vcount := 0;
        
        FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP          
          vr_linha :=   'UPDATE crapseg '
                      ||'   SET dtfimvig = ''' || rw_crapseg.dtfimvig || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_crapseg.nrdconta
                      ||'   AND nrctrseg = ' || rw_crapseg.nrctrseg ||' ; ';

          GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE crapseg
             SET crapseg.dtfimvig = TO_DATE(rw_crapseg.dtfim_prestamista,'DD/MM/RRRR')
           WHERE crapseg.cdcooper = rw_crapcop.cdcooper
             AND crapseg.nrdconta = rw_crapseg.nrdconta
             AND crapseg.nrctrseg = rw_crapseg.nrctrseg;
           
           IF vcount = 1000 THEN
             COMMIT;
           ELSE
             vcount := vcount + 1;
           END IF;          
        END LOOP;
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
