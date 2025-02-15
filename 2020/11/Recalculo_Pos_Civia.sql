declare
  --
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
          ,dat.dtmvtolt
      FROM crapcop cop
          ,crapdat dat
     WHERE cop.cdcooper = dat.cdcooper
       AND cop.cdcooper = 13 -- RETIRAR
       AND cop.flgativo = 1
     ;
  --
  rw_crapcop cr_crapcop%ROWTYPE;
  -- 
  CURSOR cr_parcelas(pr_cdcooper crappep.cdcooper%TYPE
                    ) IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.ROWID
          ,epr.dtmvtolt
          ,epr.qtmesdec
          ,epr.vlsprojt
          ,epr.txmensal
          ,epr.cdlcremp
          ,epr.vlemprst
          ,epr.dtdpagto
          ,epr.qttolatr
          ,epr.qtprecal
          ,epr.qtpreemp
          ,wpr.dtdpagto dtprivcto
          ,wpr.idcarenc
          ,wpr.dtlibera
          --
      FROM crapepr epr
          ,crawepr wpr
          ,crappep pep
     WHERE epr.cdcooper = wpr.cdcooper
       AND epr.nrdconta = wpr.nrdconta
       AND epr.nrctremp = wpr.nrctremp
       AND pep.cdcooper = epr.cdcooper
       AND pep.nrdconta = epr.nrdconta
       AND pep.nrctremp = epr.nrctremp
       AND pep.Inliquid = 0
       AND epr.inliquid = 0
       AND epr.tpemprst = 2
       --
       AND epr.cdcooper = 13
       AND epr.nrdconta = 36838
       AND epr.nrctremp = 47128
       --
       AND EXISTS (   SELECT 1
                        FROM crapepr eprX
                            ,crappep pepX
                            ,craplem lemX
                       WHERE pepX.cdcooper = eprX.cdcooper
                         AND pepX.nrdconta = eprX.nrdconta
                         AND pepX.nrctremp = eprX.nrctremp
                         AND eprX.inliquid = 0
                         AND eprX.tpemprst = 2
                         AND lemX.cdcooper = eprX.cdcooper
                         AND lemX.nrdconta = eprX.nrdconta
                         AND lemX.nrctremp = eprX.nrctremp
                         AND lemX.cdhistor = 2331
                         AND lemX.nrparepr = pepX.nrparepr
                         AND lemX.dtpagemp < pepX.dtvencto
                         AND epr.cdcooper = eprX.cdcooper
                         AND epr.nrdconta = eprX.nrdconta
                         AND epr.nrctremp = eprX.nrctremp);
  --
  rw_parcelas cr_parcelas%ROWTYPE;
  --
  -- Recalculo do saldo projetado e parcelas
  CURSOR cr_meses IS
    SELECT DISTINCT last_day(cal.data) "DATA" --TRUNC(cal.data, 'MM') "DATA"
      FROM( SELECT( to_date(seq.mm || seq.yyyy, 'MM/YYYY')-1
                    -- Subtrai 1 por SEQ.NUM n�o come�ar em zero
                  ) + seq.num AS "DATA"
              FROM( SELECT RESULT NUM, 
                           to_char(( -- Data M�nima
                                    last_day(to_date('01/07/2020', 'DD/MM/YYYY'))
                                   ), 'MM') AS "MM",
                           to_char(( -- Data M�nima
                                    last_day(to_date('01/07/2020', 'DD/MM/YYYY'))
                                   ), 'YYYY') AS "YYYY"
                      FROM( SELECT ROWNUM RESULT 
                              FROM dual
                        CONNECT BY LEVEL <= (( -- Data M�xima
                                              last_day(TRUNC(SYSDATE, 'MM'))
                                              -
                                               -- Data M�nima
                                              last_day(to_date('01/07/2020', 'DD/MM/YYYY')) -- Sempre primeiro dia do m�s
                                             ) + 1 -- �ltimo dia do �ltimo ano
                                            )
                          ) -- Quantas sequ�ncias para gerar pelo MAX
                  ) seq
          ) cal
     WHERE TRUNC(cal.data, 'MM') <= TRUNC(SYSDATE, 'MM')
     ORDER BY 1;
  --
  rw_meses cr_meses%ROWTYPE;
  --
  vr_texto_log          CLOB;
  vr_des_log            CLOB;
  vr_texto_crapepr_prox CLOB;
  vr_des_crapepr_prox   CLOB;
  vr_texto_crappep_prox CLOB;
  vr_des_crappep_prox   CLOB;
  vr_dsdireto           VARCHAR2(1000);
  vr_data_atual         DATE;
  --
  TYPE typ_registro is RECORD(vr_rowid  VARCHAR2(100)
                             ,cdcooper  crapepr.cdcooper%TYPE
                             ,nrdconta  crapepr.nrdconta%TYPE
                             ,nrctremp  crapepr.nrctremp%TYPE
                             ,dtmvtolt  crapepr.dtmvtolt%TYPE
                             ,qtmesdec  crapepr.qtmesdec%TYPE
                             ,vlsprojt  crapepr.vlsprojt%TYPE
                             ,txmensal  crapepr.txmensal%TYPE
                             ,cdlcremp  crapepr.cdlcremp%TYPE
                             ,vlemprst  crapepr.vlemprst%TYPE
                             ,dtdpagto  crapepr.dtdpagto%TYPE
                             ,qttolatr  crapepr.qttolatr%TYPE
                             ,qtprecal  crapepr.qtprecal%TYPE
                             ,qtpreemp  crapepr.qtpreemp%TYPE
                             ,dtprivcto crawepr.dtdpagto%TYPE
                             ,idcarenc  crawepr.idcarenc%TYPE
                             ,dtlibera  crawepr.dtlibera%TYPE
                             );
  --
  TYPE typ_tab_registro IS TABLE OF typ_registro INDEX BY VARCHAR2(100);
  vr_tab_registro typ_tab_registro;
  vr_indice_registro VARCHAR(100);
  --
  TYPE typ_crappep IS RECORD(vr_rowid  VARCHAR2(100)
                            ,cdcooper  crappep.cdcooper%TYPE
                            ,nrdconta  crappep.nrdconta%TYPE
                            ,nrctremp  crappep.nrctremp%TYPE
                            ,nrparepr  crappep.nrparepr%TYPE
                            ,vlparepr  crappep.vlparepr%TYPE
                            ,vlsdvpar  crappep.vlsdvpar%TYPE
                            ,vltaxatu  crappep.vltaxatu%TYPE
                            );
  --
  TYPE typ_tab_crappep IS TABLE OF typ_crappep INDEX BY VARCHAR2(100);
  vr_tab_crappep typ_tab_crappep;
  vr_indice_crappep VARCHAR(100);
  --
  -- CRPS723
  PROCEDURE pc_atualiza_saldo(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ) IS
    -- Soma valor pago da parcela
    CURSOR cr_vltotal_pago_princ(pr_cdcooper IN crappep.cdcooper%TYPE
                                ,pr_nrdconta IN crappep.nrdconta%TYPE
                                ,pr_nrctremp IN crappep.nrctremp%TYPE
                                ,pr_dtvencto IN crappep.dtvencto%TYPE
                                ) IS
      SELECT SUM(crappep.vlpagpar)
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.inliquid = 1;
         
    -- Soma valor total de Juros
    CURSOR cr_vltotal_juros(pr_cdcooper IN crappep.cdcooper%TYPE
                           ,pr_nrdconta IN crappep.nrdconta%TYPE
                           ,pr_nrctremp IN crappep.nrctremp%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                           ) IS
      SELECT SUM(vllanmto)
        FROM craplem
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp
         AND cdhistor IN(2343,2342,2345,2344)
         AND dtmvtolt <= pr_dtmvtolt;
         
    -- Soma valor pago da parcela
    CURSOR cr_vltotal_parcela(pr_cdcooper IN crappep.cdcooper%TYPE
                             ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE
                             ,pr_dtvencto IN crappep.dtvencto%TYPE
                             ) IS
      SELECT SUM(crappep.vlparepr)
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.dtvencto <= pr_dtvencto
         AND crappep.inliquid = 0;
    --
    vr_dtvencto        crappep.dtvencto%TYPE;
    vr_vltotal_pago    NUMBER(25,2);
    vr_vltotal_juros   NUMBER(25,2);
    vr_vltotal_parcela NUMBER(25,2);
    vr_vlsprojt        crapepr.vlsprojt%TYPE;
    --
    vr_indice_registro VARCHAR(100);
    --
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        crapcri.dscritic%TYPE;
    vr_exc_proximo     EXCEPTION;
    --
  BEGIN
    --
    vr_indice_registro := vr_tab_registro.first;
    --
    WHILE vr_indice_registro IS NOT NULL LOOP
      -- S� atualiza os contratos liberados at� a data de processamento
      IF vr_tab_registro(vr_indice_registro).dtlibera <= pr_dtmvtolt THEN
        --
        BEGIN
          -- Data de Vencimento correspondente do m�s
          vr_dtvencto := TO_DATE(TO_CHAR(vr_tab_registro(vr_indice_registro).dtprivcto,'DD')||'/'||TO_CHAR(pr_dtmvtolt,'MM/YYYY'),'DD/MM/RRRR');
          -- Somar o Valor Total Pago
          vr_vltotal_pago := 0;
          OPEN cr_vltotal_pago_princ(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                                    ,pr_nrdconta => vr_tab_registro(vr_indice_registro).nrdconta
                                    ,pr_nrctremp => vr_tab_registro(vr_indice_registro).nrctremp
                                    ,pr_dtvencto => vr_dtvencto
                                    );
          FETCH cr_vltotal_pago_princ INTO vr_vltotal_pago;
          CLOSE cr_vltotal_pago_princ;

          -- Somar o Valor Total de Juros de Emprestimo
          vr_vltotal_juros := 0;
          OPEN cr_vltotal_juros(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                               ,pr_nrdconta => vr_tab_registro(vr_indice_registro).nrdconta
                               ,pr_nrctremp => vr_tab_registro(vr_indice_registro).nrctremp
                               ,pr_dtmvtolt => gene0005.fn_valida_dia_util(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                                                                          ,pr_dtmvtolt => vr_dtvencto
                                                                          ,pr_tipo     => 'P')
                               );
          FETCH cr_vltotal_juros INTO vr_vltotal_juros;
          CLOSE cr_vltotal_juros;

          -- Somar o valor da parcela ate o momento
          vr_vltotal_parcela := 0;
          OPEN cr_vltotal_parcela(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                                 ,pr_nrdconta => vr_tab_registro(vr_indice_registro).nrdconta
                                 ,pr_nrctremp => vr_tab_registro(vr_indice_registro).nrctremp
                                 ,pr_dtvencto => vr_dtvencto
                                 );
          FETCH cr_vltotal_parcela INTO vr_vltotal_parcela;
          CLOSE cr_vltotal_parcela;

          -- Valor Total do Saldo Projetado
          dbms_output.put_line('vlemprst ' || NVL(vr_tab_registro(vr_indice_registro).vlemprst,0) ||
                               ' + vr_vltotal_juros ' || NVL(vr_vltotal_juros,0) ||
                               ' - vr_vltotal_parcela ' || NVL(vr_vltotal_parcela,0) ||
                               ' - vr_vltotal_pago ' || NVL(vr_vltotal_pago,0) ||
                               ' vr_dtvencto ' || vr_dtvencto
                              );
          vr_vlsprojt := NVL(vr_tab_registro(vr_indice_registro).vlemprst,0) +
                         NVL(vr_vltotal_juros,0) -
                         NVL(vr_vltotal_parcela,0) -
                         NVL(vr_vltotal_pago,0);
          --
          
          IF vr_cdcritic IS NOT NULL OR nvl(vr_cdcritic, 0) <> 0 THEN
            --
            gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro: ' || vr_tab_registro(vr_indice_registro).cdcooper || ', ' || vr_tab_registro(vr_indice_registro).nrdconta || ', ' || vr_tab_registro(vr_indice_registro).nrctremp || ' - ' || vr_cdcritic || ' - ' || vr_dscritic || chr(10));
            RAISE vr_exc_proximo;
            --
          END IF;
          --
          vr_tab_registro(vr_indice_registro).vlsprojt := vr_vlsprojt;
          --
          vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
          --
        EXCEPTION
          WHEN vr_exc_proximo THEN
            vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
        END;
        --
      ELSE
        --
        vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
        --
      END IF;
      --
    END LOOP;
    --
  END pc_atualiza_saldo;

  -- CRPS720_1
  PROCEDURE pc_calc_prox_parc_pos(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                 ) IS
    
    -- Busca os dados dos contratos e parcelas
    CURSOR cr_crappep(pr_cdcooper  IN crappep.cdcooper%TYPE
                     ,pr_nrdconta  IN crappep.nrdconta%TYPE
                     ,pr_nrctremp  IN crappep.nrctremp%TYPE
                     ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE
                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                     ) IS
      SELECT crappep.nrparepr,
             crappep.dtvencto
        FROM crappep          
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.inliquid = 0
         AND crappep.dtvencto > pr_dtmvtolt
         AND EXISTS(SELECT 1
                      FROM crappep pep                       
                     WHERE pep.cdcooper = crappep.cdcooper
                       AND pep.nrdconta = crappep.nrdconta
                       AND pep.nrctremp = crappep.nrctremp
                       AND pep.dtvencto > ADD_MONTHS(pr_dtmvtoan,1) 
                       AND pep.dtvencto <= ADD_MONTHS(pr_dtmvtolt,1)
                       AND pep.inliquid = 0 -- Apenas se existir parcelas em aberto
                   )
         AND rownum = 1               
    ORDER BY crappep.nrparepr ASC;
    --
    rw_crappep cr_crappep%ROWTYPE;
    
    -- Busca os dados da carencia
    CURSOR cr_carencia IS
      SELECT param.idcarencia,
             param.qtddias
        FROM tbepr_posfix_param_carencia param
       WHERE param.idparametro = 1;
    
    -- Busca os dados da linha de credito
    CURSOR cr_craplcr IS
      SELECT cdcooper
            ,cdlcremp
            ,cddindex
        FROM craplcr;
        
    -- Buscar a taxa acumulada do CDI
    CURSOR cr_craptxi(pr_dtiniper IN craptxi.dtiniper%TYPE
                     ) IS
      SELECT cddindex
            ,vlrdtaxa
        FROM craptxi
       WHERE dtiniper = pr_dtiniper;

    -- Registro para armazenar informacoes do contrato
    TYPE typ_parc_atu IS RECORD(cdcooper crappep.cdcooper%TYPE
                               ,nrdconta crappep.nrdconta%TYPE
                               ,nrctremp crappep.nrctremp%TYPE
                               ,nrparepr crappep.nrparepr%TYPE
                               ,vlparepr crappep.vlparepr%TYPE
                               ,vltaxatu crappep.vltaxatu%TYPE
                               ,vlsprojt crapepr.vlsprojt%TYPE
                              );

    -- Tabela onde serao armazenados os registros do contrato
    TYPE typ_tab_parc_atu IS TABLE OF typ_parc_atu INDEX BY PLS_INTEGER;
    --
    vr_tab_parcelas EMPR0011.typ_tab_parcelas;
    vr_tab_carencia CADA0001.typ_tab_number;
    vr_tab_craplcr  CADA0001.typ_tab_number;
    vr_tab_craptxi  CADA0001.typ_tab_number;
    vr_tab_parc_pep typ_tab_parc_atu;
    vr_tab_parc_epr typ_tab_parc_atu;
    --
    vr_idx_parcelas    INTEGER;
    vr_idx_parc_pep    PLS_INTEGER;
    vr_idx_parc_epr    PLS_INTEGER;
    vr_qtdias_carencia tbepr_posfix_param_carencia.qtddias%TYPE;
    vr_dtmvtoan        DATE;
    vr_dtmvtolt        DATE;
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        crapcri.dscritic%TYPE;
    --
    vr_exc_proximo EXCEPTION;

    -- Grava os dados das parcelas, emprestimo e controle do batch
    PROCEDURE pc_grava_dados(pr_tab_parc_pep IN typ_tab_parc_atu
                            ,pr_tab_parc_epr IN typ_tab_parc_atu
                            ,pr_dtmvtolt     IN DATE
                            ) IS
      --
      vr_vlparepr      crappep.vlparepr%TYPE;
      vr_vlsdvpar      crappep.vlsdvpar%TYPE;
      vr_vlsdvpar_novo crappep.vlsdvpar%TYPE;
      vr_vltaxatu      crappep.vltaxatu%TYPE;
      vr_dtvencto      crappep.dtvencto%TYPE;
      vr_dtvctaju      crappep.dtvencto%TYPE;
      vr_vlpreemp      crapepr.vlpreemp%TYPE;
      vr_vlsprojt      crapepr.vlsprojt%TYPE;
      vr_dtlibera      crapepr.dtmvtolt%TYPE;
      vr_idpgparc      VARCHAR2(1);
      vr_rowid         ROWID;
      --
    BEGIN
      -- Atualizar Parcelas
      FOR idx IN 1..pr_tab_parc_pep.count LOOP
        --
        vr_vlparepr := 0;
        vr_vlsdvpar := 0;
        vr_vltaxatu := 0;
        vr_dtvencto := NULL;
        vr_rowid    := NULL;
        --
        BEGIN
          --
          SELECT pep.vlparepr
                ,pep.vlsdvpar
                ,pep.vltaxatu
                ,(pr_tab_parc_pep(idx).vlparepr - (nvl(pep.vlpagpar,0) + 
                                                   nvl(pep.vldstrem,0) + 
                                                   nvl(pep.vldstcor,0) + 
                                                   nvl(pep.vldespar,0))) vlsdvpar_novo
                ,pep.dtvencto
                ,pep.rowid
            INTO vr_vlparepr
                ,vr_vlsdvpar
                ,vr_vltaxatu
                ,vr_vlsdvpar_novo
                ,vr_dtvencto
                ,vr_rowid
            FROM crappep pep
           WHERE pep.cdcooper = pr_tab_parc_pep(idx).cdcooper
             AND pep.nrdconta = pr_tab_parc_pep(idx).nrdconta
             AND pep.nrctremp = pr_tab_parc_pep(idx).nrctremp
             AND pep.nrparepr = pr_tab_parc_pep(idx).nrparepr
             AND pep.inliquid = 0;
          --
        EXCEPTION
          WHEN OTHERS THEN
            gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro ao buscar crappep: ' || pr_tab_parc_pep(idx).cdcooper || ', ' || pr_tab_parc_pep(idx).nrdconta || ', ' || pr_tab_parc_pep(idx).nrctremp || SQLERRM || chr(10));
            RAISE vr_exc_proximo;
        END;
        --
        IF vr_vlparepr > vr_vlsdvpar THEN
          --
          vr_idpgparc := '1';
          --
        ELSE
          --
          vr_idpgparc := '0';
          --
        END IF;
        --
        IF vr_vlparepr <> pr_tab_parc_pep(idx).vlparepr OR vr_vlsdvpar <> vr_vlsdvpar_novo THEN
          -- Ajusta a data de vencimento para um dia �til
          vr_dtvctaju := gene0005.fn_valida_dia_util(pr_cdcooper => pr_tab_parc_pep(idx).cdcooper
                                                    ,pr_dtmvtolt => vr_dtvencto
                                                    ,pr_tipo     => 'P'
                                                    );
          --
          IF (vr_dtvencto <= add_months(pr_dtmvtolt, 1)) OR
             (vr_dtvencto > add_months(pr_dtmvtolt, 1) AND add_months(pr_dtmvtolt, 1) > vr_data_atual) THEN
            --
            gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, pr_tab_parc_pep(idx).cdcooper || ';' ||
                                                                                pr_tab_parc_pep(idx).nrdconta || ';' ||
                                                                                pr_tab_parc_pep(idx).nrctremp || ';' ||
                                                                                pr_tab_parc_pep(idx).nrparepr || ';' ||
                                                                                to_char(vr_dtvencto
                                                                                       ,'DD/MM/YYYY')         || ';' ||
                                                                                vr_idpgparc                   || ';' ||
                                                                                to_char(vr_vlparepr
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                to_char(pr_tab_parc_pep(idx).vlparepr
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                to_char(vr_vlsdvpar
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                to_char(vr_vlsdvpar_novo
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                to_char(vr_vltaxatu
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                to_char(pr_tab_parc_pep(idx).vltaxatu
                                                                                       ,'999999990D90'
                                                                                       ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                vr_rowid || chr(10));
            --
            BEGIN
              --FORALL idx IN 1..pr_tab_parc_pep.COUNT SAVE EXCEPTIONS
              UPDATE crappep
                 SET vlparepr = pr_tab_parc_pep(idx).vlparepr
                    ,vlsdvpar = pr_tab_parc_pep(idx).vlparepr - (nvl(crappep.vlpagpar,0) + 
                                                                 nvl(crappep.vldstrem,0) + 
                                                                 nvl(crappep.vldstcor,0) + 
                                                                 nvl(crappep.vldespar,0))
                    ,vltaxatu = pr_tab_parc_pep(idx).vltaxatu
               WHERE cdcooper = pr_tab_parc_pep(idx).cdcooper
                 AND nrdconta = pr_tab_parc_pep(idx).nrdconta
                 AND nrctremp = pr_tab_parc_pep(idx).nrctremp
                 AND nrparepr = pr_tab_parc_pep(idx).nrparepr
                 AND inliquid = 0;
            EXCEPTION
              WHEN OTHERS THEN
                gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro ao atualizar crappep: ' || pr_tab_parc_pep(idx).cdcooper || ', ' || pr_tab_parc_pep(idx).nrdconta || ', ' || pr_tab_parc_pep(idx).nrctremp || SQLERRM || chr(10));
                RAISE vr_exc_proximo;
            END;
            -- Atualizar Emprestimos
            FOR idx IN 1..pr_tab_parc_epr.count LOOP
              --
              vr_vlpreemp := 0;
              vr_vlsprojt := 0;
              --
              BEGIN
                --
                SELECT epr.vlpreemp
                      ,epr.vlsprojt
                      ,epr.dtmvtolt
                      ,epr.rowid
                  INTO vr_vlpreemp
                      ,vr_vlsprojt
                      ,vr_dtlibera
                      ,vr_rowid
                  FROM crapepr epr
                 WHERE epr.cdcooper = pr_tab_parc_epr(idx).cdcooper
                   AND epr.nrdconta = pr_tab_parc_epr(idx).nrdconta
                   AND epr.nrctremp = pr_tab_parc_epr(idx).nrctremp;
                --
              EXCEPTION
                WHEN OTHERS THEN
                  gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro ao buscar crapepr: ' || pr_tab_parc_epr(idx).cdcooper || ', ' || pr_tab_parc_epr(idx).nrdconta || ', ' || pr_tab_parc_epr(idx).nrctremp || SQLERRM || chr(10));
                  RAISE vr_exc_proximo;
              END;
              --
              IF vr_vlpreemp <> pr_tab_parc_epr(idx).vlparepr THEN
                --
                gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, pr_tab_parc_epr(idx).cdcooper || ';' ||
                                                                                    pr_tab_parc_epr(idx).nrdconta || ';' ||
                                                                                    pr_tab_parc_epr(idx).nrctremp || ';' ||
                                                                                    to_char(vr_dtlibera
                                                                                           ,'DD/MM/YYYY')         || ';' ||
                                                                                    to_char(vr_vlpreemp
                                                                                           ,'999999990D90'
                                                                                           ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                    to_char(pr_tab_parc_epr(idx).vlparepr
                                                                                           ,'999999990D90'
                                                                                           ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                    to_char(vr_vlsprojt
                                                                                           ,'999999990D90'
                                                                                           ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                    to_char(pr_tab_parc_epr(idx).vlsprojt
                                                                                           ,'999999990D90'
                                                                                           ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                                    vr_rowid || chr(10));
                --
                BEGIN
                  --FORALL idx IN 1..pr_tab_parc_epr.COUNT SAVE EXCEPTIONS
                  UPDATE crapepr
                     SET vlpreemp = pr_tab_parc_epr(idx).vlparepr
                        ,vlsprojt = pr_tab_parc_epr(idx).vlsprojt
                   WHERE cdcooper = pr_tab_parc_epr(idx).cdcooper
                     AND nrdconta = pr_tab_parc_epr(idx).nrdconta
                     AND nrctremp = pr_tab_parc_epr(idx).nrctremp;
                EXCEPTION
                  WHEN OTHERS THEN
                    gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro ao atualizar crapepr: ' || pr_tab_parc_epr(idx).cdcooper || ', ' || pr_tab_parc_epr(idx).nrdconta || ', ' || pr_tab_parc_epr(idx).nrctremp || SQLERRM || chr(10));
                    RAISE vr_exc_proximo;
                END;
                --
              END IF;
              --
            END LOOP;
            --
          END IF;
          --
        END IF;
        --
      END LOOP;
      --
    END pc_grava_dados;
    --
  BEGIN
    -- Carregar tabela de carencia
    FOR rw_carencia IN cr_carencia LOOP
      --
      vr_tab_carencia(rw_carencia.idcarencia):= rw_carencia.qtddias;
      --
    END LOOP;
    
    -- Carregar tabela de linha de credito
    FOR rw_craplcr IN cr_craplcr LOOP
      vr_tab_craplcr(to_number(rpad(to_char(rw_craplcr.cdcooper), 2, '9') || lpad(to_char(rw_craplcr.cdlcremp), 5, '0'))):= rw_craplcr.cddindex;
    END LOOP;
    --
    vr_indice_registro := vr_tab_registro.first;
    --
    WHILE vr_indice_registro IS NOT NULL LOOP
      -- S� atualiza os contratos liberados at� a data de processamento
      IF vr_tab_registro(vr_indice_registro).dtlibera <= pr_dtmvtolt THEN
        --
        BEGIN
          -- O script faz o processamento retroativo, simulando como se estivesse na data de vencimento (dia �til) da parcela
          -- sendo necess�rio pegar tamb�m o dia �til anterior para buscar a taxa
          vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                                                    ,pr_dtmvtolt => (to_date(to_char(vr_tab_registro(vr_indice_registro).dtprivcto, 'DD') || '/' || to_char(pr_dtmvtolt, 'MM/YYYY'), 'DD/MM/YYYY') -1)
                                                    ,pr_tipo     => 'A'
                                                    );
          vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => vr_tab_registro(vr_indice_registro).cdcooper
                                                    ,pr_dtmvtolt => to_date(to_char(vr_tab_registro(vr_indice_registro).dtprivcto, 'DD') || '/' || to_char(pr_dtmvtolt, 'MM/YYYY'), 'DD/MM/YYYY')
                                                    ,pr_tipo     => 'P'
                                                    );
          -- Se a parcela n�o venceu, n�o recalcula
          IF vr_dtmvtolt >= vr_data_atual OR
          -- Se a data do recalculo � anterior a data de libera��o, n�o recalcula
             vr_dtmvtolt < vr_tab_registro(vr_indice_registro).dtlibera
            THEN
            RAISE vr_exc_proximo;
          END IF;
          
          -- Carregar tabela de taxa
          FOR rw_craptxi IN cr_craptxi(pr_dtiniper => vr_dtmvtoan) LOOP
            --
            vr_tab_craptxi(rw_craptxi.cddindex):= rw_craptxi.vlrdtaxa;
            --
          END LOOP;
          ------------------------------------------------------------------------------------------
          -- Condicao para verificar se devemos efetuar o recalculo de parcela
          ------------------------------------------------------------------------------------------
          -- 1) Parcela contendo somente o juros na carencia, o calculo devera ocorrer sempre no mes anterior
          -- 2) Parcela Principal devera ocorrer todos os meses, mesmo quando as proximas parcelas estiverem liquidadas
          -- 3) Apos o vencimento da ultima parcela nao devera mais efetuar o calculo de parcela
          -- 4) O recalculo somente ocorre no dia do aniversario da parcela
          OPEN cr_crappep(pr_cdcooper  => vr_tab_registro(vr_indice_registro).cdcooper
                         ,pr_nrdconta  => vr_tab_registro(vr_indice_registro).nrdconta
                         ,pr_nrctremp  => vr_tab_registro(vr_indice_registro).nrctremp
                         ,pr_dtmvtoan  => vr_dtmvtoan
                         ,pr_dtmvtolt  => vr_dtmvtolt
                         );
          --
          FETCH cr_crappep INTO rw_crappep;
          -- Se n�o encontrar informa��es
          IF cr_crappep%NOTFOUND THEN
            -- Fechar o cursor pois teremos raise
            CLOSE cr_crappep;
            RAISE vr_exc_proximo;
          END IF;
          -- Apenas fechar o cursor para continuar o processo
          CLOSE cr_crappep;
          
          -- Limpa PL Table
          vr_tab_parcelas.DELETE;

          vr_qtdias_carencia := 0; -- Inicializa

          -- Se for Pos-Fixado e existir carencia
          IF vr_tab_carencia.EXISTS(vr_tab_registro(vr_indice_registro).idcarenc) THEN
            --
            vr_qtdias_carencia := vr_tab_carencia(vr_tab_registro(vr_indice_registro).idcarenc);
            --
          END IF;

          -- Se NAO achou linha de credito
          IF NOT vr_tab_craplcr.EXISTS(to_number(rpad(to_char(vr_tab_registro(vr_indice_registro).cdcooper), 2, '9') || lpad(to_char(vr_tab_registro(vr_indice_registro).cdlcremp), 5, '0'))) THEN
            --
            vr_cdcritic := 363;
            vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
            gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro: ' || vr_tab_registro(vr_indice_registro).cdcooper || ', ' || vr_tab_registro(vr_indice_registro).nrdconta || ', ' || vr_tab_registro(vr_indice_registro).nrctremp || ' - ' || vr_cdcritic || ' - ' || vr_dscritic || chr(10));
            RAISE vr_exc_proximo;
            --
          END IF;
          
          -- Se NAO achou taxa
          IF NOT vr_tab_craptxi.EXISTS(vr_tab_craplcr(to_number(rpad(to_char(vr_tab_registro(vr_indice_registro).cdcooper), 2, '9') || lpad(to_char(vr_tab_registro(vr_indice_registro).cdlcremp), 5, '0')))) THEN
            vr_dscritic := 'Taxa do CDI nao cadastrada. Data: ' || TO_CHAR(vr_dtmvtoan,'DD/MM/RRRR');
            gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro: ' || vr_tab_registro(vr_indice_registro).cdcooper || ', ' || vr_tab_registro(vr_indice_registro).nrdconta || ', ' || vr_tab_registro(vr_indice_registro).nrctremp || ' - ' || vr_cdcritic || ' - ' || vr_dscritic || chr(10));
            RAISE vr_exc_proximo;
          END IF;
          /*
          dbms_output.put_line('vlsprojt: ' || vr_tab_registro(vr_indice_registro).vlsprojt);
          dbms_output.put_line('vr_dtmvtolt: ' || vr_dtmvtolt);
          dbms_output.put_line('dtdpagto: ' || vr_tab_registro(vr_indice_registro).dtdpagto);
          dbms_output.put_line('dtprivcto: ' || vr_tab_registro(vr_indice_registro).dtprivcto);
          dbms_output.put_line('vr_qtdias_carencia: ' || vr_qtdias_carencia);
          */
          -- Chama o calculo da proxima parcela
          EMPR0011.pc_calcula_prox_parcela_pos(pr_cdcooper        => vr_tab_registro(vr_indice_registro).cdcooper
                                              ,pr_flgbatch        => FALSE -- TRUE
                                              ,pr_dtcalcul        => vr_dtmvtolt
                                              ,pr_nrdconta        => vr_tab_registro(vr_indice_registro).nrdconta
                                              ,pr_nrctremp        => vr_tab_registro(vr_indice_registro).nrctremp
                                              ,pr_dtefetiv        => vr_tab_registro(vr_indice_registro).dtmvtolt
                                              ,pr_dtdpagto        => vr_tab_registro(vr_indice_registro).dtprivcto
                                              ,pr_txmensal        => vr_tab_registro(vr_indice_registro).txmensal
                                              ,pr_vlrdtaxa        => vr_tab_craptxi(vr_tab_craplcr(to_number(rpad(to_char(vr_tab_registro(vr_indice_registro).cdcooper), 2, '9') || lpad(to_char(vr_tab_registro(vr_indice_registro).cdlcremp), 5, '0'))))
                                              ,pr_qtpreemp        => vr_tab_registro(vr_indice_registro).qtpreemp
                                              ,pr_vlsprojt        => vr_tab_registro(vr_indice_registro).vlsprojt
                                              ,pr_vlemprst        => vr_tab_registro(vr_indice_registro).vlemprst
                                              ,pr_nrparepr        => rw_crappep.nrparepr
                                              ,pr_dtvencto        => rw_crappep.dtvencto
                                              ,pr_qtdias_carencia => vr_qtdias_carencia
                                              ,pr_tab_parcelas    => vr_tab_parcelas
                                              ,pr_cdcritic        => vr_cdcritic
                                              ,pr_dscritic        => vr_dscritic
                                              );
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, 'Erro: ' || vr_tab_registro(vr_indice_registro).cdcooper || ', ' || vr_tab_registro(vr_indice_registro).nrdconta || ', ' || vr_tab_registro(vr_indice_registro).nrctremp || ' - ' || vr_cdcritic || ' - ' || vr_dscritic || chr(10));
            RAISE vr_exc_proximo;
          END IF;

          -- Carrega PLTABLE das Parcelas
          vr_idx_parcelas := vr_tab_parcelas.FIRST;
          WHILE vr_idx_parcelas IS NOT NULL LOOP
            vr_idx_parc_pep := vr_tab_parc_pep.COUNT + 1;
            vr_tab_parc_pep(vr_idx_parc_pep).cdcooper := vr_tab_registro(vr_indice_registro).cdcooper;
            vr_tab_parc_pep(vr_idx_parc_pep).nrdconta := vr_tab_registro(vr_indice_registro).nrdconta;
            vr_tab_parc_pep(vr_idx_parc_pep).nrctremp := vr_tab_registro(vr_indice_registro).nrctremp;
            vr_tab_parc_pep(vr_idx_parc_pep).nrparepr := vr_tab_parcelas(vr_idx_parcelas).nrparepr;
            vr_tab_parc_pep(vr_idx_parc_pep).vlparepr := vr_tab_parcelas(vr_idx_parcelas).vlparepr;
            vr_tab_parc_pep(vr_idx_parc_pep).vltaxatu := vr_tab_parcelas(vr_idx_parcelas).vlrdtaxa;
            vr_idx_parcelas := vr_tab_parcelas.NEXT(vr_idx_parcelas);
          END LOOP;
          
          -- Carrega PLTABLE de Emprestimo
          vr_idx_parc_epr := vr_tab_parc_epr.COUNT + 1;
          vr_tab_parc_epr(vr_idx_parc_epr).cdcooper := vr_tab_registro(vr_indice_registro).cdcooper;
          vr_tab_parc_epr(vr_idx_parc_epr).nrdconta := vr_tab_registro(vr_indice_registro).nrdconta;
          vr_tab_parc_epr(vr_idx_parc_epr).nrctremp := vr_tab_registro(vr_indice_registro).nrctremp;
          vr_tab_parc_epr(vr_idx_parc_epr).vlparepr := vr_tab_parcelas(vr_tab_parcelas.FIRST).vlparepr;
          vr_tab_parc_epr(vr_idx_parc_epr).vlsprojt := vr_tab_registro(vr_indice_registro).vlsprojt;

          -- Grava os dados conforme PL Table
          pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep
                        ,pr_tab_parc_epr => vr_tab_parc_epr
                        ,pr_dtmvtolt     => vr_dtmvtolt
                        );
          -- Limpa PL Table
          vr_tab_parc_epr.DELETE;
          vr_tab_parc_pep.DELETE;
          --
          vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
          --
        EXCEPTION
          WHEN vr_exc_proximo THEN
            vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
        END;
        --
      ELSE
        --
        vr_indice_registro := vr_tab_registro.next(vr_indice_registro);
        --
      END IF;
      --
    END LOOP;
    --
  END pc_calc_prox_parc_pos;
  --
