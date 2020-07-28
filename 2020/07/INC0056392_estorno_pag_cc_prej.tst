PL/SQL Developer Test script 3.0
590
-- Created on 24/07/2020 by F0032386 
declare 

  vr_dtlanct_estorno DATE := to_date('22/07/2020','DD/MM/RRRR');
  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_des_erro             VARCHAR2(100);
  vr_excerro              EXCEPTION;
  
  vr_nmcooper             VARCHAR2(2000);
  vr_nrdconta             NUMBER;
  vr_nrctremp             NUMBER;
  vr_tipo                 VARCHAR2(2000);
  vr_vlestorn             NUMBER;
  
  TYPE typ_linhas IS TABLE OF varchar2(4000)
  INDEX BY PLS_INTEGER;
  
  vr_tab_linha  typ_linhas;          
  vr_tab_campos gene0002.typ_split;
  
  
  CURSOR cr_acordo  (pr_cdcooper   NUMBER,
                     pr_nrdconta   NUMBER,
                     pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c
     WHERE a.nracordo = c.nracordo      
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp;
  
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_acordo_2  (pr_nmrescop   VARCHAR2,
                       pr_nrdconta   NUMBER,
                       pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao,ass.inprejuz,a.cdcooper,a.nrdconta
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c,
           crapcop cop,
           crapass ass
     WHERE a.cdcooper = cop.cdcooper
       AND cop.nmrescop = pr_nmrescop
       AND a.nracordo = c.nracordo 
       AND a.cdcooper = ass.cdcooper
       AND a.nrdconta = ass.nrdconta     
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp
       AND c.cdorigem = 1
       ORDER BY a.nracordo DESC;
  rw_acordo_2 cr_acordo_2%ROWTYPE;
  

  PROCEDURE pc_grava_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                  ,pr_totalest IN tbcc_prejuizo_detalhe.vllanmto%TYPE --> Total a estornar
                                  ,pr_justific IN VARCHAR2                            --> Descrição da justificativa
                                  --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_des_erro OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_grava_estorno_preju
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Agosto/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia :
    Objetivo   : Rotina responsável por gerar os históricos específicos para o estorno da CC em prejuízo.
    Alterações :

                 25/09/2018 - Validar campo justificativa do estorno da Conta Transitória
                              PJ 450 - Diego Simas (AMcom)

                 16/10/2018 - Ajuste na rotina para realizar o estorno do abono na conta corrente do cooperado.
                              PRJ450-Regulatorio(Odirlei-AMcom)


    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar ultimo lancamento de prejuizo
    CURSOR cr_detalhe_ult_lanc(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                               pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE)IS
    SELECT d.dthrtran,
           d.idprejuizo
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.cdhistor IN (2733, --> REC. PREJUIZO
                          2723, --> ABONO PREJUIZO
                          2725, --> BX.PREJ.PRIN
                          2727, --> BX.PREJ.JUROS
                          2729) --> BX.PREJ.JUROS        
  ORDER BY d.dtmvtolt DESC, d.dthrtran DESC;
    rw_detalhe_ult_lanc cr_detalhe_ult_lanc%ROWTYPE;

    --> Consultar todos os historicos para soma à estornar
    --> 2723 – Abono de prejuízo
    --> 2725 – Pagamento do valor principal do prejuízo
    --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
    --> 2729 – Pagamento dos juros remuneratórios do prejuízo
    --> 2323 – Pagamento de IOF provisionado
    --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
    CURSOR cr_detalhe_tot_est(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                              pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE,
                              pr_dthrtran tbcc_prejuizo_detalhe.dthrtran%TYPE)IS
    SELECT d.cdhistor
          ,d.vllanmto
          ,d.idprejuizo
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.dthrtran = pr_dthrtran
       AND(d.cdhistor = 2723  --> 2723 – Abono de prejuízo
        OR d.cdhistor = 2725  --> 2725 – Pagamento do valor principal do prejuízo
        OR d.cdhistor = 2727  --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
        OR d.cdhistor = 2729  --> 2729 – Pagamento dos juros remuneratórios do prejuízo
                OR d.cdhistor = 2323  --> 2323 – Pagamento do IOF
        OR d.cdhistor = 2721  --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
        OR d.cdhistor = 2733) --> 2733 - Débito para pagamento do prejuízo (para fins contábeis)
  ORDER BY d.dtmvtolt, d.dthrtran DESC, d.cdhistor ASC;
    rw_detalhe_tot_est cr_detalhe_tot_est%ROWTYPE;
        
     -- Carrega o calendário de datas da cooperativa
     rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_cdhistor tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_valoriof tbcc_prejuizo_detalhe.vllanmto%TYPE;
    vr_valordeb tbcc_prejuizo_detalhe.vllanmto%TYPE;
    vr_nrdocmto NUMBER;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;
        
        vr_incrineg INTEGER;
        vr_tab_retorno LANC0001.typ_reg_retorno;
        vr_nrseqdig craplcm.nrseqdig%TYPE;
        
        vr_vlest_princ NUMBER;
        vr_vlest_jur60 NUMBER;
        vr_vlest_jupre NUMBER;
        vr_vlest_abono NUMBER;
        vr_vlest_IOF   NUMBER := 0;
    vr_vldpagto    NUMBER := 0;
    vr_vlest_saldo NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    
    vr_cdcooper := pr_cdcooper;
    vr_nmdatela := 'ESTORN';
    vr_cdagenci := 1;
    vr_nrdcaixa := 100;
    vr_idorigem := 7;
    vr_cdoperad := 1;
    
        
        OPEN BTCH0001.cr_crapdat(pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;

    

    -----> PROCESSAMENTO PRINCIPAL <-----
    
    IF nvl(ltrim(pr_justific), 'VAZIO') = 'VAZIO'  THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Obrigatório o preenchimento do campo justificativa';
       RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_detalhe_ult_lanc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);

    FETCH cr_detalhe_ult_lanc INTO rw_detalhe_ult_lanc;

    IF cr_detalhe_ult_lanc%FOUND THEN
       CLOSE cr_detalhe_ult_lanc;
       FOR rw_detalhe_tot_est IN cr_detalhe_tot_est(pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_dthrtran => rw_detalhe_ult_lanc.dthrtran) LOOP

           IF rw_detalhe_tot_est.cdhistor = 2723 THEN
              -- 2724 <- ESTORNO - > Abono de prejuízo
                            vr_vlest_abono := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2724;
           ELSIF rw_detalhe_tot_est.cdhistor = 2725 THEN
              -- 2726 <- ESTORNO - > Pagamento do valor principal do prejuízo
              vr_cdhistor := 2726;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
              vr_vlest_saldo := nvl(rw_detalhe_tot_est.vllanmto,0);
           ELSIF rw_detalhe_tot_est.cdhistor = 2727 THEN
              -- 2728 <- ESTORNO - > Pagamento dos juros +60 da transferência para prejuízo
                            vr_vlest_jur60 := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2728;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
           ELSIF rw_detalhe_tot_est.cdhistor = 2729 THEN
              -- 2730 <- ESTORNO - > Pagamento dos juros remuneratórios do prejuízo
                            vr_vlest_jupre := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2730;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
                     ELSIF rw_detalhe_tot_est.cdhistor = 2323 THEN
              -- 2323 <- ESTORNO - > Pagamento do IOF
                            vr_vlest_IOF := rw_detalhe_tot_est.vllanmto;
           ELSIF rw_detalhe_tot_est.cdhistor = 2721 THEN
              -- 2722 <- ESTORNO - > Débito para pagamento do prejuízo (para fins contábeis)
              vr_cdhistor := 2722;
           ELSIF rw_detalhe_tot_est.cdhistor = 2733 THEN
              -- 2732 <- ESTORNO - > Débito para pagamento do prejuízo
              vr_cdhistor := 2732;
                            vr_vlest_princ := rw_detalhe_tot_est.vllanmto;
              vr_valordeb := rw_detalhe_tot_est.vllanmto;
           END IF;

           IF rw_detalhe_tot_est.cdhistor NOT IN (2323,2723) THEN
                            -- insere o estorno com novo histórico
                            BEGIN
                                INSERT INTO tbcc_prejuizo_detalhe (
                                     dtmvtolt
                                    ,nrdconta
                                    ,cdhistor
                                    ,vllanmto
                                    ,dthrtran
                                    ,cdoperad
                                    ,cdcooper
                                    ,idprejuizo
                                    ,dsjustificativa
                                 )
                                 VALUES (
                                     rw_crapdat.dtmvtolt
                                    ,pr_nrdconta
                                    ,vr_cdhistor
                                    ,rw_detalhe_tot_est.vllanmto
                                    ,SYSDATE
                                    ,vr_cdoperad
                                    ,pr_cdcooper
                                    ,rw_detalhe_tot_est.idprejuizo
                                    ,pr_justific
                                 );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_cdcritic := 0;
                                    vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe: '||SQLERRM;
                                    RAISE vr_exc_erro;
                            END;
                        END IF;
       END LOOP;

       
       
      IF vr_valordeb > 0 THEN
       -- Insere lançamento com histórico 2738
       BEGIN
         INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
                 dtmvtolt
               , cdagenci
               , nrdconta
               , nrdocmto
               , cdhistor
               , vllanmto
               , dthrtran
               , cdoperad
               , cdcooper
               , cdorigem
          )
          VALUES (
                 rw_crapdat.dtmvtolt
               , vr_cdagenci
               , pr_nrdconta
               , 999992722
               , 2738 
               , vr_valordeb
               , SYSDATE
               , vr_cdoperad
               , pr_cdcooper
               , 5
          );
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
            
            vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                    to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

        vr_nrdocmto := 999992722; 
        LOOP
          
            LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => vr_cdagenci
                                       , pr_cdbccxlt => vr_nrdcaixa
                                       , pr_nrdolote => 650009
                                       , pr_nrdconta => pr_nrdconta
                                         , pr_nrdocmto => vr_nrdocmto
                                       , pr_cdhistor => 2719
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_valordeb
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE PAGAMENTO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
                                       , pr_hrtransa => gene0002.fn_busca_time
                                         , pr_cdoperad => vr_cdoperad
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_cdorigem => 5
                                                                             , pr_incrineg => vr_incrineg
                                                                             , pr_tab_retorno => vr_tab_retorno
                                                                             , pr_cdcritic => vr_cdcritic
                                                                             , pr_dscritic => vr_dscritic);
                                                                             
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN
              IF vr_cdcritic = 92 THEN
                vr_nrdocmto := vr_nrdocmto + 10000;
                continue;
            END IF;
              RAISE vr_exc_erro;
            ELSE
                RAISE vr_exc_erro;
            END IF;
          END IF;
          
          EXIT;
        
        END LOOP;
        
        
      END IF;
      
      vr_vldpagto := nvl(vr_vldpagto,0) - nvl(vr_valordeb,0);
      
    ELSE
       CLOSE cr_detalhe_ult_lanc;
    END IF;
    
    --> Extornar Abono
    IF vr_vldpagto > 0 AND 
       vr_vlest_abono > 0 THEN
      
     IF vr_vlest_abono < vr_vldpagto THEN
       vr_dscritic := 'Não possui valor de abono suficiente para estorno do pagamento.';
       RAISE vr_exc_erro;     
     END IF;
    
      --> Estorno na prejuizo detalhe
      BEGIN
        INSERT INTO tbcc_prejuizo_detalhe (
           dtmvtolt
          ,nrdconta
          ,cdhistor
          ,vllanmto
          ,dthrtran
          ,cdoperad
          ,cdcooper
          ,idprejuizo
          ,dsjustificativa
         )
         VALUES (
           rw_crapdat.dtmvtolt
          ,pr_nrdconta
          ,2724 -- ESTORNO - > Abono de prejuízo
          ,vr_vldpagto
          ,SYSDATE
          ,vr_cdoperad
          ,pr_cdcooper
          ,rw_detalhe_ult_lanc.idprejuizo
          ,pr_justific
         );
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe(2724): '||SQLERRM;
          RAISE vr_exc_erro;
      END;                    
      
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                               '1;100;650009');

      vr_nrdocmto := 999992724; 
      LOOP
          
      LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => vr_cdagenci
                                       , pr_cdbccxlt => vr_nrdcaixa
                                       , pr_nrdolote => 650009
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_nrdocmto => vr_nrdocmto
                                       , pr_cdhistor => 2724
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_vldpagto
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE ABONO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
                                       , pr_hrtransa => gene0002.fn_busca_time
                                       , pr_cdoperad => vr_cdoperad
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_cdorigem => 5
                                       , pr_incrineg => vr_incrineg
                                       , pr_tab_retorno => vr_tab_retorno
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);
                                                                             
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          IF vr_incrineg = 0 THEN
            IF vr_cdcritic = 92 THEN
              vr_nrdocmto := vr_nrdocmto + 10000;
              continue;
      END IF;
            RAISE vr_exc_erro;
          ELSE
            RAISE vr_exc_erro;
          END IF;
        END IF;
          
        EXIT;
        
      END LOOP;
      
      --> atualizar valor de abono com o valor que realmente conseguiu abonar
      vr_vlest_abono := vr_vldpagto;
      vr_vldpagto    := 0;
      
    END IF;   
     
        
        BEGIN
            UPDATE tbcc_prejuizo prj
                 SET prj.vlrabono = prj.vlrabono - nvl(vr_vlest_abono, 0)
                     , prj.vljur60_ctneg = prj.vljur60_ctneg + nvl(vr_vlest_jur60, 0)
                     , prj.vljuprej = prj.vljuprej + nvl(vr_vlest_jupre,0)
                     , prj.vlpgprej = prj.vlpgprej - (nvl(vr_vlest_princ,0) + nvl(vr_vlest_IOF,0))
                     , prj.vlsdprej = prj.vlsdprej + (nvl(vr_vlest_saldo,0))
             WHERE prj.idprejuizo = rw_detalhe_ult_lanc.idprejuizo;
        EXCEPTION
            WHEN OTHERS THEN
                vr_cdcritic := 0;
        vr_dscritic := 'Erro de update na TBCC_PREJUIZO: ' || SQLERRM;
        RAISE vr_exc_erro;
        END;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_grava_estorno_preju --> '|| SQLERRM;


  END pc_grava_estorno_preju;


