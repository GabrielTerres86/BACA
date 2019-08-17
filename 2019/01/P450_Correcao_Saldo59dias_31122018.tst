PL/SQL Developer Test script 3.0
618
-- Created on 11/01/2019 by T0031667 
declare 
  -- Busca saldo até 59 dias e valores de juros +60 detalhados (hist. 37+2718, hist 38 e hist. 57)

  CURSOR cr_crapcop IS
  SELECT cdcooper
    FROM crapcop cop
   WHERE cdcooper <> 3
     AND cop.flgativo = 1
   ORDER BY cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapris(pr_cdcooper NUMBER) IS 
  SELECT nrdconta
       , qtdiaatr
			 , innivris
			 , progress_recid
    FROM crapris ris
   WHERE cdcooper = pr_cdcooper
     AND dtrefere = to_date('31/12/2018', 'DD/MM/YYYY')
		 AND cdmodali = 101
		 AND nrdconta = nrctremp
		 AND qtdiaatr < 60
		 AND vldivida > 0
		 AND vlsld59d = 0;
	rw_crapris cr_crapris%ROWTYPE;
	
	vr_vlsld59d NUMBER;
vr_vlju6037 NUMBER;
vr_vlju6038 NUMBER;
vr_vlju6057 NUMBER;
vr_cdcritic NUMBER;
vr_dscritic VARCHAR(2000);

vr_cdvencto NUMBER;
	
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
	
PROCEDURE pc_busca_saldos_juros60_det(pr_cdcooper IN crapris.cdcooper%TYPE --> Código da cooperativa
                                    , pr_nrdconta IN crapris.nrdconta%TYPE --> Conta do cooperado
                                    , pr_qtdiaatr IN NUMBER DEFAULT NULL --> Quantidade de dias de atraso (se não informado, a procedure recupera da base)
                                    , pr_dtlimite IN DATE   DEFAULT NULL --> Data limite para filtro dos lançamentos na CRAPLCM
                                    , pr_tppesqui IN NUMBER DEFAULT 1    --> 1|Online  0|Batch
                                    , pr_vlsld59d OUT NUMBER             --> Saldo até 59 dias (saldo devedor - juros +60)
                                    , pr_vlju6037 OUT NUMBER             --> Juros +60 (Hist. 37 + 2718)
                                    , pr_vlju6038 OUT NUMBER             -- Juros + 60 (Hist. 38)
                                    , pr_vlju6057 OUT NUMBER             -- Juros + 60 (Hist. 57)
                                    , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    , pr_dscritic OUT crapcri.dscritic%TYPE)  IS          --> Valor dos juros +60

BEGIN

