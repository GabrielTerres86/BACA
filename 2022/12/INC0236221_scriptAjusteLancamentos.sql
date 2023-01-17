DECLARE
  
  vr_nmdireto    VARCHAR2(100);
  vr_arqdebito   VARCHAR2(50) := 'INC0236221_debitos_lancados.csv';
  vr_arqsemsaldo VARCHAR2(50) := 'INC0236221_contas_sem_saldo.csv';
  vr_arqrollback VARCHAR2(50) := 'INC0236221_rollback_script.sql';
  fl_arqdebito   utl_file.file_type;
  fl_arqsemsaldo utl_file.file_type;
  fl_arqrollback utl_file.file_type;
  

  pr_tab_sald     CECRED.EXTR0001.typ_tab_saldos;
  pr_tab_erro     CECRED.GENE0001.typ_tab_erro;
  vr_des_reto     VARCHAR2(2000);
  vr_vllimite     NUMBER;
  vr_vldsaldo     NUMBER;
  vr_incrineg     NUMBER;
  vr_cdcritic     NUMBER;
  vr_dscritic     VARCHAR2(2000);
  vr_nrseqdoc     NUMBER := 0;
  
  vr_rollback     CLOB;
  
  vr_tab_retorno  CECRED.LANC0001.typ_reg_retorno;

  CURSOR contas_total IS
    SELECT t.cdcooper, t.nrdconta, SUM(t.vllanmto) vllanmto
      FROM craplcm t
     WHERE t.cdcooper = 1
       AND t.dtmvtolt = to_date('06/12/2022','dd/mm/yyyy')
       AND t.cdhistor = 1545
       AND t.dttrans BETWEEN to_date('07/12/2022 07:00','dd/mm/yyyy hh24:mi') AND to_date('07/12/2022 23:00','dd/mm/yyyy hh24:mi')
     GROUP BY t.cdcooper, t.nrdconta;

  CURSOR conta_lancamentos(pr_nrdconta NUMBER) IS
    SELECT t.*
      FROM craplcm t
     WHERE t.cdcooper = 1
       AND t.dtmvtolt = to_date('06/12/2022','dd/mm/yyyy')
       AND t.cdhistor = 1545
       AND t.nrdconta = pr_nrdconta
       AND t.dttrans BETWEEN to_date('07/12/2022 07:00','dd/mm/yyyy hh24:mi') AND to_date('07/12/2022 23:00','dd/mm/yyyy hh24:mi');
  
