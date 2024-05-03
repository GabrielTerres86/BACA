DECLARE

  vr_dtrefere VARCHAR2(50) := '30/04/2024';
  
  vr_retfile  VARCHAR2(300);
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop
     WHERE flgativo = 1
     ORDER BY cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;

  PROCEDURE pc_risco_k(pr_cdcooper   IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_retfile   OUT VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS

    CURSOR cr_crapris_249(pr_cdcooper in crapris.cdcooper%TYPE
                         ,pr_dtultdia in crapris.dtrefere%TYPE
                         ,pr_cdorigem in crapris.cdorigem%TYPE
                         ,pr_cdmodali in crapris.cdmodali%TYPE
                         ,pr_tpemprst IN crapepr.tpemprst%TYPE) IS
      SELECT r.cdagenci
            ,(SUM(v.vldivida)) saldo_devedor
        FROM crapris r
            ,crapepr e
            ,crapvri v
       WHERE r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtultdia
         AND r.cdorigem = pr_cdorigem
         AND r.cdmodali = pr_cdmodali
         AND e.cdcooper = r.cdcooper
         AND e.nrdconta = r.nrdconta
         AND e.nrctremp = r.nrctremp
         AND e.tpemprst = pr_tpemprst
         AND v.cdcooper = r.cdcooper
         AND v.nrdconta = r.nrdconta
         AND v.nrctremp = r.nrctremp
         AND v.dtrefere = r.dtrefere
         AND v.cdmodali = r.cdmodali
         AND v.cdvencto BETWEEN 110 AND 290 
         AND NOT EXISTS (SELECT 1
                           FROM crapebn b
                          WHERE b.cdcooper = r.cdcooper
                            AND b.nrdconta = r.nrdconta
                            AND b.nrctremp = r.nrctremp)
         AND NOT EXISTS (SELECT 1
                           FROM tbcrd_cessao_credito ces
                          WHERE ces.cdcooper = r.cdcooper
                            AND ces.nrdconta = r.nrdconta
                            AND ces.nrctremp = r.nrctremp)
         GROUP BY (r.cdagenci) 
         ORDER BY nvl(r.cdagenci,0) ASC;
         
    TYPE typ_cr_crapris_249 IS TABLE OF cr_crapris_249%ROWTYPE index by PLS_INTEGER;
    rw_crapris_249 typ_cr_crapris_249; 
    
    CURSOR cr_crapris_249_jura60(pr_cdcooper in crapris.cdcooper%TYPE
                                ,pr_dtultdia in crapris.dtrefere%TYPE
                                ,pr_cdorigem in crapris.cdorigem%TYPE
                                ,pr_cdmodali in crapris.cdmodali%TYPE
                                ,pr_tpemprst IN crapepr.tpemprst%TYPE
                                ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT (SUM(NVL(j.vljura60,0))) vljura60
        FROM cecred.crapris r
            ,cecred.crapepr e
            ,GESTAODERISCO.tbrisco_juros_emprestimo j
       WHERE e.cdcooper = r.cdcooper
         AND e.nrdconta = r.nrdconta
         AND e.nrctremp = r.nrctremp
         AND r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtultdia
         AND r.cdorigem = pr_cdorigem
         AND r.cdmodali = pr_cdmodali
         AND e.tpemprst = pr_tpemprst
         AND r.cdagenci = pr_cdagenci
         AND r.cdcooper = j.cdcooper(+) 
         AND r.nrdconta = j.nrdconta(+) 
         AND r.nrctremp = j.nrctremp(+) 
         AND r.dtrefere = j.dtrefere(+) 
         AND NVL(j.vljura60,0) + nvl(j.vljurantpp,0) > 0
         AND EXISTS (SELECT 1 
                       FROM cecred.crapvri v
                      WHERE v.cdcooper = r.cdcooper
                        AND v.nrdconta = r.nrdconta
                        AND v.dtrefere = r.dtrefere
                        AND v.cdmodali = r.cdmodali
                        AND v.nrctremp = r.nrctremp
                        AND v.nrseqctr = r.nrseqctr
                        AND v.cdvencto BETWEEN 110 AND 290)
         AND NOT EXISTS (SELECT 1
                           FROM cecred.crapebn b
                          WHERE b.cdcooper = r.cdcooper
                            AND b.nrdconta = r.nrdconta
                            AND b.nrctremp = r.nrctremp)
         AND NOT EXISTS (SELECT 1
                           FROM cecred.tbcrd_cessao_credito ces
                          WHERE ces.cdcooper = r.cdcooper
                            AND ces.nrdconta = r.nrdconta
                            AND ces.nrctremp = r.nrctremp);
    vr_vljura60_249       GESTAODERISCO.tbrisco_juros_emprestimo.vljura60%TYPE;
    
    vr_exc_erro          EXCEPTION;
    vr_file_erro         EXCEPTION;

    vr_nrmaxpas          INTEGER := 0;
    rw_crapdat           btch0001.cr_crapdat%ROWTYPE;
   
    vr_cdprogra          CONSTANT crapprg.cdprogra%TYPE := 'RISCO';
    vr_cdcritic          PLS_INTEGER;
    vr_dscritic          VARCHAR2(4000);
    vr_dtrefere          DATE;

    vr_ind_arquivo       utl_file.file_type;
    vr_utlfileh          VARCHAR2(4000);
    vr_nmarquiv          VARCHAR2(100);
    vr_dscomando         VARCHAR2(4000);
    vr_typ_saida         VARCHAR2(4000);
    vr_dtincorp crapdat.dtmvtolt%TYPE;
    vr_cdcopant craptco.cdcopant%TYPE;
    
    vr_vltotorc            crapsdc.vllanmto%type;
    vr_flgctpas            boolean; 
    vr_flgctred            boolean; 
    vr_flgrvorc            boolean; 
    vr_dshcporc            varchar2(100);
    vr_lsctaorc            varchar2(100);
    vr_dtmvtolt_yymmdd     varchar2(6);
    vr_dshstorc            varchar2(240);
    vr_dtmvtopr            DATE;
    vr_dtmvtolt            DATE;
    vr_linhadet            VARCHAR(3000);
    vr_con_dtmvtolt        VARCHAR(3000);
    vr_con_dtmvtopr        VARCHAR(3000);
    vr_con_dtmovime        VARCHAR(3000);
    vr_dircon              VARCHAR2(200);
    vr_arqcon              VARCHAR2(200);
    vc_cdtodascooperativas INTEGER := 0;
    vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
    
    type typ_cratorc is record (vr_cdagenci  crapass.cdagenci%type,
                                vr_vllanmto  crapsdc.vllanmto%type);
    type typ_tab_cratorc is table of typ_cratorc index by binary_integer;
    vr_tab_cratorc         typ_tab_cratorc;

    PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
    BEGIN
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
    END;
    
    procedure pc_proc_lista_orcamento is
      vr_ger_dsctaorc    varchar2(50);
      vr_pac_dsctaorc    varchar2(50);
      vr_dtmvto          date;
      vr_indice_agencia  crapass.cdagenci%type;
    BEGIN
    
      if vr_vltotorc = 0 THEN
        return;
      end IF;
      if vr_flgctpas then  
        if vr_flgctred then 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        else 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else 
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        end if;
      else 
        if vr_flgctred then 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          else 
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          end if;
        else 
          if vr_flgrvorc then 
            vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
            vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
          else 
            vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
            vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
          end if;
        end if;
      end if;

      if vr_flgrvorc then
        vr_dtmvto := vr_dtmvtopr;
      else
        vr_dtmvto := vr_dtmvtolt;
      end if;

      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_ger_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);

      pc_gravar_linha(vr_linhadet);
      
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));

      pc_gravar_linha(vr_linhadet);

      vr_linhadet := '99'||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvto,'ddmmyy'))||
                    trim(vr_pac_dsctaorc)||
                    trim(to_char(vr_vltotorc, '99999999999990.00'))||
                    trim(vr_dshcporc)||
                    trim(vr_dshstorc);

      pc_gravar_linha(vr_linhadet);
      
      vr_indice_agencia := vr_tab_cratorc.first;

      WHILE vr_indice_agencia IS NOT NULL LOOP

        if vr_tab_cratorc(vr_indice_agencia).vr_vllanmto <> 0 then
          vr_linhadet := to_char(vr_tab_cratorc(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                         trim(to_char(vr_tab_cratorc(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));

          pc_gravar_linha(vr_linhadet);
        end if;

        vr_indice_agencia := vr_tab_cratorc.next(vr_indice_agencia);
      END LOOP;
      
    END;

  BEGIN

    vr_dtrefere := to_date(pr_dtrefere, 'dd/mm/YY');
    
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
      vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => (vr_dtrefere + 1) 
                                              ,pr_tipo      => 'P' );            

    vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                              ,pr_dtmvtolt  => vr_dtrefere
                                              ,pr_tipo      => 'A' );     

    vr_con_dtmvtolt := '70' ||
                       to_char(vr_dtmvtolt, 'yy') ||
                       to_char(vr_dtmvtolt, 'mm') ||
                       to_char(vr_dtmvtolt, 'dd');
    vr_con_dtmvtopr := '70' ||
                       to_char(vr_dtmvtopr, 'yy') ||
                       to_char(vr_dtmvtopr, 'mm') ||
                       to_char(vr_dtmvtopr, 'dd');

    vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/contab') ;

    vr_nmarquiv := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO.TMP';
    pr_retfile  := to_char(vr_dtmvtolt, 'yy') ||
                   to_char(vr_dtmvtolt, 'mm') ||
                   to_char(vr_dtmvtolt, 'dd') ||
                   '_RISCO.txt';

    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh     
                            ,pr_nmarquiv => vr_nmarquiv     
                            ,pr_tipabert => 'W'             
                            ,pr_utlfileh => vr_ind_arquivo  
                            ,pr_des_erro => vr_dscritic);   

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_file_erro;
    END IF;

    vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yymmdd');
    
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
        
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 0) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 0
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;    
                
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 0) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 0
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;   

    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    if vr_vltotorc > 0 then
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1662,'||
                     '1621,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SALDO FINANCIAMENTOS."';

      pc_gravar_linha(vr_linhadet);

      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);

      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '1621,'||
                     '1662,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO SALDO FINANCIAMENTOS."';

      pc_gravar_linha(vr_linhadet);

      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      pc_gravar_linha(vr_linhadet);
      pc_gravar_linha(vr_linhadet);

    end if;

    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 1) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 1
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;     

    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 1) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 1
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;  
        
    vr_flgrvorc := false;
    vr_flgctpas := false;
    vr_flgctred := false;
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_flgrvorc := true; 
    vr_flgctpas := false;
    vr_flgctred := false;
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 299
                                        ,pr_tpemprst => 2) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 299
                                ,pr_tpemprst => 2
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;   
    
    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1603,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    FOR rw_crapris_249 IN cr_crapris_249(pr_cdcooper => pr_cdcooper
                                        ,pr_dtultdia => vr_dtrefere
                                        ,pr_cdorigem => 3
                                        ,pr_cdmodali => 499
                                        ,pr_tpemprst => 2) LOOP
      vr_vljura60_249 := 0;
      OPEN cr_crapris_249_jura60(pr_cdcooper => pr_cdcooper
                                ,pr_dtultdia => vr_dtrefere
                                ,pr_cdorigem => 3
                                ,pr_cdmodali => 499
                                ,pr_tpemprst => 2
                                ,pr_cdagenci => rw_crapris_249.cdagenci);
      FETCH cr_crapris_249_jura60 INTO vr_vljura60_249;
      CLOSE cr_crapris_249_jura60;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_cdagenci := rw_crapris_249.cdagenci;
      vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris_249.cdagenci).vr_vllanmto, 0) + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
      vr_vltotorc := vr_vltotorc + nvl(rw_crapris_249.saldo_devedor, 0) + nvl(vr_vljura60_249, 0);
    END LOOP;   

    vr_flgrvorc := false; 
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_flgrvorc := true;  
    vr_flgctpas := false; 
    vr_flgctred := false; 
    vr_lsctaorc := ',1607,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS POSFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                              || vr_utlfileh || '/' || pr_retfile || ' 2>/dev/null';

    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    vr_dircon := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISCO/CONTABEIS';
     
    vr_arqcon := to_char(vr_dtmvtolt, 'yy') ||
                 to_char(vr_dtmvtolt, 'mm') ||
                 to_char(vr_dtmvtolt, 'dd') ||
                 '_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||
                 '_RISCO.txt';

    vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||pr_retfile||' > '||
                               vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

   IF vr_typ_saida = 'ERR' THEN
     RAISE vr_exc_erro;
   END IF;

   vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

   GENE0001.pc_OScommand(pr_typ_comando => 'S'
                        ,pr_des_comando => vr_dscomando
                        ,pr_typ_saida   => vr_typ_saida
                        ,pr_des_saida   => vr_dscritic);

   IF vr_typ_saida = 'ERR' THEN
     RAISE vr_exc_erro;
   END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN vr_file_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      
      pr_dscritic := 'Erro em RISC0001.pc_risco_k: ' || SQLERRM;
      cecred.pc_internal_exception (pr_cdcooper => 3
                                   ,pr_compleme => pr_dscritic);

  END pc_risco_k;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    
    pc_risco_k(pr_cdcooper  => rw_crapcop.cdcooper
              ,pr_dtrefere  => vr_dtrefere
              ,pr_retfile   => vr_retfile
              ,pr_dscritic  => vr_dscritic);
    IF TRIM(vr_dscritic) <> '' THEN
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
  END LOOP;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
