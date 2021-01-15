CREATE OR REPLACE PROCEDURE CECRED.pc_crps312_faba (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                           ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                           ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                           ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                           ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

   Programa: Fontes/crps312.p (Antigo Fontes/crps312.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Margarete
   Data    : Junho/2001.                     Ultima atualizacao: 24/10/2019

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 41. Ordem = 3.
               Calculo mensal dos juros sobre prejuizos de emprestimos.
               Relatorio 264.

   Alteracoes: 22/08/2001 - Tratar pagamentos dos prejuizos (Margarete).

               09/11/2001 - Alterar forma de 12 meses ou mais (Margarete).

               02/01/2002 - Corrigir prejuizo no mesmo mes (Margarete).

               06/06/2002 - Erro de quebra (Margarete).

               17/06/2002 - Incluir prejuizo a +48 meses (Margarete).

               01/08/2003 - Prejuizo para o Pac onde o associado
                            tem conta (Margarete).

               15/03/2004 - Considerar os abonos concedidos (Margarete).

               03/05/2005 - Alterado numero de copias para impressao na
                            Viacredi;
                            Alimentar o campo cdcooper das tabelas (Diego).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               25/07/2006 - Alterado numero de copias do relatorio 264 para
                            Viacredi (Elton).

               03/08/2006 - Incluida relacao de contas com contrato em prejuizo
                            a mais de 48 meses (Diego).

               08/12/2006 - Alterado para 3 o numero de copias do relatorio 264
                            para Viacredi (Elton).

               13/12/2006 - Valores pagos tira o abono (Magui).

               15/12/2006 - Incluida relacao de contas em prejuizo abertas
                            durante o mes atual (Elton).

               25/01/2007 - Alterado formato dos campos do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               06/11/2008 - Alterado formato dos campos total geral e total
                            pac para evitar estouro (Gabriel) .

               18/02/2010 - Incluir linha de credito no relatorio (David).

               15/04/2010 - Alterado para garar arquivo txt para importacao
                            excel, grava-lo no diretorio salvar e envia-lo
                            por email (Sandro-GATI).

              01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl"
                           (Vitor).

              15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                           leitura e gravacao dos arquivos (Elton).

              28/12/2010 - Inclusao da coluna "Data Primeiro Pagamento"
                           (Adriano).

              18/02/2011 - Alterado o formato da data dos campos
                           crapepr.dtprejuz e crapepr.dtdpagto.
                           De:"99/99/99" Para: "99/99/9999". (Fabricio)

              08/04/2011 - Retirado os pontos dos campos numéricos e decimais
                           que são exportados para o arquivo crrl264.txt.
                           (Isara - RKAM)

              19/10/2011 - Disponibilizar arquivo crrl264.txt para
                           Acredicoop(Mirtes)

              03/10/2012 - Disponibilizar arquivo crrl264.txt para
                           Alto Vale (David Kruger).

              10/06/2013 - Alteração função enviar_email_completo para
                           nova versão (Jean Michel).

              15/08/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

              03/09/2013 - Atualizar o saldo prejuizo na tabela crapcyb. (James)

              28/10/2013 - Ajuste para não atualizar o saldo prejuizo na tabela
                           crapcyb. (James)

              20/01/2014 - Incluir VALIDATE craplot, craplem (Lucas R.)

              31/03/2014 - Conversão Progress >> PLSQL (James).

              17/04/2014 - Adicionado campo de finalidade no relatório 264. (Reinert)

              25/04/2014 - Ajustes gerais para batimento com o Progress (Andrino-RKAM)

              30/04/2014 - Ajustes nos caracteres de quebra de linha (Marcos-Supero)

              26/01/2015 - Alterado o formato do campo nrctremp para 8
                           caracters (Kelvin - 233714)

              05/05/2015 - Alteração para realizar a geração do relatório separado por PF e PJ.
                           Projeto 186  ( Renato - Supero )

              30/06/2015 - Alterações referentes ao Projeto 215 - DV3 (Daniel)

              19/09/2016 - Gravar na coluna "crapepr.vlsprjat" o saldo do prejuízo anterior
                           "crapepr.vlsdprej", Prj.302 (Jean Michel)

              25/06/2017 - M324 - Incluir historico de pagamento - Rafael (Mout´S)

              16/10/2018 - 403 - Incluindo registros de desconto de título em prejuízo (Luis Fernando - GFT)

              12/02/2018 - P403 - Removido a matriz typ_mat_prej e adicionado o prejuizo do borderô em uma union
                           no cursor cr_crapepr_crapass com a origem DSCTIT. (Paulo Penteado GFT)

              09/01/2019 - P298 - O relatório 264 deverá apresentar aos contratos de produto Pós-fixado
                           transferidos para prejuízo.

							24/10/2019 - PRJ298.3 - Incluir no cálculo do Juros Prejuízo o % CDI para os contratos Pós Fixado (Nagasava - Supero)

              27/11/2019 - P441 - Ajustes das taxas de juros para buscar das linhas de crédito.
................................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS312';
      -- Tratamento de erros
      vr_exc_next   EXCEPTION;
      vr_exc_undo   EXCEPTION;
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cursor genérico de parametrização
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
              ,tab.tpregist
              ,tab.ROWID
          FROM craptab tab
         WHERE tab.cdcooper        = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist        = NVL(pr_tpregist,tab.tpregist);
      rw_craptab cr_craptab%ROWTYPE;

      -- Cursor para buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Cursor para buscar o lote
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                        pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.vlinfodb
              ,craplot.vlcompdb
              ,craplot.qtinfoln
              ,craplot.qtcompln
              ,craplot.nrseqdig
              ,craplot.tplotmov
              ,craplot.rowid
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = 8361;
      rw_craplot cr_craplot%ROWTYPE;

      -- Buscar os lançamento de pagamento e abono
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%type,
                        pr_nrdconta IN craplem.nrdconta%type,
                        pr_nrctremp IN craplem.nrctremp%type,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT craplem.vllanmto,
               craplem.dtmvtolt,
               craplem.cdhistor
          FROM craplem
         WHERE craplem.cdcooper  = pr_cdcooper
           AND craplem.nrdconta  = pr_nrdconta
           AND craplem.nrctremp  = pr_nrctremp
           AND craplem.dtmvtolt <= pr_dtmvtolt
           AND craplem.cdhistor IN (382, /* Pagamentos */
                                    383, /* Abonos */
                                    --384,
                                    2388, /* 2388 - PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                                    2473, /* 2473 - PAGAMENTO JUROS +60 PREJUIZO */
                                    --2389, /* 2389 - PAGAMENTO JUROS PREJUIZO */
                                    --2390, /* 2390 - PAGAMENTO MULTA ATRASO PREJUIZO */
                                    --2475, /* 2475 - PAGAMENTO JUROS MORA PREJUIZO */
                                    --2391, /* 2391 - ABONO DE PREJUIZO */
                                    2392, /* 2392 - ESTORNO PAGAMENTO DE PREJUIZO VALOR PRINCIPAL */
                                    2474 /* 2474 - ESTORNO PAGAMENTO JUROS +60 PREJUIZO */
                                    --2393, /* 2393 - ESTORNO PAGAMENTO DE JUROS PREJUIZO */
                                    --2394, /* 2394 - ESTORNO PAGAMENTO MULTA ATRASO PREJUIZO */
                                    --2476, /* 2476 - ESTORNO PAGAMENTO JUROS MORA PREJUIZO */
                                    --2395 /* 2395 - ESTORNO ABONO DE PREJUIZO */
                                    );
      rw_craplem cr_craplem%ROWTYPE;

      CURSOR cr_crapvri (prc_cdcooper IN crapvri.cdcooper%TYPE,
                         prc_nrdconta IN crapvri.nrdconta%TYPE,
                         prc_nrctremp IN crapvri.nrctremp%TYPE,
                         prc_dtrefere IN crapdat.dtultdia%TYPE,
                         prc_cdmodali IN crapvri.cdmodali%TYPE DEFAULT NULL) IS
        SELECT SUM(DECODE(vri.cdvencto, 310, vldivida,0) ) vlsaldo12
              ,SUM(DECODE(vri.cdvencto, 320, vldivida,  0)) vlsaldo13
              ,SUM(DECODE(vri.cdvencto, 330, vldivida, 0) ) vlsaldo49
          FROM crapvri vri
         WHERE vri.cdcooper = prc_cdcooper
           AND vri.nrdconta = prc_nrdconta
           AND vri.nrctremp = prc_nrctremp
           AND vri.dtrefere = prc_dtrefere
           AND (prc_cdmodali IS NOT NULL AND vri.cdmodali = prc_cdmodali OR prc_cdmodali IS NULL AND vri.cdmodali <> 0301);

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE,
                        pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT crapage.nmresage
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;

      -- Cursor para buscar os emprestimos que estao em prejuizo
      CURSOR cr_crapepr_crapass (pr_cdcooper IN crapepr.cdcooper%TYPE,
                                 pr_nrdconta in crapepr.nrdconta%TYPE) IS
         SELECT x.VR_IDORIGEM
               ,x.nrdconta
               ,x.nrctremp
               ,x.vlsdprej
               ,x.vljraprj
               ,x.vljrmprj
               ,x.vlprejuz
               ,x.cdlcremp
               ,x.cdfinemp
               ,x.dtprejuz
               ,x.dtdpagto
               ,x.vljurmes
               ,x.txmensal
               ,x.tpemprst
               ,x.linha
               ,x.vlttmupr
               ,x.vlttjmpr
               ,x.cdagenci
               ,x.nmprimtl
               ,x.dspessoa
							 ,x.dtrefjur -- PRJ298.3
							 ,x.dtlibera -- PRJ298.3
							 ,x.dtrefcor -- PRJ298.3
							 ,x.cddindex -- PRJ298.3
							 ,x.vlperidx -- PRJ298.3
							 ,x.diarefju -- PRJ298.3
							 ,x.mesrefju -- PRJ298.3
							 ,x.anorefju -- PRJ298.3
								,x.inprejuz -- PRJ298.3
               ,Row_Number() OVER (PARTITION BY x.cdagenci ORDER BY x.cdagenci) nrseqage
               ,COUNT(1) OVER (PARTITION BY x.cdagenci) qtdagenc
           FROM(
         SELECT 'CRAPEPR' VR_IDORIGEM
               ,crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.vlsdprej
               ,crapepr.vljraprj
               ,crapepr.vljrmprj
               ,crapepr.vlprejuz
               ,crapepr.cdlcremp
               ,crapepr.cdfinemp
               ,crapepr.dtprejuz
               ,crapepr.dtdpagto
               ,crapepr.vljurmes
               ,crapepr.txmensal
               ,DECODE(crapepr.tpemprst,0,'TR',1,'PP',2,'POS','-') tpemprst
               ,crapepr.rowid linha
               ,crapepr.vlttmupr
               ,crapepr.vlttjmpr
               ,crapass.cdagenci
               ,crapass.nmprimtl
               ,DECODE(crapass.inpessoa,1,'PF',2,'PJ','NA') dspessoa
							 ,crapepr.dtrefjur -- PRJ298.3
							 ,crawepr.dtlibera -- PRJ298.3
							 ,crapepr.dtrefcor -- PRJ298.3
							 ,crawepr.cddindex -- PRJ298.3
							 ,crawepr.vlperidx -- PRJ298.3
							 ,crapepr.diarefju -- PRJ298.3
							 ,crapepr.mesrefju -- PRJ298.3
							 ,crapepr.anorefju -- PRJ298.3
								,crapepr.inprejuz -- PRJ298.3
           FROM crapepr,
                crapass
							 ,crawepr -- PRJ298.3
          WHERE crapepr.cdcooper  = crapass.cdcooper
            AND crapepr.nrdconta  = crapass.nrdconta
						AND crapepr.cdcooper  = crawepr.cdcooper -- PRJ298.3
						AND crapepr.nrdconta  = crawepr.nrdconta -- PRJ298.3
						AND crapepr.nrctremp  = crawepr.nrctremp -- PRJ298.3
            AND crapepr.cdcooper  = pr_cdcooper
            AND crapepr.nrdconta >= pr_nrdconta
            AND crapepr.inprejuz  = 1

          UNION ALL

         SELECT 'DSCTIT' VR_IDORIGEM
               ,crapbdt.nrdconta
               ,crapbdt.nrborder nrctremp
               ,0 vlsdprej
               ,0 vljraprj
               ,0 vljrmprj
               ,0 vlprejuz
               ,NULL cdlcremp
               ,NULL cdfinemp
               ,NULL dtprejuz
               ,NULL dtdpagto
               ,0 vljurmes
               ,crapbdt.txmensal
               ,'DSCTIT' tpemprst
               ,crapbdt.rowid linha
               ,0 vlttmupr
               ,0 vlttjmpr
               ,crapass.cdagenci
               ,crapass.nmprimtl
               ,DECODE(crapass.inpessoa,1,'PF',2,'PJ','NA') dspessoa
							 ,NULL dtrefjur -- PRJ298.3
							 ,NULL dtlibera -- PRJ298.3
							 ,NULL dtrefcor -- PRJ298.3
							 ,NULL cddindex -- PRJ298.3
							 ,NULL vlperidx -- PRJ298.3
							 ,NULL diarefju -- PRJ298.3
							 ,NULL mesrefju -- PRJ298.3
							 ,NULL anorefju -- PRJ298.3
								,NULL inprejuz -- PRJ298.3
           FROM crapbdt,
                crapass
          WHERE crapbdt.cdcooper  = crapass.cdcooper
            AND crapbdt.nrdconta  = crapass.nrdconta
            AND crapbdt.cdcooper  = pr_cdcooper
            AND crapbdt.nrdconta >= pr_nrdconta
            AND crapbdt.inprejuz  = 1
          ) x
       ORDER BY x.cdagenci
               ,x.vr_idorigem
               ,x.nrdconta
               ,x.nrctremp;


			-- Início -- PRJ298.3
			CURSOR cr_craptxi(pr_cddindex craptxi.cddindex%TYPE
			                 ,pr_dtiniper craptxi.dtiniper%TYPE
			                 ) IS
				SELECT txi.vlrdtaxa
					FROM craptxi txi
				 WHERE txi.cddindex = pr_cddindex
					 AND txi.dtiniper = pr_dtiniper;
			--
			vr_vlrdtaxa craptxi.vlrdtaxa%TYPE;
			vr_dtiniper craptxi.dtiniper%TYPE;
			vr_vljurcor crapepr.vljuratu%TYPE;
			vr_vljuremu crapepr.vljuratu%TYPE;
			vr_qtdedias NUMBER;
			vr_taxa_periodo crapepr.vljuratu%TYPE;
			vr_txdiaria craptxi.vlrdtaxa%TYPE;
			-- Fim -- PRJ298.3

      ------------------------------- VARIAVEIS -------------------------------
      vr_txdjuros     NUMBER(35,7);             -- Taxas de Juros de Prejuizo.
      vr_txmensal     craplcr.txmensal%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;    -- Valor do juros do mes
      vr_vlrabono     crapepr.vlsdprej%TYPE;    -- Valor do Abono
      vr_vlrpagos     crapepr.vlsdprej%TYPE;    -- Valor de Pagamento
      vr_vlrestor     crapepr.vlsdprej%TYPE;    -- Valor de Estorno
      vr_dtrefere     DATE;                     -- Data do ultimo dia do mes
      vr_flgpgmes     BOOLEAN;                  -- Flag para controlar se houve pagamento dentro do mes
      vr_dspconta     VARCHAR2(1);              -- Define com * no relatorio se o contrato esta em prejuizo
      vr_tpmespre     INTEGER;                  -- Define o tipo de mês do prejuizo (1-Dentro do Mês;2-Mais de 48 meses)
      vr_credbx12     crapepr.vlprejuz%TYPE;    -- Valor transferido a 12 meses
      vr_credbx13     crapepr.vlprejuz%TYPE;    -- Valor transferido mais de 12 meses
      vr_credbx49     crapepr.vlprejuz%TYPE;    -- Valor transferido mais de 48 meses
      vr_email_dest   VARCHAR2(100);            -- Email do destinatario crrl264.txt

      -- Variaveis para os relatorios
      vr_path_arquivo VARCHAR2(1000);           -- Diretorio que sera criado o relatorio
      vr_dspathcop    VARCHAR2(1000);           -- Diretorio que sera copiado o relatorio
      vr_des_xml_lst  CLOB;                     -- XML do relatorio crrl264.lst
      vr_des_xml_txt  CLOB;                     -- XML do relatorio crrl264.txt
      vr_nrcopias     INTEGER;                  -- Número de cópias para o relatorio crrl264.lst

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;      --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
      vr_inrestar INTEGER;                    --> Indicador de Restart
      vr_nrctremp INTEGER := 0;               --> Número do contrato do Restart
      vr_qtregres NUMBER  := 0;               --> Quantidade de registros ignorados por terem sido processados antes do restart

      vr_tab_prej prej0005.typ_tab_preju;     --> Lista dados do prejuizo de bordero
      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(vr_des_xml IN OUT NOCOPY CLOB,
                               pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
      
      PROCEDURE pc_calc_juros_remu_diario(pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                                                             ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de Liberacao do Contrato
                                                                             ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                                                            ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                                                             ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                                                             ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando na mensal
                                                                             ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                                                             ,pr_diarefju IN OUT crapepr.diarefju%TYPE  --> Dia de Referencia de Juros
                                                                             ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE  --> Mes de Referencia do Juros
                                                                             ,pr_anorefju IN OUT crapepr.anorefju%TYPE  --> Ano de Referencia do Juros
                                                                             ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                                                             ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descricao da critica
                                                                              ) IS
      BEGIN
        /* .............................................................................
           Programa: pc_calc_juros_remu_diario
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Adriano Nagasava (Supero)
           Data    : Novembro/2019                         Ultima atualizacao:

           Dados referentes ao programa:

           Frequencia: Sempre que for chamado.

           Objetivo  : Procedure para calcular o Juros Remuneratorio diário

           Alteracoes:
        ............................................................................. */

        DECLARE
          -- Variaveis de calculo da procedure
          vr_diavtolt              INTEGER;
          vr_mesvtolt              INTEGER;
          vr_anovtolt              INTEGER;
          vr_qtdedias              PLS_INTEGER;
          vr_data_final            DATE;

          -- Variaveis tratamento de erros
          vr_cdcritic              crapcri.cdcritic%TYPE;
                --
        BEGIN
          -- Logica para encontrar a data inicial para calculo
          IF pr_diarefju <> 0 AND pr_mesrefju <> 0 AND pr_anorefju <> 0 THEN
            vr_diavtolt := pr_diarefju;
            vr_mesvtolt := pr_mesrefju;
            vr_anovtolt := pr_anorefju;
          ELSE
            vr_diavtolt := to_number(to_char(pr_dtlibera, 'DD'));
            vr_mesvtolt := to_number(to_char(pr_dtlibera, 'MM'));
            vr_anovtolt := to_number(to_char(pr_dtlibera, 'YYYY'));
          END IF;

          -- Parcela em Dia
          IF pr_insitpar = 1 THEN
            vr_data_final := pr_dtvencto;
          -- Parcela a Vencer
          ELSIF pr_insitpar = 3 THEN
            vr_data_final := pr_dtmvtolt;
          -- Mensal
          ELSIF pr_ehmensal THEN
            vr_data_final := last_day(pr_dtmvtolt);
          END IF;

          --Retornar Dia/mes/ano de referencia
          pr_diarefju := to_number(to_char(vr_data_final, 'DD'));
          pr_mesrefju := to_number(to_char(vr_data_final, 'MM'));
          pr_anorefju := to_number(to_char(vr_data_final, 'YYYY'));

          -- PRJ577
          EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtvencto, 'DD') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => vr_diavtolt -- Dia da data de referência da última vez que rodou juros
                                  ,pr_mesrefju => vr_mesvtolt -- Mes da data de referência da última vez que rodou juros
                                  ,pr_anorefju => vr_anovtolt -- Ano da data de referência da última vez que rodou juros
                                  ,pr_diafinal => pr_diarefju -- Dia data final
                                  ,pr_mesfinal => pr_mesrefju -- Mes data final
                                  ,pr_anofinal => pr_anorefju -- Ano data final
                                  ,pr_qtdedias => vr_qtdedias -- Quantidade de dias calculada
                                                                );

                -- vr_qtdedias := (1 + vr_data_final) - to_date(vr_diavtolt || '/' || vr_mesvtolt || '/' || vr_anovtolt, 'dd/mm/yyyy'); -- PRJ577

          -- Condicao para verificar se o Juros jah foi lancado
          IF vr_qtdedias <= 0 THEN
            pr_vljuremu := 0;
            RETURN;
          END IF;

          -- Valor do Juros Remuneratorio
          pr_vljuremu := NVL(pr_vlsprojt, 0) * NVL((POWER(1 + pr_txdiaria, vr_qtdedias)-1),0);

          IF pr_vljuremu <= 0 THEN
            pr_vljuremu := 0;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            -- Apenas retornar a variável de saida
            pr_cdcritic := NVL(vr_cdcritic, 0);
            pr_dscritic := 'Erro na procedure pc_calc_juros_remu_diario: ' || SQLERRM;
        END;
      END pc_calc_juros_remu_diario;

          
      
      PROCEDURE pc_calc_juros_correcao_diario(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                                                                    ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                                                                    ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                                                                    ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                                                                    ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                                                                    ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                                                                    ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                                                                    ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                                                                    ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                                                                    ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                                                                    ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                                                                    ,pr_qtdiacal OUT craplem.qtdiacal%TYPE     --> Quantidade de dias de calculo
                                                                                    ,pr_vltaxprd OUT craplem.vltaxprd%TYPE     --> Taxa no Periodo
                                                                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                                                                    ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descricao da critica
                                                                                    ) IS
    BEGIN
      /* .............................................................................
         Programa: pc_calc_juros_correcao_diario
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Adriano Nagasava (Supero)
         Data    : Novembro/2019                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.

         Objetivo  : Procedure para calcular o Juros Correcao Diário

         Alteracoes:
      ............................................................................. */

      DECLARE
        -- Variaveis de calculo da procedure
        vr_qtdedias       PLS_INTEGER;
        vr_taxa_periodo   NUMBER(25,8);
        vr_data_final     DATE;
        vr_data_inicial   date;
              --
              vr_dia_final      INTEGER;
              vr_mes_final      INTEGER;
              vr_ano_final      INTEGER;

        -- Variaveis tratamento de erros
        vr_exc_erro       exception;
        vr_cdcritic       crapcri.cdcritic%TYPE;
        vr_dscritic       VARCHAR2(4000);
              --
      BEGIN
        -- Logica para encontrar a data inicial do calculo do Juros de Correcao
        IF pr_dtrefcor IS NOT NULL THEN
          vr_data_inicial := pr_dtrefcor;
        ELSE
          vr_data_inicial := pr_dtlibera;
        END IF;

        -- Parcela em Dia
        IF pr_insitpar = 1 THEN
          vr_data_final := pr_dtvencto;
        -- Parcela a Vencer
        ELSIF pr_insitpar = 3 THEN
          vr_data_final := pr_dtmvtolt;
        -- Mensal
        ELSIF pr_ehmensal THEN
          vr_data_final := last_day(pr_dtmvtolt);
        END IF;

        -- Calcula a diferenca entre duas datas e retorna os dias Uteis
        -- Trocado pela 360, pois estava calculando mais dias do que deveria
              empr0011.pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                                                                 ,pr_flgbatch    => pr_flgbatch
                                                                                 ,pr_dtefetiv    => pr_dtlibera
                                                                                 ,pr_datainicial => vr_data_inicial
                                                                                 ,pr_datafinal   => vr_data_final
                                                                                 ,pr_qtdiaute    => vr_qtdedias
                                                                                 ,pr_cdcritic    => vr_cdcritic
                                          ,pr_dscritic    => vr_dscritic
                                                                                  );
              /*--
              vr_dia_final := to_char(vr_data_final, 'DD');
              vr_mes_final := to_char(vr_data_final, 'MM');
              vr_ano_final := to_char(vr_data_final, 'YYYY');
              --
              EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal -- Indica se juros esta rodando na mensal
                                ,pr_dtdpagto => to_char(pr_dtvencto, 'DD') -- Dia do primeiro vencimento do emprestimo
                                ,pr_diarefju => to_char(vr_data_inicial, 'DD') -- Dia da data de referência da última vez que rodou juros
                                ,pr_mesrefju => to_char(vr_data_inicial, 'MM') -- Mes da data de referência da última vez que rodou juros
                                ,pr_anorefju => to_char(vr_data_inicial, 'YYYY') -- Ano da data de referência da última vez que rodou juros
                                ,pr_diafinal => vr_dia_final -- Dia data final
                                ,pr_mesfinal => vr_mes_final -- Mes data final
                                ,pr_anofinal => vr_ano_final -- Ano data final
                                ,pr_qtdedias => vr_qtdedias -- Quantidade de dias calculada
                                                              );
        --*/

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
              -- vr_qtdedias := (1 + vr_data_final) - vr_data_inicial; -- PRJ577

        -- Calculo da taxa no periodo Anterior
        vr_taxa_periodo := ROUND(POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdedias / 252)) - 1,8);
        -- Condicao para verificar se devemos calcular o Juros de Correcao
        IF vr_taxa_periodo <= 0 THEN
          RETURN;
        END IF;

        -- Valor do Juros de Correcao
        pr_vljurcor := nvl(pr_vlsprojt, 0) * vr_taxa_periodo;

        -- Quantidade de dias utilizado para o calculo
        pr_qtdiacal := vr_qtdedias;
        -- Taxa do periodo calculado
        pr_vltaxprd := vr_taxa_periodo;

      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Apenas retornar a variável de saida
          IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          pr_cdcritic := NVL(vr_cdcritic, 0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- Apenas retornar a variável de saida
          pr_cdcritic := NVL(vr_cdcritic, 0);
          pr_dscritic := 'Erro na procedure pc_calc_juros_correcao_diario: ' || SQLERRM;
      END;

    END pc_calc_juros_correcao_diario;

      
          PROCEDURE pc_calcula_juros_diario(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                                                       ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual                                      
                                                                       ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento Anterior
                                                                       ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                                                       ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                                                        ,pr_flconlan IN  BOOLEAN DEFAULT TRUE      --> Considera os juros lancado no calculo
                                                                       ,pr_vljurdia OUT NUMBER                    --> Juros Diarios
                                                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                                                       ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descricao da critica
                                                                       ) IS
      /* .............................................................................
         Programa: pc_calcula_juros_diario
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : Adriano Nagasava (Supero)
         Data    : Agosto/2019                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.

         Objetivo  : Procedure para calcular os juros diários PP e PÓS

         Alteracoes: 
      ............................................................................. */
  		
          --> Busca os dados do contrato
          CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                                            ,pr_nrdconta crapepr.nrdconta%TYPE
                            ,pr_nrctremp crapepr.nrctremp%TYPE
                                            ) IS
              SELECT epr.diarefju
                          ,epr.mesrefju
                          ,epr.anorefju
                          ,wpr.dtlibera
                          ,epr.dtdpagto
                          ,epr.txmensal
                          ,epr.vlprejuz
                          ,epr.vljraprj
                          ,epr.tpemprst -- PRJ298.3
                          ,epr.dtprejuz -- PRJ298.3
                          ,wpr.cddindex -- PRJ298.3
                          ,wpr.vlperidx -- PRJ298.3
                          ,epr.dtrefjur -- PRJ298.3
                          ,epr.dtrefcor -- PRJ298.3
                          ,epr.vlsdprej -- PRJ298.3
                          ,epr.inprejuz -- PRJ298.3
                FROM crawepr wpr
                      ,crapepr epr
               WHERE wpr.cdcooper = epr.cdcooper
                    AND wpr.nrdconta = epr.nrdconta
                    AND wpr.nrctremp = epr.nrctremp
                    AND epr.cdcooper = pr_cdcooper
                    AND epr.nrdconta = pr_nrdconta
                    AND epr.nrctremp = pr_nrctremp;
          rw_crapepr cr_crapepr%ROWTYPE;
  		
          --> Buscar menor data de vencimento em aberto da parcela de emprestimo
          CURSOR cr_crappep_maior_carga(pr_cdcooper IN crappep.cdcooper%TYPE
                                                                    ,pr_nrdconta IN crappep.nrdconta%TYPE
                                                                    ,pr_nrctremp IN crappep.nrctremp%TYPE
                                                                    ) IS 
             SELECT pep.nrdconta
                          ,pep.nrctremp
                          ,MIN(pep.dtvencto) dtvencto
                FROM crappep pep
                      ,crapass ass
               WHERE pep.cdcooper = pr_cdcooper
                    AND (pep.inliquid = 0 OR pep.inprejuz = 1)
                    AND ass.cdcooper = pep.cdcooper
                    AND ass.nrdconta = pep.nrdconta
                    AND ass.nrdconta = pr_nrdconta
                    AND pep.nrctremp = pr_nrctremp
          GROUP BY pep.nrdconta
                        ,pep.nrctremp;
          rw_crappep_maior_carga cr_crappep_maior_carga%ROWTYPE;
  		
          --> Buscar ultimo lancamento de juros prejuizo
          CURSOR cr_jurprj(pr_cdcooper IN craplem.cdcooper%TYPE
                                          ,pr_nrdconta IN craplem.nrdconta%TYPE
                                          ,pr_nrctremp IN craplem.nrctremp%TYPE
                                          ) IS
             SELECT max(lem.dtmvtolt)
                  FROM craplem lem
                WHERE lem.cdcooper = pr_cdcooper
                    AND lem.nrdconta = pr_nrdconta
                    AND lem.nrctremp = pr_nrctremp
                    AND lem.cdhistor = 2409;
          vr_dtjurprj craplem.dtmvtolt%TYPE;
  		
          CURSOR cr_craplem9(pr_cdcooper craplem.cdcooper%TYPE
                                            ,pr_nrdconta craplem.nrdconta%TYPE
                                    ,pr_nrctremp craplem.nrctremp%TYPE
                                            ) IS
             SELECT SUM(CASE WHEN c.cdhistor IN(382,2388,2473,2389/*,2391 PRJ298.3*/) THEN c.vllanmto ELSE 0 END) -
                        (SUM(CASE WHEN c.cdhistor IN(2392,2474,2393,2395) THEN c.vllanmto ELSE 0 END))sum_sldprinc
                FROM craplem c
               WHERE c.cdcooper = pr_cdcooper
                    AND c.nrdconta = pr_nrdconta
                    AND c.nrctremp = pr_nrctremp
                    AND c.cdhistor IN(382,2388,2473,2389,2391, 2392,2474,2393,2395);
          rw_craplem9 cr_craplem9%ROWTYPE;
  		
          CURSOR cr_craplem2(pr_cdcooper craplem.cdcooper%TYPE
                                              ,pr_nrdconta craplem.nrdconta%TYPE
                                              ,pr_nrctremp craplem.nrctremp%TYPE
                                              ) IS
              SELECT lem.vllanmto
                FROM craplem lem
               /* faba       ,crapdat dat
               WHERE lem.cdcooper = dat.cdcooper */
                   --faba AND to_char(lem.dtmvtolt, 'MM') = to_char(dat.dtmvtolt, 'MM')
                  where to_char(lem.dtmvtolt, 'MM') = to_char(rw_crapdat.dtmvtolt, 'MM')
                    AND lem.cdhistor = 2409
                    AND lem.cdcooper = pr_cdcooper
                    AND lem.nrdconta = pr_nrdconta
                    AND lem.nrctremp = pr_nrctremp;
          rw_craplem2 cr_craplem2%ROWTYPE;
  		
          -- Início -- PRJ298.3
         CURSOR cr_craptxi(pr_cddindex craptxi.cddindex%TYPE
                          ,pr_dtiniper craptxi.dtiniper%TYPE
                          ) IS
              SELECT txi.vlrdtaxa
                  FROM craptxi txi
                WHERE txi.cddindex = pr_cddindex
                    AND txi.dtiniper = pr_dtiniper;
          -- Fim -- PRJ298.3
          
          	CURSOR cr_crawepr(pr_cdcooper in number
									 ,pr_nrdconta in number
									 ,pr_nrctremp in number
									 ) IS
                SELECT * 
                  FROM crawepr
                 WHERE crawepr.cdcooper = pr_cdcooper
                   AND crawepr.nrdconta = pr_nrdconta
                   AND crawepr.nrctremp = pr_nrctremp;
              rw_crawepr cr_crawepr%ROWTYPE;
  		
          -- Variaveis de calculo da procedure
          vr_diavtolt      INTEGER;
          vr_mesvtolt      INTEGER;
          vr_anovtolt      INTEGER;
          vr_qtdedias      PLS_INTEGER;
          --		
          vr_diarefju      crapepr.diarefju%TYPE;
          vr_mesrefju      crapepr.mesrefju%TYPE;
          vr_anorefju      crapepr.anorefju%TYPE;
          vr_dtvencto      crapepr.dtdpagto%TYPE;
          vr_txdiaria      craplcr.txdiaria%TYPE;
          vr_slprjori      crapepr.vlprejuz%TYPE;
          vr_vllanmto      crapepr.vlprejuz%TYPE;
      --
          vr_dtiniper      craptxi.dtiniper%TYPE; -- PRJ298.3
          vr_vlrdtaxa      craptxi.vlrdtaxa%TYPE; -- PRJ298.3
          --vr_dtrefere      DATE;                  -- PRJ298.3
          vr_vljurcor      crapepr.vljuratu%TYPE; -- PRJ298.3
         vr_vljuremu      crapepr.vljuratu%TYPE; -- PRJ298.3
          vr_taxa_periodo  crapepr.vljuratu%TYPE; -- PRJ298.3
      
        -- Variaveis tratamento de erros
       vr_exc_erro      EXCEPTION;
        --
     BEGIN
          --
          OPEN cr_crapepr(pr_cdcooper
                                        ,pr_nrdconta
                                        ,pr_nrctremp
                                        );
          --
          FETCH cr_crapepr INTO rw_crapepr;
          --
          IF cr_crapepr%NOTFOUND THEN
             --
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao buscar o contrato.';
             CLOSE cr_crapepr;
             RAISE vr_exc_erro;
             --
          END IF;
          --
          CLOSE cr_crapepr;
          --
          OPEN cr_crappep_maior_carga(pr_cdcooper => pr_cdcooper
                                                               ,pr_nrdconta => pr_nrdconta
                                                               ,pr_nrctremp => pr_nrctremp
                                                               );
          --
          FETCH cr_crappep_maior_carga INTO rw_crappep_maior_carga;
          --
          IF cr_crappep_maior_carga%NOTFOUND THEN
             --
             pr_cdcritic := 0;
             pr_dscritic := 'Erro ao buscar a parcela mais antiga em atraso.';
             CLOSE cr_crappep_maior_carga;
             RAISE vr_exc_erro;
             --
          END IF;
          --
          CLOSE cr_crappep_maior_carga;
          --
          OPEN cr_jurprj(pr_cdcooper
                                     ,pr_nrdconta
                                     ,pr_nrctremp
                                     );
          --
          FETCH cr_jurprj INTO vr_dtjurprj;
          --
          CLOSE cr_jurprj;
          --
          IF vr_dtjurprj IS NULL THEN
             --
             IF nvl(rw_crapepr.diarefju,0) <> 0 AND
                    nvl(rw_crapepr.mesrefju,0) <> 0 AND
                    nvl(rw_crapepr.anorefju,0) <> 0 THEN
                --
                  vr_diarefju := rw_crapepr.diarefju;
                  vr_mesrefju := rw_crapepr.mesrefju;
                  vr_anorefju := rw_crapepr.anorefju;
                --
             ELSE
                  --
                  vr_diarefju := to_number(to_char(rw_crawepr.dtlibera, 'DD'));
                  vr_mesrefju := to_number(to_char(rw_crawepr.dtlibera, 'MM'));
                  vr_anorefju := to_number(to_char(rw_crawepr.dtlibera, 'YYYY'));
                  --
             END IF;
            --
          ELSE
             --
             IF to_number(to_char(vr_dtjurprj, 'MM')) = to_number(to_char(pr_dtmvtolt, 'MM')) THEN
                  --
                  vr_diarefju := to_number(to_char(vr_dtjurprj, 'DD'));
                  vr_mesrefju := to_number(to_char(vr_dtjurprj, 'MM'));
                  vr_anorefju := to_number(to_char(vr_dtjurprj, 'YYYY'));
                  --
             ELSE
                  --
                  vr_diarefju := to_number(to_char(trunc(pr_dtmvtolt, 'MM'), 'DD'));
                  vr_mesrefju := to_number(to_char(trunc(pr_dtmvtolt, 'MM'), 'MM'));
                  vr_anorefju := to_number(to_char(trunc(pr_dtmvtolt, 'MM'), 'YYYY'));
                  --
             END IF;
             --
          END IF;
          -- Monta data de vencimento
          vr_dtvencto := TO_DATE(TO_CHAR(rw_crapepr.dtdpagto, 'DD') || '/' || TO_CHAR(pr_dtmvtolt, 'MM/RRRR'),'DD/MM/RRRR');
          -- Calcula a taxa diaria
          vr_txdiaria := round(POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1, 7);
          -- Logica para encontrar a data inicial para calculo
          IF vr_diarefju <> 0 AND vr_mesrefju <> 0 AND vr_anorefju <> 0 THEN
             --
             vr_diavtolt := vr_diarefju;
             vr_mesvtolt := vr_mesrefju;
             vr_anovtolt := vr_anorefju;
             --
          ELSE
             --
             vr_diavtolt := to_number(to_char(rw_crapepr.dtlibera, 'DD'));
             vr_mesvtolt := to_number(to_char(rw_crapepr.dtlibera, 'MM'));
             vr_anovtolt := to_number(to_char(rw_crapepr.dtlibera, 'YYYY'));
             --
          END IF;
  		    
          --Retornar Dia/mes/ano de referencia
          vr_diarefju := to_number(to_char(pr_dtmvtolt, 'DD'));
          vr_mesrefju := to_number(to_char(pr_dtmvtolt, 'MM'));
          vr_anorefju := to_number(to_char(pr_dtmvtolt, 'YYYY'));
          --
          EMPR0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                                                          ,pr_dtdpagto => to_char(vr_dtvencto, 'DD') -- Dia do primeiro vencimento do emprestimo
                                                          ,pr_diarefju => vr_diavtolt -- Dia da data de referência da última vez que rodou juros
                                                          ,pr_mesrefju => vr_mesvtolt -- Mes da data de referência da última vez que rodou juros
                                                          ,pr_anorefju => vr_anovtolt -- Ano da data de referência da última vez que rodou juros
                                                          ,pr_diafinal => vr_diarefju -- Dia data final
                                                          ,pr_mesfinal => vr_mesrefju -- Mes data final
                                                          ,pr_anofinal => vr_anorefju -- Ano data final
                                                          ,pr_qtdedias => vr_qtdedias -- Quantidade de dias calculada
                                                          ); 
          --
          vr_slprjori := NVL(rw_crapepr.vlprejuz, 0) + nvl(rw_crapepr.vljraprj, 0);
          --
          OPEN cr_craplem9(pr_cdcooper
                                       ,pr_nrdconta
                                       ,pr_nrctremp
                                       );
          --
          LOOP
             --
             FETCH cr_craplem9 INTO rw_craplem9;
             EXIT WHEN cr_craplem9%NOTFOUND;
             --
             vr_slprjori := vr_slprjori - nvl(rw_craplem9.sum_sldprinc, 0);
             --
          END LOOP;
          --
          CLOSE cr_craplem9;
          --
          vr_vllanmto := 0;
          --
          OPEN cr_craplem2(pr_cdcooper
                                          ,pr_nrdconta
                                          ,pr_nrctremp
                                          );
          --
          LOOP
             --
             FETCH cr_craplem2 INTO rw_craplem2;
             EXIT WHEN cr_craplem2%NOTFOUND;
             --
              vr_vllanmto := vr_vllanmto + nvl(rw_craplem2.vllanmto, 0);
             --
          END LOOP;
          --
          CLOSE cr_craplem2;
          -- Valor do Juros Diários
          pr_vljurdia := round(NVL(vr_slprjori, 0) * NVL((POWER(1 + vr_txdiaria, vr_qtdedias)-1), 0), 7);
          -- Início -- PRJ298.3
          -- Se for um pós fixado em prejuízo
          IF rw_crapepr.tpemprst = 2 AND rw_crapepr.inprejuz = 1 THEN -- POS
              --
              vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                                                                  ,pr_dtmvtolt => rw_crapepr.dtprejuz - 1
                                                                                                  ,pr_tipo     => 'A'
                                                                                                  );
              --
              OPEN cr_craptxi(rw_crapepr.cddindex
                                            ,vr_dtiniper
                                            );
              --
              FETCH cr_craptxi INTO vr_vlrdtaxa;
              --
              CLOSE cr_craptxi;
              --
              IF nvl(vr_vlrdtaxa, 0) = 0 THEN
                  --
                  vr_dscritic := 'Erro ao buscar a taxa. '||SQLERRM;
                  RAISE vr_exc_erro;
                  --
              ELSE
                  --
                  vr_vlrdtaxa := vr_vlrdtaxa * (rw_crapepr.vlperidx / 100);
                  --
              END IF;
              --
              pc_calc_juros_correcao_diario(pr_cdcooper => pr_cdcooper
                                                                        ,pr_dtmvtolt => pr_dtmvtolt
                                                                        ,pr_flgbatch => FALSE -- Colocado como FALSE para não somar 1 dia
                                                                        ,pr_dtlibera => rw_crapepr.dtlibera
                                                                        ,pr_vlrdtaxa => vr_vlrdtaxa
                                                                        ,pr_dtvencto => pr_dtmvtolt--vr_dtrefere
                                                                        ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                                                        ,pr_vlsprojt => rw_crapepr.vlsdprej
                                                                        ,pr_ehmensal => FALSE
                                                                        ,pr_dtrefcor => to_date(vr_diavtolt || '/' || vr_mesvtolt || '/' || vr_anovtolt,'dd/mm/yyyy') --to_date(vr_diarefju || '/' || vr_mesrefju || '/' || vr_anorefju,'dd/mm/yyyy') --rw_crapepr.dtrefcor
                                                                        -- out
                                                                        ,pr_vljurcor => vr_vljurcor
                                                                        ,pr_qtdiacal => vr_qtdedias
                                                                        ,pr_vltaxprd => vr_taxa_periodo
                                                                        ,pr_cdcritic => vr_cdcritic
                                                                        ,pr_dscritic => vr_dscritic
                                                                        );
              /* -- PRJ298.3
              empr0011.pc_calcula_juros_correcao(pr_cdcooper => pr_cdcooper
                                                                                  ,pr_dtmvtoan => pr_dtmvtoan
                                                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                                                  ,pr_flgbatch => TRUE
                                                                                  ,pr_nrdconta => pr_nrdconta
                                                                                  ,pr_nrctremp => pr_nrctremp
                                                                                  ,pr_dtlibera => rw_crapepr.dtlibera
                                                                                  ,pr_dtrefjur => rw_crapepr.dtrefjur
                                                                                  ,pr_vlrdtaxa => vr_vlrdtaxa
                                                                                  ,pr_dtvencto => pr_dtmvtolt--vr_dtrefere
                                                                                  ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                                                                  ,pr_vlsprojt => rw_crapepr.vlsdprej
                                                                                  ,pr_ehmensal => FALSE
                                                                                  ,pr_dtrefcor => to_date(vr_diavtolt || '/' || vr_mesvtolt || '/' || vr_anovtolt,'dd/mm/yyyy') --to_date(vr_diarefju || '/' || vr_mesrefju || '/' || vr_anorefju,'dd/mm/yyyy') --rw_crapepr.dtrefcor
                                                                                  -- out
                                                                                  ,pr_vljurcor => vr_vljurcor
                                                                                  ,pr_qtdiacal => vr_qtdedias
                                                                                  ,pr_vltaxprd => vr_taxa_periodo
                                                                                  ,pr_cdcritic => vr_cdcritic
                                                                                  ,pr_dscritic => vr_dscritic
                                                                                  );
        --*/
              --
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_erro;
                  --
              END IF;
              -- Calcula a taxa diaria
              vr_txdiaria := POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1;
              --
              pc_calc_juros_remu_diario(pr_dtmvtolt => pr_dtmvtolt
                                                                ,pr_dtlibera => rw_crapepr.dtlibera
                                                                ,pr_dtvencto => pr_dtmvtolt--vr_dtrefere
                                                                ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                                                ,pr_vlsprojt => rw_crapepr.vlsdprej
                                                                ,pr_ehmensal => FALSE -- TO_DO: Validar
                                                                ,pr_txdiaria => vr_txdiaria
                                                                -- in out
                                                                ,pr_diarefju => rw_crapepr.diarefju
                                                                ,pr_mesrefju => rw_crapepr.mesrefju
                                                                ,pr_anorefju => rw_crapepr.anorefju
                                                                -- out
                                                                ,pr_vljuremu => vr_vljuremu
                                                                ,pr_cdcritic => vr_cdcritic
                                                                ,pr_dscritic => vr_dscritic
                                                                );
              /*
              empr0011.pc_calcula_juros_remuneratorio(pr_cdcooper => pr_cdcooper
                                                                                            ,pr_dtmvtoan => pr_dtmvtoan
                                                                                            ,pr_dtmvtolt => pr_dtmvtolt
                                                                                            ,pr_nrdconta => pr_nrdconta
                                                                                            ,pr_nrctremp => pr_nrctremp
                                                                                            ,pr_dtlibera => rw_crapepr.dtlibera
                                                                                            ,pr_dtvencto => pr_dtmvtolt--vr_dtrefere
                                                                                            ,pr_insitpar => 3 -- Fixo para sempre pegar a data do movimento
                                                                                            ,pr_vlsprojt => rw_crapepr.vlsdprej
                                                                                            ,pr_ehmensal => FALSE -- TO_DO: Validar
                                                                                            ,pr_txdiaria => vr_txdiaria
                                                                                            -- in out
                                                                                            ,pr_diarefju => rw_crapepr.diarefju
                                                                                            ,pr_mesrefju => rw_crapepr.mesrefju
                                                                                            ,pr_anorefju => rw_crapepr.anorefju
                                                                                            -- out
                                                                                            ,pr_vljuremu => vr_vljuremu
                                                                                            ,pr_cdcritic => vr_cdcritic
                                                                                            ,pr_dscritic => vr_dscritic
                                                                                            );
              --*/
              --
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_erro;
                  --
              END IF;
              --
              pr_vljurdia := nvl(vr_vljurcor, 0) + nvl(vr_vljuremu, 0);
              --
          END IF;
          -- Fim -- PRJ298.3
          --
          IF vr_qtdedias <= 0 THEN
             --
             pr_vljurdia := 0;
             --
          END IF;
          --
          IF pr_flconlan THEN
            --
          pr_vljurdia := nvl(pr_vljurdia, 0) + vr_vllanmto;
            --
          END IF;
          --                
          IF pr_vljurdia <= 0 THEN
             --
             pr_vljurdia := 0;
             --
          END IF;
          --
          pr_vljurdia := round(pr_vljurdia, 2);
          --
    EXCEPTION
          WHEN vr_exc_erro THEN
             NULL;
          WHEN OTHERS THEN
             -- Apenas retornar a variável de saida
             pr_cdcritic := NVL(vr_cdcritic, 0);
             pr_dscritic := 'Erro na procedure pc_calcula_juros_diario: ' || SQLERRM;
              --
    END pc_calcula_juros_diario;
    
    PROCEDURE pc_busca_dados_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                   ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                   -- OUT --
                                   ,pr_tab_prej OUT prej0005.typ_tab_preju
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2
                                   ) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_prejuizo
      Sistema  :
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 24/08/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Buscar os valores de prejuizo do bordero e titulos
      Alterações:
       -- 11/09/2018 - Alteração dos campos no select (Vitor S Assanuma - GFT)
       -- 20/09/2018 - Inserção de validação de acordo e retorno do valor ao front (Vitor S Assanuma - GFT)
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
    vr_dscritic VARCHAR2(1000);        --> desc. erro

    -- Vetor da chave do titulo
    vr_index INTEGER;



    -- Cursor Bordero somatório
    CURSOR cr_crapbdt IS
      SELECT
        bdt.dtliqprj
        ,bdt.dtprejuz                        -- Data de envio para prejuizo
        ,bdt.inprejuz                        -- Flag que define se entrou em prejuizo
        ,bdt.vlaboprj                        -- Abono
        ,bdt.qtdirisc
        ,bdt.nrdconta
        ,SUM(tdb.vlprejuz)        AS toprejuz -- Valor do Prejuizo Original
        ,SUM(tdb.vlsdprej)        AS tosdprej -- Saldo em Prejuizo
        ,SUM(tdb.vljrmprj)        AS tojrmprj -- Juros Acumulados no mês
        ,SUM(tdb.vljraprj)        AS tojraprj -- Juros Remuneratórios no prejuizo
        ,SUM(tdb.vlpgjrpr)        AS topgjrpr -- Valor PAGO dos juros Remuneratórios
        ,SUM(tdb.vlttjmpr)        AS tottjmpr -- Valor dos juros de Mora
        ,SUM(tdb.vlpgjmpr)        AS topgjmpr -- Valor PAGO dos juros de Mora
        ,SUM(tdb.vlttmupr)        AS tottmupr -- Valor dos juros de Multa
        ,SUM(tdb.vlpgmupr)        AS topgmupr -- Valor PAGO dos juros de Multa
        ,SUM(tdb.vliofprj)        AS toiofprj -- Valor dos juros de IOF
        ,SUM(tdb.vliofppr)        AS toiofppr -- Valor PAGO dos juros de IOF
        ,SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)
          + (tdb.vliofprj - tdb.vliofppr)
                                ) AS vlsldatu -- Saldo atualizado
        ,SUM((tdb.vlsldtit - tdb.vlsdprej)+ vlpgjmpr + vlpgmupr + vliofppr) AS tovlpago
        ,MIN(tdb.dtvencto)        AS dtminven -- data de vencimento mais antigo
        ,SUM(tdb.vljura60)        AS totjur60
        ,SUM(tdb.vlpgjm60)        AS totpgm60
      FROM crapbdt bdt
        INNER JOIN craptdb tdb ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
      WHERE bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = pr_nrborder
        AND (tdb.insittit = 4 OR (tdb.insittit=3 AND bdt.dtliqprj IS NOT NULL))
        AND bdt.inprejuz = 1
      GROUP BY
        bdt.dtliqprj, bdt.dtprejuz, bdt.inprejuz, bdt.vlaboprj, bdt.qtdirisc, bdt.nrdconta
    ;rw_crapbdt cr_crapbdt%ROWTYPE;

    -- Cursor de saldo do acordo
    CURSOR cr_crapaco (pr_nrdconta IN craptdb.nrdconta%TYPE) IS
    SELECT SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)
          + (tdb.vliofprj - tdb.vliofppr)
                                ) AS vlsldaco -- Saldo do acordo
       FROM craptdb tdb
       INNER JOIN tbdsct_titulo_cyber ttc
         ON tdb.cdcooper = ttc.cdcooper AND tdb.nrdconta = ttc.nrdconta AND tdb.nrborder = ttc.nrborder AND tdb.nrtitulo = ttc.nrtitulo
       INNER JOIN tbrecup_acordo_contrato tac
         ON ttc.nrctrdsc = tac.nrctremp
       INNER JOIN tbrecup_acordo ta
         ON tac.nracordo = ta.nracordo AND ttc.cdcooper = ta.cdcooper
         -- FALTAVAM ESTES CAMPOS NA CLAUSULA
        AND ta.cdcooper = ttc.cdcooper
        AND ta.nrdconta = ttc.nrdconta
       WHERE tac.cdorigem   = 4 -- Desconto de Títulos
         AND ta.cdsituacao <> 3 -- Acordo não está cancelado
         AND tdb.cdcooper   = pr_cdcooper
         AND tdb.nrborder   = pr_nrborder
         AND tdb.nrdconta   = pr_nrdconta;
    rw_crapaco cr_crapaco%ROWTYPE;
    
