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
  
  CURSOR cr_registros_lgp(pr_idsicredi IN tbconv_registro_remessa_pagfor.idsicredi%TYPE) IS
    SELECT TRIM(SUBSTR(UTL_ENCODE.TEXT_DECODE(PRO.DSCOMPROVANTE_PARCEIRO, 'WE8ISO8859P1', 1), 1226, 48)) AUTENTICACAO,
           LGP.IDSICRED, 
           PRO.DSPROTOC,
           LGP.CDCOOPER,
           LGP.NRCTAPAG,
           LGP.CDAGENCI,
           LGP.CDDPAGTO,
           LGP.VLRJUROS,
           LGP.VLRDINSS,
           LGP.VLROUENT,
           LGP.VLRTOTAL,
           REG.DHRETORNO_PROCESSAMENTO,
           LGP.MMAACOMP,
           LGP.DTMVTOLT,
           LGP.CDIDENTI2
      FROM CRAPLGP LGP,
           TBCONV_REGISTRO_REMESSA_PAGFOR REG,
           CRAPPRO PRO
     WHERE lgp.idsicred = pr_idsicredi
       AND pro.cdcooper = lgp.cdcooper
       AND pro.nrdconta = lgp.nrctapag
       AND pro.dtmvtolt = lgp.dtmvtolt
       AND pro.cdtippro = 13
       AND pro.nrseqaut = lgp.nrautdoc
       AND pro.dscomprovante_parceiro IS NOT NULL
       AND reg.idsicredi = lgp.idsicred;
  rw_registros_lgp cr_registros_lgp%ROWTYPE;

BEGIN     
  
  gene0001.pc_abre_arquivo(pr_nmcaminh => '/usr/connect/tivit/TEMP_LISTA_PAGAMENTOS/GPS/3_LISTA_PAGAMENTOS_GPS.TXT',
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_handle_arq,
                           pr_des_erro => vr_dscritic);

  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);

      vr_linha_arq := CONVERT(vr_linha_arq,'US7ASCII','UTF8');
      vr_linha_arq := REPLACE(REPLACE(TRIM(vr_linha_arq),chr(13),''),chr(10),'');
      
      vr_idsicredi      := vr_linha_arq;
        
      OPEN cr_registros_lgp(pr_idsicredi => vr_idsicredi);
      FETCH cr_registros_lgp INTO rw_registros_lgp;
      CLOSE cr_registros_lgp;
        
      PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_registros_lgp.cdcooper,
                                              pr_nrdconta  => rw_registros_lgp.nrctapag,
                                              pr_cdagenci  => rw_registros_lgp.cdagenci,
                                              pr_dtmvtolt  => rw_registros_lgp.dtmvtolt,
                                              pr_cdempres  => 'C06',
                                              pr_cdagente  => 341,
                                              pr_dttransa  => rw_registros_lgp.dhretorno_processamento,
                                              pr_hrtransa  => TO_NUMBER(TO_CHAR(rw_registros_lgp.dhretorno_processamento,'sssss')),
                                              pr_dsprotoc  => rw_registros_lgp.dsprotoc,
                                              pr_dsautent  => rw_registros_lgp.autenticacao,
                                              pr_idsicred  => vr_idsicredi,
                                              pr_nrsequen  => 0,
                                              pr_cdtribut  => ' ',
                                              pr_nrrefere  => ' ',
                                              pr_vllanmto  => 0,
                                              pr_vlrjuros  => rw_registros_lgp.vlrjuros,
                                              pr_vlrmulta  => 0,
                                              pr_vlrtotal  => rw_registros_lgp.vlrtotal,
                                              pr_nrcpfcgc  => ' ',
                                              pr_dtapurac  => NULL,
                                              pr_dtlimite  => NULL,
                                              pr_cddpagto  => rw_registros_lgp.cddpagto,
                                              pr_cdidenti2 => rw_registros_lgp.cdidenti2,
                                              pr_mmaacomp  => rw_registros_lgp.mmaacomp,
                                              pr_vlrdinss  => rw_registros_lgp.vlrdinss,
                                              pr_vlrouent  => rw_registros_lgp.vlrouent,
                                              pr_flgcaixa  => FALSE,
                                              pr_dscomprv  => vr_dscomprovante);                                          
      -- Gravar o comprovante
      GENE0006.pc_grava_comprovante_parceiro (pr_cdcooper               => rw_registros_lgp.cdcooper,
                                              pr_dsprotoc               => rw_registros_lgp.dsprotoc,
                                              pr_dscomprovante_parceiro => vr_dscomprovante,
                                              pr_dscritic               => vr_dscritic);
                                                             
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      GENE0006.pc_grava_arrecadador_parceiro (pr_cdcooper => rw_registros_lgp.cdcooper,
                                              pr_nrdconta => rw_registros_lgp.nrctapag,
                                              pr_dsprotoc => rw_registros_lgp.dsprotoc,
                                              pr_cdagente => 341,
                                              pr_dscritic => vr_dscritic);    
                                                
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- LOG DA OPERAÇÃO
      gene0001.pc_gera_log(pr_cdcooper => rw_registros_lgp.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => ''
                          ,pr_dsorigem => ''
                          ,pr_dstransa => 'Alteração no Comprovante: Alterado o Agente Arrecador de 093 - Polocred para 341 - Itaú'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => ''
                          ,pr_nrdconta => rw_registros_lgp.nrctapag
                          ,pr_nrdrowid => vr_nrdrowid);  
                            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'ID Transação(idsicredi)',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_registros_lgp.idsicred);
                                  
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'Protocolo',
                                pr_dsdadant => ' ',
                                pr_dsdadatu => rw_registros_lgp.dsprotoc);
                                     
      vr_contador_commit := vr_contador_commit + 1;
      
      IF vr_contador_commit >= 10000 THEN
        vr_contador_commit := 0;
        COMMIT;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- LOG DA OPERAÇÃO
        gene0001.pc_gera_log(pr_cdcooper => rw_registros_lgp.cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => ''
                            ,pr_dsorigem => ''
                            ,pr_dstransa => 'Alteração no Comprovante: Alterado o Agente Arrecador de 093 - Polocred para 341 - Itaú'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ''
                            ,pr_nrdconta => rw_registros_lgp.nrctapag
                            ,pr_nrdrowid => vr_nrdrowid);  
                              
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'ID Transação(idsicredi)',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_registros_lgp.idsicred);
                                    
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Protocolo',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => rw_registros_lgp.dsprotoc);
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
