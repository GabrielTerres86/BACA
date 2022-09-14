  DECLARE
    -- Dados XML
    CURSOR cr_consulta_benefic_cip(pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE) IS
      SELECT npc.dsxml,
             npc.dscodbar
        FROM CECRED.tbcobran_consulta_titulo npc
       WHERE npc.cdctrlcs = pr_cdctrlcs;
    rw_consulta_benefic_cip cr_consulta_benefic_cip%ROWTYPE;

    -- Títulos
    CURSOR cr_consulta_tit(pr_cdcooper IN NUMBER,
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                           pr_nrdconta IN craptit.nrdconta%TYPE,
                           pr_vllanmto IN craplcm.vllanmto%TYPE) IS
    SELECT tit.cdctrlcs
      FROM CECRED.craptit tit,
           CECRED.crapass ass
     WHERE tit.cdcooper = pr_cdcooper
       AND tit.dtmvtolt = pr_dtmvtolt
       AND tit.nrdconta = pr_nrdconta
       AND tit.vltitulo = pr_vllanmto
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;       
    rw_consulta_tit cr_consulta_tit%ROWTYPE;
    
    CURSOR cr_cop(pr_nmcooper IN VARCHAR2) IS
    SELECT cop.cdcooper
      FROM CECRED.crapcop cop
     WHERE cop.nmrescop = pr_nmcooper; 
    rw_cop cr_cop%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
    vr_nmarquiv VARCHAR(200) := 'listaPagtosBoletosFraude.csv';
    
    vr_exc_erro EXCEPTION;
    vr_utlfileh UTL_FILE.file_type;
    vr_dsdlinha VARCHAR2(4000);
    vr_cooper   VARCHAR2(20);
    vr_nrdcta   VARCHAR2(20);
    vr_datmov   VARCHAR2(20);
    vr_vlrpag   VARCHAR2(20); 
    vr_tbtitulo NPCB0001.typ_reg_TituloCIP;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);
    vr_exc_sai  EXCEPTION;
    vr_dsdireto VARCHAR2(50);
    vr_nrcpfCnpjBen VARCHAR2(20);
    vr_tpcpfCnpjBen VARCHAR2(1);
    vr_des_tit VARCHAR2(500);
    vr_xmltitulo XMLTYPE;    
    vr_pos NUMBER;
    i NUMBER;
    vr_cdcritic VARCHAR2(500);
    pr_dscritic VARCHAR2(500);
  BEGIN

    vr_dsdireto := '/micros/cecred/cpd/bacas/RITM0246488';

    -- Abre pagamentos da planilha
    SISTEMA.abrirArquivo(pr_nmdireto => vr_dsdireto
                        ,pr_nmarquiv => 'listaPagtosBoletosFraude.txt'
                        ,pr_tipabert => 'R'
                        ,pr_utlfileh => vr_utlfileh
                        ,pr_dscritic => pr_dscritic);

    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_sai;
    END IF;    
    
    -- Gera arquivo de saída
    SISTEMA.abrirarquivo(pr_nmdireto => vr_dsdireto,
                         pr_nmarquiv => vr_nmarquiv,
                         pr_tipabert => 'A',
                         pr_utlfileh => vr_ind_arqlog,
                         pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_sai;
    END IF;                             

    -- Se o arquivo estiver aberto
    IF  utl_file.IS_OPEN(vr_utlfileh) THEN
      -- Percorre as linhas do arquivo
      LOOP
        -- Limpa a variável que receberá a linha do arquivo
        vr_dsdlinha := NULL;
        
        BEGIN
          -- Lê a linha do arquivo
          SISTEMA.leituraLinhaArquivo(pr_utlfileh => vr_utlfileh
                                     ,pr_des_text => vr_dsdlinha);                             
          vr_cooper := NULL;
          vr_nrdcta := NULL;
          vr_datmov := NULL;
          
          FOR i IN 1..LENGTH(vr_dsdlinha) LOOP
            BEGIN
              IF SUBSTR(vr_dsdlinha,i,1) = ' ' THEN
                IF vr_cooper IS NULL THEN
                   vr_cooper := SUBSTR(vr_dsdlinha,1,i-1);
                   vr_pos := i+1;
                ELSE            
                  IF vr_nrdcta IS NULL THEN
                     vr_nrdcta := SUBSTR(vr_dsdlinha,vr_pos,i-vr_pos);
                     vr_pos := i+1;
                  ELSE              
                    IF vr_datmov IS NULL THEN
                      vr_datmov := SUBSTR(vr_dsdlinha,vr_pos,i-vr_pos);
                      vr_pos := i;
                    END IF;  
                  END IF;  
                END IF;  
              END IF; 
            END;
          END LOOP;
          vr_vlrpag := SUBSTR(vr_dsdlinha,vr_pos+1,LENGTH(vr_dsdlinha)-vr_pos);
          
          OPEN cr_cop(UPPER(vr_cooper));
          FETCH cr_cop INTO rw_cop;
          
          IF cr_cop%FOUND THEN                
            CLOSE cr_cop;
                      
            -- Pesquisa título
            OPEN cr_consulta_tit(rw_cop.cdcooper, 
                                 TO_DATE(vr_datmov,'DD/MM/YYYY'), 
                                 TO_NUMBER(vr_nrdcta),
                                 TO_NUMBER(vr_vlrpag));
            FETCH cr_consulta_tit INTO rw_consulta_tit;
          
            IF cr_consulta_tit%FOUND THEN
              CLOSE cr_consulta_tit;
              -- Pesquisa XML
              OPEN cr_consulta_benefic_cip(rw_consulta_tit.cdctrlcs);
              FETCH cr_consulta_benefic_cip INTO rw_consulta_benefic_cip;
            
              IF cr_consulta_benefic_cip%FOUND THEN
                CLOSE cr_consulta_benefic_cip;
                vr_xmltitulo := xmltype.createxml(rw_consulta_benefic_cip.dsxml);
                NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltitulo.getClobVal()
                                                  ,pr_tbtitulo => vr_tbtitulo
                                                  ,pr_des_erro => vr_des_erro
                                                  ,pr_dscritic => vr_dscritic);
                -- Se for retornado um erro
                IF vr_des_erro = 'NOK' THEN
                  RAISE vr_exc_erro; 
                END IF;      
                
                vr_nrcpfCnpjBen := CASE WHEN vr_tbtitulo.CNPJ_CPFBenfcrioFinl IS NULL THEN vr_tbtitulo.CNPJ_CPFBenfcrioOr 
                                   ELSE vr_tbtitulo.CNPJ_CPFBenfcrioFinl END;
                                 
                vr_tpcpfCnpjBen := CASE WHEN vr_tbtitulo.TpPessoaBenfcrioFinl IS NULL THEN vr_tbtitulo.TpPessoaBenfcrioOr                                         
                                   ELSE vr_tbtitulo.TpPessoaBenfcrioFinl END;
                                   
                vr_des_tit := vr_cooper || ';' ||
                              vr_nrdcta || ';' ||
                              vr_datmov || ';' ||
                              vr_vlrpag || ';' ||                                            
                              vr_tpcpfCnpjBen || ';' || 
                              vr_nrcpfCnpjBen || ';' || 
                              vr_tbtitulo.CNPJ_CPFPagdr;                
              ELSE
                vr_des_tit := 'Consulta CIP nao encontrada';
                CLOSE cr_consulta_benefic_cip;
              END IF;
            ELSE          
              vr_des_tit := 'Titulo nao encontrado';
              CLOSE cr_consulta_tit;
            END IF;          
          ELSE
            vr_des_tit := 'Cooperativa nao encontrada';
            CLOSE cr_cop;      
          END IF;  
          
          sistema.escrevelinhaarquivo(pr_utlfileh => vr_ind_arqlog, 
                                      pr_des_text => vr_des_tit);             
          
          
                   
        EXCEPTION
          WHEN no_data_found THEN
          -- Acabou a leitura, então finaliza o loop
          EXIT;
        END;

      END LOOP; -- Finaliza o loop das linhas do arquivo
        -- Fechar o arquivo planilha
        fechaArquivo(pr_utlfileh => vr_utlfileh);
        -- Fecha arquivo saída
        fechaArquivo(pr_utlfileh => vr_ind_arqlog);
    END IF;    

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 1, 
                                   pr_compleme => to_char(vr_cdcritic) 
                                                  || '-' ||  vr_dscritic 
                                                  || ' - Conta:' || to_char(vr_nrdcta));
    pr_dscritic := vr_cdcritic;      
    
    -- Fechar o arquivo planilha
    fechaArquivo(pr_utlfileh => vr_utlfileh);
    -- Fecha arquivo saída
    fechaArquivo(pr_utlfileh => vr_ind_arqlog);
  END;