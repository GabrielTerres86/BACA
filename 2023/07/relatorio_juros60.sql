DECLARE

  rw_crapdat          datascooperativa;
  
  vr_cdcooper         crapcop.cdcooper%TYPE;
  
  vr_dtinicio         DATE;
  vr_vlmora60         craplem.vllanmto%TYPE;
  vr_vlsaldo59        craplem.vllanmto%TYPE;
  vr_flgremun         BOOLEAN;
  vr_vltaxatu         crappep.vltaxatu%TYPE;
  vr_txdiaria         craplcr.txdiaria%TYPE;
  vr_vljurcor         crapepr.vljuratu%TYPE;
  vr_qtdedias         PLS_INTEGER;
  vr_taxa_periodo     NUMBER(25,8);
  vr_dtvencto         crappep.dtvencto%TYPE;
  vr_qtdiaatr         INTEGER;
  vr_dtrefere60       DATE;
  vr_vljuremu         NUMBER(25,2);
  
  vr_vljurant_reneg   NUMBER(25,2);
  vr_vljurmor_reneg   NUMBER(25,2);
  vr_vljuremu_reneg   NUMBER(25,2);
  vr_vljurcor_reneg   NUMBER(25,2);
  
  vlmrapar60_total    NUMBER(25,2);
  vljura60_total      NUMBER(25,2);
  vljurcor_total      NUMBER(25,2);
  vljuremu_total      NUMBER(25,2);
  
  vr_desclob          CLOB;
  vr_cdmodali         VARCHAR2(4000);
  vr_nmarqcsv         VARCHAR2(100);  
  vr_csv_9805         CLOB;
  vr_csv_9805_temp    VARCHAR2(32672);
  vr_nmdireto         VARCHAR2(100); 
  vr_des_erro         VARCHAR2(4000);
  vr_txtcompl         VARCHAR2(32000);
  
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  
  -- Busca os contratos
  CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT /*+ parallel */
           e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
          ,e.dtmvtolt
          ,e.dtdpagto
          ,e.vlsprojt
          ,e.txmensal
          ,e.vlpreemp
          ,e.dtrefjur
          ,e.diarefju
          ,e.mesrefju
          ,e.anorefju            
          ,e.txjuremp
          ,e.vlemprst
          ,e.qtpreemp
          ,e.nrctaav1
          ,e.nrctaav2
          ,e.cdagenci
          ,e.cdbccxlt
          ,e.nrdolote
          ,e.cdfinemp
          ,e.cdlcremp
          ,e.qttolatr
          ,e.dtrefcor
          ,TO_CHAR(e.dtdpagto, 'DD') diapagto
          ,w.cddindex
          ,e.inprejuz
          ,e.dtultpag
          ,w.vlperidx
          ,w.flgreneg
          ,w.dtlibera
      FROM crapepr e,
           crawepr w
     WHERE w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
       AND e.cdcooper = pr_cdcooper 
       AND e.tpemprst = 2 -- Pos-Fixado
       AND e.inliquid = 0
       AND e.inprejuz = 0;
  TYPE typ_tab_crapepr IS TABLE OF cr_crapepr%ROWTYPE INDEX BY PLS_INTEGER;
  -- Vetor para armazenar os dados de Linha de Credito
  vr_tab_crapepr typ_tab_crapepr;
  
  -- Busca as parcelas atrasadas
  CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                   ,pr_nrdconta IN crappep.nrdconta%TYPE
                   ,pr_nrctremp IN crappep.nrctremp%TYPE
                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT p.nrparepr
          ,p.vlparepr
          ,p.dtvencto
          ,p.dtultpag
          ,p.vlsdvpar
          ,p.vlpagmta
          ,p.vlsdvatu
          ,p.vltaxatu
      FROM crappep p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.inliquid = 0;
       
  -- Busca os dados da linha de credito
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
    SELECT cdlcremp
          ,dsoperac
          ,perjurmo
          ,flgcobmu
      FROM craplcr
     WHERE cdcooper = pr_cdcooper
       AND tpprodut = 2;
  TYPE typ_tab_craplcr IS TABLE OF cr_craplcr%ROWTYPE INDEX BY PLS_INTEGER;
  -- Vetor para armazenar os dados de Linha de Credito
  vr_tab_craplcr typ_tab_craplcr;
  
  -- Saldos pendentes das renegociacoes
  CURSOR cr_renegociacao_saldo(pr_cdcooper IN crappep.cdcooper%TYPE) IS
    SELECT /*+ parallel */
           (r.vljurmor - r.vlpgjrmr) vljurmor, -- mora
           (r.vljurcor - r.vlpgjrco) vljurcor, -- correcao
           (r.vlmultap - r.vlpgmult) vlmultap, -- multa
           (r.vltariof - r.vlpgtiof) vltariof, -- iof
           (r.vljura60 - r.vlpgjr60) vljura60, -- jura60
           (r.vljuremu - r.vlpgjrem) vljuremu, -- remuneratorio
           r.cdcooper,
           r.nrdconta,
           r.nrctremp
      FROM tbepr_renegociacao_saldo r
          ,crapepr e
     WHERE e.cdcooper = r.cdcooper
       AND e.nrdconta = r.nrdconta
       AND e.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND e.inliquid = 0
       AND e.inprejuz = 0;
  -- Armazenar Saldos Renegociação Facilitada
  vr_reneg_saldos_bulk GESTAODERISCO.tiposDadosRiscos.typ_tab_reneg_saldos_bulk;
  vr_tab_reneg_saldos  GESTAODERISCO.tiposDadosRiscos.typ_tab_reneg_saldos;
  vr_idx_saldo_reneg   VARCHAR2(25);
  
  -- CURSORES
  CURSOR cr_parcelas(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT /*+ parallel */
           pep.cdcooper
          ,pep.nrdconta
          ,pep.nrctremp
          ,MIN(pep.dtvencto) dtmenven
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND (pep.inliquid = 0 OR pep.inprejuz = 1)
     GROUP BY pep.cdcooper, pep.nrdconta, pep.nrctremp;
  TYPE typ_tab_parcelas IS TABLE OF cr_parcelas%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_parcelas typ_tab_parcelas;
  
  CURSOR cr_crapris(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
    SELECT r.cdcooper, r.nrdconta, r.nrctremp, r.vljura60, r.vlmrapar60, r.vljuremu60, r.vljurcor60
          ,v.vldivida_vri, v.vlempres_vri
      FROM crapris r
          ,crapepr e
          ,(SELECT SUM(vri.vldivida) vldivida_vri, SUM(vri.vlempres) vlempres_vri, vri.cdcooper, vri.nrdconta, vri.nrctremp, vri.dtrefere
              FROM crapvri vri
             WHERE vri.cdcooper = pr_cdcooper
               AND vri.dtrefere = pr_dtrefere
               AND vri.cdmodali IN (299,499)
             GROUP BY vri.cdcooper, vri.nrdconta, vri.nrctremp, vri.dtrefere) v
     WHERE e.cdcooper = r.cdcooper
       AND e.nrdconta = r.nrdconta
       AND e.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = pr_dtrefere
       AND r.cdcooper = v.cdcooper(+)
       AND r.nrdconta = v.nrdconta(+)
       AND r.nrctremp = v.nrctremp(+)
       AND r.dtrefere = v.dtrefere(+)
       AND r.cdmodali IN (299,499)
       AND e.tpemprst = 2
       AND r.vljura60 > 0;
  TYPE typ_tab_ris_bulk IS TABLE OF cr_crapris%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_ris IS TABLE OF cr_crapris%ROWTYPE INDEX BY VARCHAR2(25);
  vr_tab_ris_bulk typ_tab_ris_bulk;
  vr_tab_ris typ_tab_ris;
  vr_idx_ris VARCHAR2(25);
  
  -- Verifica se é reneg facilitada
  CURSOR cr_verifica_reneg(pr_cdcooper crapass.cdcooper%TYPE) IS
    SELECT tr.cdcooper
          ,tr.nrdconta
          ,trc.nrctrepr
          ,trc.nrdiaatr
      FROM tbepr_renegociacao_contrato trc
          ,tbepr_renegociacao          tr
          ,crapass                     ass
     WHERE trc.cdcooper = tr.cdcooper
       AND trc.nrdconta = tr.nrdconta
       AND trc.nrctremp = tr.nrctremp
       AND trc.cdcooper = ass.cdcooper
       AND trc.nrdconta = ass.nrdconta
       AND ass.cdcooper = pr_cdcooper
     ORDER BY tr.dtlibera ASC; -- ordenar na linha do tempo, o for loop substitui o mais antigo pelo novo
  -- Armazenar Contratos de Renegociação Facilitada
  TYPE typ_reg_contrato_reneg IS
    RECORD(cdcooper tbepr_renegociacao.cdcooper%TYPE
          ,nrdconta tbepr_renegociacao.nrdconta%TYPE
          ,nrctrepr tbepr_renegociacao.nrctremp%TYPE
          ,nrdiaatr tbepr_renegociacao_contrato.nrdiaatr%TYPE);
  TYPE typ_tab_contrato_reneg_bulk  IS TABLE OF typ_reg_contrato_reneg INDEX BY PLS_INTEGER;
  TYPE typ_tab_contrato_reneg       IS TABLE OF typ_reg_contrato_reneg INDEX BY VARCHAR2(25); --> chave coop/conta/contrato
  vr_reg_contrato_reneg_bulk           typ_tab_contrato_reneg_bulk;
  vr_reg_contrato_reneg                typ_tab_contrato_reneg;
  -- Armazenar Contratos de Renegociação Facilitada
  
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE calcularMoraPosFixado(pr_cdcooper IN  crappep.cdcooper%TYPE   --> Codigo da Cooperativa
                                 ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE   --> Data de Calculo
                                 ,pr_dtvencto IN  crappep.dtvencto%TYPE   --> Data de Vencimento da Parcela
                                 ,pr_dtultpag IN  crappep.dtultpag%TYPE   --> Data do Ultimo Pagamento
                                 ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE   --> Saldo Devedor da Parcela
                                 ,pr_perjurmo IN  craplcr.perjurmo%TYPE   --> Percentual do Juros de Mora
                                 ,pr_txmensal IN  crapepr.txmensal%TYPE   --> Taxa mensal do Emprestimo
                                 ,pr_vlperidx IN  crawepr.vlperidx%TYPE   --> Percentual indexador
                                 ,pr_vltaxatu IN  crappep.vltaxatu%TYPE   --> Taxa da parcela
                                 ,pr_qttolatr IN  crapepr.qttolatr%TYPE   --> Quantidade de Tolerancia para Cobrar Multa/Juros de Mora
                                 ,pr_vlmrapar OUT NUMBER                  --> Juros de Mora Atualizado
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS

    vr_exc_erro   EXCEPTION;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(4000);
    
    vr_dtjurmora    DATE;
    vr_qtdiamor     PLS_INTEGER;
    vr_txdiaria     NUMBER(25,7);
    vr_vlrdtaxa NUMBER;
  BEGIN
    IF pr_dtultpag IS NULL THEN
      -- Pegar a data de vencimento dela
      vr_dtjurmora := pr_dtvencto;
    ELSE
      -- Pegar a ultima data que pagou a parcela
      vr_dtjurmora := pr_dtultpag;
    END IF;

    EMPR9999.pc_calc_dias_atraso_jur(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => pr_dtcalcul
                                    ,pr_dtvencto => vr_dtjurmora
                                    ,pr_qttolatr => pr_qttolatr
                                    ,pr_qtdiacal => vr_qtdiamor
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                                            
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 

    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Se a quantidade de dias para cobrança de juros de mora for zero
    IF vr_qtdiamor <= 0 THEN
      -- Zerar o percentual de mora
      pr_vlmrapar := 0;
    ELSE
      -- Taxa de mora recebe o valor da linha de crédito
      vr_txdiaria := ROUND((100 * (POWER(((pr_perjurmo + pr_txmensal) / 100) + 1,(1 / 30)) - 1)),7);
      -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
      pr_vlmrapar := round((pr_vlsdvpar * (vr_txdiaria / 100) * vr_qtdiamor),2);
                  
      vr_vlrdtaxa := pr_vltaxatu;
      -- Quantidade de dias em atraso para Mora e IOF
      EMPR9999.pc_calc_dias_atraso_jur(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => pr_dtcalcul
                                      ,pr_dtvencto => vr_dtjurmora
                                      ,pr_qttolatr => pr_qttolatr
                                      ,pr_fdiautil => 1 --> Apenas dias uteis 
                                      ,pr_qtdiacal => vr_qtdiamor
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                                                      
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 

      vr_vlrdtaxa := vr_vlrdtaxa * (pr_vlperidx / 100);
      -- Calculo da taxa no periodo Anterior
      vr_vlrdtaxa := ROUND(POWER((1 + (vr_vlrdtaxa / 100)),(vr_qtdiamor / 252)) - 1,8);
      -- Condicao para verificar se devemos calcular o Juros de Correcao
      IF vr_vlrdtaxa <= 0 THEN
        vr_vlrdtaxa := 0;
      END IF;

      pr_vlmrapar := pr_vlmrapar + round((pr_vlsdvpar * vr_vlrdtaxa),2);

    END IF;
  EXCEPTION 
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := obterCritica(vr_cdcritic);
      END IF;
      pr_dscritic := vr_dscritic;
      
      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => pr_dscritic);
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na calcularMoraPosFixado: ' || SQLERRM;     
      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => pr_dscritic);
            
  END calcularMoraPosFixado;
  
  PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2
                            ,pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
  BEGIN
    vr_des_dados := pr_dsdlinha||chr(13);
    gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, vr_des_dados, pr_fechaarq);    
  END;  
  
  PROCEDURE relatorioJuros60Contrato(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo da Cooperativa
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
        FROM crapcop
       WHERE crapcop.flgativo = 1
         AND cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER;
  BEGIN
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    vr_nmarqcsv := 'RELATORIO_JUROS60_POS_'||upper(rw_crapcop.nmrescop)||'_'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');
   
    vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RELATO_CENTRAL';
   
    vr_desclob := NULL;
    dbms_lob.createtemporary(vr_desclob, TRUE);
    dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
    
    cecred.gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, 'COOPERATIVA;CONTA;CONTRATO;SALDO59;JUROS60;REMUNERATORIO;CORRECAO;MORA60;ATRASO;RIS_VLJURA60;RIS_VLMRAPAR60;RIS_VLJUREMU60;RIS_VLJURCOR60;VRI_VLDIVIDA;VRI_VLEMPRES;RENEG'||chr(13), false);  

    -- Carregar linhas de credito
    FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
      vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
      vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
    END LOOP;
    
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    
    vr_tab_parcelas.DELETE;
    GESTAODERISCO.tiposdadosriscos.tab_cr_parcelas_emp.DELETE;
    --> Carregar temptable dos saldos das renegociações facilitadas
    OPEN cr_parcelas(pr_cdcooper => pr_cdcooper);
    FETCH cr_parcelas BULK COLLECT INTO vr_tab_parcelas;
    CLOSE cr_parcelas;
    IF vr_tab_parcelas.count > 0 THEN
      FOR idx IN vr_tab_parcelas.first .. vr_tab_parcelas.last LOOP
        -- Indice único utilizado para a tabela 
        GESTAODERISCO.tiposDadosRiscos.idx_parcelas_emp := lpad(vr_tab_parcelas(idx).cdcooper,03,'0')
                                                        || lpad(vr_tab_parcelas(idx).nrdconta,10,'0')
                                                        || lpad(vr_tab_parcelas(idx).nrctremp,10,'0');
        IF NOT GESTAODERISCO.tiposdadosriscos.tab_cr_parcelas_emp.exists(GESTAODERISCO.tiposDadosRiscos.idx_parcelas_emp) THEN 
          GESTAODERISCO.tiposdadosriscos.tab_cr_parcelas_emp(GESTAODERISCO.tiposDadosRiscos.idx_parcelas_emp).dtmenven := vr_tab_parcelas(idx).dtmenven;
        END IF;
      END LOOP;
    END IF;
    vr_tab_parcelas.DELETE;
    
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    
    vr_tab_reneg_saldos.DELETE;
    --> Carregar temptable dos saldos das renegociações facilitadas
    OPEN cr_renegociacao_saldo(pr_cdcooper => pr_cdcooper);
    FETCH cr_renegociacao_saldo BULK COLLECT INTO vr_reneg_saldos_bulk;
    CLOSE cr_renegociacao_saldo;

    IF vr_reneg_saldos_bulk.count > 0 THEN
      FOR idx IN vr_reneg_saldos_bulk.first .. vr_reneg_saldos_bulk.last LOOP
        vr_idx_saldo_reneg := lpad(vr_reneg_saldos_bulk(idx).cdcooper, 5, '0') ||
                              lpad(vr_reneg_saldos_bulk(idx).nrdconta, 10, '0') || 
                              lpad(vr_reneg_saldos_bulk(idx).nrctremp, 10, '0');
        vr_tab_reneg_saldos(vr_idx_saldo_reneg) := vr_reneg_saldos_bulk(idx);
      END LOOP;
    END IF;
    
    vr_reg_contrato_reneg.DELETE;
    OPEN cr_verifica_reneg(pr_cdcooper => pr_cdcooper);
    FETCH cr_verifica_reneg BULK COLLECT INTO vr_reg_contrato_reneg_bulk;
    CLOSE cr_verifica_reneg;

    IF vr_reg_contrato_reneg_bulk.count > 0 THEN
      FOR idx IN vr_reg_contrato_reneg_bulk.first..vr_reg_contrato_reneg_bulk.last LOOP
        BEGIN
          vr_idx_saldo_reneg := lpad(vr_reg_contrato_reneg_bulk(idx).cdcooper,5,'0')  ||
                                lpad(vr_reg_contrato_reneg_bulk(idx).nrdconta,10,'0') ||
                                lpad(vr_reg_contrato_reneg_bulk(idx).nrctrepr,10,'0');
          vr_reg_contrato_reneg(vr_idx_saldo_reneg):= vr_reg_contrato_reneg_bulk(idx);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
    END IF;

    vr_reg_contrato_reneg_bulk.DELETE;
    
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    
    OPEN cr_crapris(pr_cdcooper => pr_cdcooper
                   ,pr_dtrefere => rw_crapdat.dtmvcentral);
    FETCH cr_crapris BULK COLLECT INTO vr_tab_ris_bulk;
    CLOSE cr_crapris;

    IF vr_tab_ris_bulk.count > 0 THEN
      FOR idx IN vr_tab_ris_bulk.first .. vr_tab_ris_bulk.last LOOP
        vr_idx_ris := lpad(vr_tab_ris_bulk(idx).cdcooper, 5, '0') ||
                      lpad(vr_tab_ris_bulk(idx).nrdconta, 10, '0') || 
                      lpad(vr_tab_ris_bulk(idx).nrctremp, 10, '0');
        vr_tab_ris(vr_idx_ris) := vr_tab_ris_bulk(idx);
      END LOOP;
    END IF;
    
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    
    vr_tab_crapepr.DELETE;
    --> Carregar temptable dos saldos das renegociações facilitadas
    OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_crapepr BULK COLLECT INTO vr_tab_crapepr;
    CLOSE cr_crapepr;
    
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    -------------------------------------------------------------------------------
    
    IF vr_tab_crapepr.count > 0 THEN
      FOR idx IN vr_tab_crapepr.first .. vr_tab_crapepr.last LOOP
        
        vr_vljurant_reneg  := 0;
        vr_vljurmor_reneg  := 0;
        vr_vljuremu_reneg  := 0;
        vr_vljurcor_reneg  := 0;
        vlmrapar60_total   := 0;
        vljura60_total     := 0;
        vljurcor_total     := 0;
        vljuremu_total     := 0;
        vr_vljuremu        := 0;
        vr_vljurcor        := 0;
        
        -- Buscar a parcela com maior atraso/menor vencimento
        GESTAODERISCO.tiposdadosriscos.idx_parcelas_emp := lpad(vr_tab_crapepr(idx).cdcooper,03,'0')
                                                        || lpad(vr_tab_crapepr(idx).nrdconta,10,'0')
                                                        || lpad(vr_tab_crapepr(idx).nrctremp,10,'0');
          
        IF GESTAODERISCO.tiposdadosriscos.tab_cr_parcelas_emp.exists(GESTAODERISCO.tiposdadosriscos.idx_parcelas_emp) THEN 
          vr_dtvencto := GESTAODERISCO.tiposdadosriscos.tab_cr_parcelas_emp(GESTAODERISCO.tiposdadosriscos.idx_parcelas_emp).dtmenven;
        END IF;
        
        -- Se encontrou
        IF vr_dtvencto IS NOT NULL AND rw_crapdat.dtmvtolt > vr_dtvencto THEN
          -- Calcular a quantidade de dias em atraso
          vr_qtdiaatr  := rw_crapdat.dtmvtolt - vr_dtvencto;
        ELSE
          vr_qtdiaatr  := 0;
        END IF;
        
        -- se for contrato renegociado
        IF vr_tab_crapepr(idx).flgreneg = 1 THEN
          vr_idx_saldo_reneg := lpad(vr_tab_crapepr(idx).cdcooper, 5, '0') ||
                                lpad(vr_tab_crapepr(idx).nrdconta, 10, '0') || 
                                lpad(vr_tab_crapepr(idx).nrctremp, 10, '0');

          IF vr_tab_reneg_saldos.exists(vr_idx_saldo_reneg) THEN
            vr_vljurant_reneg := nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vlmultap,0) +
                                 nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljurmor,0) +
                                 nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljuremu,0) +
                                 nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljurcor,0);
            -- se tiver valores pendentes do contrato original
            IF vr_vljurant_reneg > 0 THEN
              vr_vljurmor_reneg := nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljurmor,0);
              vr_vljuremu_reneg := nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljuremu,0);
              vr_vljurcor_reneg := nvl(vr_tab_reneg_saldos(vr_idx_saldo_reneg).vljurcor,0);
            END IF;
          END IF;
          IF vr_reg_contrato_reneg.exists(vr_idx_saldo_reneg) THEN
            vr_qtdiaatr := vr_qtdiaatr + NVL(vr_reg_contrato_reneg(vr_idx_saldo_reneg).nrdiaatr,0);
          END IF;
        END IF;
        
        vr_flgremun := FALSE;
        
        IF nvl(vr_qtdiaatr, 0) <= 59 AND nvl(vr_vljurant_reneg, 0) = 0 THEN
          CONTINUE;
        END IF;
        
        IF nvl(vr_qtdiaatr, 0) >= 60 THEN -- se o contrato esta em +60d
          -- Listagem das parcelas vencidas
          vr_vlsaldo59 := 0;
          FOR rw_crappep IN cr_crappep(pr_cdcooper => vr_tab_crapepr(idx).cdcooper
                                      ,pr_nrdconta => vr_tab_crapepr(idx).nrdconta
                                      ,pr_nrctremp => vr_tab_crapepr(idx).nrctremp
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
            
            -- Totaliza
            vr_vlsaldo59 := nvl(vr_vlsaldo59, 0) + rw_crappep.vlsdvatu;

            -- verificar se deve calcular remuneratorio e correcao (empr999.pc_calcula_juros_60d_pos linha 2408)
            IF rw_crappep.dtvencto >= rw_crapdat.dtmvtolt AND NOT vr_flgremun THEN
              vr_flgremun := TRUE;
              vr_vltaxatu := rw_crappep.vltaxatu;
            END IF;
            
            vr_dtrefere60 := rw_crapdat.dtmvtolt - (vr_qtdiaatr - 59) + 1; -- data que virou 60d
            calcularMoraPosFixado(pr_cdcooper => vr_tab_crapepr(idx).cdcooper
                                 ,pr_dtcalcul => rw_crapdat.dtmvtolt -- ate o dia atual
                                 ,pr_dtvencto => rw_crappep.dtvencto
                                 ,pr_dtultpag => GREATEST(vr_dtrefere60, nvl(rw_crappep.dtultpag, rw_crappep.dtvencto))
                                 ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                 ,pr_perjurmo => vr_tab_craplcr(vr_tab_crapepr(idx).cdlcremp).perjurmo
                                 ,pr_txmensal => vr_tab_crapepr(idx).txmensal
                                 ,pr_vlperidx => vr_tab_crapepr(idx).vlperidx
                                 ,pr_vltaxatu => rw_crappep.vltaxatu
                                 ,pr_qttolatr => vr_tab_crapepr(idx).qttolatr
                                 ,pr_vlmrapar => vr_vlmora60
                                 ,pr_dscritic => vr_dscritic);
            -- Testar retorno de erro
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              -- Gerar erro e roolback
              RAISE vr_exc_erro;
            END IF;
            
            -- Totalizar
            vlmrapar60_total := nvl(vlmrapar60_total, 0) + nvl(vr_vlmora60, 0);
            
          END LOOP; -- cr_crappep
        END IF;
        
        -- Se deve calcular remuneratorio e correcao
        IF vr_flgremun THEN
          vr_dtvencto := TO_DATE(vr_tab_crapepr(idx).diapagto || '/' || TO_CHAR(rw_crapdat.dtmvtolt, 'MM/RRRR'),'DD/MM/RRRR');
          -- Calcula a taxa diaria
          vr_txdiaria := POWER(1 + (NVL(vr_tab_crapepr(idx).txmensal,0) / 100),(1 / 30)) - 1;
          
          EMPR0011.pc_calcula_juros_remuneratorio(pr_cdcooper => vr_tab_crapepr(idx).cdcooper
                                                 ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                 ,pr_nrdconta => vr_tab_crapepr(idx).nrdconta
                                                 ,pr_nrctremp => vr_tab_crapepr(idx).nrctremp
                                                 ,pr_dtlibera => vr_tab_crapepr(idx).dtlibera
                                                 ,pr_dtvencto => vr_dtvencto
                                                 ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                                 ,pr_vlsprojt => vr_tab_crapepr(idx).vlsprojt
                                                 ,pr_ehmensal => FALSE
                                                 ,pr_txdiaria => vr_txdiaria
                                                 -- in out
                                                 ,pr_diarefju => vr_tab_crapepr(idx).diarefju
                                                 ,pr_mesrefju => vr_tab_crapepr(idx).mesrefju
                                                 ,pr_anorefju => vr_tab_crapepr(idx).anorefju
                                                 -- out
                                                 ,pr_vljuremu => vr_vljuremu
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic
                                                 );
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          --
          EMPR0011.pc_calcula_juros_correcao(pr_cdcooper => vr_tab_crapepr(idx).cdcooper
                                            ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_flgbatch => TRUE 
                                            ,pr_nrdconta => vr_tab_crapepr(idx).nrdconta
                                            ,pr_nrctremp => vr_tab_crapepr(idx).nrctremp
                                            ,pr_dtlibera => vr_tab_crapepr(idx).dtlibera
                                            ,pr_dtrefjur => vr_tab_crapepr(idx).dtrefjur
                                            ,pr_vlrdtaxa => vr_vltaxatu
                                            ,pr_dtvencto => vr_dtvencto
                                            ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                            ,pr_vlsprojt => vr_tab_crapepr(idx).vlsprojt
                                            ,pr_ehmensal => FALSE 
                                            ,pr_dtrefcor => vr_tab_crapepr(idx).dtrefcor
                                            -- out
                                            ,pr_vljurcor => vr_vljurcor
                                            ,pr_qtdiacal => vr_qtdedias
                                            ,pr_vltaxprd => vr_taxa_periodo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            );
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- total de correcao
        vljurcor_total   := nvl(vr_vljurcor, 0) + nvl(vr_vljurcor_reneg, 0);
        -- total de remuneratorio
        vljuremu_total   := nvl(vr_vljuremu, 0) + nvl(vr_vljuremu_reneg, 0);
        -- correcao + remuneratorio + juros60 das parcelas calculadas
        vljura60_total   := vljurcor_total + vljuremu_total + vlmrapar60_total;
        
        vr_csv_9805_temp := vr_tab_crapepr(idx).cdcooper || ';' ||
                            vr_tab_crapepr(idx).nrdconta || ';' ||
                            vr_tab_crapepr(idx).nrctremp || ';' ||
                            vr_vlsaldo59                 || ';' ||
                            vljura60_total               || ';' ||
                            vljuremu_total               || ';' ||
                            vljurcor_total               || ';' ||
                            vlmrapar60_total             || ';' ||
                            nvl(vr_qtdiaatr, 0)
                            ;
        vr_idx_ris := lpad(vr_tab_crapepr(idx).cdcooper, 5, '0') ||
                      lpad(vr_tab_crapepr(idx).nrdconta, 10, '0') || 
                      lpad(vr_tab_crapepr(idx).nrctremp, 10, '0');
        IF vr_tab_ris.exists(vr_idx_ris) THEN
          vr_csv_9805_temp := vr_csv_9805_temp || ';' ||
                              vr_tab_ris(vr_idx_ris).vljura60     || ';' ||
                              vr_tab_ris(vr_idx_ris).vlmrapar60   || ';' ||
                              vr_tab_ris(vr_idx_ris).vljuremu60   || ';' ||
                              vr_tab_ris(vr_idx_ris).vljurcor60   || ';' ||
                              vr_tab_ris(vr_idx_ris).vldivida_vri || ';' ||
                              vr_tab_ris(vr_idx_ris).vlempres_vri;
        ELSE
          vr_csv_9805_temp := vr_csv_9805_temp || ';N;N;N;N';
        END IF;
        IF vr_tab_crapepr(idx).flgreneg = 1 THEN
          vr_csv_9805_temp := vr_csv_9805_temp || ';S';
        ELSE
          vr_csv_9805_temp := vr_csv_9805_temp || ';N';
        END IF;
        
        pc_escreve_linha(pr_dsdlinha => vr_csv_9805_temp); 
      END LOOP;
      
      cecred.gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, '', TRUE);

      gene0002.pc_clob_para_arquivo(pr_clob     => vr_desclob
                                   ,pr_caminho  => vr_nmdireto
                                   ,pr_arquivo  => vr_nmarqcsv||'.csv'
                                   ,pr_des_erro => vr_des_erro);
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      dbms_lob.close(vr_desclob);
      dbms_lob.freetemporary(vr_desclob);
      
    END IF;
  EXCEPTION 
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := obterCritica(vr_cdcritic);
      END IF;
      pr_dscritic := vr_dscritic;
      
      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => pr_dscritic);
      
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na relatorioJuros60Contrato: ' || SQLERRM;     
      sistema.excecaoInterna(pr_cdcooper => pr_cdcooper
                            ,pr_compleme => pr_dscritic);
  END relatorioJuros60Contrato;
  
BEGIN
  
  vr_cdcooper := 8;
  vr_dtinicio := SYSDATE;
  rw_crapdat  := datascooperativa(vr_cdcooper);
  relatorioJuros60Contrato(pr_cdcooper => vr_cdcooper
                          ,pr_dscritic => vr_dscritic);
  -- Testar retorno de erro
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    -- Gerar erro e roolback
    RAISE vr_exc_erro;
  END IF;
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
