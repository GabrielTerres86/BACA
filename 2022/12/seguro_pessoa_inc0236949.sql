DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0236949';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0236949.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_tpregist       NUMBER;
  vr_dtcancel       DATE;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.nrproposta
          ,p.nrdconta
          ,p.nrctrseg
          ,p.nrctremp
          ,p.tpregist
          ,p.dtinivig
          ,p.dtfimvig
          ,p.flcancelado_mobile
          ,p.idseqtra
          ,s.cdsitseg
          ,s.dtcancel
          ,s.cdmotcan
          ,s.dtfimvig dtfimvig_crapseg
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
       AND w.nrproposta IN ('770629152091',
                            '770629146768',
                            '770629271872',
                            '770628957070',
                            '770629024433',
                            '770629539352',
                            '770629447911',
                            '770629344462',
                            '770629084401',
                            '770629542124',
                            '770628956405',
                            '770629537600',
                            '770629147764',
                            '770629343954',
                            '770628958262',
                            '770629148981',
                            '770629471138',
                            '770629151842',
                            '770629340734',
                            '770629540350',
                            '770629540296',
                            '770629469311',
                            '770629341790',
                            '770629374841',
                            '770629341340',
                            '770629226680',
                            '770629541195',
                            '770629539646',
                            '770629470000',
                            '770629337709',
                            '770629543880',
                            '770629340700',
                            '770629440526',
                            '770629447563',
                            '770629152920',
                            '770628957142',
                            '770629342370',
                            '770628759570',
                            '770629543325',
                            '770629150714',
                            '770629147837',

                            '770629222324',
                            '770629271996',
                            '770628808538',

                            '202207303001',
                            '770629335480',
                            '770629537961',
                            '770629337113',
                            '770629338985',
                            '770629151788',
                            
                            '202207303037',

                            '770655966137',
                            '770655966676',
                            '770655942874',
                            '770656007885',
                            '770655721940',
                            '770656007893',
                            '770655720529',
                            '770655966757',
                            '770655880976',
                            '770655964886',
                            '770655966269',
                            '770655967435',
                            '770655964797',
                            '770655827250',
                            '770655722378',
                            '770655880372',
                            '770655965327',
                            '770656009250',
                            '770655966277',
                            '770655965653',
                            '770655966811',
                            '770656008458',
                            '770655955925',
                            '770655942963',
                            '770656007648',
                            '770655965041',
                            '770655718362',
                            '770656007265',
                            '770655966480',
                            '770656008369',
                            '770655944796',
                            '770656009136',
                            '770655967567',
                            '770655880607',
                            '770655955682',
                            '770656007575',
                            '770655956611',
                            '770655720200',
                            '770655943242',
                            '770655965610',
                            '770655967206',
                            '770655881441',
                            '770655955739',
                            '770656007281',
                            
                            '770655956905',
                            '770655957197',
                            '770655957138',
                            '770655956999',
                            '770655957189',

                            '202208458813');

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

         IF rw_principal.nrproposta_crawseg IN ('770629152091',
                                                '770629146768',
                                                '770629271872',
                                                '770628957070',
                                                '770629024433',
                                                '770629539352',
                                                '770629447911',
                                                '770629344462',
                                                '770629084401',
                                                '770629542124',
                                                '770628956405',
                                                '770629537600',
                                                '770629147764',
                                                '770629343954',
                                                '770628958262',
                                                '770629148981',
                                                '770629471138',
                                                '770629151842',
                                                '770629340734',
                                                '770629540350',
                                                '770629540296',
                                                '770629469311',
                                                '770629341790',
                                                '770629374841',
                                                '770629341340',
                                                '770629226680',
                                                '770629541195',
                                                '770629539646',
                                                '770629470000',
                                                '770629337709',
                                                '770629543880',
                                                '770629340700',
                                                '770629440526',
                                                '770629447563',
                                                '770629152920',
                                                '770628957142',
                                                '770629342370',
                                                '770628759570',
                                                '770629543325',
                                                '770629150714',
                                                '770629147837',

                                                '770629222324',
                                                '770629271996',
                                                '770628808538',

                                                '202207303001',
                                                '770629335480',
                                                '770629537961',
                                                '770629337113',
                                                '770629338985',
                                                '770629151788',

                                                '202207303037') THEN
           vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                       || '    SET p.tpregist = ''' || rw_principal.tpregist || ''''
                       || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

           IF rw_principal.nrproposta_crawseg IN ('770629271872',
                                                  '770629024433',
                                                  '770629084401',
                                                  '770629374841',

                                                  '770629222324',
                                                  '770629271996',
                                                  '770628808538') THEN
             vr_tpregist := 3;
           ELSE
             vr_tpregist := 1;
           END IF;

           UPDATE CECRED.tbseg_prestamista p
             SET p.tpregist = vr_tpregist
           WHERE p.idseqtra = rw_principal.idseqtra;

           vr_linha :=    ' UPDATE CECRED.crapseg p   '
                       || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                       || '       ,p.cdmotcan = ''' || rw_principal.cdmotcan || ''''
                       || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                       || '       ,p.dtfimvig = TO_DATE(''' || rw_principal.dtfimvig_crapseg || ''',''DD/MM/RRRR'')'
                       || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

           UPDATE CECRED.crapseg p
             SET p.cdsitseg = 1
                ,p.cdmotcan = NULL
                ,p.dtcancel = NULL
                ,p.dtfimvig = rw_principal.dtfimvig
           WHERE p.progress_recid = rw_principal.progress_recid;

         ELSIF rw_principal.nrproposta_crawseg IN ('770655966137',
                                                   '770655966676',
                                                   '770655942874',
                                                   '770656007885',
                                                   '770655721940',
                                                   '770656007893',
                                                   '770655720529',
                                                   '770655966757',
                                                   '770655880976',
                                                   '770655964886',
                                                   '770655966269',
                                                   '770655967435',
                                                   '770655964797',
                                                   '770655827250',
                                                   '770655722378',
                                                   '770655880372',
                                                   '770655965327',
                                                   '770656009250',
                                                   '770655966277',
                                                   '770655965653',
                                                   '770655966811',
                                                   '770656008458',
                                                   '770655955925',
                                                   '770655942963',
                                                   '770656007648',
                                                   '770655965041',
                                                   '770655718362',
                                                   '770656007265',
                                                   '770655966480',
                                                   '770656008369',
                                                   '770655944796',
                                                   '770656009136',
                                                   '770655967567',
                                                   '770655880607',
                                                   '770655955682',
                                                   '770656007575',
                                                   '770655956611',
                                                   '770655720200',
                                                   '770655943242',
                                                   '770655965610',
                                                   '770655967206',
                                                   '770655881441',
                                                   '770655955739',
                                                   '770656007281',

                                                   '770655956905',
                                                   '770655957197',
                                                   '770655957138',
                                                   '770655956999',
                                                   '770655957189',

                                                   '202208458813') THEN

           IF rw_principal.nrproposta_crawseg = '202208458813' THEN
             vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                         || '    SET p.flcancelado_mobile = ''' || rw_principal.flcancelado_mobile || ''''
                         || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

             UPDATE CECRED.tbseg_prestamista p
               SET p.flcancelado_mobile = 1
             WHERE p.idseqtra = rw_principal.idseqtra;

             vr_dtcancel := rw_principal.dtinivig;
           ELSE
             vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_principal.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

             CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

             UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 2
             WHERE p.idseqtra = rw_principal.idseqtra;

             vr_dtcancel := rw_crapcop.dtmvtolt;
           END IF;

           vr_linha :=    ' UPDATE CECRED.crapseg p   '
                       || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                       || '       ,p.cdmotcan = ''' || rw_principal.cdmotcan || ''''
                       || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                       || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

           UPDATE CECRED.crapseg p
             SET p.cdsitseg = 2
                ,p.cdmotcan = 4
                ,p.dtcancel = vr_dtcancel
           WHERE p.progress_recid = rw_principal.progress_recid;
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
