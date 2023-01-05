DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/PRB0047759';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_PRB0047759.sql';
  vr_exc_saida      EXCEPTION;
  vr_progress_recid craplcm.progress_recid%TYPE;
  
  CURSOR cr_craplau(pr_cdcooper IN craplau.cdcooper%TYPE) IS
    SELECT l.*
      FROM CECRED.craplau l
     WHERE l.cdcooper = pr_cdcooper
       AND l.cdhistor = 3651
       AND l.cdseqtel IN ('770628891850','770628950121');
  
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
    FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop.cdcooper) LOOP
  
      INSERT INTO CECRED.craplcm
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     nrdconta,
                     nrdocmto,
                     cdhistor,
                     nrseqdig,
                     vllanmto,
                     nrdctabb,
                     cdpesqbb,
                     vldoipmf,
                     nrautdoc,
                     nrsequni,
                     cdbanchq,
                     cdcmpchq,
                     cdagechq,
                     nrctachq,
                     nrlotchq,
                     sqlotchq,
                     dtrefere,
                     hrtransa,
                     cdoperad,
                     dsidenti,
                     cdcooper,
                     nrdctitg,
                     dscedent,
                     cdcoptfn,
                     cdagetfn,
                     nrterfin,
                     nrparepr,
                     nrseqava,
                     nraplica,
                     cdorigem,
                     idlautom)
                VALUES (rw_craplau.dtmvtopg,
                        rw_craplau.cdagenci,
                        rw_craplau.cdbccxlt,
                        rw_craplau.nrdolote,
                        rw_craplau.nrdconta,
                        rw_craplau.nrdocmto,
                        rw_craplau.cdhistor,
                        rw_craplau.nrseqdig,
                        rw_craplau.vllanaut,
                        rw_craplau.nrdctabb,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        rw_craplau.dttransa,
                        rw_craplau.hrtransa,
                        ' ',
                        ' ',
                        rw_craplau.cdcooper,
                        rw_craplau.nrdctitg,
                        rw_craplau.dscedent,
                        rw_craplau.cdcoptfn,
                        rw_craplau.cdagetfn,
                        rw_craplau.nrterfin,
                        0,
                        0,
                        0,
                        0,
                        0) RETURNING progress_recid INTO vr_progress_recid;
                        
      vr_linha := 'DELETE CECRED.craplcm l '  ||
                  ' WHERE l.progress_recid = ' || vr_progress_recid ||';';
       
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
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
/
