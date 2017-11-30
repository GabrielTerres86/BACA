CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS335(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                      ,pr_cdoperad IN VARCHAR2                --> Código de cooperado
                                      ,pr_inproces IN PLS_INTEGER             --> Indicador de processo
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: Fontes/crps335.p (Antigo pc_crps335)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Dezembro/2002                   Ultima atualizacao: 25/08/2015

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 001.
                   Lancar tarifa de debito em conta corrente se a conta estiver
                   negativa e houver comp no dia.

       Alteracoes: 12/04/2004 - Tabela Alterada de VLTARIFEST p/VLTARIFDIV(Mirtes)

                   30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                                e craplcm (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   30/06/2008 - Incluida chave de acesso
                                (craphis.cdcooper = glb_cdcooper ) no "find".
                                - Kbase IT Solutions - Paulo Ricardo Maciel.

                   30/10/2008 - Alterado lote 8452 para 10029 (Magui).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   08/01/2010 - Acrescentar historicos 469 e 572 na variavel
                                aux_lshistor (Guilherme/Precise)

                   02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Precise)

                   07/05/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                   09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                                o restart (Marcos-Supero)

                   14/08/2013 - Retirado busca valor tarifa na tabela craptab, incluso
                                tratamento para utilizar rotinas da b1wgen0153 para
                                buscar valor tarifa e para efetuarem lancamento tarifa
                                (Daniel).

                   11/10/2013 - Incluido parametro cdprogra nas procedures da
                                b1wgen0153 que carregamdados de tarifas (Tiago).

                   11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                                das criticas e chamadas a fimprg.p (Douglas Pagel)

                   25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)
                   
                   18/08/2015 - Ajuste para nao verificar mais compensacao de cheques e tratamento 
                                para montagem de saldo da conta sem os registros da CRAPLCM.
                                Projeto 218 Melhorias Tarifas - (Carlos Rafael Tanholi)
                   
                   25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                                tari0001.pc_cria_lan_auto_tarifa, projeto de 
                                Tarifas-218(Jean Michel) 
                                
                   05/11/2015 - Incluir condição para gerar cobrança de tarifa somente quando o 
                                valor do estouro for superior a R$ -20,00. 
                                Projeto 218 Melhorias Tarifas - (Carlos Rafael Tanholi)                                
                                
                   04/12/2015 - Incluida condição para cobrança de tarifa de pessoa juridica
                                somente se o saldo do dia anterior for inferior ao saldo atual
                                Projeto 218 Melhorias Tarifas - (Carlos Rafael Tanholi)       
                          
                   25/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
                                Heitor (Mouts) - Melhoria 440
                          
    ............................................................................. */
    DECLARE
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS335';
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      -- Instancia TEMP TABLE referente a tabela CRAPERR
      vr_tab_craterr GENE0001.typ_tab_erro;
      vr_vlslnegat NUMBER := -20.0;
      vr_slddiaanterior NUMBER;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;     --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);            --> String genérica com informações para restart
      vr_inrestar INTEGER;                   --> Indicador de Restart
      vr_ultlcm_found BOOLEAN;               --> utilizado para validacao de ultimo lcto >= 30 dias

      -- Variaves do processo
      vr_vltarest    NUMBER;                 --> Valor da tarifa
      vr_vlsldtot    NUMBER;                 --> Saldo total da conta
      vr_flgcompe    BOOLEAN;                --> Flag de compensação de cheques
      vr_qtregatu    NUMBER := 0;            --> Quantidade de registros atualizados
      vr_cdhisest    PLS_INTEGER;            --> Código de histórico
      vr_dtdivulg    DATE;                   --> Data de divulgação
      vr_dtvigenc    DATE;                   --> Data de vigência
      vr_cdhistor_pf PLS_INTEGER;            --> Código de histórico pessoa física
      vr_cdfvlcop_pf PLS_INTEGER;            --> Código valor pessoa física
      vr_vltarifa_pf NUMBER(20,2);           --> Valor de taria pessoa física
      vr_cdhistor_pj PLS_INTEGER;            --> Código de histórico pessoa jurídica
      vr_cdfvlcop_pj PLS_INTEGER;            --> Código valor pessoa jurídica
      vr_vltarifa_pj NUMBER(20,2);           --> Valor de taria pessoa jurídica
      vr_cdbattar    VARCHAR2(400);          --> Controle
      vr_cdhistor_tr PLS_INTEGER;            --> Código histórico
      vr_cdfvlcop_tr PLS_INTEGER;            --> Valor por cooperativa
      vr_rowidlap    VARCHAR2(200);          --> Índice da PL Table de erros
      

      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      /* Rowtype genérico de calendário */
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Busca informações do saldo da conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsdblfp
              ,sld.vlsdbloq
              ,sld.vlsdblpr
              ,sld.vlsddisp
              ,sld.vlsdchsl
          FROM crapsld sld
         WHERE sld.cdcooper = pr_cdcooper;

      -- Definição de tipo e tabela para armazenar as informações de
      -- saldo da conta sendo a chave o número da conta, isto ajuda
      -- no desempenho
      TYPE typ_reg_crapsld IS
        RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld INDEX BY BINARY_INTEGER; --> A conta será a chave
      -- Vetor para armazenar os dados de saldo
      vr_tab_crapsld typ_tab_crapsld;

      -- Busca dos dados dos históricos de lançamentos da Cooperativa
      CURSOR cr_craphis IS
        SELECT cdhistor
              ,inhistor
          FROM craphis
         WHERE cdcooper = pr_cdcooper;

      -- Definição de tabela para armazenar as informações de
      -- indicador de tipo de histórico de lançamentos da Cooperativa
      TYPE typ_tab_inhistor IS TABLE OF craphis.inhistor%TYPE INDEX BY BINARY_INTEGER; --> O código do histórico será a chave
      -- Vetor para armazenar
      vr_tab_inhistor typ_tab_inhistor;

      -- Busca dos associados da cooperativa
      CURSOR cr_crapass IS
        SELECT nrdconta
              ,vllimcre
              ,inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta > vr_nrctares  --> Conta do restart, se não houve, teremos 0 neste valor
         ORDER BY crapass.cdcooper, crapass.nrdconta;


      -- Buscar o ultimo lançamento automatico da conta para o historico "ADTODEPOPF"
      CURSOR cr_craplat_ultlcm(pr_nrdconta IN craplcm.nrdconta%TYPE
                              ,pr_cdhistor IN craplat.cdhistor%TYPE) IS
        SELECT dtmvtolt
          FROM craplat
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdhistor = pr_cdhistor --> "ADTODEPOPF"
           AND dtdestor IS NULL  -- que nao tenha sido estornado
           ORDER BY dtmvtolt DESC; -- recupera o ultimo registro por data
       
      rw_craplat_ultlcm cr_craplat_ultlcm%ROWTYPE;    

      -- busca saldo do dia anterior
      CURSOR cr_crapsda(pr_nrdconta IN craplcm.nrdconta%TYPE) IS
      
        SELECT vlsdblfp,vlsdbloq,vlsdblpr, 
               vlsddisp,vlsdchsl,vllimcre
          FROM crapsda
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta 
           AND dtmvtolt = rw_crapdat.dtmvtoan; -- recupera registro do dia anterior

      rw_crapsda cr_crapsda%ROWTYPE;  


    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
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

      -- Adiantamento a Depositante Pessoa Fisica
      vr_cdbattar := 'ADTODEPOPF';

      -- Busca valor da tarifa pessoa fisica
      tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_vllanmto => 1
                                           ,pr_cdprogra => vr_cdprogra
                                           ,pr_cdhistor => vr_cdhistor_pf
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => vr_vltarifa_pf
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop_pf
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_craterr);

      -- Verifica se ocorreram erros
      IF vr_dscritic = 'NOK' THEN
        -- Verifica se tabela de erros contém registros
        IF vr_tab_craterr.exists(vr_tab_craterr.first) THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> '
                                                     || vr_tab_craterr(vr_tab_craterr.first).dscritic || ' - ' || vr_cdbattar);
        END IF;
      END IF;

      -- Adiantamente a Depositante Pessoa Juridica
      vr_cdbattar := 'ADTODEPOPJ';

      -- Busca valor da tarifa pessoa fisic
      tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                           ,pr_cdbattar => vr_cdbattar
                                           ,pr_vllanmto => 1
                                           ,pr_cdprogra => vr_cdprogra
                                           ,pr_cdhistor => vr_cdhistor_pj
                                           ,pr_cdhisest => vr_cdhisest
                                           ,pr_vltarifa => vr_vltarifa_pj
                                           ,pr_dtdivulg => vr_dtdivulg
                                           ,pr_dtvigenc => vr_dtvigenc
                                           ,pr_cdfvlcop => vr_cdfvlcop_pj
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_tab_erro => vr_tab_craterr);

      -- Verifica se ocorreram erros
      IF vr_dscritic = 'NOK' THEN
        -- Verifica se tabela de erros contém registros
        IF vr_tab_craterr.exists(vr_tab_craterr.first) THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> '
                                                     || vr_tab_craterr(vr_tab_craterr.first).dscritic || ' - ' || vr_cdbattar);
        END IF;
      END IF;

      -- Realiza consistencia para valores de tarifa igual a zero
      IF vr_vltarifa_pf = 0 AND vr_vltarifa_pj = 0 THEN
        RAISE vr_exc_fimprg;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Saida de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro

      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      -- Buscar as informações da CRAPSLD - Saldos da Conta
      FOR rw_crapsld IN cr_crapsld LOOP
        -- Carregar a temp-table com as informações do
        -- registro. Este processo faz com que diminuam
        -- as leituras no banco pois não teremos esse select
        -- para cada conta, mas sim direto na temp-table
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := NVL(rw_crapsld.vlsdblfp,0);
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := NVL(rw_crapsld.vlsdbloq,0);
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := NVL(rw_crapsld.vlsdblpr,0);
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := NVL(rw_crapsld.vlsddisp,0);
        vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := NVL(rw_crapsld.vlsdchsl,0);
      END LOOP;

      -- Busca dos dados dos históricos de lançamentos da Cooperativa
      FOR rw_craphis IN cr_craphis LOOP
        -- Carregar em temp-table os indicadores por código de histórico
        -- para dessa forma fazer menos acessos ao banco de dados
        vr_tab_inhistor(rw_craphis.cdhistor) := rw_craphis.inhistor;
      END LOOP;

      -- Processar todos os associados da Cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Valida tipo de pessoa para carga de variáveis
        IF rw_crapass.inpessoa = 2 THEN
          vr_vltarest := vr_vltarifa_pj;
          vr_cdhistor_tr := vr_cdhistor_pj;
          vr_cdfvlcop_tr := vr_cdfvlcop_pj;
        ELSE
          vr_vltarest := vr_vltarifa_pf;
          vr_cdhistor_tr := vr_cdhistor_pf;
          vr_cdfvlcop_tr := vr_cdfvlcop_pf;
        END IF;

        -- Testar se não existe informação de saldo para esse associado
        IF NOT vr_tab_crapsld.EXISTS(rw_crapass.nrdconta) THEN
          -- Gerar critica 10
          pr_cdcritic := 10;
          RAISE vr_exc_saida;
        END IF;

        -- Inicializar controle de compensação
        vr_flgcompe := FALSE;
        -- Somar o saldo total
        vr_vlsldtot := vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp
                     + vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl + NVL(rw_crapass.vllimcre,0);

        -- Se saldo negativo inferior a 20 reais
        IF vr_vlsldtot < vr_vlslnegat THEN
          -- pessoa fisica
          IF rw_crapass.inpessoa = 1 THEN 
             -- filtra lancamentos "ADTODEPOPF" feitos a 30 dias
             OPEN cr_craplat_ultlcm(pr_nrdconta => rw_crapass.nrdconta
                                   ,pr_cdhistor => vr_cdhistor_pf);                                   
             
             FETCH cr_craplat_ultlcm INTO rw_craplat_ultlcm;
             
             -- se o registro nao existir deve cria-lo
             IF cr_craplat_ultlcm%NOTFOUND THEN
               vr_ultlcm_found := TRUE;
             ELSE
               -- ultimo lançamento a mais de 30 dias 
               IF (rw_crapdat.dtmvtolt - rw_craplat_ultlcm.dtmvtolt) > 30 THEN
                  vr_ultlcm_found := TRUE;
               ELSE -- do contrario nao registra novo lancamento
                  vr_ultlcm_found := FALSE;
               END IF;     
             END IF;

             -- fecha cursor
             CLOSE cr_craplat_ultlcm;
             
          ELSE -- pessoa juridica
            
             -- busca o saldo do dia anterior
             OPEN cr_crapsda(pr_nrdconta => rw_crapass.nrdconta);             
             FETCH cr_crapsda INTO rw_crapsda;
             
             --monta o saldo devedor total do dia anterior (CRAPSDA)
             vr_slddiaanterior := rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + NVL(rw_crapsda.vllimcre,0);
             
             IF cr_crapsda%FOUND THEN
                -- saldo atual com valor negativo maior que o saldo de ontem
                IF vr_vlsldtot < vr_slddiaanterior THEN
                   -- cria novo lancamento de tarifa
                   vr_ultlcm_found := TRUE;                   
                ELSE
                   -- se o saldo permance o mesmo nao cria novo lancamento de tarifa
                   vr_ultlcm_found := FALSE; 
                END IF;   
             ELSE
                -- nao ira criar o lancamento
                vr_ultlcm_found := FALSE; 
             END IF;             
             -- fecha cursor
             CLOSE cr_crapsda;             
          END IF;
                    
          -- ira criar a tarifa para PJ, para PF se nao possuir registro nos ultimos 30 dias
          IF vr_ultlcm_found THEN
            -- Criar lançamentos de tarifas
            tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_cdhistor => vr_cdhistor_tr
                                            ,pr_vllanaut => vr_vltarest
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_cdagenci => 1
                                            ,pr_cdbccxlt => 100
                                            ,pr_nrdolote => 10029
                                            ,pr_tpdolote => 1
                                            ,pr_nrdocmto => 0
                                            ,pr_nrdctabb => rw_crapass.nrdconta
                                            ,pr_nrdctitg => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                            ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')
                                            ,pr_cdbanchq => 0
                                            ,pr_cdagechq => 0
                                            ,pr_nrctachq => 0
                                            ,pr_flgaviso => TRUE
                                            ,pr_tpdaviso => 2
                                            ,pr_cdfvlcop => vr_cdfvlcop_tr
                                            ,pr_inproces => pr_inproces
                                            ,pr_rowid_craplat => vr_rowidlap
                                            ,pr_tab_erro => vr_tab_craterr
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);          
            -- Verifica se ocorreram erros
            IF vr_dscritic = 'NOK' THEN
              -- Verifica erro retornado pela tabela de erros
              IF vr_tab_craterr.exists(vr_tab_craterr.first) THEN
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                                                              vr_tab_craterr(vr_tab_craterr.first).dscritic || ' - ' || rw_crapass.nrdconta);
              END IF;
            END IF;
          END IF;

        END IF; -- saldo -20.0        
        
        -- Somente se a flag de restart estiver ativa
        IF pr_flgresta = 1 THEN
          -- Salvar informacoes no banco de dados a cada 10000 registros gravador, gravar tbm o controle
          -- de restart, pois qualquer rollback que será efetuado vai retornar a situação até o ultimo commit
          IF Mod(vr_qtregatu,10000) = 0 THEN
            -- Atualizar a tabela de restart
            BEGIN
              UPDATE crapres res
                 SET res.nrdconta = rw_crapass.nrdconta  -- conta da aplicação atual
               WHERE res.rowid = rw_crapres.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_cdcritic := 151;
                vr_dscritic := gene0001.fn_busca_critica(151)||' - Conta:'||rw_crapass.nrdconta||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Finalmente efetua commit
            COMMIT;
          END IF;
        END IF;
      END LOOP; -- Término do processamento dos associados

      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar commit
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;

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

        -- Devolvemos código e critica encontradas
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
  END pc_crps335;
/
