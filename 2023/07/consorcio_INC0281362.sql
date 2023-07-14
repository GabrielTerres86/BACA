DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_ind_arq_erro   utl_file.file_type;
  vcount            NUMBER := 0;
  vr_texto          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0281362';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0281362.sql';
  vr_nmarq_erro     VARCHAR2(100)  := 'ERRO_INC0281362.sql';
  vr_exc_saida      EXCEPTION;
  vr_idrepiqu       CECRED.tbcns_repique.idrepiqu%TYPE;
  vr_cdcritic       PLS_INTEGER := 0;
  vr_dtrefere       DATE;
  vr_nrdocmto       VARCHAR2(25);
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;  
  
  CURSOR cr_principal(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE) IS
    SELECT craplau.cdcooper
          ,craplau.cdagenci
          ,craplau.nrdconta
          ,craplau.dtmvtopg
          ,craplau.vllanaut
          ,craplau.nrdocmto
          ,craplau.nrcrcard
          ,craplau.nrdctabb
          ,craplau.cdhistor
          ,craplau.ROWID
          ,craplau.progress_recid
          ,craplau.cdbccxlt
          ,craplau.cdseqtel
          ,craplau.nrseqdig
          ,craplau.nrdolote
          ,craplau.dtmvtolt
          ,craplau.dscedent
          ,seg.cdsegmento tpconsor
          ,craplau.idlancto
      FROM CECRED.craplau
     INNER JOIN CECRED.tbconsor_segmento seg
        ON seg.cdhistordebito = craplau.cdhistor
     WHERE craplau.cdcooper = pr_cdcooper
       AND craplau.insitlau = 1
       AND craplau.dtmvtopg = TO_DATE('10/07/2023')
       AND craplau.cdhistor IN (1230, 1231, 1232, 1233, 1234, 2027)
       AND NOT EXISTS (SELECT 1
                         FROM CECRED.tbcns_repique r
                        WHERE r.idlancto = craplau.idlancto)
     ORDER BY craplau.cdagenci
             ,craplau.cdbccxlt
             ,craplau.cdbccxpg
             ,craplau.cdhistor
             ,craplau.nrdocmto;
             
  CURSOR cr_crapcns(pr_cdcooper IN CECRED.crapcns.cdcooper%TYPE
                   ,pr_tpconsor IN CECRED.crapcns.tpconsor%TYPE
                   ,pr_nrdconta IN CECRED.crapcns.nrdconta%TYPE
                   ,pr_nrctrato IN CECRED.crapcns.nrctrato%TYPE) IS
      SELECT crapcns.nrctacns
        FROM CECRED.crapcns
       WHERE crapcns.cdcooper = pr_cdcooper
         AND crapcns.tpconsor = pr_tpconsor
         AND crapcns.nrdconta = pr_nrdconta
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
    
    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq_erro
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arq_erro
                                   ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq_erro;
       RAISE vr_exc_saida;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
    
    vr_dtrefere := TO_DATE('10/07/2023','DD/MM/RRRR');
      
    FOR rw_crapcop IN cr_crapcop LOOP
      FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
        IF NVL(rw_principal.nrcrcard,0) <> 0 THEN
          vr_nrdocmto := TO_CHAR(rw_principal.nrcrcard,'fm0000000000000000000000');
        ELSE
          vr_nrdocmto := TO_CHAR(rw_principal.nrdocmto,'fm0000000000000000000000');
        END IF;
        
        FOR rw_crapcns in cr_crapcns(rw_principal.cdcooper
                                    ,rw_principal.tpconsor
                                    ,rw_principal.nrdconta
                                    ,TO_NUMBER(SUBSTR(vr_nrdocmto,1,8))) LOOP      
          BEGIN
          INSERT INTO CECRED.tbcns_repique(cdcooper
                                          ,nrdconta
                                          ,nrdocmto
                                          ,cdhistor
                                          ,vllanaut
                                          ,cdsitlct
                                          ,dtmvtolt
                                          ,dtmvtopg
                                          ,dtdebito
                                          ,dtcancel
                                          ,cdopecan
                                          ,idlancto
                                          ,cdseqtel
                                          ,nrcrcard
                                          ,nrctacns
                                          ,cdcritic)
          VALUES(rw_principal.cdcooper
                ,rw_principal.nrdconta
                ,rw_principal.nrdocmto
                ,rw_principal.cdhistor
                ,rw_principal.vllanaut
                ,1
                ,vr_dtrefere
                ,vr_dtrefere
                ,NULL
                ,NULL
                ,NULL
                ,rw_principal.idlancto
                ,rw_principal.cdseqtel
                ,rw_principal.nrcrcard
                ,rw_crapcns.nrctacns
                ,vr_cdcritic) RETURNING idrepiqu INTO vr_idrepiqu;
          EXCEPTION WHEN OTHERS THEN
            vr_texto := ' Erro inserção. Coop: ' || rw_principal.cdcooper || ' Conta: ' || rw_principal.nrdconta || ' Nrdocmto: ' || rw_principal.nrdocmto || ' Erro: ' || SQLERRM;
            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq_erro, vr_texto);
            CONTINUE;
          END;      
                
          vr_texto := ' DELETE CECRED.tbcns_repique WHERE idrepiqu = ' || vr_idrepiqu || ';';
          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq, vr_texto);
              
          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;
      END LOOP;
      
      vcount := 0;
      COMMIT;
    END LOOP;
      
    COMMIT;
      
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq_erro);
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
