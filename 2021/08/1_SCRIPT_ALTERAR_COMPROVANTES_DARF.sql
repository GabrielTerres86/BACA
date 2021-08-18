declare
  vr_idsicredi varchar2(10);
  vr_tipo_pagamento VARCHAR2(10);
  vr_dscritic varchar2(4000);
  vr_dscomprovante crappro.dscomprovante_parceiro%TYPE;
  vr_linha_arq   VARCHAR2(4000);
  vr_handle_arq  utl_file.file_type;
  vr_contador_commit NUMBER(10) := 0;
  vr_nrdrowid  ROWID;
  vr_exc_erro EXCEPTION;

  CURSOR cr_registros_lft(pr_idsicredi IN tbconv_registro_remessa_pagfor.idsicredi%TYPE) IS
     SELECT TRIM(SUBSTR(UTL_ENCODE.TEXT_DECODE(PRO.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1), 1324, 48)) AUTENTICACAO,
            LFT.IDSICRED, 
            PRO.DSPROTOC,
            LFT.CDCOOPER,
            LFT.NRDCONTA,
            LFT.CDAGENCI,
            LFT.CDTRIBUT,
            LFT.NRREFERE,
            LFT.VLLANMTO,
            LFT.VLRJUROS,
            LFT.VLRMULTA,
            (LFT.VLLANMTO + LFT.VLRJUROS + LFT.VLRMULTA) VLRTOTAL,
            LFT.NRCPFCGC,
            LFT.DTAPURAC,
            LFT.DTLIMITE,
            REG.DHRETORNO_PROCESSAMENTO,
            LFT.DTMVTOLT
       FROM CRAPLFT LFT,
            TBCONV_REGISTRO_REMESSA_PAGFOR REG,
            CRAPPRO PRO
      WHERE lft.idsicred = pr_idsicredi
        AND pro.cdcooper = lft.cdcooper
        AND pro.nrdconta = lft.nrdconta
        AND pro.dtmvtolt = lft.dtmvtolt
        AND pro.cdtippro = 16
        AND pro.nrseqaut = lft.nrautdoc
        AND pro.dscomprovante_parceiro IS NOT NULL
        AND reg.idsicredi = lft.idsicred;
  rw_registros_lft cr_registros_lft%ROWTYPE;

BEGIN     
  
  gene0001.pc_abre_arquivo(pr_nmcaminh => '/usr/connect/tivit/TEMP_LISTA_PAGAMENTOS/DARF/1_LISTA_PAGAMENTOS_DARF.TXT',
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_handle_arq,
                           pr_des_erro => vr_dscritic);

  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);

      vr_linha_arq := CONVERT(vr_linha_arq,'US7ASCII','UTF8');
      vr_linha_arq := REPLACE(REPLACE(TRIM(vr_linha_arq),chr(13),''),chr(10),'');
      
      vr_idsicredi      := vr_linha_arq;      
        
      OPEN cr_registros_lft(pr_idsicredi => vr_idsicredi);
      FETCH cr_registros_lft INTO rw_registros_lft;
      CLOSE cr_registros_lft;
      
      -- Gerar o comprovante base64
      PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_registros_lft.cdcooper,
                                              pr_nrdconta  => rw_registros_lft.nrdconta,
                                              pr_cdagenci  => rw_registros_lft.cdagenci,
                                              pr_dtmvtolt  => rw_registros_lft.dtmvtolt,
                                              pr_cdempres  => 'A0',
                                              pr_cdagente  => 341,
                                              pr_dttransa  => rw_registros_lft.dhretorno_processamento,
                                              pr_hrtransa  => TO_NUMBER(TO_CHAR(rw_registros_lft.dhretorno_processamento,'sssss')),
                                              pr_dsprotoc  => rw_registros_lft.dsprotoc,
                                              pr_dsautent  => rw_registros_lft.autenticacao,
                                              pr_idsicred  => rw_registros_lft.idsicred,
                                              pr_nrsequen  => 0,
                                              pr_cdtribut  => rw_registros_lft.cdtribut,
                                              pr_nrrefere  => rw_registros_lft.nrrefere,
                                              pr_vllanmto  => rw_registros_lft.vllanmto,
                                              pr_vlrjuros  => rw_registros_lft.vlrjuros,
                                              pr_vlrmulta  => rw_registros_lft.vlrmulta,
                                              pr_vlrtotal  => rw_registros_lft.vlrtotal,
                                              pr_nrcpfcgc  => rw_registros_lft.nrcpfcgc,
                                              pr_dtapurac  => rw_registros_lft.dtapurac,
                                              pr_dtlimite  => rw_registros_lft.dtlimite,
                                              pr_cddpagto  => 0,
                                              pr_cdidenti2 => ' ',
                                              pr_mmaacomp  => 0,
                                              pr_vlrdinss  => 0,
                                              pr_vlrouent  => 0,
                                              pr_flgcaixa  => FALSE,
                                              pr_dscomprv  => vr_dscomprovante);
                                              
      -- Gravar o comprovante
      GENE0006.pc_grava_comprovante_parceiro (pr_cdcooper               => rw_registros_lft.cdcooper,
                                              pr_dsprotoc               => rw_registros_lft.dsprotoc,
                                              pr_dscomprovante_parceiro => vr_dscomprovante,
                                              pr_dscritic               => vr_dscritic);
                                                             
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;    
        
      GENE0006.pc_grava_arrecadador_parceiro (pr_cdcooper => rw_registros_lft.cdcooper,
                                              pr_nrdconta => rw_registros_lft.nrdconta,
                                              pr_dsprotoc => rw_registros_lft.dsprotoc,
                                              pr_cdagente => 341,
                                              pr_dscritic => vr_dscritic);    

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- LOG DA OPERAÇÃO
      gene0001.pc_gera_log(pr_cdcooper => rw_registros_lft.cdcooper
                          ,pr_cdoperad => 't0031357'
                          ,pr_dscritic => ''
                          ,pr_dsorigem => ''
                          ,pr_dstransa => 'Alteração no Comprovante: Alterado o Agente Arrecador de 093 - Polocred para 341 - Itaú'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => ''
                          ,pr_nrdconta => rw_registros_lft.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);  
                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'ID Transação(idsicredi)',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_registros_lft.idsicred);
                                  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Protocolo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_registros_lft.dsprotoc);
                                     
      vr_contador_commit := vr_contador_commit + 1;
      
      IF vr_contador_commit >= 10000 THEN
        vr_contador_commit := 0;
        COMMIT;
      END IF;
      
      dbms_output.put_line(rw_registros_lft.idsicred);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- LOG DA OPERAÇÃO
        gene0001.pc_gera_log(pr_cdcooper => rw_registros_lft.cdcooper
                            ,pr_cdoperad => 't0031357'
                            ,pr_dscritic => ''
                            ,pr_dsorigem => ''
                            ,pr_dstransa => 'Alteração no Comprovante: Alterado o Agente Arrecador de 093 - Polocred para 341 - Itaú'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ''
                            ,pr_nrdconta => rw_registros_lft.nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);  
                              
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'ID Transação(idsicredi)',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_registros_lft.idsicred);
                                    
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Protocolo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_registros_lft.dsprotoc);
      WHEN NO_DATA_FOUND THEN
        IF utl_file.IS_OPEN(vr_handle_arq) THEN
           GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
        END IF;
        COMMIT;
        EXIT;
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        IF utl_file.IS_OPEN(vr_handle_arq) THEN
           GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
        END IF;
        EXIT;
    END;
  END LOOP;

END;