DECLARE
  -- Recupera dados da CRAPLCM para compor saldo devedor até 59 dias e valores de juros +60
  CURSOR cr_craplcm(pr_dt59datr IN crapris.dtinictr%TYPE
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

  -- Busca o limite de crédito atual do cooperado e a flag de prejuízo da conta corrente
  CURSOR cr_crapass IS
  SELECT nvl(sda.vllimcre,0) vllimcre
       , inprejuz
    FROM crapass ass
		   , crapsda sda
   WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta
		AND sda.cdcooper = ass.cdcooper
		AND sda.nrdconta = ass.nrdconta
		AND sda.dtmvtolt = to_date('31/12/2018', 'DD/MM/YYYY');
  rw_crapass cr_crapass%ROWTYPE;

  -- Informações de saldo atual da conta corrente
  CURSOR cr_saldos(pr_cdcooper NUMBER
                 , pr_nrdconta NUMBER) IS
  SELECT nvl(abs(sld.vlsddisp),0) vlsddisp
       , sld.dtrisclq
       , sld.qtddsdev
       , sld.vliofmes
    FROM crapsld sld
   WHERE sld.cdcooper = pr_cdcooper
     AND sld.nrdconta = pr_nrdconta;
  rw_saldos cr_saldos%ROWTYPE;

  -- Busca o saldo da conta para o dia em que ela atingiu 59 dias de atraso
  CURSOR cr_crapsda(pr_dt59datr IN DATE) IS
  SELECT abs(sda.vlsddisp)
    FROM crapsda sda
   WHERE sda.cdcooper = pr_cdcooper
     AND sda.nrdconta = pr_nrdconta
     AND sda.dtmvtolt = pr_dt59datr;

  -- Consulta data de transferência da conta corrente para prejuízo
  CURSOR cr_prejuizo IS
  SELECT dtinclusao
    FROM tbcc_prejuizo
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND dtliquidacao IS NULL;

  -- Consulta o valor estornado de juros +60 na conta corrente em prejuízo
  CURSOR cr_estjur60(pr_dtmvtolt DATE) IS
  SELECT nvl(SUM(decode(cdhistor, 2728, vllanmto, vllanmto * -1)), 0) total_estorno
    FROM tbcc_prejuizo_detalhe prj
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND dtmvtolt = pr_dtmvtolt
     AND cdhistor IN (2727, 2728);

  -- Calendário da cooperativa
  rw_crapdat btch0001.rw_crapdat%TYPE;

  vr_data_corte_dias_uteis DATE; --> Data de corte para contagem de dias de atraso em dias corridos
  vr_dtcorte_rendaprop     DATE; --> Data de corte de implantação do Rendas a Apropriar (não apropriação de receita dos juros +60)
  vr_data_59dias_atraso    DATE; --> Data em que a conta atingiu 59 dias de atraso (ADP)
  vr_jur60_37              NUMBER;
  vr_jur60_57              NUMBER;
  vr_jur60_2718            NUMBER;
  vr_jur60_38              NUMBER;
  vr_vliofprj              NUMBER := 0;
  vr_dtprejuz              DATE;
  vr_tipo_busca            Varchar2(1);

  vr_tab_saldos  EXTR0001.typ_tab_saldos;
  vr_tab_erro    GENE0001.typ_tab_erro;
  vr_vlsldisp    NUMBER;  
  vr_index_saldo INTEGER; 
  vr_des_reto    VARCHAR2(2000);
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_exc_erro    EXCEPTION;

  vr_exc_saldo_indisponivel EXCEPTION;  --> Exceção para o caso de saldo indisponível na base de dados
  vr_qtddiaatr INTEGER;                 --> Quantidade de dias de atraso da conta
  
  vr_datasaldo DATE;

  vr_saldo_dia   NUMBER;
  vr_est_jur60   NUMBER;
  
  vr_dtultano DATE; --> Data do último dia do ano
BEGIN
    -- Busca data de corte para contagem de dias de atraso em dias corridos
    vr_data_corte_dias_uteis := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                   ,'DD/MM/RRRR');
    -- Carrega o calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --  Carrega informações de saldo atual da conta
    OPEN cr_saldos(pr_cdcooper, pr_nrdconta);
    FETCH cr_saldos INTO rw_saldos;
    CLOSE cr_saldos;

    -- Busca o limite ativo da conta
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    vr_qtddiaatr := pr_qtdiaatr;

    -- Se não foi informada a quantidade de dias em atraso (este valor será informado quando
    -- for necessário considerar a quantidade de dias em atraso calculada e não a armazenada na CRAPSLD).
    IF vr_qtddiaatr IS NULL THEN
      vr_qtddiaatr := rw_saldos.qtddsdev; -- Considera os dias em atraso da CRAPSLD
    END IF;

    pr_vlju6037 := 0; -- Assume que a conta não tem juros +60, caso a conta não tenha ultrapassado os 60 dias de atraso
    pr_vlju6038 := 0; -- Assume que a conta não tem juros +60, caso a conta não tenha ultrapassado os 60 dias de atraso
    pr_vlju6057 := 0; -- Assume que a conta não tem juros +60, caso a conta não tenha ultrapassado os 60 dias de atraso

    IF vr_qtddiaatr = 0 THEN -- Se a conta não está em atraso
      pr_vlsld59d := 0;
    ELSE
      IF vr_qtddiaatr < 60 THEN -- Se a conta não ultrapassou os 60 dias de atraso

        IF pr_tppesqui = 0 THEN
          vr_dtultano := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => ADD_MONTHS(TRUNC(to_date('31/12/2018', 'DD/MM/YYYY') ,'YEAR'),12)-1 -- Dia 31/12 do ano da data recebida
                                           ,pr_tipo     => 'A'
                                           ,pr_feriado  => FALSE
                                           ,pr_excultdia => TRUE);
                                           
          IF to_date('31/12/2018', 'DD/MM/YYYY') = vr_dtultano THEN 
            OPEN cr_crapsda(to_date('31/12/2018', 'DD/MM/YYYY'));
            FETCH cr_crapsda INTO vr_vlsldisp;
            
            IF cr_crapsda%NOTFOUND THEN
               vr_des_reto:= 'NOK';
            ELSE
               vr_des_reto:= 'OK';
            END IF;
            
            CLOSE cr_crapsda;
          ELSE
            -- Processo Batch / Central de Risco
            vr_tipo_busca := 'I'; -- I=usa dtrefere (Saldo do Dia / Central)
            EXTR0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => 1
                                   ,pr_nrdcaixa   => 100
                                   ,pr_cdoperad   => NULL
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_dtrefere   => rw_crapdat.dtmvtopr
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_saldos
                                   ,pr_tab_erro   => vr_tab_erro);
          END IF;
        ELSE
          -- Processo Online / Tela Depositos A Vista
          vr_tipo_busca := 'A'; -- A=Usa dtrefere-1 (Saldo Anterior / Online)
        -- Obtém o saldo atual da conta
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 100
                                   ,pr_cdoperad => '1'
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vllimcre => rw_crapass.vllimcre
                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                   ,pr_tipo_busca => vr_tipo_busca
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_sald => vr_tab_saldos
                                   ,pr_tab_erro => vr_tab_erro);
        END IF;

        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic := 'Erro na procedure TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        -- Buscar Indice
        vr_index_saldo := vr_tab_saldos.FIRST;
        IF vr_index_saldo IS NOT NULL THEN
          -- Acumular Saldo
          vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0),2);
        END IF;
        
        -- Desconta o limite de crédito ativo do saldo devedor total
        pr_vlsld59d := abs(vr_vlsldisp) - rw_crapass.vllimcre;

        -- Tratamento para não mostrar o Saldo Devedor 59D negativo
        IF pr_vlsld59d < 0 THEN
          pr_vlsld59d := 0;
        END IF;
      ELSE --  vr_qtddiaatr >= 60
        -- Busca data em que a conta foi transferida para prejuízo
         OPEN cr_prejuizo;
         FETCH cr_prejuizo INTO vr_dtprejuz;
         
         IF cr_prejuizo%NOTFOUND THEN
           vr_dtprejuz := NULL;
         END IF;
         
         CLOSE cr_prejuizo;

        -- Calcula a data em que a aconta atingiu 59 dias de atraso
        vr_data_59dias_atraso := TELA_ATENDA_DEPOSVIS.fn_calc_data_59dias_atraso(pr_cdcooper, pr_nrdconta);

        -- Busca o primeiro dia útil anterior a data calculada de 59 dias de atraso
        WHILE NOT fn_valida_dia_util(pr_cdcooper, vr_data_59dias_atraso)  LOOP
          vr_data_59dias_atraso := vr_data_59dias_atraso - 1;
         END LOOP;

        -- Recupera o saldo do dia em que a conta atingiu 59 dias de atraso
        OPEN cr_crapsda(vr_data_59dias_atraso);
        FETCH cr_crapsda INTO pr_vlsld59d;

     IF cr_crapsda%NOTFOUND THEN
            CLOSE cr_crapsda;

            RAISE vr_exc_saldo_indisponivel;
     END IF;

     CLOSE cr_crapsda;

            -- Desconta o limite de crédito ativo do saldo devedor total
        pr_vlsld59d := pr_vlsld59d - rw_crapass.vllimcre;

            -- Percorre os lançamentos ocorridos após 60 dias de atraso que não sejam juros +60
        FOR rw_craplcm IN cr_craplcm(vr_data_59dias_atraso, vr_dtprejuz, rw_crapdat.dtmvtolt) LOOP
          -- Descarta o primeiro registro, usado apenas para popular o saldo do dia anterior para a data que completa 60 dias de atraso
          IF rw_craplcm.dtmvtolt = vr_data_59dias_atraso THEN
            continue;
          END IF;

              pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_37,0);
              pr_vlju6037 := pr_vlju6037 + nvl(rw_craplcm.jur60_2718,0); -- AJUSTAR *********
              pr_vlju6038 := pr_vlju6038 + nvl(rw_craplcm.jur60_38,0);
              pr_vlju6057 := pr_vlju6057 + nvl(rw_craplcm.jur60_57,0);
              vr_vliofprj := vr_vliofprj + nvl(rw_craplcm.iof_prej,0);

          vr_saldo_dia := rw_craplcm.vldifsld;

          IF vr_saldo_dia > 0 THEN -- Se fechou o dia com saldo positivo (crédito)
            vr_saldo_dia := vr_saldo_dia + (nvl(rw_craplcm.jur60_37, 0) +
                                            nvl(rw_craplcm.jur60_38, 0) +
                                            nvl(rw_craplcm.jur60_57, 0) +
                                            nvl(rw_craplcm.jur60_2718, 0) +
                                            nvl(rw_craplcm.iof_prej,0));

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
              -- Desconta o valor dos juros +60 do saldo do dia (débito)
              vr_saldo_dia := abs(vr_saldo_dia) - (nvl(rw_craplcm.jur60_37, 0) +
                                                   nvl(rw_craplcm.jur60_38, 0) +
                                                   nvl(rw_craplcm.jur60_57, 0) +
                                                   nvl(rw_craplcm.jur60_2718, 0) +
                                                   nvl(rw_craplcm.iof_prej, 0));
                                                   
              IF vr_dtprejuz IS NOT NULL AND rw_craplcm.dtmvtolt >= vr_dtprejuz THEN
                OPEN cr_estjur60(rw_craplcm.dtmvtolt);
                FETCH cr_estjur60 INTO vr_est_jur60;
                CLOSE cr_estjur60;
                
                IF vr_est_jur60 > 0 THEN
                  pr_vlju6037 := nvl(pr_vlju6037, 0) + vr_est_jur60;
                  vr_saldo_dia := vr_saldo_dia - vr_est_jur60;
                END IF;
                
              END IF;

           -- Incorpora o débito ao saldo devedor até 59 dias de atraso
              pr_vlsld59d := pr_vlsld59d + vr_saldo_dia;
            ELSIF vr_saldo_dia = 0 AND vr_dtprejuz IS NOT NULL 
            AND rw_craplcm.dtmvtolt >= vr_dtprejuz AND nvl(rw_craplcm.iof_prej, 0) > 0 THEN
              -- Caso tenha ocorrido débito de IOF no pagamento de prejuízo e tenha ocorrido estorno do 
              -- pagamento no mesmo dia, é necessário acrescentar o valor do IOF ao saldo até 59 dias
              -- mesmo que o saldo do dia tenha fechado com o mesmo valor do saldo do dia anteiror
              -- (Reginaldo/AMcom - P450)
              pr_vlsld59d := pr_vlsld59d - abs(rw_craplcm.iof_prej);
              END IF;
            END LOOP;

            -- Soma o valor de IOF debitado após a transferência para prejuízo ao saldo 59 dias (se não foi pago pelos créditos ocorridos na conta)
            pr_vlsld59d := pr_vlsld59d + vr_vliofprj;

          -- Tratamento para não mostrar o Saldo Devedor 59D negativo
          IF pr_vlsld59d < 0 THEN
            pr_vlsld59d := 0;
         END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
    WHEN vr_exc_saldo_indisponivel THEN
      pr_cdcritic := 853;
      pr_dscritic := 'Nao foi possível recuperar o saldo de 59 dias de atraso.';
    WHEN OTHERS THEN
      pr_cdcritic := 9999;
      pr_dscritic := 'Erro nao tratado na "TELA_ATENDA_DEPOSVIS.pc_consulta_saldos_juros60_det":' || SQLERRM;
  END;
