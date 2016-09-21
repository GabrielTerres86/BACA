CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS639 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Codigo do operador
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /*.............................................................................

    Programa: pc_crps639                              (Antigo: Fontes/crps639.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas R.
    Data    : Marco/2013.                        Ultima atualizacao: 17/04/2015

    Dados referentes ao programa:

    Frequencia: Diario (Batch). Solicitacao 40. Ordem de Execucao 06.
    Objetivo  : Gerar lancamento de cobranca de tarifas agendadas de cooperados.

    Alteracoes: 24/07/2013 - Ajuste Grupo Conta Corrente (David).

                23/08/2013 - Ajuste para nao cobrar tarifa em finais de semana
                             e feriados, para evitar estouro de conta devido
                             a saques e/ou transferencias. (David).

                20/11/2013 - Conversão Progress >> PLSQL (Jean Michel).
                
                08/05/2013 - Ajustado pc_atualiza_tarifa_vigente para inativar 
                             todas as tarifas anteriores as aquelas que estao entrando em vigencia,
                             para posteriormente ativas a tarifa que esta entrando em vigencia (Odirlei/AMcom)
                             
                17/04/2015 - Inclusão do parametro pr_tipo_busca na chamada da rotina extr0001.pc_busca_saldo_dia
                             para melhoria de performance. (Alisson - AMcom)             

  .............................................................................*/

  DECLARE
    -- VARIAVEIS --
    vr_exc_erro   EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS639';
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dsconteu VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_inttoday INTEGER;
    vr_dttransa INTEGER;
    vr_index    PLS_INTEGER;
    
    -- TIPOS DE TABELAS TEMPORARIAS
    
    TYPE typ_reg_craplat_baixado IS RECORD
      (insitlat craplat.insitlat%type,
       cdopeest craplat.cdopeest%type,
       dtdestor craplat.dtdestor%type,
       cdmotest craplat.cdmotest%type,
       dsjusest craplat.dsjusest%type,
       vr_rowid rowid);
    TYPE typ_tab_craplat_baixado IS TABLE OF typ_reg_craplat_baixado INDEX BY PLS_INTEGER;
    
    TYPE typ_reg_craplat_efetiv IS RECORD
      (insitlat craplat.insitlat%type,
       dtefetiv craplat.dtefetiv%type,
       vr_rowid rowid);
    TYPE typ_tab_craplat_efetiv IS TABLE OF typ_reg_craplat_efetiv INDEX BY PLS_INTEGER;
      
    TYPE typ_tab_craplat IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    -- TABELAS TEMPORARIAS --
    vr_tab_sald EXTR0001.typ_tab_saldos;
    vr_tab_erro GENE0001.typ_tab_erro;
    vr_tab_craplat typ_tab_craplat;
    vr_tab_craplat_efetiv typ_tab_craplat_efetiv;
    vr_tab_craplat_baixado typ_tab_craplat_baixado;
    
    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;

    rw_crapcop cr_crapcop%ROWTYPE;

    -- BUSCA DE ASSOCIADOS
    CURSOR cr_crapass IS
      SELECT ass.nrdconta, ass.cdsecext, ass.cdagenci, ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper;

    rw_crapass cr_crapass%ROWTYPE;

    -- BUSCA DE CONTAS DOS LANCAMENTOS
    CURSOR cr_craplat_carga IS
      SELECT lat.nrdconta
        FROM craplat lat
       WHERE lat.cdcooper = pr_cdcooper          -- CODIGO DA COOPERATIVA
       AND   lat.dtmvtolt <= rw_crapdat.dtmvtolt -- DATA DE MOVIMENTAÇÃO
       AND   lat.insitlat = 1; -- SITUAÇÃO DE LANÇAMENTO 1-PENDENTE, 2-EFETIVADO, 3-ESTORNADO, 4-BAIXADO

    -- BUSCA LANCAMENTOS DE TARIFAS
    CURSOR cr_craplat(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT lat.rowid,
             lat.cdcooper,
             lat.cdagenci,
             lat.nrdconta,
             lat.cdbccxlt,
             lat.nrdolote,
             lat.tpdolote,
             lat.cdoperad,
             lat.nrdctabb,
             lat.nrdctitg,
             lat.cdhistor,
             lat.cdpesqbb,
             lat.cdbanchq,
             lat.cdagechq,
             lat.nrctachq,
             lat.flgaviso,
             lat.tpdaviso,
             lat.vltarifa,
             lat.nrdocmto,
             lat.dttransa
        FROM craplat lat
       WHERE lat.cdcooper = pr_cdcooper
         AND -- CODIGO DA COOPERATIVA
             lat.nrdconta = pr_nrdconta
         AND -- NUMERO DA CONTA DO ASSOCIADO
             lat.dtmvtolt <= rw_crapdat.dtmvtolt
         AND -- DATA DE MOVIMENTAÇÃO
             lat.insitlat = 1; -- SITUAÇÃO DE LANÇAMENTO 1-PENDENTE, 2-EFETIVADO, 3-ESTORNADO, 4-BAIXADO

    rw_craplat cr_craplat%ROWTYPE;

    -- PROCEDURES --

    -- PROCEDURE PARA ATUALIZACAO DE TARIFAS
    PROCEDURE pc_atualiza_tarifa_vigente IS
      
      -- Buscar todas as faixas que devem entrar em vigencia
      CURSOR cr_crapfco IS
        SELECT cdfaixav,
               cdcooper,
               nrconven,
               cdlcremp,
               rowid
          FROM crapfco
         WHERE crapfco.cdcooper = pr_cdcooper
           AND crapfco.dtvigenc > rw_crapdat.dtmvtolt
           AND crapfco.dtvigenc <= rw_crapdat.dtmvtopr
           ORDER BY dtvigenc;
           
      TYPE typ_tab_crapfco IS TABLE OF cr_crapfco%rowtype INDEX BY PLS_INTEGER;
      vr_tab_crapfco typ_tab_crapfco;     
    
    BEGIN
      -- Ler todas as faixas que devem entrar em vigencia
      OPEN cr_crapfco;
      LOOP
        FETCH cr_crapfco BULK COLLECT INTO vr_tab_crapfco LIMIT 10000;
        EXIT WHEN vr_tab_crapfco.COUNT = 0;
        
        BEGIN
          -- Atualizar todas as faixas existentes para esse convenio e faixa para inativa, 
          --pois em seguida irá ativar somente a que esta iniciando a vigencia
          FORALL idx IN 1..vr_tab_crapfco.COUNT SAVE EXCEPTIONS
            UPDATE crapfco
               SET crapfco.flgvigen = 0
             WHERE crapfco.cdcooper = vr_tab_crapfco(idx).cdcooper -- CODIGO DA COOPERATIVA
             AND   crapfco.cdfaixav = vr_tab_crapfco(idx).cdfaixav
             AND   crapfco.nrconven = vr_tab_crapfco(idx).nrconven
             AND   crapfco.cdlcremp = vr_tab_crapfco(idx).cdlcremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro primeira atualizacao crapfco. ERRO:' ||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_erro;
        END;

        -- Ativar faixas de valores de tarifas que esta iniciando a vigencia
        BEGIN
          FORALL idx IN 1..vr_tab_crapfco.COUNT SAVE EXCEPTIONS
            UPDATE crapfco
            SET crapfco.flgvigen = 1
            WHERE crapfco.rowid = vr_tab_crapfco(idx).rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro segunda atualizacao crapfco. ERRO:' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
            RAISE vr_exc_erro;

        END;
      END LOOP;
      CLOSE cr_crapfco;
    EXCEPTION
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro não tratado na rotina pc_atualiza_tarifa_vigente: ' || sqlerrm;
        RAISE vr_exc_erro;

    END;
    -- FIM DECLARACAO PROCEDURES

  BEGIN

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => null);

    -- VALIDAÇÃO DA COOPERATIVA (CRITICA 651) --

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- SE NÃO ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVERÁ RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- DATAS DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR CR_CRAPDAT CURSOR POIS HAVERÁ RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => pr_cdcritic);

    IF vr_cdcritic <> 0 THEN
      -- SAIR DO PROCESSO RETORNANDO A CRITICA
      RAISE vr_exc_erro;
    END IF;

    -- VERIFICACAO SE É FERIADO OU FINAL DE SEMANA
    IF TRUNC(SYSDATE) <> gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => SYSDATE) THEN
      -- ATUALIZA TARIFA VIGENTE
      pc_atualiza_tarifa_vigente;
      --Levantar Excecao
      RAISE vr_exc_fimprg;
    END IF;
    
    IF pr_cdcooper = 1 THEN
      -- CHAMADA DE FUNCAO PARA ATUALIZACAO DE TARIFA
      pc_atualiza_tarifa_vigente;
      RAISE vr_exc_fimprg;
    END IF;  

    -- PROCEDURE PARA BUSCAR TARIFA VIGENTE
    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                           pr_cdbattar => 'TEMPLAUTOM',
                                           pr_dsconteu => vr_dsconteu,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic,
                                           pr_des_erro => vr_des_erro,
                                           pr_tab_erro => vr_tab_erro);

    -- VERIFICA SE HOUVE ERRO NO RETORNO
    IF vr_des_erro = 'NOK' THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      IF vr_tab_erro.count > 0 THEN

        -- RECEBE DESCRICAO DO ERRO QUE OCORREU NA PC_CARREGA_PAR_TARIFA_VIGENTE
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        -- GERA LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- ERRO TRATATO
                                   pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' -' || vr_cdprogra || ' --> ' || vr_dscritic);
      END IF;
      RAISE vr_exc_erro;
    END IF;

    -- CARREGAR CONTAS QUE SERAO PROCESSADAS
    FOR rw_craplat IN cr_craplat_carga LOOP
      vr_tab_craplat(rw_craplat.nrdconta):= 0;
    END LOOP;
      
    -- RECEBE DIA ATUAL
    vr_inttoday := TO_CHAR(SYSDATE, 'dd');

    -- CONSULTA DE COOPERADOS
    FOR rw_crapass IN cr_crapass LOOP
      -- CONTAS QUE POSSUEM INFORMACOES PARA PROCESSAR
      IF vr_tab_craplat.EXISTS(rw_crapass.nrdconta) THEN
        -- CONSULTA DE TARIFAS PENDENTES DO COOPERADO
        FOR rw_craplat IN cr_craplat(pr_nrdconta => rw_crapass.nrdconta) LOOP

          -- RECEBE SOMENTO O DIA DA TRANSACAO REFERENTE AO LANCAMENTO DA TARIFA
          vr_dttransa := NVL(to_number(to_char(rw_craplat.dttransa, 'dd')), 0);

          -- VERIFICA SE A TARIFA ESTA DENTRO DO PERIODO PARAMETRIZADO PARA COBRANCA,
          -- SE ESTOUROU O PRAZO PARA COBRANCA, DEVERA SER FEITA BAIXA DA TARIFA.
          IF vr_dsconteu < (vr_inttoday - vr_dttransa) THEN
            vr_index:= vr_tab_craplat_baixado.count+1;
            vr_tab_craplat_baixado(vr_index).insitlat:= 3; --BAIXADO
            vr_tab_craplat_baixado(vr_index).cdopeest:= '1'; -- CODIGO DO OPERADOR QUE EFETUOU O ESTORNO/BAIXA DA TARIFA
            vr_tab_craplat_baixado(vr_index).dtdestor:= rw_crapdat.dtmvtolt; -- DATA DE MOVIMENTO ATUAL
            vr_tab_craplat_baixado(vr_index).cdmotest:= 99999; -- CODIGO DO MOTIVO DE ESTORNO/BAIXA DA TARIFA
            vr_tab_craplat_baixado(vr_index).dsjusest:= 'Estouro de prazo da cobranca.'; -- JUSTIFICATIVA PARA TER EFETUADO O ESTORNO/BAIXA DA TARIFA
            vr_tab_craplat_baixado(vr_index).vr_rowid:= rw_craplat.rowid;
            --Proximo Registro
            CONTINUE;
          END IF;

          -- OBTENÇÃO DO SALDO DA CONTA SEM O DIA FECHADO
          extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                      pr_rw_crapdat => rw_crapdat,
                                      pr_cdagenci   => 0,
                                      pr_nrdcaixa   => 0,
                                      pr_cdoperad   => pr_cdoperad,
                                      pr_nrdconta   => rw_craplat.nrdconta,
                                      pr_vllimcre   => rw_crapass.vllimcre,
                                      pr_dtrefere   => rw_crapdat.dtmvtopr,
                                      pr_tipo_busca => 'A', --Usar data do dia anterior na crapsda
                                      pr_des_reto   => vr_des_erro,
                                      pr_tab_sald   => vr_tab_sald,
                                      pr_tab_erro   => vr_tab_erro);

          -- VERIFICA SE HOUVE ERRO NO RETORNO
          IF vr_des_erro = 'NOK' THEN
            -- ENVIO CENTRALIZADO DE LOG DE ERRO
            IF vr_tab_erro.count > 0 THEN

              -- RECEBE DESCRICAO DO ERRO QUE OCORREU NA PC_CARREGA_PAR_TARIFA_VIGENTE
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              -- GERA LOG
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratato
                                         pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' -' || vr_cdprogra || ' --> ' || vr_dscritic);
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          -- CRIA LANCAMENTO APENAS SE SALDO EM CC FOR MAIOR QUE ZERO
          IF vr_tab_sald.COUNT > 0 THEN
            IF (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre) >= rw_craplat.vltarifa THEN

              -- LANCAMENTO DE TARIFAS NA CONTA CORRENTE
              tari0001.pc_lan_tarifa_conta_corrente(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                                   ,pr_cdagenci => rw_craplat.cdagenci --Codigo Agencia
                                                   ,pr_nrdconta => rw_craplat.nrdconta --Numero da Conta
                                                   ,pr_cdbccxlt => rw_craplat.cdbccxlt --Codigo Bco/Ag/Caixa
                                                   ,pr_nrdolote => rw_craplat.nrdolote --Numero do Lote
                                                   ,pr_tplotmov => rw_craplat.tpdolote --Tipo Lote
                                                   ,pr_cdoperad => rw_craplat.cdoperad --Codigo Operador
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtopr --Data Movimento Atual
                                                   ,pr_nrdctabb => rw_craplat.nrdctabb --Numero Conta BB
                                                   ,pr_nrdctitg => rw_craplat.nrdctitg --Numero Conta Integr.
                                                   ,pr_cdhistor => rw_craplat.cdhistor --Codigo Historico
                                                   ,pr_cdpesqbb => rw_craplat.cdpesqbb --Codigo Pesquisa
                                                   ,pr_cdbanchq => rw_craplat.cdbanchq --Codigo Banco Cheque
                                                   ,pr_cdagechq => rw_craplat.cdagechq --Codigo Agencia Cheque
                                                   ,pr_nrctachq => rw_craplat.nrctachq --Numero Conta Cheque
                                                   ,pr_flgaviso => (rw_craplat.flgaviso = 1) --Flag Aviso
                                                   ,pr_cdsecext => rw_crapass.cdsecext --Cod Extrato Externo
                                                   ,pr_tpdaviso => rw_craplat.tpdaviso --Tipo de Aviso
                                                   ,pr_vltarifa => rw_craplat.vltarifa --Valor da Tarifa
                                                   ,pr_nrdocmto => rw_craplat.nrdocmto --Numero do Documento
                                                   ,pr_cdageass => rw_crapass.cdagenci --Cod Ag Associado
                                                   ,pr_cdcoptfn => 0 --Codigo Coop Terminal
                                                   ,pr_cdagetfn => 0 --Codigo Ag do Terminal
                                                   ,pr_nrterfin => 0 --Numero do Terminal
                                                   ,pr_nrsequni => 0 --Num Sequencial Unico
                                                   ,pr_nrautdoc => 0 --Num Autentic. Docmnto
                                                   ,pr_dsidenti => NULL --Descr da Identificacao
                                                   ,pr_inproces => rw_crapdat.inproces --Indicador do Processo
                                                   ,pr_tab_erro => vr_tab_erro --Tabela de retorno de erro
                                                   ,pr_cdcritic => vr_cdcritic --Código do erro
                                                   ,pr_dscritic => vr_dscritic); --Descricao do erro

              -- SE OCORREU ERRO
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                -- LEVANTAR EXCECAO
                RAISE vr_exc_erro;
              END IF;

              -- ATUALIZA O REGISTRO DO LANCAMENTO DE TARIFAS
              vr_index:= vr_tab_craplat_efetiv.count+1;
              vr_tab_craplat_efetiv(vr_index).insitlat:= 2; --EFETIVADO
              vr_tab_craplat_efetiv(vr_index).dtefetiv:= rw_crapdat.dtmvtopr;
              vr_tab_craplat_efetiv(vr_index).vr_rowid:= rw_craplat.rowid;
            END IF;
          END IF;
        END LOOP; -- FINAL DO LOOP RW_CRAPLAT
      END IF;  
    END LOOP; -- FINAL DO LOOP RW_CRAPASS

    -- ATUALIZAR CRAPLAT BAIXADOS
    BEGIN
      FORALL idx IN 1..vr_tab_craplat_baixado.COUNT SAVE EXCEPTIONS
        UPDATE craplat 
        SET craplat.insitlat = vr_tab_craplat_baixado(idx).insitlat,
            craplat.cdopeest = vr_tab_craplat_baixado(idx).cdopeest,
            craplat.dtdestor = vr_tab_craplat_baixado(idx).dtdestor,
            craplat.cdmotest = vr_tab_craplat_baixado(idx).cdmotest,
            craplat.dsjusest = vr_tab_craplat_baixado(idx).dsjusest
        WHERE  craplat.rowid = vr_tab_craplat_baixado(idx).vr_rowid;     
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro de atualização na CRAPLAT (1). ERRO:' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;

    -- ATUALIZAR CRAPLAT EFETIVADO
    BEGIN
      FORALL idx IN 1..vr_tab_craplat_efetiv.COUNT SAVE EXCEPTIONS
        UPDATE craplat 
        SET craplat.insitlat = vr_tab_craplat_efetiv(idx).insitlat,
            craplat.dtefetiv = vr_tab_craplat_efetiv(idx).dtefetiv
        WHERE  craplat.rowid = vr_tab_craplat_efetiv(idx).vr_rowid;     
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro de atualização na CRAPLAT (2). ERRO:' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;
          
    -- CHAMADA DE FUNCAO PARA ATUALIZACAO DE TARIFA
    pc_atualiza_tarifa_vigente;

    -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    COMMIT;   
  -- VERIFICA SE EXISTE ALGUMA EXCECAO
  EXCEPTION

    WHEN vr_exc_fimprg THEN

      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- SE FOI GERADA CRITICA PARA ENVIO AO LOG
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

        -- ENVIO CENTRALIZADO DE LOG DE ERRO
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- ERRO TRATATO
                                   pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' -' || vr_cdprogra || ' --> ' || vr_dscritic);

      END IF;

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);

      -- EFETUAR COMMIT POIS GRAVAREMOS O QUE FOI PROCESSO ATÉ ENTÃO
      COMMIT;

    WHEN vr_exc_erro THEN

      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN

        -- BUSCAR A DESCRIÇÃO DO ERRO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      END IF;

      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- EFETUAR ROLLBACK(VOLTA AS ALTERAÇÕES QUE FORAM REALIZADAS)
      ROLLBACK;

    WHEN OTHERS THEN

      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- EFETUAR ROLLBACK(VOLTA AS ALTERAÇÕES QUE FORAM REALIZADAS)
      ROLLBACK;

  END;

END PC_CRPS639;
/
