DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0221842';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0221842_1.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_crapseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE
                   ,pr_nrdconta CECRED.crapseg.nrdconta%TYPE
                   ,pr_nrctrseg CECRED.crapseg.nrctrseg%TYPE) IS
    SELECT p.*
      FROM CECRED.crapseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctrseg = pr_nrctrseg;

  CURSOR cr_prestamista(pr_cdcooper CECRED.tbseg_prestamista.cdcooper%TYPE) IS
    SELECT e.inliquid,
           e.dtliquid,
           s.cdsitseg,
           p.*
      FROM CECRED.crapseg s,
           CECRED.crapepr e,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = pr_cdcooper
       AND p.nrproposta IN ('770629375112',
                            '770628945675',
                            '770629217657',
                            '770629644571',
                            '770629370595',
                            '770629379797',
                            '770629680900',
                            '770629230742',
                            '770629225692',
                            '770629380299',
                            '770629455655',
                            '770629673270',
                            '770629439307',
                            '770629373667',
                            '770629436057',
                            '770629020306',
                            '770629218700'
                            )
       AND p.tpcustei = 0
    ORDER BY p.idseqtra;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper IN (11,13)
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  BEGIN
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

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => rw_crapcop.cdcooper) LOOP
                                              
            vr_linha := 'UPDATE CECRED.tbseg_prestamista p
                            SET p.tpregist = ' || rw_prestamista.tpregist || '
                          WHERE p.idseqtra = ' || rw_prestamista.idseqtra || ';';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 3
             WHERE p.idseqtra = rw_prestamista.idseqtra;

             FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_prestamista.cdcooper
                                        ,pr_nrdconta => rw_prestamista.nrdconta
                                        ,pr_nrctrseg => rw_prestamista.nrctrseg) LOOP

              IF rw_crapseg.cdmotcan IS NULL THEN
                 vr_linha := 'UPDATE CECRED.crapseg p
                                 SET p.cdsitseg = ' || rw_crapseg.cdsitseg || '
                                    ,p.dtcancel = TO_DATE(''' || rw_crapseg.dtcancel || ''',''DD/MM/RRRR'')
                                    ,p.dtfimvig = TO_DATE(''' || rw_crapseg.dtfimvig || ''',''DD/MM/RRRR'')
                               WHERE p.progress_recid = ' || rw_crapseg.progress_recid || ';';

              ELSE
                vr_linha := 'UPDATE CECRED.crapseg p
                                SET p.cdsitseg = ' || rw_crapseg.cdsitseg || '
                                   ,p.dtcancel = TO_DATE(''' || rw_crapseg.dtcancel || ''',''DD/MM/RRRR'')
                                   ,p.cdmotcan = ' || rw_crapseg.cdmotcan || '
                                   ,p.dtfimvig = TO_DATE(''' || rw_crapseg.dtfimvig || ''',''DD/MM/RRRR'')
                              WHERE p.progress_recid = ' || rw_crapseg.progress_recid || ';';
              END IF;

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

              UPDATE CECRED.crapseg p
                 SET p.cdsitseg = 1
                    ,p.dtcancel = NULL
                    ,p.cdmotcan = NULL
                    ,p.dtfimvig = rw_prestamista.dtfimvig
               WHERE p.progress_recid = rw_crapseg.progress_recid;
            END LOOP;

            IF vcount = 1000 THEN
              COMMIT;
            ELSE
              vcount := vcount + 1;
            END IF;
        END LOOP;        
      END LOOP;      
      COMMIT;
      
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
/
