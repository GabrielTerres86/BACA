CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS078" (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta IN PLS_INTEGER             --> Flag padr?o para utilizac?o de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execuc?o
                    ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitac?o
                    ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Codigo do operador
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN

    /* ..........................................................................

       Programa: pc_crps078 (Antigo Fontes/crps078.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Janeiro/94.                     Ultima atualizacao: 04/08/2016

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 41.
                   Calculo mensal dos juros sobre emprestimos.

       Alteracoes: 23/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                              quidacao do emprestimo (Edson).

                   17/10/94 - Alterado para inclusao de novos parametros para as
                              linhas de credito: taxa minima e maxima e o indica-
                              dor de linha com saldo devedor.

                   03/03/95 - Alterado para inclusao de novos campos no craplem:
                              dtpagemp e txjurepr (Edson).

                   14/03/95 - Alterado para pegar a moeda fixa do proximo movimento
                              (Odair).

                   11/09/95 - Altera inliquid para 1 quando vlsdeved for igual a 0
                              (Edson).

                   12/06/96 - Alterado para tratar o controle de emprestimos em
                              atraso (Edson).

                   04/10/96 - Atualizar o campo crapepr.indpagto com 0 (Odair).

                   19/11/96 - Alterar a mascara do campo nrctremp (Odair).

                   24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   26/04/2000 - Alterado o calculo dos meses decorridos para
                                emprestimos vinculados a c/c (Deborah).

                   04/12/2000 - Tratar o ano no calculo dos meses decorridos
                                (Edson).

                   02/06/2001 - Ajustes para tratar contratos em prejuizo
                                (Deborah).

                   27/02/2002 - Alterar calculo do qtprecal (Margarete).

                   15/07/2002 - Alterar dtdpagto quando contrato novo (Margarete).

                   23/03/2003 - Incluir tratamento da Concredi (Margarete).

                   17/04/2003 - Incluir criacao do crapmcr (Margarete).

                   03/01/2005 - Quando qtprecal negativo mover zeros (Margarete).

                   28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                                craplem, craplcm e crapmcr (Diego).

                   15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   12/07/2007 - Quando emprestimo for liquidado e vinculado a folha
                                ver se ha algum crapavs em aberto(Guilherme).

                   01/09/2008 - Alteracao CDEMPRES (Kbase).

                   01/06/2009 - Aumentar arrays para 999 (Magui).

                   11/12/2009 - Desativar ratings quando emprestimo liquidado.
                                Retirar comentarios desnecessarios.
                                (Gabriel).

                   26/03/2010 - Quando finalizacao do epr utilizar crapepr.dtultpag
                                em crapmcr.dtdbaixa (Magui).

                   01/03/2012 - Tratar so os emprestimos do tipo Price TR
                                (Gabriel)

                   17/01/2013 - Tratamento para armazenar novo campo crapepr.flliqmen
                                (Lucas R.)

                   04/03/2013 - Incluso verificacao para nao emitir a critica
                                "ATENCAO: Contrato NAO microfilmado" no caso de
                                cooperativa migrada (Daniel).

                   29/05/2013 - Convers?o Progress >> PLSQL (Marcos-Supero)

                   09/08/2013 - Inclus?o de teste na pr_flgresta antes de controlar
                                o restart (Marcos-Supero)

                   14/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                                das criticas e chamadas a fimprg.p (Douglas Pagel)

                   17/10/2013 - GRAVAMES - Solicitacao Baixa Automatica
                                (Guilherme/SUPERO).

                   25/11/2013 - Ajustes na passagem dos parametros para restart (Marcos-Supero)

                   07/02/2014 - GRAVAMES - Solicitacao Baixa Automatica
                                (Gabriel).

                   07/02/2014 - Ajuste para atualizar ocampo crapepr.vlsdevat (Gabriel)

                   22/04/2014 - GRAVAMES - Executar a solicita_baixa_automatica
                                apenas quando emprestimo nao estiver em prejuizo
                                (Guilherme/Supero)

                   29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                                posicoes (Tiago/Gielow SD137074).

                   01/08/2014 - Ajustado processo de baixa automatica gravames
                                incluso dentro do "IF vr_inliquid = 1 THEN" (Daniel/CECRED)

                   24/10/2014 - GRAVAMES - Executar baixa_automatica apenas quando
                                o contrato tiver sido liquidado na mensal(flliqmen)
                                (Guilherme/SUPERO)

                   21/01/2015 - Alterado o formato do campo nrctremp para 8
                                caracters (Kelvin - 233714)

                   04/08/2016 - #482583 Retirada do controle de restart (Carlos)

                   05/06/2018 - P450 - Alteração INSERT na craplcm pela chamada da rotina lanc0001.pc_gerar_lancamento_conta
  --                            Josiane Stiehler- AMcom
   
                   20/09/2018 = P450 - Elimina tratamento de incrineg no retorno da lanc0001.
                                Não verificar se é crítica de negócio para gerar o raise.
                                Renato Cordeiro - AMcom
                                
                   19/02/2019 - PJ298.2.2 - Pos fixado, nao lancar sobras na conta corrente do cooperado
                                (Rafael Faria - Supero)
    ............................................................................ */

    DECLARE

      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      -- Codigo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS078';

      -- Rolbacks para erros, ignorar o resto do processo e rollback
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
--      vr_exc_erro EXCEPTION;
      vr_exc_undo EXCEPTION;

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variaveis para controle de restart
      vr_dslinhas VARCHAR2(32767) := '000,';--> Linhas processadas do Restart (inicializada para evitar problemas com null)

      -- Variaveis para gravac?o da craplot
      vr_cdagenci CONSTANT PLS_INTEGER := 1;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca o cadastro de linhas de credito
      CURSOR cr_craplcr IS
        SELECT lcr.rowid
              ,lcr.cdlcremp
              ,lcr.txdiaria
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

      -- Busca da moeda UFIR
      CURSOR cr_crapmfx IS
        SELECT vlmoefix
          FROM crapmfx
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = rw_crapdat.dtmvtopr
           AND tpmoefix = 2; -- Ufir
      vr_vlmoefix crapmfx.vlmoefix%TYPE;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot_8360 cr_craplot%ROWTYPE; --> Lancamento de juros para o emprestimo
      rw_craplot_8350 cr_craplot%ROWTYPE; --> Lancamento de sobras para o emprestimo
      rw_craplot_8351 cr_craplot%ROWTYPE; --> Lancamento na conta-corrente
      rw_craplot_8370 cr_craplot%ROWTYPE; --> Lancamento de abono para o emprestimo

      -- Leitura dos contratos de emprestimos do associado -- Parte I
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlsdeved
              ,epr.inliquid
              ,epr.dtultpag
              ,epr.inprejuz
              ,epr.dtprejuz
              ,epr.qtprepag
              ,epr.vljuracu
              ,epr.cdlcremp
              ,epr.txjuremp
              ,epr.flgpagto
              ,epr.vlpreemp
              ,epr.dtmvtolt
              ,epr.nrdolote
              ,epr.cdbccxlt
              ,epr.cdagenci
              ,epr.cdfinemp
              ,epr.nrctaav1
              ,epr.nrctaav2
              ,epr.qtpreemp
              ,epr.vlemprst
              ,epr.qtmesdec
              ,epr.dtdpagto
              ,epr.flliqmen
              ,epr.qtprecal
              ,epr.dtinipag
              ,epr.cdempres
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.tpemprst = 0             -- Price TR
         ORDER BY epr.nrdconta
                 ,epr.nrctremp;

      -- Verificar se existe registro de microfilmagem do contrato
      CURSOR cr_crapmcr(pr_rw_crapepr cr_crapepr%ROWTYPE) IS
        SELECT rowid
          FROM crapmcr mcr
         WHERE mcr.cdcooper = pr_cdcooper
           AND mcr.dtmvtolt = pr_rw_crapepr.dtmvtolt
           AND mcr.cdagenci = pr_rw_crapepr.cdagenci
           AND mcr.cdbccxlt = pr_rw_crapepr.cdbccxlt
           AND mcr.nrdolote = pr_rw_crapepr.nrdolote
           AND mcr.nrdconta = pr_rw_crapepr.nrdconta
           AND mcr.nrcontra = pr_rw_crapepr.nrctremp
           AND mcr.tpctrmif = 1; -- Emprestimo
      vr_crapmcr_rowid rowid;

      -- Busca de registro de transferencia entre cooperativas
      CURSOR cr_craptco(pr_nrdconta IN craptco.nrdconta%TYPE) IS
        SELECT 'S'
          FROM craptco tco
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.nrdconta = pr_nrdconta
           AND tco.tpctatrf <> 3;
      vr_existco VARCHAR2(1);

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definic?o de tipo para armazenar a taxa da linha de credito
      TYPE typ_tab_craplcr IS
        TABLE OF craplcr.txdiaria%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_craplcr typ_tab_craplcr;

      ------------------------- VARIAVEIS AUXILIARES ------------------------------

      -- Variaveis auxiliares ao processo
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_tab_vldabono NUMBER;                 --> Leitura do valor do abono para emprestimos em atraso
      vr_vldsobra     NUMBER;                 --> Valor de sobra do emprestimo
      vr_vldabono     NUMBER;                 --> Valor do abono do emprestimo
      vr_inliquid     PLS_INTEGER;            --> Indicador de liquidac?o
      vr_qtmesdec     crapepr.qtmesdec%TYPE;  --> Meses decorridos do emprestimo
      vr_flliqmen     crapepr.flliqmen%TYPE;  --> Indica se o emprestimo foi liquidado no mensal.
      vr_qtcalneg     crapepr.qtprecal%TYPE;  --> Quantidade calculada de parcelas do emprestimo
      vr_qtprecal     crapepr.qtprecal%TYPE;  --> Quantidade calculada para atualizar a tabela
      vr_dtinipag     crapepr.dtinipag%TYPE;  --> Data de inicio do pagamento do emprestimo
      vr_flgsaldo     craplcr.flgsaldo%TYPE;  --> Flag de existencia de saldo na linha de credito

      -- Variaveis para chamada a pc_config_empresti_emp
      vr_tab_diapagto NUMBER;  -- Dia de pagamento de emprestimo
      vr_tab_dtcalcul DATE;    -- Data de pagamento de emprestimo
      vr_tab_flgfolha BOOLEAN; -- Flag para desconto em folha
      vr_tab_ddmesnov INTEGER; -- Configurac?o para mes novo

      -- Variaveis para passagem a rotina pc_calcula_lelem
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     NUMBER(25,10);
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;
      vr_vlsdeved     NUMBER(14,2); --> Saldo devedor do emprestimo
      -- Indicador de utilizac?o da tabela de taxa de juros
      vr_inusatab BOOLEAN;

      -- P450 - Regulatório de crédito      
      vr_incrineg     INTEGER;
      vr_tab_retorno  lanc0001.typ_reg_retorno;
      vr_fldebita     BOOLEAN;

      -- PJ298.2.2 - Pos fixado - migracao contratos
      vr_nrctremp_migrado crawepr.nrctremp%type := 0;

      -- Subrotina para checar a existencia de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                               ,pr_nrdolote   IN craplot.nrdolote%TYPE
                               ,pr_tplotmov   IN craplot.tplotmov%TYPE
                               ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                               ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                       ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplot
         INTO pr_rw_craplot; --> Rowtype passado
        -- Se n?o tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a inserc?o de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,pr_nrdolote --> Cfme enviado
                               ,pr_tplotmov --> Cfme enviado
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0)
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO pr_rw_craplot.dtmvtolt
                                ,pr_rw_craplot.cdagenci
                                ,pr_rw_craplot.cdbccxlt
                                ,pr_rw_craplot.nrdolote
                                ,pr_rw_craplot.tplotmov
                                ,pr_rw_craplot.nrseqdig
                                ,pr_rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n?o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

     -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n?o encontrar
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

      -- Validac?es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Se a variavel de erro e <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Busca da moeda UFIR
      OPEN cr_crapmfx;
      FETCH cr_crapmfx
       INTO vr_vlmoefix;
      -- Se n?o encontrar
      IF cr_crapmfx%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapmfx;
        -- Gerar critica 140
        vr_cdcritic := 140;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || ' da UFIR';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar e continuar o process
        CLOSE cr_crapmfx;
      END IF;

      -- Busca do cadastro de linhas de credito de emprestimo
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Guardamos a taxa
        vr_tab_craplcr(rw_craplcr.cdlcremp) := rw_craplcr.txdiaria;
      END LOOP;

      -- Leitura do valor do abono para emprestimos em atraso
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'EMPRATRASO'
                                               ,pr_tpregist => 1);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Converter o valor
        vr_tab_vldabono := NVL(gene0002.fn_char_para_number(vr_dstextab),0);
      ELSE
        -- N?o ha abono
        vr_tab_vldabono := 0;
      END IF;

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posic?o do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- E porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- N?o existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- N?o existe
        vr_inusatab := FALSE;
      END IF;

      -- Leitura dos contratos de emprestimos do associado -- Parte I
      FOR rw_crapepr IN cr_crapepr LOOP
        BEGIN

          -- Se o emprestimo n?o possuir mais saldo devedor, estiver liquidado e com o
          -- ultimo pagamento efetuado no mes anterior
          IF rw_crapepr.vlsdeved = 0 AND rw_crapepr.inliquid = 1 AND rw_crapepr.dtultpag < trunc(rw_crapdat.dtmvtolt,'mm') THEN
            -- Zerar os juros do emprestimo
            BEGIN
              UPDATE crapepr
                 SET vljurmes = 0
               WHERE rowid = rw_crapepr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao zerar os juros para emprestimo liquidado - Conta:'||rw_crapepr.nrdconta
                            ||' CtrEmp:'||rw_crapepr.nrctremp||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Processar o proximo registro
            CONTINUE;
          END IF;
          -- Se o emprestimo for de prejuizo e a data do prejuizo no mes anterior
          IF rw_crapepr.inprejuz > 0 AND rw_crapepr.dtprejuz < trunc(rw_crapdat.dtmvtolt,'mm') THEN
            -- Processar o proximo emprestimo
            CONTINUE;
          END IF;

          -- Buscar a configurac?o de emprestimo cfme a empresa da conta
          empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper         --> Codigo da Cooperativa
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                             ,pr_nrdconta => rw_crapepr.nrdconta --> Numero da conta do emprestimo
                                             ,pr_cdempres => rw_crapepr.cdempres --> Buscaremos a configurac?o cfme empresa do emprestimo e n?o do cadastro
                                             ,pr_dtcalcul => vr_tab_dtcalcul     --> Data calculada de pagamento
                                             ,pr_diapagto => vr_tab_diapagto     --> Dia de pagamento das parcelas
                                             ,pr_flgfolha => vr_tab_flgfolha     --> Flag de desconto em folha S/N
                                             ,pr_ddmesnov => vr_tab_ddmesnov     --> Configurac?o para mes novo
                                             ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                             ,pr_des_erro => vr_dscritic);       --> Retorno de Erro
          -- Se houve erro na rotina
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Levantar excec?o
            RAISE vr_exc_undo;
          END IF;

          -- Inicialiazacao das variaves para a rotina de calculo
          vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
          vr_vlprepag := 0;
          vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
          vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
          vr_vljurmes := 0;
          vr_dtultpag := rw_crapepr.dtultpag;
          vr_inliquid := rw_crapepr.inliquid;

          -- Para emprestimo estiver em aberto
          IF rw_crapepr.inliquid = 0 THEN
            -- Utilizaremos a taxa de juros da linha de credito
            vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp);
          -- Sen?o, se a taxa de juros do emprestimo for superior a da linha
          ELSIF rw_crapepr.txjuremp > vr_tab_craplcr(rw_crapepr.cdlcremp) THEN
            -- Utilizaremos a taxa de juros da linha de credito
            vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp);
          ELSE
            -- Usar taxa cadastrada no emprestimo
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;

          -- Zerar valores de abono e sobra
          vr_vldabono := 0;
          vr_vldsobra := 0;

          -- Chamar rotina de calculo externa
          empr0001.pc_leitura_lem(pr_cdcooper    => pr_cdcooper
                                 ,pr_cdprogra    => vr_cdprogra
                                 ,pr_rw_crapdat  => rw_crapdat
                                 ,pr_nrdconta    => rw_crapepr.nrdconta
                                 ,pr_nrctremp    => rw_crapepr.nrctremp
                                 ,pr_dtcalcul    => null
                                 ,pr_diapagto    => vr_tab_diapagto
                                 ,pr_txdjuros    => vr_txdjuros
                                 ,pr_qtprepag    => vr_qtprepag
                                 ,pr_qtprecal    => vr_qtprecal_lem
                                 ,pr_vlprepag    => vr_vlprepag
                                 ,pr_vljuracu    => vr_vljuracu
                                 ,pr_vljurmes    => vr_vljurmes
                                 ,pr_vlsdeved    => vr_vlsdeved
                                 ,pr_dtultpag    => vr_dtultpag
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_des_erro    => vr_dscritic);
          -- Se a rotina retornou com erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                       ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ' - ' ||
                                        vr_cdprogra || ' --> ' || vr_dscritic);           
            vr_dscritic := NULL;
            vr_cdcritic := 0;
            -- Gerar excec?o
            RAISE vr_exc_undo;
          END IF;
          -- Se o saldo retornar zerado
          IF vr_vlsdeved = 0 THEN
            -- Flegar indicador de liquidac?o
            vr_inliquid := 1;
          -- Sen?o, se o saldo devedor for inferior a zero
          ELSIF vr_vlsdeved < 0 THEN
            -- Gerar sobra de emprestimo, zerar saldo devedor e flegar
            -- indicador de emprestimo liquidado
            vr_vldsobra := vr_vlsdeved * -1;
            vr_vlsdeved := 0;
            vr_inliquid := 1;
          ELSE -- (Saldo superior a zero)
            -- Se o ultimo pagamento e anterior a 60 dias
            -- e o saldo devedor e inferior ou igual ao valor
            -- parametrizado de abono
            IF vr_dtultpag + 60 < rw_crapdat.dtmvtolt AND vr_vlsdeved <= vr_tab_vldabono THEN
              -- Gerar abono para o emprestimo, zerar saldo devedor
              --  e flegar o indicador de emprestimo liquidado
              vr_vldabono := vr_vlsdeved;
              vr_dtultpag := rw_crapdat.dtmvtolt;
              vr_vlsdeved := 0;
              vr_inliquid := 1;
            END IF;
          END IF;

          -- Se o emprestimo estiver com indicador de liquidado e for debito em folha
          IF rw_crapepr.inliquid = 1 AND rw_crapepr.flgpagto = 1 THEN
            -- Atualizar os avisos de debito em conta para debitado
            BEGIN
              UPDATE crapavs
                 SET insitavs = 1 --> Debitado
                    ,vlestdif = 0
                    ,vldebito = rw_crapepr.vlpreemp --> Valor da parcela
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_crapepr.nrdconta
                 AND nrdocmto = rw_crapepr.nrctremp
                 AND tpdaviso = 1
                 AND cdhistor = 108 --> Prestac?o de emprestimo
                 AND insitavs <> 1; --> Qualquer diferente de debitado
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar a tabela de avisos de debito em conta (CRAPAVS) '
                            || '- Conta:'||rw_crapepr.nrdconta ||' CtrEmp:'||rw_crapepr.nrctremp
                            ||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
          END IF;

          -- Se houver juros negativos calculados
          IF vr_vljurmes < 0 THEN
            -- Gerar critica 367 no log e continuar
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || gene0001.fn_busca_critica(367)
                                                       || ' CONTA = ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta)
                                                       || ' CONTRATO = ' || gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9')
                                                       || ' JUROS = ' || to_char(vr_vljurmes,'999g999g999g990d00'));
          -- Sen?o, se houver juros calculados
          ELSIF vr_vljurmes > 0 THEN
            -- Testar se ja retornado o registro de capas de lote para 0 8360
            IF rw_craplot_8360.rowid IS NULL THEN
              -- Chamar rotina para busca-lo, e se n?o encontrar, ira crialo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8360
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8360
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;
            -- Cria lancamento de juros para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrctremp
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,dtpagemp
                                 ,vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8360.dtmvtolt
                                 ,rw_craplot_8360.cdagenci
                                 ,rw_craplot_8360.cdbccxlt
                                 ,rw_craplot_8360.nrdolote
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,rw_crapepr.nrctremp
                                 ,98 --> Juros Emp.
                                 ,rw_craplot_8360.nrseqdig + 1
                                 ,vr_vljurmes
                                 ,vr_txdjuros
                                 ,vr_tab_dtcalcul
                                 ,0);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Atualizar as informac?es no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vljurmes
                    ,vlcompdb = vlinfodb + vr_vljurmes
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8360.rowid
               RETURNING nrseqdig INTO rw_craplot_8360.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8360.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Atualiza valor dos juros pagos em moeda fixa no crapcot
            BEGIN
              UPDATE crapcot
                 SET qtjurmfx = NVL(qtjurmfx,0) + ROUND((vr_vljurmes / vr_vlmoefix),4)
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_crapepr.nrdconta;
              -- Se n?o atualizou nenhum registro
              IF SQL%ROWCOUNT = 0 THEN
                -- Gerar erro 169 pois n?o existe o registro de cotas
                vr_cdcritic := 169;
                vr_dscritic := gene0001.fn_busca_critica(169) || ' - CONTA = '|| gene0002.fn_mask_conta(rw_crapepr.nrdconta);
                -- Retornar
                RAISE vr_exc_undo;
              END IF;
            EXCEPTION
              WHEN vr_exc_undo THEN
                -- Apensar chama-la novamente para o bloco exterior trata-la
                RAISE vr_exc_undo;
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar juros na cota (crapcot), Conta: '||rw_crapepr.nrdconta||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
          END IF;

          IF rw_crapepr.nrctremp IN (256511,337479) THEN
            NULL;
          END IF;

          -- Cria lancamento de sobras para o emprestimo
          IF vr_vldsobra > 0 THEN
            -- Testar se ja retornado o registro de capas de lote para o 8350
            IF rw_craplot_8350.rowid IS NULL THEN
              -- Chamar rotina para busca-lo, e se n?o encontrar, ira crialo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8350
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8350
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;
            -- Cria lancamento de sobras para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrctremp
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,dtpagemp
                                 ,vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8350.dtmvtolt
                                 ,rw_craplot_8350.cdagenci
                                 ,rw_craplot_8350.cdbccxlt
                                 ,rw_craplot_8350.nrdolote
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,rw_crapepr.nrctremp
                                 ,120 --> Sobras Emp.
                                 ,rw_craplot_8350.nrseqdig + 1
                                 ,vr_vldsobra
                                 ,vr_txdjuros
                                 ,vr_tab_dtcalcul
                                 ,rw_crapepr.vlpreemp);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de sobras para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Atualizar as informac?es no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vldsobra
                    ,vlcompdb = vlinfodb + vr_vldsobra
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8350.rowid
               RETURNING nrseqdig INTO rw_craplot_8350.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8350.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Descontar da quantidade de parcelas calculadas o valor da sobra / valor da parcela
            vr_qtprecal_lem := vr_qtprecal_lem - ROUND((vr_vldsobra/rw_crapepr.vlpreemp),4);
            
            -- verificar se o emprestimo foi migrado
            vr_nrctremp_migrado := 0;
            empr9999.pc_verifica_empr_migrado(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_crapepr.nrdconta
                                             ,pr_nrctrnov => rw_crapepr.nrctremp
                                             ,pr_tpempmgr => 1 -- verificar através do original
                                             ,pr_nrctremp => vr_nrctremp_migrado -- (0 Nao migrado, >0 migrado)
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

            -- caso acontecer erro na execucao nao deve parar o programa
            vr_cdcritic := 0;
            vr_dscritic := NULL;

            -- se for emprestimo migrado, nao deve lancar a sobra corrente na conta do cooperado
            IF vr_nrctremp_migrado = 0 THEN
            
            -- Testar se ja retornado o registro de capas de lote para o 8351
            IF rw_craplot_8351.rowid IS NULL THEN
              -- Chamar rotina para busca-lo, e se n?o encontrar, ira crialo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtopr
                             ,pr_nrdolote   => 8351
                             ,pr_tplotmov   => 1
                             ,pr_rw_craplot => rw_craplot_8351
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;

            -- Efetuar lancamento na conta-corrente
             -- P450 - Regulatório de Crédito
             LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot_8351.dtmvtolt
                                               ,pr_cdagenci => rw_craplot_8351.cdagenci
                                               ,pr_cdbccxlt => rw_craplot_8351.cdbccxlt
                                               ,pr_nrdolote => rw_craplot_8351.nrdolote 
                                               ,pr_nrdconta => rw_crapepr.nrdconta
                                               ,pr_nrdocmto => rw_crapepr.nrctremp
                                               ,pr_cdhistor => 20 --> Sobras Empr.
                                               ,pr_nrseqdig => rw_craplot_8351.nrseqdig + 1 
                                               ,pr_vllanmto => vr_vldsobra
                                               ,pr_nrdctabb => rw_crapepr.nrdconta
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nrdctitg => to_char(rw_crapepr.nrdconta,'fm00000000')
                                               -- OUTPUT --
                                               ,pr_tab_retorno => vr_tab_retorno
                                               ,pr_incrineg => vr_incrineg
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic); 
                              
             IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_undo;
             END IF; 
             
            -- Atualizar as informac?es no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + vr_vldsobra
                    ,vlcompcr = vlcompcr + vr_vldsobra
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8351.rowid
               RETURNING nrseqdig INTO rw_craplot_8351.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8351.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            END IF; -- IF vr_nrctremp_migrado = 0 THEN
          END IF;
           
           

          -- Se houve valor de abono
          IF vr_vldabono > 0 THEN
            -- Testar se ja retornado o registro de capas de lote para o 8370
            IF rw_craplot_8370.rowid IS NULL THEN
              -- Chamar rotina para busca-lo, e se n?o encontrar, ira crialo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8370
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8370
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;
            -- Cria lancamento de abono para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrctremp
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,dtpagemp
                                 ,vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8370.dtmvtolt
                                 ,rw_craplot_8370.cdagenci
                                 ,rw_craplot_8370.cdbccxlt
                                 ,rw_craplot_8370.nrdolote
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,rw_crapepr.nrctremp
                                 ,94 --> DESC/ABON.EMP
                                 ,rw_craplot_8370.nrseqdig + 1
                                 ,vr_vldabono
                                 ,vr_txdjuros
                                 ,vr_tab_dtcalcul
                                 ,rw_crapepr.vlpreemp);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de abono para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Atualizar as informac?es no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + vr_vldabono
                    ,vlcompcr = vlinfocr + vr_vldabono
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8370.rowid
               RETURNING nrseqdig INTO rw_craplot_8370.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                pr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8370.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Descontar da quantidade de parcelas calculadas o valor do abono / valor da parcela
            vr_qtprecal_lem := vr_qtprecal_lem + ROUND((vr_vldabono/rw_crapepr.vlpreemp),4);
          END IF;

          -- Para contratos do mes corrente
          IF TRUNC(rw_crapepr.dtmvtolt,'mm') = TRUNC(rw_crapdat.dtmvtolt,'mm') THEN
            -- Verificar se existe o registro de Microfilmagem do Contrato
            vr_crapmcr_rowid := null;
            OPEN cr_crapmcr(pr_rw_crapepr => rw_crapepr);
            FETCH cr_crapmcr
             INTO vr_crapmcr_rowid;
            CLOSE cr_crapmcr;
            -- Se encontrou
            IF vr_crapmcr_rowid IS NOT NULL THEN
              -- Apenas enviar ao LOG
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || 'ATENCAO: Contrato ja microfilmado.'
                                                         || ' Conta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta)
                                                         || '  Contrato: ' || gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9'));
            ELSE
              -- Criacao do registro para Microfilmagem dos Contratos
              BEGIN
                INSERT INTO crapmcr(cdcooper
                                   ,dtmvtolt
                                   ,cdagenci
                                   ,cdbccxlt
                                   ,nrdolote
                                   ,nrdconta
                                   ,nrcontra
                                   ,tpctrmif
                                   ,vlcontra
                                   ,qtpreemp
                                   ,nrctaav1
                                   ,nrctaav2
                                   ,cdlcremp
                                   ,cdfinemp)
                             VALUES(pr_cdcooper
                                   ,rw_crapepr.dtmvtolt
                                   ,rw_crapepr.cdagenci
                                   ,rw_crapepr.cdbccxlt
                                   ,rw_crapepr.nrdolote
                                   ,rw_crapepr.nrdconta
                                   ,rw_crapepr.nrctremp
                                   ,1 -- Emprestimo
                                   ,rw_crapepr.vlemprst
                                   ,rw_crapepr.qtpreemp
                                   ,rw_crapepr.nrctaav1
                                   ,rw_crapepr.nrctaav2
                                   ,rw_crapepr.cdlcremp
                                   ,rw_crapepr.cdfinemp);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao criar registro de microfilmagem do emprestimo (CRAPMCR) '
                              || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                              || '. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
            END IF;
            -- Inicializa os meses decorridos para os contratos do mes
            -- Para emprestimo em conta corrente
            IF rw_crapepr.flgpagto = 0 THEN
              -- Quantidade de meses decorrido e a diferenca inteira de meses
              -- entre o mes da data atual e o mes da data do primeiro pagamento
              -- do emprestimo
              -- Obs.: Utilizamos trunc(data,'mm') para usar o primeiro dia do mes
              --       para justamente considerar somente o mes no calculo, sen?o
              --       por ex 30/11 > 20/12 seria 0.6774 e n?o 1 mes
              vr_qtmesdec := months_between(trunc(rw_crapdat.dtmvtolt,'mm'),trunc(rw_crapepr.dtdpagto,'mm'));
            ELSE
              -- Se o dia do pagamento emprestimo for superior ao dia de virada do mes da empresa
              IF to_char(rw_crapepr.dtmvtolt,'dd') >= vr_tab_ddmesnov THEN
                -- Mes novo
                vr_qtmesdec := -2;
              ELSE
                -- Normal
                vr_qtmesdec := -1;
              END IF;
            END IF;
          ELSE
            -- N?o e um contrato do mes corrente, portanto mantem o valor de meses decorridos
            vr_qtmesdec := rw_crapepr.qtmesdec;
          END IF;
          -- Incrementar a quantidade de meses decorrida encontrada acima
          vr_qtmesdec := vr_qtmesdec + 1;
          -- Se o emprestimo n?o estava liquidado e a flag de liquidac?o foi ativada
          IF rw_crapepr.inliquid = 0 AND vr_inliquid = 1 THEN
            -- Indica que o emprestimo foi liquidado no mensal.
            vr_flliqmen := 1;
          ELSE
            -- Mantemos o valor da tabela
            vr_flliqmen := rw_crapepr.flliqmen;
          END IF;
          -- Armazenar a diferenca do da quantidade de parcelas na tabela e da calculada
          vr_qtcalneg := rw_crapepr.qtprecal + vr_qtprecal_lem;
          -- Se a diferenca for inferior a zero
          IF vr_qtcalneg < 0 THEN
            -- Armazenaremos zero na quantidade calculada de parcelas
            vr_qtprecal := 0;
          ELSE
            -- Armazenaremos a diferenca calculada
            vr_qtprecal := vr_qtcalneg;
          END IF;
          -- Se decorreu-se apenas 1 mes
          IF vr_qtmesdec = 1 THEN
            -- Utilizaremos o primeiro dia do mes corrente
            vr_dtinipag := rw_crapdat.dtinimes;
          ELSE
            -- Manteremos a data de pagamento da tabela
            vr_dtinipag := rw_crapepr.dtinipag;
          END IF;
          -- Enfim atualizaremos as informac?es na tabela de emprestimo
          BEGIN
            UPDATE crapepr
               SET qtmesdec = vr_qtmesdec
                  ,flliqmen = vr_flliqmen
                  ,qtprecal = vr_qtprecal
                  ,dtinipag = vr_dtinipag
                  ,txjuremp = vr_txdjuros
                  ,dtultpag = vr_dtultpag
                  ,qtprepag = vr_qtprepag
                  ,vlsdeved = vr_vlsdeved
                  ,vljurmes = vr_vljurmes
                  ,vljuracu = vr_vljuracu
                  ,inliquid = vr_inliquid
                  ,indpagto = 0
                  ,vlpagmes = 0
                  ,vlsdevat = vr_vlsdeved
             WHERE rowid = rw_crapepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar o emprestimo (CRAPEPR).'
                          || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_undo;
          END;
          -- Somente para emprestimos que foram liquidados neste processamento
          IF vr_inliquid = 1 THEN
            -- Verificar se existe o registro de Microfilmagem do Contrato
            vr_crapmcr_rowid := null;
            OPEN cr_crapmcr(pr_rw_crapepr => rw_crapepr);
            FETCH cr_crapmcr
             INTO vr_crapmcr_rowid;
            CLOSE cr_crapmcr;
            -- Se encontrou
            IF vr_crapmcr_rowid IS NOT NULL THEN
              -- Atualizar data da baixa
              BEGIN
                UPDATE crapmcr
                   SET dtdbaixa = vr_dtultpag
                 WHERE rowid = vr_crapmcr_rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao atualizar a data de baixa da Microfilmagem (CRAPMCR).'
                              || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                              || '. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
            ELSE
              -- Verifica se existe registro de transferencia da conta entre cooperativas
              vr_existco := 'N';
              OPEN cr_craptco(pr_nrdconta => rw_crapepr.nrdconta);
              FETCH cr_craptco
               INTO vr_existco;
              CLOSE cr_craptco;
              -- Se n?o existir
              IF NVL(vr_existco,'N') = 'N' THEN
                -- Gerar log
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || 'ATENCAO: Contrato NAO microfilmado.'
                                                           || ' Conta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta)
                                                           || '  Contrato: ' || gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9'));
              END IF;
            END IF;

            -- Desativar o rating deste contrato
            rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Codigo da Cooperativa
                                       ,pr_cdagenci   => 0                   --> Codigo da agencia
                                       ,pr_nrdcaixa   => 0                   --> Numero do caixa
                                       ,pr_cdoperad   => pr_cdoperad         --> Codigo do operador
                                       ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parametro (CRAPDAT)
                                       ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                       ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Emprestimo)
                                       ,pr_nrctrrat   => rw_crapepr.nrctremp --> Numero do contrato de Rating
                                       ,pr_flgefeti   => 'S'                 --> Flag para efetivac?o ou n?o do Rating
                                       ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                       ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                       ,pr_inusatab   => vr_inusatab         --> Indicador de utilizac?o da tabela de juros
                                       ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                       ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                       ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possives erros

            --------------------------------------------------------------------
            ----- N?o vers?o progress n?o testava se retornou erro aqui...  ----
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
            --  -- Levantar excec?o
            --  RAISE vr_exc_erro;
            --END IF;

            /** GRAVAMES **/
            IF  rw_crapepr.inprejuz <> 1 -- Rotina solicita_baixa_automatica so deve ser efetuada se o contrato n?o estiver em prejuizo:
            AND vr_flliqmen = 1     THEN -- Indica que o emprestimo foi liquidado no mensal.
              GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Codigo da cooperativa
                                                   ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                                   ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                                   ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                                   ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                                   ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                                   ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica
              -- No progress n?o e verificado retorno de erro no procedimento acima.
            END IF;

          END IF;

          -- Se a quantidade de meses calculada ficou negativa e foi zerada
          IF vr_qtcalneg < 0 THEN
            -- Gerar log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || 'ATENCAO: QTPRECAL NEGATIVO.'
                                                       || ' Conta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta)
                                                       || '  Contrato: ' || gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9')
                                                       || '  QTPRECAL: ' || to_char(vr_qtcalneg,'999g990d0000'));
          END IF;

          -- Se ainda houver saldo devedor ao emprestimo
          IF vr_vlsdeved > 0 THEN
            -- Se a linha atual n?o estiver na lista de linhas para restart
            IF instr(vr_dslinhas,to_char(rw_crapepr.cdlcremp,'fm0000')||',') <= 0 THEN
              -- Adiciona-la
              vr_dslinhas := vr_dslinhas || to_char(rw_crapepr.cdlcremp,'fm0000') || ',';
            END IF;
          END IF;

        EXCEPTION
          WHEN vr_exc_undo THEN
            
            -- Se foi retornado apenas codigo
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
              -- Buscar a descric?o
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
            -- Desfazer transacoes desde o ultimo commit
            --ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            --RAISE vr_exc_saida;
        END;
      END LOOP; -- Fim leitura dos emprestimos
      -- Busca de todas as linhas de credito
      FOR rw_craplcr IN cr_craplcr LOOP
        -- Se a linha foi processada acima
        IF instr(vr_dslinhas,to_char(rw_craplcr.cdlcremp,'fm0000')||',') > 0 THEN
          -- Indica que ha saldo na linha
          vr_flgsaldo := 1;
        ELSE
          -- Indica que n?o ha saldo na linha
          vr_flgsaldo := 0;
        END IF;
        -- Atualiza a tabela
        BEGIN
          UPDATE craplcr lcr
             SET lcr.flgsaldo = vr_flgsaldo
           WHERE lcr.rowid = rw_craplcr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar a Linha de Credito (CRAPLCR)'
                        || '- Linha:'||rw_craplcr.cdlcremp||'. Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END LOOP; --> Fim atualizac?o das linhas de credito

      -- Zerar indicador de integrac?o da folha
      BEGIN
        UPDATE craptab tab
           SET tab.dstextab = SUBSTR(tab.dstextab,1,13) || '0'
         WHERE tab.cdcooper = pr_cdcooper
           AND tab.cdacesso = 'DIADOPAGTO';
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          vr_dscritic := 'Erro ao atualizar o Indicador de Integrac?o da Folha (CRAPTAB). Detalhes: '||sqlerrm;
          RAISE vr_exc_saida;
      END;

      -- Efetuar commit final
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descric?o
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
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descric?o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos codigo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN
        -- Efetuar retorno do erro n?o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps078;
/
