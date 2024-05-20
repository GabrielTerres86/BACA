declare 
  vr_cdcooper  VARCHAR2(30);
  vr_nrdconta  VARCHAR2(30);
  vr_idseqttl  VARCHAR2(30);
  vr_cdpacote  INTEGER;
  vr_clobxmlc CLOB;
  rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
  vr_exc_saida EXCEPTION;
  

  vr_limwebrowid ROWID;
  vr_nrdrowid    ROWID;
  vr_dsdadant    craplgi.dsdadant%TYPE;
  vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;
  vr_nmprograma  tbgen_prglog.cdprograma%TYPE := 'Adesão pacote em massa RS - RITM0391033';
  
  vr_utlfileh  UTL_FILE.file_type;
  vr_dsdlinha  VARCHAR2(4000);
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  crapcri.dscritic%TYPE;
  vr_exc_arq   EXCEPTION;
  vr_pos       PLS_INTEGER;
  vr_idx       PLS_INTEGER;
  vr_tab_linhacsv  cecred.gene0002.typ_split;
  vr_qtlinhas  PLS_INTEGER := 0;
  vr_dsdireto  VARCHAR2(50) := '/micros/cpd/bacas/RITM0391033';
  vr_nmarquivo VARCHAR(200) := 'TranspocredPF.csv';
begin

  vr_cdcooper := 9;
  vr_cdpacote := 241;
  
  OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                 ,pr_nmarquiv => vr_nmarquivo
                                 ,pr_tipabert => 'R'
                                 ,pr_utlfileh => vr_utlfileh
                                 ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_arq;
  END IF;
  
  IF utl_file.is_open(vr_utlfileh) THEN
    LOOP
      vr_nrdconta := 0;
      
      CECRED.Gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                          ,pr_des_text => vr_dsdlinha);

      IF length(vr_dsdlinha) <= 1 THEN
       continue;
      END IF;
      
      vr_tab_linhacsv := cecred.gene0002.fn_quebra_string(vr_dsdlinha, ',');
      vr_nrdconta := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(1));     
      
      INSERT INTO tbtarif_contas_pacote (cdcooper
                                        ,nrdconta
                                        ,cdpacote
                                        ,dtadesao
                                        ,dtinicio_vigencia
                                        ,nrdiadebito
                                        ,indorigem
                                        ,flgsituacao
                                        ,cdoperador_adesao)
                                 VALUES (vr_cdcooper
                                        ,vr_nrdconta
                                        ,vr_cdpacote
                                        ,rw_crapdat.dtmvtolt
                                        ,(rw_crapdat.dtmvtolt + 1)
                                        ,5
                                        ,1
                                        ,1
                                        ,'F0033201');
                 
        
    END LOOP;
  

  END IF;
 EXCEPTION
      WHEN NO_DATA_FOUND THEN
        COMMIT;
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
       WHEN OTHERS THEN
        ROLLBACK;
        CECRED.pc_internal_exception(pr_cdcooper => 3
                                    ,pr_compleme => ' Script: => ' || vr_nmprograma   ||
                                                    ' Etapa: 2 - Leitura do Arquivo ' ||
                                                    ' cdcooper:'   || vr_cdcooper     ||
                                                    ';nrdconta:'   || vr_nrdconta     ||
                                                    ';idseqttl:'   || vr_idseqttl     ||
                                                    ';pacote:'   || vr_cdpacote);


END;
