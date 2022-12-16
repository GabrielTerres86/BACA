DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/PRB0047683';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_PRB0047683.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.nrproposta
          ,p.tpregist
          ,p.idseqtra
          ,s.cdsitseg
          ,s.dtcancel
          ,s.cdmotcan
          ,s.progress_recid
          ,w.nrproposta nrproposta_crawseg
      FROM CECRED.crawseg w,
           CECRED.crapseg s,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND p.tpcustei = 0
       AND (LENGTH(p.nrproposta) = 1 
        OR w.nrproposta IN ('770629374299',
                            '770629231455',
                            '770629312315',
                            '770628998434',
                            '770629003355',
                            '770629001263',
                            '770629436952',
                            '770629438068',
                            '770628999678',
                            '770629000020',
                            '770629001301',
                            '770629676147',
                            '770629001832',
                            '770629447164',
                            '770629001972',
                            '770629439480',
                            '770629000070',
                            '770629449698',
                            '770629371990',
                            '770629269762',
                            '770628806330',
                            '770628945322',
                            '770629001638',
                            '770629681167',
                            '770628949344',
                            '770628806497',
                            '770628804753',
                            '770629229469',
                            '770628750467',
                            '770628811458',
                            '770629082190',
                            '770629153039',
                            '770629267395',
                            '770628746532',
                            '770657756989',
                            '770629312110',
                            '770629146717',
                            '770629666699',
                            '770629537465',
                            '770629225692')
       );

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
          
         IF LENGTH(rw_principal.nrproposta) = 1 THEN
           vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.nrproposta = ''' || rw_principal.nrproposta || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          UPDATE CECRED.tbseg_prestamista p
               SET p.nrproposta = rw_principal.nrproposta_crawseg
             WHERE p.idseqtra = rw_principal.idseqtra;
           
         END IF;
         
         IF rw_principal.nrproposta_crawseg IN ('770657205346',
                                                '770657205320',
                                                '770628806152',
                                                '770657205354',
                                                '770629231455',
                                                '770629312315',
                                                '770629003355',
                                                '770628999678',
                                                '770629000070',
                                                '770629449698',
                                                '770629371990',
                                                '770628945322',
                                                '770629001638',
                                                '770629681167',
                                                '770628806497',
                                                '770628804753',
                                                '770629229469',
                                                '770628750467',
                                                '770628811458',
                                                '770629082190',
                                                '770629153039',
                                                '770629267395',
                                                '770628746532',
                                                '770657756989',
                                                '770629312110',
                                                '770629146717',
                                                '770629537465' ) THEN
           IF rw_principal.tpregist <> 3 THEN
             vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_principal.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
             
             UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 3
             WHERE p.idseqtra = rw_principal.idseqtra;
           END IF;
           
           IF rw_principal.cdsitseg <> 1 OR rw_principal.dtcancel IS NOT NULL OR rw_principal.cdmotcan = 19 THEN
             vr_linha :=    ' UPDATE CECRED.crapseg p   '
                         || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                         || '       ,p.cdmotcan = ''' || rw_principal.cdmotcan || ''''
                         || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                         || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);    
             
             UPDATE CECRED.crapseg p
               SET p.cdsitseg = 1
                  ,p.cdmotcan = NULL
                  ,p.dtcancel = NULL
             WHERE p.progress_recid = rw_principal.progress_recid;         
           END IF;
         ELSIF rw_principal.nrproposta_crawseg IN ('770655956794' ) THEN
           IF rw_principal.tpregist <> 2 THEN
             vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_principal.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
             
             UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 2
             WHERE p.idseqtra = rw_principal.idseqtra;
           END IF;
           
           IF rw_principal.cdsitseg = 1 OR rw_principal.dtcancel IS NULL THEN
             vr_linha :=    ' UPDATE CECRED.crapseg p   '
                         || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                         || '       ,p.cdmotcan = ''' || rw_principal.cdmotcan || ''''
                         || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                         || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);    
             
             UPDATE CECRED.crapseg p
               SET p.cdsitseg = 2
                  ,p.cdmotcan = NVL(p.cdmotcan,4)
                  ,p.dtcancel = NVL(p.dtcancel,TRUNC(SYSDATE))
             WHERE p.progress_recid = rw_principal.progress_recid;         
           END IF;
         END IF;

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