-- Cursor para calcular o juros de atualizacao +60
  CURSOR cr_tdb60(pr_cdcooper crapbdt.cdcooper%TYPE
                 ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                 ,pr_nrborder crapbdt.nrborder%TYPE
                 ,pr_nrdconta crapbdt.nrdconta%TYPE
                 ,pr_nrtitulo craptdb.nrtitulo%TYPE) IS
  SELECT 
     ROUND(SUM((x.dtvencto-x.dtvenmin60+1)*txdiaria*vltitulo),2) AS vljurrec, -- valor de juros de receita a ser apropriado
     cdcooper,
     nrborder,
     nrdconta
  FROM (
      SELECT UNIQUE
        tdb.dtvencto,
        tdb.vltitulo,
        tdb.cdcooper,
        tdb.vljura60,
        tdb.nrborder,
        tdb.nrdconta,
        (tdb.dtvencto-tdb.dtlibbdt) AS qtd_dias, -- quantidade de dias contabilizados para juros a apropriar
        (tdv.dtvenmin+60) AS dtvenmin60,
        ((bdt.txmensal/100)/30) AS txdiaria
      FROM 
        craptdb tdb
        INNER JOIN (SELECT cdcooper
                          ,nrdconta
                          ,nrborder
                          ,MIN(dtvencto) dtvenmin
                    FROM craptdb 
                    WHERE (dtvencto+60) < pr_dtmvtolt 
                      AND insittit = 4 
                      AND cdcooper = pr_cdcooper
                      AND nrborder = pr_nrborder
                      AND nrdconta = pr_nrdconta
                     GROUP BY cdcooper
                             ,nrdconta
                             ,nrborder
                    ) tdv ON tdb.cdcooper = tdv.cdcooper 
                         AND tdb.nrdconta = tdv.nrdconta 
                         AND tdb.nrborder = tdv.nrborder
        INNER JOIN crapbdt bdt ON bdt.nrborder=tdb.nrborder AND bdt.cdcooper=tdb.cdcooper AND bdt.flverbor=1 
        INNER JOIN crapass ass ON bdt.nrdconta=ass.nrdconta AND bdt.cdcooper=ass.cdcooper
      WHERE 1=1
        AND tdb.nrtitulo = decode(nvl(pr_nrtitulo,0), 0, tdb.nrtitulo, pr_nrtitulo)
        AND tdb.insittit = 4
        AND tdb.dtvencto >= (tdv.dtvenmin+60)
        AND tdb.nrborder = pr_nrborder
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.cdcooper = pr_cdcooper
    ) x
    GROUP BY 
      cdcooper,
      nrborder,
      nrdconta;
  rw_craptdb60 cr_tdb60%ROWTYPE;

    BEGIN


      vr_index := 0;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF cr_crapbdt%NOTFOUND THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;
      /*
      -- Caso o saldo seja zero, está liquidado
      IF rw_crapbdt.vlsldatu = 0 THEN
        vr_dscritic := 'Prejuízo já liquidado.';
        RAISE vr_exc_erro;
      END IF;*/

      -- Busca para verificar se há algum titulo em acordo
      OPEN cr_crapaco(pr_nrdconta => rw_crapbdt.nrdconta);
      FETCH cr_crapaco INTO rw_crapaco;

      IF rw_crapaco.vlsldaco IS NULL THEN
        pr_tab_prej(vr_index).vlsldaco := 0;
      ELSE
        pr_tab_prej(vr_index).vlsldaco := rw_crapaco.vlsldaco;
      END IF;
      CLOSE cr_crapaco;
      
      rw_craptdb60 := NULL;
      OPEN cr_tdb60(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_nrborder => pr_nrborder
                   ,pr_nrdconta => rw_crapbdt.nrdconta
                   ,pr_nrtitulo => 0);
      FETCH cr_tdb60 INTO rw_craptdb60;
      CLOSE cr_tdb60;

      pr_tab_prej(vr_index).dtliqprj := rw_crapbdt.dtliqprj;
      pr_tab_prej(vr_index).dtprejuz := rw_crapbdt.dtprejuz;
      pr_tab_prej(vr_index).diasatrs := rw_crapdat.dtmvtolt - rw_crapbdt.dtminven;
      pr_tab_prej(vr_index).inprejuz := rw_crapbdt.inprejuz;
      pr_tab_prej(vr_index).vlaboprj := rw_crapbdt.vlaboprj;
      pr_tab_prej(vr_index).qtdirisc := rw_crapbdt.qtdirisc;
      pr_tab_prej(vr_index).nrdconta := rw_crapbdt.nrdconta;
      pr_tab_prej(vr_index).toprejuz := rw_crapbdt.toprejuz;
      pr_tab_prej(vr_index).tosdprej := rw_crapbdt.tosdprej;
      pr_tab_prej(vr_index).tojrmprj := rw_crapbdt.tojrmprj;
      pr_tab_prej(vr_index).tojraprj := rw_crapbdt.tojraprj;
      pr_tab_prej(vr_index).topgjrpr := rw_crapbdt.topgjrpr;
      pr_tab_prej(vr_index).tottjmpr := rw_crapbdt.tottjmpr;
      pr_tab_prej(vr_index).topgjmpr := rw_crapbdt.topgjmpr;
      pr_tab_prej(vr_index).tottmupr := rw_crapbdt.tottmupr;
      pr_tab_prej(vr_index).topgmupr := rw_crapbdt.topgmupr;
      pr_tab_prej(vr_index).toiofprj := rw_crapbdt.toiofprj;
      pr_tab_prej(vr_index).toiofppr := rw_crapbdt.toiofppr;
      pr_tab_prej(vr_index).vlsldatu := rw_crapbdt.vlsldatu;
      pr_tab_prej(vr_index).tovlpago := rw_crapbdt.tovlpago;
      pr_tab_prej(vr_index).totjur60 := rw_crapbdt.totjur60;
      pr_tab_prej(vr_index).totpgm60 := rw_crapbdt.totpgm60;
      pr_tab_prej(vr_index).tojrpr60 := nvl(rw_craptdb60.vljurrec,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina PREJ0005.pc_busca_dados_prejuizo: '||SQLERRM;

  END pc_busca_dados_prejuizo;



      
      ---------------------------------------------------------------------------

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => vr_cdprogra);
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
      
      rw_crapdat.dtmvtoan := to_date('29/06/2020', 'dd/mm/RRRR');
      rw_crapdat.dtmvtolt := to_date('30/06/2020', 'dd/mm/RRRR');
      rw_crapdat.dtmvtopr := to_date('01/07/2020', 'dd/mm/RRRR');
      rw_crapdat.dtultdia := to_date('30/06/2020', 'dd/mm/RRRR');

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
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
      END IF;

      -- Se ainda houver indicação de restart
      IF vr_inrestar > 0 THEN
        -- Converter a descrição do restart que contem o contrato de empréstimo
        vr_nrctremp := gene0002.fn_char_para_number(vr_dsrestar);
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- Ultimo dia do mes
      vr_dtrefere := last_day(rw_crapdat.dtmvtolt);

      -- Obter o % de juros de prejuizo
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'JUROSPREJU'
                     ,pr_tpregist => 1);
      FETCH cr_craptab INTO rw_craptab;
      -- Se não encontrar
      IF cr_craptab%NOTFOUND THEN
         -- Fechar o cursor pois teremos raise
         CLOSE cr_craptab;
         -- Gerar erro com critica 55
         vr_cdcritic := 719;
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         RAISE vr_exc_saida;
      ELSE
         -- Fecha o cursor para continuar o processo
         CLOSE cr_craptab;
      END IF;

      -- Carrega a taxa de juros do prejuizo
      vr_txdjuros := nvl(gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,10)),0);

      -- Inicializar as informações do XML do relatorio 264.lst
      dbms_lob.createtemporary(vr_des_xml_lst, TRUE);
      dbms_lob.open(vr_des_xml_lst, dbms_lob.lob_readwrite);
      pc_escreve_xml(vr_des_xml_lst,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Inicializar as informacoes do XML do relatorio 264.txt
      dbms_lob.createtemporary(vr_des_xml_txt, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_des_xml_txt, dbms_lob.lob_readwrite);
      pc_escreve_xml(vr_des_xml_txt,'CONTA/DV;'||'CONTRATO;'||'TIPO;'||'FINALIDADE;'||'LC;'||'SALDO;'||'VALOR;'||'DATA;'||'PRIM PGTO;'||'JUROS'||chr(13));

      -- Percorre todos os emprestimo de prejuizo
      FOR rw_crapepr_crapass IN cr_crapepr_crapass (pr_cdcooper => pr_cdcooper,
                                                    pr_nrdconta => vr_nrctares) LOOP
        -- Criar bloco para tratar desvio de fluxo (next record)
        BEGIN
          -- Se há controle de restart e Se é a mesma conta, mas de uma aplicação anterior
          IF vr_inrestar > 0 AND rw_crapepr_crapass.nrdconta = vr_nrctares AND rw_crapepr_crapass.nrctremp <= vr_nrctremp THEN
            -- Ignorar o registro pois já foi processado
            RAISE vr_exc_next;
          END IF;

          -- Condicao para listar no relatorio o cabecalho por agencia
          IF rw_crapepr_crapass.nrseqage = 1 THEN
            -- Busca o nome da agencia
            OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => rw_crapepr_crapass.cdagenci);

            FETCH cr_crapage
             INTO vr_nmresage;
            CLOSE cr_crapage;

            -- Adicionar o nó da agência e já iniciar o dos contratos
            pc_escreve_xml(vr_des_xml_lst,'<agencia cdagenci="'||rw_crapepr_crapass.cdagenci||'" nmresage="'||nvl(vr_nmresage,'Nao Cadastrada')||'">');

          END IF;
          -- M324
          -- Valor do juros do mes por contrato e o que está na tela LCREDI
          --vr_vljurmes := nvl(ROUND((rw_crapepr_crapass.vlsdprej * vr_txdjuros / 100),2),0);
          vr_txmensal := NULL;
          --PJ441 ajuste de rotina
          IF rw_crapepr_crapass.cdlcremp is not null THEN
             vr_txmensal := rw_crapepr_crapass.txmensal;
          END IF;
          vr_vljurmes := nvl(ROUND((rw_crapepr_crapass.vlsdprej * nvl(vr_txmensal, vr_txdjuros) / 100),2),0);

          IF rw_crapepr_crapass.VR_IDORIGEM = 'CRAPEPR' THEN
						-- Início -- PRJ298.3
												IF rw_crapepr_crapass.tpemprst IN('PP', 'POS') AND rw_crapepr_crapass.inprejuz = 1 and rw_crapepr_crapass.vlsdprej >0  THEN
														--
														pc_calcula_juros_diario(pr_cdcooper => pr_cdcooper                 -- IN
																																														,pr_dtmvtolt => rw_crapdat.dtmvtolt         -- IN
																																														,pr_dtmvtoan => rw_crapdat.dtmvtoan         -- IN
																																														,pr_nrdconta => rw_crapepr_crapass.nrdconta -- IN
																																														,pr_nrctremp => rw_crapepr_crapass.nrctremp -- IN
																																														,pr_flconlan => False                       -- IN
																																														,pr_vljurdia => vr_vljurmes                 -- OUT
																																														,pr_cdcritic => vr_cdcritic                 -- OUT
																																														,pr_dscritic => vr_dscritic                 -- OUT
																																														);
														-- Se houve erro na rotina
														IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) <> 0 THEN
															 -- Levantar exceção
															 RAISE vr_exc_undo;
															 --
														END IF;
														--
						IF rw_crapepr_crapass.tpemprst = 'POS' THEN
							--
																BEGIN
																	 -- Atualiza os campos da tabela crapepr
																	 UPDATE crapepr
																				 SET crapepr.dtrefjur = rw_crapdat.dtmvtolt
																							 ,crapepr.diarefju = to_char(rw_crapdat.dtmvtolt, 'DD')
																							 ,crapepr.mesrefju = to_char(rw_crapdat.dtmvtolt, 'MM')
																							 ,crapepr.anorefju = to_char(rw_crapdat.dtmvtolt, 'YYYY')
																		 WHERE crapepr.ROWID = rw_crapepr_crapass.linha;
							--
															 EXCEPTION
																	 WHEN OTHERS THEN
																			 --Fechar Cursor
																			 CLOSE cr_crapepr_crapass;
																			 vr_dscritic := 'Erro ao atualizar tabela crapepr. '||SQLERRM;
																			 RAISE vr_exc_undo;
															 END;
							--
							END IF;
							--
						END IF;
						-- Fim -- PRJ298.3
          BEGIN
            -- Atualiza os campos da tabela crapepr
            UPDATE crapepr
               SET crapepr.vlsprjat = crapepr.vlsdprej
				  ,crapepr.vlsdprej = crapepr.vlsdprej + vr_vljurmes
                  ,crapepr.vljraprj = crapepr.vljraprj + vr_vljurmes
                  ,crapepr.vljrmprj = vr_vljurmes
             WHERE crapepr.ROWID = rw_crapepr_crapass.linha
              RETURNING vlsdprej
                       ,vljraprj
                       ,vljrmprj
                   INTO rw_crapepr_crapass.vlsdprej
                       ,rw_crapepr_crapass.vljraprj
                       ,rw_crapepr_crapass.vljrmprj;
          EXCEPTION
            WHEN OTHERS THEN
              --Fechar Cursor
              CLOSE cr_crapepr_crapass;
              vr_dscritic := 'Erro ao atualizar tabela crapepr. '||SQLERRM;
              RAISE vr_exc_undo;
          END;

          -- Geracao de lancamento para o juros calculado
          IF vr_vljurmes > 0 THEN
            OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
            FETCH cr_craplot
             INTO rw_craplot;
            -- Se não encontrar
            IF cr_craplot%NOTFOUND THEN
               -- Fechar o cursor pois teremos raise
               CLOSE cr_craplot;
               -- Vamos criar o registro do lote
               BEGIN
                 INSERT INTO craplot(cdcooper
                                    ,dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,nrdolote
                                    ,tplotmov)
                              VALUES(pr_cdcooper         -- Cooperativa
                                    ,rw_crapdat.dtmvtolt -- Data Atual
                                    ,1                   -- PA
                                    ,100                 -- Banco/Caixa
                                    ,8361                -- Numero do Lote
                                    ,5)                  -- Tipo de movimento
                            RETURNING dtmvtolt
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdolote
                                     ,tplotmov
                                     ,nrseqdig
                                     ,rowid
                                 INTO rw_craplot.dtmvtolt
                                     ,rw_craplot.cdagenci
                                     ,rw_craplot.cdbccxlt
                                     ,rw_craplot.nrdolote
                                     ,rw_craplot.tplotmov
                                     ,rw_craplot.nrseqdig
                                     ,rw_craplot.rowid;
                 EXCEPTION
                   WHEN OTHERS THEN
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao inserir o lote (craplot), lote: 8361. Detalhes: '||sqlerrm;
                     RAISE vr_exc_undo;
               END; /* END BEGIN */
            ELSE
              -- Fecha o cursor para continuar o processo
              CLOSE cr_craplot;
            END IF;

            -- Vamos criar o registro do lancamento de emprestimo
            BEGIN
              INSERT INTO craplem(craplem.cdcooper
                                 ,craplem.dtmvtolt
                                 ,craplem.cdagenci
                                 ,craplem.cdbccxlt
                                 ,craplem.nrdolote
                                 ,craplem.nrdconta
                                 ,craplem.nrctremp
                                 ,craplem.nrdocmto
                                 ,craplem.cdhistor
                                 ,craplem.nrseqdig
                                 ,craplem.vllanmto
                                 ,craplem.txjurepr
                                 ,craplem.dtpagemp
                                 ,craplem.vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot.dtmvtolt
                                 ,rw_craplot.cdagenci
                                 ,rw_craplot.cdbccxlt
                                 ,rw_craplot.nrdolote
                                 ,rw_crapepr_crapass.nrdconta
                                 ,rw_crapepr_crapass.nrctremp
                                 ,rw_crapepr_crapass.nrctremp
                                 ,2409--381 -- Codigo do Historico
                                 ,rw_craplot.nrseqdig + 1
                                 ,vr_vljurmes
                                 ,nvl(vr_txmensal, vr_txdjuros)
                                 ,null -- Data de pagamento do emprestimo
                                 ,0); -- Valor da prestacao
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao criar lancamento de juros prejuizo para o emprestimo (CRAPLEM) ' ||
                               '- Conta:'||rw_crapepr_crapass.nrdconta   ||
                               ' Contrato:'||rw_crapepr_crapass.nrctremp ||
                               '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;

            END; /* END BEGIN */

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vljurmes
                    ,vlcompdb = vlcompdb + vr_vljurmes
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar o lote (craplot), lote: '||
                               rw_craplot.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;

            END; /* END BEGIN */

          END IF; /* END IF vr_vljurmes > 0 */

          vr_vlrpagos := 0;
          vr_vlrabono := 0;
          vr_vlrestor := 0;
          vr_flgpgmes := FALSE;

          -- Percorre todos os lancamentos de pagamento e abono
          FOR rw_craplem IN cr_craplem (pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => rw_crapepr_crapass.nrdconta,
                                        pr_nrctremp => rw_crapepr_crapass.nrctremp,
                                        pr_dtmvtolt => vr_dtrefere) LOOP
            /* Historico de Abono */
            IF rw_craplem.cdhistor IN (383) THEN -- Somente abono antigo
              vr_vlrabono := vr_vlrabono + rw_craplem.vllanmto;
            ELSIF rw_craplem.cdhistor IN (2392,2474) THEN /* Historico de Estorno*/
              vr_vlrestor := vr_vlrestor + rw_craplem.vllanmto;
            ELSE  /* Historico de Pagamento */
              vr_vlrpagos := vr_vlrpagos + rw_craplem.vllanmto;

              /* Verifica se houve pagamento dentro do mes */
              IF to_char(rw_craplem.dtmvtolt,'mm')   = to_char(vr_dtrefere,'mm')   AND
                 to_char(rw_craplem.dtmvtolt,'RRRR') = to_char(vr_dtrefere,'RRRR') THEN
                 vr_flgpgmes := TRUE;

              END IF;

            END IF;

          END LOOP; /* END FOR rw_craplem */
            -- Define se o contrato esta em prejuizo
            IF rw_crapepr_crapass.vlprejuz - vr_vlrpagos > 0 THEN
              vr_dspconta := ' ';
            ELSE
              vr_dspconta := '*';
            END IF;

            vr_credbx12 := 0; -- Valor transferido a 12 meses
            vr_credbx13 := 0; -- Valor transferido mais de 12 meses
            vr_credbx49 := 0; -- Valor transferido mais de 48 meses
            vr_tpmespre := 0; -- Define o tipo de mês do prejuizo (1-Dentro do Mês;2-Mais de 48 meses)

            -- Condicao para verificar se o contrato em prejuizo entrou dentro do mes ou eh maior que 48 meses
            IF to_char(rw_crapepr_crapass.dtprejuz,'mmrrrr') = to_char(rw_crapdat.dtmvtolt,'mmrrrr') THEN
              vr_tpmespre := 1;
            END IF;
          --
          FOR rw_crapvri IN cr_crapvri(prc_cdcooper => pr_cdcooper,
                                       prc_nrdconta => rw_crapepr_crapass.nrdconta,
                                       prc_nrctremp => rw_crapepr_crapass.nrctremp,
                                       prc_dtrefere => rw_crapdat.dtultdia) LOOP
            vr_credbx12 := rw_crapvri.vlsaldo12;
            vr_credbx13 := rw_crapvri.vlsaldo13;
            vr_credbx49 := rw_crapvri.vlsaldo49;
            IF vr_credbx49 > 0 THEN
                vr_tpmespre := 2;
              END IF;
          END LOOP;

            -- Se o valor for zerado, nao deve ser impresso
            IF vr_vlrpagos = 0 THEN
              vr_vlrpagos := NULL;
            END IF;
          --
          IF vr_credbx12 <> 0 OR
             vr_credbx13 <> 0 OR
             vr_credbx49 <> 0 THEN
            --Montar tag do contrato para arquivo XML do relatorio 264.lst
            pc_escreve_xml(vr_des_xml_lst,'
                           <contrato>
                              <dspconta>'||vr_dspconta||'</dspconta>
                              <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_crapepr_crapass.nrdconta))||'</nrdconta>
                              <tpemprst>'||rw_crapepr_crapass.tpemprst||'</tpemprst>
                              <nmprimtl>'||rw_crapepr_crapass.nmprimtl||'</nmprimtl>
                              <nrctremp>'||LTrim(gene0002.fn_mask_contrato(rw_crapepr_crapass.nrctremp))||'</nrctremp>
                              <cdfinemp>'||rw_crapepr_crapass.cdfinemp||'</cdfinemp>
                              <cdlcremp>'||rw_crapepr_crapass.cdlcremp||'</cdlcremp>
                              <vlsdprej>'||to_char(nvl(rw_crapepr_crapass.vlsdprej,0),'fm999g999g990d00')||'</vlsdprej>
                              <vlprejuz>'||to_char(nvl(rw_crapepr_crapass.vlprejuz,0),'fm999g999g990d00')||'</vlprejuz>
                              <vlrpagos>'||to_char(nvl(vr_vlrpagos,0),'fm999g999g990d00')||'</vlrpagos>
                              <vlrestor>'||to_char(nvl(vr_vlrestor,0),'fm999g999g990d00')||'</vlrestor>
                              <vlrpgatz>'||to_char(nvl(vr_vlrpagos - vr_vlrestor,0),'fm999g999g990d00')||'</vlrpgatz>
                              <dtprejuz>'||to_char(rw_crapepr_crapass.dtprejuz,'DD/MM/RR')||'</dtprejuz>
                              <dtdpagto>'||to_char(rw_crapepr_crapass.dtdpagto,'DD/MM/RR')||'</dtdpagto>
                              <vljrmprj>'||to_char(nvl(rw_crapepr_crapass.vljrmprj,0),'fm999g999g990d00')||'</vljrmprj>
                              <vlttmupr>'||to_char(nvl(rw_crapepr_crapass.vlttmupr,0),'fm999g999g990d00')||'</vlttmupr>
                              <vlttjmpr>'||to_char(nvl(rw_crapepr_crapass.vlttjmpr,0),'fm999g999g990d00')||'</vlttjmpr>
                              <inpessoa>'||rw_crapepr_crapass.dspessoa||'</inpessoa>
                              <tipoMesPrejuizo>'||vr_tpmespre||'</tipoMesPrejuizo>
                              <valorTransferido12Meses>'||to_char(vr_credbx12,'fm999g999g990d00')||'</valorTransferido12Meses>
                              <valorTransferidoMais12Meses>'||to_char(vr_credbx13,'fm999g999g990d00')||'</valorTransferidoMais12Meses>
                              <valorTansferidoMais48Meses>'||to_char(vr_credbx49,'fm999g999g990d00')||'</valorTansferidoMais48Meses>
                           </contrato>');

           END IF;

          -- Borderô de Desconto de Títulos
          ELSIF rw_crapepr_crapass.VR_IDORIGEM = 'DSCTIT' THEN
            vr_vlrestor := 0;
            vr_credbx12 := 0; -- Valor transferido a 12 meses
            vr_credbx13 := 0; -- Valor transferido mais de 12 meses
            vr_credbx49 := 0; -- Valor transferido mais de 48 meses
            vr_tpmespre := 0; -- Define o tipo de mês do prejuizo (1-Dentro do Mês;2-Mais de 48 meses)
            
            --Faba tratamento para pular reg com problema mensal 30/06
            if pr_cdcooper = 1 and rw_crapepr_crapass.nrdconta = 6766404
                               and rw_crapepr_crapass.nrctremp = 547576 then
              continue;
            end if;
            -- faba
            pc_busca_dados_prejuizo(pr_cdcooper => pr_cdcooper
                                            ,pr_nrborder => rw_crapepr_crapass.nrctremp
                                            -- OUT --
                                            ,pr_tab_prej => vr_tab_prej
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic );

            IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
              RAISE vr_exc_saida;
            END IF;

            rw_crapepr_crapass.vlsdprej := nvl((vr_tab_prej(0).tosdprej + vr_tab_prej(0).tojraprj - vr_tab_prej(0).topgjrpr),0);
            rw_crapepr_crapass.vlprejuz := nvl(vr_tab_prej(0).toprejuz,0) + nvl(vr_tab_prej(0).tojrpr60,0);
            rw_crapepr_crapass.dtprejuz := vr_tab_prej(0).dtprejuz;
            rw_crapepr_crapass.dtdpagto := vr_tab_prej(0).dtliqprj;
            rw_crapepr_crapass.vljrmprj := nvl(vr_tab_prej(0).tojrmprj,0);
            rw_crapepr_crapass.vlttmupr := nvl(vr_tab_prej(0).tottmupr - vr_tab_prej(0).topgmupr,0);
            rw_crapepr_crapass.vlttjmpr := nvl(vr_tab_prej(0).totjur60,0);

            -- Condicao para verificar se o contrato em prejuizo entrou dentro do mes ou eh maior que 48 meses
            IF to_char(vr_tab_prej(0).dtprejuz,'mmrrrr') = to_char(rw_crapdat.dtmvtolt,'mmrrrr') THEN
              vr_tpmespre := 1;
            END IF;
            --
            FOR rw_crapvri IN cr_crapvri(prc_cdcooper => pr_cdcooper,
                                         prc_nrdconta => rw_crapepr_crapass.nrdconta,
                                         prc_nrctremp => rw_crapepr_crapass.nrctremp,
                                         prc_dtrefere => rw_crapdat.dtultdia,
                                         prc_cdmodali => 0301) LOOP
              vr_credbx12 := nvl(rw_crapvri.vlsaldo12,0);
              vr_credbx13 := nvl(rw_crapvri.vlsaldo13,0);
              vr_credbx49 := nvl(rw_crapvri.vlsaldo49,0);
              IF vr_credbx49 > 0 THEN
                vr_tpmespre := 2;
              END IF;
            END LOOP;

            vr_vlrpagos := vr_tab_prej(0).tovlpago;
            -- Se o valor for zerado, nao deve ser impresso
            IF vr_vlrpagos = 0 THEN
              vr_vlrpagos := NULL;
            END IF;
            --
            IF vr_credbx12 <> 0 OR
               vr_credbx13 <> 0 OR
               vr_credbx49 <> 0 THEN
              --Montar tag do contrato para arquivo XML do relatorio 264.lst
              pc_escreve_xml(vr_des_xml_lst,'
                             <contrato>
                                <dspconta>'||vr_dspconta||'</dspconta>
                                <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_crapepr_crapass.nrdconta))||'</nrdconta>
                                <tpemprst>'||rw_crapepr_crapass.tpemprst||'</tpemprst>
                                <nmprimtl>'||rw_crapepr_crapass.nmprimtl||'</nmprimtl>
                                <nrctremp>'||LTrim(gene0002.fn_mask_contrato(rw_crapepr_crapass.nrctremp))||'</nrctremp>
                                <cdfinemp>'||rw_crapepr_crapass.cdfinemp||'</cdfinemp>
                                <cdlcremp>'||rw_crapepr_crapass.cdlcremp||'</cdlcremp>
                                <vlsdprej>'||to_char(rw_crapepr_crapass.vlsdprej,'fm999g999g990d00')||'</vlsdprej>
                                <vlprejuz>'||to_char(rw_crapepr_crapass.vlprejuz,'fm999g999g990d00')||'</vlprejuz>
                                <vlrpagos>'||to_char(nvl(vr_vlrpagos,0),'fm999g999g990d00')||'</vlrpagos>
                                <vlrestor>'||to_char(nvl(vr_vlrestor,0),'fm999g999g990d00')||'</vlrestor>
                                <vlrpgatz>'||to_char(nvl(vr_vlrpagos - vr_vlrestor,0),'fm999g999g990d00')||'</vlrpgatz>
                                <dtprejuz>'||to_char(rw_crapepr_crapass.dtprejuz,'DD/MM/RR')||'</dtprejuz>
                                <dtdpagto>'||to_char(rw_crapepr_crapass.dtdpagto,'DD/MM/RR')||'</dtdpagto>
                                <vljrmprj>'||to_char(rw_crapepr_crapass.vljrmprj,'fm999g999g990d00')||'</vljrmprj>
                                <vlttmupr>'||to_char(rw_crapepr_crapass.vlttmupr,'fm999g999g990d00')||'</vlttmupr>
                                <vlttjmpr>'||to_char(rw_crapepr_crapass.vlttjmpr,'fm999g999g990d00')||'</vlttjmpr>
                                <inpessoa>'||rw_crapepr_crapass.dspessoa||'</inpessoa>
                                <tipoMesPrejuizo>'||vr_tpmespre||'</tipoMesPrejuizo>
                                <valorTransferido12Meses>'||to_char(vr_credbx12,'fm999g999g990d00')||'</valorTransferido12Meses>
                                <valorTransferidoMais12Meses>'||to_char(vr_credbx13,'fm999g999g990d00')||'</valorTransferidoMais12Meses>
                                <valorTansferidoMais48Meses>'||to_char(vr_credbx49,'fm999g999g990d00')||'</valorTansferidoMais48Meses>
                             </contrato>');
            END IF;
          END IF;

            --Monta o relatorio 264.txt
            pc_escreve_xml(vr_des_xml_txt,rw_crapepr_crapass.nrdconta||';'||
                                          rw_crapepr_crapass.nrctremp||';'||
                                          rw_crapepr_crapass.tpemprst||';'||
                                          rw_crapepr_crapass.cdlcremp||';'||
                                          rw_crapepr_crapass.cdfinemp||';'||
                                          rw_crapepr_crapass.vlsdprej||';'||
                                          rw_crapepr_crapass.vlprejuz||';'||
                                          to_char(rw_crapepr_crapass.dtprejuz,'DD/MM/RRRR')||';'||
                                          to_char(rw_crapepr_crapass.dtdpagto,'DD/MM/RRRR')||';'||
                                          rw_crapepr_crapass.vljrmprj||
                                          chr(10));

          -- Quando for a ultima agencia, precisamos fechar a tag do XML
          IF rw_crapepr_crapass.nrseqage = rw_crapepr_crapass.qtdagenc THEN
            pc_escreve_xml(vr_des_xml_lst,'</agencia>');
          END IF;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada 10.000 registros processados,
            -- gravar tbm o controle de restart, pois qualquer rollback que será efetuado
            -- vai retornar a situação até o ultimo commit
            -- Obs. Descontamos da quantidade atual, a quantidade que não foi processada
            --      devido a estes registros terem sido processados anteriormente ao restart
            IF Mod(cr_crapepr_crapass%ROWCOUNT - vr_qtregres,10000) = 0 THEN
              BEGIN
                UPDATE crapres
                   SET crapres.nrdconta = rw_crapepr_crapass.nrdconta             -- conta do emprestimo atual
                      ,crapres.dsrestar = LPAD(rw_crapepr_crapass.nrctremp,8,'0') -- emprestimo atual
                 WHERE crapres.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta: '||rw_crapepr_crapass.nrdconta||
                                 ' CtrEmp:'||rw_crapepr_crapass.nrctremp||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT;
            END IF;

          END IF; /* END IF pr_flgresta = 1 THEN */

        EXCEPTION
          WHEN vr_exc_next THEN
            -- Exception criada para desviar o fluxo para cá e
            -- não processar o restante das instruções após o RAISE
            -- e acumulamos o contador de registros processados
            vr_qtregres := vr_qtregres + 1;
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_saida;
        END; -- END BEGIN

      END LOOP; -- END FOR rw_crapepr_crapass

      /* Chamar rotina para eliminação do restart para evitarmos
         reprocessamento das empréstimos indevidamente */
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Efetuamos o commit final após o processamento
      COMMIT;

      -- Fecha a tag do XML raiz
      pc_escreve_xml(vr_des_xml_lst,'</raiz>');

      -- Busca do diretório base da cooperativa e a subpasta de relatórios
      vr_path_arquivo := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Gerado no diretorio /rl

      -- Verifica se a coop. eh Viacredi
      IF pr_cdcooper = 1 THEN
        vr_nrcopias := 3;
      ELSE
        vr_nrcopias := 2;
      END IF;

      -- Efetuar solicitação de geração de relatório crrl264.lst --
      GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml_lst      --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'             --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl264.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => ''                  --> Parametro
                                 ,pr_dsarqsaid => vr_path_arquivo || '/crrl264.lst'
                                 ,pr_qtcoluna  => 234                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
                                 ,pr_flg_gerar => 'S'                 --> Sempre vamos gerar o PDF na hora, pois precisamos zipar o arquivo
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml_lst);
      dbms_lob.freetemporary(vr_des_xml_lst);

      -- Cópia do 264.txt para o caminho /Tiago/
      vr_dspathcop := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL312_COPIA');
      IF vr_dspathcop IS NOT NULL THEN
        -- Se existir o literal [dsdircop] iremos substituí-lo
        vr_dspathcop := REPLACE(vr_dspathcop,'[dsdircop]',rw_crapcop.dsdircop) || ';';
      END IF;

      -- Cópia do 264.txt para o caminho /salvar/
      vr_dspathcop := vr_dspathcop || GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                                           ,pr_cdcooper => pr_cdcooper
                                                           ,pr_nmsubdir => '/salvar');

      -- Efetuar solicitação para geracao do arquivo 264.txt
      gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                       --> Cooperativa conectada
                                         ,pr_cdprogra   => vr_cdprogra                       --> Programa chamador
                                         ,pr_dtmvtolt   => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                         ,pr_dsxml      => vr_des_xml_txt                    --> Arquivo XML de dados
                                         ,pr_cdrelato   => '264'                             --> Código do relatório
                                         ,pr_dsarqsaid  => vr_path_arquivo||'/crrl264.txt'   --> Arquivo final com o path
                                         ,pr_flg_gerar  => 'S'                               --> Sempre vamos gerar o PDF na hora, pois precisamos zipar o arquivo
                                         ,pr_dspathcop  => vr_dspathcop                      --> Copiar para o diretório
                                         ,pr_fldoscop   => 'S'                               --> executar comando ux2dos
                                         ,pr_flgremarq  => 'N'                               --> Após cópia, remover arquivo de origem
                                         ,pr_des_erro   => vr_dscritic);                     --> Saída com erro

	    -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      dbms_lob.close(vr_des_xml_txt);
      dbms_lob.freetemporary(vr_des_xml_txt);

      -- Verifica se copia o arquivo para a pasta converte
      vr_dspathcop := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS312_COPIA_CONVERTE');
      IF vr_dspathcop IS NOT NULL THEN
        vr_dspathcop := REPLACE(vr_dspathcop,'[dsdircop]',rw_crapcop.dsdircop);
        -- Enviar o relatorio 264.txt para a pasta /converte/
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                    ,pr_nmarquiv => vr_path_arquivo||'/crrl264.txt'
                                    ,pr_nmarqenv => 'crrl264.txt'
                                    ,pr_des_erro => vr_dscritic);

        -- Verifica se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_dscritic := 'Erro ao converter arquivo crrl264.txt. '|| vr_dscritic;
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se deve enviar por email o relatorio 264.txt
        vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS312_EMAIL');
        IF vr_email_dest IS NOT NULL THEN
          -- Vamos zipar o relatorio 264.txt
          GENE0002.pc_zipcecred(pr_cdcooper => pr_cdcooper                  --> Cooperativa conectada
                               ,pr_dsorigem => vr_dspathcop||'crrl264.txt'  --> Arquivo a zipar
                               ,pr_tpfuncao => 'A'                          --> Tipo função (A-ADD;E-EXTRACT;V-VIEW)
                               ,pr_dsdestin => vr_dspathcop||'crrl264.zip'  --> Arquivo final .zip ou descompac
                               ,pr_dspasswd => NULL
                               ,pr_des_erro => vr_dscritic);                --> Descricao com o erro

          -- Verifica se ocorreu erro ao gerar o ZIP
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Vamos enviar por email o arquivo zipado
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper                 --> Cooperativa conectada
                                    ,pr_cdprogra        => vr_cdprogra                 --> Programa conectado
                                    ,pr_des_destino     => vr_email_dest               --> Destinatario
                                    ,pr_des_assunto     => 'Relatorio 264'             --> Assunto do e-mail
                                    ,pr_des_corpo       => ''                          --> Corpo do e-mail
                                    ,pr_des_anexo       => vr_dspathcop||'crrl264.zip' --> Um ou mais anexos separados por ';' ou ','
                                    ,pr_flg_remove_anex => 'N'                         --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N'                         --> Se o envio será do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'S'                         --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          -- Verifica se houve erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;

      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, devemos chamar a fimprg
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

  END pc_crps312_faba;
/
