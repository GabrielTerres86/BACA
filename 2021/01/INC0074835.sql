DECLARE
  vr_cdcritic        INTEGER:= 0;
  vr_dscritic        VARCHAR2(4000);
  vr_exc_saida       EXCEPTION;
  vr_dtmvtolt         date := to_date('12/01/2021', 'DD/mm/yyyy');
  vr_cdoperad         crapope.cdoperad%TYPE := '1';
  vr_nrdolote         craplem.nrdolote%TYPE := 600013;
  vr_cdhistor         craplem.cdhistor%TYPE;
  vr_vlmovimento      craplem.vllanmto%TYPE;
  vr_floperac         Boolean;
--
  CURSOR cr_consig_movimento IS
      SELECT tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela,
             NVL(tec.indautrepassecc,0) indautrepassecc,
             decode(tcm.intplancamento,3,2,
                    decode(tcm.intplancamento,12,11,tcm.intplancamento)) intplancamento,
             tcm.instatusproces,
             tcm.dserroproces,
             MIN(tcm.dtmovimento) dtmovimento,
             MIN(tcm.dtgravacao)  dtgravacao,
             MAX(epr.txjuremp) txjuremp,
             MIN(epr.vlpreemp) vlpreemp,
             MIN(epr.dtrefjur) dtrefjur,
             SUM(NVL(tcm.vldebito,0)) vldebito,
             SUM(NVL(tcm.vlcredito,0)) vlcredito,
             SUM(NVL(tcm.vlsaldo,0)) vlsaldo,
             (SELECT NVL(SUM(nvl(aux.vlsaldo,0)),0)
                FROM tbepr_consig_movimento_tmp aux
               WHERE tcm.cdcooper    = aux.cdcooper
                 AND tcm.nrdconta    = aux.nrdconta
                 AND tcm.nrctremp    = aux.nrctremp
                 AND tcm.dtmovimento = aux.dtmovimento
                 AND tcm.nrparcela   = aux.nrparcela
                 AND aux.intplancamento = 7) vldesconto,  -- desconto
             (SELECT NVL(SUM(nvl(aux.vlsaldo,0)),0)
                FROM tbepr_consig_movimento_tmp aux
               WHERE tcm.cdcooper    = aux.cdcooper
                 AND tcm.nrdconta    = aux.nrdconta
                 AND tcm.nrctremp    = aux.nrctremp
                 AND tcm.dtmovimento = aux.dtmovimento
                 AND tcm.nrparcela   = aux.nrparcela
                 AND aux.intplancamento = 16) vlestdesconto,  -- Estorno desconto
             epr.inprejuz,
             tcm.dsmotivo
--             ,tcm.idintegracao
        FROM tbepr_consig_movimento_tmp tcm,
             crapepr epr,
             tbcadast_empresa_consig tec
       WHERE tcm.cdcooper    = epr.cdcooper
         AND tcm.nrdconta    = epr.nrdconta
         AND tcm.nrctremp    = epr.nrctremp
         AND epr.cdcooper    = tec.cdcooper(+)
         AND epr.cdempres    = tec.cdempres(+)
         and   (   (    tcm.cdcooper = 5
                    and tcm.nrdconta = 30449
                    and tcm.nrctremp = 15944
                   )
                OR (    tcm.cdcooper = 1
                    and tcm.nrdconta = 6880924
                    and tcm.nrctremp = 2955745
                   )
               )
         and   tcm.dtmovimento = to_date('12/01/2021', 'DD/mm/yyyy')
         AND tcm.intplancamento not in (1,8)
         AND exists (SELECT 1
                       FROM tbepr_consig_contrato_tmp tcc
                      WHERE tcc.cdcooper    = tcm.cdcooper
                        AND (tcc.dtmovimento = tcm.dtmovimento OR tcc.instatuscontr = 2)
                        AND tcc.nrdconta = tcm.nrdconta
                        AND tcc.nrctremp = tcm.nrctremp
                        AND tcc.vlsdev_empratu_d0 <= 199999.99
                        AND tcc.vlsdev_empratu_d1 <= 199999.99
                        ) -- P437       
         AND NVL(tcm.instatusproces,'W') <> 'P' -- processado
    GROUP BY tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela,
             NVL(tec.indautrepassecc,0),
             decode(tcm.intplancamento,3,2,
                    decode(tcm.intplancamento,12,11,tcm.intplancamento)),
             tcm.instatusproces,
             tcm.dserroproces,
             tcm.dtmovimento,
             epr.inprejuz,
             tcm.dsmotivo
--             ,tcm.idintegracao
   ORDER BY  tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela;
--
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;
--
    CURSOR cr_craplcrepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                          pr_nrdconta IN crapepr.nrdconta%TYPE,
                          pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT lcr.dsoperac
        FROM craplcr lcr,
             crapepr epr
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;

    rw_craplcrepr cr_craplcrepr%ROWTYPE;
--
BEGIN
  FOR rw_consig_movimento in cr_consig_movimento LOOP
--
      OPEN cr_crapass(pr_cdcooper => rw_consig_movimento.cdcooper,
                      pr_nrdconta => rw_consig_movimento.nrdconta);
      FETCH cr_crapass
      INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
         -- Fechar o cursor
         CLOSE cr_crapass;
         -- Gerar erro
         vr_cdcritic := 1042;-- 1042 - Associado nao encontrado
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                          rw_consig_movimento.nrctremp||'/'||
                                          rw_consig_movimento.nrparcela||'/'||
                                          rw_consig_movimento.intplancamento||')';
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => rw_consig_movimento.cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || 'BACA MOVIMENTO CONSIGNADO' || ' --> '
                                                      || vr_dscritic );

         RAISE vr_exc_saida;
      ELSE
         -- Fechar o cursor
         CLOSE cr_crapass;
      END IF;
