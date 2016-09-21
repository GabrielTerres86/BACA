CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS326" (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                                    ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                                    ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                                    ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                                    ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN

  /* .............................................................................

   Programa: pc_crps326                        Antigo: fontes/crps326.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Maio/2002.                        Ultima atualizacao: 14/01/2015

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 004.
               Listar mensalmente os contratos de limite de cheque especial
               vencidos.
               Emite relatorio 275 - 132 colunas.

   Alteracoes: 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               24/04/2007 - Subst. tabela "LIMCHEQESP" por craplrt e criar
                            tabela temporaria  (Ze).

               22/02/2008 - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               11/09/2009 - Adicionar novo campo craplim.vllimit - "Valor Lim."
                            e ajustar leitura do telefone do cooperado, passar
                            a utilizar a craptfc (Fernando).

               17/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               14/01/2015 - Ajuste na verificacao do vencimento do limite.(James)
     ............................................................................. */

     DECLARE

       --Tipo de registro dos limites
       TYPE typ_reg_crawlim IS
         RECORD (nrdconta INTEGER
                ,cdagenci INTEGER
                ,nrdofone VARCHAR2(100)
                ,nmprimtl VARCHAR2(100)
                ,cdempres INTEGER
                ,cdturnos INTEGER
                ,dtfimvig DATE
                ,vllimite NUMBER);

       --Tipo de registro dos titulares de conta
       TYPE typ_reg_crapttl IS
         RECORD (cdempres crapttl.cdempres%TYPE
                ,cdturnos crapttl.cdturnos%TYPE);

       --Tipo de tabela de memoria
       TYPE typ_tab_crapage IS TABLE OF crapage.nmresage%TYPE INDEX BY PLS_INTEGER;
       TYPE typ_tab_craptfc IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
       TYPE typ_tab_crawlim IS TABLE OF typ_reg_crawlim INDEX BY VARCHAR2(20);
       TYPE typ_tab_crapttl IS TABLE OF typ_reg_crapttl INDEX BY PLS_INTEGER;

       --Tabelaa de memoria
       vr_tab_crapage  typ_tab_crapage;
       vr_tab_resid    typ_tab_craptfc;
       vr_tab_comer    typ_tab_craptfc;
       vr_tab_crawlim  typ_tab_crawlim;
       vr_tab_crapttl  typ_tab_crapttl;

       /* Cursores da rotina crps326 */

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

       --Selecionar os associados da cooperativa para loop final
       CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,SubStr(crapass.nmprimtl,1,35) nmprimtl
               ,crapass.inpessoa
               ,crapass.inisipmf
               ,crapass.nrcadast
               ,crapass.tpvincul
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;

       --Selecionar informacoes dos titulares da conta
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                         ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
         SELECT crapttl.cdcooper
               ,crapttl.nrdconta
               ,crapttl.cdempres
               ,crapttl.cdturnos
         FROM crapttl crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
         AND   crapttl.idseqttl = pr_idseqttl;
       rw_crapttl cr_crapttl%ROWTYPE;

       --Selecionar informacoes dos titulares da conta
       CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                         ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
         SELECT crapjur.cdempres
         FROM crapjur crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
         AND   crapjur.nrdconta = pr_nrdconta;

       --Selecionar informacoes das agencias
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT crapage.cdagenci
               ,crapage.nmresage
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper;

       --Selecionar os limites de credito
       CURSOR cr_craplim (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT craplim.nrdconta
               ,craplim.cddlinha
               ,craplim.dtinivig
               ,craplim.dtfimvig
               ,craplim.qtdiavig
               ,craplim.dtrenova
               ,craplim.vllimite
         FROM craplim craplim
         WHERE craplim.cdcooper = pr_cdcooper
         AND   craplim.tpctrlim = 1
         AND   craplim.insitlim = 2;

       --Selecionar os telefones dos associados
       CURSOR cr_craptfc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT craptfc.nrdddtfc
               ,craptfc.nrtelefo
               ,craptfc.nrdconta
               ,craptfc.tptelefo
         FROM craptfc
         WHERE craptfc.cdcooper = pr_cdcooper
         AND   craptfc.idseqttl = 1
         AND   craptfc.tptelefo IN (1,3)
         ORDER BY craptfc.nrdconta,craptfc.tptelefo,craptfc.progress_recid;

       --Variaveis Locais
       vr_cdagenci     INTEGER;
       vr_cdempres     INTEGER;
       vr_cdturnos     INTEGER;
       vr_dtfimvig     DATE;
       vr_nrtelefo     VARCHAR2(100);

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     VARCHAR2(10);

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;

       --Variaveis do indice
       vr_index_crawlim VARCHAR2(20);

	     -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis para retorno de critica
       vr_cdcritic    NUMBER;
       vr_dscritic    VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_saida EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapttl.DELETE;
         vr_tab_crapage.DELETE;
         vr_tab_resid.DELETE;
         vr_tab_comer.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps326.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

	     --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps326
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS326';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS326'
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
         RAISE vr_exc_saida;
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
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1 -- Fixo
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       --Limpar tabelas de memoria
       pc_limpa_tabela;

       --Carregar tabela de memoria de agencias
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapage(rw_crapage.cdagenci):= rw_crapage.nmresage;
       END LOOP;

       --Carregar tabela de memoria de telefones
       FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper) LOOP
         IF rw_craptfc.tptelefo = 1 AND NOT vr_tab_resid.EXISTS(rw_craptfc.nrdconta) THEN
           vr_tab_resid(rw_craptfc.nrdconta):= To_Char(rw_craptfc.nrdddtfc,'fm999')||' '||rw_craptfc.nrtelefo;
         ELSIF rw_craptfc.tptelefo = 3 AND NOT vr_tab_comer.EXISTS(rw_craptfc.nrdconta) THEN
           vr_tab_comer(rw_craptfc.nrdconta):= To_Char(rw_craptfc.nrdddtfc,'fm999')||' '||rw_craptfc.nrtelefo;
         END IF;
       END LOOP;

       --Carregar tabela de memoria de titulares da conta
       FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                    ,pr_idseqttl => 1) LOOP
         vr_tab_crapttl(rw_crapttl.nrdconta).cdempres:=  rw_crapttl.cdempres;
         vr_tab_crapttl(rw_crapttl.nrdconta).cdturnos:=  rw_crapttl.cdturnos;
       END LOOP;

       /* Selecionar todos os limites de credito */
       FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper) LOOP

         --Selecionar todos os associados
         FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_craplim.nrdconta) LOOP

           --Se for pessoa fisica
           IF rw_crapass.inpessoa = 1 THEN
             --Selecionar informacoes dos titulares da conta
             IF vr_tab_crapttl.EXISTS(rw_crapass.nrdconta) THEN
               --Codigo da empresa recebe o codigo da empresa do titular da conta
               vr_cdempres:= vr_tab_crapttl(rw_crapass.nrdconta).cdempres;
               vr_cdturnos:= vr_tab_crapttl(rw_crapass.nrdconta).cdturnos;
             ELSE
               --Codigo da empresa recebe zero
               vr_cdempres:= 0;
               vr_cdturnos:= 0;
             END IF;
           ELSE
             --Selecionar informacoes dos titulares da conta
             FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta) LOOP
               --Codigo da empresa recebe o codigo da empresa do titular da conta
               vr_cdempres:= rw_crapjur.cdempres;
               --Atribuir nulo para turnos
               vr_cdturnos:= 0;
             END LOOP;
           END IF;

           --Inicializar numero do telefone
           vr_nrtelefo:= NULL;

           --Se existir telefone residencial
           IF vr_tab_resid.EXISTS(rw_crapass.nrdconta) THEN
             --Recebe o telefone residencial
             vr_nrtelefo:= vr_tab_resid(rw_crapass.nrdconta);
           ELSIF vr_tab_comer.EXISTS(rw_crapass.nrdconta) THEN
             --Recebe o telefone comercial
             vr_nrtelefo:= vr_tab_comer(rw_crapass.nrdconta);
           END IF;

           vr_dtfimvig := nvl(rw_craplim.dtfimvig, rw_craplim.dtinivig + rw_craplim.qtdiavig);
           --Se a data de inicio da vigencia + dias da vigencia da linha < data movimento
           IF vr_dtfimvig < vr_dtmvtolt THEN
             --Montar indice para tabela memoria limite
             vr_index_crawlim:= LPad(rw_crapass.cdagenci,10,'0')||
                                LPad(rw_crapass.nrdconta,10,'0');
             --Popular tabela memoria limites ordenado por agencia e conta
             vr_tab_crawlim(vr_index_crawlim).nrdconta:= rw_craplim.nrdconta;
             vr_tab_crawlim(vr_index_crawlim).cdagenci:= rw_crapass.cdagenci;
             vr_tab_crawlim(vr_index_crawlim).vllimite:= rw_craplim.vllimite;
             vr_tab_crawlim(vr_index_crawlim).nrdofone:= vr_nrtelefo;
             vr_tab_crawlim(vr_index_crawlim).nmprimtl:= rw_crapass.nmprimtl;
             vr_tab_crawlim(vr_index_crawlim).dtfimvig:= vr_dtfimvig;
             vr_tab_crawlim(vr_index_crawlim).cdempres:= vr_cdempres;
             vr_tab_crawlim(vr_index_crawlim).cdturnos:= vr_cdturnos;
           END IF;
         END LOOP; --rw_crapass
       END LOOP; --rw_craplim

       -- Busca do diretório base da cooperativa para PDF
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl275';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl275>');

       --Percorrer todos os limites
       vr_index_crawlim:= vr_tab_crawlim.FIRST;
       WHILE vr_index_crawlim IS NOT NULL LOOP

         --Atribuir codigo da agencia para variavel
         vr_cdagenci:= vr_tab_crawlim(vr_index_crawlim).cdagenci;

         -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
         IF vr_index_crawlim = vr_tab_crawlim.FIRST OR vr_cdagenci <> vr_tab_crawlim(vr_tab_crawlim.PRIOR(vr_index_crawlim)).cdagenci THEN
           -- Adicionar o nó da agência e já iniciar o de depositos
           pc_escreve_xml('<agencia cdagenci="'||vr_cdagenci||
                          '" nmresage="'||vr_tab_crapage(vr_cdagenci)||'">');
         END IF;

         --Montar tag da conta para arquivo XML
         pc_escreve_xml
           ('<conta>
             <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_crawlim(vr_index_crawlim).nrdconta)||'</nrdconta>
             <nrdofone>'||vr_tab_crawlim(vr_index_crawlim).nrdofone||'</nrdofone>
             <cdempres>'||vr_tab_crawlim(vr_index_crawlim).cdempres||'</cdempres>
             <cdturnos>'||vr_tab_crawlim(vr_index_crawlim).cdturnos||'</cdturnos>
             <nmprimtl>'||vr_tab_crawlim(vr_index_crawlim).nmprimtl||'</nmprimtl>
             <dtfimvig>'||To_Char(vr_tab_crawlim(vr_index_crawlim).dtfimvig,'DD/MM/YYYY')||'</dtfimvig>
             <vllimite>'||To_Char(vr_tab_crawlim(vr_index_crawlim).vllimite,'fm999g999g990d00')||'</vllimite>
            </conta>');
         IF vr_index_crawlim = vr_tab_crawlim.LAST OR vr_tab_crawlim(vr_index_crawlim).cdagenci <> vr_tab_crawlim(vr_tab_crawlim.NEXT(vr_index_crawlim)).cdagenci THEN
           -- Finalizar o agrupador de depositos e de Agencia e inicia totalizador do PAC
           pc_escreve_xml('</agencia>');
         END IF;
         --Encontrar o proximo registro do vetor de agencias
         vr_index_crawlim:= vr_tab_crawlim.NEXT(vr_index_crawlim);
       END LOOP;

       -- Finalizar o agrupador do relatório
       pc_escreve_xml('</crrl275>');

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl275/agencia/conta' --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl275.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Sem parametros
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                  ,pr_qtcoluna  => 132                  --> 80 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                  ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 1                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                  ,pr_des_erro  => vr_dscritic);       --> Saída com erro
       -- Testar se houve erro
       IF vr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_saida;
       END IF;

       -- Liberando a memória alocada pro CLOB
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);

       --Limpar tabelas de memoria
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
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
         pr_dscritic := SQLERRM;
         -- Efetuar rollback
         ROLLBACK;
       END;
   END pc_crps326;
/

