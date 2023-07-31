DECLARE
  vr_ind_arq        utl_file.file_type;
  vcount            NUMBER := 0;
  vr_texto          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0283875';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0283875.sql';
  vr_exc_saida      EXCEPTION;
  
  vr_linha           PLS_INTEGER := 0;
  vr_caminho_arq     VARCHAR2(200);
  vr_nmarquiv        VARCHAR2(50);
  vr_listadir        VARCHAR2(4000);
  vr_tab_nmarquiv    GENE0002.typ_split;
  vr_nmarqimp        VARCHAR2(100);
  vr_input_file      utl_file.file_type;
  vr_setlinha        VARCHAR2(500);
  
  vr_nmconsor        CECRED.crapcns.nmconsor%TYPE;
  vr_nrcpfcgc        CECRED.crapcns.nrcpfcgc%TYPE;
  vr_nrdiadeb        CECRED.crapcns.nrdiadeb%TYPE;
  vr_dtinicns        CECRED.crapcns.dtinicns%TYPE;
  vr_qtparpag        CECRED.crapcns.qtparpag%TYPE;
  vr_qtparres        CECRED.crapcns.qtparres%TYPE;
  vr_vlrcarta        CECRED.crapcns.vlrcarta%TYPE;
  vr_vlparcns        CECRED.crapcns.vlparcns%TYPE;
  vr_dtfimcns        CECRED.crapcns.dtfimcns%TYPE;
  vr_dtcancel        CECRED.crapcns.dtcancel%TYPE;
  vr_dtctpcns        CECRED.crapcns.dtctpcns%TYPE;
  vr_dtentcns        CECRED.crapcns.dtentcns%TYPE;
  vr_dtmvtolt        CECRED.crapcns.dtmvtolt%TYPE;
  vr_flgativo        CECRED.crapcns.flgativo%TYPE;
  vr_qtparcns        CECRED.crapcns.qtparcns%TYPE;
  vr_tpconsor        CECRED.crapcns.tpconsor%TYPE;
  vr_cdsitcns        CECRED.crapcns.cdsitcns%TYPE;
  vr_qtparatr        CECRED.crapcns.qtparatr%TYPE;
  vr_nrdiaatr        CECRED.crapcns.nrdiaatr%TYPE;
  vr_tpcntpla        CECRED.crapcns.tpcntpla%TYPE;
  vr_perlance        CECRED.crapcns.perlance%TYPE;
  vr_dtvencns        CECRED.crapcns.dtvencns%TYPE;
  vr_dtassemb        CECRED.crapcns.dtassemb%TYPE;
  vr_vlsdeved        CECRED.crapcns.vlsdeved%TYPE;
  vr_nmopevnd        CECRED.crapcns.nmopevnd%TYPE;
  vr_cdversao        CECRED.crapcns.cdversao%TYPE;
  vr_nrctrato        CECRED.crapcns.nrctrato%TYPE;
  vr_nrcotcns        CECRED.crapcns.nrcotcns%TYPE;
  vr_nrdgrupo        CECRED.crapcns.nrdgrupo%TYPE;
  vr_cdcooper        CECRED.crapcop.cdcooper%TYPE;
  vr_cdagectl        CECRED.crapcop.cdagectl%TYPE;
  
  vr_versao          VARCHAR(2);
  vr_nrdconta        VARCHAR2(500);
  vr_tpregist        VARCHAR2(1);

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper = 3
       AND c.cdcooper = d.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapcop_ctl(pr_cdagectl CECRED.crapcop.cdagectl%TYPE) IS
    SELECT cop.cdcooper
      FROM CECRED.crapcop cop
     WHERE cop.cdagectl = pr_cdagectl;
     
  CURSOR cr_crapcns(pr_nrdgrupo IN CECRED.crapcns.nrdgrupo%TYPE
                   ,pr_nrcpfcgc IN CECRED.crapcns.nrcpfcgc%TYPE
                   ,pr_nrcotcns IN CECRED.crapcns.nrcotcns%TYPE
                   ,pr_nrctrato IN CECRED.crapcns.nrctrato%TYPE) IS 
   SELECT *
     FROM CECRED.crapcns
    WHERE crapcns.nrdgrupo = pr_nrdgrupo
      AND crapcns.nrcpfcgc = pr_nrcpfcgc
      AND crapcns.nrcotcns = pr_nrcotcns
      AND crapcns.nrctrato = pr_nrctrato;

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
      OPEN cr_crapcop;
        FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
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
      
      vr_caminho_arq := CECRED.GENE0001.fn_param_sistema('CRED', 3, 'DIR_658_RECEBE');
      
      vr_nmarquiv := 'consorcios_ajuste_status.txt';
      
      CECRED.GENE0001.pc_lista_arquivos(pr_path     => vr_caminho_arq
                                       ,pr_pesq     => vr_nmarquiv
                                       ,pr_listarq  => vr_listadir
                                       ,pr_des_erro => vr_dscritic);
                                 
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_tab_nmarquiv := CECRED.GENE0002.fn_quebra_string(pr_string => vr_listadir);
      
      FOR idx IN 1..vr_tab_nmarquiv.COUNT LOOP

        vr_nmarqimp := vr_tab_nmarquiv(idx);

        CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq
                                       ,pr_nmarquiv => vr_tab_nmarquiv(idx)
                                       ,pr_tipabert => 'R'
                                       ,pr_utlfileh => vr_input_file
                                       ,pr_des_erro => vr_dscritic);
                                
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        LOOP
          vr_linha := vr_linha + 1;

          BEGIN
            CECRED.GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                               ,pr_des_text => vr_setlinha);
            
            vr_tpregist := SUBSTR(vr_setlinha,1,1);
            
            IF vr_tpregist <> 0 THEN
              CONTINUE;
            END IF;
            
            vr_nrdconta := TRIM(SUBSTR(vr_setlinha,165,11));
            
            IF vr_nrdconta != '00000000000' THEN
              CONTINUE;
            END IF;
            
            vr_nmconsor := REPLACE(SUBSTR(vr_setlinha,22,40),'&','E');
            vr_nrcpfcgc := SUBSTR(vr_setlinha,62,14);
            vr_nrdiadeb := SUBSTR(vr_setlinha,96,2);
            vr_dtinicns := to_date(trim(SUBSTR(vr_setlinha,88,8)) ,'ddmmyyyy');
            vr_qtparpag := SUBSTR(vr_setlinha,98,3);
            vr_qtparres := SUBSTR(vr_setlinha,101,3);
            vr_vlrcarta := SUBSTR(vr_setlinha,104,11) / 100;
            vr_vlparcns := SUBSTR(vr_setlinha,115,11) / 100;
            vr_dtfimcns := to_date(trim(SUBSTR(vr_setlinha,126,8)),'ddmmyyyy');
            vr_dtcancel := to_date(trim(SUBSTR(vr_setlinha,134,8)),'ddmmyyyy');
            vr_dtctpcns := to_date(trim(SUBSTR(vr_setlinha,142,8)),'ddmmyyyy');
            vr_dtentcns := to_date(trim(SUBSTR(vr_setlinha,150,8)),'ddmmyyyy');
            vr_dtmvtolt := rw_crapcop.dtmvtolt;

            vr_versao   := SUBSTR(vr_setlinha,12,2);
            vr_cdsitcns := SUBSTR(vr_setlinha,176,3);

            IF ((vr_dtcancel IS NOT NULL) or (vr_cdsitcns = 'TRA')) THEN
              vr_flgativo := 0;
            ELSE
              IF((vr_versao = 0) AND ((vr_dtfimcns)  >= sysdate))THEN
                vr_flgativo := 1;
              ELSE
                vr_flgativo := 0;
              END IF;
            END IF;
            
            vr_qtparcns := SUBSTR(vr_setlinha,98,3) + vr_qtparres;
            vr_tpconsor := SUBSTR(vr_setlinha,86,2);
            
            vr_qtparatr := SUBSTR(vr_setlinha,179,3);
            vr_nrdiaatr := SUBSTR(vr_setlinha,182,4);
            
            CASE TRIM(SUBSTR(vr_setlinha,186,1))
              WHEN 'S' THEN
                vr_tpcntpla := 1;
              WHEN 'L' THEN
                vr_tpcntpla := 2;
              ELSE
                vr_tpcntpla := 0;
            END CASE;
            
            vr_perlance := SUBSTR(vr_setlinha,187,7) / 10000;
            vr_dtvencns := to_date(TRIM(SUBSTR(vr_setlinha,194,8)),'ddmmyyyy');
            vr_dtassemb := to_date(TRIM(SUBSTR(vr_setlinha,202,8)),'ddmmyyyy');
            vr_vlsdeved := to_number(SUBSTR(vr_setlinha,210,11)) / 100;
            vr_nmopevnd := TRIM(SUBSTR(vr_setlinha,221,40));
            vr_cdversao := SUBSTR(vr_setlinha, 12, 2);            
            vr_nrctrato := SUBSTR(vr_setlinha,14,8);
            vr_nrcotcns := SUBSTR(vr_setlinha,8,4);
            vr_nrdgrupo := SUBSTR(vr_setlinha,2,6);
            
            vr_cdagectl := SUBSTR(vr_setlinha,76,4);
            OPEN cr_crapcop_ctl(vr_cdagectl);
              FETCH cr_crapcop_ctl INTO vr_cdcooper;
            CLOSE cr_crapcop_ctl;
            
            FOR rw_crapcns IN cr_crapcns(pr_nrdgrupo => vr_nrdgrupo
                                        ,pr_nrcpfcgc => vr_nrcpfcgc
                                        ,pr_nrcotcns => vr_nrcotcns
                                        ,pr_nrctrato => vr_nrctrato) LOOP
                                        
              vr_texto := ' UPDATE CECRED.crapcns '
                       || '    SET crapcns.nmconsor = ''' || rw_crapcns.nmconsor || ''''
                       || '       ,crapcns.nrcpfcgc = ''' || rw_crapcns.nrcpfcgc || ''''
                       || '       ,crapcns.nrdiadeb = ''' || rw_crapcns.nrdiadeb || ''''
                       || '       ,crapcns.dtinicns = TO_DATE(''' || rw_crapcns.dtinicns || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.qtparpag = ''' || rw_crapcns.qtparpag || ''''
                       || '       ,crapcns.qtparres = ''' || rw_crapcns.qtparres || ''''
                       || '       ,crapcns.vlrcarta = ''' || rw_crapcns.vlrcarta || ''''
                       || '       ,crapcns.vlparcns = ''' || rw_crapcns.vlparcns || ''''
                       || '       ,crapcns.dtfimcns = TO_DATE(''' || rw_crapcns.dtfimcns || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.dtcancel = TO_DATE(''' || rw_crapcns.dtcancel || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.dtctpcns = TO_DATE(''' || rw_crapcns.dtctpcns || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.dtentcns = TO_DATE(''' || rw_crapcns.dtentcns || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.dtmvtolt = TO_DATE(''' || rw_crapcns.dtmvtolt || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.flgativo = ''' || rw_crapcns.flgativo || ''''
                       || '       ,crapcns.qtparcns = ''' || rw_crapcns.qtparcns || ''''
                       || '       ,crapcns.tpconsor = ''' || rw_crapcns.tpconsor || ''''
                       || '       ,crapcns.cdsitcns = ''' || rw_crapcns.cdsitcns || ''''
                       || '       ,crapcns.qtparatr = ''' || rw_crapcns.qtparatr || ''''
                       || '       ,crapcns.nrdiaatr = ''' || rw_crapcns.nrdiaatr || ''''
                       || '       ,crapcns.tpcntpla = ''' || rw_crapcns.tpcntpla || ''''
                       || '       ,crapcns.perlance = ''' || rw_crapcns.perlance || ''''
                       || '       ,crapcns.dtvencns = TO_DATE(''' || rw_crapcns.dtvencns || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.dtassemb = TO_DATE(''' || rw_crapcns.dtassemb || ''',''DD/MM/RRRR'')'
                       || '       ,crapcns.vlsdeved = ''' || rw_crapcns.vlsdeved || ''''
                       || '       ,crapcns.nmopevnd = ''' || rw_crapcns.nmopevnd || ''''
                       || '       ,crapcns.cdversao = ''' || rw_crapcns.cdversao || ''''
                       || '  WHERE crapcns.nrdgrupo = ' || vr_nrdgrupo
                       || '    AND crapcns.nrcpfcgc = ' || vr_nrcpfcgc
                       || '    AND crapcns.nrcotcns = ' || vr_nrcotcns
                       || '    AND crapcns.nrctrato = ' || vr_nrctrato || ';';
                       
              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);
            END LOOP;
            
            UPDATE CECRED.crapcns
               SET crapcns.nmconsor = vr_nmconsor,
                   crapcns.nrcpfcgc = vr_nrcpfcgc,
                   crapcns.nrdiadeb = vr_nrdiadeb,
                   crapcns.dtinicns = vr_dtinicns,
                   crapcns.qtparpag = vr_qtparpag,
                   crapcns.qtparres = vr_qtparres,
                   crapcns.vlrcarta = vr_vlrcarta,
                   crapcns.vlparcns = vr_vlparcns,
                   crapcns.dtfimcns = vr_dtfimcns,
                   crapcns.dtcancel = vr_dtcancel,
                   crapcns.dtctpcns = vr_dtctpcns,
                   crapcns.dtentcns = vr_dtentcns,
                   crapcns.dtmvtolt = rw_crapcop.dtmvtolt,
                   crapcns.flgativo = vr_flgativo,
                   crapcns.qtparcns = vr_qtparcns,
                   crapcns.tpconsor = vr_tpconsor,
                   crapcns.cdsitcns = vr_cdsitcns,
                   crapcns.qtparatr = vr_qtparatr,
                   crapcns.nrdiaatr = vr_nrdiaatr,
                   crapcns.tpcntpla = vr_tpcntpla,
                   crapcns.perlance = vr_perlance,
                   crapcns.dtvencns = vr_dtvencns,
                   crapcns.dtassemb = vr_dtassemb,
                   crapcns.vlsdeved = vr_vlsdeved,
                   crapcns.nmopevnd = vr_nmopevnd,
                   crapcns.cdversao = vr_cdversao
             WHERE crapcns.nrdgrupo = vr_nrdgrupo
               AND crapcns.nrcpfcgc = vr_nrcpfcgc
               AND crapcns.nrcotcns = vr_nrcotcns
               AND crapcns.nrctrato = vr_nrctrato;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              EXIT;
            WHEN OTHERS THEN
              CECRED.pc_internal_exception;
              vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        END LOOP;
        
        IF vcount = 1000 THEN
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
