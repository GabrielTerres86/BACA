CREATE OR REPLACE PROCEDURE cecred.PC_CRPS509 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                               ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                               ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                               ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                               ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps509                        Antigo: Fontes/crps509.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008                        Ultima atualizacao: 23/01/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 005. Efetuar debito de agendamentos feitos
               na Internet.

   Alteracoes: 17/06/2011 - Ajuste devido a alteracao da include (Henrique).

               31/10/2011 - Alterar situacao das transacoes pendentes de
                            operadores na internet(Guilherme).

               24/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)
               
               01/07/2014 - Tratamento para que o dtmvtopg seja a data do 
                            movimento atual qdo inproces = 1 
                            Prj automatiza compe (Tiago/Aline).
                            
               14/11/2014 - Incluido rotina de geração de arquivo de retorno de
                            pagamento de títulos agendados por arquivo ref. ao
                            Projeto 57-Upload de pagamento por arquivo (Rafael)
                            
               19/11/2015 - Alterado tratamento do para definir a data de acordo com o inprocess,
                            procedimento será rodado por job e inproces sempre será 1.
                          - Incluido tratamento para identificar se é o ultimo processo do dia, 
                            pois programa pode rodar diversas vezes no dia conforme configuração.
                            SD358499 (Odirlei-AMcom)
                            
               16/12/2015 - Atualização da situação dos agendamentos conforme solicitado no
                            chamado 335940 (Kelvin)
                            
               30/12/2015 - Ajuste na chamada da proc. pc_atualiza_trans_nao_efetiv, adicionado
                            param de saida pr_dstransa. (Jorge/David) Proj. 131 - Assinatura Multipla 
                            
               25/05/2016 - Ajustes realizados:
                            -> Passagem do novo parametro para a rotina que busca os agendamentos;
                            -> Não alterar a situação de agendamentos de TED para 4 - não efetivado
                            (Adriano - M117).             
                            
               23/01/2017 - COMMIT após SICR0001.pc_controle_exec_deb para mesmo que haja um
                            ROLlBACK avançar no controle das execuções 
                            SD590929 e SD594359  (Tiago/Fabricio).
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps509 */

       --Definicao das tabelas de memoria
       vr_tab_agendto PAGA0001.typ_tab_agendto;

       /* Cursores da rotina crps509 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;


       --Variaveis Locais

       vr_flsgproc     BOOLEAN;
       vr_cdcritic     INTEGER;
       vr_dtmvtopg     DATE;
       vr_cdprogra     VARCHAR2(10);
       vr_dstransa     VARCHAR2(4000);
       
       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;
       vr_dtmvtopr     DATE;
       vr_dtmvtoan     DATE;
       vr_dtultdia     DATE;
       vr_qtdiaute     INTEGER;
       vr_flultexe     INTEGER;
       vr_qtdexec      INTEGER;
       
       --Variaveis para retorno de erro
       vr_dscritic    VARCHAR2(4000);
       vr_dstextab    VARCHAR2(1000);

       --Variaveis de Excecao
       vr_exc_saida   EXCEPTION;
       vr_exc_fimprg  EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_agendto.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps509.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps509
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS509';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS509'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
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
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
         --Ultimo dia do mes anterior
         vr_dtultdia:= rw_crapdat.dtultdma;
         --Determinar a data do proximo pagamento
         vr_dtmvtopg:= rw_crapdat.dtmvtolt;
                           
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
       SICR0001.pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper        --> Código da coopertiva
                                      ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento                                
                                      ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa                                  
                                      ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

       IF nvl(vr_cdcritic,0) > 0 OR
          TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_saida; 
       END IF;             

       --Commit para garantir o 
       --controle de execucao do programa
       COMMIT;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       /* Valido somente para InternetBank, por isto pac 90 */
       PAGA0001.pc_atualiza_trans_nao_efetiv (pr_cdcooper => pr_cdcooper   --Código da Cooperativa
                                             ,pr_nrdconta => 0             --Numero da Conta
                                             ,pr_cdagenci => 90            --Código da Agencia
                                             ,pr_dtmvtolt => vr_dtmvtopg   --Data Proximo Pagamento
                                             ,pr_dstransa => vr_dstransa   --Msg Transação
                                             ,pr_cdcritic => vr_cdcritic   --Codigo erro
                                             ,pr_dscritic => vr_dscritic); --Descricao erro
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Essa informacao é necessária para a rotina pc_calc_poupanca
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRTITULO'
                                               ,pr_tpregist => 90);

       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic := 'Tabela HRTRTITULO nao cadastrada.';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Determinar se é segundo processo
       vr_flsgproc:=  SUBSTR(Upper(vr_dstextab),15,3) = 'SIM';

       --Obter Agendamentos de Debito
       PAGA0001.pc_obtem_agend_debitos (pr_cdcooper    => pr_cdcooper         --Cooperativa
                                       ,pr_dtmvtopg    => vr_dtmvtopg         --Data de pagamento
                                       ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                       ,pr_cdprogra    => vr_cdprogra         --Nome do programa
                                       ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                       ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                       ,pr_dscritic    => vr_dscritic);       --Descricao da Critica
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Efetuar Debitos
       PAGA0001.pc_efetua_debitos (pr_cdcooper    => pr_cdcooper         --Cooperativa
                                  ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                  ,pr_cdprogra    => vr_cdprogra         --Codigo programa
                                  ,pr_dtmvtopg    => vr_dtmvtopg         --Data Pagamento
                                  ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                  ,pr_flsgproc    => vr_flsgproc         --Flag segundo processamento
                                  ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                  ,pr_dscritic    => vr_dscritic);       --Descricao da critica;
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
       
       -- Proj. Pagamento de Titulos - Gera registro de Retorno
       IF vr_flultexe = 1 THEN -- Apenas na ultima execução do processo
          PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => vr_dtmvtopg
                                          , pr_idorigem => 3    -- Ayllos
                                          , pr_cdoperad => '1'
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic );
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
          END IF;
       END IF;              
       
       IF rw_crapdat.inproces = 1 THEN
         UPDATE craplau lau
            SET lau.insitlau = 4
               ,lau.dtdebito = lau.dtmvtopg 
               ,lau.cdcritic = 999
          WHERE lau.cdcooper = pr_cdcooper
            AND lau.dsorigem IN ('INTERNET','TAA')
            AND lau.insitlau = 1
            AND lau.dtmvtopg BETWEEN vr_dtmvtoan - 7 AND vr_dtmvtoan
            AND lau.cdtiptra <> 4; --TED
       END IF;
           
       --Gerar Relatorio
       PAGA0001.pc_gera_relatorio (pr_cdcooper    => 0              --Todas Cooperativas
                                  ,pr_cdprogra    => vr_cdprogra    --Codigo Programa
                                  ,pr_tab_agendto => vr_tab_agendto --Tabela de memoria c/ agendamentos
                                  ,pr_rw_crapdat  => rw_crapdat     --Registro de Datas
                                  ,pr_cdcritic    => vr_cdcritic    --Codigo da Critica
                                  ,pr_dscritic    => vr_dscritic);  --Descricao da critica;
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Salvar informacoes no banco de dados
       COMMIT;
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
         --Limpar variaveis retorno
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Efetuar commit pois gravaremos o que foi processo até então
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
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na procedure pc_crps509. '||sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;
     END;
   END pc_crps509;
/
