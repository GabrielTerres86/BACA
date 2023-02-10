DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0245035';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0245035.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrctrseg
          ,p.nrctremp
          ,p.nrproposta
          ,p.dtinivig
          ,l.cdseqtel
          ,l.idlancto
     FROM CECRED.craplau l,
          CECRED.crawseg w,
          CECRED.crapseg s,
          CECRED.tbseg_prestamista p
    WHERE p.cdcooper = s.cdcooper
      AND p.nrdconta = s.nrdconta
      AND p.nrctrseg = s.nrctrseg
      AND p.cdcooper = w.cdcooper
      AND p.nrdconta = w.nrdconta
      AND p.nrctrseg = w.nrctrseg
      AND p.cdcooper = l.cdcooper
      AND p.nrdconta = l.nrdconta
      AND p.nrctremp = l.nrctremp
      AND p.dtinivig = l.dtmvtolt
      AND p.nrproposta <> l.cdseqtel
      AND p.nrctremp NOT IN (43775,201019,198739)
      AND l.cdhistor = 3651
      AND p.cdcooper = pr_cdcooper;
      
  CURSOR cr_principal2(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS      
    SELECT TRUNC(p.dtrecusa) dtrecusa
          ,s.progress_recid
      FROM CECRED.crapseg s,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = pr_cdcooper
       AND p.nrproposta IN ('202213349370',
                            '202213455857',
                            '202213349361',
                            '202213349686',
                            '202213209968',
                            '202213672919',
                            '202212140409',
                            '202213182549',
                            '202213152457',
                            '202213055080',
                            '202212184005',
                            '202212384972',
                            '202212146466',
                            '202212146641',
                            '202213022762',
                            '202212146327',
                            '202212176965',
                            '202212177235',
                            '202213344449',
                            '202212787786',
                            '202213216917',
                            '202213345131',
                            '202212250654',
                            '202212138655',
                            '202213982763',
                            '202213357212',
                            '202213854831',
                            '202212153413',
                            '202212153532');
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

          vr_linha :=    ' UPDATE CECRED.craplau p   '
                      || '    SET p.cdseqtel = ''' || rw_principal.cdseqtel || ''''
                      || '  WHERE p.idlancto = ' || rw_principal.idlancto || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.craplau p
             SET p.cdseqtel = rw_principal.nrproposta
           WHERE p.idlancto = rw_principal.idlancto;
        END LOOP;
        
        FOR rw_principal2 IN cr_principal2(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.dtcancel = NULL  '
                      || '  WHERE p.progress_recid = ' || rw_principal2.progress_recid || ';';

           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.crapseg p
             SET p.dtcancel = rw_principal2.dtrecusa
           WHERE p.progress_recid = rw_principal2.progress_recid;
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
