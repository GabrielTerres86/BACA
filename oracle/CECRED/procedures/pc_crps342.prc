CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS342" (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                         ,pr_flgresta  IN PLS_INTEGER           --> Flag para indicar restart
                                         ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN

/* .............................................................................

   Programa: pc_crps342                        Antigo: Fontes/crps342.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003                        Ultima atualizacao: 06/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Liberar cheques descontados.
               Emite relatorio 288.

   Alteracoes: 13/10/2003 - Compor o saldo contabil (Edson).

               28/10/2003 - Retirado use-index crapcbd(Mirtes).

               11/12/2003 - Ajuste na composicao do saldo contabil (Edson).

               30/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               13/10/2005 - Alterada critica com problemas(Mirtes)

               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               19/08/2008 - Tratar pracas de compensacao (Magui).

               15/03/2012 - Ajuste para nao dar o "RETURN" quando cdcritic = 695
                            e a descricao desta, sera mostrada no crrl288
                            atraves da "OBS." (Adriano).

               27/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

               19/08/2013 - Conversão Progress -> Oracle - Alisson (AMcom)
               
               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)
               
               06/06/2014 - #6850 - Aumento do tamanho do varchar de vr_res_dschqcop para 29
                            pois nmrescop aumentou para 20 (Carlos)
               
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps342 */

       TYPE typ_reg_craprej IS
         RECORD (cdpesqbb VARCHAR2(10)
                ,dtmvtolt DATE
                ,nrdconta INTEGER
                ,qtproces INTEGER
                ,vlproces NUMBER
                ,qtresgat INTEGER
                ,vlresgat NUMBER
                ,qtcredit INTEGER
                ,vlcredit NUMBER
                ,qtcontra INTEGER
                ,vlcontra NUMBER
                ,cdcooper INTEGER);

       TYPE typ_reg_crapass IS
         RECORD (cdsitdtl crapass.cdsitdtl%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE);

       --Definicao do tipo de registro para tabela memoria saldo medio
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       TYPE typ_tab_craprej IS TABLE OF typ_reg_craprej INDEX BY VARCHAR2(10);
       TYPE typ_tab_crapage IS TABLE OF crapage.cdcomchq%type INDEX BY PLS_INTEGER;

       --Definicao das tabelas de memoria
       vr_tab_crapass  typ_tab_crapass;
       vr_tab_crapage  typ_tab_crapage;
       vr_tab_craprej  typ_tab_craprej;

       /* Cursores da rotina crps342 */

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
       CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT /*+ INDEX (crapass crapass##crapass6) */
                crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.inpessoa
               ,crapass.cdsitdtl
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Selecionar todas as agencias da cooperativa
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT  crapage.cdagenci
                ,crapage.nmresage
                ,crapage.cdcomchq
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper;

       --Selecionar Cheques Descontados
       CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%type
                         ,pr_dtmvtolt IN crapcdb.dtlibera%type
                         ,pr_dtmvtopr IN crapcdb.dtlibera%type) IS
         SELECT crapcdb.nrdconta
               ,crapcdb.nrdocmto
               ,crapcdb.dtmvtolt
               ,crapcdb.cdagenci
               ,crapcdb.cdbccxlt
               ,crapcdb.nrdolote
               ,crapcdb.inchqcop
               ,crapcdb.insitchq
               ,crapcdb.cdcmpchq
               ,crapcdb.cdbanchq
               ,crapcdb.cdagechq
               ,crapcdb.nrddigc1
               ,crapcdb.nrctachq
               ,crapcdb.nrddigc2
               ,crapcdb.nrcheque
               ,crapcdb.nrddigc3
               ,crapcdb.vlcheque
               ,crapcdb.dsdocmc7
               ,crapcdb.dtdevolu
               ,crapcdb.ROWID
               ,Count(1) OVER (PARTITION BY crapcdb.nrdconta) qtdreg
               ,Row_Number() OVER (PARTITION BY crapcdb.nrdconta
                                   ORDER BY crapcdb.nrdconta
                                           ,crapcdb.dtmvtolt
                                           ,crapcdb.cdagenci
                                           ,crapcdb.cdbccxlt
                                           ,crapcdb.nrdolote
                                           ,crapcdb.cdcmpchq
                                           ,crapcdb.cdbanchq
                                           ,crapcdb.cdagechq
                                           ,crapcdb.nrctachq
                                           ,crapcdb.nrcheque) nrseqreg
         FROM crapcdb
         WHERE crapcdb.cdcooper  = pr_cdcooper
         AND   crapcdb.dtlibera  > pr_dtmvtolt
         AND   crapcdb.dtlibera  <= pr_dtmvtopr
         AND   crapcdb.dtlibbdc IS NOT NULL;

       --Selecionar Cheques Descontados
       CURSOR cr_crapcdb1 (pr_cdcooper IN crapcdb.cdcooper%type
                          ,pr_dtmvtolt IN crapcdb.dtlibera%type
                          ,pr_dtmvtoan IN crapcdb.dtlibera%type) IS
         SELECT /*+ INDEX (crapcdb crapcdb##crapcdb6) */
                crapcdb.nrdconta
               ,crapcdb.nrdocmto
               ,crapcdb.dtmvtolt
               ,crapcdb.cdagenci
               ,crapcdb.cdbccxlt
               ,crapcdb.nrdolote
               ,crapcdb.inchqcop
               ,crapcdb.insitchq
               ,crapcdb.cdcmpchq
               ,crapcdb.cdbanchq
               ,crapcdb.cdagechq
               ,crapcdb.nrddigc1
               ,crapcdb.nrctachq
               ,crapcdb.nrddigc2
               ,crapcdb.nrcheque
               ,crapcdb.nrddigc3
               ,crapcdb.vlcheque
               ,crapcdb.dsdocmc7
               ,crapcdb.dtdevolu
               ,crapcdb.dtlibera
               ,crapcdb.dtlibbdc
         FROM crapcdb
         WHERE crapcdb.cdcooper  = pr_cdcooper
         AND   crapcdb.dtlibbdc IS NOT NULL
         AND (crapcdb.dtdevolu >= pr_dtmvtolt OR
              crapcdb.dtlibera >  pr_dtmvtoan OR
              crapcdb.dtlibbdc <= pr_dtmvtolt);


       --Variaveis Locais
       vr_tab_vlchqmai NUMBER;
       vr_dtchqfpr     DATE;
       vr_dtchqmai     DATE;
       vr_dtchqmen     DATE;
       vr_dtferiado    DATE;
       vr_nrdconta     INTEGER;
       vr_nrdocmto     INTEGER;
       vr_nrdepcrh     INTEGER;
       vr_nrdepmen     INTEGER;
       vr_nrdepmai     INTEGER;
       vr_nrdepfpr     INTEGER;
       vr_contador     INTEGER;
       vr_nmprimtl     VARCHAR2(100);
       vr_tot_qtproces INTEGER;
       vr_tot_qtresgat INTEGER;
       vr_tot_qtchqcrh INTEGER;
       vr_tot_qtchqmai INTEGER;
       vr_tot_qtchqmen INTEGER;
       vr_tot_qtchqfpr INTEGER;
       vr_tot_qtcontra INTEGER;
       vr_tot_vlproces NUMBER;
       vr_tot_vlresgat NUMBER;
       vr_tot_vlchqcrh NUMBER;
       vr_tot_vlchqmai NUMBER;
       vr_tot_vlchqmen NUMBER;
       vr_tot_vlchqfpr NUMBER;
       vr_tot_vlcontra NUMBER;
       vr_tot_qtchqcop INTEGER;
       vr_tot_qtchqban INTEGER;
       vr_tot_qtchqdev INTEGER;
       vr_tot_qtcheque INTEGER;
       vr_tot_qtcredit INTEGER;
       vr_tot_qtsldant INTEGER;
       vr_tot_qtlibera INTEGER;
       vr_tot_vlchqcop NUMBER;
       vr_tot_vlchqban NUMBER;
       vr_tot_vlchqdev NUMBER;
       vr_tot_vlcheque NUMBER;
       vr_tot_vlcredit NUMBER;
       vr_tot_vlsldant NUMBER;
       vr_tot_vllibera NUMBER;
       vr_res_dschqcop VARCHAR2(29);
       vr_cdpesqbb     VARCHAR2(200);
       vr_dscobser     VARCHAR2(65);
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;
       vr_dscritic     VARCHAR2(4000);

       --Variaveis de Controle de Restart
       vr_nrctares  INTEGER:= 0;
       vr_inrestar  INTEGER:= 0;
       vr_dsrestar  crapres.dsrestar%TYPE;

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_craprej VARCHAR2(10);
       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis para retorno de erro
       vr_dstextab_cheque craptab.dstextab%TYPE;

       --Variaveis de Excecao
       vr_exc_saida EXCEPTION;
       --vr_exc_fim   EXCEPTION;
       --vr_exc_pula  EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapass.DELETE;
         vr_tab_crapage.DELETE;
         vr_tab_craprej.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps342.pc_limpa_tabela. '||sqlerrm;
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
     -- Inicio Bloco Principal pc_crps342
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS342';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS342'
                                 ,pr_action => NULL);

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1 -- Fixo
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       -- Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

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

       -- Verifica se a data esta cadastrada
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
       END IF;

       --Montar descricao cheque cooperativa
       vr_res_dschqcop:= 'CHEQUES '|| SUBSTR(rw_crapcop.nmrescop,1,20)||':';

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela memoria associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).cdsitdtl:= rw_crapass.cdsitdtl;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
       END LOOP;

       --Carregar tabela memoria agencias cheque
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapage(rw_crapage.cdagenci):= rw_crapage.cdcomchq;
       END LOOP;

       --Buscar parametro maiores cheques
       vr_dstextab_cheque:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_tptabela => 'USUARI'
                                                      ,pr_cdempres => 11
                                                      ,pr_cdacesso => 'MAIORESCHQ'
                                                      ,pr_tpregist => 1);
       --Se nao encontrou
       IF vr_dstextab_cheque IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 55;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         vr_dscritic:= vr_dscritic||' CRED-USUARI-11-MAIORESCHQ-001';
         RAISE vr_exc_saida;
       ELSE
         --Valor maior cheque
         vr_tab_vlchqmai:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab_cheque,1,15));
       END IF;

       /* Tratamento e retorno de valores de restart */
       BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_flgresta => pr_flgresta
                                 ,pr_nrctares => vr_nrctares
                                 ,pr_dsrestar => vr_dsrestar
                                 ,pr_inrestar => vr_inrestar
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_dscritic);
       --Se ocrreu erro na validacao do restart
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       -- Busca do diretório base da cooperativa
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl288';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl288><contas>');

       --Data Cheque fora praca
       vr_dtchqfpr:= rw_crapdat.dtmvtopr;

       WHILE TRUE LOOP
         --Incrementar 1 dia
         vr_dtchqfpr:= vr_dtchqfpr + 1;

         --Verifica se é feriado
         vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => vr_dtchqfpr
                                                   ,pr_tipo     => 'P');
         --Data diferente significa feriado
         IF vr_dtferiado != vr_dtchqfpr THEN
           --Pular
           CONTINUE;
         END IF;

         --Incrementar contador
         vr_contador:= nvl(vr_contador,0)+1;

         --Contador igual 1
         IF vr_contador = 1 THEN
           --Data Cheques Maiores recebe Data fora praca
           vr_dtchqmai:= vr_dtchqfpr;
         ELSE
           IF vr_contador = 2 THEN
             --Data Cheques menores recebe fora praca
             vr_dtchqmen:= vr_dtchqfpr;
           ELSE
             EXIT;
           END IF;
         END IF;
       END LOOP;

       --Marcador para controle loop
       <<loop_crapcdb>>
       --Selecionar Boletos Cobranca
       FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper  => pr_cdcooper
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtopr  => rw_crapdat.dtmvtopr) LOOP
         BEGIN
           --Savepoint para desfazer ultima transacao
           SAVEPOINT sv_crapcdb;

           --Inicializar Observacao
           vr_dscobser:= NULL;
           vr_cdcritic:= 0;

           --Se for primeiro registro da conta (first-of)
           IF rw_crapcdb.nrseqreg = 1 THEN
             --Documento esta preenchido
             IF rw_crapcdb.nrdocmto > 0 THEN
               vr_nrdocmto:= TO_NUMBER(vr_dsrestar);
             ELSE
               --Obtem numero randomico
               vr_nrdocmto:= Trunc(DBMS_RANDOM.Value(50000,99999));
             END IF;

             --Determinar numero deposito para cheque/menor/maior/fora praca
             vr_nrdepcrh:= vr_nrdocmto + 100000;
             vr_nrdepmen:= vr_nrdocmto + 200000;
             vr_nrdepmai:= vr_nrdocmto + 300000;
             vr_nrdepfpr:= vr_nrdocmto + 400000;

             --Determinar Conta
             vr_nrdconta:= rw_crapcdb.nrdconta;
             --Zerar Critica
             vr_cdcritic:= 0;

             --Verificar se associado existe
             IF NOT vr_tab_crapass.EXISTS(vr_nrdconta) THEN
               vr_cdcritic:= 9;
             ELSIF vr_tab_crapass(vr_nrdconta).cdsitdtl IN (5,6,7,8) THEN
               vr_cdcritic:= 695;
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               vr_dscritic:= vr_dscritic || gene0002.fn_mask_conta(vr_nrdconta);
             END IF;

             --Se existir critica e nao for erro 95
             IF vr_cdcritic = 9 THEN
               --Levantar Excecao
               RAISE vr_exc_saida;
             ELSIF vr_cdcritic = 695 THEN
               --Escrever erro no log
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 3 --
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || vr_dscritic);
               -- Concatenar erro na observacao
               vr_dscobser:= 'OBS.: ' ||SUBSTR(vr_dscritic,(INSTR(vr_dscritic,'!')+ 1),LENGTH(vr_dscritic));
             END IF;

             --Inicializar variaveis
             vr_nmprimtl:= vr_tab_crapass(vr_nrdconta).nmprimtl;
             vr_tot_qtproces:= 0;
             vr_tot_vlproces:= 0;
             vr_tot_qtresgat:= 0;
             vr_tot_vlresgat:= 0;
             vr_tot_qtcontra:= 0;
             vr_tot_vlcontra:= 0;
             vr_tot_qtchqcrh:= 0;
             vr_tot_vlchqcrh:= 0;
             vr_tot_qtchqmai:= 0;
             vr_tot_vlchqmai:= 0;
             vr_tot_qtchqmen:= 0;
             vr_tot_vlchqmen:= 0;
             vr_tot_qtchqfpr:= 0;
             vr_tot_vlchqfpr:= 0;
             vr_tot_vlcredit:= 0;
             vr_tot_qtcredit:= 0;

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta dtmvtopr="'||To_Char(rw_crapdat.dtmvtopr,'DD/MM/YYYY')||'" nrdconta="'||
               gene0002.fn_mask_conta(vr_nrdconta)||'" nmprimtl="'||vr_nmprimtl||'" dscobser="'||
               vr_dscobser||'"><lancamentos>');
           END IF; --(first-of)

           --Montar Codigo Pesquisa
           vr_cdpesqbb:= TO_CHAR(rw_crapcdb.dtmvtolt,'DD/MM/YYYY') ||'-'||
                         GENE0002.fn_mask(rw_crapcdb.cdagenci,'999')||'-'||
                         GENE0002.fn_mask(rw_crapcdb.cdbccxlt,'999')||'-'||
                         GENE0002.fn_mask(rw_crapcdb.nrdolote,'999999');

           --Se nao for cheque cooperativa
           IF rw_crapcdb.inchqcop <> 1 THEN
             --Montar tag da conta para arquivo XML
             pc_escreve_xml
             ('<lancto>
                <cdpesqbb>'||SubStr(vr_cdpesqbb,1,25)||'</cdpesqbb>
                <cdcmpchq>'||gene0002.fn_mask(rw_crapcdb.cdcmpchq,'ZZ9')||'</cdcmpchq>
                <cdbanchq>'||gene0002.fn_mask(rw_crapcdb.cdbanchq,'ZZ9')||'</cdbanchq>
                <cdagechq>'||gene0002.fn_mask(rw_crapcdb.cdagechq,'9999')||'</cdagechq>
                <nrddigc1>'||gene0002.fn_mask(rw_crapcdb.nrddigc1,'9')||'</nrddigc1>
                <nrctachq>'||gene0002.fn_mask(rw_crapcdb.nrctachq,'999.999.999.9')||'</nrctachq>
                <nrddigc2>'||gene0002.fn_mask(rw_crapcdb.nrddigc2,'9')||'</nrddigc2>
                <nrcheque>'||gene0002.fn_mask(rw_crapcdb.nrcheque,'999.999')||'</nrcheque>
                <nrddigc3>'||gene0002.fn_mask(rw_crapcdb.nrddigc3,'9')||'</nrddigc3>
                <vlcheque>'||To_Char(rw_crapcdb.vlcheque,'999g999g990d00')||'</vlcheque>
                <dsdocmc7><![CDATA['||SubStr(rw_crapcdb.dsdocmc7,1,34)||']]></dsdocmc7>
                <dtdevolu>'||To_Char(rw_crapcdb.dtdevolu,'DD/MM/YYYY')||'</dtdevolu>
              </lancto>');
           END IF;

           --Incrementar quantidade processos
           vr_tot_qtproces:= Nvl(vr_tot_qtproces,0) + 1;
           --Acumular valor processos
           vr_tot_vlproces:= Nvl(vr_tot_vlproces,0) + rw_crapcdb.vlcheque;

           --Verificar se a agencia existe
           IF NOT vr_tab_crapage.EXISTS(rw_crapcdb.cdagenci) THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Agencia nao encontrada.';
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;

           --Verificar Situacao 0=Nao processado/2=processado/4=
           IF rw_crapcdb.insitchq IN (0,2,4) THEN
             --Cheque da cooperativa e nao processado
             IF rw_crapcdb.inchqcop = 1 AND rw_crapcdb.insitchq = 0 THEN
               --Montar Critica
               vr_cdcritic:= 684;
               --Levantar Excecao
               RAISE vr_exc_saida;
             ELSE
               --Incrementar total credito
               vr_tot_qtcredit:= Nvl(vr_tot_qtcredit,0) + 1;
               --Acumular total cheque
               vr_tot_vlcredit:= Nvl(vr_tot_vlcredit,0) + rw_crapcdb.vlcheque;
               --Atualizar situacao cheque para processado
               rw_crapcdb.insitchq:= 2;
               --Se for cheque da cooperativa
               IF rw_crapcdb.inchqcop = 1 THEN
                 --Incrementa Quantidade cheque
                 vr_tot_qtchqcrh:= Nvl(vr_tot_qtchqcrh,0) + 1;
                 --Incrementa Valor Cheque
                 vr_tot_vlchqcrh:= Nvl(vr_tot_vlchqcrh,0) + rw_crapcdb.vlcheque;
                 --Atualizar documento cheque
                 rw_crapcdb.nrdocmto:= vr_nrdepcrh;
               ELSE
                 --Codigo conpensacao igual agencia
                 IF rw_crapcdb.cdcmpchq = vr_tab_crapage(rw_crapcdb.cdagenci) THEN
                   --Valor Cheque maior cheques maiores
                   IF rw_crapcdb.vlcheque >= vr_tab_vlchqmai THEN
                     --incrementar cheques maiores
                     vr_tot_qtchqmai:= Nvl(vr_tot_qtchqmai,0) + 1;
                     --Incrementar valores cheques maiores
                     vr_tot_vlchqmai:= Nvl(vr_tot_vlchqmai,0) + rw_crapcdb.vlcheque;
                     --Atualizar documento cheque
                     rw_crapcdb.nrdocmto:= vr_nrdepmai;
                   ELSE
                     --incrementar cheques menores
                     vr_tot_qtchqmen:= Nvl(vr_tot_qtchqmen,0) + 1;
                     --Incrementar valores cheques menores
                     vr_tot_vlchqmen:= Nvl(vr_tot_vlchqmen,0) + rw_crapcdb.vlcheque;
                     --Atualizar documento cheque
                     rw_crapcdb.nrdocmto:= vr_nrdepmen;
                   END IF;
                 ELSE
                   --incrementar cheques fora praca
                   vr_tot_qtchqfpr:= Nvl(vr_tot_qtchqfpr,0) + 1;
                   --Incrementar valores cheques fora praca
                   vr_tot_vlchqfpr:= Nvl(vr_tot_vlchqfpr,0) + rw_crapcdb.vlcheque;
                   --Atualizar documento cheque
                   rw_crapcdb.nrdocmto:= vr_nrdepfpr;
                 END IF;
               END IF;
             END IF;
             --Atualizar tabela crapcdb
             BEGIN
               UPDATE crapcdb SET crapcdb.nrdocmto = rw_crapcdb.nrdocmto
                                 ,crapcdb.insitchq = rw_crapcdb.insitchq
               WHERE crapcdb.ROWID = rw_crapcdb.ROWID;
             EXCEPTION
               WHEN Others THEN
                 vr_cdcritic:= 0;
                 vr_dscritic:= 'Erro ao atualizar tabela crapcdb. '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_saida;
             END;
           ELSE
             --Resgatados
             IF rw_crapcdb.insitchq = 1 THEN
               --Diminuir cheques descontados
               vr_tot_qtresgat:= Nvl(vr_tot_qtresgat,0) - 1;
               --Diminuir valores descontados
               vr_tot_vlresgat:= Nvl(vr_tot_vlresgat,0) - rw_crapcdb.vlcheque;
             ELSIF rw_crapcdb.insitchq = 3 THEN
               --Diminuir cheques contra
               vr_tot_qtcontra:= Nvl(vr_tot_qtcontra,0) - 1;
               --Diminuir valores contra
               vr_tot_vlcontra:= Nvl(vr_tot_vlcontra,0) - rw_crapcdb.vlcheque;
             END IF;
           END IF;

           --Se for ultimo registro da conta (last-of)
           IF rw_crapcdb.nrseqreg = rw_crapcdb.qtdreg THEN

             --Finaliza tag lancamentos
             pc_escreve_xml('</lancamentos>');

             --Montar informacoes do total da conta
             pc_escreve_xml
             ('<tot_qtproces>'|| To_Char(vr_tot_qtproces,'999g990')||'</tot_qtproces>
               <tot_vlproces>'|| To_Char(vr_tot_vlproces,'999g999g999g990d00')||'</tot_vlproces>
               <tot_qtresgat>'|| To_Char(vr_tot_qtresgat,'999g990')||'</tot_qtresgat>
               <tot_vlresgat>'|| To_Char(vr_tot_vlresgat,'999g999g999g990d00')||'</tot_vlresgat>
               <tot_qtcontra>'|| To_Char(vr_tot_qtcontra,'999g990')||'</tot_qtcontra>
               <tot_vlcontra>'|| To_Char(vr_tot_vlcontra,'999g999g999g990d00')||'</tot_vlcontra>
               <tot_qtchqcrh>'|| To_Char(vr_tot_qtchqcrh,'999g990')||'</tot_qtchqcrh>
               <tot_vlchqcrh>'|| To_Char(vr_tot_vlchqcrh,'999g999g999g990d00')||'</tot_vlchqcrh>
               <tot_qtchqmai>'|| To_Char(vr_tot_qtchqmai,'999g990')||'</tot_qtchqmai>
               <tot_vlchqmai>'|| To_Char(vr_tot_vlchqmai,'999g999g999g990d00')||'</tot_vlchqmai>
               <aux_dtchqmai>'|| To_Char(vr_dtchqmai,'DD/MM/YYYY')||'</aux_dtchqmai>
               <tot_qtchqmen>'|| To_Char(vr_tot_qtchqmen,'999g990')||'</tot_qtchqmen>
               <tot_vlchqmen>'|| To_Char(vr_tot_vlchqmen,'999g999g999g990d00')||'</tot_vlchqmen>
               <aux_dtchqmen>'|| To_Char(vr_dtchqmen,'DD/MM/YYYY')||'</aux_dtchqmen>
               <tot_qtchqfpr>'|| To_Char(vr_tot_qtchqfpr,'999g990')||'</tot_qtchqfpr>
               <tot_vlchqfpr>'|| To_Char(vr_tot_vlchqfpr,'999g999g999g990d00')||'</tot_vlchqfpr>
               <aux_dtchqfpr>'|| To_Char(vr_dtchqfpr,'DD/MM/YYYY')||'</aux_dtchqfpr>
               <tot_qtcredit>'|| To_Char(vr_tot_qtcredit,'999g990')||'</tot_qtcredit>
               <tot_vlcredit>'|| To_Char(vr_tot_vlcredit,'999g999g999g990d00')||'</tot_vlcredit>
               <res_dschqcop>'|| vr_res_dschqcop||'</res_dschqcop>');

             --Montar tag para finalizar conta
             pc_escreve_xml('</conta>');

             --Montar indice para rejeicao
             vr_index_craprej:= LPad(vr_nrdconta,10,'0');
             --Criar registro de rejeicao
             vr_tab_craprej(vr_index_craprej).cdcooper := pr_cdcooper;
             vr_tab_craprej(vr_index_craprej).cdpesqbb := 'crps342';
             vr_tab_craprej(vr_index_craprej).dtmvtolt := rw_crapdat.dtmvtolt;
             vr_tab_craprej(vr_index_craprej).nrdconta := vr_nrdconta;
             vr_tab_craprej(vr_index_craprej).qtproces := vr_tot_qtproces;
             vr_tab_craprej(vr_index_craprej).vlproces := vr_tot_vlproces;
             vr_tab_craprej(vr_index_craprej).qtresgat := vr_tot_qtresgat;
             vr_tab_craprej(vr_index_craprej).vlresgat := vr_tot_vlresgat;
             vr_tab_craprej(vr_index_craprej).qtcredit := vr_tot_qtcredit;
             vr_tab_craprej(vr_index_craprej).vlcredit := vr_tot_vlcredit;
             vr_tab_craprej(vr_index_craprej).qtcontra := vr_tot_qtcontra;
             vr_tab_craprej(vr_index_craprej).vlcontra := vr_tot_vlcontra;

             -- Atualizar restart se a flag estiver ativa
             IF pr_flgresta = 1 THEN
               BEGIN
                 --Atualizar tabela de restart
                 UPDATE crapres SET crapres.nrdconta = rw_crapcdb.nrdconta
                                   ,crapres.dsrestar = vr_nrdocmto
                 WHERE crapres.cdcooper = pr_cdcooper
                 AND   crapres.cdprogra = vr_cdprogra;
               EXCEPTION
                 WHEN Others THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela crapres. '||SQLERRM;
                   --Levantar Excecao
                   RAISE vr_exc_saida;
               END;
               --Salvar registro
               COMMIT;
             END IF;
           END IF; --(last-of)
         EXCEPTION
           WHEN OTHERS THEN
             --Desfazer ultima transacao
             ROLLBACK to sv_crapcdb;
             --Sair Programa
             RAISE vr_exc_saida;
         END;
       END LOOP; --rw_crapcdb

       --Montar tag para finalizar contas e iniciar rejeitados
       pc_escreve_xml('</contas><rejeitados>');

       --Percorrer rejeitados
       vr_index_craprej:= vr_tab_craprej.FIRST;
       WHILE vr_index_craprej IS NOT NULL LOOP
         --Montar tag da conta rejeitada para arquivo XML
         pc_escreve_xml
          ('<rejeitado>
              <nrdconta>'||gene0002.fn_mask_conta(vr_tab_craprej(vr_index_craprej).nrdconta)||'</nrdconta>
              <qtproces>'||To_Char(vr_tab_craprej(vr_index_craprej).qtproces,'fm999g990')||'</qtproces>
              <vlproces>'||To_Char(vr_tab_craprej(vr_index_craprej).vlproces,'fm999g999g999g990d00')||'</vlproces>
              <qtresgat>'||To_Char(vr_tab_craprej(vr_index_craprej).qtresgat,'fm999g990')||'</qtresgat>
              <vlresgat>'||To_Char(vr_tab_craprej(vr_index_craprej).vlresgat,'fm999g999g999g990d00')||'</vlresgat>
              <qtcontra>'||To_Char(vr_tab_craprej(vr_index_craprej).qtcontra,'fm999g990')||'</qtcontra>
              <vlcontra>'||To_Char(vr_tab_craprej(vr_index_craprej).vlcontra,'fm999g999g999g990d00')||'</vlcontra>
              <qtcredit>'||To_Char(vr_tab_craprej(vr_index_craprej).qtcredit,'fm999g990')||'</qtcredit>
              <vlcredit>'||To_Char(vr_tab_craprej(vr_index_craprej).vlcredit,'fm999g999g999g990d00')||'</vlcredit>
            </rejeitado>');
         --Proximo registro do vetor
         vr_index_craprej:= vr_tab_craprej.NEXT(vr_index_craprej);
       END LOOP;

       --Montar tag para finalizar rejeitados
       pc_escreve_xml('</rejeitados>');

       /*  Saldo contabil  */

       --Zerar Variaveis saldo contabil
       vr_tot_qtchqcop:= 0;
       vr_tot_vlchqcop:= 0;
       vr_tot_qtchqban:= 0;
       vr_tot_vlchqban:= 0;
       vr_tot_qtcheque:= 0;
       vr_tot_vlcheque:= 0;
       vr_tot_qtchqdev:= 0;
       vr_tot_vlchqdev:= 0;
       vr_tot_qtlibera:= 0;
       vr_tot_vllibera:= 0;
       vr_tot_qtsldant:= 0;
       vr_tot_vlsldant:= 0;

       --Leitura dos cheques descontados
       FOR rw_crapcdb IN cr_crapcdb1 (pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP

         --Verificar se deve descartar registro
         IF rw_crapcdb.dtdevolu < rw_crapdat.dtmvtolt OR
            rw_crapcdb.dtlibera <= rw_crapdat.dtmvtoan OR
            rw_crapcdb.dtlibbdc >  rw_crapdat.dtmvtolt THEN
           --Pular
           CONTINUE;
         END IF;

         --Data liberacao maior data movimento e devolucao nula
         IF rw_crapcdb.dtlibera > rw_crapdat.dtmvtolt AND rw_crapcdb.dtdevolu IS NULL THEN
           --Se for cheque cooperativa
           IF rw_crapcdb.inchqcop = 1 THEN
             --Incrementar Cheque cooperativa
             vr_tot_qtchqcop:= Nvl(vr_tot_qtchqcop,0) + 1;
             --Incrementar valor total cheque cooperativa
             vr_tot_vlchqcop:= Nvl(vr_tot_vlchqcop,0) + rw_crapcdb.vlcheque;
           ELSE
             --Incrementar Cheque Outros bancos
             vr_tot_qtchqban:= Nvl(vr_tot_qtchqban,0) + 1;
             --Incrementar valor total cheque outros bancos
             vr_tot_vlchqban:= Nvl(vr_tot_vlchqban,0) + rw_crapcdb.vlcheque;
           END IF;
         END IF;
         --Se for devolvido e data devolucao igual data movimento
         IF rw_crapcdb.dtdevolu IS NOT NULL AND rw_crapcdb.dtdevolu = rw_crapdat.dtmvtolt THEN
           --Diminuir Cheque Devolvido
           vr_tot_qtchqdev:= Nvl(vr_tot_qtchqdev,0) - 1;
           --Diminuir valor total cheque devolvido
           vr_tot_vlchqdev:= Nvl(vr_tot_vlchqdev,0) - rw_crapcdb.vlcheque;
         END IF;
         --Se data liberacao cheque for a mesma do movimento
         IF rw_crapcdb.dtlibbdc = rw_crapdat.dtmvtolt THEN
           --Incrementar total Cheques
           vr_tot_qtcheque:= Nvl(vr_tot_qtcheque,0) + 1;
           --Incrementar valor cheques
           vr_tot_vlcheque:= Nvl(vr_tot_vlcheque,0) + rw_crapcdb.vlcheque;
           --Proximo registro cursor
           CONTINUE;
         END IF;
         --Incrementar saldo anterior
         vr_tot_qtsldant:= Nvl(vr_tot_qtsldant,0) + 1;
         --Incrementar valor saldo anterior
         vr_tot_vlsldant:= Nvl(vr_tot_vlsldant,0) + rw_crapcdb.vlcheque;
         --Liberados
         IF rw_crapcdb.dtlibera > rw_crapdat.dtmvtoan  AND
            rw_crapcdb.dtlibera <= rw_crapdat.dtmvtolt AND
            rw_crapcdb.dtdevolu IS NULL THEN
           --Diminuir total liberado
           vr_tot_qtlibera:= Nvl(vr_tot_qtlibera,0) - 1;
           --Diminuir valor liberado
           vr_tot_vllibera:= Nvl(vr_tot_vllibera,0) - rw_crapcdb.vlcheque;
         END IF;
       END LOOP; --rw_crapcdb

       --Totalizadores quantidade creditos
       vr_tot_qtcredit:= Nvl(vr_tot_qtsldant,0) + Nvl(vr_tot_qtlibera,0) +
                         Nvl(vr_tot_qtcheque,0) + Nvl(vr_tot_qtchqdev,0);
       --Totalizador valores creditos
       vr_tot_vlcredit:= Nvl(vr_tot_vlsldant,0) + Nvl(vr_tot_vllibera,0) +
                         Nvl(vr_tot_vlcheque,0) + Nvl(vr_tot_vlchqdev,0);

       --Montar tag saldo contabil para arquivo XML
       pc_escreve_xml
          ('<saldo>
              <tot_dtmvtolt>'||To_Char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'</tot_dtmvtolt>
              <tot_dschqcop>'||vr_res_dschqcop||'</tot_dschqcop>
              <tot_qtsldant>'||To_Char(vr_tot_qtsldant,'fm999g990')||'</tot_qtsldant>
              <tot_vlsldant>'||To_Char(vr_tot_vlsldant,'fm999g999g990d00')||'</tot_vlsldant>
              <tot_qtlibera>'||To_Char(vr_tot_qtlibera,'fm999g990')||'</tot_qtlibera>
              <tot_vllibera>'||To_Char(vr_tot_vllibera,'fm999g999g990d00')||'</tot_vllibera>
              <tot_qtcheque>'||To_Char(vr_tot_qtcheque,'fm999g990')||'</tot_qtcheque>
              <tot_vlcheque>'||To_Char(vr_tot_vlcheque,'fm999g999g990d00')||'</tot_vlcheque>
              <tot_qtchqdev>'||To_Char(vr_tot_qtchqdev,'fm999g990')||'</tot_qtchqdev>
              <tot_vlchqdev>'||To_Char(vr_tot_vlchqdev,'fm999g999g990d00')||'</tot_vlchqdev>
              <tot_qtcredit>'||To_Char(vr_tot_qtcredit,'fm999g990')||'</tot_qtcredit>
              <tot_vlcredit>'||To_Char(vr_tot_vlcredit,'fm999g999g990d00')||'</tot_vlcredit>
              <tot_qtchqcop>'||To_Char(vr_tot_qtchqcop,'fm999g990')||'</tot_qtchqcop>
              <tot_vlchqcop>'||To_Char(vr_tot_vlchqcop,'fm999g999g990d00')||'</tot_vlchqcop>
              <tot_qtchqban>'||To_Char(vr_tot_qtchqban,'fm999g990')||'</tot_qtchqban>
              <tot_vlchqban>'||To_Char(vr_tot_vlchqban,'fm999g999g990d00')||'</tot_vlchqban>
            </saldo>');

       --Finalizar tags saldo contabil e relatorio
       pc_escreve_xml('</crrl288>');

       -- Efetuar solicitacao de geracao de relatorio crrl288 --
       gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl288'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl288.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Titulo do relatório
                                   ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                   --> Número de cópias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro
       -- Testar se houve erro
       IF vr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_saida;
       END IF;

       -- Liberando a memória alocada pro CLOB
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);

       /* Eliminacao dos registros de restart */
       BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_flgresta => pr_flgresta
                                  ,pr_des_erro => vr_dscritic);
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
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
   END pc_crps342;
/

