DECLARE
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(4000);
  vr_log       CLOB;
  vr_exc_saida EXCEPTION;

  CURSOR cr_crapepr_est IS
    SELECT epr.cdcooper
          ,epr.cdagenci
          ,epr.nrdconta
          ,epr.cdorigem
          ,epr.nrctremp
          ,epr.dtultpag
          ,dat.dtmvtolt
      FROM crapepr epr,
           crapdat dat      
     WHERE epr.cdcooper = dat.cdcooper
       AND epr.dtultpag < to_date('23/07/2021', 'DD/MM/RRRR')
       AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) IN
           ((9, 195677, 26115),
            (9, 300675, 20664),
            (9, 185329, 38569),
            (9, 245984, 28986),
            (11, 395781, 68324),
            (11, 189235, 67271),
            (11, 591475, 119585),
            (11, 395781, 46231),
            (11, 593850, 67577),
            (11, 335100, 48548),
            (11, 92517, 57459),
            (11, 375942, 26859),
            (11, 375942, 26859),
            (11, 273210, 49219),
            (11, 428280, 60043),
            (11, 214310, 65591),
            (11, 214310, 65591),
            (11, 638013, 111771),
            (11, 92517, 57459),
            (11, 563951, 80187),
            (11, 563951, 80187),
            (11, 395765, 63809),
            (11, 138223, 61853),
            (2, 646164, 269786),
            (2, 594997, 253263),
            (2, 503657, 264736),
            (2, 634182, 264852),
            (2, 634182, 264852),
            (2, 678899, 284927),
            (2, 587044, 278366),
            (2, 587044, 278366),
            (2, 615170, 265158),
            (2, 615170, 265158),
            (2, 488739, 261553),
            (2, 488739, 261553),
            (2, 488739, 261553),
            (2, 315923, 695),
            (2, 505056, 235430),
            (2, 773603, 264849),
            (2, 663859, 259698),
            (2, 663859, 259698),
            (2, 711829, 258734),
            (2, 739707, 250391),
            (2, 716863, 247913),
            (2, 652776, 261753),
            (2, 652776, 261753),
            (2, 652776, 261753),
            (2, 725730, 1772719),
            (2, 725730, 1772719),
            (2, 376159, 266601),
            (2, 376159, 266601),
            (2, 642010, 251959),
            (2, 642010, 251959),
            (2, 150304, 262862),
            (2, 150304, 262862),
            (2, 715298, 291045),
            (2, 715298, 291045),
            (2, 550213, 251613),
            (2, 777790, 261860),
            (2, 777790, 261860),
            (2, 406872, 231983),
            (2, 745677, 277818),
            (2, 677000, 260163),
            (2, 677000, 260163),
            (2, 745928, 250825),
            (2, 745928, 250825),
            (2, 368903, 290605),
            (2, 368903, 290605),
            (2, 762563, 280735),
            (2, 762563, 280735),
            (2, 754455, 282897),
            (2, 754455, 282897),
            (2, 769568, 294296),
            (2, 769568, 294296),
            (2, 699020, 276878),
            (2, 560103, 250265),
            (2, 560103, 250265),
            (2, 560103, 259686),
            (2, 560103, 259686),
            (2, 590282, 245713),
            (2, 560103, 250267),
            (2, 560103, 250267),
            (2, 582328, 258586),
            (5, 215520, 23283),
            (5, 215422, 32045),
            (5, 188590, 18266),
            (5, 234419, 23568),
            (5, 181650, 29944),
            (5, 181650, 29944),
            (5, 174050, 29187),
            (5, 192406, 21320),
            (5, 263508, 27069),
            (5, 242004, 19315),
            (5, 230154, 17254),
            (5, 227129, 16876),
            (5, 256935, 24965),
            (5, 256935, 24965),
            (5, 171603, 29055),
            (5, 263508, 27069),
            (13, 294810, 37215),
            (13, 144908, 55009),
            (13, 470970, 73710),
            (13, 271411, 51626),
            (13, 72290, 37832),
            (13, 212571, 54865),
            (13, 322393, 58117),
            (13, 204978, 71298),
            (13, 362387, 48449),
            (13, 161756, 82372),
            (13, 144266, 55173),
            (13, 252590, 30858),
            (13, 366676, 49693),
            (13, 2305, 10829),
            (13, 206458, 29373),
            (13, 206458, 29373),
            (13, 433381, 92702),
            (13, 433381, 92702),
            (13, 133035, 26982),
            (13, 106607, 19307),
            (13, 106607, 19307),
            (13, 87831, 15241),
            (13, 204978, 71298),
            (13, 442003, 88615),
            (13, 379620, 50576),
            (13, 504335, 85422),
            (13, 378429, 65715),
            (13, 390860, 53710),
            (13, 390860, 53710),
            (16, 706639, 201424),
            (16, 129224, 70991),
            (16, 32433, 33612),
            (16, 266710, 122713),
            (16, 349208, 164099),
            (16, 367001, 124815),
            (16, 279005, 86601),
            (16, 631353, 199814),
            (16, 248274, 77517),
            (16, 6442609, 99739),
            (16, 410438, 80848),
            (16, 6096786, 96513),
            (16, 6096786, 96513),
            (16, 2473453, 59850),
            (16, 490776, 117547),
            (16, 139432, 114324),
            (16, 139432, 114324),
            (16, 468711, 127208),
            (16, 509485, 250322),
            (16, 509485, 250313),
            (16, 509485, 250313),
            (16, 105678, 84609),
            (16, 105678, 84609));
  rw_crapepr_est cr_crapepr_est%ROWTYPE;

  PROCEDURE pc_tela_estornar_pagamentos(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci        IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                       ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                       ,pr_cdoperad        IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                       ,pr_nmdatela        IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem        IN INTEGER               --> Id do m�dulo de sistema
                                       ,pr_nrdconta        IN crapepr.nrdconta%TYPE --> N�mero da conta
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_dtmvtopr        IN crapdat.dtmvtopr%TYPE --> Movimento atual
                                       ,pr_nrctremp        IN crapepr.nrctremp%TYPE --> N�mero do contrato de empr�stimo
                                       ,pr_dsjustificativa IN VARCHAR2              --> Justificativa
                                       ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic        OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    DECLARE
      -- Cursor do Lancamento do Emprestimo
      CURSOR cr_craplem_max(pr_cdcooper IN craplem.cdcooper%TYPE
                           ,pr_nrdconta IN craplem.nrdconta%TYPE
                           ,pr_nrctremp IN craplem.nrctremp%TYPE
                           ,pr_nrparepr IN craplem.nrparepr%TYPE) IS
        SELECT MAX(craplem.dtmvtolt) AS dtmvtolt
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtestorn IS NULL
           AND craplem.cdhistor IN (1039, 1044, 1045, 1057);

      /* Cursor para buscar o lancamento de Juros Remuneratorio */
      CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE
                             ,pr_nrdconta IN craplem.nrdconta%TYPE
                             ,pr_nrctremp IN craplem.nrctremp%TYPE
                             ,pr_nrparepr IN craplem.nrparepr%TYPE
                             ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT craplem.vllanmto
              ,COUNT(1) over() qtde_registro
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtmvtolt = pr_dtmvtolt
           AND craplem.cdhistor IN (1050, 1051);
      rw_craplem_juros cr_craplem_juros%ROWTYPE;

      -- Cursor para buscar a ultima parcela que foi paga
      CURSOR cr_crappep_max_pagto(pr_cdcooper IN crappep.cdcooper%TYPE
                                 ,pr_nrdconta IN crappep.nrdconta%TYPE
                                 ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT MAX(crappep.dtultpag) dtultpag
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp;
      vr_dtultpag crappep.dtultpag%TYPE;

      -- Cursor para buscar a primeira parcela que nao foi paga
      CURSOR cr_crappep_min_dtvencto(pr_cdcooper IN crappep.cdcooper%TYPE
                                    ,pr_nrdconta IN crappep.nrdconta%TYPE
                                    ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT MIN(crappep.dtvencto) dtvencto
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0;
      vr_dtvencto crappep.dtvencto%TYPE;

      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT inliquid
              ,dtultpag
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;

      -- Cursor para buscar os bens do emprestimo
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                       ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                       ,pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
        SELECT COUNT(1) total
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro IN (90, 99)
           AND crapbpr.cdsitgrv IN (0, 2)
           AND crapbpr.flgbaixa = 1
           AND crapbpr.tpdbaixa = 'A';
      vr_existbpr PLS_INTEGER := 0;

      -- Cursor para o historico do lancamento
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT cdhisest
          FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor;
      vr_cdhisest craphis.cdhisest%TYPE;

      -- Verifica se alguma parcela ficou com saldo negativo
      CURSOR cr_crappep_saldo(pr_cdcooper IN crappep.cdcooper%TYPE
                             ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT 1
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND (crappep.vlpagpar < 0 OR crappep.vlsdvpar < 0 OR crappep.vlsdvsji < 0 OR
               crappep.vldespar < 0 OR crappep.vlpagmra < 0 OR crappep.vlpagmta < 0);
      vr_flgnegat PLS_INTEGER := 0;

      -- Cursor para verificar se � um Emprestimo Consigado - P437
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp
           AND crapepr.tpemprst = 1
           AND crapepr.tpdescto = 2;
      vr_flgconsig PLS_INTEGER := 0;

      vr_tab_erro            GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas EMPR0008.typ_tab_lancto_parcelas;
      vr_tab_lancto_cc       EMPR0001.typ_tab_lancconta;
      vr_cdestorno           tbepr_estorno.cdestorno%TYPE;
      vr_cdlancamento        tbepr_estornolancamento.cdlancamento%TYPE;
      vr_vlpagpar            crappep.vlpagpar%TYPE;
      vr_vlpagmta            crappep.vlpagmta%TYPE;
      vr_vlpagmra            crappep.vlpagmra%TYPE;
      vr_vljuratr            craplem.vllanmto%TYPE;
      vr_vldescto            craplem.vllanmto%TYPE;
      vr_dtmvtolt            DATE;
      vr_index_lanc          VARCHAR2(80);
      vr_cdhislcm            PLS_INTEGER;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_des_reto VARCHAR2(3);

      PROCEDURE pc_busca_lancamentos_pagto(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci            IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                          ,pr_nrdcaixa            IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                          ,pr_cdoperad            IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                          ,pr_nmdatela            IN VARCHAR2              --> Nome da tela
                                          ,pr_idorigem            IN INTEGER               --> Id do m�dulo de sistema
                                          ,pr_nrdconta            IN crapepr.nrdconta%TYPE --> N�mero da conta
                                          ,pr_idseqttl            IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_nrctremp            IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                          ,pr_des_reto            OUT VARCHAR              --> Retorno OK / NOK
                                          ,pr_tab_erro            OUT gene0001.typ_tab_erro                --> Tabela com poss�ves erros
                                          ,pr_tab_lancto_parcelas OUT EMPR0008.typ_tab_lancto_parcelas) IS --> Tabela com registros de estorno
      BEGIN
        DECLARE
          -- Cursor do Emprestimo
          CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                           ,pr_nrdconta IN crapepr.nrdconta%TYPE
                           ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
            SELECT crapepr.inprejuz
                  ,crapepr.dtultpag
                  ,crapepr.dtliquid
                  ,crapepr.dtultest
                  ,crapepr.tpemprst
                  ,crapepr.tpdescto
                  , --P437
                   crapepr.flgpagto
                  ,crapepr.cdlcremp
                  ,crapepr.inliquid
                  ,crapepr.cdfinemp
                  ,crawepr.dtvencto
                  ,crawepr.idquapro
                  ,crawepr.dtlibera
                  ,crawepr.flgreneg
              FROM crapepr

              JOIN crawepr
                ON crawepr.cdcooper = crapepr.cdcooper
               AND crawepr.nrdconta = crapepr.nrdconta
               AND crawepr.nrctremp = crapepr.nrctremp

             WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
          rw_crapepr cr_crapepr%ROWTYPE;

          -- Cursor da Linha de Credito
          CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                           ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
            SELECT tpctrato
              FROM craplcr
             WHERE craplcr.cdcooper = pr_cdcooper
               AND craplcr.cdlcremp = pr_cdlcremp;
          rw_craplcr cr_craplcr%ROWTYPE;

          -- Cursor da Finalidade
          CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE
                           ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
            SELECT tpfinali
              FROM crapfin
             WHERE crapfin.cdcooper = pr_cdcooper
               AND crapfin.cdfinemp = pr_cdfinemp;
          rw_crapfin cr_crapfin%ROWTYPE;

          -- Cursor da Parcela do Emprestimo
          CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                           ,pr_nrdconta IN crappep.nrdconta%TYPE
                           ,pr_nrctremp IN crappep.nrctremp%TYPE
                           ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
            SELECT dtvencto
              FROM crappep
             WHERE crappep.cdcooper = pr_cdcooper
               AND crappep.nrdconta = pr_nrdconta
               AND crappep.nrctremp = pr_nrctremp
               AND crappep.nrparepr = pr_nrparepr;
          rw_crappep cr_crappep%ROWTYPE;

          rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

          -- Cursor para buscar os bens do emprestimo
          CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                           ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                           ,pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
            SELECT cdsitgrv
                  ,tpdbaixa
              FROM crapbpr
             WHERE crapbpr.cdcooper = pr_cdcooper
               AND crapbpr.nrdconta = pr_nrdconta
               AND crapbpr.nrctrpro = pr_nrctremp
               AND crapbpr.tpctrpro IN (90, 99);

          -- Cursor dos Lancamentos do Emprestimo
          CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                           ,pr_nrdconta IN craplem.nrdconta%TYPE
                           ,pr_nrctremp IN craplem.nrctremp%TYPE
                           ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE
                           ,pr_dtultest IN crapepr.dtultest%TYPE) IS
            SELECT aux.*
                  ,SUM(aux.vllanmto) OVER(PARTITION BY nrparepr) vlpagpar
              FROM (SELECT craplem.nrdconta
                          ,craplem.nrctremp
                          ,craplem.nrparepr
                          ,craplem.dtmvtolt
                          ,craplem.cdhistor
                          ,craplem.vllanmto
                          ,craplem.dtpagemp
                          ,craplem.txjurepr
                          ,craplem.vlpreemp
                          ,craphis.cdhisest
                          ,craplem.progress_recid
                      FROM craplem
                          ,craphis
                          ,crapepr
                     WHERE craphis.cdcooper = craplem.cdcooper
                       AND craphis.cdhistor = craplem.cdhistor
                       AND craplem.cdcooper = crapepr.cdcooper
                       AND craplem.nrdconta = crapepr.nrdconta
                       AND craplem.nrctremp = crapepr.nrctremp
                       AND crapepr.tpemprst || crapepr.tpdescto <> 12 --Consignado - PP - Desconto em Folha
                       AND craplem.cdcooper = pr_cdcooper
                       AND craplem.nrdconta = pr_nrdconta
                       AND craplem.nrctremp = pr_nrctremp
                       AND craplem.dtmvtolt = pr_dtmvtolt
                       AND (nvl(pr_dtultest, SYSDATE) = SYSDATE OR craplem.dtmvtolt >= pr_dtultest)
                       AND craplem.nrparepr > 0
                       AND craphis.cdhisest > 0
                       AND craphis.cdhistor NOT IN (2311, 2312) -- IOF Atraso
                    UNION
                    SELECT craplem.nrdconta
                          ,craplem.nrctremp
                          ,craplem.nrparepr
                          ,craplem.dtmvtolt
                          ,craplem.cdhistor
                          ,craplem.vllanmto
                          ,craplem.dtpagemp
                          ,craplem.txjurepr
                          ,craplem.vlpreemp
                          ,craphis.cdhisest
                          ,craplem.progress_recid
                      FROM craplem
                          ,craphis
                          ,crapepr
                     WHERE craphis.cdcooper = craplem.cdcooper
                       AND craphis.cdhistor = craplem.cdhistor
                       AND craplem.cdcooper = crapepr.cdcooper
                       AND craplem.nrdconta = crapepr.nrdconta
                       AND craplem.nrctremp = crapepr.nrctremp
                       AND crapepr.tpemprst || crapepr.tpdescto = 12 --Consignado - PP - Desconto em Folha
                       AND craplem.cdcooper = pr_cdcooper
                       AND craplem.nrdconta = pr_nrdconta
                       AND craplem.nrctremp = pr_nrctremp
                       AND craplem.dtmvtolt = pr_dtmvtolt
                       AND (nvl(pr_dtultest, SYSDATE) = SYSDATE OR craplem.dtmvtolt >= pr_dtultest)
                       AND craplem.nrparepr > 0
                       AND craphis.cdhisest > 0
                       AND craphis.cdhistor NOT IN (2311, 2312) -- IOF Atraso
                    UNION
                    --P437-CONSIGNADO
                    SELECT consig_pg.nrdconta
                          ,consig_pg.nrctremp
                          ,consig_pg.nrparepr
                          ,crapepr.dtultpag      dtmvtolt
                          ,craplcm.cdhistor
                          ,craplcm.vllanmto
                          ,crappep.dtultpag      dtpagemp
                          ,NULL                  txjurepr
                          ,consig_pg.vlparepr    vlpreemp
                          ,craphis.cdhisest
                          ,consig_pg.idsequencia progress_recid
                      FROM tbepr_consignado_pagamento consig_pg
                          ,crapepr                    crapepr
                          ,crappep                    crappep
                          ,craplcm                    craplcm
                          ,craphis                    craphis
                          ,crapdat                    crapdat
                     WHERE consig_pg.cdcooper = crapepr.cdcooper
                       AND consig_pg.nrdconta = crapepr.nrdconta
                       AND consig_pg.nrctremp = crapepr.nrctremp
                       AND crapepr.tpemprst = 1 --Empr�stimo PP - Consignado
                       AND crapepr.tpdescto = 2 --Folha de Pagamento - Consignado
                       AND crapepr.dtultpag = crappep.dtultpag
                       AND consig_pg.cdcooper = crappep.cdcooper
                       AND consig_pg.nrdconta = crappep.nrdconta
                       AND consig_pg.nrctremp = crappep.nrctremp
                       AND consig_pg.nrparepr = crappep.nrparepr
                       AND consig_pg.cdcooper = crapdat.cdcooper
                          --
                          --AND craplcm.vllanmto = consig_pg.vlpagpar
                       AND craplcm.cdcooper = consig_pg.cdcooper
                       AND craplcm.nrdconta = consig_pg.nrdconta
                       AND craplcm.cdpesqbb = gene0002.fn_mask(consig_pg.nrctremp, 'zz.zzz.zz9')
                       AND craplcm.nrparepr = consig_pg.nrparepr
                       AND craplcm.dtmvtolt = pr_dtmvtolt --data do ultimo pagamento
                       AND craplcm.dtmvtolt = crapdat.dtmvtolt -- A LCM precisa ser da data atual
                       AND craplcm.cdbccxlt = 100
                       AND craplcm.cdhistor IN (108,
                                                1539, -- PAGAMENTO
                                                3089,
                                                3190, -- SM09_2 - PAGTO PRESTACAO DE EMPRESTIMO CONSIGNADO
                                                1060,
                                                1070, -- Multa
                                                1071,
                                                1072, -- Mora/Atraso
                                                2313,
                                                2314, -- IOF
                                                1050,
                                                1051, -- Juros de Atraso
                                                1048,
                                                1049) -- Valor de Desconto
                          --
                       AND craphis.cdhistor = craplcm.cdhistor
                       AND craphis.cdcooper = craplcm.cdcooper
                       AND craphis.cdhisest > 0
                          --
                       AND consig_pg.instatus = 2 --processado
                       AND consig_pg.Inorgpgt <> 5 --Conciliacao
                       AND consig_pg.idseqpagamento IS NULL --Registro de Pagamento
                       AND consig_pg.cdcooper = pr_cdcooper
                       AND consig_pg.nrdconta = pr_nrdconta
                       AND consig_pg.nrctremp = pr_nrctremp
                     ORDER BY nrctremp
                             ,nrparepr
                             ,dtmvtolt) aux;

          -- Vari�vel de cr�ticas
          vr_cdcritic crapcri.cdcritic%TYPE;
          vr_dscritic VARCHAR2(10000);

          -- Tratamento de erros
          vr_exc_saida EXCEPTION;

          vr_nrdiaest    PLS_INTEGER;
          vr_ind_estorno VARCHAR(20);
          vr_dtliquid    DATE;
          vr_dstextab    craptab.dstextab%TYPE;
          vr_dtvenmes    DATE;

        BEGIN
          pr_tab_lancto_parcelas.DELETE;

          -- Verifica se a data esta cadastrada
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
          FETCH BTCH0001.cr_crapdat
            INTO rw_crapdat;
          -- Se nao encontrar
          IF BTCH0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois havera raise
            CLOSE BTCH0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor
            CLOSE BTCH0001.cr_crapdat;
          END IF;

          -- Busca os dados do emprestimo
          OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrctremp => pr_nrctremp);
          FETCH cr_crapepr
            INTO rw_crapepr;
          -- Verifica se a retornou registro
          IF cr_crapepr%NOTFOUND THEN
            CLOSE cr_crapepr;
            vr_cdcritic := 356;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas Fecha o Cursor
            CLOSE cr_crapepr;
          END IF;

          -- Nao pode
          IF rw_crapepr.flgreneg = 1 THEN
            vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato renegociado';
            RAISE vr_exc_saida;
          END IF;

          -- Somente o produto PP ira ter estorno
          IF rw_crapepr.tpemprst <> 1 THEN
            vr_cdcritic := 946;
            RAISE vr_exc_saida;
          END IF;

          -- Contrato de Emprestimo nao pode estar em Prejuizo
          IF rw_crapepr.inprejuz <> 0 THEN
            vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em prejuizo';
            RAISE vr_exc_saida;
          END IF;

          -- Contrato de emprestimo nao pode debitar em Folha
          IF rw_crapepr.flgpagto <> 0 AND rw_crapepr.tpemprst <> 1 AND --P437 --Valida��o do Consignado Antigo
             rw_crapepr.tpdescto <> 2 THEN
            --P437
            vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em folha';
            RAISE vr_exc_saida;
          END IF;

          -- Busca os dados da linha de credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper, pr_cdlcremp => rw_crapepr.cdlcremp);
          FETCH cr_craplcr
            INTO rw_craplcr;
          -- Verifica se a retornou registro
          IF cr_craplcr%NOTFOUND THEN
            CLOSE cr_craplcr;
            vr_dscritic := 'Linha de credito nao cadastrada. Codigo: ' ||
                           TO_CHAR(rw_crapepr.cdlcremp);
            RAISE vr_exc_saida;
          ELSE
            -- Apenas Fecha o Cursor
            CLOSE cr_craplcr;
          END IF;

          -- Emprestimo/Financiamento, Alienacao de Veiculo, Hipoteca de Imoveis, Aplicacao
          IF rw_craplcr.tpctrato NOT IN (1, 2, 3, 4) THEN
            vr_dscritic := 'Tipo de contrato da linha de credito nao permitida';
            RAISE vr_exc_saida;
          END IF;

          -- Busca os dados da Finalidade
          OPEN cr_crapfin(pr_cdcooper => pr_cdcooper, pr_cdfinemp => rw_crapepr.cdfinemp);
          FETCH cr_crapfin
            INTO rw_crapfin;
          -- Verifica se a retornou registro
          IF cr_crapfin%NOTFOUND THEN
            CLOSE cr_crapfin;
            vr_dscritic := 'Finalidade nao cadastrada. Codigo: ' || TO_CHAR(rw_crapepr.cdfinemp);
            RAISE vr_exc_saida;
          ELSE
            -- Apenas Fecha o Cursor
            CLOSE cr_crapfin;
          END IF;

          -- Caso o contrato de emprestimo estiver liquidado, precisamos fazer algumas validacoes
          IF rw_crapepr.inliquid = 1 THEN

            -- A data de liquidacao precisa estar dentro do m�s
            IF NOT (rw_crapepr.dtliquid >= rw_crapdat.dtinimes AND
                rw_crapepr.dtliquid <= rw_crapdat.dtultdia) THEN
              vr_dscritic := 'Nao e permitido efetuar o estorno, pois a liquidacao esta fora do mes';
              RAISE vr_exc_saida;
            END IF;

            -- Alienacao de Veiculo
            IF rw_craplcr.tpctrato = 2 THEN

              -- Vamos verificar se os bens estao alienados ao contrato
              FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctremp => pr_nrctremp) LOOP

                IF UPPER(rw_crapbpr.tpdbaixa) = 'M' THEN
                  vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
                  RAISE vr_exc_saida;
                END IF;

                IF rw_crapbpr.cdsitgrv NOT IN (0, 2) THEN
                  vr_dscritic := 'Nao e possivel efetuar o estorno, Gravames em processamento, verifique a tela Gravam.';
                  RAISE vr_exc_saida;
                END IF; /* END IF rw_crapbpr.cdsitgrv NOT IN (0,2) THEN */

              END LOOP; /* END FOR rw_crapbpr */

              -- Alienacao/Hipoteca de Imoveis
            ELSIF rw_craplcr.tpctrato = 3 THEN

              vr_nrdiaest := 0;
              vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                                        pr_nmsistem => 'CRED',
                                                        pr_tptabela => 'USUARI',
                                                        pr_cdempres => 11,
                                                        pr_cdacesso => 'PAREMPREST',
                                                        pr_tpregist => 1);
              --Se nao encontrou parametro
              IF TRIM(vr_dstextab) IS NULL THEN
                vr_cdcritic := 55;
                RAISE vr_exc_saida;
              ELSE
                vr_nrdiaest := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 9, 3)), 0);

              END IF;

              -- Retorna a data de liquidacao somado com os dias configurados
              vr_dtliquid := EMPR0008.fn_retorna_data_util(pr_cdcooper => pr_cdcooper,
                                                           pr_dtiniper => rw_crapepr.dtliquid,
                                                           pr_qtdialib => vr_nrdiaest);

              -- A data de liquidacao nao pode ser maior que os dias configurados
              IF NOT (vr_dtliquid >= rw_crapdat.dtmvtolt) THEN
                vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
                RAISE vr_exc_saida;
              END IF;

            END IF; /* END IF rw_crapepr.tpctrato = 3 THEN */

          END IF;

          /* Calcular o vencimento dentro do m�s */
          vr_dtvenmes := TO_DATE(TO_CHAR(rw_crapepr.dtvencto, 'DD') ||
                                 TO_CHAR(rw_crapdat.dtmvtolt, 'MMYYYY'),
                                 'DDMMYYYY');
          /* Regra para n�o permitir estornar pagamentos antes do vencimento no m�s
          que no dia do vencimento n�o ocorreu nenhum pagamento, ir� gerar residuo
          no contrato ser� avaliada uma solu��o definitiva posteriormente */
          IF (rw_crapdat.dtmvtolt > vr_dtvenmes) AND (rw_crapepr.dtultpag < vr_dtvenmes)
            -- garantir que ir� permitir estorno dentro da carencia - Rafael Maciel (RKAM)
             AND ((rw_crapepr.dtvencto < rw_crapdat.dtmvtolt) AND (rw_crapepr.tpemprst = 1) AND
             (rw_crapepr.idquapro = 0) AND (rw_crapepr.dtlibera > rw_crapdat.dtmvtolt)) THEN
            vr_dscritic := 'Contrato nao pode ser estornado.';
            RAISE vr_exc_saida;
          END IF;

          -- Vamos buscar todos os lancamentos que podem ser estornados
          FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrctremp => pr_nrctremp,
                                       pr_dtmvtolt => rw_crapepr.dtultpag,
                                       pr_dtultest => rw_crapepr.dtultest) LOOP

            -- Busca os dados da parcela
            OPEN cr_crappep(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_nrparepr => rw_craplem.nrparepr);
            FETCH cr_crappep
              INTO rw_crappep;
            -- Verifica se a retornou registro
            IF cr_crappep%NOTFOUND THEN
              CLOSE cr_crappep;
              vr_dscritic := 'Parcela nao encontrada' || '. Conta: ' || TO_CHAR(pr_nrdconta) ||
                             '. Contrato: ' || TO_CHAR(pr_nrctremp) || '. Parcela: ' ||
                             TO_CHAR(rw_craplem.nrparepr);
              RAISE vr_exc_saida;
            ELSE
              -- Apenas Fecha o Cursor
              CLOSE cr_crappep;
            END IF;

            vr_ind_estorno := pr_tab_lancto_parcelas.COUNT() + 1;
            pr_tab_lancto_parcelas(vr_ind_estorno).cdcooper := pr_cdcooper;
            pr_tab_lancto_parcelas(vr_ind_estorno).nrdconta := pr_nrdconta;
            pr_tab_lancto_parcelas(vr_ind_estorno).nrctremp := pr_nrctremp;
            pr_tab_lancto_parcelas(vr_ind_estorno).nrparepr := rw_craplem.nrparepr;
            pr_tab_lancto_parcelas(vr_ind_estorno).dtmvtolt := rw_craplem.dtmvtolt;
            pr_tab_lancto_parcelas(vr_ind_estorno).cdhistor := rw_craplem.cdhistor;
            pr_tab_lancto_parcelas(vr_ind_estorno).dtvencto := rw_crappep.dtvencto;
            pr_tab_lancto_parcelas(vr_ind_estorno).vllanmto := rw_craplem.vllanmto;
            pr_tab_lancto_parcelas(vr_ind_estorno).nrdrecid := rw_craplem.progress_recid;
            pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := TRUE;
            pr_tab_lancto_parcelas(vr_ind_estorno).dtpagemp := rw_craplem.dtpagemp;
            pr_tab_lancto_parcelas(vr_ind_estorno).txjurepr := NVL(rw_craplem.txjurepr, 0);
            pr_tab_lancto_parcelas(vr_ind_estorno).vlpreemp := NVL(rw_craplem.vlpreemp, 0);
            pr_tab_lancto_parcelas(vr_ind_estorno).vlpagpar := NVL(rw_craplem.vlpagpar, 0);

            /* Regra definida pelo Oscar, caso o Historico for igual ao historico de Estorno
            nao sera realizado o estorno do lancamento                                    */
            IF rw_craplem.cdhistor = rw_craplem.cdhisest THEN
              pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := FALSE;
            END IF;

          END LOOP; -- END FOR rw_craplem

          pr_des_reto := 'OK';

        EXCEPTION
          WHEN vr_exc_saida THEN

            IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;

            -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_nrsequen => 1 --> Fixo
                                 ,
                                  pr_cdcritic => 0,
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';
          WHEN OTHERS THEN
            pr_des_reto := 'NOK';
            -- Montar descri��o de erro n�o tratado
            vr_dscritic := 'Erro n�o tratado na EMPR0008.pc_busca_lancamentos_pagto ' || SQLERRM;
            -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_nrsequen => 1 --> Fixo
                                 ,
                                  pr_cdcritic => 0,
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);

        END;

      END pc_busca_lancamentos_pagto;

      -- Procedure Reponsavel por efetuar o estorno da parcela pago em dias diferentes
      PROCEDURE pc_efetua_estor_pgto_outro_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                              ,pr_cdagenci IN crapass.cdagenci%TYPE --> C�digo da ag�ncia
                                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do caixa
                                              ,pr_cdoperad IN crapdev.cdoperad%TYPE --> C�digo do Operador
                                              ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                              ,pr_idorigem IN INTEGER               --> Id do m�dulo de sistema
                                              ,pr_nrdconta IN crapepr.nrdconta%TYPE --> N�mero da conta
                                              ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                              ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                              ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                              ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                              ,pr_cdhisest IN craphis.cdhisest%TYPE --> Codigo do Historico de Estorno
                                              ,pr_vllanmto IN craplem.vllanmto%TYPE --> Valor do Lancamento
                                              ,pr_nrdrecid IN craplem.progress_recid%TYPE
                                              ,pr_dtpagemp IN craplem.dtpagemp%TYPE
                                              ,pr_txjurepr IN craplem.txjurepr%TYPE
                                              ,pr_vlpreemp IN craplem.vlpreemp%TYPE
                                              ,pr_des_reto OUT VARCHAR              --> Retorno OK / NOK
                                              ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
      BEGIN
        DECLARE
          -- Vari�vel de cr�ticas
          vr_cdcritic crapcri.cdcritic%TYPE;
          vr_dscritic VARCHAR2(10000);

          -- Tratamento de erros
          vr_exc_saida EXCEPTION;
        BEGIN

          -- A cada lancamento sera gravado a data que foi realizado o estorno
          BEGIN
            UPDATE craplem
               SET craplem.dtestorn = pr_dtmvtolt
             WHERE craplem.progress_recid = pr_nrdrecid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar na tabela de craplem. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Cria o lancamento de estorno
          EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper,
                                          pr_dtmvtolt => pr_dtmvtolt,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_cdbccxlt => 100,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdpactra => pr_cdagenci,
                                          pr_tplotmov => 5,
                                          pr_nrdolote => 600031,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_cdhistor => pr_cdhisest,
                                          pr_nrctremp => pr_nrctremp,
                                          pr_vllanmto => pr_vllanmto,
                                          pr_dtpagemp => pr_dtpagemp,
                                          pr_txjurepr => pr_txjurepr,
                                          pr_vlpreemp => pr_vlpreemp,
                                          pr_nrsequni => 0,
                                          pr_nrparepr => pr_nrparepr,
                                          pr_flgincre => FALSE,
                                          pr_flgcredi => FALSE,
                                          pr_nrseqava => 0,
                                          pr_cdorigem => pr_idorigem,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);

          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          pr_des_reto := 'OK';

        EXCEPTION
          WHEN vr_exc_saida THEN

            IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;

            -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_nrsequen => 1,
                                  pr_cdcritic => 0,
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);

            pr_des_reto := 'NOK';
          WHEN OTHERS THEN
            pr_des_reto := 'NOK';
            -- Montar descri��o de erro n�o tratado
            vr_dscritic := 'Erro n�o tratado na EMPR0008.pc_efetua_estor_pgto_outro_dia ' || SQLERRM;
            -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_nrsequen => 1,
                                  pr_cdcritic => 0,
                                  pr_dscritic => vr_dscritic,
                                  pr_tab_erro => pr_tab_erro);

        END;
      END pc_efetua_estor_pgto_outro_dia;

    BEGIN
      vr_tab_erro.DELETE;
      vr_tab_lancto_parcelas.DELETE;
      vr_tab_lancto_cc.DELETE;

      -- Cursor para verificar se � um Empr�stimo Consignado - P437
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
        INTO vr_flgconsig;
      CLOSE cr_crapepr;

      --Se for Consignado - P437
      IF nvl(vr_flgconsig, 0) = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Estorno Pagamento de consignado nao pode ser efetuado por este programa.';
        RAISE vr_exc_saida;
      END IF;

      -- Busca os lancamento que podem ser estornados para o contrato informado
      pc_busca_lancamentos_pagto(pr_cdcooper            => pr_cdcooper,
                                 pr_cdagenci            => pr_cdagenci,
                                 pr_nrdcaixa            => pr_nrdcaixa,
                                 pr_cdoperad            => pr_cdoperad,
                                 pr_nmdatela            => pr_nmdatela,
                                 pr_idorigem            => pr_idorigem,
                                 pr_nrdconta            => pr_nrdconta,
                                 pr_idseqttl            => pr_idseqttl,
                                 pr_nrctremp            => pr_nrctremp,
                                 pr_des_reto            => vr_des_reto,
                                 pr_tab_erro            => vr_tab_erro,
                                 pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);

      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      --Cria o registro do Estorno
      BEGIN
        INSERT INTO tbepr_estorno
          (cdcooper
          ,cdestorno
          ,nrdconta
          ,nrctremp
          ,cdoperad
          ,cdagenci
          ,dtestorno
          ,hrestorno
          ,dsjustificativa)
        VALUES
          (pr_cdcooper
          ,fn_sequence('TBEPR_ESTORNO', 'CDESTORNO', pr_cdcooper)
          ,pr_nrdconta
          ,pr_nrctremp
          ,pr_cdoperad
          ,pr_cdagenci
          ,pr_dtmvtolt
          ,gene0002.fn_busca_time
          ,pr_dsjustificativa)
        RETURNING tbepr_estorno.cdestorno INTO vr_cdestorno;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na tabela de tbepr_estorno. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Cursor para verificar se precisa fazer as baixas dos bens
      OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr
        INTO vr_existbpr;
      CLOSE cr_crapbpr;

      IF NVL(vr_existbpr, 0) > 0 THEN
        -- Solicita a baixa no gravames
        GRVM0001.pc_desfazer_baixa_automatica(pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => pr_nrdconta,
                                              pr_nrctrpro => pr_nrctremp,
                                              pr_des_reto => vr_des_reto,
                                              pr_tab_erro => vr_tab_erro);
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Buscar o erro encontrado para gravar na vr_des_erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;
        END IF;

      END IF; -- END IF NVL(vr_existbpr,0) > 0 THEN

      -- Percorre todos os lancamentos de acordo com a data de movimento
      FOR idx IN vr_tab_lancto_parcelas.FIRST .. vr_tab_lancto_parcelas.LAST LOOP
        vr_cdhislcm := 0; -- Historico de lancamento na conta corrente
        vr_vlpagpar := 0; -- Valor do Pagamento
        vr_vlpagmta := 0; -- Valor Pago na Multa
        vr_vlpagmra := 0; -- Valor Pago no Juros de Mora
        vr_vljuratr := 0; -- Valor do Juros em Atraso
        vr_vldescto := 0; -- Valor de Desconto

        -- Busca os dados da parcela
        OPEN cr_crappep(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                        pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                        pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                        pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_crappep
          INTO rw_crappep;
        -- Verifica se a retornou registro
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Parcela nao encontrada' ||
                         '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                         '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                         '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crappep;
        END IF;

        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                        pr_cdhistor => vr_tab_lancto_parcelas(idx).cdhistor);
        FETCH cr_craphis
          INTO vr_cdhisest;
        CLOSE cr_craphis;

        IF NVL(vr_cdhisest, 0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' ||
                         TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se o historico eh pagamento
        IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039, 1044, 1045, 1057) THEN
          -- Valor do Pagamento da Parcela
          vr_vlpagpar := NVL(vr_tab_lancto_parcelas(idx).vllanmto, 0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor IN (1045, 1057) THEN
            vr_cdhislcm := 1539;
          ELSE
            vr_cdhislcm := 108;
          END IF;

          -- Juros de Mora
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1619, 1077, 1620, 1078) THEN
          vr_vlpagmra := NVL(vr_tab_lancto_parcelas(idx).vllanmto, 0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1619 THEN
            vr_cdhislcm := 1543;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1077 THEN
            vr_cdhislcm := 1071;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1620 THEN
            vr_cdhislcm := 1544;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1078 THEN
            vr_cdhislcm := 1072;
          END IF;

          -- Multa
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1540, 1047, 1618, 1076) THEN
          vr_vlpagmta := NVL(vr_tab_lancto_parcelas(idx).vllanmto, 0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1540 THEN
            vr_cdhislcm := 1541;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1047 THEN
            vr_cdhislcm := 1060;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1618 THEN
            vr_cdhislcm := 1542;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1076 THEN
            vr_cdhislcm := 1070;
          END IF;

          -- Juros de Atraso
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1050, 1051) THEN
          vr_vljuratr := NVL(vr_tab_lancto_parcelas(idx).vllanmto, 0);

          -- Valor de Desconto
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1048, 1049) THEN
          vr_vldescto := NVL(vr_tab_lancto_parcelas(idx).vllanmto, 0);

        ELSE
          vr_dscritic := 'Historico nao permitido para efetuar o estorno. Codigo: ' ||
                         TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;

        END IF;

        -- Atualiza os dados da Parcela
        BEGIN
          UPDATE crappep
             SET crappep.vlpagpar = nvl(crappep.vlpagpar, 0) - nvl(vr_vlpagpar, 0)
                ,crappep.vlsdvpar = nvl(crappep.vlsdvpar, 0) + nvl(vr_vlpagpar, 0) -
                                    nvl(vr_vljuratr, 0) + nvl(vr_vldescto, 0)
                ,crappep.vlsdvsji = nvl(crappep.vlsdvsji, 0) + nvl(vr_vlpagpar, 0) -
                                    nvl(vr_vljuratr, 0) + nvl(vr_vldescto, 0)
                ,crappep.vldespar = nvl(crappep.vldespar, 0) - nvl(vr_vldescto, 0)
                ,crappep.vlpagjin = nvl(crappep.vlpagjin, 0) - nvl(vr_vljuratr, 0)
                ,crappep.inliquid = 0
                ,crappep.vlpagmra = nvl(crappep.vlpagmra, 0) - nvl(vr_vlpagmra, 0)
                ,crappep.vlpagmta = nvl(crappep.vlpagmta, 0) - nvl(vr_vlpagmta, 0)
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza os dados do Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vlpagpar
                ,crapepr.qtprepag = crapepr.qtprepag - DECODE(rw_crappep.inliquid, 1, 1, 0)
                ,crapepr.qtprecal = crapepr.qtprepag - DECODE(rw_crappep.inliquid, 1, 1, 0)
                ,crapepr.dtultest = pr_dtmvtolt
                ,crapepr.dtliquid = NULL
           WHERE crapepr.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crapepr.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crapepr.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        /* Lancamentos de Desconto e Juros de Atraso, sera apenas atualizado a data de estorno */
        IF vr_tab_lancto_parcelas(idx).flgestor = FALSE THEN
          BEGIN
            UPDATE craplem
               SET craplem.dtestorn = pr_dtmvtolt
             WHERE craplem.progress_recid = vr_tab_lancto_parcelas(idx).nrdrecid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela craplem. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Pula para o proximo lancamento
          CONTINUE;
        END IF;

        -- Sequencia da tabela de pagamentos das parcelas
        vr_cdlancamento := fn_sequence('TBEPR_ESTORNOLANCAMENTO',
                                       'CDLANCAMENTO',
                                       pr_cdcooper || ';' || vr_tab_lancto_parcelas(idx).nrdconta || ';' || vr_tab_lancto_parcelas(idx).nrctremp || ';' ||
                                       vr_cdestorno);

        BEGIN
          INSERT INTO tbepr_estornolancamento
            (cdcooper
            ,nrdconta
            ,nrctremp
            ,cdestorno
            ,cdlancamento
            ,nrparepr
            ,dtvencto
            ,dtpagamento
            ,vllancamento
            ,cdhistor)
          VALUES
            (pr_cdcooper
            ,vr_tab_lancto_parcelas(idx).nrdconta
            ,vr_tab_lancto_parcelas(idx).nrctremp
            ,vr_cdestorno
            ,vr_cdlancamento
            ,vr_tab_lancto_parcelas(idx).nrparepr
            ,vr_tab_lancto_parcelas(idx).dtvencto
            ,vr_tab_lancto_parcelas(idx).dtmvtolt
            ,vr_tab_lancto_parcelas(idx).vllanmto
            ,vr_tab_lancto_parcelas(idx).cdhistor);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela de tbepr_estornolancamento. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Condicao para estornar o pagamento efetuado no mesmo dia
        IF vr_tab_lancto_parcelas(idx).dtmvtolt = pr_dtmvtolt THEN

          EMPR0008.pc_efetua_estor_pgto_no_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                                               pr_cdagenci => pr_cdagenci,
                                               pr_nrdcaixa => pr_nrdcaixa,
                                               pr_cdoperad => pr_cdoperad,
                                               pr_nmdatela => pr_nmdatela,
                                               pr_idorigem => pr_idorigem,
                                               pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                                               pr_idseqttl => pr_idseqttl,
                                               pr_dtmvtolt => vr_tab_lancto_parcelas(idx).dtmvtolt,
                                               pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                                               pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr,
                                               pr_des_reto => vr_des_reto,
                                               pr_tab_erro => vr_tab_erro);

          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Condicao para estornar o pagamento retroativo
        ELSE
          pc_efetua_estor_pgto_outro_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                                         pr_cdagenci => pr_cdagenci,
                                         pr_nrdcaixa => pr_nrdcaixa,
                                         pr_cdoperad => pr_cdoperad,
                                         pr_nmdatela => pr_nmdatela,
                                         pr_idorigem => pr_idorigem,
                                         pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                                         pr_idseqttl => pr_idseqttl,
                                         pr_dtmvtolt => pr_dtmvtolt,
                                         pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                                         pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr,
                                         pr_cdhisest => vr_cdhisest,
                                         pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto,
                                         pr_nrdrecid => vr_tab_lancto_parcelas(idx).nrdrecid,
                                         pr_dtpagemp => vr_tab_lancto_parcelas(idx).dtpagemp,
                                         pr_txjurepr => vr_tab_lancto_parcelas(idx).txjurepr,
                                         pr_vlpreemp => vr_tab_lancto_parcelas(idx).vlpreemp,
                                         pr_des_reto => vr_des_reto,
                                         pr_tab_erro => vr_tab_erro);

          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Armazena o Valor estornado para fazer um unico lancamento em Conta Corrente
          EMPR0008.pc_cria_atualiza_ttlanconta(pr_cdcooper      => vr_tab_lancto_parcelas(idx).cdcooper,
                                               pr_nrctremp      => vr_tab_lancto_parcelas(idx).nrctremp,
                                               pr_cdhistor      => vr_cdhislcm,
                                               pr_dtmvtolt      => pr_dtmvtolt,
                                               pr_cdoperad      => pr_cdoperad,
                                               pr_cdpactra      => pr_cdagenci,
                                               pr_nrdolote      => 600031,
                                               pr_nrdconta      => vr_tab_lancto_parcelas(idx).nrdconta,
                                               pr_vllanmto      => vr_tab_lancto_parcelas(idx).vllanmto,
                                               pr_nrseqava      => 0,
                                               pr_tab_lancconta => vr_tab_lancto_cc,
                                               pr_des_erro      => vr_des_reto,
                                               pr_dscritic      => vr_dscritic);
          IF vr_des_reto = 'NOK' THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;

        -- Inicio -- PRJ577 -- EST25314
        IF empr0021.fn_contrato_renegociado(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                                            pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                                            pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp) THEN

          empr0021.pc_estorna_sld_ctr_renegociado(pr_dtpagmto => vr_tab_lancto_parcelas(idx).dtpagemp,
                                                  pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                                                  pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                                                  pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;
        -- Fim -- PRJ577 -- EST25314

        -- Busca a data do ultimo pagamento da parcela
        OPEN cr_craplem_max(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                            pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                            pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                            pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_craplem_max
          INTO vr_dtultpag;
        CLOSE cr_craplem_max;

        -- Atualiza a data de pagamento da ultima parcela paga
        BEGIN
          UPDATE crappep
             SET crappep.dtultpag = vr_dtultpag
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END LOOP; /* END FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP */

      -- Vamos verificar se os valores das parcelas ficaram com saldos negativos
      OPEN cr_crappep_saldo(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_saldo
        INTO vr_flgnegat;
      CLOSE cr_crappep_saldo;

      IF NVL(vr_flgnegat, 0) = 1 THEN
        vr_cdcritic := 968;
        RAISE vr_exc_saida;
      END IF;

      -- Busca a data do ultimo pagamento do Emprestimo
      OPEN cr_crappep_max_pagto(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_max_pagto
        INTO vr_dtultpag;
      CLOSE cr_crappep_max_pagto;

      -- Busca a data do primeiro vencimento da parcela nao pago
      OPEN cr_crappep_min_dtvencto(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_min_dtvencto
        INTO vr_dtvencto;
      CLOSE cr_crappep_min_dtvencto;

      -- Atualiza os dados do Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtultpag = vr_dtultpag
              ,crapepr.dtdpagto = vr_dtvencto
              ,crapepr.inliquid = 0
              ,crapepr.dtliquid = NULL
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      --Percorrer os Lancamentos
      vr_index_lanc := vr_tab_lancto_cc.FIRST;
      WHILE vr_index_lanc IS NOT NULL LOOP

        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                        pr_cdhistor => vr_tab_lancto_cc(vr_index_lanc).cdhistor);
        FETCH cr_craphis
          INTO vr_cdhisest;
        CLOSE cr_craphis;

        IF NVL(vr_cdhisest, 0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' ||
                         TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdhistor);
          RAISE vr_exc_saida;
        END IF;

        --> Verificar se conta nao est� em prejuizo
        IF NOT PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN

          /* Lanca em C/C e atualiza o lote */
          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                                         pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt,
                                         pr_cdagenci => vr_tab_lancto_cc(vr_index_lanc).cdagenci,
                                         pr_cdbccxlt => vr_tab_lancto_cc(vr_index_lanc).cdbccxlt,
                                         pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad,
                                         pr_cdpactra => vr_tab_lancto_cc(vr_index_lanc).cdpactra,
                                         pr_nrdolote => vr_tab_lancto_cc(vr_index_lanc).nrdolote,
                                         pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta,
                                         pr_cdhistor => vr_cdhisest,
                                         pr_vllanmto => vr_tab_lancto_cc(vr_index_lanc).vllanmto,
                                         pr_nrparepr => 0,
                                         pr_nrctremp => vr_tab_lancto_cc(vr_index_lanc).nrctremp,
                                         pr_nrseqava => vr_tab_lancto_cc(vr_index_lanc).nrseqava,
                                         pr_des_reto => vr_des_reto,
                                         pr_tab_erro => vr_tab_erro);

          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;

        ELSE

          --> Caso esteja o credito de estono deve ser direcionado ao bloqueio prejuizo
          PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper, --> Cooperativa conectada
                                        pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta, --> N�mero da conta,
                                        pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad, --> C�digo do Operador,
                                        pr_vlrlanc  => vr_tab_lancto_cc(vr_index_lanc).vllanmto, --> Valor da parcela emprestimo,
                                        pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt, --> Movimento atual
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;
        --Proximo registro
        vr_index_lanc := vr_tab_lancto_cc.NEXT(vr_index_lanc);
      END LOOP;
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Desfaz a Transacao
        ROLLBACK;
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Desfaz a Transacao
        ROLLBACK;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_estornar_pagamentos: ' || SQLERRM;
    END;
  END pc_tela_estornar_pagamentos;
BEGIN
  FOR rw_crapepr_est IN cr_crapepr_est LOOP
    pc_tela_estornar_pagamentos(pr_cdcooper        => rw_crapepr_est.cdcooper,
                                pr_cdagenci        => rw_crapepr_est.cdagenci,
                                pr_nrdcaixa        => 100,
                                pr_cdoperad        => 1,
                                pr_nmdatela        => 'ESTORN',
                                pr_idorigem        => 7,
                                pr_nrdconta        => rw_crapepr_est.nrdconta,
                                pr_idseqttl        => 1,
                                pr_dtmvtolt        => rw_crapepr_est.dtmvtolt,
                                pr_dtmvtopr        => rw_crapepr_est.dtmvtolt,
                                pr_nrctremp        => rw_crapepr_est.nrctremp,
                                pr_dsjustificativa => 'Regulariza��o de conta estourada indevidamente',
                                pr_cdcritic        => vr_cdcritic,
                                pr_dscritic        => vr_dscritic);

    vr_log := vr_log || 'Cooperativa: ' || rw_crapepr_est.cdcooper ||
                           ' Ag�ncia: ' || rw_crapepr_est.cdagenci ||
                             ' Conta: ' || rw_crapepr_est.nrdconta ||
                          ' Contrato: ' || rw_crapepr_est.nrctremp ||
                              ' Data: ' || rw_crapepr_est.dtultpag ||
                           ' Retorno: ';

    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_log := vr_log || vr_cdcritic || ' - ' || vr_dscritic;
    ELSE
      vr_log := vr_log || 'OK';
    END IF;

    vr_log := vr_log || chr(10);
  END LOOP;

  gene0002.pc_clob_para_arquivo(pr_clob     => vr_log
                               ,pr_caminho  => '/micros/cecred/odirlei/'
                               ,pr_arquivo  => 'Log_INC0100712.txt'
                               ,pr_des_erro => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
EXCEPTION
  WHEN vr_exc_saida THEN
    raise_application_error(-20500, 'Erro ao gerar arquivo de log: ' || vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20500, 'Erro ao executar script: ' || SQLERRM);
END;
