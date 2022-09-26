DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0217493';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0217493.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_nrproposta     CECRED.tbseg_prestamista.nrproposta%TYPE;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.nrproposta
          ,p.idseqtra
          ,p.nrdconta
          ,p.nrctrseg
      FROM (SELECT p.nrproposta
              FROM CECRED.tbseg_prestamista p
             GROUP BY p.nrproposta
            HAVING COUNT(1) > 1) x,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrproposta = x.nrproposta
       AND p.tpregist = 1;
                          
    CURSOR cr_nrproposta IS
      SELECT n.nrproposta
      FROM CECRED.tbseg_nrproposta n
     WHERE n.tpcustei = 1
       AND n.dhseguro IS NULL
       AND EXISTS (SELECT 1 
                     FROM CECRED.tbseg_prestamista p 
                    WHERE p.nrproposta = n.nrproposta);
  
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
      
      FOR rw_nrproposta IN cr_nrproposta LOOP
          vr_linha :=    ' UPDATE CECRED.tbseg_nrproposta p   '
                      || '    SET p.dhseguro = NULL '
                      || '  WHERE p.nrproposta = ''' || rw_nrproposta.nrproposta || ''''
                      || '    AND p.tpcustei = 1;';
          
          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          UPDATE CECRED.tbseg_nrproposta p
             SET p.dhseguro = SYSDATE
           WHERE p.nrproposta = rw_nrproposta.nrproposta
             AND p.tpcustei = 1;
             
          COMMIT;
      END LOOP;

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          
          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.nrproposta = ''' || rw_principal.nrproposta || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';
          
           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          vr_linha :=    ' UPDATE CECRED.crawseg p   '
                      || '    SET p.nrproposta = ''' || rw_principal.nrproposta || ''''
                      || '  WHERE p.cdcooper = ' || rw_crapcop.cdcooper
                      || '    AND p.nrdconta = ' || rw_principal.nrdconta
                      || '    AND p.nrctrseg = ' || rw_principal.nrctrseg || ';';
          
           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          vr_nrproposta := CECRED.segu0003.fn_nrproposta();
          
          UPDATE CECRED.tbseg_prestamista p
             SET p.nrproposta = vr_nrproposta
           WHERE p.idseqtra = rw_principal.idseqtra;
          
          UPDATE CECRED.crawseg p
             SET p.nrproposta = vr_nrproposta
           WHERE p.cdcooper = rw_crapcop.cdcooper
             AND p.nrdconta = rw_principal.nrdconta
             AND p.nrctrseg = rw_principal.nrctrseg;
             
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
