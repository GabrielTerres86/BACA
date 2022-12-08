DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0235580';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0235580_1.sql';
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
       AND p.nrproposta IN ('770657205320',
                            '770657205354',
                            '770655956794',
                            '770657205346')
    UNION   
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
       AND p.nrproposta IN ('770629144927',
                            '770629084134',
                            '770629371540',
                            '770629000178',
                            '770629145800',
                            '770629469001',
                            '770628757488',
                            '770629675434',
                            '770629375520',
                            '770629018263',
                            '770629535551',
                            '770629139613',
                            '770629018425',
                            '770629678271',
                            '770629678859',
                            '770629529675',
                            '770628947686',
                            '770629225021',
                            '770628752583',
                            '770629224181',
                            '770629376828',
                            '770628954160',
                            '770629696890',
                            '770629694919',
                            '770629080341',
                            '770628857873',
                            '770629544992',
                            '770629672885',
                            '770629547207',
                            '770628894035',
                            '770629659684',
                            '770629637826',
                            '770628806969',
                            '770628806152');

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
                      || '       ,p.nrproposta = ''' || rw_principal.nrproposta || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.cdsitseg = ''' || rw_principal.cdsitseg || ''''
                      || '       ,p.cdmotcan = ''' || rw_principal.cdmotcan || ''''
                      || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                      || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          IF rw_principal.nrproposta_crawseg IN ('770657205320','770657205354','770655956794','770657205346') THEN
            UPDATE CECRED.crapseg p
               SET p.cdsitseg = 2
                  ,p.cdmotcan = NVL(p.cdmotcan,4)
                  ,p.dtcancel = NVL(p.dtcancel,TRUNC(SYSDATE))
             WHERE p.progress_recid = rw_principal.progress_recid;

            UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 0
                  ,p.nrproposta = rw_principal.nrproposta_crawseg
             WHERE p.idseqtra = rw_principal.idseqtra;
          ELSE
            UPDATE CECRED.crapseg p
               SET p.cdsitseg = 1
                  ,p.cdmotcan = NULL
                  ,p.dtcancel = NULL
             WHERE p.progress_recid = rw_principal.progress_recid;

            UPDATE CECRED.tbseg_prestamista p
               SET p.tpregist = 3
             WHERE p.idseqtra = rw_principal.idseqtra;
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