END pc_busca_saldos_juros60_det; 

	
begin
  FOR rw_crapcop IN cr_crapcop LOOP
	  FOR rw_crapris IN cr_crapris(rw_crapcop.cdcooper) LOOP
		  pc_busca_saldos_juros60_det(pr_cdcooper => rw_crapcop.cdcooper
                                    , pr_nrdconta => rw_crapris.nrdconta
                                    , pr_qtdiaatr => rw_crapris.qtdiaatr
                                    , pr_dtlimite => to_date('31/12/2018', 'DD/MM/YYYY')
                                    , pr_tppesqui => 0
                                    , pr_vlsld59d => vr_vlsld59d
                                    , pr_vlju6037 => vr_vlju6037
                                    , pr_vlju6038 => vr_vlju6038
                                    , pr_vlju6057 => vr_vlju6057
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic);
																		
		  IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  dbms_output.put_line('Coop: '  || rw_crapcop.cdcooper || ' Conta: ' || rw_crapris.nrdconta || 'Dias de atraso: ' || rw_crapris.qtdiaatr ||
				                     ' Erro: ' || vr_dscritic);
				continue;
			END IF;
			
			UPDATE crapris ris
			   SET vlsld59d = nvl(vr_vlsld59d, 0)
				   , vljura60 = nvl(vr_vlju6037, 0) + nvl(vr_vlju6038, 0) + nvl(vr_vlju6057, 0)
			 WHERE progress_recid = rw_crapris.progress_recid;
			 
			IF rw_crapris.qtdiaatr <= 30 THEN
			  vr_cdvencto := 110;
			ELSE 
			  vr_cdvencto := 120;
			END IF;
				 
			UPDATE crapvri vri
			   SET vri.vldivida = nvl(vr_vlsld59d, 0)
			 WHERE cdcooper = rw_crapcop.cdcooper
			   AND nrdconta = rw_crapris.nrdconta
				 AND cdmodali = 101
				 AND cdvencto = vr_cdvencto
				 AND nrctremp = rw_crapris.nrdconta
				 AND innivris = rw_crapris.innivris
				 AND dtrefere = to_Date('31/12/2018', 'DD/MM/YYYY');
		END LOOP;
	END LOOP;
	
	COMMIT;  
end;
0
0