BEGIN
  
  OPEN  btch0001.cr_crapdat(1);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0236221';
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_arqdebito
                           ,pr_tipabert => 'W'
                           ,pr_utlfileh => fl_arqdebito
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20010,'Erro criar arquivo de debitos: '||vr_dscritic);
  END IF;
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_arqsemsaldo
                           ,pr_tipabert => 'W'
                           ,pr_utlfileh => fl_arqsemsaldo
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20011,'Erro criar arquivo de registros não lançados: '||vr_dscritic);
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_arqrollback
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => fl_arqrollback
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE_APPLICATION_ERROR(-20012,'Erro criar arquivo de rollback: '||vr_dscritic);
  END IF;
  
  gene0001.pc_escr_linha_arquivo(fl_arqdebito, 'REGISTROS ESTORNADOS E DEBITADOS EM CONTA CORRENTE'||CHR(10)||'COOP;CONTA;VALOR LANCTO;VALOR TOTAL;SALDO;');
  
  gene0001.pc_escr_linha_arquivo(fl_arqsemsaldo, 'REGISTROS ESTORNADOS SEM SALDO PARA LANÇAMENTO EM CONTA'||CHR(10)||'COOP;CONTA;VALOR LANCTO;VALOR TOTAL;SALDO;');
  
  gene0001.pc_escr_linha_arquivo(fl_arqrollback, 'BEGIN');
  
  
  FOR reg IN contas_total LOOP
  
    vr_vldsaldo := 0;
    
    SELECT t.vllimcre
      INTO vr_vllimite
      FROM crapass t
     WHERE t.cdcooper = reg.cdcooper
       AND t.nrdconta = reg.nrdconta;

    cecred.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper => reg.cdcooper,
                                       pr_rw_crapdat => btch0001.rw_crapdat,
                                       pr_cdagenci => 1,
                                       pr_nrdcaixa => 0,
                                       pr_cdoperad => '1',
                                       pr_nrdconta => reg.nrdconta,
                                       pr_vllimcre => vr_vllimite,
                                       pr_dtrefere => TRUNC(SYSDATE),
                                       pr_flgcrass => FALSE,
                                       pr_des_reto => vr_des_reto,
                                       pr_tab_sald => pr_tab_sald,
                                       pr_tab_erro => pr_tab_erro);

    vr_vldsaldo := NVL(pr_tab_sald(pr_tab_sald.first).vlsddisp,0) + NVL(vr_vllimite,0);

    
    FOR lanc IN conta_lancamentos(reg.nrdconta) LOOP
      
      vr_nrseqdoc := NVL(vr_nrseqdoc,0) + 1;
    
      lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => lanc.dtmvtolt
                                        ,pr_cdagenci    => lanc.cdagenci
                                        ,pr_cdbccxlt    => lanc.cdbccxlt
                                        ,pr_nrdolote    => lanc.nrdolote
                                        ,pr_nrdconta    => reg.nrdconta
                                        ,pr_nrdocmto    => SUBSTR(lanc.nrdocmto,0,19) || LPAD(vr_nrseqdoc,6,'0')
                                        ,pr_cdhistor    => 3248 
                                        ,pr_vllanmto    => lanc.vllanmto
                                        ,pr_nrdctabb    => lanc.nrdctabb
                                        ,pr_cdpesqbb    => lanc.cdpesqbb
                                        ,pr_vldoipmf    => lanc.vldoipmf
                                        ,pr_nrautdoc    => lanc.nrautdoc
                                        ,pr_nrsequni    => lanc.nrsequni
                                        ,pr_cdbanchq    => lanc.cdbanchq
                                        ,pr_cdcmpchq    => lanc.cdcmpchq
                                        ,pr_cdagechq    => lanc.cdagechq
                                        ,pr_nrctachq    => lanc.nrctachq
                                        ,pr_nrlotchq    => lanc.nrlotchq
                                        ,pr_sqlotchq    => lanc.sqlotchq
                                        ,pr_dtrefere    => lanc.dtrefere
                                        ,pr_hrtransa    => gene0002.fn_busca_time
                                        ,pr_cdoperad    => '1'
                                        ,pr_dsidenti    => lanc.dsidenti
                                        ,pr_cdcooper    => reg.cdcooper
                                        ,pr_nrdctitg    => lanc.nrdctitg
                                        ,pr_dscedent    => lanc.dscedent
                                        ,pr_cdcoptfn    => lanc.cdcoptfn
                                        ,pr_cdagetfn    => lanc.cdagetfn
                                        ,pr_nrterfin    => lanc.nrterfin
                                        ,pr_nrparepr    => lanc.nrparepr
                                        ,pr_nrseqava    => lanc.nrseqava
                                        ,pr_nraplica    => lanc.nraplica
                                        ,pr_cdorigem    => lanc.cdorigem
                                        ,pr_idlautom    => lanc.idlautom
                                        ,pr_inprolot    => 1 
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg    => vr_incrineg
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_dscritic    => vr_dscritic);
      
      
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001,'Erro ao incluir estorno de lançamento ('||lanc.progress_recid||'): '||vr_cdcritic||' - '||vr_dscritic);
      END IF;
      
      gene0001.pc_escr_linha_arquivo(fl_arqrollback, 'DELETE CRAPLCM WHERE CDCOOPER = 1 and DTMVTOLT = to_date('''||lanc.dtmvtolt||''',''dd/mm/yyyy'') and CDAGENCI = '||lanc.cdagenci||' and CDBCCXLT = '||lanc.cdbccxlt||' and NRDOLOTE = '||lanc.nrdolote||' and NRDCTABB = '||lanc.nrdctabb||' and NRDOCMTO = '||SUBSTR(lanc.nrdocmto,0,19) || LPAD(vr_nrseqdoc,6,'0')||';');
      
      IF vr_vldsaldo >= reg.vllanmto THEN
        
        lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => btch0001.rw_crapdat.dtmvtolt 
                                          ,pr_cdagenci    => lanc.cdagenci
                                          ,pr_cdbccxlt    => lanc.cdbccxlt
                                          ,pr_nrdolote    => lanc.nrdolote
                                          ,pr_nrdconta    => reg.nrdconta
                                          ,pr_nrdocmto    => lanc.nrdocmto
                                          ,pr_cdhistor    => 1545 
                                          ,pr_vllanmto    => lanc.vllanmto
                                          ,pr_nrdctabb    => lanc.nrdctabb
                                          ,pr_cdpesqbb    => lanc.cdpesqbb
                                          ,pr_vldoipmf    => lanc.vldoipmf
                                          ,pr_nrautdoc    => lanc.nrautdoc
                                          ,pr_nrsequni    => lanc.nrsequni
                                          ,pr_cdbanchq    => lanc.cdbanchq
                                          ,pr_cdcmpchq    => lanc.cdcmpchq
                                          ,pr_cdagechq    => lanc.cdagechq
                                          ,pr_nrctachq    => lanc.nrctachq
                                          ,pr_nrlotchq    => lanc.nrlotchq
                                          ,pr_sqlotchq    => lanc.sqlotchq
                                          ,pr_dtrefere    => btch0001.rw_crapdat.dtmvtolt
                                          ,pr_hrtransa    => gene0002.fn_busca_time
                                          ,pr_cdoperad    => '1'
                                          ,pr_dsidenti    => lanc.dsidenti
                                          ,pr_cdcooper    => reg.cdcooper
                                          ,pr_nrdctitg    => lanc.nrdctitg
                                          ,pr_dscedent    => lanc.dscedent
                                          ,pr_cdcoptfn    => lanc.cdcoptfn
                                          ,pr_cdagetfn    => lanc.cdagetfn
                                          ,pr_nrterfin    => lanc.nrterfin
                                          ,pr_nrparepr    => lanc.nrparepr
                                          ,pr_nrseqava    => lanc.nrseqava
                                          ,pr_nraplica    => lanc.nraplica
                                          ,pr_cdorigem    => lanc.cdorigem
                                          ,pr_idlautom    => lanc.idlautom
                                          ,pr_inprolot    => 1 
                                          ,pr_tab_retorno => vr_tab_retorno
                                          ,pr_incrineg    => vr_incrineg
                                          ,pr_cdcritic    => vr_cdcritic
                                          ,pr_dscritic    => vr_dscritic);
      
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR(-20002,'Erro ao incluir novo lançamento de débito ('||lanc.progress_recid||'): '||vr_cdcritic||' - '||vr_dscritic);
        END IF;
        
        gene0001.pc_escr_linha_arquivo(fl_arqrollback, 'DELETE CRAPLCM WHERE CDCOOPER = 1 and DTMVTOLT = to_date('''||btch0001.rw_crapdat.dtmvtolt||''',''dd/mm/yyyy'') and CDAGENCI = '||lanc.cdagenci||' and CDBCCXLT = '||lanc.cdbccxlt||' and NRDOLOTE = '||lanc.nrdolote||' and NRDCTABB = '||lanc.nrdctabb||' and NRDOCMTO = '||lanc.nrdocmto||';');
        
        gene0001.pc_escr_linha_arquivo(fl_arqdebito, reg.cdcooper||';'||reg.nrdconta||';'||lanc.vllanmto||';'||reg.vllanmto||';'||vr_vldsaldo||';');
        
      ELSE
      
        gene0001.pc_escr_linha_arquivo(fl_arqsemsaldo, reg.cdcooper||';'||reg.nrdconta||';'||lanc.vllanmto||';'||reg.vllanmto||';'||vr_vldsaldo||';');
        
      END IF;
    
    END LOOP;

  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(fl_arqrollback, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(fl_arqrollback, 'END;');

  GENE0001.pc_fecha_arquivo(pr_utlfileh => fl_arqdebito);
  GENE0001.pc_fecha_arquivo(pr_utlfileh => fl_arqsemsaldo);
  GENE0001.pc_fecha_arquivo(pr_utlfileh => fl_arqrollback);  
  
  COMMIT;
  
end;
