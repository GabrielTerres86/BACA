DECLARE

  vr_exc_erro        EXCEPTION;
  vr_dsdireto        VARCHAR2(2000);
  vr_nmarquiv        VARCHAR2(100);
  vr_dscritic        VARCHAR2(4000);
  vr_cdcritic        NUMBER;
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arqlog      utl_file.file_type;
  vr_dslinha         VARCHAR2(4000);
  vr_nmdireto        VARCHAR2(4000);
  vr_cdcooper        NUMBER;
  vr_nrdconta        NUMBER;
  vr_nrctremp        NUMBER;
  vr_cdhistor_remun  NUMBER;
  vr_cdhistor_estorn NUMBER;
  vr_nrdolote        NUMBER;
  vr_tab_crawepr     EMPR0001.typ_tab_crawepr;
  vr_index_crawepr   VARCHAR2(30);
  pr_flnormal        BOOLEAN := FALSE;
  pr_ehmensal        BOOLEAN := TRUE;
  vr_dtdpagto        DATE;
  vr_vljurmes        NUMBER;
  vr_vlsdeved_up     NUMBER := 0;
  vr_nrdrowid        ROWID;

  vr_tab_erro GENE0001.typ_tab_erro;
  vr_des_reto VARCHAR2(4000);

  vr_diarefju INTEGER;
  vr_mesrefju INTEGER;
  vr_anorefju INTEGER;

  vr_vet_dados cecred.gene0002.typ_split;

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;

  CURSOR cr_operacao(pr_cdcooper crapepr.cdcooper%TYPE,
                     pr_nrdconta crapepr.nrdconta%TYPE,
                     pr_nrctremp crapepr.nrctremp%TYPE) IS
    SELECT b.dsoperac, c.dtlibera, a.vlsdeved
      FROM CECRED.crapepr a
     INNER JOIN CECRED.craplcr b
        ON a.cdcooper = b.cdcooper
           AND a.cdlcremp = b.cdlcremp
     INNER JOIN CECRED.crawepr c
        ON a.cdcooper = c.cdcooper
           AND a.nrdconta = c.nrdconta
           AND a.nrctremp = c.nrctremp
     WHERE A.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.nrctremp = pr_nrctremp;
  rw_operacao cr_operacao%ROWTYPE;

  CURSOR cr_craplem_jrsremu(pr_cdcooper craplem.cdcooper%TYPE,
                            pr_nrdconta craplem.nrdconta%TYPE,
                            pr_nrctremp craplem.nrctremp%TYPE,
                            pr_cdhistor craplem.cdhistor%TYPE) IS
    SELECT SUM(a.vllanmto) vllanmto
      FROM CECRED.craplem a
     WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor = pr_cdhistor
           AND a.dtmvtolt BETWEEN to_date('01/02/2024', 'dd/mm/yyyy') AND
           to_date('01/02/2024', 'dd/mm/yyyy');
  rw_craplem_jrsremu cr_craplem_jrsremu%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM CECRED.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN

  vr_dsdireto := GENE0001.fn_param_sistema('CRED', 3, 'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto || 'cpd/bacas/RISCO/ACORDOS/';
  vr_nmarquiv := 'ACORDOS_V4.csv';

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarquiv,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,
                                   to_char(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                   ' Nao foi possivel ler o arquivo de entrada');
    RAISE vr_exc_erro;
  END IF;

  BEGIN

    LOOP

      IF utl_file.IS_OPEN(vr_ind_arquiv) THEN

        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                                     pr_des_text => vr_dslinha);

        vr_dslinha := REPLACE(vr_dslinha, chr(13));

        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_dslinha,
                                                  pr_delimit => ';');

        vr_cdcooper    := GENE0002.fn_char_para_number(vr_vet_dados(1));
        vr_nrdconta    := GENE0002.fn_char_para_number(vr_vet_dados(2));
        vr_nrctremp    := GENE0002.fn_char_para_number(vr_vet_dados(3));
        vr_vlsdeved_up := 0;
        vr_vljurmes    := 0;

        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                             pr_cdoperad => 1,
                             pr_dscritic => ' ',
                             pr_dsorigem => GENE0001.vr_vet_des_origens(21),
                             pr_dstransa => 'INC0312981 - Ajuste Juros Remun. - Contrato: ' ||
                                            vr_nrctremp,
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => gene0002.fn_busca_time,
                             pr_idseqttl => 1,
                             pr_nmdatela => 'ATENDA',
                             pr_nrdconta => vr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);

        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        rw_crapass := NULL;

        OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => vr_nrdconta);
        FETCH cr_crapass
          INTO rw_crapass;
        CLOSE cr_crapass;
        
        rw_operacao := NULL;

        OPEN cr_operacao(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrctremp => vr_nrctremp);
        FETCH cr_operacao
          INTO rw_operacao;
        CLOSE cr_operacao;        

        IF rw_operacao.dsoperac = 'FINANCIAMENTO' THEN
          vr_cdhistor_remun  := 1038;
          vr_cdhistor_estorn := 4541;
          vr_nrdolote        := 600011;
        ELSE
          vr_cdhistor_remun  := 1037;
          vr_cdhistor_estorn := 3272;
          vr_nrdolote        := 600010;            
        END IF;  
        
        rw_craplem_jrsremu := NULL;

        OPEN cr_craplem_jrsremu(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_nrctremp => vr_nrctremp,
                                pr_cdhistor => vr_cdhistor_remun);
        FETCH cr_craplem_jrsremu
          INTO rw_craplem_jrsremu;
        CLOSE cr_craplem_jrsremu;

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Histórico Juros Remun.',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_cdhistor_remun);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Historico Juros Estorno.',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => vr_cdhistor_estorn);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'Valor Juros Remun.',
                                  pr_dsdadant => ' ',
                                  pr_dsdadatu => nvl(rw_craplem_jrsremu.vllanmto,
                                                     0));

        IF nvl(rw_craplem_jrsremu.vllanmto, 0) > 0 THEN

          EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_cdagenci => rw_crapass.cdagenci,
                                          pr_cdbccxlt => 100,
                                          pr_cdoperad => 1,
                                          pr_cdpactra => rw_crapass.cdagenci,
                                          pr_tplotmov => 5,
                                          pr_nrdolote => vr_nrdolote,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_cdhistor => vr_cdhistor_estorn,
                                          pr_nrctremp => vr_nrctremp,
                                          pr_vllanmto => rw_craplem_jrsremu.vllanmto,
                                          pr_dtpagemp => rw_crapdat.dtmvtolt,
                                          pr_txjurepr => 0,
                                          pr_vlpreemp => 0,
                                          pr_nrsequni => 0,
                                          pr_nrparepr => 0,
                                          pr_flgincre => FALSE,
                                          pr_flgcredi => FALSE,
                                          pr_nrseqava => 0,
                                          pr_cdorigem => 5,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);

          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                      pr_nmdcampo => 'Erro ao executar EMPR0001.pc_cria_lancamento_lem',
                                      pr_dsdadant => ' ',
                                      pr_dsdadatu => vr_dscritic);

            ROLLBACK;
            CONTINUE;
          END IF;
          
          vr_vlsdeved_up := nvl(rw_operacao.vlsdeved, 0);
          vr_vlsdeved_up := vr_vlsdeved_up - nvl(rw_craplem_jrsremu.vllanmto, 0);

          UPDATE cecred.crapepr
             SET vlsdeved = vr_vlsdeved_up
           WHERE cdcooper = vr_cdcooper
                 AND nrdconta = vr_nrdconta
                 AND nrctremp = vr_nrctremp;

          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'vlsdeved apos atualizacao cria_lancamento.',
                                    pr_dsdadant => ' ',
                                    pr_dsdadatu => nvl(vr_vlsdeved_up, 0));
                                    
          COMMIT;

        END IF;

      END IF;
    END LOOP;

  EXCEPTION
    WHEN no_data_found THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  END;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
