DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0230396';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0230396_1.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_tpregist       NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.nrproposta
          ,p.tpregist
          ,p.idseqtra
          ,s.cdsitseg
          ,s.progress_recid
      FROM CECRED.crapseg s,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.nrproposta IN ('770655718460',
                            '770629373667',
                            '770628746532',
                            '770629003355',
                            '770629082190',
                            '770629644571',
                            '770628805520',
                            '770655956794',
                            '770629379797',
                            '770629537465',
                            '770629680900',
                            '770629000070',
                            '770629375112',
                            '770628945322',
                            '770629153039',
                            '770628750467',
                            '770629231455',
                            '770629449698',
                            '770629439307',
                            '770629217657',
                            '770628811458',
                            '770629146717',
                            '770629380299',
                            '770629673270',
                            '770629001638',
                            '770629681167',
                            '770629218700',
                            '770629312110',
                            '770629267395',
                            '770628804753',
                            '770629672788',
                            '770629370595',
                            '770628945675',
                            '770628999678',
                            '770629230742',
                            '770629312315',
                            '770629229469',
                            '770629436057',
                            '770629371990',
                            '770629455655',
                            '770628806497',
                            '770657756989',
                            '770657205320',
                            '770628806152',
                            '770657205346',
                            '770657205354');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

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

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_principal.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          IF rw_principal.nrproposta IN ('770657205320','770657205346') THEN
            vr_tpregist := 2;

            vr_linha :=    ' UPDATE CECRED.crapseg p   '
                        || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                        || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

            UPDATE CECRED.crapseg p
               SET p.cdsitseg = 2
             WHERE p.progress_recid = rw_principal.progress_recid;
          ELSE
            vr_tpregist := 3;
            
            IF rw_principal.cdsitseg <> 1 THEN
              vr_linha :=    ' UPDATE CECRED.crapseg p   '
                          || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                          || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

               CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

              UPDATE CECRED.crapseg p
                 SET p.cdsitseg = 1
               WHERE p.progress_recid = rw_principal.progress_recid;
            END IF;
          END IF;
          
          UPDATE CECRED.tbseg_prestamista p
             SET p.nrproposta = vr_tpregist
           WHERE p.idseqtra = rw_principal.idseqtra; 
          
          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;

        COMMIT;
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
/
