DECLARE
  vr_ind_arq        utl_file.file_type;
  vcount            NUMBER := 0;
  vr_texto          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/PRJ0025037';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_PRJ0025037_656790.sql';
  vr_exc_saida      EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
          ,p.nrapolic
          ,p.cdsegura
      FROM CECRED.crapdat d,
           CECRED.tbseg_parametros_prst p,
           CECRED.crapcop c
     WHERE c.cdcooper = p.cdcooper
       AND c.cdcooper = d.cdcooper   
       AND c.flgativo = 1
       AND c.cdcooper <> 3
       AND p.tpcustei = 1
       AND p.cdsegura = CECRED.SEGU0001.busca_seguradora
       AND p.tppessoa =  1;

  CURSOR cr_principal(pr_cdcooper IN CECRED.tbseg_prestamista.cdcooper%TYPE
                     ,pr_cdsegura IN CECRED.crapseg.cdsegura%TYPE) IS
    SELECT p.idseqtra, p.nrapolice
      FROM CECRED.crapseg w,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.tpregist IN (1,2,3,5)
       AND p.nrapolice IS NULL
       AND p.cdcooper = w.cdcooper
       AND p.nrdconta = w.nrdconta
       AND p.nrctrseg = w.nrctrseg
       AND w.cdsegura = pr_cdsegura
       AND w.tpseguro = 4;

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
        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_cdsegura => rw_crapcop.cdsegura) LOOP

          vr_texto := ' UPDATE CECRED.tbseg_prestamista '
                   || '    SET nrapolice = NULL '
                   || '  WHERE idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);

          BEGIN
             UPDATE CECRED.tbseg_prestamista
                SET nrapolice = rw_crapcop.nrapolic
              WHERE idseqtra = rw_principal.idseqtra;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              EXIT;
            WHEN OTHERS THEN
              CECRED.pc_internal_exception;
              vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
              RAISE vr_exc_saida;
          END;

          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;
      END LOOP;
      COMMIT;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    EXCEPTION
       WHEN vr_exc_saida THEN
            vr_dscritic := vr_dscritic || ' ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_dscritic);
            ROLLBACK;
       WHEN OTHERS THEN
            vr_dscritic := vr_dscritic || ' ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_dscritic);
            ROLLBACK;
    END;
/
