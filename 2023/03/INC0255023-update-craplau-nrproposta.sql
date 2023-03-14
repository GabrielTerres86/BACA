DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0255023';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0255023.sql';
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
      
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
  END;  

  BEGIN
      pc_valida_direto(pr_nmdireto => vr_nmdir,
                       pr_dscritic => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;    
  
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
