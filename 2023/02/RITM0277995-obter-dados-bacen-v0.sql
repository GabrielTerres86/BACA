  DECLARE    
    CURSOR cr_cadbanco(pr_nrcnpjif IN NUMBER) IS
      SELECT ban.nrcnpjif
        FROM CECRED.CRAPBAN ban 
       WHERE ban.nrcnpjif = pr_nrcnpjif;
    rw_cadbanco cr_cadbanco%ROWTYPE;           
    
    CURSOR cr_consulta_benefic_cip(pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE) IS
      SELECT npc.dsxml,
             npc.dscodbar
        FROM CECRED.tbcobran_consulta_titulo npc
       WHERE npc.cdctrlcs = pr_cdctrlcs;
    rw_consulta_benefic_cip cr_consulta_benefic_cip%ROWTYPE;
    
    CURSOR cr_consulta_tit IS                           
    SELECT to_date(pro.dttransa, 'DD/MM/YYYY') DTTRANSACAO,
           tit.nrcpfcgc CPFCNPJCOOP,
           cop.nmrescop NOMECOOPER,
           ass.cdagenci AGENCIACOOP,
           ass.nrdconta CONTACOOPER,
           tit.vltitulo VALORTITULO,
           tit.cdctrlcs           
      FROM CECRED.craptit tit,
           CECRED.crapass ass,
           CECRED.crapcop cop,
           CECRED.crappro pro           
     WHERE trunc(tit.dtdpagto) >= '01/12/2022'
       AND trunc(tit.dtdpagto) <= '31/01/2023'       
       AND ass.cdcooper = tit.cdcooper
       AND ass.nrdconta = tit.nrdconta
       AND cop.cdcooper = tit.cdcooper       
       AND pro.dtmvtolt = tit.dtdpagto
       AND pro.nrdconta = tit.nrdconta
       AND pro.cdtippro = 2
       AND TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(1, pro.dsinform##3, '#')), ':')) = tit.dscodbar;       
    
    CURSOR cr_cop(pr_nmcooper IN VARCHAR2) IS
    SELECT cop.cdcooper
      FROM CECRED.crapcop cop
     WHERE cop.nmrescop = pr_nmcooper; 
    rw_cop cr_cop%ROWTYPE;
    
    vr_ind_arqlog UTL_FILE.file_type;
    vr_nmarquiv VARCHAR(200) := 'listaPagtosBoletosFraude.csv';    
    vr_utlfileh UTL_FILE.file_type;
    vr_tbtitulo NPCB0001.typ_reg_TituloCIP;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);
    vr_exc_sai  EXCEPTION;
    vr_dsdireto VARCHAR2(50);
    vr_nrcpfCnpjBen VARCHAR2(20);
    vr_des_tit VARCHAR2(500) := Null;
    vr_xmltitulo XMLTYPE;    
    vr_cdcritic VARCHAR2(500);
    pr_dscritic VARCHAR2(500);
  BEGIN

    vr_dsdireto := '/micros/cecred/cpd/bacas/RITM0277995';    
    
    SISTEMA.abrirarquivo(pr_nmdireto => vr_dsdireto,
                         pr_nmarquiv => vr_nmarquiv,
                         pr_tipabert => 'A',
                         pr_utlfileh => vr_ind_arqlog,
                         pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NOT NULL THEN
      vr_cdcritic := 'Arquivo não encontrado';
      RAISE vr_exc_sai;
    END IF;     

    FOR rw_consulta_tit IN cr_consulta_tit LOOP      
      
      vr_des_tit := rw_consulta_tit.CPFCNPJCOOP || ';' ||
                    rw_consulta_tit.NOMECOOPER  || ';' ||
                    rw_consulta_tit.AGENCIACOOP || ';' ||
                    rw_consulta_tit.CONTACOOPER || ';' ||
                    rw_consulta_tit.VALORTITULO || ';';
                                          
      OPEN cr_consulta_benefic_cip(rw_consulta_tit.cdctrlcs);
      FETCH cr_consulta_benefic_cip INTO rw_consulta_benefic_cip;
            
      IF cr_consulta_benefic_cip%FOUND THEN
        CLOSE cr_consulta_benefic_cip;
        
        BEGIN
          vr_xmltitulo := xmltype.createxml(rw_consulta_benefic_cip.dsxml);
          NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltitulo.getClobVal()
                                            ,pr_tbtitulo => vr_tbtitulo
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_dscritic => vr_dscritic);          
          IF vr_des_erro = 'NOK' THEN
            vr_nrcpfCnpjBen := 'Erro consulta CIP;';
          ELSE
            vr_nrcpfCnpjBen := CASE WHEN vr_tbtitulo.CNPJ_CPFBenfcrioFinl IS NULL THEN vr_tbtitulo.CNPJ_CPFBenfcrioOr 
                               ELSE vr_tbtitulo.CNPJ_CPFBenfcrioFinl END;          
            
            OPEN cr_cadbanco(vr_tbtitulo.ISPBPartRecbdrPrincipal);
            FETCH cr_cadbanco INTO rw_cadbanco;   
            IF cr_cadbanco%FOUND THEN
            
              vr_des_tit := vr_des_tit || 
                            rw_cadbanco.nrcnpjif || ';' ||
                            vr_nrcpfCnpjBen;
            ELSE
               vr_des_tit := vr_des_tit || ';' ||
                             vr_nrcpfCnpjBen;
            END IF;             
            CLOSE cr_cadbanco;
          END IF;
          
        EXCEPTION
          WHEN OTHERS THEN
             vr_des_tit := vr_des_tit || 'Erro consulta CIP;';
        END;
                                           
      ELSE
        vr_des_tit := vr_des_tit || ';Consulta CIP nao encontrada';
        CLOSE cr_consulta_benefic_cip;
      END IF;      
          
      sistema.escrevelinhaarquivo(pr_utlfileh => vr_ind_arqlog, 
                                  pr_des_text => vr_des_tit);                   

    END LOOP;    
    
    SISTEMA.fechaArquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;    

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 1, 
                                   pr_compleme => to_char(vr_cdcritic) 
                                                  || '-' || vr_dscritic);
												  
    SISTEMA.fechaArquivo(pr_utlfileh => vr_ind_arqlog);
  END;