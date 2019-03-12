CREATE OR REPLACE PROCEDURE CECRED.pc_crps525 
                            (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                            ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                            ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /*........................................................................

    Programa: PC_CRPS525                          (Antigo Fontes/crps525.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Fernando
    Data    : Abril/2009                      Ultima Atualizacao: 26/09/2016
    Dados referente ao programa:

    Frequencia: Diario.

    Objetivo  : Criar tarifas de custodia de cheques custodiados no dia

    Alteracoes: 15/01/2013 - Conversão Progress >> Oracle PLSQL (Jean Michel)
                
                26/09/2016 - Programa reformulado para cobrar tarifa, geração do relatorio
                             não ocorrerá mais no batch e sim via tela.
                             PRJ300 - Desconto de cheque (Odirlei-AMcom)
                             
..............................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS525';

	  -- Data de Corte Liberação do Projeto 300
	  vr_dtacorte DATE := TO_DATE('23/05/2017','DD/MM/RRRR');

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      --> Buscar custodias criada no dia
      CURSOR cr_crapcst (pr_cdcooper crapcst.cdcooper%TYPE,
                         pr_dtmvtolt crapcst.dtmvtolt%TYPE )IS
       SELECT cst.cdcooper
             ,cst.nrdconta
             ,cst.nrborder
             ,ass.inpessoa
             ,MAX(cst.nrdolote)   nrdolote
             ,COUNT(cst.nrdconta) nrqtddcc
         FROM crapcst cst
             ,crapass ass
        WHERE cst.cdcooper = ass.cdcooper
          AND cst.nrdconta = ass.nrdconta
          AND cst.cdcooper = pr_cdcooper
          AND cst.dtmvtolt = pr_dtmvtolt
		  AND cst.dtmvtolt > vr_dtacorte
          AND cst.dtdevolu IS NULL
          AND cst.cdbccxlt = 600
        GROUP BY cst.cdcooper
                ,cst.nrdconta
                ,cst.nrborder
                ,ass.inpessoa
        ORDER BY cst.cdcooper
                ,cst.nrdconta;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_rec_tarcust 
           IS RECORD (cdhistor   INTEGER,
                      cdhisest   INTEGER,
                      vltarifa   NUMBER,
                      dtdivulg   DATE,
                      dtvigenc   DATE,
                      cdfvlcop   INTEGER);

      TYPE typ_tab_tarcust IS TABLE OF typ_rec_tarcust
           INDEX BY PLS_INTEGER;

      ------------------------------- VARIAVEIS -------------------------------
      vr_tab_tarcust   typ_tab_tarcust;
      vr_cdbattar      VARCHAR2(100);
      vr_cdhistor      INTEGER;
      vr_cdhisest      INTEGER;
      vr_vltarifa      NUMBER;
      vr_dtdivulg      DATE;
      vr_dtvigenc      DATE;
      vr_cdfvlcop      INTEGER;
      vr_vltottar      NUMBER := 0;
      vr_rowid         ROWID;
           
      vr_qtacobra      INTEGER;
      vr_fliseope      INTEGER;

      --------------------------- SUBROTINAS INTERNAS --------------------------



    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
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

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      FOR i IN 1..2 LOOP

        -- Codigo da tarifa
        IF i = 1 THEN
          vr_cdbattar := 'CUSTDCTOPF';
        ELSE
          vr_cdbattar := 'CUSTDCTOPJ';
        END IF;

        --> Carregar Tarifas de pessoa fisica e juridica      
        TARI0001.pc_carrega_dados_tar_vigente ( pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                               ,pr_cdbattar  => vr_cdbattar   -- Codigo Tarifa
                                               ,pr_vllanmto  => 0             -- Valor Lancamento
                                               ,pr_cdprogra  => 'CUST0001'    -- Codigo Programa
                                               ,pr_cdhistor  => vr_tab_tarcust(i).cdhistor   -- Codigo Historico
                                               ,pr_cdhisest  => vr_tab_tarcust(i).cdhisest   -- Historico Estorno
                                               ,pr_vltarifa  => vr_tab_tarcust(i).vltarifa   -- Valor tarifa
                                               ,pr_dtdivulg  => vr_tab_tarcust(i).dtdivulg   -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_tab_tarcust(i).dtvigenc   -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_tab_tarcust(i).cdfvlcop   -- Codigo faixa valor cooperativa
                                               ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                               ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                               ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel carregar a tarifa.';
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
      END LOOP;

      
      --> Buscar custodias criada no dia
      FOR rw_crapcst IN cr_crapcst (pr_cdcooper => pr_cdcooper,
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                          
        -- Codigo da tarifa
        IF rw_crapcst.inpessoa = 1 THEN
          --> CUSTDCTOPF
          vr_cdhistor := vr_tab_tarcust(1).cdhistor;
          vr_cdhisest := vr_tab_tarcust(1).cdhisest;
          vr_vltarifa := vr_tab_tarcust(1).vltarifa;
          vr_dtdivulg := vr_tab_tarcust(1).dtdivulg;
          vr_dtvigenc := vr_tab_tarcust(1).dtvigenc;
          vr_cdfvlcop := vr_tab_tarcust(1).cdfvlcop;
          
        ELSE
          --> CUSTDCTOPJ
          vr_cdhistor := vr_tab_tarcust(2).cdhistor;
          vr_cdhisest := vr_tab_tarcust(2).cdhisest;
          vr_vltarifa := vr_tab_tarcust(2).vltarifa;
          vr_dtdivulg := vr_tab_tarcust(2).dtdivulg;
          vr_dtvigenc := vr_tab_tarcust(2).dtvigenc;
          vr_cdfvlcop := vr_tab_tarcust(2).cdfvlcop;
          END IF;
     
        -- O valor sera baseado na quantidade(crapcst) de cheques, multiplicado pelo valor da tarifa
        vr_vltottar := vr_vltarifa * rw_crapcst.nrqtddcc;--> vr_nrqtddcc;
         
         
        --> Efetua verificacao para cobrancas de tarifas sobre operacoes 
        TARI0001.pc_verifica_tarifa_operacao( pr_cdcooper => rw_crapcst.cdcooper      --> Codigo da Cooperativa
                                             ,pr_cdoperad => '1'                      --> Codigo Operador
                                             ,pr_cdagenci => 1                        --> Codigo Agencia
                                             ,pr_cdbccxlt => 100                      --> Codigo banco caixa
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt      --> Data Lancamento
                                             ,pr_cdprogra => 'CRPS525'                --> Nome do Programa que chama a rotina
                                             ,pr_idorigem => 7                        --> Identificador Origem(1-AYLLOS,2-CAIXA,3-INTERNET,4-TAA,5-AYLLOS WEB,6-URA)
                                             ,pr_nrdconta => rw_crapcst.nrdconta      --> Numero da Conta
                                             ,pr_tipotari => 3                        --> Tipo de Tarifa(1-Saque,2-Consulta)
                                             ,pr_tipostaa => 0                        --> Tipo de TAA que foi efetuado a operacao(1-BB, 2-Banco 24h, 3-Banco 24h compartilhado, 4-Rede Cirrus)
                                             ,pr_qtoperac => rw_crapcst.nrqtddcc              --> Quantidade de registros da operação (Custódia, contra-ordem, folhas de cheque)
                                             ,pr_qtacobra => vr_qtacobra              --> Quantidade de registros a cobrar tarifa na operação
                                             ,pr_fliseope => vr_fliseope              --> Flag indica se ira isentar tarifa:0-Não isenta,1-Isenta
                                             ,pr_cdcritic => vr_cdcritic              --> Codigo da critica
                                             ,pr_dscritic => vr_dscritic);            --> Descricao da critica

        -- Se ocorreu erro
        IF nvl(vr_cdcritic,0) <> 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        
        IF vr_fliseope <> 1 THEN

          -- Se a quantidade de registros a cobrar tarifa na operação for maior que 0
          IF vr_qtacobra > 0 THEN
             -- Atribui novo valor total a cobrar
             vr_vltottar := vr_qtacobra * vr_vltarifa;
          END IF;         
         
          -- Criar Lancamento automatico tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => rw_crapcst.cdcooper
                                          ,pr_nrdconta      => rw_crapcst.nrdconta
                                          ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                          ,pr_cdhistor      => vr_cdhistor
                                          ,pr_vllanaut      => vr_vltottar
                                          ,pr_cdoperad      => '1'
                                          ,pr_cdagenci      => 1
                                          ,pr_cdbccxlt      => 100
                                          ,pr_nrdolote      => 10133
                                          ,pr_tpdolote      => 1
                                          ,pr_nrdocmto      => rw_crapcst.nrdolote
                                          ,pr_nrdctabb      => rw_crapcst.nrdconta
                                          ,pr_nrdctitg      => GENE0002.fn_mask(rw_crapcst.nrdconta,'99999999')
                                          ,pr_cdpesqbb      => ' '
                                          ,pr_cdbanchq      => 0
                                          ,pr_cdagechq      => 0
                                          ,pr_nrctachq      => 0
                                          ,pr_flgaviso      => FALSE
                                          ,pr_tpdaviso      => 0
                                          ,pr_cdfvlcop      => vr_cdfvlcop
                                          ,pr_inproces      => rw_crapdat.inproces
                                          ,pr_rowid_craplat => vr_rowid
                                          ,pr_tab_erro      => vr_tab_erro
                                          ,pr_cdcritic      => vr_cdcritic
                                          ,pr_dscritic      => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento tarifa de custodia de cheque.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
         
        END IF;
        
      END LOOP;                              
      
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, chama a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;

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

  END pc_crps525;
/
