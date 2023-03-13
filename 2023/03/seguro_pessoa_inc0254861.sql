DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0254861';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0254861.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.idseqtra
          ,p.situacao   
          ,p.dtrecusa   
          ,p.tprecusa   
          ,p.cdmotrec   
          ,p.dsprotocolo
          ,s.progress_recid   
          ,s.dtcancel
          ,s.cdsitseg
          ,s.cdopeexc
          ,s.cdageexc
          ,s.dtinsexc
          ,s.cdopecnl
      FROM CECRED.crapseg s, 
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = pr_cdcooper
       AND p.nrproposta IN ('202212148294',
                            '202213345019',
                            '202213381561',
                            '202213534482',
                            '202212177069');

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

          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.situacao    = ''' || rw_principal.situacao || ''''
                      || '       ,p.dtrecusa = TO_DATE(''' || rw_principal.dtrecusa || ''',''DD/MM/RRRR'')'
                      || '       ,p.tprecusa    = ''' || rw_principal.tprecusa || ''''
                      || '       ,p.cdmotrec    = ''' || rw_principal.cdmotrec || ''''
                      || '       ,p.dsprotocolo = ''' || rw_principal.dsprotocolo || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.cdsitseg    = ''' || rw_principal.cdsitseg || ''''
                      || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                      || '       ,p.cdopeexc    = ''' || rw_principal.cdopeexc || ''''
                      || '       ,p.cdageexc    = ''' || rw_principal.cdageexc || ''''
                      || '       ,p.dtinsexc = TO_DATE(''' || rw_principal.dtinsexc || ''',''DD/MM/RRRR'')'
                      || '       ,p.cdopecnl = ''' || rw_principal.cdopecnl || ''''
                      || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          UPDATE CECRED.tbseg_prestamista p
            SET p.situacao    = 1
               ,p.dtrecusa    = NULL
               ,p.tprecusa    = NULL
               ,p.cdmotrec    = NULL
               ,p.dsprotocolo = NULL
          WHERE p.idseqtra = rw_principal.idseqtra;

          UPDATE CECRED.crapseg p
             SET p.dtcancel = NULL,
                 p.cdsitseg = 1,
                 p.cdopeexc = NULL,
                 p.cdageexc = NULL,
                 p.dtinsexc = NULL,
                 p.cdopecnl = NULL
           WHERE p.progress_recid = rw_principal.progress_recid;
         
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
