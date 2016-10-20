CREATE OR REPLACE PROCEDURE CECRED.pc_crps120_1 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_cdprogra  IN crapprg.cdprogra%TYPE default null  --> Codigo do programa chamador                      
                                                ,pr_cdoperad  IN crapope.cdoperad%type  --> codigo do operador                 
                                                ,pr_crapdat   IN  btch0001.cr_crapdat%rowtype  --> type contendo as informações da crapdat
                                                ,pr_nrdconta  IN crapass.nrdconta%type  --> Nr da conta do associado
                                                ,pr_nrctremp  IN crapepr.nrctremp%type  --> Nr do emprestimo
                                                ,pr_nrdolote  IN crapepr.nrdolote%type  --> Nr do lote do emprestimo
                                                ,pr_inusatab  IN boolean                --> Indicador se utiliza taxa de juros
                                                ,pr_vldaviso  IN NUMBER                 --> Valor do aviso
                                                ,pr_vlsalliq  IN NUMBER                 --> Valor de saldo liquido
                                                ,pr_dtintegr  IN DATE                   --> Data de integração
                                                ,pr_cdhistor  IN craphis.cdhistor%type  --> Cod do historico
                                                ,pr_insitavs OUT crapavs.insitavs%type  --> Situação do aviso
                                                ,pr_vldebito OUT crapavs.vldebito%type  --> Retorno do valor debito
                                                ,pr_vlestdif OUT crapavs.vlestdif%type  --> Valor do estouro ou diferenca.
                                                ,pr_flgproce OUT crapavs.flgproce%type  --> retorno indicativo de processamento
                                                ,pr_cdcritic OUT PLS_INTEGER            --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps120_1   (Fontes/crps120_1.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Maio/1995                     Ultima atualizacao: 26/09/2016

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os debitos de emprestimos.

       Alteracoes: 19/11/96 - Alterado a mascara do campo nrctremp (Odair).

                   27/08/97 - Alterado para alimentar crapavs.flgproce quando
                              o debito for feito (Deborah).

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   12/11/98 - Tratar atendimento noturno (Deborah).

                   30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

                   29/06/2005 - Alimentado campo cdcooper da tabela craplem (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   28/04/2006 - Controlar o valor minimo a ser debitado (Julio).

                   23/01/2009 - Alteracao cdempres (Diego).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   26/03/2010 - Desativar Rating quando liquidado
                                o emprestimo (Gabriel).

                   09/03/2012 - Declarado novas variaveis da include lelem.i
                                (Tiago).

                   17/10/2013 - GRAVAMES - Solicitacao Baixa Automatica
                                (Guilherme/SUPERO).
                   
                   13/12/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)             
                   
                   29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                                posicoes (Tiago/Gielow SD137074).
                                
                   16/07/2015 - Ajuste no calculo do saldo devedor, para os emprestimos 
                                com vencimento no dia primeiro. (James)

                   05/08/2015 - Alteracao para gravar o valor do lancamento na
                                craplot como debito e nao como credito. (Jaison)
                                
                   22/09/2015 - Ajustes para inicializar a pr_flgproce que no Progress
                                é inicializada com zero e no Oracle permanecia vazia
                                (Marcos-Supero)

                   26/09/2016 - Inclusao de verificacao de contratos de acordos,
                                Prj. 302 (Jean Michel). 
                                
                   06/10/2016 - Incluir inclusão do lote, caso o mesmo não seja encontrado. Solicitado
                                por James - Projeto 302 - ACordos   (Renato Darosci - Supero)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS120';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_flgativo   INTEGER := 0;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados do empréstimo
      CURSOR cr_crapepr (pr_cdcooper crapcop.cdcooper%type,
                         pr_nrdconta crapass.nrdconta%type,
                         pr_nrctremp crapepr.nrctremp%type) IS
      SELECT inliquid,
             txjuremp,
             cdlcremp,
             nrdconta,
             nrctremp,
             vlsdeved,
             vljuracu,
             dtultpag,
             qtprepag,
             vlpreemp,
             ROWID
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
         
      rw_crapepr cr_crapepr%rowtype;  
      
      -- Busca dos dados de Linhas de Credito
      CURSOR cr_craplcr (pr_cdcooper crapcop.cdcooper%type,
                         pr_cdlcremp crapepr.cdlcremp%type) IS
        SELECT txdiaria 
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      
      rw_craplcr cr_craplcr%rowtype;  
      
      -- Busca dos dados de Linhas de Credito
      CURSOR cr_craplot (pr_cdcooper crapcop.cdcooper%type,
                         pr_dtintegr date,
                         pr_cdagenci crapage.cdagenci%type,
                         pr_cdbccxlt crapban.cdbccxlt%type,
                         pr_nrdolote crapepr.nrdolote%type) IS
                         
      SELECT dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrseqdig,
             qtinfoln,
             qtcompln,
             vlinfocr,
             vlcompcr,
             rowid  dsrowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtintegr
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%rowtype;  
         
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      -- Variaveis para tratamento de erros
      vr_des_reto varchar2(10);
      vr_tab_erro GENE0001.typ_tab_erro;
      -- Variaveis utilizadas para a leitura da lelem e geração da CRAPLEM e CRAPLOT
      vr_nrdconta crapepr.nrdconta%type;
      vr_nrseqdig craplem.nrseqdig%type;
      vr_vlsdeved crapepr.vlsdeved%type;
      vr_vljuracu crapepr.vljuracu%type;
      vr_dtultpag crapepr.dtultpag%type;
      vr_qtprepag crapepr.qtprepag%type;
      vr_dstextab craptab.dstextab%type;
      vr_vllanmto craplem.vllanmto%type;
      vr_diapagto NUMBER;
      vr_txdjuros NUMBER;
      vr_vlmindeb NUMBER;
      vr_qtprecal NUMBER;      
      vr_vlprepag NUMBER(14,2);
      vr_vljurmes NUMBER(11,2);
      vr_cdagenci crapage.cdagenci%type := 1;  --atribuir agencia inicial
      vr_cdbccxlt crapban.cdbccxlt%type := 100;--atribuir banco inicial
      
      
      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => pr_cdprogra
                                ,pr_action => 'PC_'||vr_cdprogra);

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      -- Buscar informacoes de valor minimo de debito
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'VLMINDEBTO'
                                               ,pr_tpregist => 0);
      
      IF vr_dstextab is null THEN
         vr_vlmindeb := 0;
      ELSE
         vr_vlmindeb := to_number(vr_dstextab);
      END IF;
      
      --Ler emprestimos
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr 
       INTO rw_crapepr;
      
      --  se não encontrar gravar log
      IF cr_crapepr%NOTFOUND THEN
        vr_dscritic := gene0001.fn_busca_critica(356);  
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                                                                  ||' CTR: '|| gene0002.fn_mask_contrato(pr_nrctremp));
        CLOSE cr_crapepr;
        --retonar para o programa chamador
        RETURN;
      ELSE
        --somente fechar cursor
        CLOSE cr_crapepr;
      END IF;  
      
      -- Inicializar parametros de saída
      pr_flgproce := 0;
      pr_vldebito := 0;
                         
      -- Se o emprestimo ja foi liquidado, retornar para o programa chamador 
      IF rw_crapepr.inliquid > 0   THEN
        pr_insitavs := 1;
        pr_vlestdif := pr_vldaviso;
        pr_flgproce := 1;--TRUE;
        RETURN;
      END IF;
      
      IF pr_inusatab             AND
         rw_crapepr.inliquid = 0 THEN
         
        --Ler linha de credito
        OPEN cr_craplcr (pr_cdcooper => pr_cdcooper,
                         pr_cdlcremp => rw_crapepr.cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        
        IF cr_craplcr%NOTFOUND THEN
          --se não encontrar, gravar log
          vr_dscritic := gene0001.fn_busca_critica(356);  
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '|| vr_dscritic 
                                                     ||' LCR: '|| gene0002.fn_mask(rw_crapepr.cdlcremp,'zzz9'));                                                     
          CLOSE cr_craplcr;
          --retonar para o programa chamador
          RETURN;
        ELSE
          vr_txdjuros := rw_craplcr.txdiaria;
          CLOSE cr_craplcr;                    
        END IF;                  
      ELSE
        vr_txdjuros := rw_crapepr.txjuremp;
      END IF;   
      --Setar variaveis para utilizar na chamada do procedimento abaixo
      vr_nrdconta := rw_crapepr.nrdconta;
      vr_vlsdeved := rw_crapepr.vlsdeved;
      vr_vljuracu := rw_crapepr.vljuracu;
      vr_dtultpag := rw_crapepr.dtultpag;
      vr_qtprepag := rw_crapepr.qtprepag;
      vr_diapagto := 0;      
      
      -- Chamar rotina de cálculo externa
      empr0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                             ,pr_cdprogra    => vr_cdprogra
                             ,pr_rw_crapdat  => pr_crapdat
                             ,pr_nrdconta    => pr_nrdconta
                             ,pr_nrctremp    => pr_nrctremp
                             ,pr_dtcalcul    => NULL
                             ,pr_diapagto    => vr_diapagto
                             ,pr_txdjuros    => vr_txdjuros
                             ,pr_qtprepag    => vr_qtprepag
                             ,pr_qtprecal    => vr_qtprecal
                             ,pr_vlprepag    => vr_vlprepag
                             ,pr_vljuracu    => vr_vljuracu
                             ,pr_vljurmes    => vr_vljurmes
                             ,pr_vlsdeved    => vr_vlsdeved
                             ,pr_dtultpag    => vr_dtultpag
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_des_erro    => vr_dscritic);
      -- Se a rotina retornou com erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        -- Gerar exceção, gravar log
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '|| vr_dscritic);                                                     
        --retonar para o programa chamador
        RETURN;
      END IF;
      
      -- VErificar se está sendo chamado da rotina de pagamento de acordos
      IF pr_cdprogra <> 'RECP0001' THEN
        -- Verifica se existe contrato de acordo ativo
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSIF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;      
        END IF;
                                   
        IF vr_flgativo = 1 THEN
          vr_dscritic := 'Lancamento nao permitido, contrato para liquidar esta em acordo.';
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      
      -- Saldo devedor menor ou igual a zero
      IF vr_vlsdeved <= 0   THEN 
         
        BEGIN
          --Atualizar emprestimo como liquidado
          UPDATE crapepr
             SET inliquid = 1
           WHERE ROWID = rw_crapepr.rowid;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel atualizar emprestimo'
                           ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                           ||' CTR: '|| gene0002.fn_mask_contrato(pr_nrctremp)||':'||SQLERRM;  
            RAISE vr_exc_saida;
        END;
        
        pr_vlestdif := pr_vldaviso;
        pr_insitavs := 1;
        pr_flgproce := 1;--TRUE;

        -- Desativar o Rating associado a esta operaçao
        rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                   ,pr_cdagenci   => 0                   --> Código da agência
                                   ,pr_nrdcaixa   => 0                   --> Número do caixa
                                   ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                   ,pr_rw_crapdat => pr_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                   ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                   ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                   ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                   ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                   ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                   ,pr_inusatab   => pr_inusatab         --> Indicador de utilização da tabela de juros
                                   ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                   ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                   ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros

        --------------------------------------------------------------------
        ----- Não versão progress não testava se retornou erro aqui...  ----
        --------------------------------------------------------------------

        -- Se retornar erro
        --IF vr_des_reto = 'NOK' THEN
        --  -- Tenta buscar o erro no vetor de erro
        --  IF vr_tab_erro.COUNT > 0 THEN
        --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  ELSE
        --    pr_dscritic := 'Retorno "NOK" na rati0001.pc_desativa_rating e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  END IF;
        --  -- Levantar exceção
        --  RAISE vr_exc_erro;
        --END IF;

        /** GRAVAMES **/
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                             ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                             ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                             ,pr_dtmvtolt => pr_crapdat.dtmvtolt  -- Data de movimento para baixa
                                             ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                             ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                             ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                             ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

        --------------------------------------------------------------------
        ----- Não versão progress não testava se retornou erro aqui...  ----
        --------------------------------------------------------------------
        -- Se retornar erro
        --IF vr_des_reto <> 'OK' THEN
        --  -- Tenta buscar o erro no vetor de erro
        --  IF vr_tab_erro.COUNT > 0 THEN
        --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  ELSE
        --    pr_dscritic := 'Retorno "NOK" na GRVM0001.pc_solicita_baixa_automatica e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  END IF;
        --  -- Levantar exceção
        --  RAISE vr_exc_erro;
        --END IF;
               
        RETURN;
      END IF;
      
      -- Se o saldo devedor for menor que o valor do aviso
      IF vr_vlsdeved > pr_vldaviso   THEN
        --se o valor do aviso for maior que o o saldo liquido
        IF pr_vldaviso > pr_vlsalliq   THEN
          vr_vllanmto := pr_vlsalliq;
          pr_vlestdif := pr_vlsalliq - pr_vldaviso;
          pr_insitavs := 0; -- situacao do aviso (0-naodeb)
        ELSE
          vr_vllanmto := pr_vldaviso;
          pr_vlestdif := 0;
          pr_insitavs := 1; -- situacao do aviso (1-deb). 
          pr_flgproce := 1;--TRUE;
        END IF;
        --se for menor que o limite minimo retornar para o programa chamador            
        IF vr_vllanmto < vr_vlmindeb   THEN
          pr_vlestdif := pr_vldaviso * -1;
          pr_insitavs := 0; -- situacao do aviso (0-naodeb). 
          pr_flgproce := 0;--FALSE;                        
          RETURN;
        END IF;
        
      -- Senão se o saldo devedor for maior que o saldo liquido
      ELSIF vr_vlsdeved > pr_vlsalliq   THEN
        vr_vllanmto := pr_vlsalliq;
        pr_vlestdif := pr_vlsalliq - vr_vlsdeved;
        pr_insitavs := 0; -- situacao do aviso (0-naodeb).
      ELSE
        vr_vllanmto := vr_vlsdeved;
        pr_vlestdif := pr_vldaviso - vr_vlsdeved;
        pr_insitavs := 1; -- situacao do aviso (1-deb).
        pr_flgproce := 1;--TRUE;
      END IF;
      
      -- Buscar lote
      OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                       pr_dtintegr => pr_dtintegr,
                       pr_cdagenci => vr_cdagenci,
                       pr_cdbccxlt => vr_cdbccxlt,
                       pr_nrdolote => pr_nrdolote);
      FETCH cr_craplot
        INTO rw_craplot;
      
      --  se não encontrar gravar log
      IF cr_craplot%NOTFOUND THEN
        CLOSE cr_craplot;
        
        -- Alterado para que ao não encontrar o lote, criar o mesmo. Esta solicitação foi feita pelo 
        -- James, devido há uma situação ocorrida no projeto 302 - Acordos. (Renato Darosci - 06/10/2016)
        BEGIN
          -- Insere o lote
          INSERT INTO craplot(cdcooper
                             ,dtmvtolt 
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig
                             ,vlcompcr
                             ,vlinfocr
                             ,cdhistor
                             ,cdoperad
                             ,dtmvtopg)
                       VALUES(pr_cdcooper
                             ,pr_dtintegr
                             ,vr_cdagenci
                             ,vr_cdbccxlt
                             ,pr_nrdolote -- 8453
                             ,5
                             ,0
                             ,0
                             ,0
                             ,0
                             ,'1'
                             ,NULL) RETURNING dtmvtolt
                                            , cdagenci
                                            , cdbccxlt
                                            , nrdolote
                                            , nrseqdig
                                            , qtinfoln
                                            , qtcompln
                                            , vlinfocr
                                            , vlcompcr
                                            , ROWID   
                                         INTO rw_craplot.dtmvtolt
                                            , rw_craplot.cdagenci
                                            , rw_craplot.cdbccxlt
                                            , rw_craplot.nrdolote
                                            , rw_craplot.nrseqdig
                                            , rw_craplot.qtinfoln
                                            , rw_craplot.qtcompln
                                            , rw_craplot.vlinfocr
                                            , rw_craplot.vlcompcr
                                            , rw_craplot.dsrowid;
                                             
        EXCEPTION 
          WHEN OTHERS THEN
            -- A lógica de não retornar o erro foi mantida da mesma forma como era feito 
            -- na versão antiga, para que não cause erros que antes não ocorriam
            vr_dscritic := 'Erro ao inserir lote: '||SQLERRM;  
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '|| vr_dscritic 
                                                       ||'AG: 001 BCX: 100 LOTE:'|| gene0002.fn_mask(pr_nrdolote,'999999'));
            --retonar para o programa chamador
            RETURN;
        END;
        
        -- 
        /*vr_dscritic := gene0001.fn_busca_critica(60);  
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '|| vr_dscritic 
                                                   ||'AG: 001 BCX: 100 LOTE:'|| gene0002.fn_mask(pr_nrdolote,'999999'));
        CLOSE cr_craplot;
        --retonar para o programa chamador
        RETURN;*/
      ELSE
        --somente fechar cursor
        CLOSE cr_craplot;
      END IF;       
      
      pr_vldebito := vr_vllanmto;
      
      -- Inserir Lancamentos em emprestimos. (D-08)
      BEGIN
        INSERT INTO CRAPLEM 
                    ( dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrdconta
                     ,nrctremp
                     ,nrdocmto
                     ,vllanmto
                     ,cdhistor
                     ,nrseqdig
                     ,dtpagemp
                     ,txjurepr
                     ,cdcooper
                     ,vlpreemp)                     
             VALUES ( rw_craplot.dtmvtolt      -- dtmvtolt
                     ,rw_craplot.cdagenci      -- cdagenci
                     ,rw_craplot.cdbccxlt      -- cdbccxlt
                     ,rw_craplot.nrdolote      -- nrdolote 
                     ,vr_nrdconta              -- nrdconta
                     ,rw_crapepr.nrctremp      -- nrctremp
                     ,(rw_craplot.nrseqdig + 1)-- nrdocmto
                     ,vr_vllanmto              -- vllanmto
                     ,pr_cdhistor              -- cdhistor 
                     ,(rw_craplot.nrseqdig + 1)-- nrseqdig 
                     ,rw_craplot.dtmvtolt      -- dtpagemp
                     ,vr_txdjuros              -- txjurepr
                     ,pr_cdcooper              -- cdcooper
                     ,rw_crapepr.vlpreemp      -- vlpreemp
                     )
              returning  nrseqdig into vr_nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel inserir lançamento emprestimo(CRAPLEM)'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                         ||' CTR: '|| gene0002.fn_mask_contrato(pr_nrctremp)||' :'||SQLERRM;  
          RAISE vr_exc_saida;  
      END;  
      
      -- Atualizar lote
      BEGIN
        UPDATE craplot
           SET craplot.qtinfoln = craplot.qtinfoln + 1,
               craplot.qtcompln = craplot.qtcompln + 1,
               craplot.vlinfodb = craplot.vlinfodb + vr_vllanmto,
               craplot.vlcompdb = craplot.vlcompdb + vr_vllanmto,
               craplot.nrseqdig = vr_nrseqdig
         WHERE ROWID = rw_craplot.dsrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar lote(CRAPLOT)'
                         ||' cdcooper: '|| pr_cdcooper
                         ||' nrdolote: '|| pr_nrdolote||' :'||SQLERRM;  
          RAISE vr_exc_saida;  
      END;
        
      -- Atualizar data de ultimo pagamento, taxa de jutos e identificação de liquidação do emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtultpag = rw_craplot.dtmvtolt,
               crapepr.txjuremp = vr_txdjuros,
               crapepr.inliquid = (CASE 
                                     WHEN (vr_vlsdeved - vr_vllanmto) > 0 THEN 0
                                     ELSE 1
                                   END)                                      
         WHERE ROWID = rw_crapepr.rowid
         returning inliquid into rw_crapepr.inliquid;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar emprestimo(crapepr)'
                         ||' CTA: '|| gene0002.fn_mask_conta(pr_nrdconta)
                         ||' CTR: '|| gene0002.fn_mask_contrato(pr_nrctremp)||' :'||SQLERRM;  
          RAISE vr_exc_saida;  
      END;
      
      -- Verificar se o emprestimo está liquidado
      IF  rw_crapepr.inliquid = 1   THEN                        

        -- Desativar o Rating associado a esta operaçao
        rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                   ,pr_cdagenci   => 0                   --> Código da agência
                                   ,pr_nrdcaixa   => 0                   --> Número do caixa
                                   ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                   ,pr_rw_crapdat => pr_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                   ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                   ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                   ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                   ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                   ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                   ,pr_inusatab   => pr_inusatab         --> Indicador de utilização da tabela de juros
                                   ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                   ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                   ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros

        --------------------------------------------------------------------
        ----- Não versão progress não testava se retornou erro aqui...  ----
        --------------------------------------------------------------------

        -- Se retornar erro
        --IF vr_des_reto = 'NOK' THEN
        --  -- Tenta buscar o erro no vetor de erro
        --  IF vr_tab_erro.COUNT > 0 THEN
        --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  ELSE
        --    pr_dscritic := 'Retorno "NOK" na rati0001.pc_desativa_rating e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  END IF;
        --  -- Levantar exceção
        --  RAISE vr_exc_erro;
        --END IF;

        /** GRAVAMES **/
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                             ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                             ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                             ,pr_dtmvtolt => pr_crapdat.dtmvtolt  -- Data de movimento para baixa
                                             ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                             ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                             ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                             ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

        --------------------------------------------------------------------
        ----- Não versão progress não testava se retornou erro aqui...  ----
        --------------------------------------------------------------------
        -- Se retornar erro
        --IF vr_des_reto <> 'OK' THEN
        --  -- Tenta buscar o erro no vetor de erro
        --  IF vr_tab_erro.COUNT > 0 THEN
        --    pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        --    pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  ELSE
        --    pr_dscritic := 'Retorno "NOK" na GRVM0001.pc_solicita_baixa_automatica e pr_vet_erro vazia! Conta: '||rw_crapepr.nrdconta||' Contrato: '||rw_crapepr.nrctremp;
        --  END IF;
        --  -- Levantar exceção
        --  RAISE vr_exc_erro;
        --END IF;
               
      END IF;
      
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
		pr_insitavs := NVL(pr_insitavs,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
    END;

  END pc_crps120_1;
/
