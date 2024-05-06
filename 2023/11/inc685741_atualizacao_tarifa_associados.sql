DECLARE 
  vr_vltarass          CECRED.crapret.vltarass%TYPE := 0;
  vr_progress_recid    VARCHAR2(30);
  vr_nrdrowid          ROWID;
  vr_dsdadant          CECRED.craplgi.dsdadant%TYPE;
  vr_idprglog          tbgen_prglog.idprglog%TYPE := 0;
  vr_nmprograma        tbgen_prglog.cdprograma%TYPE := 'Alterar Tarifa Associados - INC685741';
  vr_utlfileh          UTL_FILE.file_type;
  vr_dsdlinha          VARCHAR2(4000);
  vr_cdcritic          crapcri.cdcritic%TYPE;
  vr_dscritic          crapcri.dscritic%TYPE;
  vr_exc_arq           EXCEPTION;
  vr_pos               PLS_INTEGER;
  vr_idx               PLS_INTEGER;
  vr_dsdireto          VARCHAR2(50) := '/micros/cpd/bacas/INC685741';
  vr_nmarquivo         VARCHAR(200) := 'alteracao_tarifa_associado.csv';
  
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
        
        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                           ,pr_des_text => vr_dsdlinha);
                                           
        vr_progress_recid   := NULL;
        vr_dsdadant         := NULL;

        FOR vr_idx IN 1 .. LENGTH(vr_dsdlinha) LOOP
          IF SUBSTR(vr_dsdlinha, vr_idx, 1) = ';' THEN
            IF vr_progress_recid IS NULL THEN
              vr_progress_recid := SUBSTR(vr_dsdlinha, 1, vr_idx - 1);
              vr_pos := vr_idx + 1;
            END IF;
          END IF;
        END LOOP;
        
        vr_dsdadant := SUBSTR(vr_dsdlinha, vr_pos, LENGTH(vr_dsdlinha) - vr_pos);
        
        BEGIN 
          UPDATE CECRED.crapret ret
             SET ret.vltarass = vr_vltarass
           WHERE ret.progress_recid = vr_progress_recid;
           
          CECRED.GENE0001.pc_gera_log(pr_cdcooper => 0
                                     ,pr_nrdconta => vr_progress_recid
                                     ,pr_idseqttl => 0
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
                                          ,pr_nmdcampo => 'crapret.vltarass'
                                          ,pr_dsdadant => vr_dsdadant
                                          ,pr_dsdadatu => vr_vltarass);
                                          
          COMMIT;             
        EXCEPTION     
         WHEN OTHERS THEN
           ROLLBACK;
           CECRED.pc_internal_exception(pr_cdcooper => 0
                                       ,pr_compleme => ' Script: => ' || vr_nmprograma         ||
                                                       ' Etapa: 3 - Update Tarifa Associado '  ||
                                                       ' progress_recid:' || vr_progress_recid ||
                                                       ';vltarass:'       || vr_vltarass);
        END;
      END LOOP;
    EXCEPTION
       WHEN OTHERS THEN
        ROLLBACK;
        CECRED.pc_internal_exception(pr_cdcooper => 0
                                    ,pr_compleme => ' Script: => ' || vr_nmprograma   ||
                                                    ' Etapa: 2 - Leitura do Arquivo ');
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
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Script: => ' || vr_nmprograma    ||
                                                ' Etapa: 1 - Abertura do Arquivo');
                                                
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);                              
END;