BEGIN
  -- Inicializar o CLOB
  vr_texto_log     := NULL;
  vr_des_log       := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
  --
  vr_texto_crapepr_prox := NULL;
  vr_des_crapepr_prox   := NULL;
  dbms_lob.createtemporary(vr_des_crapepr_prox, TRUE);
  dbms_lob.open(vr_des_crapepr_prox, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, 'cdcooper;nrdconta;nrctremp;dtlibera;vr_vlpreemp_antes;vr_vlpreemp;vr_vlsprojt_antes;vr_vlsprojt;rowid' || chr(10));
  --
  vr_texto_crappep_prox := NULL;
  vr_des_crappep_prox   := NULL;
  dbms_lob.createtemporary(vr_des_crappep_prox, TRUE);
  dbms_lob.open(vr_des_crappep_prox, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, 'cdcooper;nrdconta;nrctremp;nrparepr;dtvencto;idpgparc;vr_vlparepr_antes;vr_vlparepr;vr_vlsdvpar_antes;vr_vlsdvpar;vr_vltaxatu_antes;vr_vltaxatu;rowid' || chr(10));
  --
  OPEN cr_crapcop;
  --
  LOOP
    --
    FETCH cr_crapcop INTO rw_crapcop;
    EXIT WHEN cr_crapcop%NOTFOUND;
    --
    vr_data_atual := rw_crapcop.dtmvtolt;
    --
    OPEN cr_parcelas(rw_crapcop.cdcooper
                    );
    --
    LOOP
      --
      FETCH cr_parcelas INTO rw_parcelas;
      EXIT WHEN cr_parcelas%NOTFOUND;
      --
      IF NOT vr_tab_registro.exists(rw_parcelas.rowid) THEN
        --
        vr_tab_registro(rw_parcelas.rowid).vr_rowid  := rw_parcelas.rowid;
        vr_tab_registro(rw_parcelas.rowid).cdcooper  := rw_parcelas.cdcooper;
        vr_tab_registro(rw_parcelas.rowid).nrdconta  := rw_parcelas.nrdconta;
        vr_tab_registro(rw_parcelas.rowid).nrctremp  := rw_parcelas.nrctremp;
        vr_tab_registro(rw_parcelas.rowid).dtmvtolt  := rw_parcelas.dtmvtolt;
        vr_tab_registro(rw_parcelas.rowid).qtmesdec  := rw_parcelas.qtmesdec;
        vr_tab_registro(rw_parcelas.rowid).vlsprojt  := rw_parcelas.vlsprojt;
        vr_tab_registro(rw_parcelas.rowid).txmensal  := rw_parcelas.txmensal;
        vr_tab_registro(rw_parcelas.rowid).cdlcremp  := rw_parcelas.cdlcremp;
        vr_tab_registro(rw_parcelas.rowid).vlemprst  := rw_parcelas.vlemprst;
        vr_tab_registro(rw_parcelas.rowid).txmensal  := rw_parcelas.txmensal;
        vr_tab_registro(rw_parcelas.rowid).dtdpagto  := rw_parcelas.dtdpagto;
        vr_tab_registro(rw_parcelas.rowid).vlsprojt  := rw_parcelas.vlsprojt;
        vr_tab_registro(rw_parcelas.rowid).qttolatr  := rw_parcelas.qttolatr;
        vr_tab_registro(rw_parcelas.rowid).qtprecal  := rw_parcelas.qtprecal;
        vr_tab_registro(rw_parcelas.rowid).qtpreemp  := rw_parcelas.qtpreemp;
        vr_tab_registro(rw_parcelas.rowid).dtprivcto := rw_parcelas.dtprivcto;
        vr_tab_registro(rw_parcelas.rowid).idcarenc  := rw_parcelas.idcarenc;
        vr_tab_registro(rw_parcelas.rowid).dtlibera  := rw_parcelas.dtlibera;
        --
      END IF;
      --
    END LOOP;
    --
    CLOSE cr_parcelas;
    --
  END LOOP;
  --
  CLOSE cr_crapcop;
  --
  OPEN cr_meses;
  --
  LOOP
    --
    FETCH cr_meses INTO rw_meses;
    EXIT WHEN cr_meses%NOTFOUND;
    -- CRPS723 -- Atualiza o saldo
    pc_atualiza_saldo(rw_meses.data);
    -- CRPS720_1 -- Atualiza a pr�xima parcela
    pc_calc_prox_parc_pos(rw_meses.data);
    --
  END LOOP;
  --
  CLOSE cr_meses;
  -- Fecha o arquivo
  gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'log_erros_prmj.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);
  --
  gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crapepr_prox, vr_dsdireto, 'crapepr_prox_parc_prmj.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_crapepr_prox);
  dbms_lob.freetemporary(vr_des_crapepr_prox);
  --
  gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crappep_prox, vr_dsdireto, 'crappep_prox_parc_prmj.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_crappep_prox);
  dbms_lob.freetemporary(vr_des_crappep_prox);
  --
  COMMIT;
  --
exception
  when others then
   ROLLBACK;   
end;
