CREATE OR REPLACE PROCEDURE CECRED.
                pc_crps312 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
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
   Data    : Junho/2001.                     Ultima atualizacao: 19/09/2016

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
               
              25/06/2017 - M324 - Incluir historico de pagamento - Jean (Mout´S)
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
           AND (craplem.cdhistor = 382 /* Pagamentos */
             OR craplem.cdhistor = 383 /* Abonos */
             OR craplem.cdhistor = 2388); /* Pagamento Prejuizo */
      rw_craplem cr_craplem%ROWTYPE;

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
         SELECT crapepr.nrdconta
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
               ,DECODE(crapepr.tpemprst,0,'TR',1,'PP','-') tpemprst
               ,crapepr.rowid
               ,crapepr.vlttmupr
               ,crapepr.vlttjmpr
               ,crapass.cdagenci
               ,crapass.nmprimtl
               ,DECODE(crapass.inpessoa,1,'PF',2,'PJ','NA') dspessoa
               ,Row_Number() OVER (PARTITION BY crapass.cdagenci ORDER BY crapass.cdagenci) nrseqage
               ,COUNT(1) OVER (PARTITION BY crapass.cdagenci) qtdagenc
           FROM crapepr,
                crapass
          WHERE crapepr.cdcooper  = crapass.cdcooper
            AND crapepr.nrdconta  = crapass.nrdconta
            AND crapepr.cdcooper  = pr_cdcooper
            AND crapepr.nrdconta >= pr_nrdconta
            AND crapepr.inprejuz  = 1
       ORDER BY crapass.cdagenci,
                crapepr.nrdconta,
                crapepr.nrctremp;

      ------------------------------- VARIAVEIS -------------------------------
      vr_txdjuros     NUMBER(35,7);             -- Taxas de Juros de Prejuizo.
      vr_vljurmes     crapepr.vljurmes%TYPE;    -- Valor do juros do mes
      vr_vlrabono     crapepr.vlsdprej%TYPE;    -- Valor do Abono
      vr_vlrpagos     crapepr.vlsdprej%TYPE;    -- Valor de Pagamento
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

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_xml(vr_des_xml IN OUT NOCOPY CLOB,
                               pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

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

          -- Valor do juros do mes
          vr_vljurmes := nvl(ROUND((rw_crapepr_crapass.vlsdprej * vr_txdjuros / 100),2),0);
          BEGIN
            -- Atualiza os campos da tabela crapepr
            UPDATE crapepr
               SET crapepr.vlsprjat = crapepr.vlsdprej
				  ,crapepr.vlsdprej = crapepr.vlsdprej + vr_vljurmes
                  ,crapepr.vljraprj = crapepr.vljraprj + vr_vljurmes
                  ,crapepr.vljrmprj = vr_vljurmes
            WHERE crapepr.ROWID = rw_crapepr_crapass.ROWID
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
                                 ,381 -- Codigo do Historico
                                 ,rw_craplot.nrseqdig + 1
                                 ,vr_vljurmes
                                 ,vr_txdjuros,
                                 null, -- Data de pagamento do emprestimo
                                 0); -- Valor da prestacao
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
          vr_flgpgmes := FALSE;

          -- Percorre todos os lancamentos de pagamento e abono
          FOR rw_craplem IN cr_craplem (pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => rw_crapepr_crapass.nrdconta,
                                        pr_nrctremp => rw_crapepr_crapass.nrctremp,
                                        pr_dtmvtolt => vr_dtrefere) LOOP
            /* Historico de Abono */
            IF rw_craplem.cdhistor = 383 THEN
              vr_vlrabono := vr_vlrabono + rw_craplem.vllanmto;
            ELSE  /* Historico de Pagamento */
              vr_vlrpagos := vr_vlrpagos + rw_craplem.vllanmto;

              /* Verifica se houve pagamento dentro do mes */
              IF to_char(rw_craplem.dtmvtolt,'mm')   = to_char(vr_dtrefere,'mm')   AND
                 to_char(rw_craplem.dtmvtolt,'RRRR') = to_char(vr_dtrefere,'RRRR') THEN
                 vr_flgpgmes := TRUE;

              END IF;

            END IF;

          END LOOP; /* END FOR rw_craplem */

          /* Se nao houve pagamento dentro do mes, e o valor do prejuizo e o valor do juros for igual a 0, nao vamos listar no relatorio */
          IF NOT(NOT vr_flgpgmes AND rw_crapepr_crapass.vlsdprej = 0 AND rw_crapepr_crapass.vljrmprj = 0) THEN

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

            -- Condicao para somar o valor transferido ate 12 meses
            IF rw_crapepr_crapass.vlprejuz - vr_vlrpagos - vr_vlrabono > 0 THEN
              IF months_between(trunc(rw_crapdat.dtmvtolt,'MM'), trunc(rw_crapepr_crapass.dtprejuz,'MM')) +1 <= 12 THEN
                vr_credbx12 := rw_crapepr_crapass.vlprejuz - vr_vlrpagos - vr_vlrabono;
              ELSIF months_between(trunc(rw_crapdat.dtmvtolt,'MM'), trunc(rw_crapepr_crapass.dtprejuz,'MM')) +1 BETWEEN 13 AND 48  THEN
                -- Condicao para somar o valor transferido mais de 12 meses até 48 meses
                vr_credbx13 := rw_crapepr_crapass.vlprejuz - vr_vlrpagos - vr_vlrabono;
              ELSE
                -- Condicao para somar o valor transferido mais de 48 meses
                vr_credbx49 := rw_crapepr_crapass.vlprejuz - vr_vlrpagos - vr_vlrabono;
                vr_tpmespre := 2;
              END IF;
            END IF;

            -- Se o valor for zerado, nao deve ser impresso
            IF vr_vlrpagos = 0 THEN
              vr_vlrpagos := NULL;
            END IF;

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

          END IF;

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

  END pc_crps312;
