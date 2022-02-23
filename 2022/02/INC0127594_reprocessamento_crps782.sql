BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT c.cdcooper 
      FROM CRAPCOP c
      WHERE
           c.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    CURSOR cr_consig_movimento (pr_dtmovimento tbepr_consig_parcelas_tmp.dtmovimento%TYPE, 
                                pr_cdcooper crappep.cdcooper%TYPE) IS
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
                 AND aux.intplancamento = 7) vldesconto,
             (SELECT NVL(SUM(nvl(aux.vlsaldo,0)),0)
                FROM tbepr_consig_movimento_tmp aux
               WHERE tcm.cdcooper    = aux.cdcooper
                 AND tcm.nrdconta    = aux.nrdconta
                 AND tcm.nrctremp    = aux.nrctremp
                 AND tcm.dtmovimento = aux.dtmovimento
                 AND tcm.nrparcela   = aux.nrparcela
                 AND aux.intplancamento = 16) vlestdesconto,
             epr.inprejuz,
             tcm.dsmotivo,
             tcm.idintegracao,
             epr.inliquid
        FROM tbepr_consig_movimento_tmp tcm,
             crapepr epr,
             tbcadast_empresa_consig tec
       WHERE tcm.cdcooper    = epr.cdcooper
         AND tcm.nrdconta    = epr.nrdconta
         AND tcm.nrctremp    = epr.nrctremp 
         AND epr.cdcooper    = tec.cdcooper(+)
         AND epr.cdempres    = tec.cdempres(+)
         and tcm.dtmovimento = pr_dtmovimento
         AND tcm.cdcooper    = pr_cdcooper
         AND tcm.intplancamento not in (1,8)
         AND exists (SELECT 1
                       FROM tbepr_consig_contrato_tmp tcc
                      WHERE tcc.cdcooper    = pr_cdcooper
                        AND (tcc.dtmovimento = pr_dtmovimento OR tcc.instatuscontr = 2)
                        AND tcc.nrdconta = tcm.nrdconta
                        AND tcc.nrctremp = tcm.nrctremp
                        AND tcc.vlsdev_empratu_d0 <= 199999.99
                        AND tcc.vlsdev_empratu_d1 <= 199999.99
                        )
         AND NVL(tcm.instatusproces,'W') <> 'P'
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
             tcm.dsmotivo,
             tcm.idintegracao,
             epr.inliquid
   ORDER BY  tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela;

    -- verifica se existe parcela vencendo no dia
    CURSOR cr_vecto_parc (pr_cdcooper IN crappep.cdcooper%TYPE,
                          pr_nrdconta IN crappep.nrdconta%TYPE,
                          pr_nrctremp IN crappep.nrctremp%TYPE,
                          pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                          pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
    SELECT 'S' vr_existe
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.dtvencto >  pr_dtmvtoan
       AND pep.dtvencto <= pr_dtmvtolt
       AND pep.inliquid = 0;

    rw_vecto_parc  cr_vecto_parc%ROWTYPE;

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

    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;


    CURSOR cr_consignado_pagto (pr_cdcooper IN tbepr_consignado_pagamento.cdcooper%TYPE,
                                pr_nrdconta IN tbepr_consignado_pagamento.nrdconta%TYPE,
                                pr_nrctremp IN tbepr_consignado_pagamento.nrctremp%TYPE,
                                pr_nrparepr IN tbepr_consignado_pagamento.nrparepr%TYPE,
                                pr_dtmvtolt IN tbepr_consignado_pagamento.dtmvtolt%TYPE,
                                pr_dsmotivo IN VARCHAR2,
                                pr_idintegracao IN tbepr_consignado_pagamento.Idintegracao%TYPE) IS
    
       
    SELECT 1 vr_existe
      FROM tbepr_consignado_pagamento tcp
     WHERE tcp.cdcooper = pr_cdcooper
       AND tcp.nrdconta = pr_nrdconta
       AND tcp.nrctremp = pr_nrctremp
       AND tcp.nrparepr = pr_nrparepr
       AND ((nvl(pr_dsmotivo,'M') = 'REENVIARPAGTO'
             AND tcp.idsequencia =(SELECT max(consig_pgto.idsequencia)                
                                     FROM tbepr_consignado_pagamento consig_pgto
                                    WHERE consig_pgto.cdcooper     = tcp.cdcooper
                                      AND consig_pgto.nrdconta     = tcp.nrdconta
                                      AND consig_pgto.nrctremp     = tcp.nrctremp
                                      AND consig_pgto.idseqpagamento is null
                                      AND consig_pgto.idintegracao = pr_idintegracao
                                      AND consig_pgto.Instatus     = 2  --PROCESSADO
                                      )
             ) 
            OR (nvl(pr_dsmotivo,'M') <> 'REENVIARPAGTO' 
                AND tcp.dtmvtolt = pr_dtmvtolt));  

     rw_consignado_pagto cr_consignado_pagto%ROWTYPE;


    -- busca os juros remuneratarios
    CURSOR cr_juros_rem (pr_cdcooper IN tbepr_consig_movimento_tmp.cdcooper%TYPE,
                         pr_nrdconta IN tbepr_consig_movimento_tmp.nrdconta%TYPE,
                         pr_nrctremp IN tbepr_consig_movimento_tmp.nrctremp%TYPE,
                         pr_nrparepr IN tbepr_consig_movimento_tmp.nrparcela%TYPE,
                         pr_dtmovimento in tbepr_consig_movimento_tmp.dtmovimento%TYPE) IS
     SELECT NVL(SUM(nvl(tcm.vlsaldo,0)),0) vljurosrem
       FROM tbepr_consig_movimento_tmp tcm
      WHERE tcm.cdcooper    = pr_cdcooper
        AND tcm.nrdconta    = pr_nrdconta
        AND tcm.nrctremp    = pr_nrctremp
        AND tcm.nrparcela   = pr_nrparepr
        AND tcm.dtmovimento<= pr_dtmovimento
        AND NVL(tcm.instatusproces,'W') <> 'P'
        AND tcm.intplancamento = 10; -- Lancamentos de Juros remunerat?rios

    --Selecionar Cotas
    CURSOR cr_crapcot (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
     SELECT crapcot.ROWID
       FROM crapcot
      WHERE crapcot.cdcooper = pr_cdcooper
        AND crapcot.nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;

    --Selecionar Moedas
    CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                      ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
     SELECT mfx.cdcooper,
            mfx.vlmoefix
       FROM crapmfx mfx
      WHERE mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtmvtolt
        AND mfx.tpmoefix = pr_tpmoefix;
     rw_crapmfx cr_crapmfx%ROWTYPE;
 

    CURSOR cr_maior_dtmvtolt_craplem(pr_cdcooper craplem.cdcooper%TYPE
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE
                     ) IS
      select max(dtmvtolt) dtmvtolt
        from craplem crapx
       where crapx.cdcooper = pr_cdcooper
         and crapx.nrdconta = pr_nrdconta
         and crapx.nrctremp = pr_nrctremp
         and crapx.cdhistor in (1038,1037);


    CURSOR cr_contrato_liquidado(pr_cdcooper crappep.cdcooper%TYPE
                     ,pr_nrdconta crappep.nrdconta%TYPE
                     ,pr_nrctremp crappep.nrctremp%TYPE ) IS

      select nvl(max(0),1) inliquid
        from crappep cpp
       where cpp.inliquid = 0 -- Se inliquid for zero, a parcela n?o est? liquidada, e havendo alguma parcela n?o liquidada o contrato n?o deve ser liquidado.
         and cpp.cdcooper = pr_cdcooper
         and cpp.nrdconta = pr_nrdconta
         and cpp.nrctremp = pr_nrctremp;

    --Constantes
    vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE:= 'CRPS782';

    --Variaveis para retorno de erro
    vr_cdcritic        INTEGER:= 0;
    vr_dscritic        VARCHAR2(4000);

    --Variaveis de Excecao
    vr_exc_saida       EXCEPTION;

    -- Tipo utilizado para armazenar os dados da tabela do ODI
    TYPE typ_tbepr_consig_parcelas_tmp IS TABLE OF tbepr_consig_parcelas_tmp%ROWTYPE INDEX BY VARCHAR2(40);
    vr_tab_parcelas      typ_tbepr_consig_parcelas_tmp;

    TYPE typ_tab_pagto IS TABLE OF NUMBER INDEX BY VARCHAR2(40);
    vr_tab_pagto        typ_tab_pagto;

    TYPE typ_tab_pagto_ctr IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
    vr_tab_pagto_ctr        typ_tab_pagto_ctr;

     -- Defini??o de tipo para armazenar os dados da data do movimento da FIS
    TYPE typ_reg_inorigem IS RECORD(inorigem NUMBER);
    TYPE typ_tab_inorigem IS
      TABLE OF typ_reg_inorigem
       INDEX BY VARCHAR2(40);
    vr_tab_inorigem       typ_tab_inorigem;
    vr_index_inorigem     VARCHAR2(40);

    pr_cdcritic           crapcri.cdcritic%TYPE;
    pr_dscritic           varchar2(250);
    vr_dtmvtctr           tbepr_consig_contrato_tmp.dtmovimento%TYPE;
    vr_floperac           Boolean;
    vr_cdhistor           craplem.cdhistor%TYPE;
    vr_cdhistor_es        craplem.cdhistor%TYPE;
    vr_cdhistorrem        craplem.cdhistor%TYPE;
    vr_nrdolote           craplem.nrdolote%TYPE;
    vr_cdoperad           crapope.cdoperad%TYPE:= '1';
    vr_cdorigem           craplem.cdorigem%TYPE;
    vr_jurosrem           craplem.vllanmto%TYPE;
    vr_dtmvtolt           crapdat.dtmvtolt%TYPE;
    vr_dtmvtoan           crapdat.dtmvtoan%TYPE;
    vr_dtmvtopr           crapdat.dtmvtopr%TYPE;
    vr_inproces           crapdat.inproces%TYPE;
    vr_vlmovimento        craplem.vllanmto%TYPE;
    vr_contrato_liquidado number(1);
    vr_maior_dtmvtolt     craplem.dtmvtolt%type;

    -- Funcao para buscar o hsit?rico do estorno
    FUNCTION fn_busca_hist_estorno (pr_cdcooper IN craphis.cdcooper%TYPE,
                                    pr_cdhistor IN craphis.cdhistor%TYPE) RETURN NUMBER IS
      CURSOR cr_craphis IS
       SELECT cdhisest
         FROM craphis
        WHERE craphis.cdcooper = pr_cdcooper
          AND craphis.cdhistor = pr_cdhistor;

      vr_cdhisest craphis.cdhisest%TYPE;
    BEGIN
      vr_cdhisest:= null;
      FOR rw_craphis IN cr_craphis
      LOOP
        vr_cdhisest:= rw_craphis.cdhisest;
      END LOOP;
      RETURN (vr_cdhisest);
    END;

  BEGIN    
    --Limpar parametros saida
    vr_inproces:= 3;
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    vr_tab_inorigem.DELETE;
    vr_tab_parcelas.DELETE;
    vr_tab_pagto_ctr.DELETE;
    vr_tab_pagto.DELETE;
    
    vr_dtmvtoan:= to_date('21/02/2022', 'DD/MM/YYYY');
    vr_dtmvtolt:= to_date('22/02/2022', 'DD/MM/YYYY');--rw_crapdat.dtmvtolt;
    vr_dtmvtopr:= to_date('23/02/2022', 'DD/MM/YYYY');--rw_crapdat.dtmvtolt;
    vr_dtmvtctr:= vr_dtmvtolt;

    -------------------------------------------------------------------------
    -- Inicio Atualizacao do Extrato de emprestimo do consignado - CRAPLEM
    ------------------------------------------------------------------------
        -- leitura dos movimentos da tabela do ODI  Se for na noturna
    IF vr_inproces > 1 THEN
       FOR rw_crapcop IN cr_crapcop 
       LOOP
           
         --Limpar parametros saida
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;
          vr_tab_inorigem.DELETE;

          FOR rw_consig_movimento IN cr_consig_movimento (pr_dtmovimento => vr_dtmvtctr, pr_cdcooper => rw_crapcop.cdcooper)
          LOOP
            -- seleciona a linha de credito
            OPEN cr_craplcrepr(pr_cdcooper => rw_consig_movimento.cdcooper,
                               pr_nrdconta => rw_consig_movimento.nrdconta,
                               pr_nrctremp => rw_consig_movimento.nrctremp);
            FETCH cr_craplcrepr
            INTO rw_craplcrepr;
            -- Se nao encontrar
            IF cr_craplcrepr%NOTFOUND THEN
               -- Fechar o cursor
               CLOSE cr_craplcrepr;
               -- Gerar erro
               vr_cdcritic := 1178;-- linha de credito n?o encontrada
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                rw_consig_movimento.nrctremp||'/'||
                                                rw_consig_movimento.nrparcela||'/'||
                                                rw_consig_movimento.intplancamento||')';
                                                
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic );
              RAISE vr_exc_saida;
            ELSE
               -- Fechar o cursor
               CLOSE cr_craplcrepr;
            END IF;
            vr_floperac := rw_craplcrepr.dsoperac = 'FINANCIAMENTO';

            -- seleciona agencia do cooperado
            OPEN cr_crapass(pr_cdcooper => rw_consig_movimento.cdcooper,
                            pr_nrdconta => rw_consig_movimento.nrdconta);
            FETCH cr_crapass
            INTO rw_crapass;
            -- Se n?o encontrar
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
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic );

               RAISE vr_exc_saida;
            ELSE
               -- Fechar o cursor
               CLOSE cr_crapass;
            END IF;

            --Selecionar Valor Moeda
            OPEN cr_crapmfx (pr_cdcooper => rw_consig_movimento.cdcooper
                            ,pr_dtmvtolt => vr_dtmvtolt
                            ,pr_tpmoefix => 2);
            FETCH cr_crapmfx INTO rw_crapmfx;
            --Se nao encontrou
            IF cr_crapmfx%NOTFOUND THEN
               CLOSE cr_crapmfx;
               -- Montar mensagem de critica
               vr_cdcritic:= 140;
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               --Complementar mensagem
               vr_dscritic:= vr_dscritic ||' da UFIR.';

               vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                rw_consig_movimento.nrctremp||'/'||
                                                rw_consig_movimento.nrparcela||'/'||
                                                rw_consig_movimento.intplancamento||')';
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic );
               RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crapmfx;

            rw_vecto_parc.vr_existe:= 'N';
            -- Verifica se a parrcela esta vencendo
            OPEN cr_vecto_parc (pr_cdcooper => rw_consig_movimento.cdcooper,
                                pr_nrdconta => rw_consig_movimento.nrdconta,
                                pr_nrctremp => rw_consig_movimento.nrctremp,
                                pr_dtmvtolt => vr_dtmvtolt,
                                pr_dtmvtoan => vr_dtmvtoan);

            FETCH cr_vecto_parc INTO rw_vecto_parc;
            CLOSE cr_vecto_parc;


            -- os lan?amentos 1,8 e 9 j? s?o criados na efetiva??o da proposta (b1wgen0084.grava_efetivacao_proposta)
            -- 1 - Valor liberado para o cliente (Debito)
            -- 8 - Valor de IOF cobrado (Credito)
            -- 9 - Valor de TAC cobrada (Credito)
            -- O lan?amento do Juros remunerat?rios (10), ? somado e lan?ado somente no pagamento, no vencimento ou na mensal
            -- 16 - O lan?amento de estorno de desconto n?o ? lan?ado no extrato de emprestimo
            -- Os lan?amento 17 e 18 n?o ? lan?ado no extrato (craplem), pois n?o financia IOF/TAXA
            -- 17 - Valor de IOF cobrado - d?bito em conta corrente (bancado) (D?bito)
            -- 18 - Valor de TAC cobrada - d?bito em conta corrente (bancado) (D?bito

            vr_nrdolote:= 600013;
            vr_cdhistor:= null;
            vr_vlmovimento:= rw_consig_movimento.vlsaldo;
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

            ELSIF rw_consig_movimento.intplancamento = 7 THEN -- 7 - Valor de Desconto (Credito)
                vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1049 ELSE 1048 END;

            ELSIF rw_consig_movimento.intplancamento IN (11,12) THEN -- 11 - Estorno Pagamento - Valor Principal amortizada (Credito)
                                                                     -- 12 - Estorno Pagamento - Valor Juros amortizado (Credito)
                   
                   IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN -- P437.3 - Estorno por avalista de pagamento
                     vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1057 ELSE 1045 END;
                   ELSE
                     vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
                   END IF;
                   
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                        pr_cdhistor => vr_cdhistor_es);
                  
                vr_vlmovimento:= rw_consig_movimento.vlsaldo - NVL(rw_consig_movimento.vlestdesconto,0); -- estorno do desconto

            ELSIF rw_consig_movimento.intplancamento = 13 THEN -- 13 - Estorno Pagamento - Juros de Mora (Credito)
                  
                 IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN -- P437.3 - Estorno por avalista de juros
                   vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1620 ELSE 1619 END;
                 ELSE
                    vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END;
                 END IF;
                  
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                       pr_cdhistor => vr_cdhistor_es);

            ELSIF rw_consig_movimento.intplancamento = 14 THEN -- 14 - Estorno Pagamento - Multa (Credito)
                  
                 IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN -- P437.3 - estorno por avalista multa
                   vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1618 ELSE 1540 END;
                 ELSE
                    vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END;
                 END IF;
                  
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                       pr_cdhistor => vr_cdhistor_es);

            ELSIF rw_consig_movimento.intplancamento = 15 THEN -- 15 - Estorno Pagamento - IOF Atraso (Credito)
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                     pr_cdhistor =>  CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END);

            ELSIF rw_consig_movimento.intplancamento IN (1,8,9,10,16,17,18) THEN
              -- os lan?amentos 1,8 e 9 j? s?o criados na efetiva??o da proposta (b1wgen0084.grava_efetivacao_proposta)
              -- o lan?amento 10, ? somado e lan?ado somente no pagamento, no vencimento ou na mensal
              -- O lan?amento 17 e 18, n?o ? feito no extrato ( craplem), s?o lan?amentos refrente a ao N?o financia IOF
              -- O lan?amento 16 - estorno de desconto n?o ? lan?ado
              vr_cdhistor:= NULL;
            END IF;

            -- Lancamento do juros remuneratorios
            -- ocorre no pagameto, no vencimento e na mensal
            IF (rw_consig_movimento.intplancamento = 2 OR -- Valor de Pagamento - Valor Principal amortizada
                rw_vecto_parc.vr_existe = 'S' OR -- no vencimento da parcela
                trunc(vr_dtmvtolt,'mm') <> trunc(vr_dtmvtopr,'mm')) THEN -- mensal
                vr_cdhistorrem := CASE vr_floperac WHEN TRUE THEN 1038 ELSE 1037 END;
                vr_jurosrem:= 0;
                -- Busca os juros lan?ados
                FOR rw_juros_rem IN cr_juros_rem (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp,
                                                  pr_nrparepr => 0,
                                                  pr_dtmovimento => vr_dtmvtolt)
                LOOP
                  vr_jurosrem:= rw_juros_rem.vljurosrem;
                END LOOP;

                IF vr_jurosrem > 0 THEN
                  --Cria lancamento craplem e atualiza o seu lote */
                  empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper --Codigo Cooperativa
                                                  ,pr_dtmvtolt => vr_dtmvtolt --Data Emprestimo
                                                  ,pr_cdagenci => rw_crapass.cdagenci --Codigo Agencia
                                                  ,pr_cdbccxlt => 100 --Codigo Caixa
                                                  ,pr_cdoperad => vr_cdoperad --Operador
                                                  ,pr_cdpactra => rw_crapass.cdagenci --Posto Atendimento - - agencia do coperado crapass
                                                  ,pr_tplotmov => 5 --Tipo movimento
                                                  ,pr_nrdolote => vr_nrdolote --Numero Lote
                                                  ,pr_nrdconta => rw_consig_movimento.nrdconta --Numero da Conta
                                                  ,pr_cdhistor => vr_cdhistorrem --Codigo Historico do juros remuneratorio
                                                  ,pr_nrctremp => rw_consig_movimento.nrctremp --Numero Contrato
                                                  ,pr_vllanmto => vr_jurosrem -- Valor do lan?amento
                                                  ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                                  ,pr_txjurepr => rw_consig_movimento.txjuremp --Taxa Juros Emprestimo
                                                  ,pr_vlpreemp => rw_consig_movimento.vlpreemp --Valor Emprestimo
                                                  ,pr_nrsequni => 0 --Numero Sequencia
                                                  ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                                  ,pr_flgincre => TRUE --Indicador Credito
                                                  ,pr_flgcredi => TRUE --Credito
                                                  ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                                  ,pr_cdorigem => 7 -- Batch
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
                       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
                       RAISE vr_exc_saida;
                    END IF;

                    -- Atualiza a data do lan?amento do juros na crapepr
                    BEGIN
                      vr_contrato_liquidado := rw_consig_movimento.inliquid;
                      FOR rw_contrato_liquidado IN cr_contrato_liquidado (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp)
                      LOOP
                        vr_contrato_liquidado := rw_contrato_liquidado.inliquid;
                      END LOOP;
                      
                      vr_maior_dtmvtolt := rw_consig_movimento.dtrefjur;
                      FOR rw_maior_dtmvtolt_craplem IN cr_maior_dtmvtolt_craplem (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp)
                      LOOP
                        vr_maior_dtmvtolt := rw_maior_dtmvtolt_craplem.dtmvtolt;
                      END LOOP;
                      
                      UPDATE crapepr epr
                         SET epr.dtrefjur = vr_maior_dtmvtolt,
                             epr.inliquid = vr_contrato_liquidado                         
                       WHERE epr.cdcooper = rw_consig_movimento.cdcooper
                         AND epr.nrdconta = rw_consig_movimento.nrdconta
                         AND epr.nrctremp = rw_consig_movimento.nrctremp;

                    EXCEPTION
                      WHEN OTHERS THEN
                        cecred.pc_internal_exception;
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Erro ao atualizar tabela CRAPEPR - '||SQLERRM;
                        vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                         rw_consig_movimento.nrctremp||'/'||
                                                         rw_consig_movimento.nrparcela||'/'||
                                                         rw_consig_movimento.intplancamento||')';
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' --> '
                                                                     || vr_dscritic );
                        RAISE vr_exc_saida;
                    END;

                    -- Atualiza a tabela do ODI para processado (P)
                   BEGIN
                      UPDATE tbepr_consig_movimento_tmp a
                         SET a.instatusproces = 'P'
                       WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                         AND a.nrdconta  = rw_consig_movimento.nrdconta
                         AND a.nrctremp  = rw_consig_movimento.nrctremp
                         AND a.dtmovimento <= vr_dtmvtolt
                         AND a.nrparcela = 0
                         AND a.intplancamento = 10 -- Juros remuneratorio
                         AND a.instatusproces is null;
                   EXCEPTION
                     WHEN OTHERS THEN
                       cecred.pc_internal_exception;
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                        vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                         rw_consig_movimento.nrctremp||'/'||
                                                         rw_consig_movimento.nrparcela||'/'||
                                                         rw_consig_movimento.intplancamento||')';
                        -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
                        RAISE vr_exc_saida;
                   END;

                    --  Atualiza valor dos juros pagos em moeda fixa no crapcot
                    OPEN cr_crapcot (pr_cdcooper => rw_consig_movimento.cdcooper
                                    ,pr_nrdconta => rw_consig_movimento.nrdconta);
                     --Proximo Registro
                     FETCH cr_crapcot INTO rw_crapcot;
                     --Se nao encontrou
                     IF cr_crapcot%NOTFOUND THEN
                       --Fechar Cursor
                       CLOSE cr_crapcot;
                       vr_cdcritic:= 169;
                       vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                       --Complementar Mensagem
                       vr_dscritic:= vr_dscritic||' - CONTA = '||gene0002.fn_mask(rw_consig_movimento.nrdconta,'zzzz.zz9.9')||
                                                  ' ('||rw_consig_movimento.nrdconta||'/'||
                                                        rw_consig_movimento.nrctremp||'/'||
                                                        rw_consig_movimento.nrparcela||'/'||
                                                        rw_consig_movimento.intplancamento||')';
                       -- Envio centralizado de log de erro
                       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' --> '
                                                                     || vr_dscritic );

                       RAISE vr_exc_saida;
                     ELSE
                       --Fechar Cursor
                       CLOSE cr_crapcot;
                       --Atualizar tabela cotas
                       BEGIN
                         UPDATE crapcot cot
                            SET cot.qtjurmfx = nvl(cot.qtjurmfx,0) +
                                               ROUND(vr_jurosrem / rw_crapmfx.vlmoefix,4)
                          WHERE cot.rowid = rw_crapcot.rowid;
                       EXCEPTION
                         WHEN OTHERS THEN
                           cecred.pc_internal_exception;
                           vr_cdcritic:= 0;
                           vr_dscritic:= 'Erro ao atualizar tabela crapcot. '||SQLERRM;

                           vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                            rw_consig_movimento.nrctremp||'/'||
                                                            rw_consig_movimento.nrparcela||'/'||
                                                            rw_consig_movimento.intplancamento||')';
                           -- Envio centralizado de log de erro
                           btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_dscritic );
                           RAISE vr_exc_saida;
                       END;
                     END IF;
                   END IF;      
              END IF;

              -- P437.3 - Quando o contrato foi transferido para preju?zo, n?o atualiza mais nada. 
              IF rw_consig_movimento.inprejuz = 1 AND vr_cdhistor IS NOT NULL THEN
                 vr_cdhistor := NULL;
                 -- Atualiza a tabela do ODI para processado (P)
                 BEGIN
                    UPDATE tbepr_consig_movimento_tmp a
                       SET a.instatusproces = 'P'
                     WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                       AND a.nrdconta  = rw_consig_movimento.nrdconta
                       AND a.nrctremp  = rw_consig_movimento.nrctremp
                       AND a.nrparcela = rw_consig_movimento.nrparcela
                       AND decode(a.intplancamento,3,2,
                                   decode(a.intplancamento,12,11,a.intplancamento))  = rw_consig_movimento.intplancamento
                       AND a.dtmovimento = rw_consig_movimento.dtmovimento;
                 EXCEPTION
                 WHEN OTHERS THEN
                   cecred.pc_internal_exception;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                    vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                     rw_consig_movimento.nrctremp||'/'||
                                                     rw_consig_movimento.nrparcela||'/'||
                                                     rw_consig_movimento.intplancamento||')';
                    -- Envio centralizado de log de erro
                    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' --> '
                                                                  || vr_dscritic );
                    RAISE vr_exc_saida;
                 END;
            END IF;

            IF vr_cdhistor IS NOT NULL THEN
               vr_index_inorigem:= lpad(rw_consig_movimento.cdcooper, 10, '0') ||
                                   lpad(rw_consig_movimento.nrdconta, 10, '0') ||
                                   lpad(rw_consig_movimento.nrctremp, 10, '0') ||
                                   lpad(rw_consig_movimento.nrparcela,10, '0');

               -- Verifica se o lan?amento existe no Aimaro
               -- 20 - Consignado (efetuado na FIS), 5 - Aimaro WEB
               IF rw_consig_movimento.intplancamento IN(2,3,11,12) THEN -- 2,3 -Pagamento, 11,12 - Estorno Pagamento
                  OPEN cr_consignado_pagto(pr_cdcooper => rw_consig_movimento.cdcooper,
                                           pr_nrdconta => rw_consig_movimento.nrdconta,
                                           pr_nrctremp => rw_consig_movimento.nrctremp,
                                           pr_nrparepr => rw_consig_movimento.nrparcela,
                                           pr_dtmvtolt => rw_consig_movimento.dtmovimento,
                                           pr_dsmotivo => rw_consig_movimento.dsmotivo,
                                           pr_idintegracao => rw_consig_movimento.idintegracao
                                           );

                  FETCH cr_consignado_pagto
                   INTO rw_consignado_pagto;
                  -- Se n?o encontrar
                  IF cr_consignado_pagto%NOTFOUND THEN
                     vr_cdorigem:= 20; -- consignado
                     CLOSE cr_consignado_pagto;
                     IF rw_consig_movimento.intplancamento IN(2,3) THEN
                        IF rw_consig_movimento.indautrepassecc = 1 THEN -- autoriza debito em C/C
                            vr_cdhistor:=  3026; -- quando a empresa autoriza debitar em conta
                         ELSE
                            vr_cdhistor:=  3027; --quando paga a folha via TED
                         END IF;
                     END IF;
                  ELSE
                     vr_cdorigem:= 5; --Aimaro web
                     CLOSE cr_consignado_pagto;
                  END IF;
               ELSE
                   vr_cdorigem:= 5; --Aimaro web
               END IF;
               -- Armazenar na tabela de mem?ria a origem do movimento
               vr_tab_inorigem(vr_index_inorigem).inorigem := vr_cdorigem;

               --Cria lancamento craplem e atualiza o seu lote */
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
                                              ,pr_vllanmto => vr_vlmovimento -- Valor do lancamento
                                              ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                              ,pr_txjurepr => rw_consig_movimento.txjuremp --Taxa Juros Emprestimo
                                              ,pr_vlpreemp => rw_consig_movimento.vlpreemp --Valor Emprestimo
                                              ,pr_nrsequni => rw_consig_movimento.nrparcela --Numero Sequencia
                                              ,pr_nrparepr => rw_consig_movimento.nrparcela --Numero Parcelas Emprestimo
                                              ,pr_flgincre => TRUE --Indicador Credito
                                              ,pr_flgcredi => TRUE --Credito
                                              ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                              ,pr_cdorigem => vr_cdorigem
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
                  btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || vr_dscritic );
                  RAISE vr_exc_saida;
               END IF;

               -- Atualiza a tabela do ODI para processado (P)
               BEGIN
                  UPDATE tbepr_consig_movimento_tmp a
                     SET a.instatusproces = 'P'
                   WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                     AND a.nrdconta  = rw_consig_movimento.nrdconta
                     AND a.nrctremp  = rw_consig_movimento.nrctremp
                     AND a.nrparcela = rw_consig_movimento.nrparcela
                     AND decode(a.intplancamento,3,2,
                                 decode(a.intplancamento,12,11,a.intplancamento))  = rw_consig_movimento.intplancamento
                     AND a.dtmovimento = rw_consig_movimento.dtmovimento;
               EXCEPTION
                 WHEN OTHERS THEN
                   cecred.pc_internal_exception;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                    vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                     rw_consig_movimento.nrctremp||'/'||
                                                     rw_consig_movimento.nrparcela||'/'||
                                                     rw_consig_movimento.intplancamento||')';
                    -- Envio centralizado de log de erro
                    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' --> '
                                                                  || vr_dscritic );
                    RAISE vr_exc_saida;
               END;
             END IF;
        END LOOP;-- fim do Loop dos movimentos
       
      END LOOP;
   END IF; 

   commit;
   
   Dbms_Output.put_line('SUCESSO.');
   EXCEPTION
    WHEN vr_exc_saida THEN
      ROLLBACK;
      -- Devolvemos codigo e critica encontradas
      Dbms_Output.put_line(TO_CHAR(NVL(vr_cdcritic,0)) || ' - ' || vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK;
      Dbms_Output.put_line(TO_CHAR(NVL(vr_cdcritic,0)) || ' - ' || vr_dscritic);
      
      cecred.pc_internal_exception(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_compleme => 'pr_cdcooper: ' || rw_crapcop.cdcooper ||
                                                 ' pr_cdagenci: ' || 0 ||
                                                 ' pr_nmdatela: ' || vr_cdprogra ||
                                                 ' pr_idparale: ' || 0);
  END;
END; 
/