BEGIN 
  vr_tab_linha(vr_tab_linha.count) := 'CREDELESC;25828;25828;baca;200,81;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;379131;379131;baca;143,33;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'TRANSPOCRED;150738;150738;baca;183,44;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'UNILOS;113557;113557;baca;2220;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8624895;8624895;baca;435;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;10018450;10018450;baca;36,28;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8885079;8885079;baca;108,48;Sai dinheiro da transitoria e recuperou prejuízo de cc';
--  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8885079;8885079;baca;108,48;Sai dinheiro da transitoria e recuperou prejuízo de cc'; --> duplicado
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9005161;9005161;baca;100,54;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9466118;9466118;baca;104,44;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;10205861;10205861;baca;101,35;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;443301;443301;baca;100,81;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;184357;184357;baca;307,56;Sai dinheiro da transitoria e recuperou prejuízo de cc';


  FOR i IN vr_tab_linha.first..vr_tab_linha.count-1 LOOP
    
    vr_tab_campos := gene0002.fn_quebra_string(pr_string => vr_tab_linha(i), 
                                               pr_delimit => ';');
                                               
                              
    vr_nmcooper := vr_tab_campos(1);
    vr_nrdconta := vr_tab_campos(2);
    vr_nrctremp := vr_tab_campos(3);
    vr_tipo     := vr_tab_campos(4);
    vr_vlestorn := gene0002.fn_char_para_number(vr_tab_campos(5));
    
    IF upper(vr_tipo) = 'BACA' THEN
      dbms_output.put_line(vr_tab_linha(i));  
      OPEN cr_acordo_2 ( pr_nmrescop  => vr_nmcooper,
                         pr_nrdconta  => vr_nrdconta,
                         pr_nrctremp  => vr_nrctremp);
      FETCH cr_acordo_2 INTO rw_acordo_2;
      
      IF cr_acordo_2%NOTFOUND THEN
        CLOSE cr_acordo_2; 
        dbms_output.put_line('  --> NAO ENCONTRADO');  
        continue;
      ELSE
        CLOSE cr_acordo_2;
        IF rw_acordo_2.cdsituacao <> 1 THEN
          dbms_output.put_line('  --> ACORDO NAO ESTA ATIVO');      
        ELSIF rw_acordo_2.inprejuz <> 1 THEN
          dbms_output.put_line('  --> CONTA NAO ESTA EM PREJUIZO');       
        END IF;      
      
      END IF;    
      
      
      BEGIN
        UPDATE tbrecup_acordo a  
           SET a.cdsituacao = 3 -- mudar para cancelado temporariamente
         WHERE a.nracordo = rw_acordo_2.nracordo;  
      END;
          
      pc_grava_estorno_preju(pr_cdcooper => rw_acordo_2.cdcooper
                            ,pr_nrdconta => rw_acordo_2.nrdconta
                            ,pr_totalest => vr_vlestorn
                            ,pr_justific => 'Pagamento de parcela indevida pelo modelo de acordo'
                            --> CAMPOS IN/OU
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_des_erro => vr_des_erro);

      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_excerro;
      END IF; 
      
       BEGIN
        UPDATE tbrecup_acordo a  
           SET a.cdsituacao = rw_acordo_2.cdsituacao -- voltar para o valor original
         WHERE a.nracordo = rw_acordo_2.nracordo;  
       END;
    END IF;
  END LOOP;    
  
  COMMIT;
EXCEPTION
   WHEN vr_excerro THEN    
     ROLLBACK; 
     raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic);
end;
0
2
pr_nrdconta
pr_dthrtran
