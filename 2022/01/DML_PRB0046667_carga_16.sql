DECLARE


  CURSOR cr_crapcop IS
    SELECT c.cdcooper,
           d.dtmvtoan
      FROM crapcop c,
           crapdat d
     WHERE c.cdcooper = d.cdcooper
       AND c.flgativo = 1
       AND c.cdcooper = 16
     ORDER BY c.cdcooper DESC;

  PROCEDURE cargaHistoricoJuros60 (pr_cdcooper IN NUMBER,
                                   pr_dtmvtoan IN DATE ) IS
    
    pr_nrdconta NUMBER;
    
    pr_vlsld59d NUMBER;
    pr_dtmvtolt DATE;
    pr_dtlimite DATE;
    pr_vlju6037 NUMBER;
    pr_vlju6038 NUMBER;
    pr_vlju6057 NUMBER;
    
    vr_contador NUMBER := 0;
    
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
    
    vr_vliofprj           NUMBER;
    vr_saldo_dia          NUMBER;
    vr_est_jur60          NUMBER;
    vr_dtprejuz           DATE;
    vr_data_59dias_atraso DATE;
    vr_dtinilan           DATE;
    vr_dtrefere           DATE;
    
    
    CURSOR cr_crapris (pr_cdcooper IN NUMBER,
                       pr_dtmvtoan IN DATE ) IS
      SELECT r.cdcooper,
             r.nrdconta,
             r.dtrefere,
             r.qtdiaatr,
             a.vllimcre           
        FROM crapris r,
             crapass a
       WHERE r.cdcooper = a.cdcooper
         AND r.nrdconta = a.nrdconta
         AND r.cdcooper = pr_cdcooper
         AND r.dtrefere = pr_dtmvtoan 
         AND r.cdmodali = 101
         AND r.qtdiaatr >= 60;


    -- Recupera dados da CRAPLCM para compor saldo devedor até 59 dias e valores de juros +60
    CURSOR cr_craplcm(pr_cdcooper IN NUMBER
                    , pr_nrdconta IN NUMBER
                    , pr_dtlimite IN DATE
                    , pr_dt59datr IN crapris.dtinictr%TYPE
                    , pr_dtprejuz IN tbcc_prejuizo.dtinclusao%TYPE
                    , pr_dtmvtolt IN crapsda.dtmvtolt%TYPE) IS
      SELECT *
      FROM (
          WITH lancamentos AS (
            SELECT lcm.dtmvtolt dtmvtolt
                 , his.cdhistor cdhistor
                 , his.indebcre indebcre
                 , lcm.vllanmto vllanmto
                               , 0            vlsddisp
                               , 0            vlsdante
                               , 0            vldifsld
      FROM craplcm lcm
         , craphis his
               WHERE his.cdcooper = lcm.cdcooper
                   AND his.cdhistor   = lcm.cdhistor
                   AND lcm.cdcooper = pr_cdcooper
                   AND lcm.nrdconta = pr_nrdconta
                   AND lcm.dtmvtolt > pr_dt59datr
                   AND lcm.cdhistor IN (37,38,57,2718,2323)
                   AND (pr_dtlimite IS NULL OR lcm.dtmvtolt <= pr_dtlimite)
                      UNION
                      SELECT sda.dtmvtolt dtmvtolt
                           , 0            cdhistor
                               , 'X'          indebcre
                               , 0            vllanmto
                               , abs(sda.vlsddisp) vlsddisp
                 , LAG(abs(sda.vlsddisp)) OVER(ORDER BY sda.dtmvtolt) vlsdante
                 , NVL((LAG(abs(sda.vlsddisp)) OVER(ORDER BY sda.dtmvtolt) ) - abs(sda.vlsddisp) ,0) vldifsld
                        FROM crapsda sda
                       WHERE sda.cdcooper = pr_cdcooper
               AND sda.nrdconta = pr_nrdconta
               AND sda.dtmvtolt >= pr_dt59datr
                           AND (pr_dtlimite IS NULL OR sda.dtmvtolt <= pr_dtlimite)
                      UNION
                      -- Cria registro para o dia atual (que não tem saldo na CRAPSDA)
                      SELECT pr_dtmvtolt   dtmvtolt
                 , 0             cdhistor
                 , 'X'           indebcre
                 , 0             vllanmto
                 , 0             vlsddisp
                 , 0             vlsdante
                 , nvl(SUM(decode(his.indebcre, 'C', vllanmto, vllanmto * -1)), 0) vldifsld
              FROM craplcm lcm
                 , craphis his
             WHERE his.cdcooper = lcm.cdcooper
               AND his.cdhistor = lcm.cdhistor
               AND lcm.cdcooper = pr_cdcooper
               AND lcm.nrdconta = pr_nrdconta
               AND lcm.dtmvtolt = pr_dtmvtolt
                           AND NOT EXISTS (
                                SELECT 1
                                        FROM crapsda aux
                                       WHERE aux.cdcooper = lcm.cdcooper
                                         AND aux.nrdconta = lcm.nrdconta
                                           AND aux.dtmvtolt = pr_dtmvtolt
                               )
          )
          SELECT 'jur60_37' tipo
                   , lct.dtmvtolt
                   , sum(lct.vllanmto) valor
              FROM lancamentos lct
           WHERE lct.cdhistor = 37
           GROUP BY lct.dtmvtolt
          UNION
          SELECT 'jur60_38' tipo
                   , lct.dtmvtolt
                   , SUM(lct.vllanmto) valor
           FROM lancamentos lct
          WHERE lct.cdhistor = 38
          GROUP BY lct.dtmvtolt
          UNION
          SELECT 'jur60_57' tipo
                   , lct.dtmvtolt
                   , SUM(lct.vllanmto) valor
           FROM lancamentos lct
          WHERE lct.cdhistor = 57
          GROUP BY lct.dtmvtolt
          UNION
          SELECT 'jur60_2718' tipo
                   , lct.dtmvtolt
                   , SUM(lct.vllanmto) valor
           FROM lancamentos lct
          WHERE lct.cdhistor = 2718
          GROUP BY lct.dtmvtolt
          UNION
          SELECT 'iof_prej' tipo
                   , lct.dtmvtolt
                   , SUM(lct.vllanmto) valor
           FROM lancamentos lct
          WHERE lct.cdhistor = 2323
              AND pr_dtprejuz IS NOT NULL
              AND lct.dtmvtolt >= pr_dtprejuz
          GROUP BY lct.dtmvtolt
          UNION
          SELECT 'vlsddisp' tipo
                   , lct.dtmvtolt
                   , SUM(lct.vlsddisp) valor
           FROM lancamentos lct
           WHERE lct.cdhistor = 0
           GROUP BY lct.dtmvtolt
          UNION
          SELECT 'vlsdante' tipo
               , lct.dtmvtolt
                   , SUM(lct.vlsdante) valor
            FROM lancamentos lct
           WHERE lct.cdhistor = 0
           GROUP BY lct.dtmvtolt
           UNION
           SELECT 'vldifsld' tipo
               , lct.dtmvtolt
                   , SUM(lct.vldifsld) valor
            FROM lancamentos lct
           WHERE lct.cdhistor = 0
          GROUP BY lct.dtmvtolt
      )
      PIVOT
      (
         SUM(valor)
           FOR tipo IN ('jur60_37'   AS jur60_37
                      , 'jur60_38'   AS jur60_38
                      , 'jur60_57'   AS jur60_57
                      , 'jur60_2718' AS jur60_2718
                      , 'iof_prej'   AS iof_prej
                      , 'vlsddisp'   AS vlsddisp
                      , 'vlsdante'   AS vlsdante
                      , 'vldifsld'   AS vldifsld)
      )
      ORDER BY dtmvtolt;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    CURSOR cr_prejuizo (pr_cdcooper IN NUMBER,
                        pr_nrdconta IN NUMBER)IS
      SELECT dtinclusao
        FROM tbcc_prejuizo
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
           AND dtliquidacao IS NULL;

    -- Busca o saldo da conta para o dia em que ela atingiu 59 dias de atraso
    CURSOR cr_crapsda( pr_cdcooper IN NUMBER,
                       pr_nrdconta IN NUMBER,
                       pr_dt59datr IN DATE) IS
      SELECT abs(sda.vlsddisp)
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dt59datr;

    -- Consulta o valor estornado de juros +60 na conta corrente em prejuízo
    CURSOR cr_estjur60( pr_cdcooper IN NUMBER,
                        pr_nrdconta IN NUMBER,
                        pr_dtmvtolt DATE) IS
      SELECT nvl(SUM(decode(cdhistor, 2728, vllanmto, vllanmto * -1)), 0) total_estorno
        FROM tbcc_prejuizo_detalhe prj
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtmvtolt = pr_dtmvtolt
         AND cdhistor IN (2727, 2728);       


    FUNCTION fn_valida_dia_util(pr_cdcooper NUMBER, pr_dtmvtolt DATE)
        RETURN BOOLEAN AS vr_dia_util BOOLEAN;


      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                     ,pr_dtcompar IN crapfer.dtferiad%TYPE) IS
      SELECT cf.dsferiad
        FROM crapfer cf
       WHERE cf.cdcooper = pr_cdcooper
         AND cf.dtferiad = pr_dtcompar;
      rw_crapfer cr_crapfer%ROWTYPE;

      ----->>> VARIÁVEIS <<<-----

      vr_dtcompar DATE;
      vr_contador   INTEGER := 0;

    BEGIN
        vr_dtcompar := pr_dtmvtolt;

        -- Busca se a data é feriado
        OPEN cr_crapfer(pr_cdcooper, vr_dtcompar);
        FETCH cr_crapfer INTO rw_crapfer;

        -- Se a data não for sabado ou domingo ou feriado
        vr_dia_util := NOT(TO_CHAR(vr_dtcompar, 'd') IN (1,7) OR cr_crapfer%FOUND);

        CLOSE cr_crapfer;

        RETURN vr_dia_util;
    END fn_valida_dia_util;
    
    
    FUNCTION fn_calcula_saldo_cheques(pr_cdcooper crapcop.cdcooper%TYPE
                                     ,pr_nrdconta crapass.nrdconta%TYPE
                                     ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                     ,pr_database crapdat.dtmvtolt%TYPE
                                     ,pr_vldsaldo craplcm.vllanmto%TYPE
                                     ,pr_tpdsaldo NUMBER DEFAULT 1
                                     ) RETURN NUMBER IS
     /*-----------------------------------------------
       Programa: fn_calcula_saldo_cheques
       Sistema : CRED
       Autor   : Guilherme/AMcom
       Data    : Outubro/2020                    Ultima atualizacao: 29/01/2021

       Dados referentes ao programa:

       Objetivo  : Tratar saldo do dia quando há cheques devolvidos, não considerando cheques no saldo disp.
       
       Alterações 29/01/2021 - RISCOS - Correção da rotina quando o cheque era devolvido
                               no dia exato de inicio do Saldo59d.
                               (Guilherme/AMcom)

      -------------------------------------------------------------------------------------------------------------*/

      vr_saldo_dia_int  craplcm.vllanmto%TYPE :=0;
      vr_qtdCheques   NUMBER;
      vr_found_chq    BOOLEAN;
      vr_data_cheque  DATE;
      vr_data_dodia   DATE;

      CURSOR cr_hist_cheques(pr_dtmvtolt IN DATE) IS
        SELECT nvl(decode(h.indebcre, 'C', l.vllanmto, l.vllanmto * -1), 0) vl_lancto_cheque
              ,h.indebcre
              ,l.nrdocmto
              ,l.dtmvtolt
          FROM craplcm l, craphis h
         WHERE l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND h.cdcooper = l.cdcooper
           AND h.cdhistor = l.cdhistor
           AND l.dtmvtolt = pr_dtmvtolt
           AND ( (l.cdhistor IN (21,524,572) )           -- Debitos
                 OR
                 (l.cdhistor IN (47, 191, 338, 573,78) ) -- Creditos
               )
            ORDER BY l.progress_recid;
      rw_hist_cheques  cr_hist_cheques%ROWTYPE;

      CURSOR cr_tem_lcm(pr_dtmvtolt IN DATE
                       ,pr_dtlimite IN DATE
                       ,pr_vllanmto IN craplcm.vllanmto%TYPE
                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                       ,pr_indebcre IN VARCHAR2) IS
        SELECT nvl(decode(h.indebcre, 'C', l.vllanmto, l.vllanmto * -1), 0) vllanmto
              ,h.indebcre
              ,l.dtmvtolt
          FROM craplcm l,craphis h
         WHERE l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND l.nrdocmto = pr_nrdocmto
           AND l.vllanmto = pr_vllanmto
           AND l.dtmvtolt >= pr_dtmvtolt
           AND l.dtmvtolt <= pr_dtlimite
           AND h.cdcooper = l.cdcooper
           AND h.cdhistor = l.cdhistor
           AND ( (l.cdhistor IN (21,524,572) AND        --Debitos
                  pr_indebcre = 'C'
                 )
                 OR
                 (l.cdhistor IN (47, 191, 338, 573,78) AND  -- Creditos
                  pr_indebcre = 'D'
                 )
              );
      rw_tem_lcm   cr_tem_lcm%ROWTYPE;

    BEGIN
      vr_saldo_dia_int := pr_vldsaldo;
      IF  pr_tpdsaldo = 0
      AND pr_vldsaldo > 0  THEN
        -- Para essa rotina precisamos trabalhar com
        -- o saldo59 com o valor negativo
        -- e garantir que ele veio como "positivo" na chamada
        vr_saldo_dia_int := vr_saldo_dia_int * (-1);
      END IF;

      FOR rw_hist_cheques IN cr_hist_cheques(pr_database) LOOP

        vr_data_cheque := pr_database;
        vr_data_dodia  := pr_database;

        IF rw_hist_cheques.indebcre = 'C' THEN
           vr_data_dodia := vr_data_cheque - 1;
          -- Verificar se "ontem" teve um DEBITO
          WHILE NOT fn_valida_dia_util(pr_cdcooper, vr_data_dodia)  LOOP
            vr_data_dodia := vr_data_dodia - 1;
          END LOOP;
        ELSE -- D - DEBITOS
          vr_data_cheque := vr_data_cheque + 1;
          -- Verificar se "amanhã" haverá um CREDITO
          WHILE NOT fn_valida_dia_util(pr_cdcooper, vr_data_cheque)  LOOP
            vr_data_cheque := vr_data_cheque + 1;
          END LOOP;
        END IF;

        -- Verificar lançamentos equivalentes
        OPEN cr_tem_lcm(pr_dtmvtolt => vr_data_dodia
                       ,pr_dtlimite => vr_data_cheque
                       ,pr_vllanmto => abs(rw_hist_cheques.vl_lancto_cheque)
                       ,pr_nrdocmto => rw_hist_cheques.nrdocmto
                       ,pr_indebcre => rw_hist_cheques.indebcre
                                       );
        FETCH cr_tem_lcm INTO rw_tem_lcm;
        vr_found_chq   := cr_tem_lcm%FOUND;
        CLOSE cr_tem_lcm;

        IF vr_found_chq     -- Se encontrou o cheque
        AND rw_tem_lcm.dtmvtolt <> rw_hist_cheques.dtmvtolt THEN

          IF pr_tpdsaldo = 0 THEN
            -- No dia do Saldo59d
            IF rw_hist_cheques.indebcre = 'D' THEN
              -- Apenas quando é DEBITO do cheque
              -- crédito ja foi considerado, debito no saldo do dia anterior, nada fazer
              -- "Estou devolvendo o valor do cheque para o valor do saldo do dia"
              vr_saldo_dia_int := vr_saldo_dia_int - rw_hist_cheques.vl_lancto_cheque;

            END IF;

          ELSE -- Acima de 60d
            --se achou, deve retirar o valor do saldo
             vr_saldo_dia_int := vr_saldo_dia_int - rw_hist_cheques.vl_lancto_cheque;

          END IF;
        END IF;  -- FIM IF vr_found_chq

      END LOOP;

      IF  pr_tpdsaldo = 0  THEN
        vr_saldo_dia_int := abs(vr_saldo_dia_int);
      END IF;

      RETURN vr_saldo_dia_int;
    END fn_calcula_saldo_cheques;



  BEGIN
    

    vr_contador := 0;

    FOR rw_crapris IN cr_crapris (pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtoan => pr_dtmvtoan) LOOP
      vr_contador := vr_contador + 1; 
      
      BEGIN
        
        pr_nrdconta := rw_crapris.nrdconta; 
        pr_dtmvtolt := rw_crapris.dtrefere;
        pr_dtlimite := rw_crapris.dtrefere;
        
        pr_vlju6037 := 0;
        pr_vlju6038 := 0;
        pr_vlju6057 := 0;
        vr_vliofprj := 0;
        pr_vlsld59d := 0;

      
        -- Busca data em que a conta foi transferida para prejuízo
        OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_prejuizo INTO vr_dtprejuz;

        IF cr_prejuizo%NOTFOUND THEN
          vr_dtprejuz := NULL;
        END IF;

        CLOSE cr_prejuizo;

      
        -- Calcula a data em que a aconta atingiu 59 dias de atraso
        vr_data_59dias_atraso := TELA_ATENDA_DEPOSVIS.fn_calc_data_59dias_atraso(pr_cdcooper => pr_cdcooper
                                                          , pr_nrdconta => pr_nrdconta);

        -- Busca o primeiro dia útil anterior a data calculada de 59 dias de atraso
        WHILE NOT fn_valida_dia_util(pr_cdcooper, vr_data_59dias_atraso)  LOOP
          vr_data_59dias_atraso := vr_data_59dias_atraso - 1;
         END LOOP;
              
        -- Recupera o saldo do dia em que a conta atingiu 59 dias de atraso
        OPEN cr_crapsda (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_dt59datr => vr_data_59dias_atraso);
        FETCH cr_crapsda INTO pr_vlsld59d;

        IF cr_crapsda%NOTFOUND THEN
          CLOSE cr_crapsda;
          CONTINUE;
        END IF;
        CLOSE cr_crapsda;

        -- Desconta o limite de crédito ativo do saldo devedor total
        pr_vlsld59d := pr_vlsld59d - rw_crapris.vllimcre;

        -- Verificar se houve cheque D/C no dia do saldo59d
        pr_vlsld59d := fn_calcula_saldo_cheques(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_database => vr_data_59dias_atraso
                                               ,pr_vldsaldo => pr_vlsld59d
                                               ,pr_tpdsaldo => 0
                                               );

        vr_dtinilan := vr_data_59dias_atraso; 
        vr_dtrefere := pr_dtmvtolt;  
        

        -- Percorre os lançamentos ocorridos após 60 dias de atraso que não sejam juros +60
        FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_dtlimite => pr_dtlimite
                                    , pr_dt59datr => vr_dtinilan
                                    , pr_dtprejuz => vr_dtprejuz
                                    , pr_dtmvtolt => vr_dtrefere) LOOP
          -- Descarta o primeiro registro, usado apenas para popular o saldo do dia anterior para a data que completa 60 dias de atraso
          IF rw_craplcm.dtmvtolt = vr_data_59dias_atraso THEN
            CONTINUE;
          END IF;

          pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_37,0);
          pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_2718,0);
          pr_vlju6038 := pr_vlju6038 + nvl(rw_craplcm.jur60_38,0);
          pr_vlju6057 := pr_vlju6057 + nvl(rw_craplcm.jur60_57,0);
          vr_vliofprj := vr_vliofprj + nvl(rw_craplcm.iof_prej,0);

          vr_saldo_dia := rw_craplcm.vldifsld;


          -- Verificar se algum valor do 'Saldo do Dia' é referente a Cheque 
          vr_saldo_dia := fn_calcula_saldo_cheques(pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_database => rw_craplcm.dtmvtolt
                                                  ,pr_vldsaldo => vr_saldo_dia
                                                  );

          IF vr_saldo_dia > 0 THEN -- Se fechou o dia com saldo positivo (crédito)
            vr_saldo_dia := vr_saldo_dia + 
                           (nvl(rw_craplcm.jur60_37, 0) +
                            nvl(rw_craplcm.jur60_38, 0) +
                            nvl(rw_craplcm.jur60_57, 0) +
                            nvl(rw_craplcm.jur60_2718, 0) +
                            nvl(rw_craplcm.iof_prej,0));
          ELSE
            -- Desconta o valor dos juros +60 do saldo do dia (débito)
            vr_saldo_dia := (nvl(rw_craplcm.jur60_37, 0) +
                            nvl(rw_craplcm.jur60_38, 0) +
                            nvl(rw_craplcm.jur60_57, 0) +
                            nvl(rw_craplcm.jur60_2718, 0) +
                            nvl(rw_craplcm.iof_prej, 0))
                            - abs(vr_saldo_dia);
          END IF;



          IF vr_saldo_dia > 0 THEN -- Se fechou o dia com saldo positivo (crédito)
            -- Paga IOF debitado após transferência para prejuízo (se houver)
            IF vr_vliofprj > 0 THEN
              IF vr_saldo_dia >= vr_vliofprj THEN
                vr_saldo_dia := vr_saldo_dia - vr_vliofprj;
                  vr_vliofprj := 0;
              ELSE
                vr_vliofprj := vr_vliofprj - vr_saldo_dia;
                vr_saldo_dia := 0;
              END IF;
            END IF;

            IF vr_saldo_dia > 0 AND pr_vlju6037 > 0 THEN
                -- Amortiza os juros + 60 (Hist. 37 + Hist. 2718)
              IF vr_saldo_dia >= pr_vlju6037 THEN
                vr_saldo_dia := vr_saldo_dia - pr_vlju6037;
                pr_vlju6037 := 0;
              ELSE
                pr_vlju6037 := pr_vlju6037 - vr_saldo_dia;
                vr_saldo_dia := 0;
              END IF;
            END IF;

            IF vr_saldo_dia > 0 AND pr_vlju6038 > 0 THEN
              -- Amortiza os juros + 60 (Hist. 38)
              IF vr_saldo_dia >= pr_vlju6038 THEN
                vr_saldo_dia := vr_saldo_dia - pr_vlju6038;
                pr_vlju6038 := 0;
              ELSE
                pr_vlju6038 := pr_vlju6038 - vr_saldo_dia;
                vr_saldo_dia := 0;
              END IF;
            END IF;

            IF vr_saldo_dia > 0 AND pr_vlju6057 > 0 THEN
              -- Amortiza os juros + 60 (Hist. 57)
              IF vr_saldo_dia >= pr_vlju6057 THEN
                vr_saldo_dia := vr_saldo_dia - pr_vlju6057;
                pr_vlju6057 := 0;
              ELSE
                pr_vlju6057 := pr_vlju6057 - vr_saldo_dia;
                vr_saldo_dia := 0;
              END IF;
            END IF;

            IF vr_saldo_dia > 0 THEN
              -- Amortiza o saldo devedor até 59 dias
              IF vr_saldo_dia >= pr_vlsld59d THEN
                pr_vlsld59d := 0;
              ELSE
                pr_vlsld59d := pr_vlsld59d - vr_saldo_dia;
              END IF;
            END IF;

          ELSIF vr_saldo_dia < 0 THEN -- Se fechou o dia com saldo negativo (débito)
            IF vr_dtprejuz IS NOT NULL AND rw_craplcm.dtmvtolt >= vr_dtprejuz THEN
              OPEN cr_estjur60( pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_dtmvtolt => rw_craplcm.dtmvtolt);
              FETCH cr_estjur60 INTO vr_est_jur60;
              CLOSE cr_estjur60;

              IF vr_est_jur60 > 0 THEN
                pr_vlju6037  := nvl(pr_vlju6037, 0) + vr_est_jur60;
                vr_saldo_dia := vr_saldo_dia        + vr_est_jur60;
              END IF;

            END IF;

            -- Incorpora o débito ao saldo devedor até 59 dias de atraso
            pr_vlsld59d := pr_vlsld59d - vr_saldo_dia; -- menos com menos soma
          END IF;

        END LOOP;

        -- Soma o valor de IOF debitado após a transferência para prejuízo ao saldo 59 dias (se não foi pago pelos créditos ocorridos na conta)
        pr_vlsld59d := pr_vlsld59d + vr_vliofprj;

        -- Tratamento para não mostrar o Saldo Devedor 59D negativo
        IF pr_vlsld59d < 0 THEN
          pr_vlsld59d := 0;
        END IF;
        
        gestaoderisco.incluirHistCCJuros60
                              (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_qtdiaatr => rw_crapris.qtdiaatr,
                               pr_dtmvtolt => pr_dtmvtolt,
                               pr_dtatra59 => vr_data_59dias_atraso,
                               pr_vlsld59d => pr_vlsld59d,
                               pr_vlju6037 => pr_vlju6037,
                               pr_vlju6038 => pr_vlju6038,
                               pr_vlju6057 => pr_vlju6057,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
        
        
        IF MOD(vr_contador,500) = 0 THEN
          COMMIT;      
        END IF;
          
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
    END LOOP; -- Fim loop crapris
    
    COMMIT;
    
  END cargaHistoricoJuros60;



BEGIN
  


  FOR rw_crapcop IN cr_crapcop LOOP
    
    cargaHistoricoJuros60 (pr_cdcooper => rw_crapcop.cdcooper,
                           pr_dtmvtoan => rw_crapcop.dtmvtoan);
  
  
  END LOOP;  


  
END;
