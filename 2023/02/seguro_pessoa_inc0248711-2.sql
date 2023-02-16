DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0248711';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0248711.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_vlprodut       NUMBER;
  vr_vlsdeved       NUMBER;

  CURSOR cr_principal(pr_cdcooper CECRED.crapcop.cdcooper%TYPE) IS
    SELECT p.nrdconta
          ,p.nrctremp
          ,LAST_DAY(p.dtinivig) dtultimodia
          ,e.vlsdeved vlsdeved_crapepr
          ,p.vlprodut
          ,p.vlsdeved
          ,p.vldevatu
          ,p.idseqtra
      FROM CECRED.crapepr e,
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.tpcustei = 1
       AND p.vldevatu = 0
       AND p.dtinivig >= TO_DATE('22/01/2023','DD/MM/RRRR')
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND e.inliquid = 0;
       
  CURSOR cr_crapris(pr_cdcooper IN CECRED.crapris.cdcooper%TYPE
                   ,pr_nrdconta IN CECRED.crapris.nrdconta%TYPE
                   ,pr_nrctremp IN CECRED.crapris.nrctremp%TYPE
                   ,pr_dtrefere IN CECRED.crapris.dtrefere%TYPE) IS
    SELECT i.vldivida 
      FROM CECRED.crapris i 
     WHERE i.cdcooper = pr_cdcooper 
       AND i.nrdconta = pr_nrdconta
       AND i.nrctremp = pr_nrctremp
       AND i.dtrefere = pr_dtrefere;
  rw_crapris cr_crapris%ROWTYPE;
   
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
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        
        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
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
          OPEN cr_crapris(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_nrdconta => rw_principal.nrdconta
                         ,pr_nrctremp => rw_principal.nrctremp
                         ,pr_dtrefere => rw_principal.dtultimodia);
            FETCH cr_crapris INTO rw_crapris;
            IF cr_crapris%FOUND THEN
              vr_vlsdeved := rw_crapris.vldivida;
            ELSE
              vr_vlsdeved := rw_principal.vlsdeved_crapepr;
            END IF;
          CLOSE cr_crapris;
          
          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.vlprodut = ' || REPLACE(rw_principal.vlprodut,',','.')
                      || '       ,p.vlsdeved = ' || REPLACE(rw_principal.vlsdeved,',','.')
                      || '       ,p.vldevatu = ' || REPLACE(rw_principal.vldevatu,',','.')
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';
          
           CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
           
          vr_vlprodut := vr_vlsdeved * (0.02088/100);
          
          UPDATE CECRED.tbseg_prestamista p
             SET p.vlprodut = vr_vlprodut
                ,p.vlsdeved = vr_vlsdeved
                ,p.vldevatu = vr_vlsdeved
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
/
