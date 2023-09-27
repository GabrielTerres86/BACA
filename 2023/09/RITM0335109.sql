DECLARE
  vr_ind_arq        utl_file.file_type;
  vcount            NUMBER := 0;
  vr_texto          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/RITM0335109';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_RITM0335109.sql';
  vr_exc_saida      EXCEPTION;

  CURSOR cr_principal IS
    SELECT c.progress_recid
          ,c.nrctacns
      FROM CECRED.crapcns c
     WHERE c.nrctacns <> 0;

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

      FOR rw_principal IN cr_principal LOOP

        vr_texto := ' UPDATE CECRED.crapcns '
                 || '    SET nrctacns = ' || rw_principal.nrctacns
                 || '  WHERE progress_recid = ' || rw_principal.progress_recid || ';';

        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);
                
        BEGIN
           UPDATE CECRED.crapcns
              SET nrctacns = 0
            WHERE progress_recid = rw_principal.progress_recid;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
          WHEN OTHERS THEN
            CECRED.pc_internal_exception;
            vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
            RAISE vr_exc_saida;
        END;

        IF vcount = 1000 THEN
		  vcount := 0;
          COMMIT;
        ELSE
          vcount := vcount + 1;
        END IF;
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
