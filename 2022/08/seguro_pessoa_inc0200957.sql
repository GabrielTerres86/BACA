DECLARE
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0200957';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0200957.sql';
  vr_exc_saida  EXCEPTION;
  vcount        NUMBER;
  vr_cdmotcan   NUMBER;

  CURSOR cr_crapseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT seg.nrdconta
          ,seg.nrctremp
          ,p.progress_recid
          ,p.cdmotcan
          ,p.dtcancel
          ,p.cdsitseg
      FROM CECRED.crapseg p,
           CECRED.tbseg_prestamista seg
     WHERE seg.cdcooper = pr_cdcooper
       AND seg.cdcooper = p.cdcooper
       AND seg.nrdconta = p.nrdconta
       AND seg.nrctrseg = p.nrctrseg
       AND p.tpseguro = 4
       AND seg.tpregist = 0
       AND p.cdsitseg = 1;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  CURSOR cr_crapepr(pr_cdcooper CECRED.crapseg.cdcooper%TYPE,
                    pr_nrdconta CECRED.crapepr.nrdconta%TYPE,
                    pr_nrctremp CECRED.crapepr.nrctremp%TYPE) IS
    SELECT e.inliquid
      FROM CECRED.crapepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp
       AND e.inliquid = 1;
    rw_crapepr cr_crapepr%ROWTYPE;

  BEGIN
    BEGIN
      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                              ,pr_nmarquiv => vr_nmarq
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arq
                              ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_linha :=   'UPDATE CECRED.crapseg '
                      ||'   SET cdmotcan = ''' || rw_crapseg.cdmotcan || ''','
                      ||'       dtcancel = ''' || rw_crapseg.dtcancel || ''','
                      ||'       cdsitseg = ''' || rw_crapseg.cdsitseg || ''''
                      ||' WHERE progress_recid = ' || rw_crapseg.progress_recid ||' ; ';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          OPEN cr_crapepr(pr_cdcooper => rw_crapcop.cdcooper,
                          pr_nrdconta => rw_crapseg.nrdconta,
                          pr_nrctremp => rw_crapseg.nrctremp);
            FETCH cr_crapepr INTO rw_crapepr;
            IF cr_crapepr%FOUND THEN
              vr_cdmotcan := 20;
            ELSE
              vr_cdmotcan := 4;
            END IF;
          CLOSE cr_crapepr;

          UPDATE CECRED.crapseg p
             SET p.cdmotcan = vr_cdmotcan
                ,p.dtcancel = TRUNC(SYSDATE)
                ,p.cdsitseg = 2
           WHERE p.progress_recid = rw_crapseg.progress_recid;
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
END;
/
