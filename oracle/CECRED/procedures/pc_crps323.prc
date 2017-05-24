CREATE OR REPLACE PROCEDURE CECRED.pc_crps323 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  BEGIN

  /* .............................................................................

   Programa: pc_crps323                        Antigo: Fontes/crps323.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Marco/2002                        Ultima atualizacao: 05/04/2017

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 004.
               Ordem do programa na solicitacao: 25.
               Emite relatorio 274 com os 100 maiores saldos de depositos
               (a vista + a prazo).

   Alteracoes: 07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               08/11/2006 - Inclusao do PAC do cooperado no relatorio 274
                            (Elton).

               27/11/2006 - Melhoria da performance (Evandro).

               31/07/2007 - Tratamento para aplicacoes RDC (David).

               19/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i. (Sidnei - Precise).

               22/01/2009 - Alteracao cdempres (Diego).

               05/05/2009 - Alterar formato de aux1_vlsldapl p/ evitar estouro
                            (Gabriel).

               10/01/2012 - Melhoria do desempenho (Gabriel).

               22/04/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               18/11/2013 - Formatação do campo matrícula antes sem formato (Marcos-Supero)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero).

               18/12/2013 - Implementação das alterações de novembro (Petter - Supero).
							 
							 25/08/2014 - Adicionado tratamento para aplicações de captação nas 
							              colunas de DEP. A PRAZO e TOTAL DE DEPOSITOS do crrl274.
														(Reinert)

               05/04/2017 - #455742 Melhorias de performance. Ajuste de passagem dos parâmetros inpessoa
                            e nrcpfcgc para não consultar novamente o associado no pkg apli0001 (Carlos)
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps323 */

       -- Informações das aplicações do RDCA
       TYPE typ_reg_craprda_det IS
         RECORD(nraplica craprda.nraplica%TYPE
               ,tpaplica craprda.tpaplica%TYPE
               ,vlsltxmx craprda.vlsltxmx%TYPE);
       TYPE typ_tab_craprda_det IS
         TABLE OF typ_reg_craprda_det
           INDEX BY PLS_INTEGER;

       TYPE typ_reg_craprda IS
         RECORD(tab_craprda typ_tab_craprda_det);
       TYPE typ_tab_craprda IS
         TABLE OF typ_reg_craprda
           INDEX BY PLS_INTEGER; -- Numero da conta
       vr_tab_craprda typ_tab_craprda;
			 
			 -- Informações das aplicações de captação
			 TYPE typ_reg_craprac IS
			   RECORD(nraplica craprac.nraplica%TYPE
				       ,vlsldatl craprac.vlsldatl%TYPE);
			 TYPE typ_tab_craprac IS 
			   TABLE OF typ_reg_craprac
				   INDEX BY PLS_INTEGER;
			 vr_tab_craprac typ_tab_craprac;

       --Definicao do tipo de registro para relatorio geral
       TYPE typ_reg_salva IS
         RECORD (nrdconta INTEGER
                ,cdagenci INTEGER
                ,cdempres INTEGER
                ,nrmatric INTEGER
                ,vlsldsom NUMBER
                ,vlslddep NUMBER
                ,vlsldapl NUMBER
                ,nmprimtl crapass.nmprimtl%TYPE);

       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_salva  IS TABLE OF typ_reg_salva INDEX BY VARCHAR2(30);
       TYPE typ_tab_tot    IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

       --Definicao das tabelas de memoria
       vr_tab_salva        typ_tab_salva;
       vr_tab_crapdtc      typ_tab_tot;
       vr_tab_crapsld      typ_tab_tot;
       vr_tab_crapttl      typ_tab_tot;
       vr_tab_erro         GENE0001.typ_tab_erro;

       --Cursores da rotina crps323

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

       --Selecionar informacoes das aplicacoes rdca
       CURSOR cr_craprda IS
         SELECT craprda.nrdconta
               ,craprda.nraplica
               ,craprda.tpaplica
               ,craprda.vlsltxmx
         FROM  crapass,
               craprda
         WHERE craprda.cdcooper = crapass.cdcooper
         AND   craprda.tpaplica IN (3,5,7,8)
         AND   craprda.insaqtot = 0
         AND   craprda.cdageass = crapass.cdagenci
         AND   craprda.nrdconta = crapass.nrdconta
         AND   crapass.cdcooper = pr_cdcooper
         AND   crapass.dtelimin IS NULL
         AND   crapass.inpessoa <> 3;
				 
			 -- Selecionar informações das aplicações de captação
			 CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE) IS
				 SELECT rac.vlsldatl
				       ,rac.nrdconta
							 ,rac.nraplica
					 FROM craprac rac
					WHERE rac.cdcooper = pr_cdcooper;
						
       --Selecionar informacoes dos associados
       CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE) IS
         SELECT crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.inpessoa
               ,crapass.nrmatric
               ,crapass.nmprimtl
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.dtelimin IS NULL
         AND   crapass.inpessoa <> 3;

       --Selecionar as formas de captacao de recursos
       CURSOR cr_crapdtc (pr_cdcooper IN crapdtc.cdcooper%TYPE) IS
         SELECT crapdtc.tpaplica
               ,crapdtc.tpaplrdc
         FROM crapdtc crapdtc
         WHERE crapdtc.cdcooper = pr_cdcooper;

       --Selecionar informacoes das poupancas
       CURSOR cr_craprpp (pr_cdcooper IN craprpp.cdcooper%TYPE
                         ,pr_nrdconta IN craprpp.nrdconta%TYPE) IS
         SELECT craprpp.rowid,
                crapass.inpessoa,
                crapass.nrcpfcgc
         FROM craprpp, crapass
         WHERE craprpp.cdcooper = pr_cdcooper
         AND   craprpp.nrdconta = pr_nrdconta
         AND   craprpp.cdcooper = crapass.cdcooper
         AND   craprpp.nrdconta = crapass.nrdconta;

       --Selecionar informacoes do saldo das aplicacoes
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
         SELECT crapsld.nrdconta
               ,(Nvl(crapsld.vlsddisp,0) +
                 Nvl(crapsld.vlsdbloq,0) +
                 Nvl(crapsld.vlsdblpr,0) +
                 Nvl(crapsld.vlsdblfp,0) +
                 Nvl(crapsld.vlsdchsl,0)) total
         FROM crapsld crapsld
         WHERE crapsld.cdcooper = pr_cdcooper;

       --Selecionar informacoes do titulas da conta
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE) IS
         SELECT crapttl.nrdconta
               ,crapttl.cdempres
         FROM crapttl crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
         AND   crapttl.idseqttl = 1;

       --Selecionar informacoes da pessoa juridica
       CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                         ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
         SELECT crapjur.cdempres
         FROM crapjur crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
         AND   crapjur.nrdconta = pr_nrdconta;

       --Constantes Locais
       vr_cdagenci_par CONSTANT INTEGER:= 0;
       vr_nrdcaixa_par CONSTANT INTEGER:= 0;

       --Variaveis Locais
       vr_vlsldapl     NUMBER(25,8);
       vr_vlsldrdc     NUMBER(25,8);
       vr_vlsldrda     NUMBER(25,8);
       vr_vlsdpoup     NUMBER(25,8);
       vr_vlslddep     NUMBER(25,8);
       vr_vlsldsom     NUMBER(25,8);
       vr_vlsdrdpp     NUMBER(25,8);
       vr_ger_vlsdrdca NUMBER(25,8);
       vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
       vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA

       /***** Variaveis RDCA para BO *****/
       vr_vldperda     NUMBER(25,8);
       vr_txaplica     NUMBER(25,8);
       vr_cdempres     INTEGER;
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS323';
       vr_contador     INTEGER;
       vr_vlsldapl_2   NUMBER(25,8);

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_salva    VARCHAR2(30);
       vr_ind_rda        NUMBER(06);

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;
       vr_dtmvtopr     DATE;

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;

       --Variaveis para retorno de erro
       --vr_des_erro    VARCHAR2(4000);
       vr_des_compl   VARCHAR2(4000);
       vr_dstextab    VARCHAR2(1000);

       --Variavel para arquivo de dados e xml
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis de Excecao
       vr_exc_undo  EXCEPTION;
       vr_exc_erro  EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;
       vr_exc_fimprg EXCEPTION;
       vr_cdcritic   crapcri.cdcritic%TYPE;
       vr_dscritic   VARCHAR2(4000);

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_salva.DELETE;
         vr_tab_crapsld.DELETE;
         vr_tab_crapdtc.DELETE;
         vr_tab_crapttl.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps323.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

       --Geração do relatório crrl274
       PROCEDURE pc_imprime_crrl274 (pr_des_erro OUT VARCHAR2) IS
         --Variavel de Exceção
         vr_exc_erro EXCEPTION;
       BEGIN
         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl274';
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl274><contas>');

         --Iniciar contador
         vr_contador:= 0;
         --Acessar primeiro registro da tabela de memoria de detalhe
         vr_index_salva:= vr_tab_salva.FIRST;
         WHILE vr_index_salva IS NOT NULL  LOOP
           --Incrementar contador
           vr_contador:= vr_contador + 1;
           --Somente imprimir os 100 primeiros
           IF vr_contador > 100 THEN
             EXIT;
           END IF;
           --Verificar se a quantidade depositada é zero
           IF Nvl(vr_tab_salva(vr_index_salva).vlslddep,0) = 0 THEN
             vr_tab_salva(vr_index_salva).vlslddep:= NULL;
           END IF;
           --Verificar se a quantidade aplicada é zero
           IF Nvl(vr_tab_salva(vr_index_salva).vlsldapl,0) = 0 THEN
             vr_tab_salva(vr_index_salva).vlsldapl:= NULL;
           END IF;
           --Montar tag da conta para arquivo XML
           pc_escreve_xml
             ('<conta>
                <cdagenci>'||vr_tab_salva(vr_index_salva).cdagenci||'</cdagenci>
                <qtregist>'||vr_contador||'</qtregist>
                <nrdconta>'||GENE0002.fn_mask_conta(vr_tab_salva(vr_index_salva).nrdconta)||'</nrdconta>
                <cdempres>'||vr_tab_salva(vr_index_salva).cdempres||'</cdempres>
                <nrmatric>'||gene0002.fn_mask_matric(vr_tab_salva(vr_index_salva).nrmatric)||'</nrmatric>
                <nmprimtl>'||SubStr(vr_tab_salva(vr_index_salva).nmprimtl,1,40)||'</nmprimtl>
                <vlsldsom>'||To_Char(vr_tab_salva(vr_index_salva).vlsldsom,'fm999g999g999g990d00')||'</vlsldsom>
                <vlslddep>'||To_Char(vr_tab_salva(vr_index_salva).vlslddep,'fm999g999g999g990d00')||'</vlslddep>
                <vlsldapl>'||To_Char(vr_tab_salva(vr_index_salva).vlsldapl,'fm999g999g999g990d00')||'</vlsldapl>
             </conta>');
           --Encontrar o proximo registro da tabela de memoria
           vr_index_salva:= vr_tab_salva.NEXT(vr_index_salva);
         END LOOP;

         --Finalizar tag detalhe
         pc_escreve_xml('</contas></crrl274>');

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl274/contas/conta'       --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl274.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Titulo do relatório
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_flg_gerar => 'N'                 --> Gerar arquivo na hora
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
           pr_des_erro:= 'Erro ao imprimir relatório crrl274. '||sqlerrm;
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps323
     ---------------------------------------
     BEGIN

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic := 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
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
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
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
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| vr_dscritic );
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela de memoria de tipos de captacao
       FOR rw_crapdtc IN cr_crapdtc (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapdtc(rw_crapdtc.tpaplica):= rw_crapdtc.tpaplrdc;
       END LOOP;

       --Carregar tabela de memória de saldos
       FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapsld(rw_crapsld.nrdconta):= rw_crapsld.total;
       END LOOP;

       --Carregar tabela de memoria de titulares de conta
       FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapttl(rw_crapttl.nrdconta):= rw_crapttl.cdempres;
       END LOOP;

       --Carregar a tabela de aplicações do RDCA
       FOR rw_craprda IN cr_craprda LOOP
         -- Adicionar ao vetor as informações chaveando pela conta
         vr_tab_craprda(rw_craprda.nrdconta).tab_craprda(cr_craprda%ROWCOUNT).nraplica := rw_craprda.nraplica;
         vr_tab_craprda(rw_craprda.nrdconta).tab_craprda(cr_craprda%ROWCOUNT).tpaplica := rw_craprda.tpaplica;
         vr_tab_craprda(rw_craprda.nrdconta).tab_craprda(cr_craprda%ROWCOUNT).vlsltxmx := rw_craprda.vlsltxmx;
       END LOOP;

       -- Carregar a tabela de aplicações de captação
       FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper) LOOP
				 vr_tab_craprac(rw_craprac.nrdconta).nraplica := rw_craprac.nraplica;
				 vr_tab_craprac(rw_craprac.nrdconta).vlsldatl := NVL(vr_tab_craprac(rw_craprac.nrdconta).vlsldatl,0) + NVL(rw_craprac.vlsldatl,0);
			 END LOOP;

       --Essa informacao é necessária para a rotina pc_calc_poupanca
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PERCIRAPLI'
                                               ,pr_tpregist => 0);

       --Pesquisar todos os associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         --Zerar valores do saldo
         vr_vlsldrdc:= 0;
         vr_vlsldrda:= 0;
         vr_vlsdpoup:= 0;
         vr_vlsldsom:= 0;
         vr_vlslddep:= 0;
         vr_vlsldapl:= 0;
         vr_vlsldapl_2:= 0;

         -- Verifica se tem aplicacao
         IF vr_tab_craprda.EXISTS(rw_crapass.nrdconta) THEN
           vr_ind_rda := vr_tab_craprda(rw_crapass.nrdconta).tab_craprda.first;

           --Pesquisar todas as aplicacoes
           WHILE vr_ind_rda IS NOT NULL LOOP
             --Bloco necessário para controle fluxo
             BEGIN
               --Inicializar variavel de retorno do saldo
               vr_ger_vlsdrdca:= 0;
               /* Calcular o Saldo da aplicacao ate a data do movimento */
               IF vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).tpaplica = 3 THEN
                 -- Consulta saldo aplicação RDCA30 (Antiga includes/b1wgen0004.i)
                 APLI0001.pc_consul_saldo_aplic_rdca30 (pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                       ,pr_dtmvtolt => vr_dtmvtolt         --> Data do processo
                                                       ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                                       ,pr_dtmvtopr => vr_dtmvtopr         --> Próximo dia util
                                                       ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                                       ,pr_cdagenci => vr_cdagenci_par     --> Código da agência
                                                       ,pr_nrdcaixa => vr_nrdcaixa_par     --> Número do caixa
                                                       ,pr_nrdconta => rw_crapass.nrdconta --> Nro da conta da aplicação RDCA
                                                       ,pr_nraplica => vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).nraplica --> Nro da aplicação RDCA
                                                       ,pr_vlsdrdca => vr_ger_vlsdrdca     --> Saldo da aplicação
                                                       ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicacao RDCA
                                                       ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                       ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                       ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                                       ,pr_txaplica => vr_txaplica         --> Taxa aplicada sob o empréstimo
                                                       ,pr_des_reto => vr_dscritic         --> OK ou NOK
                                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros

                 --Se retornou erro
                 IF vr_dscritic = 'NOK' THEN
                   -- Tenta buscar o erro no vetor de erro
                   IF vr_tab_erro.COUNT > 0 THEN
                     vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapass.nrdconta;
                   ELSE
                     vr_cdcritic:= 0;
                     vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta;
                   END IF;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                 END IF;

                 --Se a quantidade for negativa pula
                 IF vr_ger_vlsdrdca > 0 THEN
                   --Acumular saldo total aplicacao
                   vr_vlsldrda:= Nvl(vr_vlsldrda,0) + Nvl(vr_ger_vlsdrdca,0);
                 END IF;

               ELSIF vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).tpaplica = 5 THEN
                 --Inicializar variavel de retorno
                 vr_ger_vlsdrdca:= 0;
                 -- Executar Rotina de calculo do aniversario do RDCA2 (Antiga includes/rdca2c.i)
                 APLI0001.pc_calc_aniver_rdca2c (pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                ,pr_dtmvtolt => vr_dtmvtolt         --> Data do processo
                                                ,pr_nrdconta => rw_crapass.nrdconta --> Nro da conta da aplicação RDCA
                                                ,pr_nraplica => vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).nraplica --> Nro da aplicação RDCA
                                                ,pr_vlsdrdca => vr_ger_vlsdrdca     --> Saldo da aplicação pós cálculo
                                                ,pr_des_erro => vr_dscritic);       --> Saida com com erros;

                 --Se retornou erro
                 IF vr_dscritic IS NOT NULL THEN
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                 END IF;

                 --Acumular saldo total aplicacao
                 vr_vlsldrda:= Nvl(vr_vlsldrda, 0) + Nvl(vr_ger_vlsdrdca, 0);
               ELSE
                 --Selecionar os tipos de captação
                 IF NOT vr_tab_crapdtc.EXISTS(vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).tpaplica) THEN
                   vr_cdcritic:= 346;
                   --Descricao do erro recebe mensagam da critica
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                   --Complementar a msg erro
                   vr_des_compl:= ' Conta/dv: '||gene0002.fn_mask_conta(rw_crapass.nrdconta)||
                                  ' Nr.Aplicacao: '||vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).nraplica;
                   -- Envio centralizado de log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| vr_dscritic || vr_des_compl);
                   --Pular registro
                   RAISE vr_exc_pula;
                 ELSE
                   --Acumular saldo total aplicacao
                   vr_vlsldrdc:= Nvl(vr_vlsldrdc,0) + Nvl(vr_tab_craprda(rw_crapass.nrdconta).tab_craprda(vr_ind_rda).vlsltxmx,0);
                 END IF;
               END IF;
             EXCEPTION
               WHEN vr_exc_pula THEN NULL;
             END;
             vr_ind_rda := vr_tab_craprda(rw_crapass.nrdconta).tab_craprda.next(vr_ind_rda);
           END LOOP; --rw_craprda
         END IF; -- Existe aplicacao

         IF vr_tab_craprac.EXISTS(rw_crapass.nrdconta) THEN
					 --Acumular saldo total aplicacao
           vr_vlsldrdc := Nvl(vr_vlsldrdc, 0) + vr_tab_craprac(rw_crapass.nrdconta).vlsldatl;
				 END IF;

         --Zerar valor poupanca
         vr_vlsdpoup:= 0;
         --Selecionar todas as poupancas
         FOR rw_craprpp IN cr_craprpp (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta) LOOP
           --Zerar valor poupanca
           vr_vlsdrdpp:= 0;
           --Executar rotina calcula poupanca programada
           APLI0001.pc_calc_poupanca (pr_cdcooper  => pr_cdcooper          --> Cooperativa
                                     ,pr_dstextab  => vr_dstextab          --> Percentual de IR da aplicação
                                     ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                     ,pr_inproces  => rw_crapdat.inproces  --> Indicador do processo
                                     ,pr_dtmvtolt  => vr_dtmvtolt          --> Data do processo
                                     ,pr_dtmvtopr  => vr_dtmvtopr          --> Próximo dia útil
                                     ,pr_rpp_rowid => rw_craprpp.rowid     --> Identificador do registro da tabela CRAPRPP em processamento
                                     ,pr_inpessoa  => rw_craprpp.inpessoa
                                     ,pr_nrcpfcgc  => rw_craprpp.nrcpfcgc
                                     ,pr_vlsdrdpp  => vr_vlsdrdpp          --> Saldo da poupança programada
                                     ,pr_cdcritic  => vr_cdcritic          --> Codigo da Critica
                                     ,pr_des_erro  => vr_dscritic);        --> Retorno do erro

           --Se ocorreu erro
           IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Acumular valor do saldo da poupanca
           vr_vlsdpoup:= Nvl(vr_vlsdpoup,0) + Nvl(vr_vlsdrdpp,0);
         END LOOP;

         -- Saldo total aplicacao recebe saldo rdca + rdc pre + poupanca
         vr_vlsldapl_2:= Nvl(vr_vlsldrda,0) + Nvl(vr_vlsldrdc,0) + Nvl(vr_vlsdpoup,0);

         --Encontrar o saldo da aplicacao do associado
         IF NOT vr_tab_crapsld.EXISTS(rw_crapass.nrdconta) THEN
           vr_cdcritic:= 10;
           --Descricao do erro recebe mensagam da critica
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Abortar programa
           RAISE vr_exc_erro;
         ELSE
           --Acumular valor saldo depositado
           --Saldo disponivel + bloqueado + bloq. da praca + bloq. fora praca + cheque salário
           vr_vlslddep:= Nvl(vr_tab_crapsld(rw_crapass.nrdconta),0);
         END IF;

         --Somatoria do saldo recebe saldo aplicado mais depositado
         vr_vlsldsom:= Nvl(vr_vlsldapl_2,0) + Nvl(vr_vlslddep,0);

         --Se o somatorio nao for zero
         IF Nvl(vr_vlsldsom,0) > 0 THEN
           --Inicializar codigo da empresa
           vr_cdempres:= NULL;
           --Se for pessoa fisica
           IF rw_crapass.inpessoa = 1 THEN
             --Verificar se a conta existe na tabela de memória
             IF vr_tab_crapttl.EXISTS(rw_crapass.nrdconta) THEN
               vr_cdempres:= vr_tab_crapttl(rw_crapass.nrdconta);
             END IF;
           ELSE
             --Selecionar informacoes pessoa juridica
             FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapass.nrdconta) LOOP
               --Determinar codigo da empresa
               vr_cdempres:= rw_crapjur.cdempres;
             END LOOP;
           END IF;
           --Encontrar o indice da tabela de memoria para ordenar pelo maior saldo
           vr_index_salva:= LPad(99999999999999999999 - Nvl(vr_vlsldsom,0),20,'0')||LPad(rw_crapass.nrdconta,10,'0');
           --Criar registro na tabela de memoria
           vr_tab_salva(vr_index_salva).nrdconta:= rw_crapass.nrdconta;
           vr_tab_salva(vr_index_salva).cdagenci:= rw_crapass.cdagenci;
           vr_tab_salva(vr_index_salva).cdempres:= vr_cdempres;
           vr_tab_salva(vr_index_salva).nrmatric:= rw_crapass.nrmatric;
           vr_tab_salva(vr_index_salva).nmprimtl:= rw_crapass.nmprimtl;
           vr_tab_salva(vr_index_salva).vlsldsom:= Nvl(vr_vlsldsom,0);
           vr_tab_salva(vr_index_salva).vlslddep:= Nvl(vr_vlslddep,0);
           vr_tab_salva(vr_index_salva).vlsldapl:= Nvl(vr_vlsldapl_2,0);
         END IF;
       END LOOP; --rw_crapass

       --Executar procedure geração relatorio 100 maiores depositantes
       pc_imprime_crrl274 (pr_des_erro => vr_dscritic);
       --Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_erro;
       END IF;
       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;
     EXCEPTION
       WHEN vr_exc_fimprg THEN

         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

         -- Se foi gerada critica para envio ao log
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic );
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
         pr_dscritic := SQLERRM;
     END;
   END pc_crps323;
/