--
      OPEN cr_craplcrepr(pr_cdcooper => rw_consig_movimento.cdcooper,
                         pr_nrdconta => rw_consig_movimento.nrdconta,
                         pr_nrctremp => rw_consig_movimento.nrctremp);
      FETCH cr_craplcrepr
      INTO rw_craplcrepr;
      -- Se não encontrar
      IF cr_craplcrepr%NOTFOUND THEN
         -- Fechar o cursor
         CLOSE cr_craplcrepr;
         -- Gerar erro
         vr_cdcritic := 1178;-- linha de credito não encontrada
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                          rw_consig_movimento.nrctremp||'/'||
                                          rw_consig_movimento.nrparcela||'/'||
                                          rw_consig_movimento.intplancamento||')';
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => rw_consig_movimento.cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || 'BACA MOVIMENTO CONSIGNADO' || ' --> '
                                                      || vr_dscritic );
        RAISE vr_exc_saida;
      ELSE
         -- Fechar o cursor
         CLOSE cr_craplcrepr;
      END IF;
--
      vr_cdhistor    := null;
      vr_vlmovimento := rw_consig_movimento.vlsaldo;
      vr_floperac    := rw_craplcrepr.dsoperac = 'FINANCIAMENTO';
--
      IF rw_consig_movimento.intplancamento IN(2,3) THEN  -- 2 - Valor de Pagamento - Valor Principal amortizada (Credito)
                                                          -- 3 - Valor de Pagamento - Valor Juros amortizado (Credito)
         -- P437.3 - Pagamento por avalista
         IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1057 ELSE 1045 END;
         ELSE
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
         END IF;
         vr_vlmovimento:= rw_consig_movimento.vlsaldo - NVL(rw_consig_movimento.vldesconto,0);
      ELSIF rw_consig_movimento.intplancamento = 4 THEN --4 - Valor de Pagamento de Juros de Mora por atraso (Debito)
         IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN -- P437.3 - Pagamento por avalista
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1620 ELSE 1619 END;
         ELSE
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END;
         END IF;
      ELSIF rw_consig_movimento.intplancamento = 5 THEN -- 5 - Valor de Pagamento de Multa por Atraso (Debito)
         IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN -- P437.3 - Pagamento por avalista multa
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1618 ELSE 1540 END;
         ELSE
           vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END;
         END IF;
      ELSIF rw_consig_movimento.intplancamento = 6 THEN -- 6 - Valor de Pagamento de IOF Atraso (Debito)
         vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END;
      END IF;
--
     empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper --Codigo Cooperativa
                                    ,pr_dtmvtolt => vr_dtmvtolt --Data Emprestimo
                                    ,pr_cdagenci => rw_crapass.cdagenci --Codigo Agencia
                                    ,pr_cdbccxlt => 100 --Codigo Caixa
                                    ,pr_cdoperad => vr_cdoperad --Operador
                                    ,pr_cdpactra => rw_crapass.cdagenci --Posto Atendimento - - agencia do coperado crapass
                                    ,pr_tplotmov => 5 --Tipo movimento
                                    ,pr_nrdolote => vr_nrdolote --Numero Lote
                                    ,pr_nrdconta => rw_consig_movimento.nrdconta --Numero da Conta
                                    ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                    ,pr_nrctremp => rw_consig_movimento.nrctremp --Numero Contrato
                                    ,pr_vllanmto => vr_vlmovimento -- Valor do lançamento
                                    ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                    ,pr_txjurepr => rw_consig_movimento.txjuremp --Taxa Juros Emprestimo
                                    ,pr_vlpreemp => rw_consig_movimento.vlpreemp --Valor Emprestimo
                                    ,pr_nrsequni => rw_consig_movimento.nrparcela --Numero Sequencia
                                    ,pr_nrparepr => rw_consig_movimento.nrparcela --Numero Parcelas Emprestimo
                                    ,pr_flgincre => TRUE --Indicador Credito
                                    ,pr_flgcredi => TRUE --Credito
                                    ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                    ,pr_cdorigem => 5 -- Aimaro
                                    ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                    ,pr_dscritic => vr_dscritic); --Descricao Erro
     --Se ocorreu erro
     IF vr_cdcritic IS NOT NULL OR
        vr_dscritic IS NOT NULL THEN
        vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                         rw_consig_movimento.nrctremp||'/'||
                                         rw_consig_movimento.nrparcela||'/'||
                                         rw_consig_movimento.intplancamento||')';
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_consig_movimento.cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || 'BACA MOVIMENTO CONSIGNADO' || ' --> '
                                                     || vr_dscritic );
        RAISE vr_exc_saida;
     END IF;

     -- Atualiza a tabela do ODI para processado (P)
     UPDATE tbepr_consig_movimento_tmp a
        SET a.instatusproces = 'P'
     WHERE a.cdcooper  = rw_consig_movimento.cdcooper
       AND a.nrdconta  = rw_consig_movimento.nrdconta
       AND a.nrctremp  = rw_consig_movimento.nrctremp
       AND a.nrparcela = rw_consig_movimento.nrparcela
       AND decode(a.intplancamento,3,2,
                   decode(a.intplancamento,12,11,a.intplancamento))  = rw_consig_movimento.intplancamento
       AND a.dtmovimento = rw_consig_movimento.dtmovimento;
--
    commit;
--
  END LOOP;
END;
/
