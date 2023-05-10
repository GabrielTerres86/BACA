DECLARE
  CURSOR cr_consulta_benefic_cip(pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE) IS
    SELECT npc.dsxml, npc.dscodbar
      FROM CECRED.tbcobran_consulta_titulo npc
     WHERE npc.cdctrlcs = pr_cdctrlcs;
  rw_consulta_benefic_cip cr_consulta_benefic_cip%ROWTYPE;

  CURSOR cr_consulta_tit_barras(pr_cdcooper      IN craptit.cdcooper%TYPE,
                                pr_codigo_barras IN craptit.dscodbar%TYPE) IS
    SELECT tit.cdctrlcs
      FROM CECRED.craptit tit
     WHERE tit.cdcooper = pr_cdcooper
       AND upper(tit.dscodbar) = pr_codigo_barras;
  rw_consulta_tit_barras cr_consulta_tit_barras%ROWTYPE;

  CURSOR cr_consulta_pro(pr_cdcooper      IN crappro.cdcooper%TYPE,
                         pr_nrdconta      IN crappro.nrdconta%TYPE,
                         pr_codigo_barras IN craptit.dscodbar%TYPE) IS
    SELECT pro.dttransa
      FROM CECRED.crappro pro
     WHERE pro.cdcooper = pr_cdcooper
       AND pro.nrdconta = pr_nrdconta
       AND pro.cdtippro = 2
       AND substr(pro.dsinform##3, 19, 44) = pr_codigo_barras;
  rw_consulta_pro cr_consulta_pro%ROWTYPE;

  CURSOR cr_cop(pr_nmcooper IN VARCHAR2) IS
    SELECT cop.cdcooper
      FROM CECRED.crapcop cop
     WHERE cop.nmrescop = pr_nmcooper;
  rw_cop cr_cop%ROWTYPE;

  vr_ind_arqlog UTL_FILE.file_type;
  vr_exc_erro EXCEPTION;
  vr_utlfileh         UTL_FILE.file_type;
  vr_dsdlinha         VARCHAR2(4000);
  vr_cooper           VARCHAR2(20);
  vr_nrdcta           VARCHAR2(20);
  vr_datmov           VARCHAR2(20);
  vr_vlrpag           VARCHAR2(20);
  vr_codigo_barras    VARCHAR2(100);
  vr_nrcpf_cnpj       VARCHAR2(100);
  vr_achou_tit_barras BOOLEAN;
  vr_tbtitulo         NPCB0001.typ_reg_TituloCIP;
  vr_dscritic         VARCHAR2(4000);
  vr_des_erro         VARCHAR2(10);
  vr_exc_sai EXCEPTION;
  vr_dsdireto     VARCHAR2(50);
  vr_nrcpfCnpjBen VARCHAR2(20);
  vr_tpcpfCnpjBen VARCHAR2(1);

  vr_des_tit           VARCHAR2(500);
  vr_xmltitulo         XMLTYPE;
  vr_pos               NUMBER;
  i                    NUMBER;
  vr_cdcritic          VARCHAR2(500);
  pr_dscritic          VARCHAR2(500);
  vr_nmarquivo_entrada VARCHAR(200) := 'bacen_abr_2023.csv';
  vr_nmarquivo_saida   VARCHAR(200) := 'listaPagtosBoletosFraude.csv';

BEGIN

  vr_dsdireto := '/micros/cpd/bacas/RITM0301456';

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto,
                           pr_nmarquiv => vr_nmarquivo_entrada,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_utlfileh,
                           pr_des_erro => pr_dscritic);

  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_sai;
  END IF;

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto,
                           pr_nmarquiv => vr_nmarquivo_saida,
                           pr_tipabert => 'A',
                           pr_utlfileh => vr_ind_arqlog,
                           pr_des_erro => pr_dscritic);

  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_sai;
  END IF;

  IF utl_file.IS_OPEN(vr_utlfileh) THEN
    LOOP
      vr_dsdlinha := NULL;
    
      BEGIN
        cecred.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh,
                                            pr_des_text => vr_dsdlinha);
        vr_cooper        := NULL;
        vr_nrdcta        := NULL;
        vr_datmov        := NULL;
        vr_vlrpag        := NULL;
        vr_codigo_barras := NULL;
        vr_nrcpf_cnpj    := NULL;
        
        FOR i IN 1 .. LENGTH(vr_dsdlinha) LOOP
          BEGIN
            IF SUBSTR(vr_dsdlinha, i, 1) = ';' THEN
              IF vr_cooper IS NULL THEN
                vr_cooper := SUBSTR(vr_dsdlinha, 1, i - 1);
                vr_pos    := i + 1;
              ELSE
                IF vr_nrdcta IS NULL THEN
                  vr_nrdcta := SUBSTR(vr_dsdlinha, vr_pos, i - vr_pos);
                  vr_pos    := i + 1;
                ELSE
                  IF vr_datmov IS NULL THEN
                    vr_datmov := SUBSTR(vr_dsdlinha, vr_pos, i - vr_pos);
                    vr_pos    := i;
                  ELSE
                    IF vr_vlrpag IS NULL THEN
                      vr_vlrpag := SUBSTR(vr_dsdlinha,
                                          vr_pos + 1,
                                          (i - 1) - vr_pos);
                      vr_pos    := i;
                    ELSE
                      IF vr_codigo_barras IS NULL THEN
                        vr_codigo_barras := SUBSTR(vr_dsdlinha,
                                                   vr_pos + 1,
                                                   (i - 1) - vr_pos);
                        vr_pos           := i;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END;
        END LOOP;
      
        OPEN cr_cop(UPPER(vr_cooper));
        FETCH cr_cop
          INTO rw_cop;
      
        vr_nrcpf_cnpj := SUBSTR(vr_dsdlinha,
                                vr_pos + 1,
                                LENGTH(vr_dsdlinha) - vr_pos);
      
        IF cr_cop%FOUND THEN
          CLOSE cr_cop;
        
          OPEN cr_consulta_tit_barras(TO_NUMBER(rw_cop.cdcooper),
                                      vr_codigo_barras);
          FETCH cr_consulta_tit_barras
            INTO rw_consulta_tit_barras;
          vr_achou_tit_barras := FALSE;
          IF cr_consulta_tit_barras%FOUND THEN
            vr_achou_tit_barras := TRUE;
          END IF;
        
          IF cr_consulta_tit_barras%FOUND THEN
            CLOSE cr_consulta_tit_barras;
          
            OPEN cr_consulta_benefic_cip(rw_consulta_tit_barras.cdctrlcs);
            FETCH cr_consulta_benefic_cip
              INTO rw_consulta_benefic_cip;
          
            IF cr_consulta_benefic_cip%FOUND THEN
              CLOSE cr_consulta_benefic_cip;
              vr_xmltitulo := xmltype.createxml(rw_consulta_benefic_cip.dsxml);
              NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltitulo.getClobVal(),
                                                 pr_tbtitulo => vr_tbtitulo,
                                                 pr_des_erro => vr_des_erro,
                                                 pr_dscritic => vr_dscritic);
              IF vr_des_erro = 'NOK' THEN
                vr_des_tit := 'XML consulta CIP em branco - ' ||
                              vr_codigo_barras;
              ELSE
                vr_nrcpfCnpjBen := CASE
                                     WHEN vr_tbtitulo.CNPJ_CPFBenfcrioFinl IS NULL THEN
                                      vr_tbtitulo.CNPJ_CPFBenfcrioOr
                                     ELSE
                                      vr_tbtitulo.CNPJ_CPFBenfcrioFinl
                                   END;
              
                vr_tpcpfCnpjBen := CASE
                                     WHEN vr_tbtitulo.TpPessoaBenfcrioFinl IS NULL THEN
                                      vr_tbtitulo.TpPessoaBenfcrioOr
                                     ELSE
                                      vr_tbtitulo.TpPessoaBenfcrioFinl
                                   END;
              
                vr_des_tit := vr_cooper || ';' || vr_nrdcta || ';' ||
                              vr_datmov || ';' || vr_vlrpag || ';' ||
                              vr_codigo_barras || ';' || vr_tpcpfCnpjBen || ';' || 
                              vr_nrcpfCnpjBen  || ';' || vr_tbtitulo.CNPJ_CPFPagdr;
              END IF;
            ELSE
              vr_des_tit := 'Consulta CIP nao encontrada - ' || vr_cooper || '-' ||
                            vr_codigo_barras;
              CLOSE cr_consulta_benefic_cip;
            END IF;
          ELSE
            CLOSE cr_consulta_tit_barras;
            OPEN cr_consulta_pro(rw_cop.cdcooper,
                                 vr_nrdcta,
                                 vr_codigo_barras);
            FETCH cr_consulta_pro
              INTO rw_consulta_pro;
            IF cr_consulta_pro%FOUND THEN
              CLOSE cr_consulta_PRO;
              vr_des_tit := vr_cooper || ';' || vr_nrdcta  || ';' ||
                            vr_datmov || ';' || vr_vlrpag  || ';' ||
                            vr_codigo_barras || ';' || ';' || 
                            ';'  || ';' || 'Titulo estornado';
            ELSE
              CLOSE cr_consulta_pro;
              vr_des_tit := vr_cooper || ';' || vr_nrdcta  || ';' ||
                            vr_datmov || ';' || vr_vlrpag  || ';' ||
                            vr_codigo_barras || ';' || ';' || 
                            ';'  || ';' || 'Titulo nao encontrado';
            END IF;
          END IF;
        ELSE
          vr_des_tit := 'Cooperativa nao encontrada';
          CLOSE cr_cop;
        END IF;
      
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_ind_arqlog,
                                       pr_des_text => vr_des_tit);
      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
      END;
    
    END LOOP;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  END IF;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 1,
                                 pr_compleme => to_char(vr_cdcritic) || '-' ||
                                                vr_dscritic || ' - Conta:' ||
                                                to_char(vr_nrdcta) ||
                                                '- Erro: ' || SQLERRM);
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
END;
