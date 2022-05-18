DECLARE 
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := '/usr/cooptst/cecred/INC0130631';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0130631.sql';
  vr_exc_saida  EXCEPTION;
  vcount        NUMBER	:= 1;

  CURSOR cr_crawseg(pr_cdcooper cecred.tbseg_prestamista.cdcooper%TYPE) IS
    SELECT w.dtfimvig,
           p.dtfimvig as dtfim_prestamista,
           w.rowid as nr_linha_craw
      FROM cecred.crawseg w,
           cecred.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND p.nrctremp = w.nrctrato
       and p.dtfimvig is not null
       AND w.tpseguro = 4
       AND w.dtfimvig IS NULL
       AND p.tpregist IN (1,3);

  CURSOR cr_crapseg(pr_cdcooper cecred.tbseg_prestamista.cdcooper%TYPE) IS
    SELECT w.dtfimvig,
           p.dtfimvig as dtfim_prestamista,
           w.rowid as nr_linha_crap
      FROM cecred.crapseg w,
           cecred.crawseg a,
           cecred.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       and a.tpseguro = 4
       and p.nrctrseg = a.nrctrseg
       and p.nrctremp = a.nrctrato
       and p.nrdconta = a.nrdconta
       and p.cdcooper = a.cdcooper
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       and p.dtfimvig is not null
       and w.cdsitseg not in (2,5)
       AND w.tpseguro = 4
       AND w.dtfimvig IS NULL
       AND p.tpregist IN (1,3);

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN
    BEGIN
      cecred.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                              ,pr_nmarquiv => vr_nmarq
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arq
                              ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP

        vr_linha := '';

        FOR rw_crawseg IN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP          
          vr_linha :=   'UPDATE cecred.crawseg a '
                      ||'   SET a.dtfimvig = ''' || rw_crawseg.dtfimvig || ''''
                      ||' WHERE a.rowid = ' || chr(39) || rw_crawseg.nr_linha_craw || chr(39) ||' ; ';

          cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE cecred.crawseg a
             SET a.dtfimvig = rw_crawseg.dtfim_prestamista
           WHERE a.rowid = rw_crawseg.nr_linha_craw;
           
           IF vcount = 1000 THEN
             COMMIT;
             vcount := 1;
           ELSE
             vcount := vcount + 1;
           END IF;          
        END LOOP;
               
        FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP          
          vr_linha :=   'UPDATE cecred.crapseg a '
                      ||'   SET a.dtfimvig = ''' || rw_crapseg.dtfimvig || ''''
                      ||' WHERE a.rowid = ' || chr(39) || rw_crapseg.nr_linha_crap || chr(39) ||' ; ';

          cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE cecred.crapseg a
             SET a.dtfimvig = rw_crapseg.dtfim_prestamista
           WHERE a.rowid = rw_crapseg.nr_linha_crap;
           
           IF vcount = 1000 THEN
             COMMIT;
             vcount := 1;
           ELSE
             vcount := vcount + 1;
           END IF;          
        END LOOP;
      END LOOP;

      commit;

      cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      cecred.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
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