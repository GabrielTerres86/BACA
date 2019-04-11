CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS753 (pr_cdcooper  IN craptab.cdcooper%TYPE
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_cdagenci  IN PLS_INTEGER DEFAULT 0  --> Código da agência, utilizado no paralelismo
                                              ,pr_idparale  IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.                                              
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2)  IS 

 /*********************************************************************
    **                                                                  **
    ** PROGRAMA: CALCULA OS SALDOS DO DIA DAS APLICAÇÕES DOS COOPERADOS **
    ** AUTOR: DAVID VALENTE [ENVOLTI]                                   **
    ** DATA CRIAÇÃO: 19/03/2019                                         **
    ** DATA MODIFICAÇÃO:                                                **
    ** SISTEMA:                                                         **
    **                                                                  **
    *********************************************************************/

      
      -- Variáveis de retorno da procedure pc_busca_saldo_aplicacoes
      vr_vlsldtot  NUMBER;
      vr_vlsldrgt  NUMBER;

      -- Indice para tabela temporária 
      vr_index_saldo_aplica PLS_INTEGER;

      pr_des_erro VARCHAR2(400); --> ERRO DA EXCEPTION

      -- Constantes
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS753';  --> Nome do programa

      -- Instancia TEMP TABLE referente a tabela CRAPERR
      vr_tab_craterr GENE0001.typ_tab_erro;
                                            
      rw_crapdat btch0001.cr_crapdat%ROWTYPE; --> Buffer do cursor cr_crapdat (BTCH0001) 
      
      -- Variaveis de Excecao
      vr_continua     EXCEPTION; --> Variável para controle da próxima iteração do LOOP
      vr_exc_erro     EXCEPTION; --> Variável para exceção personalizada
      vr_exc_proxepr  EXCEPTION; --> Controle de iteração do cursor crapepr
      vr_exc_pula     EXCEPTION; --> Controle de iteração do cursor

      -- Variaveis projeto ligeiriho
      vr_qterro         NUMBER;
      vr_qtdjobs        NUMBER;
      vr_dsplsql        VARCHAR2(3000);
      vr_jobname        VARCHAR2(500);
      vr_idparale       NUMBER;
      vr_idlog_ini_ger  NUMBER;
      vr_idlog_ini_par  NUMBER;
      vr_tpexecucao     tbgen_prglog.tpexecucao%type;
      --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
      
      --Cursor buscar a informação de todas as agências que o programa será executado.
    --Controlando também a re-execução de uma agência através do parametro pr_qterro
    CURSOR cr_crapage (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_cdagenci IN crapass.cdagenci%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                      ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE
                      ,pr_qterro   IN NUMBER) IS
      select age.cdagenci
        from crapage age
       where age.cdcooper = pr_cdcooper
         and age.cdagenci = decode(pr_cdagenci,0,age.cdagenci,pr_cdagenci)
         and (pr_qterro = 0 or
             (pr_qterro > 0 and exists (select 1
                                          from tbgen_batch_controle
                                         where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                           and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           and tbgen_batch_controle.tpagrupador = 1
                                           and tbgen_batch_controle.cdagrupador = age.cdagenci
                                           and tbgen_batch_controle.insituacao  = 1
                                           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
      order by age.cdagenci asc;

    --Fim - Projeto Ligeirinho

      -- Variáveis locais SUB_ROTINAS
      vr_index_saldo     VARCHAR2(20);
      vr_index_rdacta    VARCHAR2(20);  --> Chave de acesso a tabela
      vr_index_rda       PLS_INTEGER;   -->
      vr_vlsdrdca        NUMBER(20,8);  --> Valor do RDCA
      vr_vlsdeved        NUMBER(20,8);  --> Valor de saldo devedor
      vr_vlsldrdc        NUMBER(20,8);  --> Valor do RDC
      vr_vlsldconcilia   NUMBER(20,8);  --> Valor do Saldo Conciliacao B3
      vr_rd2_vlsdrdca    NUMBER(20,8);  --> Valor de retorno do cálculo do RDCA2
      vr_vlsldapl              NUMBER;  --> Variável para armazenar valor de retorno de RDCA30
      vr_vldperda        NUMBER(20,8);  --> Valor da perda
      vr_txaplica        NUMBER(20,8);  --> Valor da taxa aplicada
      vr_dscritic       VARCHAR2(400);  --> Variável para armazenar a descrição da crítica
      vr_sldpresg        NUMBER(20,8);  --> Valor disponível para resgate
      vr_cdcritic       VARCHAR2(400);  --> Variável para armazenzar mensagens de crítica
      vr_vlrdirrf        NUMBER(20,8);  --> Valor de retorno do cálculo do IRRF
      vr_perirrgt        NUMBER(15,2);  --> Valor do período
      vr_dtinitax                DATE;  --> Data início da taxa de poupança
      vr_dtfimtax                DATE;  --> Data final da taxa de poupança
      vr_vlrentot        NUMBER(20,8);             --> Valor total de rendimento
      vr_tot_vlprerpp    NUMBER(20,8);             --> Valor total do pre      
      vr_vlbascal        NUMBER(20,8) := 0; -- Base de Calculo
      vr_vlultren        NUMBER(20,8) := 0; -- Ultimo Rendimento
      vr_vlrevers        NUMBER(20,8) := 0; -- Valor de Reversão
      vr_percirrf        NUMBER(20,8) := 0; -- Percentual de IRRF 
      vr_inusatab        BOOLEAN;           --> Indicador taxa para rotina saldo_epr.p

      vr_dstextab_tx  craptab.dstextab%TYPE;       --> Variavel para armazenar mensagem tabela generica Taxa      
      vr_percirtab         craptab.dstextab%TYPE;  --> Variavel para armazenar mensagem tabela generica IR
      vr_rpp_vlsdrdpp craprpp.vlsdrdpp%type := 0;  --> Valor do saldo da poupança programada
      vr_dstextab          craptab.dstextab%TYPE;  -->
      vr_dup_vlsdrdca      craplap.vllanmto%TYPE;  --> Acumulo do saldo da aplicacao RDCA     
      
      -- Tipo para instanciar PL TABLE para armazenar registros referentes as aplicação cadastradas
      TYPE typ_reg_crapdtc IS RECORD(tpaplrdc crapdtc.tpaplrdc%TYPE);

      -- Instancia e indexa o tipo da PL TABLE para liberar para uso
      TYPE typ_tab_crapdtc IS TABLE OF typ_reg_crapdtc INDEX BY VARCHAR2(3);
      vr_tab_crapdtc typ_tab_crapdtc;

      -- Cursor dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Código da cooperativa
         SELECT cop.nmrescop
               ,cop.nrtelura
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      
      -- Cursor tipos de captacao oferecidas para o cooperado.
      CURSOR cr_crapdtc(pr_cdcooper  IN crapcob.cdcooper%TYPE) IS --> Código da cooperativa
      SELECT ct.tpaplrdc
            ,ct.tpaplica
      FROM crapdtc ct
      WHERE ct.cdcooper = pr_cdcooper;

      -- Cursor Cadastro dos associados
      CURSOR cr_crapass_1(pr_cdcooper IN craptab.cdcooper%TYPE) IS --> Código da cooperativa
        SELECT crapass.nrdconta
              ,crapass.vllimcre
              ,crapass.cdagenci
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.dtelimin IS NULL
          AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

      -- Cursor Cadastro das aplicações RDCA (Recibo de Depósito Cooperativo)
      CURSOR cr_craprda (pr_cdcooper  IN crapcob.cdcooper%TYPE) IS --> Código da cooperativa
          SELECT  rda.tpaplica
                 ,rda.cdageass
                 ,rda.nrdconta
                 ,rda.nraplica
                 ,rda.dtmvtolt
                 ,rda.vlsdrdca
                 ,decode(rda.tpaplica,8, /* RDCPOS */ rda.qtdiauti, /* RDCPRE */ rda.qtdiaapl) qtdiacar
           FROM craprda rda
               ,crapass ass
           WHERE rda.cdcooper = ass.cdcooper
             AND rda.nrdconta = ass.nrdconta
             AND rda.cdcooper = pr_cdcooper
             AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
             AND rda.insaqtot = 0;                  

       -- Cursor registros de Poupança Programada
      CURSOR cr_craprpp(pr_cdcooper    IN crapcob.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_nrdconta IN craprpp.nrdconta%TYPE) IS --> Número da conta
           SELECT ca.cdsitrpp
                 ,ca.vlprerpp
                 ,ca.nrctrrpp
                 ,ca.dtmvtolt
                 ,ca.rowid                
           FROM craprpp ca
           WHERE ca.cdcooper = pr_cdcooper
             AND ca.nrdconta = pr_nrdconta;

       -- Cursor registros de aplicações de captação NÃO PROGRAMADAS
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                        ,pr_nrdconta IN craprac.nrdconta%TYPE) IS
         SELECT craprac.nraplica nraplica
               ,craprac.cdprodut cdprodut               
               ,craprac.idblqrgt idblqrgt
               ,crapcpc.idtippro idtippro                           
               ,craprac.dtmvtolt
               ,crapcpc.idtxfixa
               ,crapcpc.cddindex
               ,craprac.qtdiacar
               ,craprac.txaplica
               ,craprac.vlbasapl
               ,craprac.nrctrrpp               
           FROM craprac --> Registro de aplicacao da captacao
               ,crapass --> Cadastro de associados
               ,crapcpc --> Cadastro dos produtos de captacao
          WHERE craprac.cdcooper = pr_cdcooper
            AND craprac.nrdconta = pr_nrdconta
			AND craprac.idsaqtot = 0
            AND crapass.cdcooper = craprac.cdcooper
            AND crapass.nrdconta = craprac.nrdconta
            AND crapcpc.cdprodut = craprac.cdprodut;

      --Cursor registros de aplicações POUPANÇA PROGRAMADA
      CURSOR cr_craprpp_conta (pr_cdcooper IN craprpp.cdcooper%TYPE) IS
      SELECT craprpp.nrdconta, craprpp.nrctrrpp
        FROM craprpp --> Cadastro de poupanca programada.
            ,crapass --> Cadastro do Associado
       WHERE craprpp.cdcooper = crapass.cdcooper
         AND craprpp.nrdconta = crapass.nrdconta
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND craprpp.cdcooper = pr_cdcooper;
      
      -- Variavéis com os cursores      
      rw_craprda cr_craprda%ROWTYPE; -- RDA
      rw_craprpp cr_craprpp%rowtype; -- PP
      rw_crapcop cr_crapcop%ROWTYPE; -- Coperativa 
                                     
      -- VARIAVEL DO TIPO ROW cr_craprda
      TYPE typ_rec_craprda IS TABLE OF cr_craprda%ROWTYPE INDEX BY PLS_INTEGER;

      -- INSTANCIA VARIAVEL DO TIPO TABLE origem cr_craprda
      vr_tab_craprda_carga typ_rec_craprda;

      -- VARIAVEL DO TIPO TABLE
      TYPE typ_tab_craprda IS TABLE OF typ_rec_craprda INDEX BY VARCHAR2(20); --cdagencia + nrdconta
      vr_tab_craprda typ_tab_craprda;

      -- Instancia e indexa o tipo da PL TABLE para liberar para uso
      TYPE typ_tab_craprpp IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_craprpp typ_tab_craprpp;
     
      -- Tipo para instanciar PL TABLE Poupança Programada
      TYPE typ_reg_saldo_plano IS RECORD(nrdconta   craprpp.nrdconta%TYPE
                                        ,nrctrrpp   craprpp.nrctrrpp%TYPE
                                        ,vlsdrdpp   craprpp.vlsdrdpp%TYPE);

      -- Instancia e indexa o tipo da PL TABLE para liberar para uso
      TYPE typ_tab_saldo_plano IS TABLE OF typ_reg_saldo_plano INDEX BY VARCHAR2(20);
      vr_tab_saldo_plano  typ_tab_saldo_plano;
      
      -- Estutura de tabela temporária 
      -- para melhorar a performance do insert na tabela TBCAPT_SALDO_APLICA
      TYPE typ_tab_insert_saldo_aplica IS TABLE OF TBCAPT_SALDO_APLICA%ROWTYPE INDEX BY PLS_INTEGER;
      tab_insert_saldo_aplica typ_tab_insert_saldo_aplica;
      
      -- INSERE OS SALDOS DAS APLICAÇÕES DIARIAMENTE
      PROCEDURE pc_insere_saldo_aplic
                  (pr_cdcooper       IN NUMBER --> Código da cooperativa
                  ,pr_nrdconta       IN NUMBER --> Número da conta
                  ,pr_nraplica       IN NUMBER --> Número da Aplicação
                  ,pr_tp_aplica      IN TBCAPT_SALDO_APLICA.TPAPLICACAO%TYPE  --> (1 - RDC POS e PRE / 2 - PCAPTA)
                  ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE
                  ,pr_saldo_bruto    IN TBCAPT_SALDO_APLICA.VLSALDO_BRUTO%TYPE
                  ,pr_saldo_concilia IN TBCAPT_SALDO_APLICA.VLSALDO_CONCILIA%TYPE
                  ,pr_des_erro       OUT VARCHAR2) AS

      BEGIN
         --Inicializar variavel de erro
         pr_des_erro := NULL;              

         BEGIN
           
           -- Verifica se existe indice para a tabela, caso não exista, cria com indice 1
           if not tab_insert_saldo_aplica.exists(1) then
              vr_index_saldo_aplica := 1;   
           else 
              vr_index_saldo_aplica := tab_insert_saldo_aplica.last + 1;
           end if;                                                     
           
           -- Insere o registro com o saldo do dia da aplicação do cooperado
           tab_insert_saldo_aplica(vr_index_saldo_aplica).CDCOOPER         :=  pr_cdcooper;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).NRDCONTA         :=  pr_nrdconta;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).NRAPLICA         :=  pr_nraplica;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).TPAPLICACAO      :=  pr_tp_aplica;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).DTMVTOLT         :=  pr_dtmvtolt;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).VLSALDO_BRUTO    :=  pr_saldo_bruto;
           tab_insert_saldo_aplica(vr_index_saldo_aplica).VLSALDO_CONCILIA :=  pr_saldo_concilia;                                       
                                                                               
         EXCEPTION
          WHEN others THEN
            --Retonar mensagem de erro
            pr_des_erro := 'Erro ao inserir registro na tabela TBCAPT_SALDO_APLICA: ' || sqlerrm;           
         END;

      END; --pc_insere_saldo_aplic
                                            
      -- Subprocedure para execução das SubRotinas
     PROCEDURE pc_sub_rotinas(pr_des_erro OUT VARCHAR2) IS --> Erros no processo
     BEGIN
       DECLARE
         vr_exe_erro  EXCEPTION; --> Variável para controle de exceção              
       BEGIN
         
         -- Alterar module acrescentando action
         GENE0001.pc_informa_acesso(pr_module  => 'PC_'||vr_cdprogra
                                    ,pr_action => 'pc_sub_rotinas');
         --Inicializar mensagem erro
         pr_des_erro:= NULL;

         -- AQUI INICIA TODO O CALCULO
         
         -- Verifica se o cursor está aberto
         IF btch0001.cr_crapdat%ISOPEN = FALSE THEN
             OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
              --Posicionar no proximo registro
              FETCH btch0001.cr_crapdat INTO rw_crapdat;
              --Fechar Cursor
             CLOSE btch0001.cr_crapdat; 
         END IF;      
             
       
         -- Validações iniciais do programa
         btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                                  ,pr_flgbatch => 1
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_cdcritic => pr_cdcritic);

         -- Se retornou algum erro
         IF pr_cdcritic <> 0 THEN
           -- Buscar descricão do erro
           pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
           
           -- Envio centralizado de log de erro
           RAISE vr_exc_erro;
           
         END IF;

         -- Incluir nome do modulo logado
         gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra,
                                   pr_action => vr_cdprogra);
          
         --Inicializar retorno erro
         vr_dscritic := '';


        -- Data de fim e inicio da utilização da taxa de poupança.
        -- Utiliza-se essa data quando o rendimento da aplicação for menor que
        -- a poupança, a cooperativa opta por usar ou não.
        -- Buscar a descrição das faixas contido na craptab
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'MXRENDIPOS'
                                                ,pr_tpregist => 1);

        -- Se não encontrar registros
        IF vr_dstextab IS NULL THEN
          vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
          vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
        ELSE
          vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, vr_dstextab, ';'), 'DD/MM/YYYY');
          vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, vr_dstextab, ';'), 'DD/MM/YYYY');
        END IF;


        -- Carregar PL Table com dados da tabela CRAPDTC
        -- [tipos de captacao oferecidas para o cooperado.]
        FOR vr_crapdtc IN cr_crapdtc(pr_cdcooper) LOOP
          vr_tab_crapdtc(lpad(vr_crapdtc.tpaplica, 3, '0')).tpaplrdc := vr_crapdtc.tpaplrdc;
        END LOOP;

        --Carregar tabela memoria com dados da tabela CRAPRPP
        -- [Cadastro de poupanca programada.]
        FOR rw_craprpp IN cr_craprpp_conta (pr_cdcooper => pr_cdcooper) LOOP
          vr_tab_craprpp(rw_craprpp.nrdconta):= 0;
        END LOOP;

        -- Carregar PL Table com dados da tabela CRAPRDA ou seja, APLICAÇÕES.
        OPEN cr_craprda (pr_cdcooper => pr_cdcooper);
        LOOP

          FETCH cr_craprda BULK COLLECT INTO vr_tab_craprda_carga  LIMIT 100000;
          EXIT WHEN vr_tab_craprda_carga.COUNT = 0;

          FOR idx IN vr_tab_craprda_carga.first..vr_tab_craprda_carga.last LOOP

            --Montar indice para tabela memoria
            vr_index_rdacta:= lpad(vr_tab_craprda_carga(idx).cdageass, 10, '0')||
                              lpad(vr_tab_craprda_carga(idx).nrdconta, 10, '0');

            IF vr_tab_craprda.exists(vr_index_rdacta) THEN
              vr_index_rda := vr_tab_craprda(vr_index_rdacta).count;
            ELSE
              -- caso o indice ainda nao exista, inicializa com zero
              vr_index_rda := 0;
            END IF;
            -- Insere os registros na PL, tabela temporária de APLICAÇÕES.
            vr_tab_craprda(vr_index_rdacta)(vr_index_rda):= vr_tab_craprda_carga(idx);

          END LOOP;

        END LOOP;
        CLOSE cr_craprda; -- FIM BLOCO PL Table com dados da tabela CRAPRDA

        --Selecionar o percentual de IR para calculo poupanca
        vr_percirtab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'CONFIG'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'PERCIRAPLI'
                                                 ,pr_tpregist => 0);

        BEGIN

          -- PERCORRE dados das contas dos associados
          FOR rw_crapass IN cr_crapass_1(pr_cdcooper => pr_cdcooper) LOOP

              -- CHAVE PARA PL TABLE (AGENCIA E CONTA) dados dos associados
              vr_index_rdacta := lpad(rw_crapass.cdagenci, 10, '0')||
                                 lpad(rw_crapass.nrdconta, 10, '0');

              -- VERIFICA SE EXISTE REGISTROS do associado
              IF vr_tab_craprda.exists(vr_index_rdacta) THEN

                  --PERCORRE rendimentos das aplicacoes DO ASSOCIADO
                  FOR idx IN nvl(vr_tab_craprda(vr_index_rdacta).first,0) .. nvl(vr_tab_craprda(vr_index_rdacta).last,-1) LOOP

                      -- PEGA O REGISTRO DA PL TABLE RDA (INDICE AGENCIA E CONTA)
                      rw_craprda := vr_tab_craprda(vr_index_rdacta)(idx);

                      --Zerar variaveis
                      vr_vlsdrdca:= 0;
                      vr_vlsdeved:= 0;
                      vr_vlsldrdc:= 0;
                      vr_rd2_vlsdrdca:= 0;

                      BEGIN  -- INICIO DO BLOCO FOR aplicacoes DO ASSOCIADO

                        IF rw_craprda.tpaplica = 3 THEN

                           --Zerar variavel cálculo
                           vr_vlsdrdca:= 0;

                           -- Cálculo do valor do RDCA
                           apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                ,pr_inproces => rw_crapdat.inproces
                                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                                ,pr_cdprogra => vr_cdprogra
                                                                ,pr_cdagenci => rw_craprda.cdageass
                                                                ,pr_nrdcaixa => 99 --> somente para gerar mensagem em caso de erro
                                                                ,pr_nrdconta => rw_craprda.nrdconta
                                                                ,pr_nraplica => rw_craprda.nraplica
                                                                ,pr_vlsdrdca => vr_vlsdrdca
                                                                ,pr_vlsldapl => vr_vlsldapl
                                                                ,pr_sldpresg => vr_sldpresg         --> Valor saldo de resgate
                                                                ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                                ,pr_vldperda => vr_vldperda
                                                                ,pr_txaplica => vr_txaplica
                                                                ,pr_des_reto => vr_dscritic
                                                                ,pr_tab_erro => vr_tab_craterr);


                           -- Insere registro do saldo do dia
                           pc_insere_saldo_aplic(pr_cdcooper       => pr_cdcooper
                                                ,pr_nrdconta       => rw_craprda.nrdconta
                                                ,pr_nraplica       => rw_craprda.nraplica
                                                ,pr_tp_aplica      => 1
                                                ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                                ,pr_saldo_bruto    => vr_vlsdrdca
                                                ,pr_saldo_concilia => vr_sldpresg
                                                ,pr_des_erro       => vr_dscritic);

                           -- Se o saldo RDCA for zero vai para o próximo registro
                           IF vr_vlsdrdca <= 0 THEN
                             RAISE vr_continua;
                           END IF;

                         ELSIF rw_craprda.tpaplica = 5 THEN

                            --Zerar variavel cálculo
                           vr_rd2_vlsdrdca:= 0;

                           apli0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                                ,pr_cdprogra => vr_cdprogra
                                                                ,pr_cdagenci => rw_craprda.cdageass
                                                                ,pr_nrdcaixa => 99 --> somente para gerar mensagem em caso de erro
                                                                ,pr_nrdconta => rw_craprda.nrdconta
                                                                ,pr_nraplica => rw_craprda.nraplica
                                                                ,pr_vlsdrdca => vr_rd2_vlsdrdca
                                                                ,pr_sldpresg => vr_sldpresg
                                                                ,pr_des_reto => vr_dscritic
                                                                ,pr_tab_erro => vr_tab_craterr);


                            -- Insere registro do saldo do dia
                            pc_insere_saldo_aplic( pr_cdcooper       => pr_cdcooper
                                                  ,pr_nrdconta       => rw_craprda.nrdconta
                                                  ,pr_nraplica       => rw_craprda.nraplica
                                                  ,pr_tp_aplica      => 1
                                                  ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                                  ,pr_saldo_bruto    => vr_rd2_vlsdrdca
                                                  ,pr_saldo_concilia => vr_sldpresg
                                                  ,pr_des_erro       => vr_dscritic);

                           -- Se o valor do RDCA estiver zerado vai para a próxima iteração do LOOP
                           IF vr_rd2_vlsdrdca <= 0 THEN
                             RAISE vr_continua;
                           END IF;


                         ELSE
                            -- Valida se retornou algum valor, gera crítica caso necessário
                           IF NOT vr_tab_crapdtc.exists(lpad(rw_craprda.tpaplica, 3, '0')) THEN
                             vr_cdcritic := 346;
                             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                                       ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                           vr_dscritic || '. ' ||
                                                                           ' Conta/DV: ' || GENE0002.fn_mask_conta(pr_nrdconta => rw_craprda.nrdconta) ||
                                                                           ' - Nr. aplicação: ' || GENE0002.fn_mask(pr_dsorigi => rw_craprda.nraplica, pr_dsforma => 'zzz.zz9'));
                           END IF;

                           -- Limpar valores
                           vr_tab_craterr.DELETE;
                           vr_vlsldrdc := 0;

                           -- Para RDC PRE
                           IF vr_tab_crapdtc(lpad(rw_craprda.tpaplica, 3, '0')).tpaplrdc = 1 THEN

                             --Zerar variavel cálculo
                             vr_vlsldrdc:= 0;

                             -- Calculo do saldo da RDC Pré-fixada
                             apli0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => rw_craprda.nrdconta
                                                      ,pr_nraplica => rw_craprda.nraplica
                                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                      ,pr_dtiniper => NULL
                                                      ,pr_dtfimper => NULL
                                                      ,pr_txaplica => 0
                                                      ,pr_flggrvir => FALSE
                                                      ,pr_tab_crapdat => rw_crapdat
                                                      ,pr_cdprogra => 'CUSAPL'
                                                      ,pr_vlsdrdca => vr_vlsldrdc
                                                      ,pr_vlrdirrf => vr_vlrdirrf
                                                      ,pr_perirrgt => vr_perirrgt
                                                      ,pr_des_reto => vr_dscritic
                                                      ,pr_tab_erro => vr_tab_craterr);


                            /* Para o Saldo para Conciliacao B3, devemos considerar o valor rendido no periodo de carencia */
                            vr_vlsldconcilia := vr_vlsldrdc; --> Saldo da aplicação pós calculo
                            IF APLI0007.fn_tem_carencia(pr_dtmvtapl => rw_craprda.dtmvtolt
                                                       ,pr_qtdiacar => rw_craprda.qtdiacar
                                                       ,pr_dtmvtres => rw_crapdat.dtmvtolt) = 'S' THEN
                               vr_vlsldconcilia := rw_craprda.vlsdrdca;
                            END IF;

                            -- Insere registro do saldo do dia
                            pc_insere_saldo_aplic( pr_cdcooper       => pr_cdcooper
                                                  ,pr_nrdconta       => rw_craprda.nrdconta
                                                  ,pr_nraplica       => rw_craprda.nraplica
                                                  ,pr_tp_aplica      => 1
                                                  ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                                  ,pr_saldo_bruto    => vr_vlsldrdc
                                                  ,pr_saldo_concilia => vr_vlsldconcilia
                                                  ,pr_des_erro       => vr_dscritic);

                             -- Caso encontre erros
                             IF vr_dscritic = 'NOK' THEN

                               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                                         ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                             vr_dscritic || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
                                                                             ' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);
                               RAISE vr_exc_erro;
                             END IF;

                                                       
                           ELSIF vr_tab_crapdtc(lpad(rw_craprda.tpaplica, 3, '0')).tpaplrdc = 2 THEN -- RDCPOS

                             --Zerar variavel cálculo
                             vr_vlsldrdc:= 0;

                             -- Cálculo de saldo da RDC Pós Fixada
                             apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper
                                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                                      ,pr_nrdconta => rw_craprda.nrdconta
                                                      ,pr_nraplica => rw_craprda.nraplica
                                                      ,pr_dtmvtpap => rw_crapdat.dtmvtolt
                                                      ,pr_dtcalsld => rw_crapdat.dtmvtolt
                                                      ,pr_flantven => FALSE
                                                      ,pr_flggrvir => FALSE
                                                      ,pr_dtinitax => vr_dtinitax
                                                      ,pr_dtfimtax => vr_dtfimtax
                                                      ,pr_cdprogra => 'CUSAPL'
                                                      ,pr_vlsdrdca => vr_vlsldrdc
                                                      ,pr_vlrentot => vr_vlrentot
                                                      ,pr_vlrdirrf => vr_vlrdirrf
                                                      ,pr_perirrgt => vr_perirrgt
                                                      ,pr_des_reto => vr_dscritic
                                                      ,pr_tab_erro => vr_tab_craterr);

                            /* Para o Saldo para Conciliacao B3, devemos considerar o valor rendido no periodo de carencia */
                            vr_vlsldconcilia := vr_vlsldrdc;
                            IF APLI0007.fn_tem_carencia(pr_dtmvtapl => rw_craprda.dtmvtolt
                                                       ,pr_qtdiacar => rw_craprda.qtdiacar
                                                       ,pr_dtmvtres => rw_crapdat.dtmvtolt) = 'S' THEN
                               vr_vlsldrdc := rw_craprda.vlsdrdca;
                            END IF;

                            -- Insere registro do saldo do dia
                            pc_insere_saldo_aplic( pr_cdcooper        => pr_cdcooper
                                                  ,pr_nrdconta        => rw_craprda.nrdconta
                                                  ,pr_nraplica        => rw_craprda.nraplica
                                                  ,pr_tp_aplica       => 1
                                                  ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                                  ,pr_saldo_bruto     => vr_vlsldrdc
                                                  ,pr_saldo_concilia  => vr_vlsldconcilia
                                                  ,pr_des_erro        => vr_dscritic);


                             -- Caso encontre erros
                             IF vr_dscritic = 'NOK' THEN
                               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                                         ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                                             vr_dscritic || '. ' || vr_tab_craterr(vr_tab_craterr.FIRST).CDCRITIC ||
                                                                             ' - ' || vr_tab_craterr(vr_tab_craterr.FIRST).DSCRITIC);
                               --Levantar Excecao
                               RAISE vr_exc_erro;
                             END IF;

                           END IF;

                        END IF;

                       -- Se ocorrer erro
                       IF vr_dscritic IS NOT NULL THEN
                         RAISE vr_exc_erro;
                       END IF;

                     EXCEPTION
                       WHEN vr_exc_erro THEN
                         pr_des_erro:= vr_dscritic;
                         --levantar Excecao
                         RAISE vr_exc_erro;
                       WHEN vr_continua THEN
                         -- Somente para passar para a próxima iteração do cursor
                         NULL;
                       WHEN others THEN
                         vr_dscritic := 'Erro ao processar loop craprda: ' || sqlerrm;
                         RAISE vr_exc_erro;

                     END; -- FIM DO BLOCO aplicacoes DO ASSOCIADO

                  END LOOP; -- FIM FOR aplicacoes DO ASSOCIADO

              END IF; -- FIM [VERIFICA SE EXISTE REGISTROS do associado]

              -- APLICAÇÕES PCAPTA
              FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                
                vr_vlbascal := 0;
                IF rw_craprac.idtippro = 1 THEN -- Pre-Fixada
                    
                  -- Consulta saldo de aplicacao pre
                  apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                                         ,pr_nrdconta => rw_crapass.nrdconta -- Conta do Cooperado
                                                         ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                         ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                         ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                         ,pr_idtxfixa => rw_craprac.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                         ,pr_cddindex => rw_craprac.cddindex -- Codigo de Indexador
                                                         ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                         ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                         ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                         ,pr_dtfimcal => rw_crapdat.dtmvtolt -- Data de Fim do Calculo
                                                         ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                         ,pr_flgcaren => 1                   -- Ignora a carencia
                                                         ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                         ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                         ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                         ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                         ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                         ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                         ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                         ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                         ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                         ,pr_dscritic => vr_dscritic);       -- Descricao de Critica
                ELSIF rw_craprac.idtippro = 2 THEN -- Pos-Fixada
                    
                  -- Consulta saldo de aplicacao pos
                  apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                                         ,pr_nrdconta => rw_crapass.nrdconta -- Conta do Cooperado
                                                         ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                         ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                         ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                         ,pr_idtxfixa => rw_craprac.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                         ,pr_cddindex => rw_craprac.cddindex -- Codigo de Indexador
                                                         ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                         ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                         ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                         ,pr_dtfimcal => rw_crapdat.dtmvtolt -- Data de Fim do Calculo
                                                         ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                         ,pr_flgcaren => 1                   -- Ignora a carencia
                                                         ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                         ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                         ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                         ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                         ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                         ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                         ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                         ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                         ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                         ,pr_dscritic => vr_dscritic);       -- Descricao de Critica
                END IF;
                
                /* Para o Saldo de Conciliacao B3, devemos considerar o valor rendido no periodo de carencia */
                vr_vlsldconcilia := vr_vlsldtot;
                IF APLI0007.fn_tem_carencia(pr_dtmvtapl => rw_craprac.dtmvtolt
                                           ,pr_qtdiacar => rw_craprac.qtdiacar
                                           ,pr_dtmvtres => rw_crapdat.dtmvtolt) = 'S' THEN
                   vr_vlsldtot := rw_craprac.vlbasapl;
                END IF;
                
                  -- Insere registro do saldo do dia
                  pc_insere_saldo_aplic( pr_cdcooper       => pr_cdcooper
                                        ,pr_nrdconta       => rw_crapass.nrdconta
                                        ,pr_nraplica       => rw_craprac.nraplica
                                        ,pr_tp_aplica      => 2
                                        ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                        ,pr_saldo_bruto    => vr_vlsldtot
                                        ,pr_saldo_concilia => vr_vlsldconcilia
                                        ,pr_des_erro       => vr_dscritic);                                                    
                             
                     --Montar indice para acesso tabela memória
                     vr_index_saldo := lpad(rw_crapass.nrdconta, 10, '0') ||
                                       lpad(rw_craprac.nrctrrpp, 10, '0');
                        
                     IF NOT vr_tab_saldo_plano.exists(vr_index_saldo) THEN
                       vr_tab_saldo_plano(vr_index_saldo).vlsdrdpp := vr_vlsldtot;
                     ELSE
                       vr_tab_saldo_plano(vr_index_saldo).vlsdrdpp := vr_tab_saldo_plano(vr_index_saldo).vlsdrdpp + vr_vlsldtot;
                     END IF;

                 END LOOP;

              -- POUPANCA PROGRAMADA
              IF vr_tab_craprpp.EXISTS(rw_crapass.nrdconta) THEN

                   -- Busca registros para poupança programada
                   FOR rw_craprpp IN cr_craprpp(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_crapass.nrdconta) LOOP

                     BEGIN
                         
                       IF rw_craprpp.cdsitrpp = 1 THEN
                         vr_tot_vlprerpp := Nvl(vr_tot_vlprerpp,0) + rw_craprpp.vlprerpp;
                       END IF;
                         
                        --Montar indice para acesso tabela memória
                       vr_index_saldo := lpad(rw_crapass.nrdconta, 10, '0') ||
                                         lpad(rw_craprpp.nrctrrpp, 10, '0');                       
                         
                       if vr_tab_saldo_plano.exists(vr_index_saldo) then
                          vr_rpp_vlsdrdpp := vr_tab_saldo_plano(vr_index_saldo).vlsdrdpp;
                       else
                         -- Calcular o saldo até a data do movimento
                         apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                                ,pr_dstextab  => vr_percirtab
                                                ,pr_cdprogra  => vr_cdprogra
                                                ,pr_inproces  => rw_crapdat.inproces
                                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                                ,pr_rpp_rowid => rw_craprpp.rowid
                                                ,pr_vlsdrdpp  => vr_rpp_vlsdrdpp
                                                ,pr_cdcritic  => vr_cdcritic
                                                ,pr_des_erro  => vr_dscritic);
                        END IF;

                        -- Insere registro do saldo do dia
                        pc_insere_saldo_aplic( pr_cdcooper       => pr_cdcooper
                                              ,pr_nrdconta       => rw_crapass.nrdconta
                                              ,pr_nraplica       => rw_craprpp.nrctrrpp
                                              ,pr_tp_aplica      => 3
                                              ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                              ,pr_saldo_bruto    => vr_rpp_vlsdrdpp
                                              ,pr_saldo_concilia => vr_rpp_vlsdrdpp
                                              ,pr_des_erro       => vr_dscritic);


                       -- Se o valor do saldo for menor ou igual a zero passa para a próxima iteração do laço
                       IF vr_rpp_vlsdrdpp <= 0 THEN
                         --Pular para proximo registro
                         RAISE vr_exc_pula;
                       END IF;

                       -- Se ocorrer erro
                       IF vr_dscritic IS NOT NULL THEN
                         --Levantar Excecao
                         RAISE vr_exc_erro;
                       END IF;                   

                     EXCEPTION
                       WHEN vr_exc_erro THEN
                         pr_des_erro:= vr_dscritic;
                         --levantar Excecao
                         RAISE vr_exc_erro;
                       WHEN vr_exc_pula THEN
                         NULL;
                       WHEN OTHERS THEN
                         vr_dscritic:= 'Erro ao processar loop craprpp. '||SQLERRM;
                         RAISE vr_exc_erro;
                     END;
                   END LOOP; --rw_craprpp
                 END IF;

          END LOOP; -- FECHA O LOOP FOR rw_crapass

       
          -- Processo OK, devemos chamar a fimprg
          btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
         
          
          -- Insere os registros da tabela temporária 
          -- tab_insert_saldo_aplica para TBCAPT_SALDO_APLICA
          FORALL idx in tab_insert_saldo_aplica.first .. tab_insert_saldo_aplica.last
          INSERT INTO TBCAPT_SALDO_APLICA VALUES tab_insert_saldo_aplica(idx);
  
          
          COMMIT; --> Comfirma as operações no banco de dados.

          -- Apaga a TABELA TEMPORÁRIA
          vr_tab_craprda.delete;
          vr_tab_saldo_plano.delete;
          tab_insert_saldo_aplica.delete;
          
          
        EXCEPTION
                    
             WHEN vr_exc_erro THEN
               pr_des_erro := vr_dscritic;          
               ROLLBACK; --> Desfaz os procedimentos com o banco de dados
             WHEN others THEN
               pr_des_erro := 'Erro: ' || vr_dscritic || ' - ' || sqlerrm;          
               ROLLBACK; --> Desfaz os procedimentos com o banco de dados.
        END;
       
         -- FIM DE TODO O CALCULO    

         -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
         GENE0001.pc_informa_acesso(pr_module  => 'PC_'||vr_cdprogra
                                    ,pr_action => 'pc_sub_rotinas');

         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_erro;
         END IF;
       
         --Se ocorreu erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_erro;
         END IF;

       EXCEPTION
         WHEN vr_exc_erro THEN
           --Retornar erro
           pr_des_erro:= vr_dscritic;
         WHEN others THEN
           pr_des_erro := 'Erro ao processar rotina pc_sub_rotinas: ' || sqlerrm;
       END;
     END pc_sub_rotinas;

      
