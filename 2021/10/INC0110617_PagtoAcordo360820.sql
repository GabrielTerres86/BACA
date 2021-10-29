DECLARE
  vr_cdprogra CONSTANT VARCHAR2(8) := 'RECP0001';
  vr_dsarqlog CONSTANT VARCHAR2(10) := 'acordo.log';

  vr_nracordo   tbrecup_acordo.nracordo%TYPE := 360820;
  vr_nrparcel   tbrecup_acordo_parcela.nrparcela%TYPE := 0;
  vr_vlparcel   NUMBER := 0;
  vr_cdoperad   VARCHAR2(100) := '1';
  vr_idorigem   NUMBER := 1;
  vr_nmtelant   VARCHAR2(100) := 'CRPS538';
  vr_vltotpag   NUMBER := 0;
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_des_erro   VARCHAR2(1000);
  vr_tab_saldos EXTR0001.typ_tab_saldos;
  vr_tab_erro   GENE0001.typ_tab_erro;
  vr_exe_erro EXCEPTION;

  CURSOR cr_crapass(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
    SELECT ass.cdcooper
          ,ass.cdagenci
          ,ass.nrdconta
          ,ass.vllimcre
      FROM crapass        ass
          ,tbrecup_acordo acd
     WHERE ass.cdcooper = acd.cdcooper
       AND ass.nrdconta = acd.nrdconta
       AND acd.nracordo = pr_nracordo;
  rw_crapass cr_crapass%ROWTYPE;

  PROCEDURE pc_pagar_contrato_acordo(pr_nracordo IN tbrecup_acordo.nracordo%TYPE
                                    ,pr_nrparcel IN tbrecup_acordo_parcela.nrparcela%TYPE
                                    ,pr_vlparcel IN NUMBER
                                    ,pr_cdoperad IN VARCHAR2
                                    ,pr_idorigem IN NUMBER
                                    ,pr_nmtelant IN VARCHAR2
                                    ,pr_vltotpag OUT NUMBER
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2) IS
    CURSOR cr_acordo IS
      SELECT acd.cdcooper
            ,acd.nrdconta
            ,SUM(DECODE(aco.cdorigem, 1, 1, 0)) qtestour
            ,SUM(DECODE(aco.cdorigem, 1, 0, 1)) qtempres
            ,SUM(nvl(aco.vljuresp, 0) + nvl(aco.vljurmes, 0)) vlhistcontanegat
            ,acd.vlbloqueado
        FROM tbrecup_acordo_contrato aco
            ,tbrecup_acordo          acd
       WHERE aco.nracordo = acd.nracordo
         AND acd.nracordo = pr_nracordo
       GROUP BY acd.cdcooper
               ,acd.nrdconta
               ,acd.vlbloqueado;
    rw_acordo cr_acordo%ROWTYPE;
  
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
            ,ass.vllimcre
            ,ass.inprejuz
            ,sld.vliofmes
        FROM crapass ass
            ,crapsld sld
       WHERE ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = pr_cdcooper
         AND sld.cdcooper = ass.cdcooper
         AND sld.nrdconta = ass.nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    CURSOR cr_acordo_contrato IS
      WITH contratos_acordo AS
       (SELECT a.cdcooper
              ,a.nrdconta
              ,a.nracordo
              ,c.nrctremp
              ,c.cdorigem
              ,DECODE(c.cdorigem, 1, 1, 2) AS cdorigem_sort
              ,c.indpagar
              ,c.vliofdev
              ,c.vlbasiof
              ,c.vliofpag
              ,c.vljuresp
              ,c.vljurmes
              ,c.cdmodelo
              ,c.nrgrupo
              ,c.rowid
          FROM tbrecup_acordo a
         INNER JOIN tbrecup_acordo_contrato c
            ON c.nracordo = a.nracordo
         WHERE a.nracordo = pr_nracordo)
      SELECT acc.cdcooper
            ,acc.nrdconta
            ,acc.cdorigem
            ,acc.cdorigem_sort
            ,acc.nrctremp
            ,acc.nracordo
            ,cyb.flgpreju
            ,acc.vliofdev
            ,acc.vlbasiof
            ,acc.vliofpag
            ,acc.rowid
            ,ass.inprejuz
            ,acc.vljuresp
            ,acc.vljurmes
            ,acc.cdmodelo
            ,acc.nrgrupo
        FROM crapass ass
       INNER JOIN contratos_acordo acc
          ON ass.cdcooper = acc.cdcooper
         AND ass.nrdconta = acc.nrdconta
        LEFT JOIN crapcyb cyb
          ON cyb.cdcooper = acc.cdcooper
         AND cyb.nrdconta = acc.nrdconta
         AND cyb.nrctremp = acc.nrctremp
         AND cyb.cdorigem = acc.cdorigem
       WHERE acc.indpagar = 'S' -- Somente os contratos marcados como 'Pagar' na tela ATACOR (Reginaldo - AMcom)
       ORDER BY acc.cdorigem_sort -- 1. Efetuar pagamento do estouro de conta corrente
               ,nvl(cyb.qtdiaatr, 0) DESC -- 2. Efetuar pagamento do contrato de empréstimo/financiamento ou título com maior tempo de atraso
               ,nvl(cyb.vlsdeved, 0) DESC -- 3. Caso haja empate nesta regra, então, considerar primeiro o contrato com maior saldo devedor
               ,cyb.nrctremp ASC; -- 4. Caso os saldos devedores também sejam iguais, considerar o contrato de menor número CYBER.
    rw_acordo_contrato cr_acordo_contrato%ROWTYPE;
  
    TYPE typ_tab_acordo_contrato IS TABLE OF cr_acordo_contrato%ROWTYPE INDEX BY PLS_INTEGER;
    vr_tab_acordo_contrato typ_tab_acordo_contrato;
  
    vr_tab_saldos           EXTR0001.typ_tab_saldos;
    vr_vlsddisp             NUMBER;
    vr_vltotpag             NUMBER;
    vr_vltotpag_iof         NUMBER;
    vr_idxsaldo             NUMBER;
    vr_des_erro             VARCHAR2(1000);
    vr_tab_erro             GENE0001.typ_tab_erro;
    vr_vlparcel             NUMBER := pr_vlparcel; -- irá trabalhar com a variável, não com o parametro
    vr_cdcritic             NUMBER;
    vr_dscritic             VARCHAR2(1000);
    vr_fldespes             BOOLEAN; -- Indica que deve lançar o valor como despesa
    vr_flbloque             BOOLEAN; -- Indica que deve lançar a sobra como valor bloqueado
    vr_flagerro             BOOLEAN; -- Indica que o processamento de pagamento de acordo apresentou crítica
    vr_idvlrmin             NUMBER := 0; -- Indica que houve critica do valor minimo
    vr_vlParCtr             NUMBER;
    vr_vliofpri             NUMBER;
    vr_vliofadi             NUMBER;
    vr_vliofcpl             NUMBER;
    vr_vltaxa_iof_principal VARCHAR2(20);
    vr_qtdiaiof             NUMBER;
    vr_flgimune             PLS_INTEGER;
    vr_dscatbem             VARCHAR2(100);
    vr_cdlcremp             NUMBER;
    vr_cdfinemp             NUMBER;
    vr_cdmodelo             tbrecup_acordo_contrato.cdmodelo%TYPE;
    vr_inrisco_acordo       tbrecup_acordo_contrato.inrisco_acordo%TYPE;
    vr_nrseqdig             craplcm.nrseqdig%TYPE;
    vr_incrineg             INTEGER;
    vr_tab_retorno          LANC0001.typ_reg_retorno;
    vr_qtdCtrEmAberto       NUMBER;
    vr_idvlrpen             NUMBER;
    vr_dtrefere             crapdat.dtmvtolt%TYPE;
    vr_vlpagocontrato       NUMBER;
    -- Cursor para bens do contrato: 
    /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
    Já "MOTO" reduz apenas as alíquotas de IOF principal e complementar..
    Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, não precisa mais verificar os outros bens..*/
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT b.dscatbem
            ,t.cdlcremp
            ,t.cdfinemp
        FROM crapepr t
       INNER JOIN crapbpr b
          ON b.nrdconta = t.nrdconta
         AND b.cdcooper = t.cdcooper
         AND b.nrctrpro = t.nrctremp
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctremp = pr_nrctremp
         AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
       ORDER BY upper(b.dscatbem) ASC;
    rw_crapbpr cr_crapbpr%ROWTYPE;
  
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT dtdpagto
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    vr_exc_erro EXCEPTION;
  
    FUNCTION fn_qtd_contrato_saldo_pagar(pr_nracordo IN tbrecup_acordo.nracordo%TYPE
                                        ,pr_vlsddisp IN NUMBER) RETURN NUMBER IS
      CURSOR cr_acordo_contrato_sld_pend(pr_nracordo IN tbrecup_acordo.NRACORDO%TYPE
                                        ,pr_vlsddisp IN NUMBER) IS
        SELECT COUNT(1) AS qtde
          FROM (WITH acordo_contrato AS (SELECT a.nracordo
                                               ,a.cdcooper
                                               ,a.nrdconta
                                               ,c.nrctremp
                                               ,c.cdorigem
                                               ,c.nrgrupo
                                           FROM tbrecup_acordo a
                                          INNER JOIN tbrecup_acordo_contrato c
                                             ON a.nracordo = c.nracordo
                                          WHERE a.cdsituacao = 1
                                            AND a.nracordo = pr_nracordo)
                 SELECT ac.*
                       ,ABS(nvl(pr_vlsddisp, 0)) AS vlsdeved
                   FROM acordo_contrato ac
                  WHERE ac.cdorigem = 1
                 UNION ALL
                 SELECT ac.*
                       ,greatest(e.vlsdprej, e.vlsdeved) AS vlsdeved
                   FROM acordo_contrato ac
                  INNER JOIN crapepr e
                     ON ac.cdcooper = e.cdcooper
                    AND ac.nrdconta = e.nrdconta
                    AND ac.nrctremp = e.nrctremp
                  WHERE ((e.inliquid = 0 AND e.vlsdeved > 0) OR (e.inprejuz = 1 AND e.vlsdprej > 0))
                    AND ac.cdorigem IN (2, 3)
                 UNION ALL
                 SELECT ac.*
                       ,(tdb.vlsldtit + (tdb.vliofcpl - tdb.vlpagiof) +
                        (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra)) AS vlsdeved
                   FROM acordo_contrato ac
                  INNER JOIN tbdsct_titulo_cyber ttc
                     ON ttc.cdcooper = ac.cdcooper
                    AND ttc.nrdconta = ac.nrdconta
                    AND ttc.nrctrdsc = ac.nrctremp
                  INNER JOIN craptdb tdb
                     ON ttc.cdcooper = tdb.cdcooper
                    AND ttc.nrdconta = tdb.nrdconta
                    AND ttc.nrborder = tdb.nrborder
                    AND ttc.nrtitulo = tdb.nrtitulo
                  WHERE ac.cdorigem = 4
                 UNION ALL
                 SELECT DISTINCT ac.*
                                ,1 AS vlsdeved
                   FROM acordo_contrato                           ac
                       ,recuperacao.tbrecup_acordo_lanctofuturo   acordo_lancfut
                       ,recuperacao.tbrecup_cobran_lancamento_fut lanctfut
                  WHERE ac.cdorigem = acordo_lancfut.cdorigem
                    AND ac.nracordo = acordo_lancfut.nracordo
                    AND ac.nrgrupo = acordo_lancfut.nrgrupo
                    AND ac.nrctremp = acordo_lancfut.nrctremp
                    AND acordo_lancfut.idcobran_lancamento = lanctfut.idcobran_lancamento
                    AND EXISTS (SELECT 1
                           FROM craplat
                          WHERE lanctfut.nmestrut = 'CRAPLAT'
                            AND lanctfut.cdchave = craplat.cdlantar
                            AND craplat.insitlat = 1
                         UNION
                         SELECT 1
                           FROM craplau
                          WHERE lanctfut.nmestrut = 'CRAPLAU'
                            AND lanctfut.cdchave = craplau.idlancto
                            AND craplau.insitlau = 1)
                    AND ac.cdorigem = 6)
                  WHERE vlsdeved > 0;
    
    
      rw_acordo_contrato_sld_pend cr_acordo_contrato_sld_pend%ROWTYPE;
    BEGIN
      OPEN cr_acordo_contrato_sld_pend(pr_nracordo => pr_nracordo, pr_vlsddisp => pr_vlsddisp);
      FETCH cr_acordo_contrato_sld_pend
        INTO rw_acordo_contrato_sld_pend;
      CLOSE cr_acordo_contrato_sld_pend;
      RETURN rw_acordo_contrato_sld_pend.qtde;
    END;
  
    PROCEDURE pc_gera_log_mail(pr_cdcooper IN NUMBER -- Código da cooperativa
                              ,pr_nrdconta IN NUMBER -- Número da conta
                              ,pr_nracordo IN NUMBER -- Número do acordo
                              ,pr_nrctremp IN NUMBER DEFAULT 0 -- Número do contrato de empréstimo
                              ,pr_dscritic IN VARCHAR2 -- Descrição da crítica
                              ,pr_dsmodule IN VARCHAR2 DEFAULT NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vr_dsdemail CONSTANT VARCHAR2(50) := 'estrategiadecobranca@ailos.coop.br'; -- Email de destino
      vr_dsassunt CONSTANT VARCHAR2(10) := 'ACORDO';
      vr_dsdcorpo VARCHAR2(4000);
      vr_dsrefere VARCHAR2(100);
      vr_dsmodule VARCHAR2(100);
      vr_des_erro VARCHAR2(1000);
    BEGIN
      vr_dsrefere := '[' || pr_nracordo || '/' || pr_nrdconta || '/' || pr_nrctremp || ']';
    
      -- Se informou módulo
      IF pr_dsmodule IS NOT NULL THEN
        vr_dsmodule := '[' || UPPER(pr_dsmodule) || ']';
      END IF;
    
      -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2,
                                 pr_nmarqlog     => vr_dsarqlog,
                                 pr_des_log      => to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  ACORDO ' || vr_dsrefere || ' - ' ||
                                                    'ERRO: ' || pr_dscritic || ' ' || vr_dsmodule || '.');
    
      -- MONTAR O CORPO DA MENSAGEM
      vr_dsdcorpo := 'Não foi possível efetuar o crédito do boleto do acordo na conta corrente, ' ||
                     'conforme dados abaixo. Favor verificar: <br>' || 'Cooperativa: ' ||
                     pr_cdcooper || '<br>' || 'Conta: ' || pr_nrdconta || '<br>' || 'Acordo: ' ||
                     pr_nracordo || '<br><br>' ||
                     'Para maiores detalhes, consulte o log de pagamento de acordos (LOGTEL).';
    
      -- Realizar a solicitação do envio do e-mail
      gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper,
                                 pr_cdprogra    => 'RECP0001',
                                 pr_des_destino => vr_dsdemail,
                                 pr_des_assunto => vr_dsassunt,
                                 pr_des_corpo   => vr_dsdcorpo,
                                 pr_des_anexo   => NULL,
                                 pr_des_erro    => vr_des_erro);
    
      --Se ocorreu algum erro
      IF vr_des_erro IS NOT NULL THEN
        -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2,
                                   pr_nmarqlog     => vr_dsarqlog,
                                   pr_des_log      => to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  ACORDO ' || vr_dsrefere || ' - ' ||
                                                      'ERRO no envio de email: ' || vr_des_erro || ' ' ||
                                                      vr_dsmodule || '.');
      END IF;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 3,
                                   pr_nmarqlog     => vr_dsarqlog,
                                   pr_des_log      => to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  ACORDO ' || vr_dsrefere || ' - ' ||
                                                      'ERRO: ' || SQLERRM || ' ' || vr_dsmodule || '.');
      
        COMMIT;
    END pc_gera_log_mail;
  
    PROCEDURE pc_pagar_emprestimo_prejuizo(pr_cdcooper    IN crapepr.cdcooper%TYPE -- Código da Cooperativa
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE -- Número da Conta
                                          ,pr_cdagenci    IN crapass.cdagenci%TYPE -- Código da agencia
                                          ,pr_crapdat     IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                          ,pr_nrparcel    IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                          ,pr_nrctremp    IN crapepr.nrctremp%TYPE -- Número do contrato de empréstimo
                                          ,pr_tpemprst    IN crapepr.tpemprst%TYPE -- Tipo do empréstimo
                                          ,pr_vlprejuz    IN crapepr.vlprejuz%TYPE -- Valor do prejuízo
                                          ,pr_vlsdprej    IN crapepr.vlsdprej%TYPE -- Saldo do prejuízo
                                          ,pr_vlsprjat    IN crapepr.vlsprjat%TYPE -- Saldo anterior do prejuízo
                                          ,pr_vlpreemp    IN crapepr.vlpreemp%TYPE -- Valor da prestação do empréstimo
                                          ,pr_vlttmupr    IN crapepr.vlttmupr%TYPE -- Valor total da multa do prejuízo
                                          ,pr_vlpgmupr    IN crapepr.vlpgmupr%TYPE -- Valor pago da multa do prejuízo
                                          ,pr_vlttjmpr    IN crapepr.vlttjmpr%TYPE -- Valor total dos juros do prejuízo
                                          ,pr_vlpgjmpr    IN crapepr.vlpgjmpr%TYPE -- Valor pago dos juros do prejuízo
                                          ,pr_cdoperad    IN VARCHAR2 -- Código do cooperado
                                          ,pr_vlparcel    IN NUMBER -- Valor pago do boleto do acordo
                                          ,pr_inliqaco    IN VARCHAR2 DEFAULT 'N' -- Indica que deve realizar a liquidação do acordo
                                          ,pr_vlrabono    IN NUMBER DEFAULT 0 -- Valor do abono concedido (aplicado somente a contratos em prejuízo P637)
                                          ,pr_nmtelant    IN VARCHAR2 -- Nome da tela
                                          ,pr_vliofcpl    IN crapepr.vliofcpl%TYPE -- Valor do IOF complementar
                                          ,pr_flabono_iof IN NUMBER DEFAULT 0 -- Valor do abono concedido (aplicado somente a contratos em prejuízo P637)
                                          ,pr_vltotpag    OUT NUMBER -- Retorno do valor pago
                                          ,pr_cdcritic    OUT NUMBER -- Código de críticia
                                          ,pr_dscritic    OUT VARCHAR2) IS
      vr_dtprmutl          DATE; -- Data do primeiro dia útil do mês
      vr_vlajuste          NUMBER;
      vr_vlpagmto          NUMBER := pr_vlparcel;
      vr_vltotpgt          NUMBER := 0; -- PJ637
      vr_vlabono           NUMBER := pr_vlrabono;
      vr_des_reto          VARCHAR2(10);
      vr_tab_erro          GENE0001.typ_tab_erro;
      vr_cdcritic          NUMBER;
      vr_vljurdia          NUMBER := 0;
      vr_dscritic          VARCHAR2(1000);
      vr_vlsaldoiof_abonar NUMBER;
      vr_exc_erro EXCEPTION;
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      CURSOR cr_crapepr IS
        SELECT (epr.vlsdprej + (nvl(epr.vlttmupr, 0) - nvl(epr.vlpgmupr, 0)) +
               (nvl(epr.vlttjmpr, 0) - nvl(epr.vlpgjmpr, 0))) vlsdprjliq
              ,nvl(epr.vltiofpr, 0) - nvl(epr.vlpiofpr, 0) vlsaldoiof
              ,epr.tpemprst
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
    BEGIN
      ------------------------------------------------------------------------------------------------------------
      -- INICIO DO TRATAMENTO DA COMPEFORA
      ------------------------------------------------------------------------------------------------------------
      IF pr_nmtelant = 'COMPEFORA' THEN
        -- Busca o primeiro dia útil do mês
        vr_dtprmutl := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => TRUNC(pr_crapdat.dtmvtolt, 'MM'));
      
        -- Verifica se é o primeiro dia útil no mes
        IF pr_crapdat.dtmvtolt = vr_dtprmutl THEN
          -- Calcular o valor do ajuste
          vr_vlajuste := pr_vlsdprej - pr_vlsprjat;
        
          -- Se por um motivo não previsto o valor do ajuste for menor que zero, considerar zero
          IF NVL(vr_vlajuste, 0) < 0 THEN
            vr_vlajuste := 0;
          END IF;
        
          -- Se o valor do ajuste calculado é maior que zero
          IF NVL(vr_vlajuste, 0) > 0 THEN
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => pr_crapdat.dtmvtolt,
                                           pr_cdagenci => pr_cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => pr_cdoperad,
                                           pr_cdpactra => pr_cdagenci,
                                           pr_nrdolote => 600032,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_cdhistor => 2012,
                                           pr_vllanmto => vr_vlajuste,
                                           pr_nrparepr => pr_nrparcel,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_des_reto => vr_des_reto,
                                           pr_tab_erro => vr_tab_erro);
          
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
          
            -- O valor a ser pago da parcela será o valor da parcela acrescido do valor do ajuste
            vr_vlpagmto := NVL(vr_vlpagmto, 0) + nvl(vr_vlajuste, 0);
          END IF; -- FIM NVL(vr_vlajuste, 0) > 0
        END IF; -- FIM pr_dtmvtolt = vr_dtprmutl
      END IF; -- FIM pr_nmtelant = 'COMPEFORA'
      ------------------------------------------------------------------------------------------------------------
      -- FIM DO TRATAMENTO DA COMPEFORA
      ------------------------------------------------------------------------------------------------------------
    
      ------------------------------------------------------------------------------------------------------------
      -- INICIO PARA O LANÇAMENTO DE PAGAMENTO DO PREJUIZO ORIGINAL
      ----------------------------- := -------------------------------------------------------------------------------
      vr_vlsaldoiof_abonar := 0;
      IF pr_inliqaco = 'S' AND vr_vlpagmto = 0 THEN
        --vr_vlabono := pr_vlsdprej;
        OPEN cr_crapepr;
        FETCH cr_crapepr
          INTO rw_crapepr;
        CLOSE cr_crapepr;
      
        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
      
        --recebe o valor sem o IOF
        vr_vlabono := rw_crapepr.vlsdprjliq;
        IF pr_flabono_iof = 0 THEN
          --Se não abona, soma o valor do IOF ao prejuizo
          vr_vlabono := vr_vlabono + rw_crapepr.vlsaldoiof;
        ELSE
          --Se abona, deixa os valores separados
          vr_vlsaldoiof_abonar := rw_crapepr.vlsaldoiof;
        END IF;
      
        -- INICIO -- PRJ298.3
        IF rw_crapepr.tpemprst IN (1, 2) THEN
          prej0001.pc_calcula_juros_diario(pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_dtmvtoan => rw_crapdat.dtmvtoan,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_flconlan => FALSE,
                                           pr_vljurdia => vr_vljurdia,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) <> 0 THEN
            RAISE vr_exc_erro;
          END IF;
          vr_vlabono := vr_vlabono + vr_vljurdia;
        END IF;
      ELSE
        vr_vlabono := pr_vlrabono;
      END IF;
    
      pc_crps780_1(pr_cdcooper    => pr_cdcooper,
                   pr_nrdconta    => pr_nrdconta,
                   pr_nrctremp    => pr_nrctremp,
                   pr_vlpagmto    => vr_vlpagmto,
                   pr_vldabono    => vr_vlabono,
                   pr_cdagenci    => pr_cdagenci,
                   pr_cdoperad    => pr_cdoperad,
                   pr_vlabono_iof => vr_vlsaldoiof_abonar,
                   pr_vltotpgt    => vr_vltotpgt,
                   pr_cdcritic    => vr_cdcritic,
                   pr_dscritic    => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
        RAISE vr_exc_erro;
      ELSE
        pr_vltotpag := vr_vltotpgt;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_vltotpag := 0;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_vltotpag := 0;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na PC_PAGAR_EMPRESTIMO_PREJUIZO: ' || SQLERRM;
        ROLLBACK;
    END pc_pagar_emprestimo_prejuizo;
  
    PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper IN crapepr.cdcooper%TYPE -- Código da Cooperativa
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE -- Número da Conta
                                          ,pr_cdagenci IN NUMBER -- Código da agencia
                                          ,pr_crapdat  IN btch0001.cr_crapdat%ROWTYPE -- Datas da cooperativa
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE -- Número do contrato de empréstimo 
                                          ,pr_nracordo IN NUMBER -- Número do acordo
                                          ,pr_nrparcel IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                          ,pr_cdoperad IN VARCHAR2 -- Código do operador
                                          ,pr_vlparcel IN NUMBER -- Valor pago do boleto do acordo
                                          ,pr_idorigem IN NUMBER -- Indicador da origem
                                          ,pr_nmtelant IN VARCHAR2 -- Nome da tela 
                                          ,pr_flpagmin IN BOOLEAN DEFAULT FALSE -- Realizar apenas pagamento minimo
                                          ,pr_idvlrmin OUT NUMBER -- Indica que houve critica do valor minimo
                                          ,pr_vltotpag OUT NUMBER -- Retorno do valor pago
                                          ,pr_cdcritic OUT NUMBER -- Código de críticia
                                          ,pr_dscritic OUT VARCHAR2) IS
      CURSOR cr_crapepr IS
        SELECT epr.cdlcremp
              ,epr.tpemprst
              ,epr.flgpagto
              ,epr.inliquid
              ,epr.inprejuz
              ,epr.qtprepag
              ,epr.vlsdeved
              ,epr.vlsdevat
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.vlprejuz
              ,epr.vlsdprej
              ,epr.vlsprjat
              ,epr.vlpreemp
              ,epr.vlttmupr
              ,epr.vlpgmupr
              ,epr.vlttjmpr
              ,epr.vlpgjmpr
              ,epr.dtultpag
              ,epr.vliofcpl
              ,epr.dtmvtolt
              ,epr.vlemprst
              ,epr.txmensal
              ,epr.dtdpagto
              ,epr.vlsprojt
              ,epr.qttolatr
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr  cr_crapepr%ROWTYPE;
      vr_vlpagmto NUMBER := pr_vlparcel;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(1000);
      vr_exp_erro EXCEPTION;
    BEGIN
      OPEN cr_crapepr;
      FETCH cr_crapepr
        INTO rw_crapepr;
    
      -- Se o contrato não for encontrado
      IF cr_crapepr%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapepr;
      
        -- Deve retornar erro de execução
        pr_cdcritic := 0;
        pr_dscritic := 'Contrato ' || TRIM(GENE0002.fn_mask_contrato(pr_nrctremp)) ||
                       ' do acordo não foi encontrado para a conta ' ||
                       TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) || '.';
        RAISE vr_exp_erro;
      END IF;
    
      -- Fecha o cursor
      CLOSE cr_crapepr;
    
      -- Verificar se o contrato já está LIQUIDADO   OU
      -- Se o contrato de PREJUIZO já foi TOTALMENTE PAGO
      IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0) OR
         (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
        pr_vltotpag := 0; -- Indicar que nenhum valor foi pago para este contrato
        RETURN; -- Retornar da rotina
      END IF;
    
      pr_idvlrmin := 0;
      IF rw_crapepr.inprejuz = 1 THEN
        pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_cdagenci => pr_cdagenci,
                                     pr_crapdat  => pr_crapdat,
                                     pr_nrctremp => pr_nrctremp,
                                     pr_tpemprst => rw_crapepr.tpemprst,
                                     pr_vlprejuz => rw_crapepr.vlprejuz,
                                     pr_vlsdprej => rw_crapepr.vlsdprej,
                                     pr_vlsprjat => rw_crapepr.vlsprjat,
                                     pr_vlpreemp => rw_crapepr.vlpreemp,
                                     pr_vlttmupr => rw_crapepr.vlttmupr,
                                     pr_vlpgmupr => rw_crapepr.vlpgmupr,
                                     pr_vlttjmpr => rw_crapepr.vlttjmpr,
                                     pr_vlpgjmpr => rw_crapepr.vlpgjmpr,
                                     pr_nrparcel => pr_nrparcel,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_vlparcel => vr_vlpagmto,
                                     pr_nmtelant => pr_nmtelant,
                                     pr_vliofcpl => rw_crapepr.vliofcpl,
                                     pr_vltotpag => pr_vltotpag,
                                     pr_cdcritic => vr_cdcritic,
                                     pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
      ELSIF rw_crapepr.flgpagto = 1 THEN
        EMPR9999.pc_pagar_emprestimo_folha(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_cdagenci => pr_cdagenci,
                                           pr_crapdat  => pr_crapdat,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_nrparcel => pr_nrparcel,
                                           pr_cdlcremp => rw_crapepr.cdlcremp,
                                           pr_inliquid => rw_crapepr.inliquid,
                                           pr_qtprepag => rw_crapepr.qtprepag,
                                           pr_vlsdeved => rw_crapepr.vlsdeved,
                                           pr_vlsdevat => rw_crapepr.vlsdevat,
                                           pr_vljuracu => rw_crapepr.vljuracu,
                                           pr_txjuremp => rw_crapepr.txjuremp,
                                           pr_dtultpag => rw_crapepr.dtultpag,
                                           pr_vlparcel => vr_vlpagmto,
                                           pr_nmtelant => pr_nmtelant,
                                           pr_cdoperad => pr_cdcooper,
                                           pr_vltotpag => pr_vltotpag,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
      ELSE
        IF rw_crapepr.tpemprst = 0 THEN
          EMPR9999.pc_pagar_emprestimo_tr(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_crapdat  => pr_crapdat,
                                          pr_nrctremp => pr_nrctremp,
                                          pr_nrparcel => pr_nrparcel,
                                          pr_cdlcremp => rw_crapepr.cdlcremp,
                                          pr_inliquid => rw_crapepr.inliquid,
                                          pr_qtprepag => rw_crapepr.qtprepag,
                                          pr_vlsdeved => rw_crapepr.vlsdeved,
                                          pr_vlsdevat => rw_crapepr.vlsdevat,
                                          pr_vljuracu => rw_crapepr.vljuracu,
                                          pr_txjuremp => rw_crapepr.txjuremp,
                                          pr_dtultpag => rw_crapepr.dtultpag,
                                          pr_vlparcel => vr_vlpagmto,
                                          pr_idorigem => pr_idorigem,
                                          pr_nmtelant => pr_nmtelant,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_vltotpag => pr_vltotpag,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exp_erro;
          END IF;
        ELSIF rw_crapepr.tpemprst = 1 THEN
          recp0001.pc_pagar_emprestimo_pp(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_crapdat  => pr_crapdat,
                                          pr_nrctremp => pr_nrctremp,
                                          pr_nracordo => pr_nracordo,
                                          pr_nrparcel => pr_nrparcel,
                                          pr_vlsdeved => rw_crapepr.vlsdeved,
                                          pr_vlsdevat => rw_crapepr.vlsdevat,
                                          pr_vlparcel => vr_vlpagmto,
                                          pr_idorigem => pr_idorigem,
                                          pr_nmtelant => pr_nmtelant,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_flpagmin => pr_flpagmin,
                                          pr_idvlrmin => pr_idvlrmin,
                                          pr_vltotpag => pr_vltotpag,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exp_erro;
          END IF;
        ELSIF rw_crapepr.tpemprst = 2 THEN
          recp0001.pc_pagar_emprestimo_pos(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_cdagenci => pr_cdagenci,
                                           pr_crapdat  => pr_crapdat,
                                           pr_nrctremp => pr_nrctremp,
                                           pr_dtefetiv => rw_crapepr.dtmvtolt,
                                           pr_cdlcremp => rw_crapepr.cdlcremp,
                                           pr_vlemprst => rw_crapepr.vlemprst,
                                           pr_txmensal => rw_crapepr.txmensal,
                                           pr_dtdpagto => rw_crapepr.dtdpagto,
                                           pr_vlsprojt => rw_crapepr.vlsprojt,
                                           pr_qttolatr => rw_crapepr.qttolatr,
                                           pr_nrparcel => pr_nrparcel,
                                           pr_vlparcel => vr_vlpagmto,
                                           pr_idorigem => pr_idorigem,
                                           pr_nmtelant => pr_nmtelant,
                                           pr_cdoperad => pr_cdoperad,
                                           pr_flpagmin => pr_flpagmin,
                                           pr_idvlrmin => pr_idvlrmin,
                                           pr_vltotpag => pr_vltotpag,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exp_erro;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exp_erro THEN
        pr_vltotpag := 0;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_vltotpag := 0;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_EMPRESTIMO: ' || SQLERRM;
    END pc_pagar_contrato_emprestimo;
  
    PROCEDURE pc_pagar_minimo_acordo(pr_nracordo IN tbrecup_acordo.nracordo%TYPE
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE
                                    ,pr_cdoperad IN VARCHAR2
                                    ,pr_nrparcel IN tbrecup_acordo_parcela.nrparcela%TYPE
                                    ,pr_crapdat  IN btch0001.cr_crapdat%ROWTYPE
                                    ,pr_idorigem IN NUMBER
                                    ,pr_nmtelant IN VARCHAR2
                                    ,pr_vlparcel IN OUT NUMBER
                                    ,pr_vltotpag OUT NUMBER
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
      CURSOR cr_acordo_contrato_pgmin(pr_nracordo IN tbrecup_acordo_contrato.nracordo%TYPE) IS
        SELECT a.cdcooper
              ,a.nrdconta
              ,c.nrctremp
              ,c.cdorigem
          FROM tbrecup_acordo a
         INNER JOIN tbrecup_acordo_contrato c
            ON a.nracordo = c.nracordo
         INNER JOIN crapepr e
            ON e.cdcooper = a.cdcooper
           AND e.nrdconta = a.nrdconta
           AND e.nrctremp = c.nrctremp
         WHERE a.nracordo = pr_nracordo
           AND a.cdsituacao = recuperacao.tiposdadosacordos.situacao_ativo
           AND c.cdorigem = 3
           AND e.tpemprst IN (1, 2) -- PP e POS
           AND e.inprejuz = 0
           AND e.inliquid = 0
           AND e.vlsdeved > 0;
      rw_acordo_contrato_pgmin cr_acordo_contrato_pgmin%ROWTYPE;
    
      vr_vltotpag NUMBER;
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(1000);
      vr_idvlrmin NUMBER := 0;
      vr_exe_erro EXCEPTION;
    BEGIN
      -- Efetuar pagamento valor minimo dos contratos do acordo
      FOR rw_acordo_contrato_pgmin IN cr_acordo_contrato_pgmin(pr_nracordo) LOOP
        IF (rw_acordo_contrato_pgmin.cdorigem IN (2, 3)) THEN
          pc_pagar_contrato_emprestimo(pr_cdcooper => rw_acordo_contrato_pgmin.cdcooper,
                                       pr_nrdconta => rw_acordo_contrato_pgmin.nrdconta,
                                       pr_nrctremp => rw_acordo_contrato_pgmin.nrctremp,
                                       pr_nracordo => pr_nracordo,
                                       pr_nrparcel => pr_nrparcel,
                                       pr_cdagenci => pr_cdagenci,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_crapdat  => pr_crapdat,
                                       pr_vlparcel => pr_vlparcel,
                                       pr_idorigem => pr_idorigem,
                                       pr_nmtelant => pr_nmtelant,
                                       pr_flpagmin => TRUE,
                                       pr_idvlrmin => vr_idvlrmin,
                                       pr_vltotpag => vr_vltotpag,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
          IF (vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato_pgmin.cdcooper,
                             pr_nrdconta => rw_acordo_contrato_pgmin.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato_pgmin.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'PAGAR_CONTRATO_EMPRESTIMO_MINIMO');
            RAISE vr_exe_erro;
          END IF;
          pr_vltotpag := NVL(pr_vltotpag, 0) + nvl(vr_vltotpag, 0);
          pr_vlparcel := pr_vlparcel - nvl(vr_vltotpag, 0);
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exe_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    END pc_pagar_minimo_acordo;
  BEGIN
    OPEN cr_acordo;
    FETCH cr_acordo
      INTO rw_acordo;
  
    -- Se o acordo não for encontrado
    IF cr_acordo%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_acordo;
    
      pr_dscritic := 'Acordo número ' || pr_nracordo || ' não foi encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Fecha o cursor
    CLOSE cr_acordo;
  
    -- Buscar o CRAPDAT da cooperativa
    OPEN BTCH0001.cr_crapdat(rw_acordo.cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO BTCH0001.rw_crapdat;
  
    -- Se não encontrar registro na CRAPDAT
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    
      pr_dscritic := 'Erro ao buscar datas da cooperativa(' || rw_acordo.cdcooper || ').';
      RAISE vr_exc_erro;
    END IF;
  
    -- Fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  
    -- Buscar os dados do cooperado
    OPEN cr_crapass(rw_acordo.cdcooper, rw_acordo.nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
  
    -- Se não encontrar registro na CRAPASS
    IF cr_crapass%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapass;
    
      pr_dscritic := 'Erro ao buscar dados da conta do cooperado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
  
    vr_tab_saldos.DELETE;
    vr_vlsddisp := 0;
    vr_tab_saldos.DELETE;
    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_acordo.cdcooper,
                                pr_rw_crapdat => BTCH0001.rw_crapdat,
                                pr_cdagenci   => rw_crapass.cdagenci,
                                pr_nrdcaixa   => 100,
                                pr_cdoperad   => pr_cdoperad,
                                pr_nrdconta   => rw_acordo.nrdconta,
                                pr_vllimcre   => rw_crapass.vllimcre,
                                pr_dtrefere   => BTCH0001.rw_crapdat.dtmvtolt,
                                pr_des_reto   => vr_des_erro,
                                pr_tab_sald   => vr_tab_saldos,
                                pr_tipo_busca => 'A',
                                pr_tab_erro   => vr_tab_erro);
  
    -- Se retornar erro 
    IF vr_des_erro <> 'OK' THEN
      pr_dscritic := 'Erro ao obter saldo: ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      RAISE vr_exc_erro;
    END IF;
  
    -- Verifica se encontrou saldo
    IF vr_tab_saldos.COUNT() > 0 THEN
      -- Guardar indice inicial da tabela de saldos
      vr_idxsaldo := vr_tab_saldos.FIRST;
    
      /*
        Se a conta não está em prejuízo, desconta o valor da parcela do saldo devedor da conta.
          Se a conta estiver em prejuízo, o valor da parcela já foi debitado (transferido para a conta transitória)
      */
      IF rw_crapass.inprejuz = 0 THEN
        -- Saldo Disponivel na conta corrente - Descontando o valor pago do boleto
        vr_vlsddisp := NVL(vr_tab_saldos(vr_idxsaldo).vlsddisp, 0) - nvl(vr_vlparcel, 0);
      ELSE
        vr_vlsddisp := NVL(vr_tab_saldos(vr_idxsaldo).vlsddisp, 0) -
                       PREJ0003.fn_juros_remun_prov(rw_acordo.cdcooper, rw_acordo.nrdconta);
      END IF;
    ELSE
      pr_dscritic := 'Não foi retornado saldo dia da conta.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Verifica se o acordo dispõe de saldo bloqueado
    IF NVL(rw_acordo.vlbloqueado, 0) > 0 THEN
    
      -- Valor do boleto será o valor pago do boleto + saldo bloqueado do acordo
      vr_vlparcel := nvl(vr_vlparcel, 0) + rw_acordo.vlbloqueado;
    
      IF rw_crapass.inprejuz = 0 THEN
        -- Gera o lançamento na conta para descontar o saldo bloqueado
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper,
                                       pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                       pr_cdagenci => rw_crapass.cdagenci,
                                       pr_cdbccxlt => 100,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_cdpactra => rw_crapass.cdagenci,
                                       pr_nrdolote => 650001,
                                       pr_nrdconta => rw_acordo.nrdconta,
                                       pr_cdhistor => 2194,
                                       pr_vllanmto => rw_acordo.vlbloqueado,
                                       pr_nrparepr => pr_nrparcel,
                                       pr_nrctremp => 0,
                                       pr_des_reto => vr_des_erro,
                                       pr_tab_erro => vr_tab_erro);
      
        -- Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => rw_acordo.cdcooper,
                                      pr_nrdconta => rw_acordo.nrdconta,
                                      pr_vlrlanc  => rw_acordo.vlbloqueado,
                                      pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
      
        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        
          RAISE vr_exc_erro;
        END IF;
      
        PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => rw_acordo.cdcooper,
                                          pr_nrdconta => rw_acordo.nrdconta,
                                          pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                          pr_cdhistor => 2971,
                                          pr_vllanmto => rw_acordo.vlbloqueado,
                                          pr_dthrtran => SYSDATE,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      
        IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NOT NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      -- ZERAR O VALOR BLOQUEADO NA TABELA DE ACORDO
      BEGIN
        -- Alterar a situação do acordo para cancelado
        UPDATE tbrecup_acordo
           SET vlbloqueado = 0
         WHERE nracordo = pr_nracordo;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao zerar saldo bloqueado: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    END IF; -- Fim saldo bloqueado do acordo   
  
    /* ---------------------------------------------------------------------------------------------------------
      O sistema Ayllos deverá cadastrar o(s) contrato(s) do acordo como CIN quando identificar o pagamento da 
      entrada ou primeira parcela (do acordo). Caso o contrato já esteja marcado como CIN, o sistema deverá 
      sobrescrever a marcação.
    ----------------------------------------------------------------------------------------------------------*/
    -- Se for o pagamentos da primeira parcela
    IF pr_nrparcel = 0 THEN
      -- Percorre todos os contratos do acordo 
      FOR rw_acordo_contrato IN cr_acordo_contrato LOOP
        --Giovane Gibbert/Mouts Para os contratos com modelo 0, faz a busca do modelo de acordo com as regras
        IF rw_acordo_contrato.cdmodelo = 0 THEN
          IF to_char(BTCH0001.rw_crapdat.dtmvtolt, 'MM') <>
             to_char(BTCH0001.rw_crapdat.dtmvtoan, 'MM') THEN
            vr_dtrefere := BTCH0001.rw_crapdat.dtultdma;
          ELSE
            vr_dtrefere := BTCH0001.rw_crapdat.dtmvtoan;
          END IF;
          RECUPERACAO.obterModeloAcordo(pr_cdcooper       => rw_acordo_contrato.cdcooper,
                                        pr_nrdconta       => rw_acordo_contrato.nrdconta,
                                        pr_nrctremp       => rw_acordo_contrato.nrctremp,
                                        pr_cdorigem       => rw_acordo_contrato.cdorigem,
                                        pr_dtmvtoan       => vr_dtrefere,
                                        pr_dtmvtolt       => BTCH0001.rw_crapdat.dtmvtolt,
                                        pr_flgpreju       => rw_acordo_contrato.flgpreju,
                                        pr_tpoperacao     => 'P',
                                        pr_cdmodelo       => vr_cdmodelo,
                                        pr_inrisco_acordo => vr_inrisco_acordo,
                                        pr_cdcritic       => vr_cdcritic,
                                        pr_dscritic       => vr_dscritic);
        
          IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --> Caso não identifique o modelo de acordo, deve manter modelo antigo
            vr_cdmodelo       := 1;
            vr_inrisco_acordo := 0;
          
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => rw_acordo_contrato.cdcooper,
                                       pr_ind_tipo_log => 2,
                                       pr_nmarqlog     => vr_dsarqlog,
                                       pr_des_log      => to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' -->  ACORDO ' || '[' || pr_nracordo || '/' ||
                                                          rw_acordo_contrato.nrdconta || '/' ||
                                                          rw_acordo_contrato.nrctremp || ']' ||
                                                          ' - ERRO: ' || vr_dscritic ||
                                                          ' RECUPERACAO.obterModeloAcordo.');
          
            vr_cdcritic := 0;
            vr_dscritic := NULL;
          
          END IF;
        
          BEGIN
            -- Alterar o modelo do acordo e o risco do mesmo
            UPDATE tbrecup_acordo_contrato ctr
               SET ctr.cdmodelo       = vr_cdmodelo
                  ,ctr.inrisco_acordo = vr_inrisco_acordo
             WHERE ctr.nracordo = pr_nracordo
               AND ctr.nrgrupo = rw_acordo_contrato.nrgrupo
               AND ctr.cdorigem = rw_acordo_contrato.cdorigem
               AND ctr.nrctremp = rw_acordo_contrato.nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar modelo do acordo: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      
        BEGIN
          UPDATE crapcyc
             SET flvipant = flgehvip
                ,cdmotant = decode(cdmotcin, 2, cdmotant, 7, cdmotant, cdmotcin)
                ,flgehvip = 1
                ,cdmotcin = decode(cdmotcin, 2, cdmotcin, 7, cdmotcin, 1)
                ,dtaltera = BTCH0001.rw_crapdat.dtmvtolt
                ,cdoperad = 'cyber'
           WHERE cdcooper = rw_acordo_contrato.cdcooper
             AND cdorigem = DECODE(rw_acordo_contrato.cdorigem, 2, 3, rw_acordo_contrato.cdorigem)
             AND nrdconta = rw_acordo_contrato.nrdconta
             AND nrctremp = rw_acordo_contrato.nrctremp;
        
          -- Se não encontrou registro para alterar
          IF SQL%ROWCOUNT = 0 THEN
            -- Deverá realizar a inclusão do registro
            INSERT INTO crapcyc
              (cdcooper
              ,cdorigem
              ,nrdconta
              ,nrctremp
              ,cdoperad
              ,dtinclus
              ,cdopeinc
              ,dtaltera
              ,flgehvip
              ,cdmotcin)
            VALUES
              (rw_acordo_contrato.cdcooper -- cdcooper
              ,DECODE(rw_acordo_contrato.cdorigem, 2, 3, rw_acordo_contrato.cdorigem) -- cdorigem
              ,rw_acordo_contrato.nrdconta -- nrdconta
              ,rw_acordo_contrato.nrctremp -- nrctremp
              ,pr_cdoperad -- cdoperad
              ,BTCH0001.rw_crapdat.dtmvtolt -- dtinclus
              ,pr_cdoperad -- cdopeinc
              ,BTCH0001.rw_crapdat.dtmvtolt -- dtaltera
              ,1 -- flgehvip
              ,1); -- cdmotcin
          
          END IF; -- IF SQL%ROWCOUNT = 0 
        
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPCYC: ' || SQLERRM;
          
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                             pr_nrdconta => rw_acordo_contrato.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'ATUALIZACAO_CIN');
        END;
      END LOOP;
    END IF;
    vr_flagerro := FALSE;
    pc_pagar_minimo_acordo(pr_nracordo => pr_nracordo,
                           pr_cdagenci => rw_crapass.cdagenci,
                           pr_cdoperad => pr_cdoperad,
                           pr_nrparcel => pr_nrparcel,
                           pr_crapdat  => btch0001.rw_crapdat,
                           pr_idorigem => pr_idorigem,
                           pr_nmtelant => CASE
                                            WHEN rw_crapass.inprejuz = 1 THEN
                                             'BLQPREJU'
                                            ELSE
                                             pr_nmtelant
                                          END,
                           pr_vlparcel => vr_vlparcel,
                           pr_vltotpag => vr_vltotpag,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic);
  
    pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
  
    IF rw_crapass.inprejuz = 1 AND NVL(vr_vltotpag, 0) > 0 THEN
      -- Debita da conta transitória o valor utilizado para pagamento do empréstimo
      PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_acordo.cdcooper,
                                    pr_nrdconta => rw_acordo.nrdconta,
                                    pr_vlrlanc  => NVL(vr_vltotpag, 0),
                                    pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                    pr_dsoperac => 'RECP0001 MIN',
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
        -- Indicar que houve crítica ao processar o pagamento de estouro de conta
        vr_flagerro := TRUE;
      
        -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
        pc_gera_log_mail(pr_cdcooper => rw_acordo.cdcooper,
                         pr_nrdconta => rw_acordo.nrdconta,
                         pr_nracordo => pr_nracordo,
                         pr_nrctremp => 0,
                         pr_dscritic => vr_dscritic,
                         pr_dsmodule => 'PAGAR_CONTRATO_MIN');
      
      END IF;
    END IF;
  
    vr_qtdCtrEmAberto := 0;
    vr_qtdCtrEmAberto := fn_qtd_contrato_saldo_pagar(pr_nracordo => pr_nracordo,
                                                     pr_vlsddisp => vr_vlsddisp);
    --Loop para fazer duas tentativas de pagamento quando sobrar valor
    FOR idx IN 1 .. 2 LOOP
      -- Percorrer os contratos do acordo, conforme a regra de pagamentos
      FOR rw_acordo_contrato IN cr_acordo_contrato LOOP
      
        vr_vlParCtr     := round(vr_vlparcel / greatest(nvl(vr_qtdCtrEmAberto, 0), 1), 2);
        vr_vltotpag     := 0;
        vr_vltotpag_iof := 0;
      
        -- Se a origem estiver indicando ESTOURO DE CONTA
        IF rw_acordo_contrato.cdorigem = 1 THEN
        
          --IOF
          BEGIN
            -- Regularizar valor do IOF de estouro de conta do acordo
            recp0001.pc_pagar_IOF_contrato_conta(pr_cdcooper  => rw_acordo_contrato.cdcooper,
                                                 pr_nrdconta  => rw_acordo_contrato.nrdconta,
                                                 pr_cdagenci  => rw_crapass.cdagenci,
                                                 pr_crapdat   => BTCH0001.rw_crapdat,
                                                 pr_cdoperad  => pr_cdoperad,
                                                 pr_nracordo  => pr_nracordo,
                                                 pr_vlparcel  => vr_vlParCtr,
                                                 pr_vliofdev  => rw_acordo_contrato.vliofdev,
                                                 pr_vlbasiof  => rw_acordo_contrato.vlbasiof,
                                                 pr_vliofpag  => rw_acordo_contrato.vliofpag,
                                                 pr_rowid_ctr => rw_acordo_contrato.rowid
                                                 
                                                ,
                                                 pr_vltotpag => vr_vltotpag,
                                                 pr_cdcritic => vr_cdcritic,
                                                 pr_dscritic => vr_dscritic);
          
            -- Verifica ocorrencia de erro                   
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            
              -- Indicar que houve crítica ao processar o pagamento de estouro de conta
              vr_flagerro := TRUE;
            
              -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
              pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                               pr_nrdconta => rw_acordo_contrato.nrdconta,
                               pr_nracordo => pr_nracordo,
                               pr_nrctremp => rw_acordo_contrato.nrctremp,
                               pr_dscritic => vr_dscritic,
                               pr_dsmodule => 'PC_PAGAR_IOF_CONTRATO_CONTA');
            
              -- Voltar ao Loop para processar o próximo pagamento
              CONTINUE;
            
            END IF;
          
            -- Lança IOF pago no extrato do prejuízo de conta corrente
            IF rw_crapass.inprejuz = 1 THEN
              PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                                pr_nrdconta => rw_acordo_contrato.nrdconta,
                                                pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                                pr_cdhistor => 2323,
                                                pr_vllanmto => vr_vltotpag,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);
            
              -- Verifica ocorrencia de erro
              IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
                -- Indicar que houve crítica ao processar o pagamento de estouro de conta
                vr_flagerro := TRUE;
              
                -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
                pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                 pr_nrdconta => rw_acordo_contrato.nrdconta,
                                 pr_nracordo => pr_nracordo,
                                 pr_nrctremp => rw_acordo_contrato.nrctremp,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsmodule => 'PC_PAGAR_IOF_CONTRATO_CONTA');
              
                -- Voltar ao Loop para processar o próximo pagamento
                CONTINUE;
              END IF;
            END IF;
          
            -- Somar o valor pago ao montante total de pagamentos
            pr_vltotpag     := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
            vr_vltotpag_iof := nvl(vr_vltotpag, 0);
            vr_vlParCtr     := vr_vlParCtr - NVL(vr_vltotpag, 0);
            -----------------------------------------------------------------------------------------------
          END;
          --FIM IOF
        
          IF NVL(rw_crapass.vllimcre, 0) > 0 THEN
            vr_vlsddisp := vr_vlsddisp + NVL(rw_crapass.vllimcre, 0);
          END IF;
          -- Chamar procedure para regularizar o valor do estouro de conta
          recp0001.pc_pagar_contrato_conta(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                           pr_nrdconta => rw_acordo_contrato.nrdconta,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_crapdat  => BTCH0001.rw_crapdat,
                                           pr_cdoperad => pr_cdoperad,
                                           pr_nracordo => pr_nracordo,
                                           pr_vlsddisp => vr_vlsddisp,
                                           pr_vlparcel => vr_vlParCtr,
                                           pr_vltotpag => vr_vltotpag,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
        
          -- Verifica ocorrencia de erro                   
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
          
            -- Indicar que houve crítica ao processar o pagamento de estouro de conta
            vr_flagerro := TRUE;
          
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                             pr_nrdconta => rw_acordo_contrato.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
          
            -- Voltar ao Loop para processar o próximo pagamento
            CONTINUE;
          ELSE
            -- Se pagou a conta corrente
            -- Somar o valor pago ao montante total de pagamentos
            pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
            vr_vlsddisp := nvl(vr_vlsddisp, 0) + nvl(vr_vltotpag, 0);
            vr_vltotpag := nvl(vr_vltotpag, 0) + nvl(vr_vltotpag_iof, 0);
            -----------------------------------------------------------------------------------------------
          
            IF rw_acordo_contrato.inprejuz = 1 THEN
              -- Efetua o pagamento do prejuízo de conta corrente
              PREJ0003.pc_pagar_prejuizo_cc(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                            pr_nrdconta => rw_acordo_contrato.nrdconta,
                                            pr_vlrpagto => vr_vltotpag - nvl(vr_vltotpag_iof, 0),
                                            pr_atsldlib => 0,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
            
              IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
                -- Indicar que houve crítica ao processar o pagamento de estouro de conta
                vr_flagerro := TRUE;
              
                -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
                pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                 pr_nrdconta => rw_acordo_contrato.nrdconta,
                                 pr_nracordo => pr_nracordo,
                                 pr_nrctremp => rw_acordo_contrato.nrctremp,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
              
                -- Voltar ao Loop para processar o próximo pagamento
                CONTINUE;
              END IF;
            
              -- Debita da conta transitória o valor utilizado para pagamento
              PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                            pr_nrdconta => rw_acordo_contrato.nrdconta,
                                            pr_vlrlanc  => vr_vltotpag,
                                            pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                            pr_dsoperac => 'RECP0001 CC',
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
            
              IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
                -- Indicar que houve crítica ao processar o pagamento de estouro de conta
                vr_flagerro := TRUE;
              
                -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
                pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                 pr_nrdconta => rw_acordo_contrato.nrdconta,
                                 pr_nracordo => pr_nracordo,
                                 pr_nrctremp => rw_acordo_contrato.nrctremp,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
              
                -- Voltar ao Loop para processar o próximo pagamento
                CONTINUE;
              END IF;
            
              vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT',
                                         pr_nmdcampo => 'NRSEQDIG',
                                         pr_dsdchave => to_char(rw_acordo_contrato.cdcooper) || ';' ||
                                                        to_char(BTCH0001.rw_crapdat.dtmvtolt,
                                                                'DD/MM/RRRR') || ';' ||
                                                        '1;100;650010');
            
              LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => BTCH0001.rw_crapdat.dtmvtolt,
                                                 pr_cdagenci    => 1,
                                                 pr_cdbccxlt    => 100,
                                                 pr_nrdolote    => 650010,
                                                 pr_nrdconta    => rw_acordo_contrato.nrdconta,
                                                 pr_nrdocmto    => PREJ0003.fn_gera_nrdocmto_craplcm(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                                                                                     pr_nrdconta => rw_acordo_contrato.nrdconta,
                                                                                                     pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                                                                                     pr_cdhistor => 2733),
                                                 pr_cdhistor    => 2720,
                                                 pr_nrseqdig    => vr_nrseqdig,
                                                 pr_vllanmto    => vr_vltotpag,
                                                 pr_nrdctabb    => rw_acordo_contrato.nrdconta,
                                                 pr_cdpesqbb    => 'PAGAMENTO DE PREJUÍZO DE C/C VIA ACORDO',
                                                 pr_dtrefere    => BTCH0001.rw_crapdat.dtmvtolt,
                                                 pr_hrtransa    => gene0002.fn_busca_time,
                                                 pr_cdoperad    => 1,
                                                 pr_cdcooper    => rw_acordo_contrato.cdcooper,
                                                 pr_cdorigem    => 5,
                                                 pr_incrineg    => vr_incrineg,
                                                 pr_tab_retorno => vr_tab_retorno,
                                                 pr_cdcritic    => vr_cdcritic,
                                                 pr_dscritic    => vr_dscritic);
            
              IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Indicar que houve crítica ao processar o pagamento de estouro de conta
                vr_flagerro := TRUE;
              
                -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
                pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                 pr_nrdconta => rw_acordo_contrato.nrdconta,
                                 pr_nracordo => pr_nracordo,
                                 pr_nrctremp => rw_acordo_contrato.nrctremp,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
              
                -- Voltar ao Loop para processar o próximo pagamento
                CONTINUE;
              END IF;
            END IF; -- FIM IF rw_acordo_contrato.inprejuz = 1 THEN
          END IF;
        
          -- Diminuir o valor pago do boleto com o lançamento efetuado na conta corrente
          --vr_vlparcel := vr_vlparcel - NVL(vr_vltotpag,0);
          -----------------------------------------------------------------------------------------------
          --Se sobrou valor no pagamento e tem juros ou taxa de conta negativa, joga commo erro para forçar bloqueio dos valores
          IF vr_vlParCtr - vr_vltotpag > 0 AND
             (nvl(rw_acordo_contrato.vljuresp, 0) > 0 OR nvl(rw_acordo_contrato.vljurmes, 0) > 0) THEN
            vr_flagerro := TRUE;
          END IF;
        ELSIF rw_acordo_contrato.cdorigem IN (2, 3) THEN
          pc_pagar_contrato_emprestimo(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                       pr_nrdconta => rw_acordo_contrato.nrdconta,
                                       pr_nrctremp => rw_acordo_contrato.nrctremp,
                                       pr_nracordo => pr_nracordo,
                                       pr_nrparcel => pr_nrparcel,
                                       pr_cdagenci => rw_crapass.cdagenci,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_crapdat  => BTCH0001.rw_crapdat,
                                       pr_vlparcel => vr_vlParCtr,
                                       pr_idorigem => pr_idorigem,
                                       pr_nmtelant => CASE
                                                        WHEN rw_crapass.inprejuz = 1 THEN
                                                         'BLQPREJU'
                                                        ELSE
                                                         pr_nmtelant
                                                      END,
                                       pr_idvlrmin => vr_idvlrmin,
                                       pr_vltotpag => vr_vltotpag,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            vr_flagerro := TRUE;
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                             pr_nrdconta => rw_acordo_contrato.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'PAGAR_CONTRATO_EMPRESTIMO');
            RAISE vr_exc_erro;
          END IF;
          vr_vlpagocontrato := nvl(vr_vlpagocontrato, 0) + vr_vltotpag;
          -- Se houver ocorrencia de critica de valor mínimo
          IF NVL(vr_idvlrmin, 0) = 1 THEN
            -- Indicar que houve critica ao processar pagamento de empréstimo
            vr_flagerro := TRUE;
          END IF;
        
          -----------------------------------------------------------------------------------------------
        
          -- Novo cálculo de IOF
          vr_dscatbem := NULL;
          vr_cdlcremp := NULL;
        
          --Verifica o primeiro bem do contrato para saber se tem isenção de alíquota
          OPEN cr_crapbpr(pr_cdcooper => rw_acordo_contrato.cdcooper,
                          pr_nrdconta => rw_acordo_contrato.nrdconta,
                          pr_nrctremp => rw_acordo_contrato.nrctremp);
          FETCH cr_crapbpr
            INTO rw_crapbpr;
          IF cr_crapbpr%FOUND THEN
            vr_dscatbem := rw_crapbpr.dscatbem;
            vr_cdlcremp := rw_crapbpr.cdlcremp;
            vr_cdfinemp := rw_crapbpr.cdfinemp;
          END IF;
          CLOSE cr_crapbpr;
        
          --Dias de atraso
          OPEN cr_crapepr(pr_cdcooper => rw_acordo_contrato.cdcooper,
                          pr_nrdconta => rw_acordo_contrato.nrdconta,
                          pr_nrctremp => rw_acordo_contrato.nrctremp);
          FETCH cr_crapepr
            INTO rw_crapepr;
          IF cr_crapepr%FOUND THEN
            vr_qtdiaiof := rw_crapepr.dtdpagto - BTCH0001.rw_crapdat.dtmvtolt;
          ELSE
            vr_qtdiaiof := 0;
          END IF;
          CLOSE cr_crapepr;
        
          --Calcula o IOF
          TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac             => 2,
                                            pr_cdcooper             => rw_acordo_contrato.cdcooper,
                                            pr_nrdconta             => rw_acordo_contrato.nrdconta,
                                            pr_nrctremp             => rw_acordo_contrato.nrctremp,
                                            pr_vlemprst             => vr_vlParCtr,
                                            pr_dscatbem             => vr_dscatbem,
                                            pr_cdlcremp             => vr_cdlcremp,
                                            pr_cdfinemp             => vr_cdfinemp,
                                            pr_dtmvtolt             => BTCH0001.rw_crapdat.dtmvtolt,
                                            pr_qtdiaiof             => vr_qtdiaiof,
                                            pr_vliofpri             => vr_vliofpri,
                                            pr_vliofadi             => vr_vliofadi,
                                            pr_vliofcpl             => vr_vliofcpl,
                                            pr_vltaxa_iof_principal => vr_vltaxa_iof_principal,
                                            pr_flgimune             => vr_flgimune,
                                            pr_dscritic             => vr_dscritic);
        
          IF NVL(vr_dscritic, ' ') <> ' ' THEN
            RAISE vr_exc_erro;
          END IF;
        
          --Imunidade....
          IF vr_flgimune > 0 THEN
            vr_vliofpri := 0;
            vr_vliofadi := 0;
            vr_vliofcpl := 0;
          ELSE
            vr_vliofcpl := NVL(vr_vliofcpl, 0);
          END IF;
        
          -- Somar o valor pago ao montante total de pagamentos
          pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
          -----------------------------------------------------------------------------------------------
        
          IF rw_crapass.inprejuz = 1 THEN
            -- Debita da conta transitória o valor utilizado para pagamento do empréstimo
            PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                          pr_nrdconta => rw_acordo_contrato.nrdconta,
                                          pr_vlrlanc  => NVL(vr_vltotpag, 0),
                                          pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                          pr_dsoperac => 'RECP0001 EPR',
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
          
            IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
              -- Indicar que houve crítica ao processar o pagamento de estouro de conta
              vr_flagerro := TRUE;
            
              -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
              pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                               pr_nrdconta => rw_acordo_contrato.nrdconta,
                               pr_nracordo => pr_nracordo,
                               pr_nrctremp => rw_acordo_contrato.nrctremp,
                               pr_dscritic => vr_dscritic,
                               pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
            
              -- Voltar ao Loop para processar o próximo pagamento
              CONTINUE;
            END IF;
          END IF;
        
          -- AWAE: Se a origem estiver indicando DESCONTO DE TÍTULOS
        ELSIF (rw_acordo_contrato.cdorigem = 4) THEN
          recp0001.pc_pagar_contrato_desc_tit(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                              pr_nrdconta => rw_acordo_contrato.nrdconta,
                                              pr_nrctrdsc => rw_acordo_contrato.nrctremp,
                                              pr_crapdat  => BTCH0001.rw_crapdat,
                                              pr_cdagenci => rw_crapass.cdagenci,
                                              pr_nrdcaixa => 100,
                                              pr_idorigem => pr_idorigem,
                                              pr_cdoperad => pr_cdoperad,
                                              pr_vlparcel => vr_vlParCtr,
                                              pr_idvlrmin => vr_idvlrmin,
                                              pr_vltotpag => vr_vltotpag,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
        
          -- Verifica ocorrencia de erro
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
          
            -- Indicar que houve crítica ao processar o pagamento de estouro de conta
            vr_flagerro := TRUE;
          
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                             pr_nrdconta => rw_acordo_contrato.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'PAGAR_CONTRATO_TITULO');
          
            -- Voltar ao Loop para processar o próximo pagamento
            CONTINUE;
          END IF;
          -----------------------------------------------------------------------------------------------
        
          -- Somar o valor pago ao montante total de pagamentos
          pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
          -----------------------------------------------------------------------------------------------
        
          IF rw_crapass.inprejuz = 1 THEN
            -- Debita da conta transitória o valor utilizado para pagamento do empréstimo
            -- E lança valor em conta corrente
            -- OBS: nesse passo, o valor sai da transitória e vai para C.C.
            --      Há 2 lançamentos
            --      No entanto, isso só é necessário pois não há pagamento de
            --      DESC.TITULO para conta em prejuizo (Sem transitar C.C.)
            PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                            pr_nrdconta => rw_acordo_contrato.nrdconta,
                                            pr_vllanmto => NVL(vr_vltotpag, 0),
                                            pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                            pr_versaldo => 1,
                                            pr_atsldlib => 0,
                                            pr_dsoperac => 'RECP0001 DSC TIT',
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          
            IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
              -- Indicar que houve crítica ao processar o pagamento de estouro de conta
              vr_flagerro := TRUE;
            
              -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
              pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                               pr_nrdconta => rw_acordo_contrato.nrdconta,
                               pr_nracordo => pr_nracordo,
                               pr_nrctremp => rw_acordo_contrato.nrctremp,
                               pr_dscritic => vr_dscritic,
                               pr_dsmodule => 'PAGAR_CONTRATO_CONTA');
            
              -- Voltar ao Loop para processar o próximo pagamento
              CONTINUE;
            END IF;
          END IF;
        ELSIF rw_acordo_contrato.cdorigem = 6 THEN
          recp0001.pc_pagar_contrato_tarifas(pr_cdcooper   => rw_acordo_contrato.cdcooper,
                                             pr_nracordo   => rw_acordo_contrato.nracordo,
                                             pr_nrdconta   => rw_acordo_contrato.nrdconta,
                                             pr_nrcontrato => rw_acordo_contrato.nrctremp,
                                             pr_crapdat    => BTCH0001.rw_crapdat,
                                             pr_cdagenci   => rw_crapass.cdagenci,
                                             pr_nrdcaixa   => 100,
                                             pr_idorigem   => pr_idorigem,
                                             pr_cdoperad   => pr_cdoperad,
                                             pr_vlparcel   => vr_vlParCtr,
                                             pr_vltotpag   => vr_vltotpag,
                                             pr_idvlrpen   => vr_idvlrpen,
                                             pr_cdcritic   => vr_cdcritic,
                                             pr_dscritic   => vr_dscritic);
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
          
            -- Indicar que houve crítica ao processar o pagamento de tarifas
            vr_flagerro := TRUE;
          
            -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
            pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                             pr_nrdconta => rw_acordo_contrato.nrdconta,
                             pr_nracordo => pr_nracordo,
                             pr_nrctremp => rw_acordo_contrato.nrctremp,
                             pr_dscritic => vr_dscritic,
                             pr_dsmodule => 'PAGAR_CONTRATO_ACORDO');
          
            -- Voltar ao Loop para processar o próximo pagamento
            CONTINUE;
          END IF;
          vr_vlpagocontrato := nvl(vr_vlpagocontrato, 0) + nvl(vr_vltotpag, 0);
          IF rw_crapass.inprejuz = 1 THEN
            -- Debita da conta transitória o valor utilizado para pagamento do empréstimo
            -- E lança valor em conta corrente
            -- OBS: nesse passo, o valor sai da transitória e vai para C.C.
            --      Há 2 lançamentos
            --      No entanto, isso só é necessário pois não há pagamento de
            --      DESC.TITULO para conta em prejuizo (Sem transitar C.C.)
            PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => rw_acordo_contrato.cdcooper,
                                            pr_nrdconta => rw_acordo_contrato.nrdconta,
                                            pr_vllanmto => NVL(vr_vltotpag, 0),
                                            pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                            pr_versaldo => 1,
                                            pr_atsldlib => 0,
                                            pr_dsoperac => 'RECP0001 TARIFA',
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          
            IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
              -- Indicar que houve crítica ao processar o pagamento de estouro de conta
              vr_flagerro := TRUE;
            
              -- Em caso de erro será gerado o log e prosseguirá ao próximo pagamento
              pc_gera_log_mail(pr_cdcooper => rw_acordo_contrato.cdcooper,
                               pr_nrdconta => rw_acordo_contrato.nrdconta,
                               pr_nracordo => pr_nracordo,
                               pr_nrctremp => rw_acordo_contrato.nrctremp,
                               pr_dscritic => vr_dscritic,
                               pr_dsmodule => 'PAGAR_CONTRATO_ACORDO');
            
              -- Voltar ao Loop para processar o próximo pagamento
              CONTINUE;
            END IF;
          END IF;
        
          IF vr_idvlrpen = 1 AND vr_vlParCtr - vr_vlpagocontrato > 0 THEN
            vr_flagerro := TRUE;
          END IF;
        
          -----------------------------------------------------------------------------------------------
        
          -- Somar o valor pago ao montante total de pagamentos
          pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vltotpag, 0);
        
        END IF;
      
        vr_vlparcel := vr_vlparcel - NVL(vr_vltotpag, 0);
      
        IF (NVL(vr_vltotpag, 0) > 0) THEN
          vr_qtdCtrEmAberto := vr_qtdCtrEmAberto - 1;
        END IF;
      
        -- Deve sair do loop quando não houver mais saldo disponivel para pagamentos --
        EXIT WHEN vr_vlparcel <= 0;
        -------------------------------------------------------------------------------
      
      END LOOP; -- cr_acordo_contrato
      vr_qtdCtrEmAberto := fn_qtd_contrato_saldo_pagar(pr_nracordo => pr_nracordo,
                                                       pr_vlsddisp => vr_vlsddisp);
      --encera se não tem valor de parcela ou se é parcela de entrada
      EXIT WHEN vr_vlparcel <= 0 /*OR pr_nrparcel = 0 */
      OR vr_qtdCtrEmAberto = 0;
    END LOOP;
    -- Se sobrou valor de pagamento - Deve verificar se deve lançar como despesa ou como valor bloqueado
    IF vr_vlparcel > 0 THEN
    
      -- Se o acordo possui apenas estouro de conta e não possui valores nos historicos 37 e 38
      IF rw_acordo.qtestour > 0 AND rw_acordo.qtempres = 0 AND rw_acordo.vlhistcontanegat = 0 THEN
        -- Não deve lançar despesa, nem saldo bloqueado, pois o valor já está creditado na conta
        vr_flbloque := FALSE;
        vr_fldespes := FALSE;
      ELSE
      
        vr_qtdCtrEmAberto := 0;
        vr_qtdCtrEmAberto := fn_qtd_contrato_saldo_pagar(pr_nracordo => pr_nracordo,
                                                         pr_vlsddisp => vr_vlsddisp);
      
        -- Verificar se houve erro no processamento do estouro de conta e/ou empréstimo
        -- Ou ainda tem contrato com valor em aberto a pagar
        IF vr_flagerro OR vr_qtdCtrEmAberto > 0 THEN
          -- Caracteriza como saldo bloqueado, pois algum valor não pode ser debitado
          vr_flbloque := TRUE;
          vr_fldespes := FALSE;
        ELSE
          -- Caracteriza como despesa, pois todos os valores foram debitados, mas houve sobra
          vr_flbloque := FALSE;
          vr_fldespes := TRUE;
        END IF;
      
      END IF;
    
      -- Se for para lançar a sobra como SALDO BLOQUEADO
      IF vr_flbloque THEN
        IF rw_crapass.inprejuz = 0 THEN
          -- Realiza o lançamento do saldo bloqueado na conta corrente do cooperado
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper,
                                         pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                         pr_cdagenci => rw_crapass.cdagenci,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => pr_cdoperad,
                                         pr_cdpactra => rw_crapass.cdagenci,
                                         pr_nrdolote => 650001,
                                         pr_nrdconta => rw_acordo.nrdconta,
                                         pr_cdhistor => 2193,
                                         pr_vllanmto => vr_vlparcel,
                                         pr_nrparepr => pr_nrparcel,
                                         pr_nrctremp => 0,
                                         pr_des_reto => vr_des_erro,
                                         pr_tab_erro => vr_tab_erro);
        
          -- Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.COUNT() > 0 THEN
              pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
            END IF;
            RAISE vr_exc_erro;
          END IF;
        ELSE
          -- Em Prejuizo
          PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => rw_acordo.cdcooper,
                                        pr_nrdconta => rw_acordo.nrdconta,
                                        pr_vlrlanc  => vr_vlparcel,
                                        pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                        pr_dsoperac => 'RECP0001 VLBLQ',
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
        
          IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          
            RAISE vr_exc_erro;
          END IF;
        
          PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => rw_acordo.cdcooper,
                                            pr_nrdconta => rw_acordo.nrdconta,
                                            pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                            pr_cdhistor => 2970,
                                            pr_vllanmto => vr_vlparcel,
                                            pr_dthrtran => SYSDATE,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
        
          IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          
            RAISE vr_exc_erro;
          END IF;
        END IF;
      
        -- Alterar o valor bloqueado no acordo, com o valor lançado
        BEGIN
          -- Alterar a situação do acordo para cancelado
          UPDATE tbrecup_acordo
             SET vlbloqueado = NVL(vlbloqueado, 0) + NVL(vr_vlparcel, 0)
           WHERE nracordo = pr_nracordo;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar acordo: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vlparcel, 0);
      END IF;
    
      IF vr_fldespes THEN
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_acordo.cdcooper,
                                       pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                       pr_cdagenci => rw_crapass.cdagenci,
                                       pr_cdbccxlt => 100,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_cdpactra => rw_crapass.cdagenci,
                                       pr_nrdolote => 650001,
                                       pr_nrdconta => rw_acordo.nrdconta,
                                       pr_cdhistor => 2182,
                                       pr_vllanmto => vr_vlparcel,
                                       pr_nrparepr => pr_nrparcel,
                                       pr_nrctremp => 0,
                                       pr_des_reto => vr_des_erro,
                                       pr_tab_erro => vr_tab_erro);
        IF vr_des_erro <> 'OK' THEN
          IF vr_tab_erro.COUNT() > 0 THEN
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      
        IF rw_crapass.inprejuz = 1 THEN
          PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => rw_acordo.cdcooper,
                                          pr_nrdconta => rw_acordo.nrdconta,
                                          pr_vllanmto => vr_vlparcel,
                                          pr_dtmvtolt => BTCH0001.rw_crapdat.dtmvtolt,
                                          pr_versaldo => 0,
                                          pr_atsldlib => 0,
                                          pr_dsoperac => 'RECP0001 VLDESP',
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      
        pr_vltotpag := NVL(pr_vltotpag, 0) + NVL(vr_vlparcel, 0);
      END IF;
    END IF;
  
    BEGIN
      UPDATE cecred.tbrecup_acordo_parcela
         SET vlpago = pr_vlparcel
       WHERE nracordo = pr_nracordo
         AND nrparcela = pr_nrparcel;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao atualizar parcela ' || pr_nrparcel || ' do acordo ' || pr_nracordo ||
                       ' : ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_vltotpag := 0;
    WHEN OTHERS THEN
      pr_vltotpag := 0;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_ACORDO: ' || SQLERRM;
  END pc_pagar_contrato_acordo;
  
  
