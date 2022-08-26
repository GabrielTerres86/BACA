DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0210067';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0210067_2.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_nrproposta     VARCHAR2(15);

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.tpregist
          ,p.nrproposta
          ,p.idseqtra
      FROM CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.idseqtra IN (586075,499681)
       AND p.nrproposta IN ('770658374044', '770572951456');

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
         vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          vr_linha :=   'UPDATE CECRED.tbseg_prestamista '
                      ||'   SET tpregist   = ''' || rw_principal.tpregist   || ''','
                      ||'       nrproposta = ''' || rw_principal.nrproposta || ''''
                      ||' WHERE idseqtra = ' || rw_principal.idseqtra ||' ; ';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          vr_nrproposta := CECRED.segu0003.FN_NRPROPOSTA(pr_tpcustei => 1,
                                                         pr_cdcooper => rw_crapcop.cdcooper);

          UPDATE CECRED.tbseg_prestamista p
             SET p.tpregist = 1,
                 p.nrproposta = vr_nrproposta
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
END;
/