BEGIN 
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    --Apenas valida a cooperativa quando for o programa principal, paralelos não tem necessidade.
    IF pr_idparale = 0 THEN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar registros montar mensagem de critica
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Buscar mensagem de erro
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapcop;
      END IF;
    END IF; 
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    --Apenas valida a cooperativa quando for o programa principal, paralelos não tem necessidade.
    IF pr_idparale = 0 THEN
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar registros montar mensagem de critica
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Buscar mensagem de erro
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapcop;
      END IF;
    END IF;

    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Caso retorno crítica busca a descrição
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das taxas para a tabela generica
    vr_dstextab_tx:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);

    --Se nao encontrou parametro
    IF vr_dstextab_tx IS NULL THEN
      vr_inusatab:= FALSE;
    ELSE
      --Se o valor da posicao 1 = 0
      IF SubStr(vr_dstextab_tx,1,1) = '0' THEN
        vr_inusatab:= FALSE;
      ELSE
        vr_inusatab:= TRUE;
      END IF;
    END IF;

    -- Data de fim e inicio da utilização da taxa de poupança.
    -- Utiliza-se essa data quando o rendimento da aplicação for menor que
    -- a poupança, a cooperativa opta por usar ou não.
    -- Buscar a descrição das faixas contido na craptab
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'MXRENDIPOS'
                                            ,pr_tpregist => 1);

    -- Se não encontrar registros
    IF vr_dstextab IS NULL THEN
      vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
      vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
    ELSE
      vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1, vr_dstextab, ';'), 'DD/MM/YYYY');
      vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2, vr_dstextab, ';'), 'DD/MM/YYYY');
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    
    -- Projeto Ligeirinho 
    -- Início da alteração para executar o paralelismo
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := 0;
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --> Código da coopertiva
                                                 ,pr_cdprogra => vr_cdprogra --> Código do programa
                                                 );
    -- remover teste David de forçar paralelismo
    rw_crapdat.inproces := 3;
    
     /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if rw_crapdat.inproces  > 2 and
       vr_qtdjobs           > 0 and
       pr_cdagenci          = 0 then

      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_id_paralelo;

      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
         RAISE vr_exc_erro;
      END IF;

      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',
                      pr_cdprograma => vr_cdprogra,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);

      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);

      -- Retorna todas as Agências para criação dos Jobs.
      for rw_crapage in cr_crapage (pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_qterro   => vr_qterro
                                    ) loop
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$';

        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_erro;
        end if;

        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13) || --
                      '  wpr_stprogra NUMBER;' || chr(13) || --
                      '  wpr_infimsol NUMBER;' || chr(13) || --
                      '  wpr_cdcritic NUMBER;' || chr(13) || --
                      '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                      'BEGIN' || chr(13) || --
                      '  pc_crps753( '|| pr_cdcooper             || ',' ||
                                         '0'                     || ',' ||
                                         rw_crapage.cdagenci     || ',' ||
                                         vr_idparale             || ',' ||
                                         ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' || chr(13) ||
                      'END;';

        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                              ,pr_cdprogra => vr_cdprogra  --> Código do programa
                              ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname  => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
           -- Levantar exceçao
           raise vr_exc_erro;
        end if;

        -- Chama rotina que irá pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execuçao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                    ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        if  vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_erro;
        end if;
      end loop;

      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_erro;
      end if;

      
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
      if vr_qterro > 0 then
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_erro;
      end if;

    else

      --Classifica o tipo de execução de acordo com a informação no campo agência.
      if pr_cdagenci <> 0 then
        vr_tpexecucao := 2;
      else
        vr_tpexecucao := 1;
      end if;

      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                      ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic
                                       );
      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_erro;
      end if;

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - procedure pc_sub_rotinas. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        -- Executar programas
        pc_sub_rotinas(pr_des_erro => vr_dscritic);

        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim - procedure pc_sub_rotinas. AGENCIA: '||pr_cdagenci,
                        PR_IDPRGLOG           => vr_idlog_ini_par);


       -- Retornar nome do módulo original, para que tire o action gerado pelo programa chamado acima
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

       -- Levantar exceção no caso de erros no processo paralelo
       IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
       END IF;

       
      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 1);

    end if;

    -- Projeto Ligeirinho - Fim do paralelismo
    
    if pr_idparale = 0 then
    -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

      if vr_idcontrole <> 0 then
        -- Atualiza finalização do batch na tabela de controle
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);

        -- Testar saida com erro
        if  vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_erro;
        end if;

      end if;

      if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 then
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_ger,
                        pr_flgsucesso => 1);
      end if;

    -- Salvar informacoes
    COMMIT;

    --Zerar tabela de memoria auxiliar
    --pc_limpa_tabela;


    --Se for job chamado pelo programa do batch
    else
      -- Atualiza finalização do batch na tabela de controle
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);

      -- Salvar informacoes
      COMMIT;

      --Zerar tabela de memoria auxiliar
      --pc_limpa_tabela;
    end if;
    
    EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      --Zerar tabela de memoria auxiliar
      --pc_limpa_tabela;

      if pr_idparale <> 0 then
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;


      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      --Zerar tabela de memoria auxiliar
      --pc_limpa_tabela;

      if pr_idparale <> 0 then
        -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||pr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;


      -- Efetuar rollback
      ROLLBACK;  
    
END PC_CRPS753;
/
