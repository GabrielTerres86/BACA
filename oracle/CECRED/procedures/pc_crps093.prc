CREATE OR REPLACE PROCEDURE CECRED.pc_crps093 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da Cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da crítica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_crps093   (Antigo: Fontes/crps093.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Deborah/Edson
     Data    : Agosto/94.                          Ultima atualizacao: 01/04/2015

     Dados referentes ao programa:

     Frequencia: Mensal (Batch) - projeto 364 alterado para Diaria
     Objetivo  : Geracao dos lancamentos de baixa de capital e saldo dos demi-
                 tidos. Atende a solicitacao 052.

     Alteracoes: 08/12/94 - Alterado para nao permitir a baixa se o associado ti-
                          ver algum registro em craprda (aplicacoes finaceiras
                          RDCA) (Deborah).

                 14/03/95 - Alterado para executar somente nos finais de tri-
                            mestre (Edson).

                 05/07/95 - Alterado para analisar os avisos e os debitos em
                            conta (Odair).

                 24/11/95 - Acerto na atualizacao dos saldos medios (Deborah).

                 21/03/96 - Alterado para analisar poupanca programada (Odair).

                 21/08/96 - Alterado nao baixar se o associado tiver cartao
                            Credicard (Edson).

                 17/04/97 - Alterado para analisar cartao de credito (Odair).

                 09/07/97 - Atualizar crapsld.vlsdanes (Odair)

                 25/09/97 - Alterado para nao executar ate segunda ordem (Edson).

                 02/01/98 - Alterado para executar apenas nos meses de JUNHO e
                            DEZEMBRO (Edson).

                 29/07/98 - Como o vlipmfap podera ser < 0, alterado para tratar
                            por diferente de 0. (Deborah)

                 09/11/98 - Nao eliminar se a situacao estiver com prejuizo
                            (Deborah).

                 19/11/98 - Nao eliminar se houver valores em crapcot.qtrsjmfx
                            (Deborah).

                 11/12/2000 - Alterar o programa para incluir alguns criterios
                              de selecao. (Eduardo)

                 18/12/2000 - Liberado para rodar (Deborah).

                 10/04/2001 - Acerto para baixar o retorno creditado para
                              contas que ja estavam com dtelimin (Deborah).

                 28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                              craplcm e craplct (Diego).

                 14/07/2005 - Ajuste no saldo medio e saldo diario (Edson).

                 14/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

                 19/10/2005 - Solicitado para comentar o campo vldoipmf (SQLWorks).

                 10/11/2005 - Incluido o tpcheque no uso da crapfdc (Evandro).

                 14/12/2005 - Alimentar o crapfdc.dtliqchq no cancelamento do
                              cheque (Edson).

                 15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                 12/08/2010 - Alteraçao na verificaçao de operacoes pendentes
                              do crapass (Vitor).

                 20/01/2011 - Alteraçao no consulta de lancamentos automaticos
                              e consulta de cartoes de credito (Irlan)

                 02/03/2011 - Inclusao da opcao crawcrd.insitcrd = 6 para nao
                              considerar os registros encerrados
                              (Isara - RKAM)

                 02/08/2011 - Nao sera permitido eliminar um associado quando este,
                              tiver algum tipo de limite ativo (Adriano).

                 19/10/2011 - Tratamento melhorias seguro (Diego).

                 27/09/2012 - Removido tratamento para o campo vllimcrd
                              do for each crapass (Lucas R).

                 28/03/2013 - Ajustes referentes ao Projeto Tarifas Fase 2
                              Grupo de cheque (Lucas R.).

                 16/09/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom)

                 22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                              ser acionada em caso de saída para continuação da cadeia,
                              e não em caso de problemas na execução (Marcos-Supero)

                 25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

                 25/03/2014 - Ajustes devido falta de conversão na atualização da crapmat (Marcos-Supero)

                 08/08/2014 - Adicionado tratamento para craprac. (Reinert)

                 01/04/2015 - Projeto de separação contábeis de PF e PJ.
                              (Andre Santos - SUPERO)

				 06/01/2017 - Ajustado para não parar o processo em caso de parâmetro
							  nulo. (Rodrigo - 586601)
                
                 14/11/2017 - Projeto 364 - Estruturar demissão cooperado
                              (Demetrius Wolff - Mouts)
      ............................................................................. */

    DECLARE
      -- Tipo de registro para armazenar os contratos de limites de crédito
      TYPE typ_reg_craplim IS
      RECORD (nrdconta craplim.nrdconta%TYPE);
      --
      TYPE typ_tab_craplim IS
        TABLE OF typ_reg_craplim
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craplim03  typ_tab_craplim;

      -- Tipo de registro para armazenar o cadastro das autorizações de débitos em conta
      TYPE typ_reg_crapatr IS
      RECORD (nrdconta crapatr.nrdconta%TYPE);
      --
      TYPE typ_tab_crapatr IS
        TABLE OF typ_reg_crapatr
        INDEX BY PLS_INTEGER;
      --
      vr_tab_crapatr typ_tab_crapatr;

      -- Tipo de registro para armazenar o cadastro de poupanças programadas
      TYPE typ_reg_craprpp IS
      RECORD (nrdconta craprpp.nrdconta%TYPE);
      --
      TYPE typ_tab_craprpp IS
        TABLE OF typ_reg_craprpp
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craprpp typ_tab_craprpp;


      -- Tipo de registro para armazenar os lancamentos automaticos
      TYPE typ_reg_craplau IS
      RECORD (nrdconta craplau.nrdconta%TYPE);
      --
      TYPE typ_tab_craplau IS
        TABLE OF typ_reg_craplau
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craplau typ_tab_craplau;


      -- Tipo de registro para armazenar o cadastro de seguros ativos/renovados/substituídos
      TYPE typ_reg_crapseg IS
      RECORD (nrdconta crapseg.nrdconta%TYPE);
      --
      TYPE typ_tab_crapseg IS
        TABLE OF typ_reg_crapseg
        INDEX BY PLS_INTEGER;
      --
      vr_tab_crapseg typ_tab_crapseg;

      -- Tipo de registro para armazenar os lançamentos de tarifas
      TYPE typ_reg_craplat IS
      RECORD (nrdconta craplat.nrdconta%TYPE);
      --
      TYPE typ_tab_craplat IS
        TABLE OF typ_reg_craplat
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craplat typ_tab_craplat;

      -- Tipo de registro para armazenar o cadastro de cartoes magneticos solicitados e ativos (1,2)
      TYPE typ_reg_crapcrm IS
      RECORD ( nrdconta crapcrm.nrdconta%TYPE);
      --
      TYPE typ_tab_crapcrm IS
        TABLE OF typ_reg_crapcrm
        INDEX BY PLS_INTEGER;
      --
      vr_tab_crapcrm typ_tab_crapcrm;

      -- Tipo de registro para armazenar o cadastro de controle de cartoes de crédito não cancelados
      TYPE typ_reg_crawcrd IS
      RECORD ( nrdconta crawcrd.nrdconta%TYPE);
      --
      TYPE typ_tab_crawcrd IS
        TABLE OF typ_reg_crawcrd
        INDEX BY PLS_INTEGER;
      --
      vr_tab_crawcrd typ_tab_crawcrd;

      -- Tipo de registro para armazenar o cadastro de aplicações RDCA
      TYPE typ_reg_craprda IS
      RECORD (nrdconta craprda.nrdconta%TYPE);
      --
      TYPE typ_tab_craprda IS
        TABLE OF typ_reg_craprda
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craprda typ_tab_craprda;
			
      -- Tipo de registro para armazenar o registro de aplicações de captação
      TYPE typ_reg_craprac IS
      RECORD (nrdconta craprac.nrdconta%TYPE);
      --
      TYPE typ_tab_craprac IS
        TABLE OF typ_reg_craprac
        INDEX BY PLS_INTEGER;
      --
      vr_tab_craprac typ_tab_craprac;

      -- Tipo de registro para armazenar o cadastro de empréstimos
      TYPE typ_reg_crapepr IS
      RECORD (nrdconta crapepr.nrdconta%TYPE);
      --
      TYPE typ_tab_crapepr IS
        TABLE OF typ_reg_crapepr
        INDEX BY PLS_INTEGER;
      --
      vr_tab_crapepr  typ_tab_crapepr;

      ------------------------------------------------
      -- DECLARAÇÃO DE CURSORES
      ------------------------------------------------
      --Seleciona informacoes cadastro de empréstimos
      CURSOR cr_crapepr ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapepr.nrdconta
        FROM   crapepr
        WHERE  crapepr.cdcooper = pr_cdcooper
        AND    crapepr.inliquid = 0;
      --rw_crapepr cr_crapepr%ROWTYPE;

      --Seleciona informacoes dos contratos de limites de crédito que não estejam cancelados
      CURSOR cr_craplim03 ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT craplim.nrdconta
        FROM   craplim
        WHERE  craplim.cdcooper = pr_cdcooper
        AND    craplim.insitlim <> 3;

      --Seleciona informacoes do cadastro de aplicações RDCA
      CURSOR cr_craprda ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT craprda.nrdconta
        FROM   craprda
        WHERE  craprda.cdcooper = pr_cdcooper
        AND    craprda.insaqtot = 0;
      rw_craprda cr_craprda%ROWTYPE;

      --Seleciona informacoes do cadastro das autorizações de débitos em conta
      CURSOR cr_crapatr ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapatr.nrdconta
        FROM   crapatr
        WHERE  crapatr.cdcooper = pr_cdcooper;

      --Seleciona informacoes do cadastro de poupanças programadas
      CURSOR cr_craprpp ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT craprpp.nrdconta
        FROM   craprpp
        WHERE  craprpp.cdcooper = pr_cdcooper
        AND    craprpp.cdsitrpp = 1;

      --Seleciona informacoes de lancamentos automaticos
      CURSOR cr_craplau ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT craplau.nrdconta
        FROM   craplau
        WHERE  craplau.cdcooper +0 = pr_cdcooper
        AND    craplau.dtdebito IS NULL;

      --Seleciona informacoes do cadastro de seguros
      CURSOR cr_crapseg ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_dtmvtolt IN DATE) IS
        -- Seguros ativos
        SELECT crapseg.nrdconta
        FROM   crapseg
        WHERE  crapseg.cdcooper = pr_cdcooper
        AND    crapseg.cdsitseg = 1
        UNION
        -- Seguro CASA Renovado
        SELECT crapseg.nrdconta
        FROM   crapseg
        WHERE  crapseg.cdcooper = pr_cdcooper
        AND    (crapseg.cdsitseg  = 3 AND crapseg.tpseguro  = 11)
        UNION
        -- Seguro AUTO Substiuido
        SELECT crapseg.nrdconta
        FROM   crapseg
        WHERE  crapseg.cdcooper = pr_cdcooper
        AND (crapseg.cdsitseg  = 3 AND
             crapseg.tpseguro  = 2 AND
             crapseg.dtfimvig >= pr_dtmvtolt);

      --Seleciona informacoes do cadastro de lançamentos de tarifas
      CURSOR cr_craplat ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT craplat.nrdconta
        FROM   craplat
        WHERE  craplat.cdcooper = pr_cdcooper
        AND    craplat.insitlat = 1;

      --Seleciona informacoes do cadastro de avalistas
      CURSOR cr_crapavl ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapavl.nrdconta
              ,crapavl.nrctaavd
              ,crapavl.tpctrato
        FROM   crapavl
        WHERE  crapavl.cdcooper = pr_cdcooper
        AND    crapavl.nrdconta = pr_nrdconta
        AND    crapavl.tpctrato IN( 1   -- emprestimo
                                   ,2   -- desconto de cheques
                                   ,3   -- cheque especial
                                   ,4   -- cartão
                                   ,8); -- desconto de títulos
      rw_crapavl cr_crapavl%ROWTYPE;

      --Seleciona informacoes do cadastro de cartoes magneticos solicitados e ativos (1,2)
      CURSOR cr_crapcrm ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapcrm.nrdconta
        FROM   crapcrm
        WHERE  crapcrm.cdcooper = pr_cdcooper
        AND    crapcrm.cdsitcar < 2; -- PJ 364 somente ativos  (sit=2 vencidos não deve impedir)

      --Seleciona informacoes do cadastro de controle de cartoes de crédito não cancelados
      CURSOR cr_crawcrd ( pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crawcrd.nrdconta
        FROM   crawcrd
        WHERE  crawcrd.cdcooper = pr_cdcooper
        AND    crawcrd.insitcrd NOT IN (5, 6);

      --Seleciona informacoes do cadastro de saldos
      CURSOR cr_crapsld ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapsld.nrdconta
              ,crapsld.qtddsdev
              ,crapsld.vlsdbloq
              ,crapsld.vlipmfap
              ,crapsld.vlipmfpg
              ,crapsld.vlsdblpr
              ,crapsld.vlsdblfp
              ,crapsld.vlsddisp
              ,crapsld.vlsdchsl
              ,crapsld.rowid
        FROM   crapsld
        WHERE  crapsld.cdcooper = pr_cdcooper
        AND    crapsld.nrdconta = pr_nrdconta;
      rw_crapsld cr_crapsld%ROWTYPE;

      --Seleciona o valor total dos cheques do cadastro de folhas de cheque emitidas para o cooperado
      CURSOR cr_crapfdc01 ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE )  IS
        SELECT nvl(SUM(crapfdc.vlcheque),0) vlcheque
        FROM   crapfdc
        WHERE  crapfdc.cdcooper = pr_cdcooper
        AND    crapfdc.nrdconta = pr_nrdconta
        AND    crapfdc.tpcheque = 3
        AND    crapfdc.incheque = 0;
      rw_crapfdc01 cr_crapfdc01%ROWTYPE;

      --Seleciona informacoes de cotas e recursos
      CURSOR cr_crapcot ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapcot.nrdconta
              ,crapcot.qtjurmfx
              ,crapcot.qtraimfx
              ,crapcot.qtrsjmfx
              ,crapcot.vldcotas
              ,crapcot.vlcmicot
              ,crapcot.vlcmmcot
              ,crapcot.qtcotmfx
              ,crapcot.rowid
        FROM   crapcot
        WHERE  crapcot.cdcooper = pr_cdcooper
        AND    crapcot.nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;

       -- seleciona capa de lote por dia e tipo de lote
       CURSOR cr_craplot ( pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_dtmvtolt IN DATE
                          ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
         SELECT craplot.rowid
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.nrseqdig
               ,craplot.qtinfoln
               ,craplot.qtcompln
               ,craplot.cdcooper
               ,craplot.dtmvtolt
               ,craplot.vlinfodb
               ,craplot.vlcompdb
         FROM   craplot
         WHERE  craplot.cdcooper = pr_cdcooper
         AND    craplot.dtmvtolt = pr_dtmvtolt
         AND    craplot.cdagenci = 1
         AND    craplot.cdbccxlt = 100
         AND    craplot.nrdolote = pr_nrdolote;
      rw_craplot7200  cr_craplot%ROWTYPE;
      rw_craplot8006  cr_craplot%ROWTYPE;

 

      --Selecionar informacoes dos associados
      CURSOR cr_crapass ( pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_dtlimite IN DATE
                         ,pr_nrctares IN crapass.nrdconta%TYPE
                         ,pr_dtmvtolt IN DATE) IS
        SELECT  crapass.nrdconta
               ,crapass.inpessoa
               ,crapass.dtelimin
               ,crapass.inmatric
               ,ROWID
        FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   (crapass.dtelimin IS NULL OR crapass.dtelimin = to_date('29/12/2000','DD/MM/RRRR'))
        AND   crapass.vllimcre = 0
        AND   crapass.cdsitdtl < 5
        AND   crapass.dtdemiss < pr_dtlimite
        AND   crapass.nrdconta > pr_nrctares
        AND   NOT EXISTS ( SELECT 1
                           FROM   crapavs
                           WHERE  crapavs.cdcooper = crapass.cdcooper
                           AND    crapavs.nrdconta = crapass.nrdconta)
-- PJ 364 - Sarah solicitou retirar consitencia de folha de cheque
--        AND   NOT EXISTS ( SELECT 1
--                           FROM   crapfdc
--                           WHERE  crapfdc.cdcooper = crapass.cdcooper
--                           AND    crapfdc.nrdconta = crapass.nrdconta
--                           AND    crapfdc.tpcheque <> 3
--                           AND    crapfdc.incheque = 0)
        AND   NOT EXISTS(  SELECT 1
                           FROM   craplim
                           WHERE  craplim.cdcooper = crapass.cdcooper
                           AND    craplim.nrdconta = crapass.nrdconta
                           AND    craplim.insitlim = 2)
        AND   NOT EXISTS(  SELECT 1
                           FROM   crapsli
                           WHERE  crapsli.cdcooper = crapass.cdcooper
                           AND    crapsli.nrdconta = crapass.nrdconta
                           AND    to_char(crapsli.dtrefere,'MMYYYY') = to_char(pr_dtmvtolt, 'MMYYYY')
                           AND    crapsli.vlsddisp <> 0)
        ORDER BY crapass.nrdconta;

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres( pr_cdcooper IN crapres.cdcooper%TYPE
                        ,pr_cdprogra IN crapres.cdprogra%TYPE) IS
        SELECT res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = pr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;
			
			-- Selecionar registro de aplicação da captação
			CURSOR cr_craprac( pr_cdcooper IN craprac.cdcooper%TYPE ) IS
			  SELECT rac.nrdconta
				  FROM craprac rac
				 WHERE rac.cdcooper = pr_cdcooper AND
               rac.idsaqtot = 0;

      -- Código do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS093';
      -- Tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_saida    EXCEPTION;
      vr_des_erro     VARCHAR2(4000);
      vr_exc_fimprg   EXCEPTION;
      -- Controle para rollback to savepoint
      vr_exc_undo     EXCEPTION;
      -- Variáveis de controle de calendário
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      -- Variável para retorno de busca na craptab
      vr_dstextab     craptab.dstextab%TYPE;
      vr_flgfound     BOOLEAN := TRUE;
      -- Variáveis para controle de restart
      vr_nrctares     crapass.nrdconta%TYPE;--> Número da conta de restart
      vr_dsrestar     VARCHAR2(4000);       --> String genérica com informações para restart
      vr_inrestar     INTEGER;              --> Indicador de Restart
      -- Demais variáveis de controle
      vr_vldcotas     NUMBER;
      vr_vldcotpf     NUMBER; --> Separando o valor de cotas por PF
      vr_vldcotpj     NUMBER; --> Separando o valor de cotas por PJ
      vr_vlcmicot     NUMBER;
      vr_vlcmmcot     NUMBER;
      vr_qtcotmfx     NUMBER(15,4);
      vr_qtdiabax     INTEGER;
      vr_qtassbai     INTEGER;
      vr_qtasbxpf     INTEGER;
      vr_qtasbxpj     INTEGER;
      vr_dtlimite     DATE;
      vr_flgzerar     BOOLEAN;
      vr_idsmstre     NUMBER;
      vr_vllanmto     NUMBER;
      vr_qtproces     NUMBER;


      --Procedure para limpar os dados das tabelas de memoria
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        vr_tab_crapepr.delete;
        vr_tab_craplim03.delete;
        vr_tab_craprda.delete;
        vr_tab_crapatr.delete;
        vr_tab_craprpp.delete;
        vr_tab_craplau.delete;
        vr_tab_crapseg.delete;
        vr_tab_craplat.delete;
        vr_tab_crapcrm.delete;
        vr_tab_crawcrd.delete;
				vr_tab_craprac.delete;
      END;
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS093'
                                ,pr_action => null);

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
	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
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
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Carrega o numero de dias para baixa dos valores
      TABE0001.pc_busca_craptab(pr_cdcooper => pr_cdcooper
																							 ,pr_nmsistem => 'CRED'
																							 ,pr_tptabela => 'USUARI'
																							 ,pr_cdempres => 11
																							 ,pr_cdacesso => 'DIASBAXVAL'
							   ,pr_tpregist => 0
							   ,pr_flgfound => vr_flgfound
							   ,pr_dstextab => vr_dstextab);

			-- se não encontrar o parâmetro gera exceção e aborta a execução do programa
      IF NOT vr_flgfound THEN
        -- Código da crítica
        vr_cdcritic := 408;
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres( pr_cdcooper => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra);
        FETCH cr_crapres INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      vr_qtdiabax := gene0002.fn_char_para_number(vr_dstextab);

      -- Se o valor estiver null ou deu erro de conversão ou veio vazio
      IF vr_qtdiabax IS NULL THEN
        -- Código da crítica
        vr_cdcritic := 408;
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - Impossível converter parâmetro DIASBAXVAL para número.';
        --Envio do log de erro
        RAISE vr_exc_fimprg;
      END IF;

      BEGIN
        vr_qtassbai := gene0002.fn_char_para_number(SUBSTR(vr_dsrestar,001,008)); -- Total de contagem de associados baixados/demitidos
        vr_qtasbxpf := gene0002.fn_char_para_number(SUBSTR(vr_dsrestar,010,008)); -- Contagem de associados PF baixados/demitidos
        vr_qtasbxpj := gene0002.fn_char_para_number(SUBSTR(vr_dsrestar,019,008)); -- Contagem de associados PJ baixados/demitidos
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao converter a informação genérica com informações para restart('||vr_dsrestar||')';
          RAISE vr_exc_saida;
      END;

      vr_dtlimite := rw_crapdat.dtmvtolt - nvl(vr_qtdiabax,0);

      -- É verdadeiro a partir do momento que não tenha iniciado a partir de restart.
      vr_flgzerar := nvl(vr_inrestar,0) = 0;

      -- Limpando as tabelas de memória
      pc_limpa_tabela;

			-- Carregando dos contratos de limites de crédito não cancelados
      FOR rw_craplim03 IN cr_craplim03( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craplim03(rw_craplim03.nrdconta).nrdconta := rw_craplim03.nrdconta;
      END LOOP;

			-- Carregando as informações do cadastro de autorizações de débitos em conta
      FOR rw_crapatr IN cr_crapatr( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapatr(rw_crapatr.nrdconta).nrdconta := rw_crapatr.nrdconta;
      END LOOP;

			-- Carregando as informações do cadastro de poupanças programadas
      FOR rw_craprpp IN cr_craprpp( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craprpp(rw_craprpp.nrdconta).nrdconta := rw_craprpp.nrdconta;
      END LOOP;

			-- Carregando as informações de lancamentos automaticos
--Pj 364 - Sarah solicitou retirar essa restricao
--      FOR rw_craplau IN cr_craplau( pr_cdcooper => pr_cdcooper) LOOP
--        vr_tab_craplau(rw_craplau.nrdconta).nrdconta := rw_craplau.nrdconta;
--      END LOOP;

			-- Carregando as informações do cadastro de seguros ativos/renovados/substituídos
--Pj 364 - Sarah solicitou retirar essa restricao
--      FOR rw_crapseg IN cr_crapseg( pr_cdcooper => pr_cdcooper
--                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
--        vr_tab_crapseg(rw_crapseg.nrdconta).nrdconta := rw_crapseg.nrdconta;
--      END LOOP;

			-- Carregando as informações do cadastro de poupanças programadas
      FOR rw_craplat IN cr_craplat( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craplat(rw_craplat.nrdconta).nrdconta := rw_craplat.nrdconta;
      END LOOP;

			-- Carregando as informações do cadastro de cartoes magneticos solicitados e ativos (1,2)
      FOR rw_crapcrm IN cr_crapcrm( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapcrm(rw_crapcrm.nrdconta).nrdconta := rw_crapcrm.nrdconta;
      END LOOP;

			-- Carregando as informações do cadastro de controle de cartoes de crédito não cancelados
      FOR rw_crawcrd IN cr_crawcrd( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crawcrd(rw_crawcrd.nrdconta).nrdconta := rw_crawcrd.nrdconta;
      END LOOP;

			-- Carregando as informações de lançamentos automáticos
      FOR rw_crapepr IN cr_crapepr( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapepr(rw_crapepr.nrdconta).nrdconta := rw_crapepr.nrdconta;
      END LOOP;

			-- Carregando as informações do cadastro de aplicações RDCA
      FOR rw_craprda IN cr_craprda( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craprda(rw_craprda.nrdconta).nrdconta := rw_craprda.nrdconta;
      END LOOP;
			
			-- Carregando as informações do cadastro de aplicações RDCA
      FOR rw_craprac IN cr_craprac( pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_craprac(rw_craprac.nrdconta).nrdconta := rw_craprac.nrdconta;
      END LOOP;

      -- Verifica se existe capa de lote para o dia e para o lote 7200
      OPEN cr_craplot( pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdolote => 7200);
      FETCH cr_craplot INTO rw_craplot7200;
      CLOSE cr_craplot;

      -- Verifica se existe capa de lote para o dia e para o lote 8006
      OPEN cr_craplot( pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdolote => 8006);
      FETCH cr_craplot INTO rw_craplot8006;
      CLOSE cr_craplot;

      -- O parâmetro abaixo é reponsável por retornar:
      -- valor de cotas do associado
      -- valor da C.M a incorporar sobre as cotas
      -- valor da correção monetária do mês sobre as cotas
      -- qtde de cotas em moeda fixa
      TABE0001.pc_busca_craptab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'VALORBAIXA'
                               ,pr_tpregist => 0
							   ,pr_flgfound => vr_flgfound
							   ,pr_dstextab => vr_dstextab);

      -- se não encontrar o parãmetro gera crítica
      IF NOT vr_flgfound THEN
        vr_cdcritic := 409;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- se não iniciou pelo restart zera o parâmetro e processa todo o lote
      IF vr_flgzerar THEN
        -- limpa a variável do parâmetro para desconsiderar os valores antigos
        vr_dstextab := NULL;
      END IF;

      -- desfragmentando os valores do parâmetro
      vr_vldcotas := nvl(SUBSTR(vr_dstextab,001,016),0); -- valor de cotas do associado
      vr_vlcmicot := nvl(SUBSTR(vr_dstextab,018,016),0); -- valor da C.M a incorporar sobre as cotas
      vr_vlcmmcot := nvl(SUBSTR(vr_dstextab,035,016),0); -- valor da correção monetária do mês sobre as cotas
      vr_qtcotmfx := nvl(SUBSTR(vr_dstextab,052,016),0); -- qtde de cotas em moeda fixa
      vr_vldcotpf := nvl(SUBSTR(vr_dstextab,069,016),0); -- valor de cotas do associado PF
      vr_vldcotpj := nvl(SUBSTR(vr_dstextab,086,016),0); -- valor de cotas do associado PJ

      ------------------------------------------------------------------------------
      -- INICIA O PROCESSO DE BAIXA
      ------------------------------------------------------------------------------
      -- Processar todos os associados da Cooperativa levando em conta a data limite
      -- e o controle de restart...
      FOR rw_crapass IN cr_crapass( pr_cdcooper => pr_cdcooper
                                   ,pr_dtlimite => vr_dtlimite
                                   ,pr_nrctares => nvl(vr_nrctares,0)
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt)
      LOOP

        BEGIN
          -- Se existir algum lançamento para o associado vai para a próxima iteração
          IF vr_tab_crapepr.EXISTS(rw_crapass.nrdconta) OR -- empréstimos
             vr_tab_craprda.EXISTS(rw_crapass.nrdconta) OR -- aplicações RDCA
             vr_tab_crapatr.EXISTS(rw_crapass.nrdconta) OR -- autorizações de débitos em conta
             vr_tab_craprpp.EXISTS(rw_crapass.nrdconta) OR -- poupanças programadas
             vr_tab_craplau.EXISTS(rw_crapass.nrdconta) OR -- lancamentos automaticos
             vr_tab_crapseg.EXISTS(rw_crapass.nrdconta) OR -- seguros
             vr_tab_craplat.EXISTS(rw_crapass.nrdconta) OR -- poupanças programadas
						 vr_tab_craprac.EXISTS(rw_crapass.nrdconta) THEN -- aplicações captação

            -- vai para a próxima iteração
            CONTINUE;
          END IF;

          -- seleciona os avalistas do associado
          OPEN cr_crapavl( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          FETCH cr_crapavl INTO rw_crapavl;

          -- verifica se existe lançamentos no cadastro de avalistas para o associado
          IF cr_crapavl%FOUND THEN
            -- Fecha o cursor
            CLOSE cr_crapavl;

            -- Verifica se o contrato é de emprestimo (1-Emprestimo)
            IF rw_crapavl.tpctrato = 1 THEN
              -- Verifica se o avalista possui emprestimo
              IF vr_tab_crapepr.EXISTS(rw_crapavl.nrctaavd) THEN
                -- Vai para a próxima iteração
                CONTINUE;
              END IF;
            -- verifica as demais situações
            ELSIF rw_crapavl.tpctrato = 2 OR   -- desconto de cheques
                  rw_crapavl.tpctrato = 3 OR   -- cheque especial
                  rw_crapavl.tpctrato = 4 OR   -- cartao
                  rw_crapavl.tpctrato = 8 THEN -- desconto de titulos

              -- Verifica se o avalista possui contrato de limite de crédito que não esteja cancelado
              IF vr_tab_craplim03.EXISTS(rw_crapavl.nrdconta) THEN
                -- Vai para a próxima iteração
                CONTINUE;
              END IF;
            END IF; --IF rw_crapavl.tpctrato = 1 THEN
          ELSE
            -- Fecha o cursor
            CLOSE cr_crapavl;
          END IF; --IF cr_crapavl%FOUND THEN

          -- Verifica se existe cartão magnético solicitado e ativo para a conta do associado
          IF vr_tab_crapcrm.EXISTS(rw_crapass.nrdconta) THEN
            -- Vai para a próxima iteração
            CONTINUE;
          END IF;

          -- Verifica se existe cartão de crédito não cancelado para a conta do associado
          IF vr_tab_crawcrd.EXISTS(rw_crapass.nrdconta) THEN
            -- Vai para a próxima iteração
            CONTINUE;
          END IF;

          -- Verifica os emprestimos do avalista
          OPEN cr_crapsld( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          FETCH cr_crapsld INTO rw_crapsld;

          -- Verifica se existe cadastro de saldos para a conta do associado
          IF cr_crapsld%NOTFOUND THEN
            -- fechando o cursor
            CLOSE cr_crapsld;
            -- se não existir lançamento de saldos, gerar crítica e aborta a execução
            vr_cdcritic := 10;
            vr_dscritic :=  gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - CONTA: '||rw_crapass.nrdconta;
            RAISE vr_exc_undo;
          ELSE
            -- fechando o cursor
            CLOSE cr_crapsld;
          END IF;

          -- se existir saldo em algum dos campos abaixo, vai para a próxima iteração
          IF nvl(rw_crapsld.qtddsdev,0) >  0  OR -- quantidade de dias em que o saldo está negativo
             nvl(rw_crapsld.vlsdbloq,0) >  0  OR -- valor do saldo bloqueado
             nvl(rw_crapsld.vlipmfap,0) <> 0  OR -- valor do IPMF apurado
             nvl(rw_crapsld.vlipmfpg,0) >  0  OR -- valor do IPMF a pagar
             nvl(rw_crapsld.vlsdblpr,0) >  0  OR -- valor do saldo bloqueado em depositos da praça
             nvl(rw_crapsld.vlsdblfp,0) >  0  OR -- valor do saldo bloqueado em depositos fora da praça
             nvl(rw_crapsld.vlsddisp,0) <  0  THEN -- valor do saldo disponivel
            -- vai para a próxima iteração
            CONTINUE;
          END IF;

          -- verifica se valor do saldo em cheque salário é maior que zero
          IF nvl(rw_crapsld.vlsdchsl,0) > 0 THEN

            -- seleciona o valor total de cheques salário (tpcheque = 3) compensados
            OPEN cr_crapfdc01( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_crapfdc01 INTO rw_crapfdc01;
            CLOSE cr_crapfdc01;

            -- se o valor do saldo dos cheques salário for diferente do valor dos cheques salários compensados
            -- vai para a próxima iteração e não efetua a baixa
            IF nvl(rw_crapsld.vlsdchsl,0) <> nvl(rw_crapfdc01.vlcheque,0) THEN
              CONTINUE;
            END IF;
          END IF;--IF nvl(rw_crapsld.vlsdchsl,0) > 0 THEN

          -- seleciona informacoes de cotas e recursos
          OPEN cr_crapcot( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;

          -- Verifica se existe cadastro de saldos para a conta do associado
          IF cr_crapcot%NOTFOUND THEN
            -- fecha o cursor
            CLOSE cr_crapcot;
            -- se não existir lançamento de saldos, gerar crítica e aborta a execução
            vr_cdcritic := 169;
            vr_dscritic :=  gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - CONTA: '||rw_crapass.nrdconta;
            RAISE vr_exc_undo;
          ELSE
            -- fecha o cursor
            CLOSE cr_crapcot;
          END IF;

          -- se possui saldo em um dos campos abaixo, vai para a proxima iteração e não efetua a baixa da conta
          IF nvl(rw_crapcot.qtjurmfx,0) > 0 OR -- juros pagos sobre c/c e emprestimos em moeda fixa
             nvl(rw_crapcot.qtraimfx,0) > 0 OR -- quantidade de retorno a incorporar
             nvl(rw_crapcot.qtrsjmfx,0) > 0 THEN -- quantidade de residuos da incorporação
            -- vai para a proxima iteração
            CONTINUE;
          END IF;

          --------------------------------------------------------------
          --  Inicio da baixa dos valores do conta-corrente
          --------------------------------------------------------------
          -- se não existir a capa do lote 7200 no dia, o mesmo será criado
          IF rw_craplot7200.rowid IS NULL THEN
            -- cadastra a capa do lote 7200 na craplot e retornando as informações para usar abaixo
            BEGIN
              INSERT INTO craplot(dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,cdcooper)
              VALUES ( rw_crapdat.dtmvtolt
                       ,1
                       ,100
                       ,7200
                       ,1
                       ,pr_cdcooper)
              RETURNING cdcooper
                       ,dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrseqdig
                       ,qtinfoln
                       ,qtcompln
                       ,ROWID
              INTO  rw_craplot7200.cdcooper
                   ,rw_craplot7200.dtmvtolt
                   ,rw_craplot7200.cdagenci
                   ,rw_craplot7200.cdbccxlt
                   ,rw_craplot7200.nrdolote
                   ,rw_craplot7200.nrseqdig
                   ,rw_craplot7200.qtinfoln
                   ,rw_craplot7200.qtcompln
                   ,rw_craplot7200.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir lote 7200 na tabela craplot para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;
          END IF;

          -- se o valor do saldo disponivel é maior que zero
          IF nvl(rw_crapsld.vlsddisp,0) > 0 THEN
            -- inserindo na tabela de depósistos a vista craplcm
            BEGIN
              INSERT INTO craplcm( dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,nrdctabb
                                  ,nrdctitg
                                  ,nrdconta
                                  ,vllanmto
                                  ,cdhistor
                                  ,cdpesqbb
                                  ,nrseqdig
                                  ,nrdocmto
                                  ,cdcooper)
              VALUES( rw_craplot7200.dtmvtolt
                     ,rw_craplot7200.cdagenci
                     ,rw_craplot7200.cdbccxlt
                     ,rw_craplot7200.nrdolote
                     ,rw_crapass.nrdconta
                     ,gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                     ,rw_crapass.nrdconta
                     ,rw_crapsld.vlsddisp
                     ,decode(rw_crapass.inpessoa,1,2061,2062)
                     ,' '
                     ,nvl(rw_craplot7200.nrseqdig,0) + 1
                     ,nvl(rw_craplot7200.nrseqdig,0) + 1
                     ,pr_cdcooper)
              RETURNING vllanmto
              INTO      vr_vllanmto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplcm para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            -- atualizando a tabela de lotes e retornando oa valores para utilizar na próxima iteração
            BEGIN
              UPDATE craplot
              SET vlinfodb = nvl(vlinfodb,0) + nvl(vr_vllanmto,0)
                 ,vlcompdb = nvl(vlcompdb,0) + nvl(vr_vllanmto,0)
                 ,qtinfoln = nvl(qtinfoln,0) + 1
                 ,qtcompln = nvl(qtcompln,0) + 1
                 ,nrseqdig = nvl(nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot7200.rowid
              RETURNING vlinfodb
                       ,vlcompdb
                       ,qtinfoln
                       ,nrseqdig
              INTO rw_craplot7200.vlinfodb
                  ,rw_craplot7200.vlcompdb
                  ,rw_craplot7200.qtinfoln
                  ,rw_craplot7200.nrseqdig;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela craplot para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            BEGIN
              UPDATE tbcotas_devolucao
                 SET vlcapital = vlcapital + rw_crapsld.vlsddisp
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_crapass.nrdconta
                 AND tpdevolucao = 4; -- DEPOSITO - EQUIVALE HIST 110
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO tbcotas_devolucao (cdcooper,
                                             nrdconta, 
                                             tpdevolucao,
                                             vlcapital)
                                     VALUES (pr_cdcooper
                     ,rw_crapass.nrdconta
                                            ,4 -- DEPOSITO - EQUIVALE HIST 110
                                            ,rw_crapsld.vlsddisp); 
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela tbcotas_devolucao para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;


            -- Verifica se o mês é superior a 6
            vr_idsmstre := to_char(rw_crapdat.dtmvtolt,'MM');
            IF vr_idsmstre > 6 THEN
              -- trás o mês para abaixo de 6
              vr_idsmstre := vr_idsmstre - 6;
            END IF;

            -- atualizando os saldos na tabela crapsld
            BEGIN
              UPDATE crapsld
              SET vlsddisp = nvl(vlsddisp,0) - nvl(vr_vllanmto,0)
                 ,vlsdmesa = nvl(vlsdmesa,0) - nvl(vr_vllanmto,0)
                 ,vlsdanes = nvl(vlsdmesa,0) - nvl(vr_vllanmto,0)
                 ,vlsmstre##1 = decode(vr_idsmstre, 1, nvl(vlsmstre##1,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##1)
                 ,vlsmstre##2 = decode(vr_idsmstre, 2, nvl(vlsmstre##2,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##2)
                 ,vlsmstre##3 = decode(vr_idsmstre, 3, nvl(vlsmstre##3,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##3)
                 ,vlsmstre##4 = decode(vr_idsmstre, 4, nvl(vlsmstre##4,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##4)
                 ,vlsmstre##5 = decode(vr_idsmstre, 5, nvl(vlsmstre##5,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##5)
                 ,vlsmstre##6 = decode(vr_idsmstre, 6, nvl(vlsmstre##6,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##6)
                 ,smposano##1 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'01', nvl(smposano##1,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##1)
                 ,smposano##2 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'02', nvl(smposano##2,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##2)
                 ,smposano##3 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'03', nvl(smposano##3,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##3)
                 ,smposano##4 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'04', nvl(smposano##4,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##4)
                 ,smposano##5 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'05', nvl(smposano##5,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##5)
                 ,smposano##6 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'06', nvl(smposano##6,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##6)
                 ,smposano##7 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'07', nvl(smposano##7,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##7)
                 ,smposano##8 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'08', nvl(smposano##8,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##8)
                 ,smposano##9 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'09', nvl(smposano##9,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##9)
                 ,smposano##10 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'10', nvl(smposano##10,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##10)
                 ,smposano##11 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'11', nvl(smposano##11,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##11)
                 ,smposano##12 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'12', nvl(smposano##12,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##12)
              WHERE crapsld.ROWID = rw_crapsld.rowid
              RETURNING crapsld.vlsddisp
              INTO      rw_crapsld.vlsddisp;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela crapsld para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;
          END IF;--IF nvl(rw_crapsld.vlsddisp,0) > 0 THEN

          -- verifica se valor do saldo em cheque salário é maior que zero
          IF nvl(rw_crapsld.vlsdchsl,0) > 0 THEN
            -- inserindo na tabela de depósistos a vista craplcm
            BEGIN
              INSERT INTO craplcm( dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,nrdctabb
                                  ,nrdctitg
                                  ,nrdconta
                                  ,vllanmto
                                  ,cdhistor
                                  ,cdpesqbb
                                  ,nrseqdig
                                  ,nrdocmto
                                  ,cdcooper)
              VALUES( rw_craplot7200.dtmvtolt
                     ,rw_craplot7200.cdagenci
                     ,rw_craplot7200.cdbccxlt
                     ,rw_craplot7200.nrdolote
                     ,rw_crapass.nrdconta
                     ,gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                     ,rw_crapass.nrdconta
                     ,rw_crapsld.vlsdchsl
                     ,111
                     ,' '
                     ,nvl(rw_craplot7200.nrseqdig,0) + 1
                     ,nvl(rw_craplot7200.nrseqdig,0) + 1
                     ,pr_cdcooper)
              RETURNING vllanmto
              INTO      vr_vllanmto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplcm para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            -- atualizando a tabela de lotes e retornando oa valores para utilizar na próxima iteração
            BEGIN
              UPDATE craplot
              SET vlinfodb = nvl(vlinfodb,0) + nvl(vr_vllanmto,0)
                 ,vlcompdb = nvl(vlcompdb,0) + nvl(vr_vllanmto,0)
                 ,qtinfoln = nvl(qtinfoln,0) + 1
                 ,qtcompln = nvl(qtcompln,0) + 1
                 ,nrseqdig = nvl(nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot7200.rowid
              RETURNING vlinfodb
                       ,vlcompdb
                       ,qtinfoln
                       ,nrseqdig
              INTO rw_craplot7200.vlinfodb
                  ,rw_craplot7200.vlcompdb
                  ,rw_craplot7200.qtinfoln
                  ,rw_craplot7200.nrseqdig;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela craplot para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            -- Verifica se o mês é superior a 6
            vr_idsmstre := to_char(rw_crapdat.dtmvtolt,'MM');
            IF vr_idsmstre > 6 THEN
              -- trás o mês para abaixo de 6
              vr_idsmstre := vr_idsmstre - 6;
            END IF;

            -- atualizando os saldos na tabela crapsld
            BEGIN
              UPDATE crapsld
              SET vlsdchsl = nvl(vlsdchsl,0) - nvl(vr_vllanmto,0)
                 ,vlsdmesa = nvl(vlsdmesa,0) - nvl(vr_vllanmto,0)
                 ,vlsdanes = nvl(vlsdmesa,0) - nvl(vr_vllanmto,0)
                 ,vlsmstre##1 = decode(vr_idsmstre, 1, nvl(vlsmstre##1,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##1)
                 ,vlsmstre##2 = decode(vr_idsmstre, 2, nvl(vlsmstre##2,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##2)
                 ,vlsmstre##3 = decode(vr_idsmstre, 3, nvl(vlsmstre##3,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##3)
                 ,vlsmstre##4 = decode(vr_idsmstre, 4, nvl(vlsmstre##4,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##4)
                 ,vlsmstre##5 = decode(vr_idsmstre, 5, nvl(vlsmstre##5,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##5)
                 ,vlsmstre##6 = decode(vr_idsmstre, 6, nvl(vlsmstre##6,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute), vlsmstre##6)
                 ,smposano##1 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'01', nvl(smposano##1,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##1)
                 ,smposano##2 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'02', nvl(smposano##2,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##2)
                 ,smposano##3 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'03', nvl(smposano##3,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##3)
                 ,smposano##4 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'04', nvl(smposano##4,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##4)
                 ,smposano##5 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'05', nvl(smposano##5,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##5)
                 ,smposano##6 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'06', nvl(smposano##6,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##6)
                 ,smposano##7 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'07', nvl(smposano##7,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##7)
                 ,smposano##8 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'08', nvl(smposano##8,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##8)
                 ,smposano##9 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'09', nvl(smposano##9,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##9)
                 ,smposano##10 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'10', nvl(smposano##10,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##10)
                 ,smposano##11 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'11', nvl(smposano##11,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##11)
                 ,smposano##12 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'12', nvl(smposano##12,0) - (nvl(vr_vllanmto,0) / rw_crapdat.qtdiaute),smposano##12)
              WHERE crapsld.ROWID = rw_crapsld.rowid
              RETURNING crapsld.vlsdchsl
              INTO      rw_crapsld.vlsdchsl;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela crapsld para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            -- Altera em todos os cheques salário (tpcheque = 3) compensados da conta do associado,
            -- e atualiza o indicador do estado dos cheques de 1 para 8 (Não tem descrição de cada estado na tabela)
            -- e a data de liquidação do cheque para a data atual
            BEGIN
              UPDATE crapfdc
              SET incheque = 8
                 ,dtretchq = decode(dtretchq, NULL, to_date('01/01/0001', 'DD/MM/RRRR'), dtretchq)
                 ,dtliqchq = rw_crapdat.dtmvtolt
              WHERE cdcooper = pr_cdcooper
              AND   nrdconta = rw_crapass.nrdconta
              AND   tpcheque = 3
              AND   incheque = 0;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela crapfdc para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;
          END IF; --IF nvl(rw_crapsld.vlsdchsl,0) > 0 THEN

          -- Atualizando os valores dos saldos diários do associado
          BEGIN
            UPDATE crapsda
            SET vlsddisp = nvl(rw_crapsld.vlsddisp,0)-- valor do saldo disponivel
               ,vlsdchsl = nvl(rw_crapsld.vlsdchsl,0)-- valor do saldo em cheque salário
            WHERE cdcooper = pr_cdcooper
            AND   nrdconta = rw_crapass.nrdconta
            AND   dtmvtolt = rw_crapdat.dtmvtolt;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela crapsda para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_undo;
          END;

          --------------------------------------------------------------
          --  Inicio da baixa dos valores do capital
          --------------------------------------------------------------
          -- se não existir a capa do lote 7200 no dia, o mesmo será criado
          IF rw_craplot8006.rowid IS NULL THEN
            -- cadastra a capa do lote 7200 na craplot e retornando as informações para usar abaixo
            BEGIN
              INSERT INTO craplot(dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,cdcooper)
              VALUES ( rw_crapdat.dtmvtolt
                       ,1
                       ,100
                       ,8006
                       ,2
                       ,pr_cdcooper)
              RETURNING cdcooper
                       ,dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrseqdig
                       ,qtinfoln
                       ,qtcompln
                       ,ROWID
              INTO  rw_craplot8006.cdcooper
                   ,rw_craplot8006.dtmvtolt
                   ,rw_craplot8006.cdagenci
                   ,rw_craplot8006.cdbccxlt
                   ,rw_craplot8006.nrdolote
                   ,rw_craplot8006.nrseqdig
                   ,rw_craplot8006.qtinfoln
                   ,rw_craplot8006.qtcompln
                   ,rw_craplot8006.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir lote 8006 na tabela craplot para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;
          END IF;


          -- se o associado possuir cotas, efetua a baixa de capital
          IF nvl(rw_crapcot.vldcotas,0) > 0 THEN -- valor de cotas do associado
            -- Insere lançamento na tabela de lançamentos de cotas de capital
            BEGIN
              INSERT INTO craplct( dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,nrdconta
                                  ,vllanmto
                                  ,cdhistor
                                  ,nrseqdig
                                  ,nrdocmto
                                  ,qtlanmfx
                                  ,cdcooper)
              VALUES( rw_craplot8006.dtmvtolt
                     ,rw_craplot8006.cdagenci
                     ,rw_craplot8006.cdbccxlt
                     ,rw_craplot8006.nrdolote
                     ,rw_crapass.nrdconta
                     ,nvl(rw_crapcot.vldcotas,0)
                     ,decode(rw_crapass.inpessoa,1,2079,2080)
                     ,rw_craplot8006.nrseqdig + 1
                     ,rw_craplot8006.nrseqdig + 1
                     ,nvl(rw_crapcot.qtcotmfx,0)
                     ,pr_cdcooper)
              RETURNING vllanmto
              INTO      vr_vllanmto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplct para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

			-- atualizando a tabela de lotes e retornando oa valores para utilizar na próxima iteração
            BEGIN
              UPDATE craplot
              SET vlinfodb = nvl(vlinfodb,0) + nvl(vr_vllanmto,0)
                 ,vlcompdb = nvl(vlcompdb,0) + nvl(vr_vllanmto,0)
                 ,qtinfoln = nvl(qtinfoln,0) + 1
                 ,qtcompln = nvl(qtcompln,0) + 1
                 ,nrseqdig = nvl(nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot8006.rowid
              RETURNING vlinfodb
                       ,vlcompdb
                       ,qtinfoln
                       ,nrseqdig
              INTO rw_craplot8006.vlinfodb
                  ,rw_craplot8006.vlcompdb
                  ,rw_craplot8006.qtinfoln
                  ,rw_craplot8006.nrseqdig;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a tabela craplot para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;

            BEGIN
              UPDATE tbcotas_devolucao
                 SET vlcapital = vlcapital + nvl(rw_crapcot.vldcotas,0)
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = rw_crapass.nrdconta
                 AND tpdevolucao = 3;  -- SOBRAS COTAS - EQUIVALE HIST 112
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO tbcotas_devolucao (cdcooper,
                                             nrdconta, 
                                             tpdevolucao,
                                             vlcapital)
                                     VALUES (pr_cdcooper
                     ,rw_crapass.nrdconta
                                            ,3 -- SOBRAS COTAS - EQUIVALE HIST 112
                                            ,nvl(rw_crapcot.vldcotas,0)); 
               END IF;              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela tbcotas_devolucao para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
            END;


          END IF; --IF nvl(rw_crapcot.vldcotas,0) > 0 THEN


          -- acumulando os valores para atualizar o parâmetro
          vr_vldcotas := nvl(vr_vldcotas,0) + nvl(rw_crapcot.vldcotas,0);
          vr_vlcmicot := nvl(vr_vlcmicot,0) + nvl(rw_crapcot.vlcmicot,0);
          vr_vlcmmcot := nvl(vr_vlcmmcot,0) + nvl(rw_crapcot.vlcmmcot,0);
          vr_qtcotmfx := nvl(vr_qtcotmfx,0) + nvl(rw_crapcot.qtcotmfx,0);

          -- Se for Pessoa Fisica
          IF rw_crapass.inpessoa = 1 THEN
             -- Acumulando o valor de cotas referente a pessoa fisica
             vr_vldcotpf := nvl(vr_vldcotpf,0) + nvl(rw_crapcot.vldcotas,0);
          ELSE -- Pessoa Juridica
             -- Acumulando o valor de cotas referente a pessoa juridica
             vr_vldcotpj := nvl(vr_vldcotpj,0) + nvl(rw_crapcot.vldcotas,0);
          END IF;

          -- limpa o parâmetro
          BEGIN
            UPDATE crapcot
            SET    vldcotas = 0
                  ,qtcotmfx = 0
                  ,vlcapmes##1 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'01', 0, vlcapmes##1)
                  ,vlcapmes##2 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'02', 0, vlcapmes##2)
                  ,vlcapmes##3 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'03', 0, vlcapmes##3)
                  ,vlcapmes##4 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'04', 0, vlcapmes##4)
                  ,vlcapmes##5 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'05', 0, vlcapmes##5)
                  ,vlcapmes##6 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'06', 0, vlcapmes##6)
                  ,vlcapmes##7 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'07', 0, vlcapmes##7)
                  ,vlcapmes##8 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'08', 0, vlcapmes##8)
                  ,vlcapmes##9 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'09', 0, vlcapmes##9)
                  ,vlcapmes##10 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'10', 0, vlcapmes##10)
                  ,vlcapmes##11 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'11', 0, vlcapmes##11)
                  ,vlcapmes##12 = decode(to_char(rw_crapdat.dtmvtolt,'MM'),'12', 0, vlcapmes##12)
            WHERE crapcot.ROWID = rw_crapcot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar o parâmetro "VALORBAIXA" na tabela craptab para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_undo;
          END;
          -- montando o valor que será atualizado no parâmetro com formatação para colocar sinal de negativo a direita
          vr_dstextab := to_char(vr_vldcotas,'099999999999D99MI') || ' ' ||
                         to_char(vr_vlcmicot,'099999999999D99MI') || ' ' ||
                         to_char(vr_vlcmmcot,'099999999999D99MI') || ' ' ||
                         to_char(vr_qtcotmfx,'0999999999D9999MI') || ' ' ||
                         to_char(vr_vldcotpf,'099999999999D99MI') || ' ' ||
                         to_char(vr_vldcotpj,'099999999999D99MI');

          -- Atualizando a data de eliminacao dos valores (Saldo e capital) na conta do associado
          BEGIN
            UPDATE crapass
            SET   dtelimin = decode(dtelimin, NULL, rw_crapdat.dtmvtolt, dtelimin)
            WHERE crapass.rowid = rw_crapass.rowid
            RETURNING dtelimin
                     ,inmatric
            INTO      rw_crapass.dtelimin
                     ,rw_crapass.inmatric;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela crapass para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_undo;
          END;

          -- Se a data de eliminação foi atualizada para a data de hoje..
          IF rw_crapass.dtelimin = rw_crapdat.dtmvtolt THEN
            -- se a matricula for original (1)
            IF rw_crapass.inmatric = 1 THEN
              -- Incrementa a contagem de associados baixados/demitidos
              vr_qtassbai := nvl(vr_qtassbai,0) + 1;
              -- Separando as informacoes de associado baixados/demitidos 
              IF rw_crapass.inpessoa = 1 THEN
                 -- Gravando a quantidade de associado PF baixados/demitidos
                 vr_qtasbxpf := NVL(vr_qtasbxpf,0) + 1;
              ELSE
                 -- Gravando a quantidade de associado PJ baixados/demitidos
                 vr_qtasbxpj := NVL(vr_qtasbxpj,0) + 1;
              END IF;
            END IF;
          END IF;

          -- acumula a quantidade de registros processados para efetuar o commit a cada 1000 registros
          vr_qtproces := nvl(vr_qtproces,0) + 1;

          -- efetua commit a cada 1000 registros processados
          IF MOD(vr_qtproces, 5000) = 0 THEN
            -- Somente se a flag de restart estiver ativa
            IF pr_flgresta = 1 THEN
              -- Atualizando o valor do parãmetro com os totais atualizados.
              BEGIN
                UPDATE craptab
                SET   dstextab = vr_dstextab
                WHERE cdcooper = pr_cdcooper
                AND   nmsistem = 'CRED'
                AND   tptabela = 'GENERI'
                AND   cdempres = 0
                AND   cdacesso = 'VALORBAIXA'
                AND   tpregist = 0;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar o parâmetro "VALORBAIXA" na tabela craptab para a conta ( '||rw_crapass.nrdconta||' ). '||SQLERRM;
                  --Sair do programa
                  RAISE vr_exc_undo;
              END;

              --Atualizar tabela de restart
              BEGIN

                UPDATE crapres
                SET    crapres.nrdconta = rw_crapass.nrdconta
                      ,crapres.dsrestar = LPAD(NVL(vr_qtassbai,0),8,'0')||' '|| -- Grava o total de contagem de associados baixados/demitidos
                                          LPAD(NVL(vr_qtasbxpf,0),8,'0')||' '|| -- Grava contagem de associados PF baixados/demitidos
                                          LPAD(NVL(vr_qtasbxpj,0),8,'0')        -- Grava contagem de associados PJ baixados/demitidos
                WHERE crapres.cdcooper = pr_cdcooper
                AND   crapres.cdprogra = vr_cdprogra;

                --Se nao atualizou nada
                IF SQL%ROWCOUNT = 0 THEN
                  --Buscar mensagem de erro da critica
                  vr_cdcritic := 151;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' CONTA = '||gene0002.fn_mask_conta(rw_crapass.nrdconta);
                  --Sair do programa
                  RAISE vr_exc_undo;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                vr_des_erro:= 'Erro ao atualizar tabela crapres. '||SQLERRM;
                --Sair do programa
                RAISE vr_exc_undo;
              END;
            END IF;

            -- Commita os registros
            COMMIT;
          END IF;

        EXCEPTION
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
           -- ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_saida;
        END;

      END LOOP; --> Fim loop cr_crapass

      BEGIN
        UPDATE craptab
        SET   dstextab = vr_dstextab
        WHERE cdcooper = pr_cdcooper
        AND   nmsistem = 'CRED'
        AND   tptabela = 'GENERI'
        AND   cdempres = 0
        AND   cdacesso = 'VALORBAIXA'
        AND   tpregist = 0;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o parâmetro "VALORBAIXA" na tabela craptab. '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

      --Zerar tabela de memoria auxiliar
      pc_limpa_tabela;

      -- Chama rotina para eliminação do restart para evitarmos
      -- reprocessamento das aplicações indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_saida;
      END IF;
      
      -- Atualização da crapmat
      BEGIN
        UPDATE crapmat 
           SET qtassbai = NVL(vr_qtassbai,0)
              ,qtasbxpf = NVL(vr_qtasbxpf,0)
              ,qtasbxpj = NVL(vr_qtasbxpj,0)
         WHERE cdcooper = pr_cdcooper;
        -- Se não encontrou nada
        IF SQL%ROWCOUNT = 0 THEN
          -- Gerar critica 194
          vr_cdcritic := 194;
          RAISE vr_exc_saida;
        END IF;
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Rechamar a exception
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar os campos "qtassbai", "qtasbxpf" e "qtasbxpj" da tabela CRAPMAT: '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

      -- Término da solicitação
      pr_infimsol := 1;
  
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      
      -- Efetuar Commit de informações pendentes de gravação
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
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
        -- Limpando as tabelas de memória
        pc_limpa_tabela;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
       -- Limpando as tabelas de memória
       pc_limpa_tabela;
    END;
  END pc_crps093;
/
