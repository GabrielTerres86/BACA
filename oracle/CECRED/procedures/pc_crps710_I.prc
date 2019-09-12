CREATE OR REPLACE PROCEDURE CECRED.pc_crps710_I ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                 ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /*........................................................................

    Programa: PC_CRPS710_I
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : Setembro/2016                      Ultima Atualizacao: 06/06/2018
    Dados referente ao programa:

    Frequencia: Diario.
    Objetivo  : Renovacao automatica do limite de desconto de cheque.

    Alteração : 17/04/2017 - Alterar datas pois rotina será executada via Job.
                             PRJ300-Desconto de Cheque (Odirlei-AMcom)

                25/05/2017 - Retirado processo de bloqueio de inclusao de bordero
                             conforme solicitado area de negocio Gilmar (Daniel)

                06/06/2018 - Ajustes para considerar titulos de bordero vencidos (Andrew Albuquerque - GFT)

                21/03/2019 - Projeto rating adicionado a chamada pc_solicitar_rating_motor

                29/05/2019 - Ajuste no atualização do Rating quando vence o produto (Mario - AMcom)

                05/06/2019 - Inclusão de parametro RATING_RENOVACAO_ATIVO (Mario - AMcom)

                16/08/2019 - P450 - Grava rating como vencimdo pc_grava_rating_operacao sem
                             pesquisar a contingencia (Luiz Otavio Olinger Momm - AMCOM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS710';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Regras
      vr_dtaltera   DATE;           --> Data de revisao cadastral
      vr_dtmincta   DATE;           --> Data do Tempo Minimo de Conta
      vr_dstextab   VARCHAR2(1000); --> Campo da tabela generica
      vr_vlarrast   NUMBER;         --> Valor Arrasto
      vr_nivrisco   VARCHAR2(2);    --> Nivel de Risco
      vr_in_risco_rat INTEGER;
      -- Auxiliares
      vr_flgfound   BOOLEAN;        --> Verifica se achou registro
      vr_liquidez   NUMBER;         --> Percentual de liquidez
      vr_vllimite   NUMBER;         --> Valor limite do contrato
      vr_flgsaldo   INTEGER;        --> Indicador do saldo
      vr_dtperant   DATE;           --> Data Anterior
      vr_dtultmes_ant DATE;         --> Data ultimo dia mês anterior
      -- Parametro de Flag Rating Renovacao Ativo: 0-Não Ativo, 1-Ativo
      vr_flg_Rating_Renovacao_Ativo    NUMBER := 0;
      vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)
      vr_vlendivid                     craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
      vr_vllimrating                   craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
      vr_strating                      tbrisco_operacoes.insituacao_rating%TYPE; -- Identificador da Situacao Rating
      vr_dtrating                      tbrisco_operacoes.dtrisco_rating%TYPE; -- Data para efetivar o rating;

      -- Consulta de limite
      vr_tab_lim_desconto DSCC0001.typ_tab_lim_desconto;

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Listagem de alterações cadastrais
      CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                       ,pr_nrdconta IN crapalt.nrdconta%TYPE) IS
        SELECT /*+index_desc (crapalt  CRAPALT##CRAPALT1) */
              crapalt.dtaltera
          FROM crapalt
         WHERE crapalt.cdcooper = pr_cdcooper
           AND crapalt.nrdconta = pr_nrdconta
           AND crapalt.tpaltera = 1
           AND ROWNUM = 1;
