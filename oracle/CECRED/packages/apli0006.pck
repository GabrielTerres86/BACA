CREATE OR REPLACE PACKAGE CECRED.apli0006 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0006
  --  Sistema  : Rotinas genericas referente a calculos de aplicacao
  --  Sigla    : APLI
  --  Autor    : Jean Michel - CECRED
  --  Data     : Julho - 2014.                   Ultima atualizacao: 27/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas referente a calculos de aplicacao

  -- Alteracoes: 19/08/2014 - Inclusao das procedures pc_taxa_acumulada_aplicacao_pos
  --                          e pc_taxa_acumulada_aplicacao_pre (Jean Michel).
  --
  --             27/07/2018 - P411.2 Tratamento das rotinas de Poupança Programada X Aplicação Programada
  --                          Cláudio - CIS Corporate
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina referente a atualizar saldo de aplicacoes de aplicacao pós
  PROCEDURE pc_posicao_saldo_aplicacao_pos(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                          ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                          ,pr_dtiniapl IN craprac.dtmvtolt%TYPE --> Data de Início da Aplicação
                                          ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                          ,pr_idtxfixa IN PLS_INTEGER           --> Taxa Fixa (1-SIM/2-NAO)
                                          ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                          ,pr_qtdiacar IN craprac.qtdiacar%TYPE --> Dias de Carência
                                          ,pr_idgravir IN PLS_INTEGER           --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                          ,pr_idaplpgm IN PLS_INTEGER DEFAULT 0 --> Aplicacao Programada (0-Não/1-Sim)
                                          ,pr_dtinical IN DATE                  --> Data Inicial Cálculo
                                          ,pr_dtfimcal IN DATE                  --> Data Final Cálculo
                                          ,pr_idtipbas IN PLS_INTEGER           --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                          ,pr_vlbascal IN OUT NUMBER            --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                          ,pr_vlsldtot OUT NUMBER               --> Saldo Total da Aplicação
                                          ,pr_vlsldrgt OUT NUMBER               --> Saldo Total para Resgate
                                          ,pr_vlultren OUT NUMBER               --> Valor Último Rendimento
                                          ,pr_vlrentot OUT NUMBER               --> Valor Rendimento Total
                                          ,pr_vlrevers OUT NUMBER               --> Valor de Reversão
                                          ,pr_vlrdirrf OUT NUMBER               --> Valor do IRRF
                                          ,pr_percirrf OUT NUMBER               --> Percentual do IRRF
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente a atualizar saldo de aplicacoes de aplicacao pre
  PROCEDURE pc_posicao_saldo_aplicacao_pre(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                          ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                          ,pr_dtiniapl IN craprac.dtmvtolt%TYPE --> Data de Início da Aplicação
                                          ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                          ,pr_idtxfixa IN PLS_INTEGER           --> Taxa Fixa (1-SIM/2-NAO)
                                          ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                          ,pr_qtdiacar IN craprac.qtdiacar%TYPE --> Dias de Carência
                                          ,pr_idgravir IN PLS_INTEGER           --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                          ,pr_idaplpgm IN PLS_INTEGER DEFAULT 0 --> Aplicacao Programada (0-Não/1-Sim)
                                          ,pr_dtinical IN DATE                  --> Data Inicial Cálculo
                                          ,pr_dtfimcal IN DATE                  --> Data Final Cálculo
                                          ,pr_idtipbas IN PLS_INTEGER           --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                          ,pr_vlbascal IN OUT NUMBER            --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                          ,pr_vlsldtot OUT NUMBER               --> Saldo Total da Aplicação
                                          ,pr_vlsldrgt OUT NUMBER               --> Saldo Total para Resgate
                                          ,pr_vlultren OUT NUMBER               --> Valor Último Rendimento
                                          ,pr_vlrentot OUT NUMBER               --> Valor Rendimento Total
                                          ,pr_vlrevers OUT NUMBER               --> Valor de Reversão
                                          ,pr_vlrdirrf OUT NUMBER               --> Valor do IRRF
                                          ,pr_percirrf OUT NUMBER               --> Percentual do IRRF
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente a calculo da taxa acumulada das aplicações pós-fixadas
  PROCEDURE pc_taxa_acumul_aplic_pos(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                    ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                    ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                    ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                    ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                    ,pr_txacumul OUT NUMBER               --> Taxa acumulada durante o período total da aplicação
                                    ,pr_txacumes OUT NUMBER               --> Taxa acumulada durante o mês vigente
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente a calculo da taxa acumulada das aplicações pré-fixadas
  PROCEDURE pc_taxa_acumul_aplic_pre(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                    ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                    ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                    ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                    ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                    ,pr_txacumul OUT NUMBER               --> Taxa acumulada durante o período total da aplicação
                                    ,pr_txacumes OUT NUMBER               --> Taxa acumulada durante o mês vigente
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina referente a calculo da taxa acumulada das aplicações pré-fixadas
  PROCEDURE pc_valor_base_resgate(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_nrdconta IN craprac.nrdconta%TYPE --> Conta do Cooperado
                                 ,pr_idtippro IN crapcpc.idtippro%TYPE --> Tipo do Produto da Aplicação
                                 ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                 ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                 ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                 ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                 ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                 ,pr_vlresgat IN craprga.vlresgat%TYPE --> Valor do Resgate
                                 ,pr_percirrf IN NUMBER                --> Percentual de IRRF
                                 ,pr_vlbasrgt OUT NUMBER               --> Valor Base do Resgate
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
END apli0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.apli0006 IS

  -- Rotina referente a calculo para obter saldo atualizado de aplicacao pós
  PROCEDURE pc_posicao_saldo_aplicacao_pos(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                          ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                          ,pr_dtiniapl IN craprac.dtmvtolt%TYPE --> Data de Início da Aplicação
                                          ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                          ,pr_idtxfixa IN PLS_INTEGER           --> Taxa Fixa (1-SIM/2-NAO)
                                          ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                          ,pr_qtdiacar IN craprac.qtdiacar%TYPE --> Dias de Carência
                                          ,pr_idgravir IN PLS_INTEGER           --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                          ,pr_idaplpgm IN PLS_INTEGER DEFAULT 0 --> Aplicacao Programada (0-Não/1-Sim)
                                          ,pr_dtinical IN DATE                  --> Data Inicial Cálculo
                                          ,pr_dtfimcal IN DATE                  --> Data Final Cálculo
                                          ,pr_idtipbas IN PLS_INTEGER           --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                          ,pr_vlbascal IN OUT NUMBER            --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                          ,pr_vlsldtot OUT NUMBER               --> Saldo Total da Aplicação
                                          ,pr_vlsldrgt OUT NUMBER               --> Saldo Total para Resgate
                                          ,pr_vlultren OUT NUMBER               --> Valor Último Rendimento
                                          ,pr_vlrentot OUT NUMBER               --> Valor Rendimento Total
                                          ,pr_vlrevers OUT NUMBER               --> Valor de Reversão
                                          ,pr_vlrdirrf OUT NUMBER               --> Valor do IRRF
                                          ,pr_percirrf OUT NUMBER               --> Percentual do IRRF
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_posicao_saldo_aplicacao_pos
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 15/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a calculo para obter saldo atualizado de aplicacoes pos.

     Observacao: -----

     Alteracoes: 15/07/2018 - Inclusao de novo parametro para indicao de apl. programada
                              Cláudio - CIS Corporate
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_null  EXCEPTION;

      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_dtinical DATE; -- Data do inicio da aplicacao
      vr_dtfimcal DATE; -- Data do fim do periodo
      vr_dtperiod DATE; -- Data inicial do periodo
      vr_dtpertxi DATE; -- Data Periodo da taxa
      vr_dtultdia DATE; -- Ultimo dia util do mes
      vr_txperiod NUMBER(20,8) := 0; -- Valor da taxa do periodo
      vr_txfixper NUMBER(20,8) := 0; -- Valor da taxa fixa do periodo
      vr_txacumul NUMBER(20,8) := 0; -- Valor da taxa acumulada
      vr_vlrendim NUMBER(20,8) := 0; -- Valor do rendimento
      vr_vlsldtot NUMBER(20,8) := 0; -- Valor de saldo total
      vr_vlrentot NUMBER(20,8) := 0; -- Valor do rendimento total
      vr_vlprovis NUMBER(20,8) := 0; -- Valor de lancamento de provisoes
      vr_vlrevers NUMBER(20,8) := 0; -- Valor de lancamento de reversoes

      vr_flgimune BOOLEAN; -- Imunidade tributaria
      vr_flgrvvlr BOOLEAN; -- Indica gravacao de registro

      vr_dsreturn VARCHAR2(10); -- Retorno de procedure;

      vr_tab_erro gene0001.typ_tab_erro;
      -- Selecionar dados da aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação (craprac.nraplica)
                        ) IS

        SELECT rac.vlsldatl, rac.dtatlsld, rac.cdprodut, rac.vlbasapl, rac.dtmvtolt, rac.nraplica, rac.vlaplica, rac.idsaqtot
          FROM craprac rac
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nraplica = pr_nraplica;

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar valores de taxa do indexador
      CURSOR cr_craptxi(pr_cddindex IN crapind.cddindex%TYPE --> Código do indexador
                       ,pr_dtperiod IN craptxi.dtiniper%TYPE --> Data doperiodo
                        ) IS

        SELECT ind.idexpres, txi.vlrdtaxa
          FROM crapind ind, craptxi txi
         WHERE ind.cddindex = pr_cddindex
           AND txi.cddindex = ind.cddindex
           AND txi.dtiniper = pr_dtperiod
           AND txi.dtfimper = pr_dtperiod;

      rw_craptxi cr_craptxi%ROWTYPE;

      -- Consulta de historico de provisoes e revesao
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS

        SELECT
          cpc.cdhsprap, cpc.cdhsrvap, ind.idperiod
        FROM
          crapcpc cpc, crapind ind
        WHERE
              cpc.cdprodut = pr_cdprodut
          AND ind.cddindex = cpc.cddindex;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Verifica provisoes
      CURSOR cr_craplac(pr_cdcooper IN craplac.cdcooper%TYPE,
                        pr_nrdconta IN craplac.nrdconta%TYPE,
                        pr_nraplica IN craplac.nraplica%TYPE,
                        pr_cdhsprap IN crapcpc.cdhsprap%TYPE,
                        pr_cdhsrvap IN crapcpc.cdhsrvap%TYPE) IS

        SELECT lac.cdhistor, lac.vllanmto
          FROM craplac lac
         WHERE lac.cdcooper = pr_cdcooper
           AND lac.nrdconta = pr_nrdconta
           AND lac.nraplica = pr_nraplica
           AND lac.cdhistor IN (pr_cdhsprap, pr_cdhsrvap);

      rw_craplac cr_craplac%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Inicializar parametros de saída
      pr_vlsldtot := 0;
      pr_vlsldrgt := 0;
      pr_vlultren := 0;
      pr_vlrentot := 0;
      pr_vlrevers := 0;
      pr_vlrdirrf := 0;
      pr_percirrf := 0;
                                          
      vr_dtfimcal := pr_dtfimcal;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Consulta dados da aplicacao
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nraplica => pr_nraplica);

      FETCH cr_craprac INTO rw_craprac;

      IF cr_craprac%NOTFOUND THEN
        CLOSE cr_craprac;
        vr_dscritic := 'Erro ao consultar dados da aplicacao.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craprac;
      END IF;

      -- Leitura de produtos
      OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto ' || rw_craprac.cdprodut || ' nao cadastrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      -- Verificacao de datas
      IF rw_craprac.dtmvtolt = rw_crapdat.dtmvtolt AND
         rw_crapdat.dtmvtolt = vr_dtfimcal      THEN

        pr_vlsldtot := rw_craprac.vlaplica;
        pr_vlsldrgt := rw_craprac.vlaplica;

        RAISE vr_exc_null;

      END IF;
      
      -- Aplicacao encerrada
      IF  rw_craprac.idsaqtot > 0  THEN
        pr_vlsldtot := 0;
        pr_vlsldrgt := 0;
        
        RAISE vr_exc_null;
      END IF;

      -- Verifica a quantidade de dias para saber o IR
      vr_qtdiasir := vr_dtfimcal - pr_dtiniapl;

      -- Consulta faixas de IR
      apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

      FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
        IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
          pr_percirrf := NVL(apli0001.vr_faixa_ir_rdc(i).perirtab,0);
        END IF;

      END LOOP;

      IF NVL(pr_percirrf,0) = 0 AND pr_cdcooper <> 3 THEN
        vr_dscritic := 'Faixa de IRRF nao encontrada.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica Base Cálculo Total
      IF pr_idtipbas = 2 THEN        
        pr_vlbascal := rw_craprac.vlsldatl; -- Saldo atualizado
        vr_dtinical := rw_craprac.dtatlsld; -- Data de atualização do saldo        
      ELSIF pr_idtipbas = 1 THEN
        -- Verifica Base Cálculo Parcial
        vr_dtinical := pr_dtinical; -- Data de atualização do saldo
      END IF;

      vr_vlsldtot := pr_vlbascal;
      vr_dtperiod := vr_dtinical;

      IF vr_vlsldtot IS NULL OR
         vr_vlsldtot <= 0 THEN

        vr_dscritic := 'Saldo nao informado.';
        RAISE vr_exc_saida;

      END IF;

      WHILE vr_dtperiod < vr_dtfimcal LOOP
        -- Verifica se e final de semana ou feriado
        IF to_char(vr_dtperiod, 'D') NOT IN (1, 7) AND
           NOT flxf0001.fn_verifica_feriado(pr_cdcooper, vr_dtperiod) THEN

          IF rw_crapcpc.idperiod = 1 THEN --> Taxa Cadastrada Diariamente
            vr_dtpertxi := vr_dtperiod;
          ELSIF rw_crapcpc.idperiod = 2 THEN --> Taxa Cadastrada Mensalmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'MM');
          ELSIF rw_crapcpc.idperiod = 3 THEN --> Taxa Cadastrada Anualmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'YY');
          ELSE
            vr_dscritic := 'Periodicidade de cadastro da taxa do indexador '
                           || pr_cddindex || ' invalido.';
            RAISE vr_exc_saida;
          END IF;

          -- Consulta de taxa
          OPEN cr_craptxi(pr_cddindex => pr_cddindex   --> Código do indexador
                         ,pr_dtperiod => vr_dtpertxi); --> Data da taxa

          FETCH cr_craptxi
            INTO rw_craptxi;

          IF cr_craptxi%NOTFOUND THEN
            CLOSE cr_craptxi;
            vr_dscritic := 'Taxa do indexador ' || pr_cddindex ||
                           ' nao cadastrada. Periodo: ' || TO_CHAR(vr_dtpertxi,'dd/mm/RRRR');
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craptxi;
          END IF;

          -- Se a taxa for expressa ao mês, a taxa deve ser capitalizada ao ano.
          IF rw_craptxi.idexpres = 1 THEN
            vr_txperiod := ROUND((POWER((rw_craptxi.vlrdtaxa / 100) + 1, 12) - 1) * 100, 8); -- Taxa Expressa Ao Mês
          ELSE
            vr_txperiod := rw_craptxi.vlrdtaxa; -- Taxa Expressa Ao Ano
          END IF;

          -- Taxa do indexador deverá estar descapitalizada ao dia, pois o rendimento é calculado diariamente
          vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);

          -- Se o produto utilizar taxa fixa, essa taxa também deve ser descapitalizada ao dia e acrescentada a taxa do período
          IF pr_idtxfixa = 1 THEN -- Taxa Fixa
            vr_txfixper := ROUND((POWER((pr_txaplica / 100) + 1, 1 / 252) - 1), 8);
            vr_txperiod := ROUND((((vr_txperiod + 1) * (vr_txfixper + 1)) - 1), 8);
          ELSIF pr_idtxfixa = 2 THEN -- Sem Taxa Fixa / Se não existe taxa fixa no produto, a taxa utilizada no período deve ser obtida com base na taxa contratada
            vr_txperiod := ROUND(vr_txperiod * (pr_txaplica / 100), 8);
          END IF;

          -- Rendimento calculado com base no saldo da aplicação
          IF vr_txacumul = 0 THEN
            vr_txacumul := ROUND(vr_txperiod, 8);
          ELSE
            vr_txacumul := ROUND(((vr_txacumul + 1) * (vr_txperiod + 1)) - 1,
                                 8);
          END IF;

          vr_vlrendim := ROUND(vr_vlsldtot * vr_txperiod, 6);
          vr_vlsldtot := ROUND(vr_vlsldtot + vr_vlrendim, 6);
          vr_vlrentot := ROUND(vr_vlrentot + vr_vlrendim, 6);

        END IF;

        -- Incrementa data
        vr_dtperiod := vr_dtperiod + 1;

        -- Verifica ultimo dia util do mes
        vr_dtultdia := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => LAST_DAY(vr_dtperiod)
                                                  ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês

        -- Se for ultimo dia util do mes, arredonda os valores de saldo e rendimento
        IF vr_dtperiod = vr_dtultdia THEN
          vr_vlsldtot := ROUND(vr_vlsldtot, 2); -- Valor de saldo
        END IF;

      END LOOP;

      vr_vlsldtot := ROUND(vr_vlsldtot, 2);
      vr_vlrentot := ROUND(vr_vlrentot, 2);

      -- Verifica base de calculo
      IF pr_idtipbas = 2 THEN
        -- Base Cálculo Total

        OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

        FETCH cr_crapcpc
          INTO rw_crapcpc;

        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Historicos de Provisao e Reversao nao cadastrados para produto: ' ||
                         rw_craprac.cdprodut;
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_crapcpc;

          -- Consulta lancamento da aplicacao
          OPEN cr_craplac(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nraplica => pr_nraplica,
                          pr_cdhsprap => rw_crapcpc.cdhsprap,
                          pr_cdhsrvap => rw_crapcpc.cdhsrvap);

          LOOP

            FETCH cr_craplac INTO rw_craplac;
            EXIT WHEN cr_craplac%NOTFOUND;

            IF rw_craplac.cdhistor = rw_crapcpc.cdhsprap THEN
              -- Historico de Provisão
              vr_vlprovis := vr_vlprovis + rw_craplac.vllanmto;
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrvap THEN
              -- Historico de Reversão
              vr_vlrevers := vr_vlrevers + rw_craplac.vllanmto;
            END IF;

          END LOOP;

          CLOSE cr_craplac;

        END IF;

        pr_vlultren := vr_vlrentot;
        pr_vlrentot := (vr_vlprovis - vr_vlrevers) + vr_vlrentot;
        pr_vlrevers := pr_vlrentot;

        -- Verifica se a aplicação estiver na carência e o resgate for total
        IF vr_qtdiasir < pr_qtdiacar THEN
          pr_vlsldtot := rw_craprac.vlbasapl;
          pr_vlsldrgt := rw_craprac.vlbasapl;
          pr_vlrentot := 0;
          pr_vlrdirrf := 0;
          pr_vlbascal := rw_craprac.vlbasapl;

        END IF;

      ELSIF pr_idtipbas = 1 THEN
        -- Base Cálculo Parcial

        pr_vlultren := vr_vlrentot;
        pr_vlrentot := vr_vlrentot;
        pr_vlrevers := vr_vlrentot;

        -- Verifica se a aplicação estiver na carência e o resgate for parcial
        IF vr_qtdiasir < pr_qtdiacar THEN
          pr_vlsldtot := pr_vlbascal;
          pr_vlsldrgt := pr_vlbascal;
          pr_vlrentot := 0;
          pr_vlrdirrf := 0;

        END IF;

      END IF;

      -- Os cálculos abaixo deverão ser executados somente a aplicação passou o período de carência
      IF vr_qtdiasir >= pr_qtdiacar THEN

        -- O valor do IRRF deve ser calculado com base no rendimento total
        pr_vlrdirrf := ROUND(pr_vlrentot * (pr_percirrf / 100), 2);

        -- Independente do tipo da base de cálculo, o saldo total da aplicação será o valor da variável vr_vlsldtot
        pr_vlsldtot := vr_vlsldtot;

        IF pr_idgravir = 1 THEN
          vr_flgrvvlr := TRUE;
        ELSE
          vr_flgrvvlr := FALSE;
        END IF;

        -- Verifica imunidade tributaria
        IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                            pr_flgrvvlr => vr_flgrvvlr,
                                            pr_cdinsenc => 5,
                                            pr_vlinsenc => pr_vlrdirrf,
                                            pr_flgimune => vr_flgimune,
                                            pr_dsreturn => vr_dsreturn,
                                            pr_tab_erro => vr_tab_erro);

        -- Verifica se houve erro na consulta de imunidade tributaria
        IF vr_dsreturn <> 'OK' THEN
          vr_dscritic := 'Erro ao verificar imunidade tributaria.';
          RAISE vr_exc_saida;
        END IF;

        -- Verifica imunidade tributaria
        IF vr_flgimune THEN
          -- Imune a tributacao
          pr_vlrdirrf := 0;
        END IF;

        -- Saldo para resgate com deducao de IRRF
        pr_vlsldrgt := pr_vlsldtot - pr_vlrdirrf;

        -- Se for base de cálculo total, o valor base retornado deve ser o saldo da aplicação subtraído o valor de reversão
        IF pr_idtipbas = 2 THEN
          pr_vlbascal := pr_vlsldtot - pr_vlrevers;
        END IF;

        -- Se a base for parcial, retornar o valor base proporcional ao resgate, conforme imunidade tributária
        IF NOT vr_flgimune THEN
          -- Imune a tributacao
          pr_vlbascal := round(pr_vlbascal /
                               (1 +
                               (vr_txacumul * (1 - (pr_percirrf / 100)))),
                               2);
        ELSE
          pr_vlbascal := round(pr_vlbascal / (1 + vr_txacumul), 2);
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Calculos de Aplicacao POS: ' || SQLERRM;
    END;

  END pc_posicao_saldo_aplicacao_pos;

  -- Rotina referente a calculo para obter saldo atualizado de aplicacao pre
  PROCEDURE pc_posicao_saldo_aplicacao_pre(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                          ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                          ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                          ,pr_dtiniapl IN craprac.dtmvtolt%TYPE --> Data de Início da Aplicação
                                          ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                          ,pr_idtxfixa IN PLS_INTEGER           --> Taxa Fixa (1-SIM/2-NAO)
                                          ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                          ,pr_qtdiacar IN craprac.qtdiacar%TYPE --> Dias de Carência
                                          ,pr_idgravir IN PLS_INTEGER           --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                          ,pr_idaplpgm IN PLS_INTEGER DEFAULT 0 --> Aplicacao Programada (0-Não/1-Sim)
                                          ,pr_dtinical IN DATE                  --> Data Inicial Cálculo
                                          ,pr_dtfimcal IN DATE                  --> Data Final Cálculo
                                          ,pr_idtipbas IN PLS_INTEGER           --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                          ,pr_vlbascal IN OUT NUMBER            --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                          ,pr_vlsldtot OUT NUMBER               --> Saldo Total da Aplicação
                                          ,pr_vlsldrgt OUT NUMBER               --> Saldo Total para Resgate
                                          ,pr_vlultren OUT NUMBER               --> Valor Último Rendimento
                                          ,pr_vlrentot OUT NUMBER               --> Valor Rendimento Total
                                          ,pr_vlrevers OUT NUMBER               --> Valor de Reversão
                                          ,pr_vlrdirrf OUT NUMBER               --> Valor do IRRF
                                          ,pr_percirrf OUT NUMBER               --> Percentual do IRRF
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_posicao_saldo_aplicacao_pre
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 16/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a calculo para obter saldo atualizado de aplicacoes pre.

     Observacao: -----

     Alteracoes: 15/07/2018 - Inclusao de novo parametro para indicao de apl. programada
                              Cláudio - CIS Corporate

    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_null  EXCEPTION;

      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_dtinical DATE; -- Data do inicio da aplicacao
      vr_dtfimcal DATE; -- Data do fim do periodo
      vr_dtperiod DATE; -- Data inicial do periodo
	    vr_dtpertxi DATE; -- Data Periodo da taxa
      vr_dtultdia DATE; -- Ultimo dia util do mes
      vr_txperiod NUMBER(20,8) := 0; -- Valor da taxa do periodo
      vr_txfixper NUMBER(20,8) := 0; -- Valor da taxa fixa do periodo
      vr_txacumul NUMBER(20,8) := 0; -- Valor da taxa acumulada
      vr_vlrendim NUMBER(20,8) := 0; -- Valor do rendimento
      vr_vlsldtot NUMBER(20,8) := 0; -- Valor de saldo total
      vr_vlrentot NUMBER(20,8) := 0; -- Valor do rendimento total
      vr_vlprovis NUMBER(20,8) := 0; -- Valor de lancamento de provisoes
      vr_vlrevers NUMBER(20,8) := 0; -- Valor de lancamento de reversoes

      vr_flgimune BOOLEAN; -- Imunidade tributaria
      vr_flgrvvlr BOOLEAN; -- Indica gravacao de registro

      vr_dsreturn VARCHAR2(10); -- Retorno de procedure;

      vr_tab_erro gene0001.typ_tab_erro;
      -- Selecionar dados da aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação (craprac.nraplica)
                        ) IS

        SELECT rac.vlsldatl, rac.dtatlsld, rac.cdprodut, rac.vlbasapl, rac.dtmvtolt, rac.nraplica, rac.vlaplica, rac.idsaqtot
          FROM craprac rac
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nraplica = pr_nraplica;

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar valores de taxa do indexador
      CURSOR cr_craptxi(pr_cddindex IN crapind.cddindex%TYPE --> Código do indexador
                       ,pr_dtperiod IN craptxi.dtiniper%TYPE --> Data doperiodo
                        ) IS

        SELECT ind.idexpres, txi.vlrdtaxa
          FROM crapind ind, craptxi txi
         WHERE ind.cddindex = pr_cddindex
           AND txi.cddindex = ind.cddindex
           AND txi.dtiniper = pr_dtperiod
           AND txi.dtfimper = pr_dtperiod;

      rw_craptxi cr_craptxi%ROWTYPE;

      -- Consulta de historico de provisoes e revesao
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS

        SELECT cpc.cdhsprap, cpc.cdhsrvap, ind.idperiod
          FROM crapcpc cpc, crapind ind
         WHERE cpc.cdprodut = pr_cdprodut AND
               ind.cddindex = cpc.cddindex;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Verifica provisoes
      CURSOR cr_craplac(pr_cdcooper IN craplac.cdcooper%TYPE,
                        pr_nrdconta IN craplac.nrdconta%TYPE,
                        pr_nraplica IN craplac.nraplica%TYPE,
                        pr_cdhsprap IN crapcpc.cdhsprap%TYPE,
                        pr_cdhsrvap IN crapcpc.cdhsrvap%TYPE) IS

        SELECT lac.cdhistor, lac.vllanmto
          FROM craplac lac
         WHERE lac.cdcooper = pr_cdcooper
           AND lac.nrdconta = pr_nrdconta
           AND lac.nraplica = pr_nraplica
           AND lac.cdhistor IN (pr_cdhsprap, pr_cdhsrvap);

      rw_craplac cr_craplac%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Inicializar parametros de saída
      pr_vlsldtot := 0;
      pr_vlsldrgt := 0;
      pr_vlultren := 0;
      pr_vlrentot := 0;
      pr_vlrevers := 0;
      pr_vlrdirrf := 0;
      pr_percirrf := 0;
      
      vr_dtfimcal := pr_dtfimcal;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Consulta dados da aplicacao
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nraplica => pr_nraplica);

      FETCH cr_craprac INTO rw_craprac;

      IF cr_craprac%NOTFOUND THEN
        CLOSE cr_craprac;
        vr_dscritic := 'Erro ao consultar dados da aplicacao.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craprac;
      END IF;

      ---- Leitura de produtos
      OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto ' || rw_craprac.cdprodut || ' nao cadastrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      -- Verificacao de datas
      IF rw_craprac.dtmvtolt = rw_crapdat.dtmvtolt AND
         rw_crapdat.dtmvtolt = vr_dtfimcal      THEN

        pr_vlsldtot := rw_craprac.vlaplica;
        pr_vlsldrgt := rw_craprac.vlaplica;

        RAISE vr_exc_null;

      END IF;
      
      -- Aplicacao encerrada
      IF  rw_craprac.idsaqtot > 0  THEN
        pr_vlsldtot := 0;
        pr_vlsldrgt := 0;
        
        RAISE vr_exc_null;
      END IF;

      -- Verifica a quantidade de dias para saber o IR
      vr_qtdiasir := vr_dtfimcal - pr_dtiniapl;

      -- Consulta faixas de IR
      apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

      FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.FIRST .. apli0001.vr_faixa_ir_rdc.LAST LOOP

        IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
          pr_percirrf := NVL(apli0001.vr_faixa_ir_rdc(i).perirtab,0);
        END IF;

      END LOOP;

      IF NVL(pr_percirrf,0) = 0 AND pr_cdcooper <> 3 THEN
        vr_dscritic := 'Faixa de IRRF nao encontrada.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica Base Cálculo Total
      IF pr_idtipbas = 2 THEN              
        pr_vlbascal := rw_craprac.vlsldatl; -- Saldo atualizado
        vr_dtinical := rw_craprac.dtatlsld; -- Data de atualização do saldo
      ELSIF pr_idtipbas = 1 THEN
        -- Verifica Base Cálculo Parcial
        vr_dtinical := pr_dtinical; -- Data de atualização do saldo
      END IF;

      vr_vlsldtot := pr_vlbascal;
      vr_dtperiod := vr_dtinical;

      IF vr_vlsldtot IS NULL OR
         vr_vlsldtot <= 0 THEN

        vr_dscritic := 'Saldo nao informado.';
        RAISE vr_exc_saida;

      END IF;

      WHILE vr_dtperiod < vr_dtfimcal LOOP
        -- Verifica se e final de semana ou feriado
        IF to_char(vr_dtperiod, 'D') NOT IN (1, 7) AND
           NOT flxf0001.fn_verifica_feriado(pr_cdcooper, vr_dtperiod) THEN

          IF rw_crapcpc.idperiod = 1 THEN --> Taxa Cadastrada Diariamente
            vr_dtpertxi := pr_dtiniapl;
          ELSIF rw_crapcpc.idperiod = 2 THEN --> Taxa Cadastrada Mensalmente
            vr_dtpertxi := TRUNC(pr_dtiniapl,'MM');
          ELSIF rw_crapcpc.idperiod = 3 THEN --> Taxa Cadastrada Anualmente
            vr_dtpertxi := TRUNC(pr_dtiniapl,'YY');
          ELSE
            vr_dscritic := 'Periodicidade de cadastro da taxa do indexador '
                           || pr_cddindex || ' invalido.';
            RAISE vr_exc_saida;
          END IF;

          -- Consulta o valor da taxa do periodo para o indexador
          OPEN cr_craptxi(pr_cddindex => pr_cddindex --> Código do indexador
                         ,pr_dtperiod => vr_dtpertxi); --> Data doperiodo

          FETCH cr_craptxi
            INTO rw_craptxi;

          IF cr_craptxi%NOTFOUND THEN
            CLOSE cr_craptxi;
            vr_dscritic := 'Taxa do indexador ' || pr_cddindex ||
                           ' nao cadastrada. Periodo: ' || TO_CHAR(vr_dtpertxi,'dd/mm/RRRR');
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craptxi;
          END IF;

          -- Se a taxa for expressa ao mês, a taxa deve ser capitalizada ao ano.
          IF rw_craptxi.idexpres = 1 THEN
            vr_txperiod := ROUND((POWER((rw_craptxi.vlrdtaxa / 100) + 1, 12) - 1) * 100,8); -- Taxa Expressa Ao Mês
          ELSE
            vr_txperiod := rw_craptxi.vlrdtaxa; -- Taxa Expressa Ao Ano
          END IF;

          -- Taxa do indexador deverá estar descapitalizada ao dia, pois o rendimento é calculado diariamente
          vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);

          -- Se o produto utilizar taxa fixa, essa taxa também deve ser descapitalizada ao dia e acrescentada a taxa do período
          IF pr_idtxfixa = 1 THEN -- Taxa Fixa
            vr_txfixper := ROUND((POWER((pr_txaplica / 100) + 1, 1 / 252) - 1), 8);
            vr_txperiod := ROUND((((vr_txperiod + 1) * (vr_txfixper + 1)) - 1), 8);
          ELSIF pr_idtxfixa = 2 THEN -- Sem Taxa Fixa / Se não existe taxa fixa no produto, a taxa utilizada no período deve ser obtida com base na taxa contratada
            vr_txperiod := ROUND(vr_txperiod * (pr_txaplica / 100), 8);
          END IF;

          -- Rendimento calculado com base no saldo da aplicação
          IF vr_txacumul = 0 THEN
            vr_txacumul := ROUND(vr_txperiod, 8);
          ELSE
            vr_txacumul := ROUND(((vr_txacumul + 1) * (vr_txperiod + 1)) - 1,
                                 8);
          END IF;

          vr_vlrendim := ROUND(vr_vlsldtot * vr_txperiod, 6);
          vr_vlsldtot := ROUND(vr_vlsldtot + vr_vlrendim, 6);
          vr_vlrentot := ROUND(vr_vlrentot + vr_vlrendim, 6);

        END IF;
        -- Incrementa data
        vr_dtperiod := vr_dtperiod + 1;

        -- Verifica ultimo dia util do mes
        vr_dtultdia := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => LAST_DAY(vr_dtperiod)
                                                  ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês

        -- Se for ultimo dia util do mes, arredonda os valores de saldo e rendimento
        IF vr_dtperiod = vr_dtultdia THEN
          vr_vlsldtot := ROUND(vr_vlsldtot, 2); -- Valor de saldo
        END IF;

      END LOOP;

      vr_vlsldtot := ROUND(vr_vlsldtot, 2);
      vr_vlrentot := ROUND(vr_vlrentot, 2);

      -- Verifica base de calculo
      IF pr_idtipbas = 2 THEN

        -- Base Cálculo Total
        OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

        FETCH cr_crapcpc
          INTO rw_crapcpc;

        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Historicos de Provisao e Reversao nao cadastrados para produto: ' ||
                         rw_craprac.cdprodut;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcpc;
          -- Consulta lancamento da aplicacao
          OPEN cr_craplac(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nraplica => pr_nraplica,
                          pr_cdhsprap => rw_crapcpc.cdhsprap,
                          pr_cdhsrvap => rw_crapcpc.cdhsrvap);

          LOOP

            FETCH cr_craplac INTO rw_craplac;

            EXIT WHEN cr_craplac%NOTFOUND;

            IF rw_craplac.cdhistor = rw_crapcpc.cdhsprap THEN
              -- Historico de Provisão
              vr_vlprovis := vr_vlprovis + rw_craplac.vllanmto;
            ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrvap THEN
              -- Historico de Reversão
              vr_vlrevers := vr_vlrevers + rw_craplac.vllanmto;
            END IF;

          END LOOP;

          CLOSE cr_craplac;

        END IF;

        pr_vlultren := vr_vlrentot;
        pr_vlrentot := (vr_vlprovis - vr_vlrevers) + vr_vlrentot;
        pr_vlrevers := pr_vlrentot;

        -- Verifica se a aplicação estiver na carência e o resgate for total
        IF vr_qtdiasir < pr_qtdiacar THEN
          pr_vlsldtot := rw_craprac.vlbasapl;
          pr_vlsldrgt := rw_craprac.vlbasapl;
          pr_vlrentot := 0;
          pr_vlrdirrf := 0;
          pr_vlbascal := rw_craprac.vlbasapl;

        END IF;

      ELSIF pr_idtipbas = 1 THEN
        -- Base Cálculo Parcial

        pr_vlultren := vr_vlrentot;
        pr_vlrentot := vr_vlrentot;
        pr_vlrevers := vr_vlrentot;

        -- Verifica se a aplicação estiver na carência e o resgate for parcial
        IF vr_qtdiasir < pr_qtdiacar THEN
          pr_vlsldtot := pr_vlbascal;
          pr_vlsldrgt := pr_vlbascal;
          pr_vlrentot := 0;
          pr_vlrdirrf := 0;

        END IF;

      END IF;

      -- Os cálculos abaixo deverão ser executados somente a aplicação passou o período de carência
      IF vr_qtdiasir >= pr_qtdiacar THEN

        -- O valor do IRRF deve ser calculado com base no rendimento total
        pr_vlrdirrf := ROUND(pr_vlrentot * (pr_percirrf / 100), 2);

        -- Independente do tipo da base de cálculo, o saldo total da aplicação será o valor da variável vr_vlsldtot
        pr_vlsldtot := vr_vlsldtot;

        IF pr_idgravir = 1 THEN
          vr_flgrvvlr := TRUE;
        ELSE
          vr_flgrvvlr := FALSE;
        END IF;

        -- Verifica imunidade tributaria
        IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                            pr_flgrvvlr => vr_flgrvvlr,
                                            pr_cdinsenc => 5,
                                            pr_vlinsenc => pr_vlrdirrf,
                                            pr_flgimune => vr_flgimune,
                                            pr_dsreturn => vr_dsreturn,
                                            pr_tab_erro => vr_tab_erro);

        -- Verifica se houve erro na consulta de imunidade tributaria
        IF vr_dsreturn <> 'OK' THEN
          vr_dscritic := 'Erro ao verificar imunidade tributaria.';
          RAISE vr_exc_saida;
        END IF;

        -- Verifica imunidade tributaria
        IF vr_flgimune THEN
          -- Imune a tributacao
          pr_vlrdirrf := 0;
        END IF;

        -- Saldo para resgate com deducao de IRRF
        pr_vlsldrgt := pr_vlsldtot - pr_vlrdirrf;

        -- Se for base de cálculo total, o valor base retornado deve ser o saldo da aplicação subtraído o valor de reversão
        IF pr_idtipbas = 2 THEN
          pr_vlbascal := pr_vlsldtot - pr_vlrevers;
        END IF;

        -- Se a base for parcial, retornar o valor base proporcional ao resgate, conforme imunidade tributária
        IF NOT vr_flgimune THEN
          -- Imune a tributacao
          pr_vlbascal := round(pr_vlbascal / (1 + (vr_txacumul * (1 - (pr_percirrf / 100)))), 2);
        ELSE
          pr_vlbascal := round(pr_vlbascal / (1 + vr_txacumul), 2);
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Calculos de Aplicacao PRE: ' || SQLERRM;
    END;

  END pc_posicao_saldo_aplicacao_pre;

  -- Rotina referente a calculo da taxa acumulada das aplicações pós-fixadas
  PROCEDURE pc_taxa_acumul_aplic_pos(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                    ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                    ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                    ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                    ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                    ,pr_txacumul OUT NUMBER               --> Taxa acumulada durante o período total da aplicação
                                    ,pr_txacumes OUT NUMBER               --> Taxa acumulada durante o mês vigente
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_taxa_acumul_aplic_pos
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 19/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a calcular a taxa acumulada das aplicações pós-fixadas

     Observacao: -----

     Alteracoes: 20/12/2018 - Removido rollback do tratamento de excecao (Anderson)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_dtinimes DATE; --> Data inicial do mes vigente
      vr_dtperiod DATE;
      vr_dtpertxi DATE; 
      vr_txperiod NUMBER := 0; --> Valor de taxa por periodo
      vr_txfixper NUMBER := 0; --> Valor de taxa fixa do periodo

      -- CURSORES

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.nmextcop
              ,cop.nrdocnpj
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapind (pr_cddindex IN crapind.cddindex%TYPE) IS
        SELECT
          ind.cddindex
         ,ind.nmdindex
         ,ind.idperiod
         ,ind.idcadast
         ,ind.idexpres
        FROM
          crapind ind
        WHERE
          ind.cddindex = pr_cddindex;
      rw_crapind cr_crapind%ROWTYPE;
      
      CURSOR cr_craptxi (pr_cddindex IN crapind.cddindex%TYPE
                        ,pr_dtperiod IN craptxi.dtiniper%TYPE) IS
        SELECT         
          txi.dtiniper
         ,txi.dtfimper
         ,txi.vlrdtaxa
         ,txi.dtcadast
        FROM
          craptxi txi
        WHERE             
              txi.cddindex = pr_cddindex
          AND txi.dtiniper = pr_dtperiod
          AND txi.dtfimper = pr_dtperiod;
       rw_craptxi cr_craptxi%ROWTYPE;

    BEGIN

      -- Inicializar parametros de saída
      pr_txacumul := 0;
      pr_txacumes := 0;
                                    
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      OPEN cr_crapind(pr_cddindex => pr_cddindex);

      FETCH cr_crapind INTO rw_crapind;

      IF cr_crapind%NOTFOUND THEN
        CLOSE cr_crapind;
        vr_dscritic := 'Indexador nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapind;
      END IF;     

      -- Inicializacao de variaveis
      pr_txacumul := 0;
      pr_txacumes := 0;

      -- Data final do mes anterior
      vr_dtinimes := rw_crapdat.dtultdma;

      -- Atribui parametro de entrada a variavel que será utilizada em calculos
      vr_dtperiod := pr_dtinical;

      WHILE vr_dtperiod < pr_dtfimcal LOOP

        -- Verifica se e final de semana ou feriado
        IF TO_CHAR(vr_dtperiod, 'D') NOT IN (1, 7) AND
           NOT FLXF0001.fn_verifica_feriado(pr_cdcooper, vr_dtperiod) THEN

          IF rw_crapind.idperiod = 1 THEN --> Taxa Cadastrada Diariamente
            vr_dtpertxi := vr_dtperiod;
          ELSIF rw_crapind.idperiod = 2 THEN --> Taxa Cadastrada Mensalmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'MM');
          ELSIF rw_crapind.idperiod = 3 THEN --> Taxa Cadastrada Anualmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'YY');
          ELSE
            vr_dscritic := 'Periodicidade de cadastro da taxa do indexador '
                           || pr_cddindex || ' invalido.';
            RAISE vr_exc_saida;
          END IF;
          
          -- Consulta de taxa
          OPEN cr_craptxi(pr_cddindex => pr_cddindex
                         ,pr_dtperiod => vr_dtpertxi);

          FETCH cr_craptxi INTO rw_craptxi;

          IF cr_craptxi%NOTFOUND THEN
            CLOSE cr_craptxi;
            vr_dscritic := 'Taxa do indexador ' || pr_cddindex ||
                           ' nao cadastrada. Periodo: ' || TO_CHAR(vr_dtpertxi,'dd/mm/RRRR');
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craptxi;
          END IF;

          IF rw_crapind.idexpres = 1 THEN -- Taxa Expressa Ao Mês
            vr_txperiod := ROUND((POWER((rw_craptxi.vlrdtaxa / 100) + 1, 12) - 1) * 100, 8);
          ELSE -- Taxa Expressa Ao Ano
            vr_txperiod := rw_craptxi.vlrdtaxa;
          END IF;

          -- A taxa do indexador será descapitalizada ao dia, pois o rendimento é calculado diariamente
          vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);

          -- Se o produto está configurado para utilizar taxa fixa, essa taxa também deve ser
          -- descapitalizada ao dia e acrescentada a taxa do período.
          IF pr_idtxfixa = 1 THEN -- Taxa Fixa
            vr_txfixper := ROUND((POWER((pr_txaplica / 100) + 1, 1 / 252) - 1), 8);
            vr_txperiod := ROUND((((vr_txperiod + 1) * (vr_txfixper + 1)) - 1), 8);
          ELSIF pr_idtxfixa = 2 THEN -- Sem Taxa Fixa
            vr_txperiod := ROUND(vr_txperiod * (pr_txaplica / 100), 8);
          END IF;

          IF pr_txacumul = 0 THEN
            pr_txacumul := ROUND(vr_txperiod, 8);
          ELSE
            pr_txacumul := ROUND(((pr_txacumul + 1) * (vr_txperiod + 1)) - 1, 8);
          END IF;

          IF rw_craptxi.dtiniper >= vr_dtinimes THEN
            IF pr_txacumes = 0 THEN
              pr_txacumes := ROUND(vr_txperiod, 8);
            ELSE
              pr_txacumes := ROUND(((pr_txacumes + 1) * (vr_txperiod + 1)) - 1, 8);
            END IF;
          END IF;

        END IF;

        vr_dtperiod := vr_dtperiod + 1;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0006.pc_taxa_acumul_aplic_pos. Erro: ' || SQLERRM;
    END;

  END pc_taxa_acumul_aplic_pos;

  -- Rotina referente a calculo da taxa acumulada das aplicações pre-fixadas
  PROCEDURE pc_taxa_acumul_aplic_pre(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                    ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                    ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                    ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                    ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                    ,pr_txacumul OUT NUMBER               --> Taxa acumulada durante o período total da aplicação
                                    ,pr_txacumes OUT NUMBER               --> Taxa acumulada durante o mês vigente
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_taxa_acumul_aplic_pre
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 20/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a calcular a taxa acumulada das aplicações pré-fixadas

     Observacao: -----

     Alteracoes: 20/12/2018 - Removido rollback do tratamento de excecao (Anderson)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_dtinimes DATE; --> Data inicial do mes vigente
      vr_dtperiod DATE;
      vr_dtpertxi DATE;      
      vr_txperiod NUMBER := 0; --> Valor de taxa por periodo
      vr_txfixper NUMBER := 0; --> Valor de taxa fixa do periodo

      -- CURSORES

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.nmextcop
              ,cop.nrdocnpj
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      CURSOR cr_crapind (pr_cddindex IN crapind.cddindex%TYPE) IS
        SELECT
          ind.cddindex
         ,ind.nmdindex
         ,ind.idperiod
         ,ind.idcadast
         ,ind.idexpres
        FROM
          crapind ind
        WHERE
          ind.cddindex = pr_cddindex;
      rw_crapind cr_crapind%ROWTYPE;
      
      CURSOR cr_craptxi (pr_cddindex IN crapind.cddindex%TYPE
                        ,pr_dtperiod IN craptxi.dtiniper%TYPE) IS
        SELECT         
          txi.dtiniper
         ,txi.dtfimper
         ,txi.vlrdtaxa
         ,txi.dtcadast
        FROM
          craptxi txi
        WHERE             
              txi.cddindex = pr_cddindex
          AND txi.dtiniper = pr_dtperiod
          AND txi.dtfimper = pr_dtperiod;
       rw_craptxi cr_craptxi%ROWTYPE;

    BEGIN

      -- Inicializar parametros de saída
      pr_txacumul := 0;
      pr_txacumes := 0;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      OPEN cr_crapind(pr_cddindex => pr_cddindex);

      FETCH cr_crapind INTO rw_crapind;

      IF cr_crapind%NOTFOUND THEN
        CLOSE cr_crapind;
        vr_dscritic := 'Indexador nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapind;
      END IF; 

      -- Inicializacao de variaveis
      pr_txacumul := 0;
      pr_txacumes := 0;

      -- Data final do mes anterior
      vr_dtinimes := rw_crapdat.dtultdma;

      -- Atribui parametro de entrada a variavel que será utilizada em calculos
      vr_dtperiod := pr_dtinical;

      WHILE vr_dtperiod < pr_dtfimcal LOOP

        -- Verifica se e final de semana ou feriado
        IF TO_CHAR(vr_dtperiod, 'D') NOT IN (1, 7) AND
           NOT FLXF0001.fn_verifica_feriado(pr_cdcooper, vr_dtperiod) THEN
           
          IF rw_crapind.idperiod = 1 THEN --> Taxa Cadastrada Diariamente
            vr_dtpertxi := vr_dtperiod;
          ELSIF rw_crapind.idperiod = 2 THEN --> Taxa Cadastrada Mensalmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'MM');
          ELSIF rw_crapind.idperiod = 3 THEN --> Taxa Cadastrada Anualmente
            vr_dtpertxi := TRUNC(vr_dtperiod,'YY');
          ELSE
            vr_dscritic := 'Periodicidade de cadastro da taxa do indexador '
                           || pr_cddindex || ' invalido.';
            RAISE vr_exc_saida;
          END IF;

          -- Consulta de taxa
          OPEN cr_craptxi(pr_cddindex => pr_cddindex
                         ,pr_dtperiod => vr_dtpertxi);

          FETCH cr_craptxi INTO rw_craptxi;

          IF cr_craptxi%NOTFOUND THEN
            CLOSE cr_craptxi;
            vr_dscritic := 'Taxa do indexador ' || pr_cddindex ||
                           ' nao cadastrada. Periodo: ' || TO_CHAR(vr_dtpertxi,'dd/mm/RRRR');
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_craptxi;
          END IF;

          -- Se a taxa for expressa ao mês, a taxa deve ser capitalizada ao ano.
          IF rw_crapind.idexpres = 1 THEN -- Taxa Expressa Ao Mês
            vr_txperiod := ROUND((POWER((rw_craptxi.vlrdtaxa / 100) + 1, 12) - 1) * 100, 8);
          ELSE -- Taxa Expressa Ao Ano
             vr_txperiod := rw_craptxi.vlrdtaxa;
          END IF;

          -- A taxa do indexador deverá estar descapitalizada ao dia, pois o rendimento é calculado diariamente
          vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);

          -- Se o produto está configurado para utilizar taxa fixa, essa taxa também deve ser descapitalizada ao dia e acrescentada a taxa do período.
          -- Se não existe taxa fixa no produto, a taxa utilizada no período deve ser obtida com base na taxa contratada.
          IF pr_idtxfixa = 1 THEN -- Taxa Fixa
             vr_txfixper := ROUND((POWER((pr_txaplica / 100) + 1, 1 / 252) - 1), 8);
             vr_txperiod := ROUND((((vr_txperiod + 1) * (vr_txfixper + 1)) - 1), 8);
          ELSIF pr_idtxfixa = 2 THEN -- Sem Taxa Fixa
            vr_txperiod := ROUND(vr_txperiod * (pr_txaplica / 100), 8);
          END IF;

          IF pr_txacumul = 0 THEN
             pr_txacumul := ROUND(vr_txperiod, 8);
          ELSE
             pr_txacumul := ROUND(((pr_txacumul + 1) * (vr_txperiod + 1)) - 1, 8);
          END IF;


          IF rw_craptxi.dtiniper >= vr_dtinimes THEN
            IF pr_txacumes = 0 THEN
              pr_txacumes := ROUND(vr_txperiod, 8);
            ELSE
              pr_txacumes := ROUND(((pr_txacumes + 1) * (vr_txperiod + 1)) - 1, 8);
            END IF;
          END IF;

        END IF;

        vr_dtperiod := vr_dtperiod + 1;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0006.pc_taxa_acumul_aplic_pre. Erro: ' || SQLERRM;
    END;

  END pc_taxa_acumul_aplic_pre;

  -- Rotina referente a calculo da taxa acumulada das aplicações pré-fixadas
  PROCEDURE pc_valor_base_resgate(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_nrdconta IN craprac.nrdconta%TYPE --> Conta do Cooperado
                                 ,pr_idtippro IN crapcpc.idtippro%TYPE --> Tipo do Produto da Aplicação
                                 ,pr_txaplica IN craprac.txaplica%TYPE --> Taxa da Aplicação
                                 ,pr_idtxfixa IN craprac.txaplica%TYPE --> Taxa Fixa (1-SIM/2-NAO)
                                 ,pr_cddindex IN crapcpc.cddindex%TYPE --> Código do Indexador
                                 ,pr_dtinical IN DATE                  --> Data Inicial Cálculo (Fixo na chamada)
                                 ,pr_dtfimcal IN DATE                  --> Data Final Cálculo (Fixo na chamada)
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                 ,pr_vlresgat IN craprga.vlresgat%TYPE --> Valor do Resgate
                                 ,pr_percirrf IN NUMBER                --> Percentual de IRRF
                                 ,pr_vlbasrgt OUT NUMBER               --> Valor Base do Resgate
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis locais
      vr_flgimune BOOLEAN;           -- Flag que indica imunidade
      vr_dsreturn VARCHAR2(10);      -- Retorno de procedure;
      vr_txacumul NUMBER(20,8) := 0; -- Valor da taxa acumulada
      vr_txacumes NUMBER(20,8) := 0; -- Valor da taxa acumulada do mês

      -- Variavel de excecao
      vr_exc_saida EXCEPTION;

      -- Tabela generica de erro
      vr_tab_erro gene0001.typ_tab_erro;

    BEGIN

      -- Inicializar parametro de saída
      pr_vlbasrgt := 0;
      
      -- Verifica tipo aplicacao
      IF pr_idtippro = 1 THEN -- Pré-Fixada
         pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper
                                 ,pr_txaplica => pr_txaplica
                                 ,pr_idtxfixa => pr_idtxfixa
                                 ,pr_cddindex => pr_cddindex
                                 ,pr_dtinical => pr_dtinical
                                 ,pr_dtfimcal => pr_dtfimcal
                                 ,pr_txacumul => vr_txacumul
                                 ,pr_txacumes => vr_txacumes
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

         -- Verifica se houve critica no processamento
         IF vr_dscritic IS NOT NULL THEN
            -- Executa excecao
            RAISE vr_exc_saida;
         END IF;

      ELSIF pr_idtippro = 2  THEN -- Pós-Fixada

         pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper
                                 ,pr_txaplica => pr_txaplica
                                 ,pr_idtxfixa => pr_idtxfixa
                                 ,pr_cddindex => pr_cddindex
                                 ,pr_dtinical => pr_dtinical
                                 ,pr_dtfimcal => pr_dtfimcal
                                 ,pr_txacumul => vr_txacumul
                                 ,pr_txacumes => vr_txacumes
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

         -- Verifica se houve critica no processamento
         IF vr_dscritic IS NOT NULL THEN
            -- Executa excecao
            RAISE vr_exc_saida;
         END IF;

      END IF;

      -- Verifica imunidade tributaria
      IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_dtmvtolt => pr_dtmvtolt,
                                          pr_flgrvvlr => FALSE,
                                          pr_cdinsenc => 5,
                                          pr_vlinsenc => 0,
                                          pr_flgimune => vr_flgimune,
                                          pr_dsreturn => vr_dsreturn,
                                          pr_tab_erro => vr_tab_erro);

      IF vr_flgimune THEN -- Imune a tributacao
         pr_vlbasrgt := round(pr_vlresgat / (1 + vr_txacumul), 2);
      ELSE
         pr_vlbasrgt := round(pr_vlresgat /
                             (1 + (vr_txacumul * (1 - (pr_percirrf / 100)))), 2);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0006.pc_valor_base_resgate. Erro: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_valor_base_resgate;

END apli0006;
/