BEGIN
  

  OPEN cr_crapass(pr_nracordo => vr_nracordo);
  FETCH cr_crapass
    INTO rw_crapass;

  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_dscritic := 'Acordo número ' || vr_nracordo || ' não foi encontrado.';
    RAISE vr_exe_erro;
  END IF;
  CLOSE cr_crapass;

  OPEN BTCH0001.cr_crapdat(rw_crapass.cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO BTCH0001.rw_crapdat;

  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE BTCH0001.cr_crapdat;
    vr_dscritic := 'Erro ao buscar datas da cooperativa(' || rw_crapass.cdcooper || ').';
    RAISE vr_exe_erro;
  END IF;
  CLOSE BTCH0001.cr_crapdat;

  EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapass.cdcooper,
                              pr_rw_crapdat => BTCH0001.rw_crapdat,
                              pr_cdagenci   => rw_crapass.cdagenci,
                              pr_nrdcaixa   => 100,
                              pr_cdoperad   => vr_cdoperad,
                              pr_nrdconta   => rw_crapass.nrdconta,
                              pr_vllimcre   => rw_crapass.vllimcre,
                              pr_dtrefere   => BTCH0001.rw_crapdat.dtmvtolt,
                              pr_des_reto   => vr_des_erro,
                              pr_tab_sald   => vr_tab_saldos,
                              pr_tipo_busca => 'A',
                              pr_tab_erro   => vr_tab_erro);
  IF vr_des_erro <> 'OK' THEN
    vr_dscritic := 'Erro ao obter saldo: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
    RAISE vr_exe_erro;
  END IF;

  IF vr_tab_saldos.count() > 0 THEN
    vr_vlparcel := nvl(vr_tab_saldos(vr_tab_saldos.first).vlsddisp, 0);
  END IF;

  IF vr_vlparcel > 0 THEN
    vr_vlparcel := least(vr_vlparcel, 390);
    pc_pagar_contrato_acordo(pr_nracordo => vr_nracordo,
                             pr_nrparcel => vr_nrparcel,
                             pr_vlparcel => vr_vlparcel,
                             pr_cdoperad => vr_cdoperad,
                             pr_idorigem => vr_idorigem,
                             pr_nmtelant => vr_nmtelant,
                             pr_vltotpag => vr_vltotpag,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exe_erro;
    END IF;
    COMMIT;
  ELSE
    vr_dscritic := 'Saldo insuficiente: ' || vr_vlparcel;
    RAISE vr_exe_erro;
  END IF;
  
EXCEPTION
  WHEN vr_exe_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || ' - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
