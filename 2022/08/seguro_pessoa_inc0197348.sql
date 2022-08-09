DECLARE
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0197348';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0197348.sql';
  vr_exc_saida  EXCEPTION;
  vcount        NUMBER;

  CURSOR cr_crapseg(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT s.nrdconta,
           s.nrctrseg,
           s.cdmotcan,
           s.dtcancel,
           s.cdsitseg
      FROM CECRED.crapseg s,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND s.tpseguro = 4
       AND p.nrproposta = '770629437312';

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
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
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_linha :=   'UPDATE CECRED.crapseg '
                      ||'   SET cdmotcan = ''' || rw_crapseg.cdmotcan || ''','
                      ||'       dtcancel = ''' || rw_crapseg.dtcancel || ''','
                      ||'       cdsitseg = ''' || rw_crapseg.cdsitseg || ''''
                      ||' WHERE cdcooper = ' || rw_crapcop.cdcooper
                      ||'   AND nrdconta = ' || rw_crapseg.nrdconta
                      ||'   AND nrctrseg = ' || rw_crapseg.nrctrseg ||' ; ';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.crapseg p
             SET p.cdmotcan = 20
                ,p.dtcancel = TO_DATE(SYSDATE,'DD/MM/RRRR')
                ,p.cdsitseg = 2
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_crapseg.nrdconta
             AND p.nrctrseg = rw_crapseg.nrctrseg
             AND p.tpseguro = 4;
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
