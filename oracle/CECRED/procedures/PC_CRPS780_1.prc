CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS780_1(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%type  --> contrato de emprestimo
                                        ,pr_vlpagmto in crapepr.vlsdprej%type  --> valor do pagamento
                                        ,pr_vldabono in crapepr.vlsdprej%type  --> valor do abono
                                        ,pr_cdagenci IN crapass.cdagenci%type  --> código da agencia
                                        ,pr_cdoperad IN crapnrc.cdoperad%TYPE  --> Código do operador
                                        ,pr_vltotpgt OUT crapepr.vlsdprej%type --> valor pago (contrato+iof)
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                        ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS780_1
  Sistema : Prejuizo - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Jean (Mout´S)
  Data    : Junho/2017.                    Ultima atualizacao: 09/11/2018

  Dados referentes ao programa:

  Frequencia: Diaria
         Programa Chamador: PC_CRPS780 (rotina de priorização das parcelas para pagamento)

  Objetivo  : Pagamento de parcelas dos emprestimos em prejuizo

  Alteracoes: 12/06/2017 - Criação da rotina (Everton / Mout´S)
  
              05/07/2018 - P410 - Inclusão do Pagamento do IOF do Prejuizo (Marcos-Envolti)
              
              08/08/2018 - P410 - Diminuir do valor principal da LEM o valor do IOF (Marcos-Envolti)
              
              09/11/2018 - Ajustes para nao debitar IOF em conta corrente para pagamentos de conta em prejuizo CC.
                           PRJ450 - Regulatorio(Odirlei-AMcom)
              
			  09/05/2019 - P298.2.2 Tratamento para juros +60 PosFixado (Rafael Faria - Supero)

			  25/06/2019 - P298.3 - Ajustes para resolver diferenças contabeis (Nagasava - Supero)

              25/07/2019 - P637 - Passagem de parâmetro pr_vltotpgt utilizado na EMPR9999              

              
    ............................................................................. */

  DECLARE

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS780_1';

    --Variaveis para retorno de erro
    vr_cdcritic      INTEGER:= 0;
    vr_dscritic      VARCHAR2(4000);

    --Variaveis de Excecao
    vr_exc_erro           EXCEPTION;
    vr_exc_erro_principal EXCEPTION;

    -- Variaveis para gravação da craplot
    vr_vldabono number;

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos empréstimos
    CURSOR cr_crapepr IS
      SELECT epr.rowid
            ,epr.cdcooper
            ,epr.cdorigem
            ,epr.nrdconta
            ,epr.nrctremp
            ,epr.inliquid
            ,epr.qtpreemp
            ,epr.qtprecal
            ,epr.vlsdeved
            ,epr.dtmvtolt
            ,epr.inprejuz
            ,epr.txjuremp
            ,epr.vljuracu
            ,epr.dtdpagto
            ,epr.flgpagto
            ,epr.qtmesdec
            ,epr.vlpreemp
            ,epr.cdlcremp
            ,epr.qtprepag
            ,epr.dtultpag
            ,epr.tpdescto
            ,epr.indpagto
            ,epr.cdagenci
            ,epr.cdfinemp
            ,epr.vlemprst
            ,epr.vlsdprej
            ,epr.tpemprst
            ,nvl(epr.vltiofpr,0) vltiofpr
            ,nvl(epr.vlttmupr,0) vlttmupr
            ,nvl(epr.vlttjmpr,0) vlttjmpr
            ,nvl(epr.vlpiofpr,0) vlpiofpr
            ,nvl(epr.vlpgmupr,0) vlpgmupr
            ,nvl(epr.vlpgjmpr,0) vlpgjmpr
            ,epr.txmensal vltaxa_juros         
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp
         and epr.inprejuz = 1; 

    -- Buscar os juros+60 e juros atualizados
    CURSOR cr_craplem_juros(prc_cdcooper craplem.cdcooper%TYPE                            
                           ,prc_nrdconta crapepr.nrdconta%TYPE
                           ,prc_nrctremp craplem.nrctremp%TYPE) IS
      SELECT sum(case when c.cdhistor in (2402,2406,2382,2397) then c.vllanmto else 0 end) - 
             (sum(case when c.cdhistor in (2473) then c.vllanmto else 0 end) -
             sum(case when c.cdhistor in (2474) then c.vllanmto else 0 end) )sum_vllanmto_jr60,
             sum(case when c.cdhistor in (381,2409) then c.vllanmto else 0 end) - 
             (sum(case when c.cdhistor in (2389,391) then c.vllanmto else 0 end) -
             sum(case when c.cdhistor in (2393) then c.vllanmto else 0 end) )sum_vllanmto_jratlz
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2402,2406,2382,2397,2473,2474,381,391,2409,2389,2393); 
              
    vr_qtdjuros60 NUMBER;
  
    
    ------------------------- ESTRUTURAS DE REGISTRO ---------------------

    -- Definição de tipo para armazenar informações dos saldos associados
    TYPE typ_reg_crapsld IS
      RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
            ,vlsdbloq crapsld.vlsdbloq%TYPE
            ,vlsdblpr crapsld.vlsdblpr%TYPE
            ,vlsddisp crapsld.vlsddisp%TYPE
            ,vlsdchsl crapsld.vlsdchsl%TYPE
            ,vlipmfap crapsld .vlipmfap%TYPE
            ,vlipmfpg crapsld.vlipmfpg%TYPE);
    TYPE typ_tab_crapsld IS
      TABLE OF typ_reg_crapsld
        INDEX BY PLS_INTEGER; --> Número da conta
    vr_tab_crapsld typ_tab_crapsld;

    ---------------------- VARIÁVEIS -------------------------

    -- Variáveis auxiliares no processo
    vr_vldpagto      NUMBER(18,6);           --> Valor de desconto das parcelas
    vr_vlPrincAbono NUMBER(18,6);           --> Valor de desconto das parcelas
    vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
    
    -- Erro em chamadas da pc_gera_erro
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;

    vr_vlpiofpr NUMBER;
    vr_vlpgmupr NUMBER;
    vr_vlpgjmpr NUMBER;
    vr_vljr60lm NUMBER;
    vr_vljratlz NUMBER;
    vr_juros_atualizado NUMBER;
    vr_tab_sald         extr0001.typ_tab_saldos;
    
  ---------------------------------------
  -- Inicio Bloco Principal PC_CRPS780_1
  ---------------------------------------
  BEGIN
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat  INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
        --
        -- Iniciar variaveis
        vr_tab_sald.delete;
        vr_tab_erro.delete;
        vr_tab_crapsld.delete;
        
        EXTR0001.PC_OBTEM_SALDO_DIA(pr_cdcooper => pr_cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci => 0,
                                    pr_nrdcaixa => 0,
                                    pr_cdoperad => '1',
                                    pr_nrdconta => pr_nrdconta,
                                    pr_vllimcre => 0,
                                    pr_dtrefere => rw_crapdat.dtmvtolt,
                                    pr_flgcrass => FALSE, --pr_flgcrass,
                                    pr_tipo_busca => 'A',
                                    pr_des_reto => vr_des_reto,
                                    pr_tab_sald => vr_tab_sald,
                                    pr_tab_erro => vr_tab_erro);
        
        IF vr_des_reto <> 'OK' THEN
          IF vr_tab_erro.count() > 0 THEN -- RMM
            -- Atribui críticas às variaveis
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := 'Falha ao buscar saldo atual '||vr_tab_erro(vr_tab_erro.first).dscritic;
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Falha ao buscar saldo atual - '||sqlerrm;
            raise vr_exc_erro;
          END IF;          
        END IF;
               
        IF vr_tab_sald.EXISTS(vr_tab_sald.first) THEN
          vr_tab_crapsld(pr_nrdconta).vlsddisp := vr_tab_sald(vr_tab_sald.first).vlsddisp;
          vr_tab_crapsld(pr_nrdconta).vlsdbloq := vr_tab_sald(vr_tab_sald.first).vlsdbloq;
          vr_tab_crapsld(pr_nrdconta).vlsdblpr := vr_tab_sald(vr_tab_sald.first).vlsdblpr;
          vr_tab_crapsld(pr_nrdconta).vlsddisp := vr_tab_sald(vr_tab_sald.first).vlsddisp;
          --vr_tab_crapsld(pr_nrdconta).vlipmfap := vr_tab_sald(vr_tab_sald.first).vlipmfap;
          vr_tab_crapsld(pr_nrdconta).vlipmfpg := vr_tab_sald(vr_tab_sald.first).vlipmfpg;
          vr_tab_crapsld(pr_nrdconta).vlsdchsl := vr_tab_sald(vr_tab_sald.first).vlsdchsl;          
        END IF;
        --
      --END IF;
      --
      -- Busca do Empréstimo
      FOR rw_crapepr IN cr_crapepr LOOP
        vr_vldpagto := 0;
        --
        IF NOT vr_tab_crapsld.EXISTS(rw_crapepr.nrdconta) THEN
          -- Gerar critica 10
          vr_cdcritic := 10;
          vr_dscritic := gene0001.fn_busca_critica(10) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
          RAISE vr_exc_erro;
        END IF;

        -- Se o valor vier preenchido por parâmetro, considerar o valor do parâmetro
        IF  nvl(pr_vlpagmto,0) = 0 AND nvl(pr_vldabono,0) = 0 THEN
           -- Saldo online da conta.
           vr_vldpagto := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0);--rw_crapepr.vlsdprej;
           vr_vldabono := 0;
        ELSE
           vr_vldpagto := pr_vlpagmto;
           vr_vldabono := pr_vldabono;
        END IF;
        --
        -- Gerar lançamento do historico de Abono  
        IF nvl(vr_vldabono,0) > 0 THEN
          
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2391 -- abono
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vldabono
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                           
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu falha ao retornar gravação LEM (valor abono): ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Para caso o saldo da conta seja maior que o saldo total devedor
        IF rw_crapepr.vlsdprej +  -- saldo devedor atualizado
          (nvl(rw_crapepr.vltiofpr,0) - nvl(rw_crapepr.vlpiofpr,0)) + -- valor residual IOF
          (nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
          (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0)) < vr_vldpagto AND 
           vr_vldabono = 0 THEN
          -- Atribuir somente o valor devedor do prejuízo
          vr_vldpagto := (rw_crapepr.vlsdprej +  -- saldo devedor atualizado
                             (nvl(rw_crapepr.vltiofpr,0) - nvl(rw_crapepr.vlpiofpr,0)) + -- valor residual IOF
                             (nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
                             (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0)));
        
        ELSIF vr_vldpagto <= 0 AND vr_vldabono <= 0 THEN
          vr_dscritic := 'Pagamento não permitido, Saldo de pagamento ou abono menor ou igual a zero.';
          RAISE vr_exc_erro;                  
           
        END IF;
        --
        -- Variavel de valor utilizada para realizar as quebras de pagamentos
        vr_vlPrincAbono := nvl(vr_vldpagto,0) + nvl(vr_vldabono,0);
        --
        -- Não permitir ter uma variavel de valor maior que o saldo devedor
        IF rw_crapepr.vlsdprej +  -- saldo devedor atualizado
          (nvl(rw_crapepr.vltiofpr,0) - nvl(rw_crapepr.vlpiofpr,0)) + -- valor residual IOF
          (nvl(rw_crapepr.vlttmupr,0) - nvl(rw_crapepr.vlpgmupr,0)) + -- valor residual de multa
          (nvl(rw_crapepr.vlttjmpr,0) - nvl(rw_crapepr.vlpgjmpr,0)) < vr_vlPrincAbono THEN
  
          vr_dscritic := 'O valor é superior ao saldo do prejuizo';
          raise vr_exc_erro;
          
        END IF;
        --      
        vr_qtdjuros60 := 0;
        vr_juros_atualizado := 0;
        -- Buscar o valor atualizado do juros+60 e juros atualizado na mensal
        FOR rw_craplem_juros in cr_craplem_juros(rw_crapepr.cdcooper
                                                ,rw_crapepr.nrdconta
                                                ,rw_crapepr.nrctremp) LOOP
          vr_qtdjuros60 := nvl(rw_craplem_juros.sum_vllanmto_jr60,0);
          vr_juros_atualizado := nvl(rw_craplem_juros.sum_vllanmto_jratlz,0);
        END LOOP;
        --
        
        /* 1o Valor de IOF */
        IF (rw_crapepr.vltiofpr - rw_crapepr.vlpiofpr) >= vr_vlPrincAbono THEN
            vr_vlpiofpr := vr_vlPrincAbono;--rw_crapepr.vlpgmupr + vr_vlPrincAbono;
            vr_vlPrincAbono := 0;
        ELSE     
           vr_vlpiofpr := rw_crapepr.vltiofpr - rw_crapepr.vlpiofpr;
           vr_vlPrincAbono := vr_vlPrincAbono - vr_vlpiofpr;
        END IF; 
        
        /* 2o Valor de Multa     */
        IF (rw_crapepr.vlttmupr - rw_crapepr.vlpgmupr) >= vr_vlPrincAbono THEN
            vr_vlpgmupr := vr_vlPrincAbono;--rw_crapepr.vlpgmupr + vr_vlPrincAbono;
            vr_vlPrincAbono := 0;
        ELSE     
         --  vr_vldescto := vr_vldescto - (rw_crapepr.vlttmupr - rw_crapepr.vlpgmupr);
           vr_vlpgmupr := rw_crapepr.vlttmupr - rw_crapepr.vlpgmupr;
           vr_vlPrincAbono := vr_vlPrincAbono - vr_vlpgmupr;
        END IF;  
                             
        /* 3o Valor de Juros Mora     */
        IF vr_vlPrincAbono > 0 THEN
          IF (rw_crapepr.vlttjmpr - rw_crapepr.vlpgjmpr) >= vr_vlPrincAbono THEN
            vr_vlpgjmpr := vr_vlPrincAbono; --rw_crapepr.vlpgjmpr + vr_vlPrincAbono;
            vr_vlPrincAbono := 0;
          ELSE
            vr_vlpgjmpr := rw_crapepr.vlttjmpr - rw_crapepr.vlpgjmpr; 
            vr_vlPrincAbono := vr_vlPrincAbono - vr_vlpgjmpr;
          END IF;
        END IF;
        
        /* 4o Valor juros+60 */
        IF vr_vlPrincAbono > 0 THEN -- Tem saldo de pag+abono para pagar?
          IF vr_qtdjuros60 > 0 THEN -- Tem juros+60 para ser pago?
            IF vr_qtdjuros60 >= vr_vlPrincAbono THEN -- Valor nao cobriu o juros +60
              vr_vljr60lm := vr_vlPrincAbono; -- Atualizar a craplem com valor parcial
              rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vlPrincAbono; -- Atualizar o saldo do prejuizo
              vr_vlPrincAbono := 0; -- quitar o saldo de pag+abono
            ELSE
              rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_qtdjuros60; -- Atualizar o saldo do prejuizo
              vr_vljr60lm         := vr_qtdjuros60; -- Atualizar a craplem com o valor total
              vr_vlPrincAbono := vr_vlPrincAbono - vr_qtdjuros60;
            END IF;
          END IF;
        END IF;
        
        --
        IF vr_vlPrincAbono > 0 THEN -- Tem saldo de pag+abono para pagar saldo prejuizo e juros atualizado
          IF vr_juros_atualizado > 0 THEN --  existe juros atualizado?
            IF (rw_crapepr.vlsdprej - vr_vlPrincAbono) <= 0 THEN -- Verifica se quitou o saldo prejuizo
                rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_juros_atualizado;
                vr_vljratlz     := vr_juros_atualizado; -- Atualizar a craplem com o valor total
                vr_vlPrincAbono := vr_vlPrincAbono - vr_juros_atualizado;
                rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vlPrincAbono;
            ELSIF (rw_crapepr.vlsdprej - vr_vlPrincAbono) <= vr_juros_atualizado THEN -- OU se o saldo ja esta no juros atualizado
              --IF vr_juros_atualizado >= (rw_crapepr.vlsdprej - vr_vlPrincAbono) THEN -- Valor nao cobriu o juros Atualizado
                vr_vljratlz := vr_juros_atualizado - (rw_crapepr.vlsdprej - vr_vlPrincAbono) ; -- Atualizar a craplem com valor parcial
                rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vlPrincAbono;
                vr_vlPrincAbono := vr_vlPrincAbono - vr_vljratlz; -- quitar o saldo de pag+abono
              --END IF;
            ELSE 
              --vr_vljratlz     := vr_juros_atualizado; -- Atualizar a craplem com o valor total
              rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vlPrincAbono;              
            END IF;
          ELSE
            IF rw_crapepr.vlsdprej < 0 THEN
               rw_crapepr.vlsdprej := (rw_crapepr.vlsdprej * -1) - vr_vlPrincAbono;
            ELSE
               rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - vr_vlPrincAbono;
            END IF;
          END IF;
        END IF; 
        
        -- Inserir o valor de pagamento na conta corrente do cooperado 
        IF vr_vldpagto > 0  THEN -- PRJ298.3 -- Retirar soma do IOF, pois já faz parte do valor de pagto
          -- Descontar do valor total pago o que será destinado ao IOF
          vr_vldpagto := vr_vldpagto - vr_vlpiofpr;
          -- Se mesmo assim houver pagamento
          IF vr_vldpagto > 0 THEN
					-- Lança débito na conta corrente somente se não está em prejuízo
					IF PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) = FALSE THEN
            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper 
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => 1 --rw_craplot_8457.cdagenci
                                          ,pr_cdbccxlt => 100
                                          ,pr_cdoperad => '1'
                                          ,pr_cdpactra => 1 --rw_craplot_8457.cdagenci
                                          ,pr_nrdolote => 8457 --rw_craplot_8457.nrdolote
                                          ,pr_nrdconta => rw_crapepr.nrdconta
                                          ,pr_cdhistor => 2386
                                          ,pr_vllanmto => vr_vldpagto
                                          ,pr_nrparepr => 0
                                          ,pr_nrctremp => rw_crapepr.nrctremp
                                          ,pr_nrseqava => 0
                                          ,pr_idlautom => 0 
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro );
            IF vr_des_reto <> 'OK' THEN
              IF vr_tab_erro.count() > 0 THEN -- RMM
                -- Atribui críticas às variaveis
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := 'Falha ao inserir LCM '||vr_tab_erro(vr_tab_erro.first).dscritic;
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Falha ao inserir LCM - '||sqlerrm;
                raise vr_exc_erro;
              END IF; 
            END IF;  
		ELSE
			-- Lança débito no extrato do prejuízo (para correto processamento do pagamento pelo CYBER)
            PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                            , pr_nrdconta => rw_crapepr.nrdconta
                                            , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            , pr_cdhistor => 2781
                                            , pr_vllanmto => vr_vldpagto
																	          , pr_nrctremp => rw_crapepr.nrctremp
                                            , pr_cdcritic => vr_cdcritic
                                            , pr_dscritic => vr_dscritic);
					END IF;

          IF rw_crapepr.txjuremp <> rw_crapepr.vltaxa_juros THEN
            rw_crapepr.txjuremp := rw_crapepr.vltaxa_juros;
            vr_inusatab := TRUE;
          ELSE
            vr_inusatab := FALSE;
          END IF;
          --
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_cdpactra => pr_cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => rw_crapepr.nrdconta
                                           ,pr_cdhistor => 2701 -- pagamento
                                           ,pr_nrctremp => rw_crapepr.nrctremp
                                           ,pr_vllanmto => vr_vldpagto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => 0
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                                                 
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (pagamento): ' || vr_dscritic;
              RAISE vr_exc_erro;
            END IF;            
          END IF;  
          
          -- Se houver pagamento de IOF
          IF vr_vlpiofpr > 0 THEN
          
            -- Lança débito na conta corrente somente se não está em prejuízo
					  IF PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) = FALSE THEN
              -- Lançar em C/C o Pagamento
              empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper 
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdagenci => 1 --rw_craplot_8457.cdagenci
                                            ,pr_cdbccxlt => 100
                                            ,pr_cdoperad => '1'
                                            ,pr_cdpactra => 1 --rw_craplot_8457.cdagenci
                                            ,pr_nrdolote => 8457 --rw_craplot_8457.nrdolote
                                            ,pr_nrdconta => rw_crapepr.nrdconta
                                            ,pr_cdhistor => 2317
                                            ,pr_vllanmto => vr_vlpiofpr
                                            ,pr_nrparepr => 0
                                            ,pr_nrctremp => rw_crapepr.nrctremp
                                            ,pr_nrseqava => 0
                                            ,pr_idlautom => 0 
                                            ,pr_des_reto => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro );
              IF vr_des_reto <> 'OK' THEN
                IF vr_tab_erro.count() > 0 THEN -- RMM
                  -- Atribui críticas às variaveis
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic := 'Falha ao inserir LCM IOF '||vr_tab_erro(vr_tab_erro.first).dscritic;
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Falha ao inserir LCM IOF - '||sqlerrm;
                  raise vr_exc_erro;
                END IF; 
              END IF; 
            ELSE
              -- Lançar débito no do IOF no extrato do prejuízo, para contabilização 
              PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                              , pr_nrdconta => rw_crapepr.nrdconta
                                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              , pr_cdhistor => 2795 --> IOF.REC.PREJU
                                              , pr_vllanmto => vr_vlpiofpr
                                              , pr_nrctremp => rw_crapepr.nrctremp
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic);
            
              IF vr_cdcritic > 0 AND 
                 vr_dscritic IS NOT NULL THEN
                 
                RAISE vr_exc_erro;                
              END IF;         
            END IF;
          END IF;
                   
                                                                      
          -- Armazenar informações para aproveitamento posterior
          IF rw_crapepr.txjuremp <> rw_crapepr.vltaxa_juros THEN
            rw_crapepr.txjuremp := rw_crapepr.vltaxa_juros;
            vr_inusatab := TRUE;
          ELSE
            vr_inusatab := FALSE;
          END IF;                
            
        END IF;         
        
        -- Lancamento da multa 2390
        IF nvl(vr_vlpgmupr,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2390 -- juros de mora
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vlpgmupr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                           
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor multa): ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- atualizar juros de mora -- 2475
        IF nvl(vr_vlpgjmpr,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2475 -- juros de mora
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vlpgjmpr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => TRUE
                                         ,pr_flgcredi => FALSE
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros): ' || vr_dscritic;
            --pr_des_reto := 'NOK';
            raise vr_exc_erro;
          END IF;
        END IF;    
            
        -- Lancamento de juros + 60 -- 2473
        IF  nvl(vr_vljr60lm,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2473 -- juros+60
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vljr60lm
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                           
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros+60): ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;          
        
        -- Valor juros atualizado
        IF NVL(vr_vljratlz,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2389 -- juros atualizado
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vljratlz
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                           
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros atualizado): ' || vr_dscritic;
            --pr_des_reto := 'NOK';
             raise vr_exc_erro;
          END IF;
        END IF;
              
        -- Gerar craplem valor principal 2388
        IF vr_vlPrincAbono > 0 THEN -- PRJ298.3 - Retirado desconto do IOF, pois já foi feito
          -- atualiza valor principal.
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_cdhistor => 2388 -- valor principal
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_vllanmto => vr_vlPrincAbono -- PRJ298.3 - Retirado desconto do IOF, pois já foi feito
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                           
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Gerar craplem para quando pagar juros prejuizo da mensal
        -- Se o saldo é menor ou igual a zero, significa que o contrato foi quitado
        IF rw_crapepr.vlsdprej <= 0 THEN
          -- Indicar que o emprestimo está liquidado
          --rw_crapepr.inliquid := 1;
          -- Desativar o Rating associado a esta operaçao
          rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                     ,pr_cdagenci   => 0                   --> Código da agência
                                     ,pr_nrdcaixa   => 0                   --> Número do caixa
                                     ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                     ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                     ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                     ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                     ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                     ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros

          IF vr_des_reto <> 'OK' THEN
            IF vr_tab_erro.count() > 0 THEN -- RMM
              -- Atribui críticas às variaveis
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
              vr_dscritic := 'Falha ao desativar rating '||vr_tab_erro(vr_tab_erro.first).dscritic;
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Falha ao Desativar Rating - '||sqlerrm;
              RAISE vr_exc_erro;
            END IF;          
          END IF;                                     
          
          /** GRAVAMES **/
          GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                               ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                               ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                               ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                               ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                               ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

          IF vr_des_reto <> 'OK' THEN
            IF vr_tab_erro.count() > 0 THEN -- RMM
              -- Atribui críticas às variaveis
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
              vr_dscritic := 'Falha ao solicitar baixa GRVM0001 '||vr_tab_erro(vr_tab_erro.first).dscritic;
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Falha ao Falha ao solicitar baixa GRVM0001 - '||sqlerrm;
              RAISE vr_exc_erro;
            END IF;          
          END IF;                                                
          
          -- zerar o saldo devedor
          rw_crapepr.vlsdprej := 0;        
        END IF;
        
        BEGIN
          UPDATE crapepr
            SET dtdpagto  = rw_crapepr.dtdpagto
                ,txjuremp = rw_crapepr.txjuremp
                ,indpagto = rw_crapepr.indpagto
                ,vlsdprej = rw_crapepr.vlsdprej  
                ,vlpgjmpr = vlpgjmpr + nvl(vr_vlpgjmpr, nvl(vlpgjmpr,0) )
                ,vlpgmupr = vlpgmupr + nvl(vr_vlpgmupr, nvl(vlpgmupr,0) )
                ,vlpiofpr = vlpiofpr + nvl(vr_vlpiofpr, nvl(vlpiofpr,0) )
         WHERE rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Falha ao atualizar o empréstimo (CRAPEPR).'
                        || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                        || '. Detalhes: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        --
      END LOOP; -- FIM LOOP PRINCIPAL

      -- retorna o valor pago para controlar sobra de lancamentos - PJ637
      pr_vltotpgt := vr_vldpagto + vr_vlpiofpr;
      --
  EXCEPTION
      
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      
      WHEN vr_exc_erro_principal THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
  END;
END PC_CRPS780_1;
/
