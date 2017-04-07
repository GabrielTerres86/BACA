CREATE OR REPLACE PROCEDURE CECRED.pc_crps405 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                         ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  BEGIN

  /* .............................................................................

   Programa: pc_crps405                        Antigo: fontes/crps405.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2004                       Ultima atualizacao: 23/06/2016

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorio 368 - Relacao Rating a serem atualizados.
               (Apos atualizacao Rating Central de Risco )
               Sol.4 / Ordem 27 /Cadeia 1 / Exclusividade = 2
   Alteracoes:

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).
               25/08/2005 - Alterada verificacao atualizacao(Mirtes)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               08/12/2005 - Nao listar se cooperado nao possuer
                            saldo operacoes de credito(Mirtes)

               06/02/2006 - Escrever "VENCIDO" quando o rating nao foi
                            atualizado no mes e envio por e-mail (Evandro).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               10/03/2006 - Imprimir o CPF/CNPJ (Edson).

               05/07/2006 - Ajustes para melhorar a performance (Edson).

               26/01/2007 - Alterado formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).

               15/10/2009 - Ler a crapnrc ao inves da crapras.
                            Retirar campos da crapass relacionados ao Rating
                            (Gabriel).

               11/08/2011 - Parametro dtrefere na obtem_risco - GE (Guilherme).

               10/01/2012 - Melhoria de desempenho (Gabriel)


               23/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                            inpessoa (Marcos-Supero)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes de envia-lo por e-mail(Odirlei-AMcom)

               25/06/2014 - Incluso novo parametro na chamada RATI0001.pc_obtem_risco
                            SoftDesk 137892 (Daniel)

               01/10/2014 - Corrigido o tratamento de exceção na saida da pc_saldo_utiliza
                            (Marcos-Supero)

               23/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                            (Carlos Rafael Tanholi).
                            
               22/07/2016 - Correcao para exibicao correta das operacoes.
                            SoftDesk 481860 (Gil - RKAM)             

               21/02/2017 - Ajustes de performance: removida leitura e carga de tabela em memória 
			                desnecessaria da crapass (Rodrigo)

			   03/04/2017 - Chamado 598515 - Ao emitir relatório 368 não está desconsiderando valores de risco abaixo de 50000 
			                (Jean / Mout´S)
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps405 */

       --Definicao do tipo de registro para tabela memoria atualiz.
       TYPE typ_reg_atualiz IS
         RECORD (nrcpfcgc crapass.nrcpfcgc%TYPE
                ,nrdconta crapass.nrdconta%TYPE

                ,nrnotrat crapnrc.nrnotrat%TYPE
                ,indrisco crapnrc.indrisco%TYPE
                ,dtmvtolt crapnrc.dtmvtolt%TYPE
                ,vlutiliz NUMBER
                ,dtvencto VARCHAR2(100)
                ,dsoperac VARCHAR2(100)
                ,nrctrrat INTEGER
                ,dsdopera VARCHAR2(100));

       --Definicao do tipo de tabela para o relatorio
       TYPE typ_reg_conta IS
         RECORD (nrcpfcgc crapass.nrcpfcgc%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,dtaturat crapnrc.dtmvtolt%TYPE
                ,indrisco crapnrc.indrisco%TYPE
                ,inpessoa crapass.inpessoa%TYPE
                ,vlrdnota NUMBER
                ,vlutiliz NUMBER
                ,nivrisco VARCHAR2(100)
                ,dtvencto VARCHAR2(100)
                ,dscpfcgc VARCHAR2(100)
                ,nrctrrat INTEGER
                ,dsoperac VARCHAR2(100));

       --Definicao do tipo de tabela crapnrc
       TYPE typ_reg_crapnrc IS
         RECORD (nrnotrat crapnrc.nrnotrat%TYPE
                ,indrisco crapnrc.indrisco%TYPE
                ,nrctrrat crapnrc.nrctrrat%TYPE
                ,tpctrrat crapnrc.tpctrrat%TYPE
                ,dtmvtolt crapnrc.dtmvtolt%TYPE);

       --Definicao do tipo de tabela crapass
       TYPE typ_reg_crapass IS
         RECORD (cdagenci crapass.cdagenci%TYPE
                ,nrcpfcgc crapass.nrcpfcgc%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,inpessoa crapass.inpessoa%TYPE);

       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_atualiz  IS TABLE OF typ_reg_atualiz  INDEX BY PLS_INTEGER;
       TYPE typ_tab_desprez  IS TABLE OF crapass.nrcpfcgc%TYPE INDEX BY VARCHAR2(25);
       TYPE typ_tab_conta    IS TABLE OF typ_reg_conta    INDEX BY VARCHAR2(200);
       TYPE typ_tab_crapnrc  IS TABLE OF typ_reg_crapnrc  INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapass  IS TABLE OF typ_reg_crapass  INDEX BY PLS_INTEGER;
       TYPE typ_tab_nivrisco IS TABLE OF INTEGER          INDEX BY VARCHAR2(3);


       --Definicao das tabelas de memoria
       vr_tab_atualiz      typ_tab_atualiz;
       vr_tab_desprez      typ_tab_desprez;
       vr_tab_conta        typ_tab_conta;
       vr_tab_crapnrc      typ_tab_crapnrc;
       vr_tab_crapass      typ_tab_crapass;
       vr_tab_dsdrisco     RATI0001.typ_tab_dsdrisco;
       vr_tab_nivrisco     typ_tab_nivrisco;


       --Cursores da rotina crps405

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
               ,cop.vlmaxleg
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar informacoes da tabela generica
       CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                         ,pr_nmsistem IN craptab.nmsistem%TYPE
                         ,pr_tptabela IN craptab.tptabela%TYPE
                         ,pr_cdempres IN craptab.cdempres%TYPE
                         ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
         SELECT craptab.tpregist
               ,craptab.dstextab
         FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
         AND   UPPER(craptab.nmsistem) = pr_nmsistem
         AND   UPPER(craptab.tptabela) = pr_tptabela
         AND   craptab.cdempres = pr_cdempres
         AND   UPPER(craptab.cdacesso) = pr_cdacesso;

       --Selecionar informacoes Notas do rating por conta
       CURSOR cr_crapnrc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapnrc.nrdconta
               ,crapnrc.nrnotrat
               ,crapnrc.indrisco
               ,crapnrc.nrctrrat
               ,crapnrc.tpctrrat
               ,crapnrc.dtmvtolt
         FROM crapnrc crapnrc
         WHERE crapnrc.cdcooper = pr_cdcooper
         AND   crapnrc.insitrat = 2;

       --Selecionar os associados da cooperativa
       CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.inpessoa

               ,Count(1) OVER (PARTITION BY crapass.nrcpfcgc) qtdreg
               ,Row_Number() OVER (PARTITION BY crapass.nrcpfcgc
                                   ORDER BY crapass.nrcpfcgc) nrseqreg
         FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.dtelimin IS NULL
         AND   crapass.inpessoa <> 3;

       --Selecionar os associados da cooperativa para loop final
       CURSOR cr_crapass_final (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT /* INDEX (crapass crapass##crapass6) */
                crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.inpessoa
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Variaveis Locais
       vr_inusatab     BOOLEAN;
       vr_vlrisco      NUMBER;
       vr_diarating    INTEGER;
       vr_contador     INTEGER;
       vr_nrdconta     INTEGER;
       vr_vlutiliz     NUMBER;
       vr_nivrisco     VARCHAR2(2);
       vr_dtrefere     DATE;
       vr_data         DATE;

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS405';
       vr_exc_fimprg   EXCEPTION;
       vr_cdcritic     crapcri.cdcritic%TYPE;
       vr_dscritic     VARCHAR2(4000);

       --Variaveis de apoio para tabela memoria
       vr_nrc_nrnotrat crapnrc.nrnotrat%TYPE;
       vr_nrc_indrisco crapnrc.indrisco%TYPE;
       vr_nrc_dtmvtolt crapnrc.dtmvtolt%TYPE;
       vr_nrc_nrctrrat crapnrc.nrctrrat%TYPE;
       vr_nrc_dsdopera VARCHAR2(100);

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_atualiz INTEGER;
       vr_index_salvo   INTEGER;
       vr_index_desprez VARCHAR2(25);
       vr_index_conta   VARCHAR2(200);

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;

	   -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;

       --Variaveis para retorno de erro
       vr_dstextab_bacen craptab.dstextab%TYPE;
       vr_dstextab_dias  craptab.dstextab%TYPE;

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_atualiz.DELETE;
         vr_tab_desprez.DELETE;
         vr_tab_conta.DELETE;
         vr_tab_crapnrc.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_dsdrisco.DELETE;
         vr_tab_nivrisco.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps405.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

       --Escrever no arquivo CLOB
	   PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

	   --Geração do relatório crrl368
       PROCEDURE pc_imprime_crrl368 (pr_des_erro OUT VARCHAR2) IS

         --Cursores Locais
         CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE
                           ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
           SELECT crapage.nmresage
           FROM crapage crapage
           WHERE crapage.cdcooper = pr_cdcooper
           AND   crapage.cdagenci = pr_cdagenci;
         rw_crapage cr_crapage%ROWTYPE;

         --Variaveis Locais
         vr_cdagenci     INTEGER;
         vr_dsassunto    VARCHAR2(100);
         vr_destino      VARCHAR2(100);
         vr_nrcpfcgc_ant crapass.nrcpfcgc%TYPE:= 0;

   	     --Variavel de Exceção
		     vr_exc_erro EXCEPTION;

         --Variaveis de arquivo
         vr_nom_direto     VARCHAR2(100);
         vr_nom_arquivo    VARCHAR2(100);

	   BEGIN
	     --Inicializar variavel de erro
		 vr_dscritic:= NULL;

         -- Busca do diretório base da cooperativa para PDF
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl368><agencias>');
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl368';

         --Acessar primeiro registro da tabela de memoria
         vr_index_conta:= vr_tab_conta.FIRST;

         WHILE vr_index_conta IS NOT NULL  LOOP

           --Determinar a agencia atual
           vr_cdagenci:= vr_tab_conta(vr_index_conta).cdagenci;

           --Se for o primeiro registro da agencia
           IF vr_index_conta = vr_tab_conta.FIRST OR vr_cdagenci <> vr_tab_conta(vr_tab_conta.PRIOR(vr_index_conta)).cdagenci THEN
             --Selecionar informacoes das agencias
             OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => vr_cdagenci);
             FETCH cr_crapage INTO rw_crapage;
             CLOSE cr_crapage;
             -- Adicionar o nó da agências
             pc_escreve_xml('<agencia cdagenci="'||vr_cdagenci||'" nmresage="'||rw_crapage.nmresage||'">');
           END IF;

           --Se for a primeira conta do cpf/cnpj
           IF vr_tab_conta(vr_index_conta).nrcpfcgc != vr_nrcpfcgc_ant THEN

             --Atualizar cpf anterior com o atual
             vr_nrcpfcgc_ant:= vr_tab_conta(vr_index_conta).nrcpfcgc;

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_conta(vr_index_conta).nrdconta)||'</nrdconta>
                  <nmprimtl>'||SubStr(vr_tab_conta(vr_index_conta).nmprimtl,0,30)||'</nmprimtl>
                  <nrcpfcgc>'||GENE0002.fn_mask_cpf_cnpj(vr_tab_conta(vr_index_conta).nrcpfcgc,vr_tab_conta(vr_index_conta).inpessoa)||'</nrcpfcgc>
                  <nrctrrat>'||To_Char(vr_tab_conta(vr_index_conta).nrctrrat,'fm999g999g999')||'</nrctrrat>
                  <dsoperac>'||vr_tab_conta(vr_index_conta).dsoperac||'</dsoperac>
                  <dtaturat>'||To_Char(vr_tab_conta(vr_index_conta).dtaturat,'DD/MM/RR')||'</dtaturat>
                  <indrisco>'||vr_tab_conta(vr_index_conta).indrisco||'</indrisco>
                  <vlrdnota>'||To_Char(vr_tab_conta(vr_index_conta).vlrdnota,'fm999g999d00')||'</vlrdnota>
                  <vlutiliz>'||To_Char(vr_tab_conta(vr_index_conta).vlutiliz,'fm999g999g999d00')||'</vlutiliz>
                  <nivrisco>'||vr_tab_conta(vr_index_conta).nivrisco||'</nivrisco>
                  <dtvencto>'||vr_tab_conta(vr_index_conta).dtvencto||'</dtvencto>
               </conta>');
           ELSE
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta>
                  <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_conta(vr_index_conta).nrdconta)||'</nrdconta>
                  <nmprimtl>'||SubStr(vr_tab_conta(vr_index_conta).nmprimtl,0,30)||'</nmprimtl>
                  <nrcpfcgc></nrcpfcgc>
                  <nrctrrat></nrctrrat>
                  <dsoperac></dsoperac>
                  <dtaturat></dtaturat>
                  <indrisco></indrisco>
                  <vlrdnota></vlrdnota>
                  <vlutiliz></vlutiliz>
                  <nivrisco></nivrisco>
                  <dtvencto></dtvencto>
               </conta>');
           END IF;

           IF vr_index_conta = vr_tab_conta.LAST OR vr_cdagenci <> vr_tab_conta(vr_tab_conta.NEXT(vr_index_conta)).cdagenci THEN
             --Finalizar tag contas e agencia
             pc_escreve_xml('</agencia>');
		       END IF;

           --Encontrar o proximo registro da tabela de memoria
           vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);
         END LOOP;

			   -- Finalizar o agrupador de agencias
         pc_escreve_xml('</agencias></crrl368>');

         --Enviar email se for Viacredi
         IF pr_cdcooper = 1 THEN
           --Recuperar emails de destino
           vr_destino:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL368');
           --Se nao encontrou
           IF vr_destino IS NULL THEN
             --Montar mensagem de erro
             vr_dscritic:= 'Não foi encontrado destinatário para o relatorio crrl368.';
             --Levantar Exceção
             RAISE vr_exc_erro;
           END IF;
           --Determinar o assunto do email
           vr_dsassunto:= 'RELATORIO 368/405';
         ELSE
           --Nao enviar email
           vr_destino:= NULL;
           vr_dsassunto:= NULL;
         END IF;

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl368/agencias/agencia/conta' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl368.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Enviar como parâmetro apenas o titulo
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_fldosmail => 'S'                 --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                    ,pr_dsmailcop => vr_destino          --> Destinatario email
                                    ,pr_dsassmail => vr_dsassunto        --> Assunto do email
                                    ,pr_des_erro  => vr_dscritic);       --> Saída com erro
         -- Testar se houve erro
         IF vr_dscritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

	     EXCEPTION
	       WHEN vr_exc_erro THEN
		     pr_des_erro:= vr_dscritic;
           WHEN OTHERS THEN
             pr_des_erro:= 'Erro ao imprimir relatório crrl368. '||sqlerrm;
	   END;
     ---------------------------------------
     -- Inicio Bloco Principal pc_crps405
     ---------------------------------------
     BEGIN

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
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
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
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
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela de notas do rating por contrato
       FOR rw_crapnrc IN cr_crapnrc (pr_cdcooper => pr_cdcooper) LOOP
         --Popular vetor de memoria
         vr_tab_crapnrc(rw_crapnrc.nrdconta).dtmvtolt:= rw_crapnrc.dtmvtolt;
         vr_tab_crapnrc(rw_crapnrc.nrdconta).nrnotrat:= rw_crapnrc.nrnotrat;
         vr_tab_crapnrc(rw_crapnrc.nrdconta).indrisco:= rw_crapnrc.indrisco;
         vr_tab_crapnrc(rw_crapnrc.nrdconta).nrctrrat:= rw_crapnrc.nrctrrat;
         vr_tab_crapnrc(rw_crapnrc.nrdconta).tpctrrat:= rw_crapnrc.tpctrrat;
       END LOOP;

       --Carregar tabela de notas do rating por contrato
       FOR rw_crapass IN cr_crapass_final (pr_cdcooper => pr_cdcooper) LOOP
         --Popular vetor de memoria
         vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
         vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc:= rw_crapass.nrcpfcgc;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
       END LOOP;

       --selecionar informacoes do risco na tabela generica
       FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'GENERI'
                                    ,pr_cdempres => 0
                                    ,pr_cdacesso => 'PROVISAOCL') LOOP

         --Se for tipo registro 999
         IF rw_craptab.tpregist = 999 THEN  /* Vlr obrigatorio informar risco */
           --Atribuir valor do risco
           vr_vlrisco:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,15,11));
           --Atribuir dia rating
           vr_diarating:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,87,3));
         END IF;

         --Popular vetor memoria para uso na RATI0001.pc_obtem_risco
         vr_contador:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,2));
         vr_tab_dsdrisco(vr_contador):= TRIM(SUBSTR(rw_craptab.dstextab,8,3));
         vr_tab_nivrisco(TRIM(SUBSTR(rw_craptab.dstextab,8,3))):= vr_contador;
         /** Alimentar variavel para nao ser preciso criar registro na PROVISAOCL **/
         vr_tab_dsdrisco(10):= 'H';
         vr_tab_nivrisco('H'):= 10;
         vr_tab_dsdrisco(0)  := 'A';
         vr_tab_nivrisco(' '):= 2;
       END LOOP;

       --Popular variavel com valor risco bacen
       vr_dstextab_bacen:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'USUARI'
                                                     ,pr_cdempres => 11
                                                     ,pr_cdacesso => 'RISCOBACEN'
                                                     ,pr_tpregist => 0);

       --Selecionar informacoes das taxas para calculo dias
       vr_dstextab_dias:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'USUARI'
                                                    ,pr_cdempres => 11
                                                    ,pr_cdacesso => 'TAXATABELA'
                                                    ,pr_tpregist => 0);

       --Se encontrou valor para os dias
       IF vr_dstextab_dias IS NULL THEN
         vr_inusatab:= FALSE;
       ELSE
         IF SUBSTR(vr_dstextab_dias,1,1) = '0' THEN
           vr_inusatab:= FALSE;
         ELSE
           vr_inusatab:= TRUE;
         END IF;
       END IF;

       --Determinar a data do movimento
       vr_dtmvtolt:= (rw_crapdat.dtmvtolt - vr_diarating); /* 180 dias */

       /* Parametro dias para rating ser atualizado */
       IF vr_diarating <> 0 THEN

         --Escrever mensagem no log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 1 -- mensagem
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || 'Calculando o saldo utilizado');
         /* Ratings efetivos */

         --Selecionar todos os associados
         FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP

           BEGIN
             --Se for a primeira ocorrencia do cpf/cnpj
             IF rw_crapass.nrseqreg = 1 THEN
               --Executar rotina saldo_utiliza.p
               GENE0005.pc_saldo_utiliza (pr_cdcooper    => pr_cdcooper          --> Código da Cooperativa
                                         ,pr_tpdecons    => 1                    --> Consulta pelo cpf/cnpj
                                         ,pr_nrdconta    => NULL                 --> Numero da Conta do associado
                                         ,pr_nrcpfcgc    => rw_crapass.nrcpfcgc  --> Numero do cpf ou cgc do associado
                                         ,pr_dsctrliq    => ' '                  --> Numero do contrato de liquidacao
                                         ,pr_cdprogra    => vr_cdprogra          --> Código do programa chamador
                                         ,pr_tab_crapdat => rw_crapdat           --> Tipo de registro de datas
                                         ,pr_inusatab    => vr_inusatab          --> Indicador de utilização da tabela de juros
                                         ,pr_vlutiliz    => vr_vlutiliz          --> Valor utilizado do credito
                                         ,pr_cdcritic    => vr_cdcritic          --> Código de retorno da critica
                                         ,pr_dscritic    => vr_dscritic);        --> Mensagem de erro
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;
             END IF;

             /* Rating efetivo */
             IF vr_tab_crapnrc.EXISTS(rw_crapass.nrdconta) AND Nvl(vr_vlutiliz,0) > 0 THEN
               /* Rating devera ser atualizado prox.mes*/
               vr_data:= vr_tab_crapnrc(rw_crapass.nrdconta).dtmvtolt + vr_diarating - 30;
               /* No proximo mes estara vencendo ... */
               IF To_Char(vr_data,'YYYYMM') = To_Char(rw_crapdat.dtmvtopr,'YYYYMM') THEN
 
             --Se o valor utilizado for menor valor risco -- retirar esta regra se não for aprovado o conceito (Jean / Mout´S)
             IF Nvl(vr_vlutiliz,0) < Nvl(vr_vlrisco,0) THEN
               --Inserir na tabela de desprezados
               vr_index_desprez:= LPad(rw_crapass.nrcpfcgc,25,'0');
               vr_tab_desprez(vr_index_desprez):= rw_crapass.nrcpfcgc;
               --proximo registro crapass
               CONTINUE;
             END IF;
             
                 --Determinar o proximo registro
                 vr_index_atualiz:= vr_tab_atualiz.Count+1;
                 vr_tab_atualiz(vr_index_atualiz).nrcpfcgc:= rw_crapass.nrcpfcgc;
                 vr_tab_atualiz(vr_index_atualiz).nrdconta:= rw_crapass.nrdconta;

                 vr_tab_atualiz(vr_index_atualiz).nrnotrat:= vr_tab_crapnrc(rw_crapass.nrdconta).nrnotrat;
                 vr_tab_atualiz(vr_index_atualiz).indrisco:= vr_tab_crapnrc(rw_crapass.nrdconta).indrisco;
                 vr_tab_atualiz(vr_index_atualiz).dtmvtolt:= vr_tab_crapnrc(rw_crapass.nrdconta).dtmvtolt;
                 vr_tab_atualiz(vr_index_atualiz).vlutiliz:= vr_vlutiliz;
                 vr_tab_atualiz(vr_index_atualiz).nrctrrat:= vr_tab_crapnrc(rw_crapass.nrdconta).nrctrrat;
                 vr_tab_atualiz(vr_index_atualiz).dtvencto:= To_Char(vr_tab_crapnrc(rw_crapass.nrdconta).dtmvtolt + vr_diarating,'DD/MM/RR');
                 vr_tab_atualiz(vr_index_atualiz).dsdopera:= RATI0001.fn_busca_descricao_operacao(vr_tab_crapnrc(rw_crapass.nrdconta).tpctrrat);
                 --proximo registro crapass
                 CONTINUE;
               END IF;
             END IF;
             /* Possue Rating atualizado */
             IF vr_tab_crapnrc.EXISTS(rw_crapass.nrdconta) AND
                vr_tab_crapnrc(rw_crapass.nrdconta).dtmvtolt > vr_dtmvtolt THEN
               --Inserir na tabela de desprezados
               vr_index_desprez:= LPad(rw_crapass.nrcpfcgc,25,'0');
               vr_tab_desprez(vr_index_desprez):= rw_crapass.nrcpfcgc;
               --proximo registro crapass
               CONTINUE;
             END IF;

             --Se o valor utilizado for menor valor maximo legislaçao / 3
             IF Nvl(vr_vlutiliz,0) < (rw_crapcop.vlmaxleg / 3) THEN
               --Inserir na tabela de desprezados
               vr_index_desprez:= LPad(rw_crapass.nrcpfcgc,25,'0');
               vr_tab_desprez(vr_index_desprez):= rw_crapass.nrcpfcgc;
               --proximo registro crapass
               CONTINUE;
             END IF;

             --Se o valor utilizado for menor valor risco
             IF Nvl(vr_vlutiliz,0) < Nvl(vr_vlrisco,0) THEN
               --Inserir na tabela de desprezados
               vr_index_desprez:= LPad(rw_crapass.nrcpfcgc,25,'0');
               vr_tab_desprez(vr_index_desprez):= rw_crapass.nrcpfcgc;
               --proximo registro crapass
               CONTINUE;
             END IF;

             --Se existir crapnrc
             IF vr_tab_crapnrc.EXISTS(rw_crapass.nrdconta) THEN
               --Atribui valores do vetor para as variaveis
               vr_nrc_nrnotrat:= vr_tab_crapnrc(rw_crapass.nrdconta).nrnotrat;
               vr_nrc_indrisco:= vr_tab_crapnrc(rw_crapass.nrdconta).indrisco;
               vr_nrc_dtmvtolt:= vr_tab_crapnrc(rw_crapass.nrdconta).dtmvtolt;
               vr_nrc_nrctrrat:= vr_tab_crapnrc(rw_crapass.nrdconta).nrctrrat;
               vr_nrc_dsdopera:= RATI0001.fn_busca_descricao_operacao(vr_tab_crapnrc(rw_crapass.nrdconta).tpctrrat);

             ELSE
               --Atribuir null para todas as variaveis
               vr_nrc_nrnotrat:= NULL;
               vr_nrc_indrisco:= NULL;
               vr_nrc_dtmvtolt:= NULL;
               vr_nrc_nrctrrat:= NULL;
               vr_nrc_dsdopera:= NULL;
             END IF;

             --Determinar o proximo registro
             vr_index_atualiz:= vr_tab_atualiz.Count+1;
             vr_tab_atualiz(vr_index_atualiz).nrcpfcgc:= rw_crapass.nrcpfcgc;
             vr_tab_atualiz(vr_index_atualiz).nrdconta:= rw_crapass.nrdconta;

             vr_tab_atualiz(vr_index_atualiz).nrnotrat:= vr_nrc_nrnotrat;
             vr_tab_atualiz(vr_index_atualiz).indrisco:= vr_nrc_indrisco;
             vr_tab_atualiz(vr_index_atualiz).dtmvtolt:= vr_nrc_dtmvtolt;
             vr_tab_atualiz(vr_index_atualiz).vlutiliz:= vr_vlutiliz;
             vr_tab_atualiz(vr_index_atualiz).nrctrrat:= vr_nrc_nrctrrat;
             vr_tab_atualiz(vr_index_atualiz).dtvencto:= 'VENCIDO';
             vr_tab_atualiz(vr_index_atualiz).dsdopera:= vr_nrc_dsdopera;

           EXCEPTION
             WHEN vr_exc_erro THEN
               RAISE vr_exc_erro;
             WHEN OTHERS THEN
               vr_dscritic:= ''||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END LOOP; --rw_crapass

         /* Verifica se alguma conta possui RATING */

         --Posicionar no inicio do vetor
         vr_index_atualiz:= vr_tab_atualiz.FIRST;
         --Percorrer todos os registros do vetor
         WHILE vr_index_atualiz IS NOT NULL LOOP
           --Verificar se é para desprezar e apaga registro
           vr_index_desprez:= LPad(vr_tab_atualiz(vr_index_atualiz).nrcpfcgc,25,'0');
           IF vr_tab_desprez.EXISTS(vr_index_desprez) THEN
             --Salvar o proximo registro para excluir o atual
             vr_index_salvo:= vr_tab_atualiz.NEXT(vr_index_atualiz);
             --Remover o cpf atual do vetor
             vr_tab_atualiz.DELETE(vr_index_atualiz);
             --Determinar qual o proximo registro do vetor com base no index salvo
             vr_index_atualiz:= vr_index_salvo;
           ELSE
             --Encontrar o proximo registro do vetor
             vr_index_atualiz:= vr_tab_atualiz.NEXT(vr_index_atualiz);
           END IF;
         END LOOP;

         --Escrever mensagem no log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 1 -- mensagem
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || 'Calculando o risco');

         --Posicionar no inicio do vetor
         vr_index_atualiz:= vr_tab_atualiz.FIRST;
         --Percorrer todos os registros do vetor
         WHILE vr_index_atualiz IS NOT NULL LOOP
           --Determinar o numero da conta para facilitar buscas
           vr_nrdconta:= vr_tab_atualiz(vr_index_atualiz).nrdconta;
           --Obter risco
           RATI0001.pc_obtem_risco (pr_cdcooper       => pr_cdcooper        --Código da Cooperativa
                                   ,pr_nrdconta       => vr_nrdconta        --Numero da Conta do Associado
                                   ,pr_tab_dsdrisco   => vr_tab_dsdrisco    --Vetor com dados das provisoes
                                   ,pr_dstextab_bacen => vr_dstextab_bacen  --Descricao da craptab do RISCOBACEN
                                   ,pr_dtmvtolt       => rw_crapdat.dtmvtolt -- Data de Movimento
                                   ,pr_nivrisco       => vr_nivrisco        --Nivel de Risco
                                   ,pr_dtrefere       => vr_dtrefere        --Data de Referencia do Risco
                                   ,pr_cdcritic       => vr_cdcritic        --Código da Critica de Erro
                                   ,pr_dscritic       => vr_dscritic);      --Descricao do erro
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o nivel de risco nao for nulo
           IF vr_nivrisco IS NOT NULL THEN

             --Inserir registro tabela conta
             vr_index_conta:= LPad(vr_tab_crapass(vr_nrdconta).cdagenci,10,'0')||
                              LPad(99999999999999999999 - (Round(vr_tab_atualiz(vr_index_atualiz).vlutiliz,2) * 100),20,'0')||
                              LPad(vr_tab_crapass(vr_nrdconta).nrcpfcgc,25,'0')||
                              LPad(999 - vr_tab_nivrisco(NVL(vr_tab_atualiz(vr_index_atualiz).indrisco,' ')),3,'0')||
                              LPad(vr_tab_atualiz(vr_index_atualiz).nrnotrat,25,'0')||
                              To_Char(vr_tab_atualiz(vr_index_atualiz).dtmvtolt,'DDMMYYYY')||
                              LPad(vr_nrdconta,10,'0');

             vr_tab_conta(vr_index_conta).cdagenci:= vr_tab_crapass(vr_nrdconta).cdagenci;
             vr_tab_conta(vr_index_conta).nrcpfcgc:= vr_tab_crapass(vr_nrdconta).nrcpfcgc;
             vr_tab_conta(vr_index_conta).inpessoa:= vr_tab_crapass(vr_nrdconta).inpessoa;
             vr_tab_conta(vr_index_conta).nrdconta:= vr_nrdconta;
             vr_tab_conta(vr_index_conta).nmprimtl:= vr_tab_crapass(vr_nrdconta).nmprimtl;
             vr_tab_conta(vr_index_conta).dtaturat:= vr_tab_atualiz(vr_index_atualiz).dtmvtolt;
             vr_tab_conta(vr_index_conta).indrisco:= vr_tab_atualiz(vr_index_atualiz).indrisco;
             vr_tab_conta(vr_index_conta).vlrdnota:= vr_tab_atualiz(vr_index_atualiz).nrnotrat; 
             vr_tab_conta(vr_index_conta).vlutiliz:= vr_tab_atualiz(vr_index_atualiz).vlutiliz;
             vr_tab_conta(vr_index_conta).nrctrrat:= vr_tab_atualiz(vr_index_atualiz).nrctrrat;
             vr_tab_conta(vr_index_conta).dsoperac:= vr_tab_atualiz(vr_index_atualiz).dsdopera; /* Corrigido (Gil Rkam) */
             vr_tab_conta(vr_index_conta).nivrisco:= vr_nivrisco;
             vr_tab_conta(vr_index_conta).dtvencto:= vr_tab_atualiz(vr_index_atualiz).dtvencto;
             vr_tab_conta(vr_index_conta).dscpfcgc:= GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta).nrcpfcgc,vr_tab_crapass(vr_nrdconta).inpessoa);
           END IF;

           --Encontrar o proximo registro do vetor
           vr_index_atualiz:= vr_tab_atualiz.NEXT(vr_index_atualiz);
         END LOOP;

         --Escrever inicio geração relatório no log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || 'Gerando relatorio');

         --Executar relatório RELACAO RATING A SEREM ATUALIZADOS
         pc_imprime_crrl368 (pr_des_erro => vr_dscritic);
         --Se retornou erro
         IF vr_dscritic IS NOT NULL THEN
           --Levantar Exceção
           RAISE vr_exc_erro;
         END IF;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         --Salvar informacoes no banco de dados
         COMMIT;

       END IF; --vr_diarating <> 0

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
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Efetuar commit pois gravaremos o que foi processo até então
         COMMIT;
       WHEN vr_exc_erro THEN
         -- Efetuar rollback
         ROLLBACK;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Retornar texto do erro
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;

       WHEN OTHERS THEN
         -- Efetuar rollback
         ROLLBACK;
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Retornar texto do erro
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;

     END;
   END pc_crps405;
/
