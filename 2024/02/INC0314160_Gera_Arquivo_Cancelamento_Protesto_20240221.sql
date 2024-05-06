DECLARE

  vr_dtreferencia DATE := to_date('17102023', 'ddmmyyyy');

  vr_nmprograma VARCHAR2(50) := 'INC0314160';

  TYPE typ_reg_linha IS RECORD(
     ds_registro VARCHAR2(600)
    ,cdcooper    crapcop.cdcooper%TYPE
    ,ds_rowid    VARCHAR2(400));
  TYPE typ_tab_arquivo IS TABLE OF typ_reg_linha INDEX BY PLS_INTEGER;
  vr_tab_arquivo typ_tab_arquivo;
  TYPE typ_tab_itemlog IS TABLE OF tbcobran_log_item_arq_ieptb%ROWTYPE INDEX BY BINARY_INTEGER;
  vr_tab_itemlog typ_tab_itemlog;
  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
  vr_dtmvutil    DATE := vr_dtreferencia;

  PROCEDURE pc_controla_log_batch(pr_idtiplog IN NUMBER
                                 ,pr_dscritic IN VARCHAR2) IS
    vr_dstiplog VARCHAR2(10);
  BEGIN
    IF pr_idtiplog = 2 THEN
      vr_dstiplog := 'ERRO: ';
    ELSE
      vr_dstiplog := 'ALERTA: ';
    END IF;
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => pr_idtiplog
                              ,pr_cdprograma   => vr_nmprograma
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED', 3, 'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_nmprograma || ' --> ' ||
                                                  vr_dstiplog || pr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3);
  END pc_controla_log_batch;

  PROCEDURE pc_gera_cancelamento_ieptb(pr_dscritic OUT VARCHAR2) IS
    CURSOR cr_craprem(pr_dtmvtolt IN DATE) IS
      SELECT lpad(crapcob.cdbandoc, 3, '0') cdbandoc
            ,rpad(crapban.nmresbcc, 40, ' ') nmresbcc
            ,to_char(crapdat.dtmvtolt, 'DDMMYYYY') dtmvtolt
            ,lpad(tbcobran_retorno_ieptb.cdcartorio, 2, '0') cdcartor
            ,lpad(tbcobran_retorno_ieptb.cdcomarc, 7, '0') cdcomarc
            ,lpad(tbcobran_retorno_ieptb.nrprotoc_cartorio, 10, '0') nrprotoc
            ,to_char(tbcobran_retorno_ieptb.dtprotocolo, 'DDMMYYYY') dtprotoc
            ,lpad(crapcob.nrdocmto, 11, '0') nrdocmto
            ,rpad(UPPER(GENE0007.fn_caract_especial(crapsab.nmdsacad)), 45, ' ') nmdsacad
            ,lpad(TRUNC(crapcob.vltitulo * 100), 14, '0') vltitulo
            ,lpad(crapcop.cdagectl, 4, '0') || lpad(crapcob.nrdconta, 8, '0') nrdconta
            ,lpad(crapcob.nrnosnum, 12, '0') nrnosnum
            ,crapcob.rowid
            ,crapcob.cdcooper cdcoplog
            ,crapcob.cdbandoc cdbanlog
            ,crapcob.nrdctabb nrcbblog
            ,crapcob.nrcnvcob nrcnvlog
            ,crapcob.nrdconta nrctalog
            ,crapcob.nrdocmto nrdoclog
            ,crapcob.vltitulo vltitlog
        FROM craprem
            ,crapcob
            ,crapdat
            ,crapban
            ,crapcop
            ,crapsab
            ,tbcobran_retorno_ieptb
            ,crapcco
            ,crapcre
       WHERE crapcco.cdcooper > 0
         AND crapcco.cddbanco = 85
         AND crapcre.cdcooper = crapcco.cdcooper
         AND crapcre.nrcnvcob = crapcco.nrconven
         AND crapcre.dtmvtolt = pr_dtmvtolt
         AND crapcre.intipmvt = 1
         AND craprem.cdcooper = crapcre.cdcooper
         AND craprem.nrcnvcob = crapcre.nrcnvcob
         AND craprem.nrremret = crapcre.nrremret
         AND craprem.cdcooper = crapcob.cdcooper
         AND craprem.nrcnvcob = crapcob.nrcnvcob
         AND craprem.nrdconta = crapcob.nrdconta
         AND craprem.nrdocmto = crapcob.nrdocmto
         AND crapdat.cdcooper = crapcob.cdcooper
         AND crapban.cdbccxlt = crapcob.cdbandoc
         AND crapcop.cdcooper = crapcob.cdcooper
         AND crapsab.cdcooper = crapcob.cdcooper
         AND crapsab.nrdconta = crapcob.nrdconta
         AND crapsab.nrinssac = crapcob.nrinssac
         AND tbcobran_retorno_ieptb.cdcooper = craprem.cdcooper
         AND tbcobran_retorno_ieptb.nrdconta = craprem.nrdconta
         AND tbcobran_retorno_ieptb.nrcnvcob = craprem.nrcnvcob
         AND tbcobran_retorno_ieptb.nrdocmto = craprem.nrdocmto
         AND crapcob.cdbandoc = 85
         AND crapcob.insrvprt = 1
         AND craprem.cdocorre IN (81)
       ORDER BY tbcobran_retorno_ieptb.cdcomarc
               ,tbcobran_retorno_ieptb.cdcartorio;
  
    rw_craprem cr_craprem%ROWTYPE;
  
    vr_arq_xml CLOB;
  
    vr_cdcomarc tbcobran_confirmacao_ieptb.cdcomarc%TYPE;
    vr_cdcartor tbcobran_confirmacao_ieptb.cdcartorio%TYPE;
    vr_qtregist NUMBER;
    vr_qtcartor NUMBER;
    vr_qtnumarq NUMBER;
    vr_dsdlinha VARCHAR2(600);
    vr_qtregtra NUMBER;
    vr_vlsomseg NUMBER;
    vr_idgercab BOOLEAN;
    vr_arquivo  CLOB;
  
    vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
    vr_nmarqtxt   VARCHAR2(13);
    vr_nmdirtxt   VARCHAR2(400);
  
    vr_idlogarq tbcobran_log_arquivo_ieptb.idlog_arquivo%TYPE;
    vr_dscrilog VARCHAR2(1000);
  
    vr_exc_erro EXCEPTION;
  
  BEGIN
    pc_controla_log_batch(1, 'Início ' || vr_nmprograma);
    vr_qtregist := 1;
    vr_qtcartor := 1;
    vr_qtnumarq := 0;
    vr_vlsomseg := 0;
    vr_idgercab := TRUE;
  
    vr_tab_arquivo.delete;
    vr_tab_itemlog.delete;
  
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    OPEN cr_craprem(pr_dtmvtolt => vr_dtreferencia);
  
    LOOP
    
      FETCH cr_craprem
        INTO rw_craprem;
      EXIT WHEN cr_craprem%NOTFOUND;
    
      IF vr_qtregist = 1 THEN
        vr_arquivo := htf.escape_sc('<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?><cancelamento>');
      END IF;
      IF nvl(vr_cdcomarc, '0') <> rw_craprem.cdcomarc THEN
        IF vr_qtregist > 1 THEN
          vr_arquivo := vr_arquivo || htf.escape_sc('</cartorio></comarca>');
        END IF;
        vr_arquivo  := vr_arquivo || htf.escape_sc('<comarca><CodMun>' || TRIM(rw_craprem.cdcomarc) || '</CodMun>');
        vr_cdcomarc := rw_craprem.cdcomarc;
        vr_qtcartor := 1;
        vr_cdcartor := 0;
      END IF;
      IF nvl(vr_cdcartor, 0) <> to_number(rw_craprem.cdcartor) THEN
        IF vr_qtcartor > 1 THEN
          vr_arquivo := vr_arquivo || htf.escape_sc('</cartorio>');
        END IF;
        vr_arquivo  := vr_arquivo ||
                       htf.escape_sc('<cartorio><numero_cartorio>' || TRIM(rw_craprem.cdcartor) || '</numero_cartorio>');
        vr_cdcartor := rw_craprem.cdcartor;
        vr_qtcartor := vr_qtcartor + 1;
      END IF;
      vr_arquivo := vr_arquivo || htf.escape_sc('<titulo>');
      vr_arquivo := vr_arquivo || htf.escape_sc('<numero_protocolo>' || TRIM(rw_craprem.nrprotoc) || '</numero_protocolo>');
      vr_arquivo := vr_arquivo || htf.escape_sc('<data_protocolo>' || TRIM(rw_craprem.dtprotoc) || '</data_protocolo>');
      vr_arquivo := vr_arquivo || htf.escape_sc('<numero_titulo>' || TRIM(rw_craprem.nrdocmto) || '</numero_titulo>');
      vr_arquivo := vr_arquivo || htf.escape_sc('<nome_devedor>' || TRIM(rw_craprem.nmdsacad) || '</nome_devedor>');
      vr_arquivo := vr_arquivo || htf.escape_sc('<valor_titulo>' || TRIM(rw_craprem.vltitulo) || '</valor_titulo>');
      vr_arquivo := vr_arquivo || htf.escape_sc('</titulo>');
      vr_qtregist := vr_qtregist + 1;
      vr_tab_itemlog(vr_tab_itemlog.count() + 1).cdcooper := rw_craprem.cdcoplog;
      vr_tab_itemlog(vr_tab_itemlog.count()).cdbandoc := rw_craprem.cdbanlog;
      vr_tab_itemlog(vr_tab_itemlog.count()).nrdctabb := rw_craprem.nrcbblog;
      vr_tab_itemlog(vr_tab_itemlog.count()).nrcnvcob := rw_craprem.nrcnvlog;
      vr_tab_itemlog(vr_tab_itemlog.count()).nrdconta := rw_craprem.nrctalog;
      vr_tab_itemlog(vr_tab_itemlog.count()).nrdocmto := rw_craprem.nrdoclog;
      vr_tab_itemlog(vr_tab_itemlog.count()).vltitulo := rw_craprem.vltitlog;
    
    END LOOP;
    CLOSE cr_craprem;
  
    IF vr_qtregist > 1 THEN
      vr_arquivo := vr_arquivo || htf.escape_sc('</cartorio></comarca></cancelamento>');
    
      vr_dtmvtolt := rw_crapdat.dtmvtocd;
    
      vr_nmarqtxt := cobr0011.fn_gera_nome_arq_cancelamento(pr_cdbandoc => '85', pr_dtmvtolt => vr_dtmvutil);
    
      vr_arquivo := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:protesto_brIntf-Iprotesto_br">' ||
                    '<soapenv:Header/>' || '<soapenv:Body>' ||
                    '<urn:Cancelamento soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' ||
                    '<user_arq xsi:type="xsd:string">' || vr_nmarqtxt || '</user_arq>' ||
                    '<user_dados xsi:type="xsd:string">' || vr_arquivo || '</user_dados>' || '</urn:Cancelamento>' ||
                    '</soapenv:Body>' || '</soapenv:Envelope>';
    
      vr_nmdirtxt := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 3, pr_cdacesso => 'DIR_IEPTB_REMESSA');
    
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_arquivo
                                   ,pr_caminho  => vr_nmdirtxt
                                   ,pr_arquivo  => vr_nmarqtxt
                                   ,pr_des_erro => pr_dscritic);

      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      pc_controla_log_batch(1
                           ,to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || vr_nmprograma ||
                            '  --> Finalizado o processamento dos cancelamentos.');
    
      COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                               ,pr_dtarquiv => vr_dtmvtolt
                               ,pr_qtregarq => vr_tab_itemlog.count()
                               ,pr_idfrmprc => 2
                               ,pr_cdoperad => '1'
                               ,pr_idlogarq => vr_idlogarq
                               ,pr_cdsituac => 1
                               ,pr_dscritic => vr_dscrilog);
    
      IF vr_dscrilog IS NOT NULL THEN
        pc_controla_log_batch(2
                             ,to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || vr_nmprograma || ' --> Erro ao gravar log:' ||
                              vr_dscrilog);
      ELSE
        IF vr_tab_itemlog.count > 0 THEN
          FOR ind IN vr_tab_itemlog.FIRST .. vr_tab_itemlog.LAST
          LOOP
          
            COBR0011.pc_gera_log_item_iptb(pr_idlogarq => vr_idlogarq
                                          ,pr_cdcooper => vr_tab_itemlog(ind).cdcooper
                                          ,pr_cdbandoc => vr_tab_itemlog(ind).cdbandoc
                                          ,pr_nrdctabb => vr_tab_itemlog(ind).nrdctabb
                                          ,pr_nrcnvcob => vr_tab_itemlog(ind).nrcnvcob
                                          ,pr_nrdconta => vr_tab_itemlog(ind).nrdconta
                                          ,pr_nrdocmto => vr_tab_itemlog(ind).nrdocmto
                                          ,pr_vltitulo => vr_tab_itemlog(ind).vltitulo
                                          ,pr_dscritic => vr_dscrilog);
          
            IF vr_dscrilog IS NOT NULL THEN
              pc_controla_log_batch(2
                                   ,to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || vr_nmprograma ||
                                    ' --> Erro ao gravar item do log:' || vr_dscrilog);
            
              vr_dscrilog := NULL;
            END IF;
          
          END LOOP;
        END IF;
      END IF;
    
    END IF;
  
    ROLLBACK;
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_nmarqtxt IS NOT NULL THEN
        COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                 ,pr_dtarquiv => vr_dtmvtolt
                                 ,pr_qtregarq => 0
                                 ,pr_idfrmprc => 2
                                 ,pr_cdoperad => '1'
                                 ,pr_dserrarq => 'Erro ao gerar arquivo cancelamento: ' || pr_dscritic
                                 ,pr_cdsituac => 2
                                 ,pr_idlogarq => vr_idlogarq
                                 ,pr_dscritic => vr_dscrilog);
      
        IF vr_dscrilog IS NOT NULL THEN
          pc_controla_log_batch(2
                               ,to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || vr_nmprograma || ' --> Erro ao gravar log:' ||
                                vr_dscrilog);
        END IF;
      
      END IF;
      ROLLBACK;
    
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      pr_dscritic := SQLERRM;
    
      IF vr_nmarqtxt IS NOT NULL THEN
        COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                 ,pr_dtarquiv => vr_dtmvtolt
                                 ,pr_qtregarq => 0
                                 ,pr_idfrmprc => 2
                                 ,pr_cdoperad => '1'
                                 ,pr_dserrarq => 'Erro ao gerar arquivo cancelamento: ' || pr_dscritic
                                 ,pr_cdsituac => 2
                                 ,pr_idlogarq => vr_idlogarq
                                 ,pr_dscritic => vr_dscrilog);
      
        IF vr_dscrilog IS NOT NULL THEN
          pc_controla_log_batch(2
                               ,to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || vr_nmprograma || ' --> Erro ao gravar log:' ||
                                vr_dscrilog);
        END IF;
      
      END IF;
      ROLLBACK;
    
  END pc_gera_cancelamento_ieptb;

BEGIN

  DECLARE
  
    vr_dscritic VARCHAR2(32000);
  
  BEGIN
  
    pc_gera_cancelamento_ieptb(vr_dscritic);
  
    dbms_output.put_line(vr_dscritic);
  
  END;

END;