--        ORDER BY crapalt.dtaltera DESC; --> Recadastramento
      rw_crapalt cr_crapalt%ROWTYPE;

      -- Verifica se possui registro no CYBER
      CURSOR cr_crapcyb(pr_cdcooper IN crapcyb.cdcooper%TYPE,
                        pr_nrdconta IN crapcyb.nrdconta%TYPE,
                        pr_cdorigem VARCHAR2,
                        pr_qtdiaatr IN crapcyb.qtdiaatr%TYPE) IS
        SELECT qtdiaatr
          FROM crapcyb
         WHERE crapcyb.cdcooper = pr_cdcooper
           AND crapcyb.nrdconta = pr_nrdconta
           AND ','||pr_cdorigem||',' LIKE ('%,'||crapcyb.cdorigem||',%')
           AND crapcyb.qtdiaatr > pr_qtdiaatr
           AND crapcyb.dtdbaixa IS NULL
           AND ROWNUM = 1;
      rw_crapcyb cr_crapcyb%ROWTYPE;

      -- Limite de desconto
      CURSOR cr_craplim_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                                pr_inpessoa IN crapass.inpessoa%TYPE,
                                pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                                pr_dtmvtoan IN crapdat.dtmvtoan%TYPE,
                                pr_qtdiaren IN craprli.qtdiaren%TYPE) IS
        SELECT craplim.cdcooper,
               craplim.nrdconta,
               craplim.vllimite,
               craplim.qtrenova,
               craplim.cddlinha,
               craplim.qtdiavig,
               craplim.nrctrlim,
               nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig,
               craplim.rowid,
               crapass.nmprimtl,
               crapass.cdagenci,
               crapass.dtadmiss,
               crapass.cdsitdct,
               crapass.nrdctitg,
               crapass.flgctitg,
               crapass.flgrenli,
               crapass.inpessoa,
               crapass.nrcpfcnpj_base
          FROM craplim, crapass
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.tpctrlim = 2 -- Desconto de Cheque
           AND craplim.insitlim = 2
           AND crapass.cdcooper = craplim.cdcooper
           AND crapass.nrdconta = craplim.nrdconta
           AND crapass.inpessoa = pr_inpessoa
           -- Vencimento no Final de Semana
           AND ((nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) > pr_dtmvtoan   AND
                 nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) <= pr_dtmvtolt) OR
               -- Tentativas de Renovacao
                (nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) >= (pr_dtmvtolt - pr_qtdiaren) AND
                 nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) <= pr_dtmvtolt));

      -- Linhas de desconto de cheque
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE) IS
        SELECT crapldc.cddlinha
              ,crapldc.flgstlcr
              ,crapldc.tpdescto
          FROM crapldc
         WHERE crapldc.cdcooper = pr_cdcooper
           AND crapldc.tpdescto = 2;

      -- Regras do limite de desconto de cheque
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE) IS
        SELECT craprli.cdcooper,
               craprli.inpessoa,
               craprli.vlmaxren,
               craprli.nrrevcad,
               craprli.qtmincta,
               craprli.qtdiaren,
               craprli.qtmaxren,
               craprli.qtdiaatr,
               craprli.qtatracc,
               craprli.dssitdop,
               craprli.dsrisdop,
               craprli.pcliqdez,
               craprli.qtdialiq
          FROM craprli
         WHERE craprli.cdcooper = pr_cdcooper
           AND craprli.tplimite = 2; -- Lim. Desconto de Cheque

      -- Risco com divida (Valor Arrasto)
      CURSOR cr_ris_comdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                          ,pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_inddocto IN crapris.inddocto%TYPE
                          ,pr_vldivida IN crapris.vldivida%TYPE) IS
        SELECT /*+index_desc (CRAPRIS CRAPRIS##CRAPRIS1)*/
               innivris
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtrefere = pr_dtrefere
           AND inddocto = pr_inddocto
           AND vldivida > pr_vldivida
           AND rownum = 1;
      rw_ris_comdiv cr_ris_comdiv%ROWTYPE;

      -- Risco sem divida
      CURSOR cr_ris_semdiv(pr_cdcooper IN crapris.cdcooper%TYPE
                          ,pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_inddocto IN crapris.inddocto%TYPE) IS
        SELECT MAX(innivris) innivris
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtrefere = pr_dtrefere
           AND inddocto = pr_inddocto;
      rw_ris_semdiv cr_ris_semdiv%ROWTYPE;

      --Calcular o valor devolvido
      CURSOR cr_craplcm(pr_cdcooper     IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta     IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                       ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE) IS
        SELECT nvl(SUM(lcm.vllanmto),0) vldevolv
          FROM craplcm lcm
          WHERE lcm.cdcooper = pr_cdcooper
            AND lcm.nrdconta = pr_nrdconta
            AND lcm.cdhistor = 399
            AND lcm.dtmvtolt BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate;
      rw_craplcm cr_craplcm%ROWTYPE;

      --Para calcular o valor descontado utilizar a leitura:
      CURSOR cr_crapcdb(pr_cdcooper     IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta     IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                       ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE) IS
        SELECT nvl(SUM(cdb.vlcheque), 0) vldescto
          FROM crapcdb cdb,
               crapbdc dbc
         WHERE dbc.cdcooper = pr_cdcooper
           AND dbc.nrdconta = pr_nrdconta
           AND dbc.dtmvtolt BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate
           AND cdb.cdcooper = dbc.cdcooper
           AND cdb.dtmvtolt = dbc.dtmvtolt
           AND cdb.cdagenci = dbc.cdagenci
           AND cdb.cdbccxlt = dbc.cdbccxlt
           AND cdb.nrdolote = dbc.nrdolote
           AND cdb.nrborder = dbc.nrborder
           AND cdb.nrdconta = dbc.nrdconta;

      rw_crapcdb cr_crapcdb%ROWTYPE;

      CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
                        ,pr_cddlinha IN craplim.cddlinha%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT lim.cdcooper
          FROM craplim lim
              ,crapbdc bdc
              ,crapcdb cdb
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.tpctrlim = 2
           AND lim.insitlim = 2 -- Ativa
           AND lim.cddlinha = pr_cddlinha
           AND bdc.cdcooper = lim.cdcooper
           AND bdc.nrdconta = lim.nrdconta
           AND bdc.nrctrlim = lim.nrctrlim
           AND cdb.cdcooper = bdc.cdcooper
           AND cdb.nrdconta = bdc.nrdconta
           AND cdb.nrborder = bdc.nrborder
           AND cdb.dtlibera >= pr_dtmvtolt
           AND cdb.insitchq = 2
           AND ROWNUM = 1; -- Processado
      rw_craplim cr_craplim%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       -- Busca do nr cpfcnpj base do associado
       CURSOR cr_crapass_ope (pr_cdcooper  IN crapass.cdcooper%TYPE     --> Coop. conectada
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS --> Codigo Conta
       SELECT  ass.nrcpfcnpj_base
          FROM crapass ass
       WHERE ass.cdcooper  = pr_cdcooper
          AND ass.nrdconta = pr_nrdconta;
       rw_crapass_ope   cr_crapass_ope%ROWTYPE;
      ------------------------------- TIPOS DE REGISTROS -----------------------
      TYPE typ_reg_crapldc IS RECORD
        (flgstlcr crapldc.flgstlcr%TYPE); -- Situacao da linha

      -- Tabela temporaria para os tipos de risco
      TYPE typ_reg_craptab IS RECORD
        (dsdrisco craptab.dstextab%TYPE);

      ------------------------------- TIPOS DE DADOS ---------------------------
      TYPE typ_tab_crapldc  IS TABLE OF typ_reg_crapldc INDEX BY PLS_INTEGER;
      TYPE typ_tab_craptab  IS TABLE OF typ_reg_craptab INDEX BY PLS_INTEGER;

      ----------------------------- VETORES DE MEMORIA -------------------------
      vr_tab_crapldc  typ_tab_crapldc;
      vr_tab_craptab  typ_tab_craptab;

      ----------------------------- PROCEDURES ---------------------------------
      --Procedure para limpar os dados das tabelas de memoria
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        vr_tab_crapldc.DELETE;
        vr_tab_craptab.DELETE;
      EXCEPTION
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
          vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps710.pc_limpa_tabela. '||sqlerrm;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

      -- Registra LOG de alteração para a tela ALTERA
      PROCEDURE pc_gera_log_alteracao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN crapcop.nrdconta%TYPE
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                     ,pr_nrdctitg IN crapass.nrdctitg%TYPE
                                     ,pr_flgctitg IN crapass.flgctitg%TYPE) IS

        -- Variaveis de Log de Alteracao
        vr_flgctitg crapalt.flgctitg%TYPE;
        vr_dsaltera LONG;

        -- Variaveis com erros
        vr_des_erro   VARCHAR2(4000);

        -- Cursor alteracao de cadastro
        CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS

          SELECT crapalt.dsaltera,
                 crapalt.rowid
            FROM crapalt
           WHERE crapalt.cdcooper = pr_cdcooper
             AND crapalt.nrdconta = pr_nrdconta
             AND crapalt.dtaltera = pr_dtmvtolt;
        rw_crapalt cr_crapalt%ROWTYPE;

      BEGIN

        -- Por default fica como 3
        vr_flgctitg  := 3;
        vr_dsaltera  := 'Renov. Aut. Limite Desc. de Cheque: ' || pr_nrctrlim || ',';

        -- Se for conta integracao ativa, seta a flag para enviar ao BB
        IF trim(pr_nrdctitg) IS NOT NULL AND pr_flgctitg = 2 THEN  -- Ativa
          --Conta Integracao
          vr_flgctitg := 0;
        END IF;

        -- Verifica se jah possui alteracao
        OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtmvtolt => pr_dtmvtolt);

        FETCH cr_crapalt INTO rw_crapalt;
        --Verificar se encontrou
        IF cr_crapalt%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapalt;
          -- Altera o registro
          BEGIN
            UPDATE crapalt SET
                   crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
                   crapalt.flgctitg = vr_flgctitg
             WHERE crapalt.rowid = rw_crapalt.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Conta: '    || pr_nrdconta ||'.'||
                             'Contrato: ' || pr_nrctrlim ||'.'||
                             'Erro ao atualizar crapalt. '||SQLERRM;

              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            ||vr_cdprogra || ' --> '|| vr_des_erro);
          END;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapalt;

          BEGIN
            INSERT INTO crapalt
              (crapalt.nrdconta
              ,crapalt.dtaltera
              ,crapalt.tpaltera
              ,crapalt.dsaltera
              ,crapalt.cdcooper
              ,crapalt.flgctitg
              ,crapalt.cdoperad)
            VALUES
              (pr_nrdconta
              ,pr_dtmvtolt
              ,2
              ,vr_dsaltera
              ,pr_cdcooper
              ,vr_flgctitg
              ,pr_cdoperad);
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro:= 'Conta: '    || pr_nrdconta ||'.'||
                            'Contrato: ' || pr_nrctrlim ||'.'||
                            'Erro ao inserir crapalt. '||SQLERRM;

              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            ||vr_cdprogra || ' --> ' || vr_des_erro);
          END;

        END IF;

      END pc_gera_log_alteracao;

      -- Procedure para atualizar a nao renovacao do limite de desconto
      PROCEDURE pc_nao_renovar(pr_craplim_crapass IN cr_craplim_crapass%ROWTYPE
                              ,pr_dsnrenov        IN VARCHAR2
                              ,pr_dsvlrmot        IN VARCHAR2) IS
        -- Variaveis com erros
        vr_exc_erro   EXCEPTION;
        vr_des_erro   VARCHAR2(4000);

      BEGIN
        -- Atualizar a tabela de limite de desconto de cheque
        UPDATE craplim
           SET dsnrenov = pr_dsnrenov || '|' || pr_dsvlrmot
         WHERE rowid    = pr_craplim_crapass.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
          vr_des_erro := 'Conta: '    || pr_craplim_crapass.nrdconta ||'.'||
                         'Contrato: ' || pr_craplim_crapass.nrctrlim ||'.'||
                         'Erro ao atualizar tabela craplim. Rotina pc_crps710. '||SQLERRM;
          -- Catalogar o erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_des_erro);
      END;

      -- Procedure para liberacao e bloqueio de inclusao de bordero
      PROCEDURE pc_blq_lib_inclusao_bord(pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_dscritic OUT VARCHAR2) IS
        BEGIN
        DECLARE

        CURSOR cr_craplim_crapsld(pr_cdcooper IN crapass.cdcooper%TYPE,
                                  pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT craplim.cdcooper,
                 craplim.nrdconta,
                 craplim.insitblq,
                 craplim.rowid,
                 (SELECT crapsld.qtdriclq
                    FROM crapsld
           WHERE crapsld.cdcooper = craplim.cdcooper
                     AND crapsld.nrdconta = craplim.nrdconta) qtdriclq
            FROM craplim
           WHERE craplim.cdcooper = pr_cdcooper
             AND craplim.tpctrlim = 2
             AND craplim.insitlim = 2
             AND craplim.dtfimvig >= pr_dtmvtolt;
        --rw_craplim cr_craplim%ROWTYPE;

        CURSOR cr_craplcm(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN craplcm.nrdconta%TYPE
                         ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
          SELECT 1
            FROM craplcm
           WHERE craplcm.cdcooper = pr_cdcooper
             AND craplcm.nrdconta = pr_nrdconta
             AND craplcm.cdhistor = 399
             AND craplcm.dtmvtolt = pr_dtmvtolt
             AND ROWNUM = 1;
        rw_craplcm cr_craplcm%ROWTYPE;

        ------------------------------- VARIAVEIS -------------------------------

        -- Tratamento de erros
        vr_exc_saida  EXCEPTION;
        vr_dscritic   VARCHAR2(4000);

        -- Cursor genérico de calendário
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;

        BEGIN

          --------------- REGRA DE NEGOCIO ------------------

          -- Leitura do calendario da cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;

          FOR rw_craplim_crapsld IN cr_craplim_crapsld( pr_cdcooper => pr_cdcooper,
                                                        pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
            -- Verifica se o saldo é positivo
            IF rw_craplim_crapsld.qtdriclq > 0 AND rw_craplim_crapsld.insitblq = 0 THEN
              -- Consulta o Associado
              OPEN cr_craplcm(pr_cdcooper => rw_craplim_crapsld.cdcooper
                             ,pr_nrdconta => rw_craplim_crapsld.nrdconta
                             ,pr_dtmvtolt => rw_crapdat.dtmvtoan);
              FETCH cr_craplcm INTO rw_craplcm;

              -- Verifica a conta do associado
              IF cr_craplcm%NOTFOUND THEN
                CLOSE cr_craplcm;
                CONTINUE;
              ELSE
                -- Atualizar para Bloquada Inclusão de Bordero
                CLOSE cr_craplcm;
                
                BEGIN
                  UPDATE craplim lim
                     SET lim.insitblq = 1
                   WHERE lim.rowid = rw_craplim_crapsld.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar a CRAPLIM. Conta: ' || rw_craplim_crapsld.nrdconta || ' ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
            ELSE
              -- Atualizar para Liberada Inclusão de Bordero
              IF rw_craplim_crapsld.qtdriclq = 0 AND rw_craplim_crapsld.insitblq = 1 THEN
                BEGIN
                  UPDATE craplim lim
                     SET lim.insitblq = 0
                   WHERE lim.rowid = rw_craplim_crapsld.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar a CRAPLIM. Conta: ' || rw_craplim_crapsld.nrdconta || ' ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
            END IF;
          END LOOP;

        EXCEPTION
          WHEN vr_exc_saida THEN
            -- Se foi retornado apenas código
            IF vr_dscritic IS NULL THEN
              -- Buscar a descrição
              vr_dscritic := SQLERRM;
            END IF;
            pr_dscritic := vr_dscritic;
          WHEN OTHERS THEN
            pr_dscritic := SQLERRM;
        END;
      END pc_blq_lib_inclusao_bord;

      --> Rotina para cobrança das tarifas de renovação de contrato
      PROCEDURE pc_gera_tarifa_renova( pr_cdcooper crapcop.cdcooper%TYPE,
                                       pr_crapdat  btch0001.cr_crapdat%ROWTYPE) IS

        --------> CURSORES <--------
        CURSOR cr_craplim_tari IS
          SELECT ass.inpessoa,
                 ass.nrdconta,
                 lim.nrctrlim,
                 lim.vllimite
            FROM craplim lim,
                 crapass ass
           WHERE lim.cdcooper = ass.cdcooper
             AND lim.nrdconta = ass.nrdconta
             AND lim.cdcooper = pr_cdcooper
             AND lim.tpctrlim = 2 -- Desconto de Cheque
             AND lim.insitlim = 2 -- Ativo
             AND lim.dtrenova = pr_crapdat.dtmvtoan
             AND lim.tprenova = 'A'
             AND lim.qtrenova > 0;

        --------> VARIAVEIS <--------
        --> Critica
        vr_cdcritic PLS_INTEGER;
        vr_dscritic VARCHAR2(4000);
        vr_tab_erro GENE0001.typ_tab_erro;

        -- Variaveis de tarifa
        vr_cdhistor craphis.cdhistor%TYPE;
        vr_cdhisest craphis.cdhistor%TYPE;
        vr_dtdivulg DATE;
        vr_dtvigenc DATE;
        vr_cdfvlcop crapfco.cdfvlcop%TYPE;
        vr_vltarifa crapfco.vltarifa%TYPE;
        vr_cdbattar VARCHAR2(10);

        vr_rowid         ROWID;

      BEGIN

        --> buscar os limites renovados hj para cobrança de Tarifa
        FOR rw_craplim_tari IN cr_craplim_tari LOOP

          -- 1 - Pessoa Fisica
          IF rw_craplim_tari.inpessoa = 1 THEN
            vr_cdbattar := 'DSCCHQREPF'; -- Renovacao contrato pessoa fisica
          ELSE
            vr_cdbattar := 'DSCCHQREPJ'; -- Renovacao contrato pessoa juridica
          END IF;

          -- Busca valor da tarifa
          TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                               ,pr_cdbattar => vr_cdbattar
                                               ,pr_vllanmto => rw_craplim_tari.vllimite
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_cdhistor => vr_cdhistor
                                               ,pr_cdhisest => vr_cdhisest
                                               ,pr_vltarifa => vr_vltarifa
                                               ,pr_dtdivulg => vr_dtdivulg
                                               ,pr_dtvigenc => vr_dtvigenc
                                               ,pr_cdfvlcop => vr_cdfvlcop
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_tab_erro => vr_tab_erro);

          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count() > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
            END IF;
            -- Envio centralizado de log de erro
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' - ' || vr_cdbattar);
            -- Efetua Limpeza das variaveis de critica
            vr_cdcritic := 0;
            vr_dscritic := NULL;

            -- Se não Existe Tarifa
            CONTINUE;
          END IF;

          -- Verifica se valor da tarifa esta zerado
          IF vr_vltarifa = 0 THEN
            CONTINUE;
          END IF;
          
          -- Criar Lançamento automatico Tarifas de contrato de desconto de cheques
          TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                          , pr_nrdconta     => rw_craplim_tari.nrdconta
                                          , pr_dtmvtolt     => pr_crapdat.dtmvtolt
                                          , pr_cdhistor     => vr_cdhistor
                                          , pr_vllanaut     => vr_vltarifa
                                          , pr_cdoperad     => '1'
                                          , pr_cdagenci     => 1
                                          , pr_cdbccxlt     => 100
                                          , pr_nrdolote     => 10028
                                          , pr_tpdolote     => 1
                                          , pr_nrdocmto     => 0
                                          , pr_nrdctabb     => rw_craplim_tari.nrdconta
                                          , pr_nrdctitg     => gene0002.fn_mask(rw_craplim_tari.nrdconta,'99999999')
                                          , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_craplim_tari.nrctrlim)
                                          , pr_cdbanchq     => 0
                                          , pr_cdagechq     => 0
                                          , pr_nrctachq     => 0
                                          , pr_flgaviso     => TRUE
                                          , pr_tpdaviso     => 2
                                          , pr_cdfvlcop     => vr_cdfvlcop
                                          , pr_inproces     => pr_crapdat.inproces
                                          , pr_rowid_craplat=> vr_rowid
                                          , pr_tab_erro     => vr_tab_erro
                                          , pr_cdcritic     => vr_cdcritic
                                          , pr_dscritic     => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro no lancamento Tarifa de contrato de desconto de cheques';
            END IF;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||
                                                          gene0002.fn_mask_conta(rw_craplim_tari.nrdconta)||'- '
                                                       || vr_dscritic );
            -- Limpa valores das variaveis de critica
            vr_cdcritic:= 0;
            vr_dscritic:= NULL;
          END IF;

        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Não foi possivel gerar tarifa de renovação: '||SQLERRM;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic );
          -- Limpa valores das variaveis de critica
          vr_cdcritic:= 0;
          vr_dscritic:= NULL;
      END pc_gera_tarifa_renova;


    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

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


      pc_limpa_tabela;

      --> Buscar Parametro
      vr_flg_Rating_Renovacao_Ativo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                ,pr_cdcooper => 0
                                                                ,pr_cdacesso => 'RATING_RENOVACAO_ATIVO');

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Seleciona valor de arrasto da tabela generica
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 0);
      -- Atribui o valor do arrasto
      vr_vlarrast := nvl(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 3, 9)),0);
      -- Carrega os tipos de riscos
      vr_tab_craptab(1).dsdrisco  := 'AA';
      vr_tab_craptab(2).dsdrisco  := 'A';
      vr_tab_craptab(3).dsdrisco  := 'B';
      vr_tab_craptab(4).dsdrisco  := 'C';
      vr_tab_craptab(5).dsdrisco  := 'D';
      vr_tab_craptab(6).dsdrisco  := 'E';
      vr_tab_craptab(7).dsdrisco  := 'F';
      vr_tab_craptab(8).dsdrisco  := 'G';
      vr_tab_craptab(9).dsdrisco  := 'H';
      vr_tab_craptab(10).dsdrisco := 'H';

      -- Consulta o limite de desconto por tipo de pessoa
      DSCC0001.pc_busca_tab_limdescont( pr_cdcooper => pr_cdcooper                  --> Codigo da cooperativa
                                       ,pr_inpessoa => 0                            --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                       ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto
                                       ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                       ,pr_dscritic => vr_dscritic);                --> Descrição da crítica

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Buscar todas as linhas de desconto de cheque
      FOR rw_crapldc IN cr_crapldc(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapldc(rw_crapldc.cddlinha).flgstlcr  := rw_crapldc.flgstlcr;

        -- Verifica se linha de credito de desconto de cheque possui saldo
        -- Verificando existem se borderôs de desconto ativos
        OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                        ,pr_cddlinha => rw_crapldc.cddlinha
                        ,pr_dtmvtolt => rw_crapdat.dtmvtoan);
        FETCH cr_craplim INTO rw_craplim;
        -- Se nao encontrar
        IF cr_craplim%FOUND THEN
          vr_flgsaldo := 1; -- Possui saldo
        ELSE
          vr_flgsaldo := 0;-- Nao possui saldo
        END IF;
        CLOSE cr_craplim;

        -- Atualiza o indicador
        BEGIN
          UPDATE crapldc
             SET flgsaldo = vr_flgsaldo
           WHERE cdcooper = pr_cdcooper
             AND tpdescto = 2
             AND cddlinha = rw_crapldc.cddlinha;
        EXCEPTION
          WHEN OTHERS THEN
            --Montar mensagem de erro
            vr_dscritic := 'Erro ao atualizar tabela crapldc. Rotina pc_crps710. ' || SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;

      END LOOP;

      -- Definir dia util anterior ao dia de ontem para o filtro de periodo
      vr_dtperant := gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper,
                                                  pr_dtmvtolt => rw_crapdat.dtmvtoan-1,
                                                  pr_tipo     => 'A' );

      --> Definir o ultimo dia do mes anterior com base no dia anterior
      vr_dtultmes_ant := last_day(add_months(rw_crapdat.dtmvtoan,-1));


      FOR rw_craprli IN cr_craprli(pr_cdcooper => pr_cdcooper) LOOP
        -- Buscar todos os limites de desconto de cheque que vencem hoje ou
        -- que venceram de acordo com a quantidade de tentativas para renovacao
        FOR rw_craplim_crapass IN cr_craplim_crapass (pr_cdcooper => rw_craprli.cdcooper
                                                     ,pr_inpessoa => rw_craprli.inpessoa
                                                     ,pr_dtmvtolt => rw_crapdat.dtmvtoan
                                                     ,pr_dtmvtoan => vr_dtperant
                                                     ,pr_qtdiaren => rw_craprli.qtdiaren) LOOP

          -- Verifica a situacao do limite do desconto de cheque
          IF nvl(rw_craplim_crapass.flgrenli,0) = 0 THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Desabilitado Renovacao Automatica'
                          ,pr_dsvlrmot        => '');
            CONTINUE;
          END IF;

          -- Verifica se a linha rotativa esta cadastrada
          IF NOT vr_tab_crapldc.EXISTS(rw_craplim_crapass.cddlinha) THEN
            vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim_crapass.cddlinha;
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '|| vr_dscritic);
            CONTINUE;
          END IF;

          -- Verifica a situacao do limite de desconto de cheque
          IF nvl(vr_tab_crapldc(rw_craplim_crapass.cddlinha).flgstlcr,0) = 0 THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Linha de desconto bloqueada'
                          ,pr_dsvlrmot        => rw_craplim_crapass.cddlinha);
            CONTINUE;
          END IF;

          -- Verifica a situacao da conta
          IF (INSTR(';' || rw_craprli.dssitdop || ';',';' || rw_craplim_crapass.cdsitdct || ';') <= 0) THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Situacao da Conta'
                          ,pr_dsvlrmot        => rw_craplim_crapass.cdsitdct);
            CONTINUE;
          END IF;

          -- Pega o menor valor
          IF nvl(rw_craprli.vlmaxren,0) < vr_tab_lim_desconto(rw_craplim_crapass.inpessoa).vllimite THEN
            vr_vllimite := rw_craprli.vlmaxren;
          ELSE
            vr_vllimite := vr_tab_lim_desconto(rw_craplim_crapass.inpessoa).vllimite;
          END IF;

          -- Valida se o limite do contrato respeita o Limite Maximo do Contrato
          IF nvl(rw_craplim_crapass.vllimite,0) > vr_vllimite THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Valor do Limite'
                          ,pr_dsvlrmot        => TO_CHAR(rw_craplim_crapass.vllimite,'fm999g999g999g990d00'));
            CONTINUE;
          END IF;

          -- Verificar a quantidade maxima que pode renovar
          IF ((nvl(rw_craprli.qtmaxren,0) > 0)                                    AND
              (nvl(rw_craplim_crapass.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Qtde. maxima de renovacao excedida'
                          ,pr_dsvlrmot        => rw_craplim_crapass.qtrenova);
            CONTINUE;
          END IF;

          vr_dtmincta := ADD_MONTHS(rw_crapdat.dtmvtolt, - (rw_craprli.qtmincta));
          -- Verificar o tempo de conta
          IF rw_craplim_crapass.dtadmiss > vr_dtmincta THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Tempo de Conta'
                          ,pr_dsvlrmot        => to_char(rw_craplim_crapass.dtadmiss,'DD/MM/RRRR'));
            CONTINUE;
          END IF;

          -- Risco com divida (Valor Arrasto)
          OPEN cr_ris_comdiv(pr_cdcooper => rw_craplim_crapass.cdcooper
                            ,pr_nrdconta => rw_craplim_crapass.nrdconta
                            ,pr_dtrefere => vr_dtultmes_ant
                            ,pr_inddocto => 1
                            ,pr_vldivida => vr_vlarrast);
          FETCH cr_ris_comdiv
           INTO rw_ris_comdiv;
          CLOSE cr_ris_comdiv;
          
          -- Se encontrar
          IF rw_ris_comdiv.innivris IS NOT NULL THEN
            vr_nivrisco := TRIM(vr_tab_craptab(rw_ris_comdiv.innivris).dsdrisco);
          ELSE
            -- Risco sem divida
            OPEN cr_ris_semdiv(pr_cdcooper => rw_craplim_crapass.cdcooper
                              ,pr_nrdconta => rw_craplim_crapass.nrdconta
                              ,pr_dtrefere => vr_dtultmes_ant
                              ,pr_inddocto => 1);
            FETCH cr_ris_semdiv
             INTO rw_ris_semdiv;
            CLOSE cr_ris_semdiv;
            -- Se encontrar
            IF rw_ris_semdiv.innivris IS NOT NULL THEN
              -- Quando possuir operacao em Prejuizo, o risco da central sera H
              IF rw_ris_semdiv.innivris = 10 THEN
                vr_nivrisco := TRIM(vr_tab_craptab(rw_ris_semdiv.innivris).dsdrisco);
              ELSE
                vr_nivrisco := TRIM(vr_tab_craptab(2).dsdrisco);
              END IF;
            ELSE
              vr_nivrisco := TRIM(vr_tab_craptab(2).dsdrisco);
            END IF;

          END IF;

          -- Caso seja uma classificacao antiga
          IF vr_nivrisco = 'AA' THEN
            vr_nivrisco := 'A';
          END IF;

          -- Verifica o risco da conta
          IF (INSTR(';' || rw_craprli.dsrisdop || ';',';' || vr_nivrisco || ';') <= 0) THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Risco da Conta'
                          ,pr_dsvlrmot        => vr_nivrisco);
            CONTINUE;
          END IF;

          vr_dtaltera := NULL;

          -- Revisão Cadastral
          OPEN cr_crapalt(pr_cdcooper => rw_craplim_crapass.cdcooper
                         ,pr_nrdconta => rw_craplim_crapass.nrdconta);
          FETCH cr_crapalt
           INTO rw_crapalt;
          -- Se NAO encontrar alteração passa para o proximo registro
          IF cr_crapalt%FOUND THEN
            CLOSE cr_crapalt;
            vr_dtaltera := rw_crapalt.dtaltera;
          ELSE
            CLOSE cr_crapalt;
          END IF;

          -- Verifica a revisao cadastral se estah dentro do periodo
          IF ((ADD_MONTHS(rw_crapdat.dtmvtoan, - (rw_craprli.nrrevcad)) > vr_dtaltera) OR (vr_dtaltera IS NULL)) THEN
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Revisao Cadastral'
                          ,pr_dsvlrmot        => to_char(vr_dtaltera,'DD/MM/RRRR'));
            CONTINUE;
          END IF;

          -- Verifica se o cooperado possui algum emprestimo em atraso no CYBER
          OPEN cr_crapcyb(pr_cdcooper => rw_craplim_crapass.cdcooper
                         ,pr_nrdconta => rw_craplim_crapass.nrdconta
                         --Ajustes para considerar titulos de bordero vencidos (Andrew Albuquerque - GFT)
                         ,pr_cdorigem => '2,3,4'
                         ,pr_qtdiaatr => rw_craprli.qtdiaatr);
          FETCH cr_crapcyb INTO rw_crapcyb;
          IF cr_crapcyb%FOUND THEN
            CLOSE cr_crapcyb;
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Qtde de dias Atraso do Emprestimo'
                          ,pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));

            CONTINUE;
          ELSE
            CLOSE cr_crapcyb;
          END IF;

          -- Verifica se o cooperado possui estouro de conta no CYBER
          OPEN cr_crapcyb(pr_cdcooper => rw_craplim_crapass.cdcooper
                         ,pr_nrdconta => rw_craplim_crapass.nrdconta
                         ,pr_cdorigem => '1'
                         ,pr_qtdiaatr => rw_craprli.qtatracc);
          FETCH cr_crapcyb INTO rw_crapcyb;
          IF cr_crapcyb%FOUND THEN
            CLOSE cr_crapcyb;
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Qtde de dias Atraso Conta Corrente'
                          ,pr_dsvlrmot        => nvl(rw_crapcyb.qtdiaatr,0));

            CONTINUE;
          ELSE
            CLOSE cr_crapcyb;
          END IF;
          
          -- Valor Descontado
          OPEN cr_crapcdb(pr_cdcooper     => rw_craplim_crapass.cdcooper
                         ,pr_nrdconta     => rw_craplim_crapass.nrdconta
                         ,pr_dtmvtolt_de  => rw_crapdat.dtmvtoan - rw_craprli.qtdialiq
                         ,pr_dtmvtolt_ate => rw_crapdat.dtmvtoan);
          FETCH cr_crapcdb INTO rw_crapcdb;
          vr_flgfound := cr_crapcdb%FOUND;
          CLOSE cr_crapcdb;

          -- Se não houver desconto, liquidez é 100%
          IF rw_crapcdb.vldescto = 0 THEN
            vr_liquidez := 100;
          ELSE
            -- Valor Devolvido
            OPEN cr_craplcm(pr_cdcooper     => rw_craplim_crapass.cdcooper
                           ,pr_nrdconta     => rw_craplim_crapass.nrdconta
                           ,pr_dtmvtolt_de  => rw_crapdat.dtmvtoan - rw_craprli.qtdialiq
                           ,pr_dtmvtolt_ate => rw_crapdat.dtmvtoan);
            FETCH cr_craplcm INTO rw_craplcm;
            CLOSE cr_craplcm;

            vr_liquidez := 100 - (rw_craplcm.vldevolv / rw_crapcdb.vldescto * 100);
          END IF;

          -- Verifica se o cooperado possui liquidez no produto de desconto de cheques
          -- maior ou igual ao percentual cadastrado
          IF vr_liquidez < rw_craprli.pcliqdez THEN
            -- Atualiza motivo da nao renovacao do limite de desconto de cheque
            pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                          ,pr_dsnrenov        => 'Liquidez no produto de desconto de cheques'
                          ,pr_dsvlrmot        => ROUND(nvl(vr_liquidez,0),2));

            CONTINUE;
          END IF;

          -- P450 SPT13 - alteracao para habilitar rating novo
          IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN
            -- Verifica processamento do Rating Renovacao
            IF vr_flg_Rating_Renovacao_Ativo = 1 THEN
              -- Grava rating

              -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
              RATI0003.pc_busca_endivid_param(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_craplim_crapass.nrdconta
                                             ,pr_vlendivi => vr_vlendivid
                                             ,pr_vlrating => vr_vllimrating
                                             ,pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdcritic := 0;
                pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                              ,pr_dsnrenov        => 'Erro ao buscar o endividamento no desct. cheque PC_CRPS710_I.'
                              ,pr_dsvlrmot        => ROUND(nvl(vr_liquidez,0),2));
                CONTINUE;
              END IF;

              vr_strating := 2; -- Analisado
              vr_dtrating := NULL;
              IF (vr_vlendivid  > vr_vllimrating)  THEN
                -- Gravar o Rating da operação, efetivando-o
                vr_strating := 4; -- Efetivado
                vr_dtrating := rw_crapdat.dtmvtolt;
              END IF;

              rati0003.pc_grava_rating_operacao( pr_cdcooper           => pr_cdcooper
                                                ,pr_nrdconta           => rw_craplim_crapass.nrdconta
                                                ,pr_tpctrato           => 2
                                                ,pr_nrctrato           => rw_craplim_crapass.nrctrlim
                                                ,pr_strating           => vr_strating
                                                ,pr_dtrataut           => rw_crapdat.dtmvtolt  --> Data da nova renovação
                                                ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                                ,pr_dtrating           => vr_dtrating
                                                --Variáveis de crítica
                                                ,pr_cdcritic           => vr_cdcritic     --> Critica encontrada no processo
                                                ,pr_dscritic           => vr_dscritic);   --> Descritivo do erro

              IF ( vr_cdcritic >= 0 AND vr_cdcritic IS NOT NULL) OR TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdcritic := 0;
                pc_nao_renovar(pr_craplim_crapass => rw_craplim_crapass
                              ,pr_dsnrenov        => 'Erro ao atualizar o rating no desct. cheque PC_CRPS710_I.'
                              ,pr_dsvlrmot        => ROUND(nvl(vr_liquidez,0),2));
                CONTINUE;
              END IF;
            END IF;
          END IF;
          -- P450 SPT13 - alteracao para habilitar rating novo

          -- Atualiza os dados do limite de desconto de cheque
          BEGIN
            UPDATE craplim SET
                   dtrenova = rw_crapdat.dtmvtoan,
                   tprenova = 'A',
                   dsnrenov = ' ',
                   dtfimvig = rw_crapdat.dtmvtoan + nvl(qtdiavig,0),
                   qtrenova = nvl(qtrenova,0) + 1
             WHERE rowid = rw_craplim_crapass.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Conta: '    || rw_craplim_crapass.nrdconta ||'.'||
                             'Contrato: ' || rw_craplim_crapass.nrctrlim ||'.'||
                             'Erro ao atualizar tabela craplim. Rotina pc_crps710. ' || SQLERRM;
              -- Catalogar o Erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '||
                                                            vr_cdprogra || ' --> ' || vr_dscritic);
              CONTINUE;
          END;

          -- Gera Log de alteracao
          pc_gera_log_alteracao(pr_cdcooper => rw_craplim_crapass.cdcooper
                               ,pr_nrdconta => rw_craplim_crapass.nrdconta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdoperad => 1
                               ,pr_nrctrlim => rw_craplim_crapass.nrctrlim
                               ,pr_nrdctitg => rw_craplim_crapass.nrdctitg
                               ,pr_flgctitg => rw_craplim_crapass.flgctitg);

        END LOOP; -- END LOOP FOR rw_craplim

      END LOOP; -- END LOOP FOR rw_craprli

      pc_limpa_tabela;

      --> Rotina para cobrança das tarifas de renovação de contrato
      pc_gera_tarifa_renova (pr_cdcooper => pr_cdcooper,
                             pr_crapdat  => rw_crapdat);
      /*
      -- Rotina para bloqueio e desbloqueio da inclusao de cordero
      pc_blq_lib_inclusao_bord(pr_cdcooper => pr_cdcooper
                              ,pr_dscritic => vr_dscritic);

      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      */

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps710_I;
/
