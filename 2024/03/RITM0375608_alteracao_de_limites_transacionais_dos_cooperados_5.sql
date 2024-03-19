DECLARE 
  vr_cdcooper  VARCHAR2(30);
  vr_nrdconta  VARCHAR2(30);
  vr_idseqttl  VARCHAR2(30);
  vr_vllimweb  VARCHAR2(30);

  vr_limwebrowid ROWID;
  vr_nrdrowid    ROWID;
  vr_dsdadant    craplgi.dsdadant%TYPE;
  vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;
  vr_nmprograma  tbgen_prglog.cdprograma%TYPE := 'Alterar Limite Web - RITM0375608';
  
  vr_utlfileh  UTL_FILE.file_type;
  vr_dsdlinha  VARCHAR2(4000);
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  crapcri.dscritic%TYPE;
  vr_exc_arq   EXCEPTION;
  vr_pos       PLS_INTEGER;
  vr_idx       PLS_INTEGER;
  vr_qtlinhas  PLS_INTEGER := 0;
  vr_dsdireto  VARCHAR2(50) := '/micros/cpd/bacas/RITM0375608';
  vr_nmarquivo VARCHAR(200) := 'alteracao_limite_web.csv';
  
BEGIN
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                 ,pr_nmarquiv => vr_nmarquivo
                                 ,pr_tipabert => 'R'
                                 ,pr_utlfileh => vr_utlfileh
                                 ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_arq;
  END IF;
  
  IF utl_file.IS_OPEN(vr_utlfileh) THEN
    BEGIN
      LOOP
        vr_dsdlinha := NULL;
        vr_qtlinhas := vr_qtlinhas + 1;
        
        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                           ,pr_des_text => vr_dsdlinha);
        vr_cdcooper := NULL;
        vr_nrdconta := NULL;
        vr_idseqttl := NULL;
        vr_vllimweb := NULL;
        
        FOR vr_idx IN 1 .. LENGTH(vr_dsdlinha) LOOP
          IF SUBSTR(vr_dsdlinha, vr_idx, 1) = ';' THEN
            IF vr_cdcooper IS NULL THEN
              vr_cdcooper := SUBSTR(vr_dsdlinha, 1, vr_idx - 1);
              vr_pos := vr_idx + 1;
            ELSE
              IF vr_nrdconta IS NULL THEN
                vr_nrdconta := SUBSTR(vr_dsdlinha, vr_pos, vr_idx - vr_pos);
                vr_pos := vr_idx + 1;
              ELSE
                IF vr_idseqttl IS NULL THEN
                  vr_idseqttl := SUBSTR(vr_dsdlinha, vr_pos, vr_idx - vr_pos);
                  vr_pos := vr_idx;
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
        
        vr_vllimweb := SUBSTR(vr_dsdlinha, vr_pos + 1, LENGTH(vr_dsdlinha) - vr_pos);
        
        BEGIN 
          SELECT snh.ROWID
                ,snh.vllimweb
            INTO vr_limwebrowid
                ,vr_dsdadant
            FROM crapsnh snh
           WHERE snh.cdcooper = vr_cdcooper
             AND snh.nrdconta = vr_nrdconta
             AND snh.idseqttl = vr_idseqttl
             AND snh.tpdsenha = 1;
             
          UPDATE crapsnh snh
             SET snh.vllimweb = vr_vllimweb
           WHERE snh.ROWID = vr_limwebrowid;
           
          IF vr_qtlinhas = 1000 THEN
            COMMIT;
            vr_qtlinhas := 0;
          END IF;
          
          CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => vr_nrdconta
                                     ,pr_idseqttl => vr_idseqttl
                                     ,pr_cdoperad => 't0035324'
                                     ,pr_dscritic => 'Registro alterado com sucesso.'
                                     ,pr_dsorigem => 'AIMARO'
                                     ,pr_dstransa => vr_nmprograma
                                     ,pr_dttransa => TRUNC(SYSDATE)
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                     ,pr_nmdatela => 'SCRIPT ADHOC'
                                     ,pr_nrdrowid => vr_nrdrowid);
                
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'crapsnh.vllimweb'
                                          ,pr_dsdadant => vr_dsdadant
                                          ,pr_dsdadatu => vr_vllimweb);             
        EXCEPTION     
          WHEN NO_DATA_FOUND THEN
            CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_idseqttl => vr_idseqttl
                                       ,pr_cdoperad => 't0035324'
                                       ,pr_dscritic => 'Sem informacoes do Limite Web atual'
                                       ,pr_dsorigem => 'AIMARO'
                                       ,pr_dstransa => vr_nmprograma
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 0
                                       ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                       ,pr_nmdatela => 'SCRIPT ADHOC'
                                       ,pr_nrdrowid => vr_nrdrowid);
         WHEN OTHERS THEN
           ROLLBACK;
           CECRED.pc_internal_exception(pr_cdcooper => 3
                                       ,pr_compleme => ' Script: => ' || vr_nmprograma     ||
                                                       ' Etapa: 3 - Atualizar limite Web ' ||
                                                       ' cdcooper:'   || vr_cdcooper       ||
                                                       ';nrdconta:'   || vr_nrdconta       ||
                                                       ';idseqttl:'   || vr_idseqttl       ||
                                                       ';vllimweb:'   || vr_vllimweb);
        END;
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
       WHEN OTHERS THEN
        ROLLBACK;
        CECRED.pc_internal_exception(pr_cdcooper => 3
                                    ,pr_compleme => ' Script: => ' || vr_nmprograma   ||
                                                    ' Etapa: 2 - Leitura do Arquivo ' ||
                                                    ' cdcooper:'   || vr_cdcooper     ||
                                                    ';nrdconta:'   || vr_nrdconta     ||
                                                    ';idseqttl:'   || vr_idseqttl     ||
                                                    ';vllimweb:'   || vr_vllimweb);
    END;
  END IF;
  COMMIT;
EXCEPTION 
  WHEN vr_exc_arq THEN
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_cdprograma    => vr_nmprograma
                          ,pr_cdcooper      => 3 
                          ,pr_tpexecucao    => 0
                          ,pr_tpocorrencia  => 1
                          ,pr_cdcriticidade => 1
                          ,pr_cdmensagem    => 1053
                          ,pr_dsmensagem    => vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
                          
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
  WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 3
                                ,pr_compleme => ' Script: => ' || vr_nmprograma    ||
                                                ' Etapa: 1 - Abertura do Arquivo ' ||
                                                ' cdcooper:'   || vr_cdcooper      ||
                                                ';nrdconta:'   || vr_nrdconta      ||
                                                ';idseqttl:'   || vr_idseqttl      ||
                                                ';vllimweb:'   || vr_vllimweb);
                                                
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);                              
END;
