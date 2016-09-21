CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS432" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps432                        Antigo: fontes/crps432.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005                     Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal.

   Objetivo  : Atende a solicitacao 3.
               Ordem do programa na solicitacao 5.
               Relatorio 407 (CONTROLE DE LIMITES DE CARTOES DE CREDITO).

   Alteracoes: 21/03/2005 - Atualizacao do crawcrd.inanuida (Julio)

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               13/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               02/07/2013 - Alterado return no find da crapass para next e
                            incluso nrconta no log. (Daniel)

               28/08/2013 - Adequação Ajustes Progress - Alisson (AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)
                            
               30/08/2014 - Alterado o programa para que a critica 532 não encerre
                            a execução do programa, devendo apenas gerar uma 
                            mensagem no log.  ( Renato - Supero )
                            
               03/09/2014 - SoftDesk 195885 -> Com a entrada em Produção dos cartões do 
                            projeto 56 - Cartão Bancoob, não buscar registro na tabela 
                            craptlc para cartões vinculados às administradoras com código 
                            entre 10 e 80 e sim do campo crawcrd.vllimcrd. ( Renato - Supero )
                            
               01/11/2014 - Ajuste ao incrementar valores nas pltables, para iniciar primeiro, 
                            caso esteja vazia a fim de não dar erro de no-data-found (Odirlei-Amcom)
     ............................................................................. */

     DECLARE

       --Tipo de registro de associados
       TYPE typ_reg_crapass IS
         RECORD (nmprimtl crapass.nmprimtl%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,tpvincul crapass.tpvincul%TYPE);

       --Tipo de registro dos cartoes de credito
       TYPE typ_reg_crawcrd IS
         RECORD (cdcooper crawcrd.cdcooper%TYPE
                ,nrdconta crawcrd.nrdconta%TYPE
                ,nrctrcrd crawcrd.nrctrcrd%TYPE);

       --Tipo de tabela de memoria
       TYPE typ_tab_tot     IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_craptlc IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
       TYPE typ_tab_crapdcd IS TABLE OF NUMBER INDEX BY VARCHAR2(35);
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       TYPE typ_tab_crawcrd IS TABLE OF typ_reg_crawcrd INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapage IS TABLE OF crapage.nmresage%TYPE INDEX BY PLS_INTEGER;

       --Tabelaa de memoria
       vr_tab_qtaprova  typ_tab_tot;
       vr_tab_qtsolici  typ_tab_tot;
       vr_tab_qtlibera  typ_tab_tot;
       vr_tab_vllimite  typ_tab_tot;
       vr_tab_vldebito  typ_tab_tot;
       vr_tab_qtusando  typ_tab_tot;
       vr_tab_craptlc   typ_tab_craptlc;
       vr_tab_crapass   typ_tab_crapass;
       vr_tab_crapage   typ_tab_crapage;
       vr_tab_crapdcd   typ_tab_crapdcd;
       vr_tab_crawcrd   typ_tab_crawcrd;

       /* Cursores da rotina crps432 */

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
         SELECT crapass.cdagenci
               ,crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.inpessoa
               ,crapass.inisipmf
               ,crapass.nrcadast
               ,crapass.tpvincul
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Selecionar informacoes das agencias
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT crapage.cdagenci
               ,SubStr(crapage.nmresage,1,15) nmresage
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper
         AND   crapage.cdagenci < 99
         ORDER BY crapage.cdagenci;

       --Selecionar informacoes dos cadastros das adm cartao credito
       CURSOR cr_crapadc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapadc.cdadmcrd
               ,crapadc.nmresadm
         FROM crapadc
         WHERE crapadc.cdcooper = pr_cdcooper;

       --Selecionar informacoes do cadastro auxiliar cartoes credito
       CURSOR cr_crawcrd (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
         SELECT crawcrd.nrdconta
               ,crawcrd.insitcrd
               ,crawcrd.cdadmcrd
               ,crawcrd.tpcartao
               ,crawcrd.cdlimcrd
               ,crawcrd.nrcrcard
               ,crawcrd.nrctrcrd
               ,crawcrd.ROWID
               ,crawcrd.vllimcrd
         FROM crawcrd crawcrd
         WHERE crawcrd.cdcooper = pr_cdcooper
         AND   crawcrd.cdadmcrd = pr_cdadmcrd;

       --Carregar tabela de memoria de limite de cartao e dia debito
       CURSOR cr_craptlc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT craptlc.cdadmcrd
               ,craptlc.tpcartao
               ,craptlc.cdlimcrd
               ,craptlc.dddebito
               ,craptlc.vllimcrd
         FROM craptlc craptlc
         WHERE craptlc.cdcooper = pr_cdcooper
         AND   craptlc.dddebito = 0;

       --Selecionar debitos do cartao credito
       CURSOR cr_crapdcd (pr_cdcooper IN crapdcd.cdcooper%TYPE
                         ,pr_dtdebito IN crapdcd.dtdebito%TYPE) IS
         SELECT  crapdcd.nrdconta
                ,crapdcd.nrcrcard
                ,Nvl(Sum(Nvl(crapdcd.vldebito,0)),0) vldebito
         FROM crapdcd crapdcd
         WHERE crapdcd.cdcooper = pr_cdcooper
         AND   Trunc(crapdcd.dtdebito,'MM') = Trunc(pr_dtdebito,'MM')
         GROUP BY crapdcd.nrdconta,crapdcd.nrcrcard;

       --Variaveis Locais
       vr_cdagenci     INTEGER;
       vr_cdadmcrd     INTEGER;
       vr_dsmesano     VARCHAR2(30);
       vr_vllimcrd     crawcrd.vllimcrd%TYPE;

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS432';
       --Variaveis para retorno de erro
       vr_cdcritic     INTEGER;
       vr_dscritic     VARCHAR2(4000);


       --Variaveis do indice
       vr_index_craptlc  VARCHAR2(30);
       vr_index_crapdcd  VARCHAR2(35);
       vr_index_crapage  INTEGER;
       vr_index_crawcrd  INTEGER;

	     -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;
       vr_exc_fimprg exception;

       -- Variavel de controle
       vr_existe    BOOLEAN;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapass.DELETE;
         vr_tab_craptlc.DELETE;
         vr_tab_crapage.DELETE;
         vr_tab_crapdcd.DELETE;
         vr_tab_crawcrd.DELETE;
         vr_tab_qtaprova.DELETE;
         vr_tab_qtsolici.DELETE;
         vr_tab_qtlibera.DELETE;
         vr_tab_vllimite.DELETE;
         vr_tab_vldebito.DELETE;
         vr_tab_qtusando.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps432.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

       --Procedure para inicializar com zeros os dados das tabelas de memoria
       PROCEDURE pc_inicializa_tabela IS
       BEGIN
         --Percorrer as 99 agencias
         FOR idx IN 1..99 LOOP
           vr_tab_qtaprova(idx):= 0;
           vr_tab_qtsolici(idx):= 0;
           vr_tab_qtlibera(idx):= 0;
           vr_tab_vllimite(idx):= 0;
           vr_tab_vldebito(idx):= 0;
           vr_tab_qtusando(idx):= 0;
         END LOOP;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps432.pc_inicializa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;

	     --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps432
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
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1 /* 1-True 0-false*/
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

       --Limpar tabelas de memoria
       pc_limpa_tabela;

       --Carregar tabela de memoria de agencias
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapage(rw_crapage.cdagenci):= rw_crapage.nmresage;
       END LOOP;

       --Carregar tabela de memoria de associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
         vr_tab_crapass(rw_crapass.nrdconta).tpvincul:= rw_crapass.tpvincul;
       END LOOP;

       --Carregar tabela de memoria de limite de cartao e dia debito
       FOR rw_craptlc IN cr_craptlc (pr_cdcooper => pr_cdcooper) LOOP
         --Verificar se existe limite de cartao e dias debito
         vr_index_craptlc:= LPad(pr_cdcooper,10,'0')||
                            LPad(rw_craptlc.cdadmcrd,5,'0')||
                            LPad(rw_craptlc.tpcartao,5,'0')||
                            LPad(rw_craptlc.cdlimcrd,5,'0')||
                            LPad(rw_craptlc.dddebito,5,'0');
         vr_tab_craptlc(vr_index_craptlc):= rw_craptlc.vllimcrd;
       END LOOP;

       --Carregar tabela de memoria crapdcd
       FOR rw_crapdcd IN cr_crapdcd (pr_cdcooper => pr_cdcooper
                                    ,pr_dtdebito => rw_crapdat.dtmvtolt) LOOP
         vr_index_crapdcd:= LPad(rw_crapdcd.nrdconta,10,'0')||
                            LPad(rw_crapdcd.nrcrcard*100,25,'0');
         vr_tab_crapdcd(vr_index_crapdcd):= rw_crapdcd.vldebito;
       END LOOP;

       --Determinar o mes e ano
       vr_dsmesano:= GENE0001.vr_vet_nmmesano(To_Number(To_Char(rw_crapdat.dtmvtolt,'MM')))||'/'||
                     To_Char(rw_crapdat.dtmvtolt,'YYYY');

       -- Busca do diretório base da cooperativa para PDF
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl407';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl407 dsmesano="'||vr_dsmesano||'">');

       --Iniciar controle mudanca administradora
       vr_cdadmcrd:= 0;

       /* Selecionar todos os cheques descontados */
       FOR rw_crapadc IN cr_crapadc (pr_cdcooper => pr_cdcooper) LOOP

         --Verificar se é o primeiro registro ou mudou administradora
         IF vr_cdadmcrd = 0 THEN
           -- Inicia o agrupador da administradora
           pc_escreve_xml('<adm nmresadm="'||rw_crapadc.nmresadm||'">');
           --Atualizar controle da quebra
           vr_cdadmcrd:= rw_crapadc.cdadmcrd;
         ELSE
           IF vr_cdadmcrd != rw_crapadc.cdadmcrd THEN
             -- Finaliza o antigo e Inicia novo agrupador da administradora
             pc_escreve_xml('</adm><adm nmresadm="'||rw_crapadc.nmresadm||'">');
             --Atualizar controle da quebra
             vr_cdadmcrd:= rw_crapadc.cdadmcrd;
           END IF;
         END IF;

         --Inicializar tabelas de totais
         pc_inicializa_tabela;

         --Selecionar informacoes do cadastro auxiliar cartoes credito
         FOR rw_crawcrd IN cr_crawcrd (pr_cdcooper => pr_cdcooper
                                      ,pr_cdadmcrd => rw_crapadc.cdadmcrd) LOOP
           --Verificar se o associado existe
           IF NOT vr_tab_crapass.EXISTS(rw_crawcrd.nrdconta) THEN
             -- Montar mensagem de critica
             vr_cdcritic:= 9;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Complementar erro
             vr_dscritic := vr_dscritic||' - '||rw_crawcrd.nrdconta||
                                         ' - '||rw_crawcrd.nrcrcard;
             -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 3 --
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic);
             --Proximo Registro Loop
             CONTINUE;
           ELSE
             vr_cdagenci:= vr_tab_crapass(rw_crawcrd.nrdconta).cdagenci;
           END IF;

           --Verificar situacao cartao
           CASE rw_crawcrd.insitcrd
             WHEN 1 THEN
               --Somar quantidade aprovada total e da agencia
               IF vr_tab_qtaprova.exists(vr_cdagenci) THEN
                 vr_tab_qtaprova(vr_cdagenci):= vr_tab_qtaprova(vr_cdagenci) + 1;
               ELSE
                 vr_tab_qtaprova(vr_cdagenci):= 1;
               END IF;  
             WHEN 2 THEN
               --Somar quantidade solicitada total e da agencia
               IF vr_tab_qtsolici.exists(vr_cdagenci) THEN
                 vr_tab_qtsolici(vr_cdagenci):= vr_tab_qtsolici(vr_cdagenci) + 1;
               ELSE
                 vr_tab_qtsolici(vr_cdagenci):= 1;
               END IF;  
             WHEN 3 THEN
               --Somar quantidade liberada total e da agencia
               IF vr_tab_qtlibera.exists(vr_cdagenci) THEN
                 vr_tab_qtlibera(vr_cdagenci):= vr_tab_qtlibera(vr_cdagenci) + 1;
               ELSE
                 vr_tab_qtlibera(vr_cdagenci):= 1;
               END IF;  
             WHEN 4 THEN
               
               -- Limpar a variável
               vr_vllimcrd := 0;
             
               -- Com a entrada em Produção dos cartões do projeto 56 - Cartão 
               -- Bancoob, não buscar registro na tabela craptlc para cartões 
               -- vinculados às administradoras com código entre 10 e 80 e sim 
               -- do campo crawcrd.vllimcrd.  ( Renato - Supero - SD 195885 )
               IF rw_crawcrd.cdadmcrd BETWEEN 10 AND 80 THEN
                 -- Variável recebe o valor da tabela crawcrd
                 vr_vllimcrd := NVL(rw_crawcrd.vllimcrd,0);
               ELSE
                 -- Verificar se existe limite de cartao e dias debito
                 vr_index_craptlc:= LPAD(pr_cdcooper,10,'0')||
                                    LPAD(rw_crawcrd.cdadmcrd,5,'0')||
                                    LPAD(rw_crawcrd.tpcartao,5,'0')||
                                    LPAD(rw_crawcrd.cdlimcrd,5,'0')||
                                    LPAD(0,5,'0');

                 -- Se não encontrar o valor do limite
                 IF NOT vr_tab_craptlc.EXISTS(vr_index_craptlc) THEN
                   -- Montar mensagem de critica
                   vr_cdcritic := 532;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                 
                   -- Gerar log e continuar o processo
                   -- Envio centralizado de log de erro
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                             ,pr_ind_tipo_log => 3 --
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '
                                                                 || vr_dscritic || ' Chave: '
                                                                 || vr_index_craptlc);
                 
                   -- limpar os erros
                   vr_cdcritic := NULL;
                   vr_dscritic := NULL;
                 
                   -- NÃO DEVE DAR MAIS ERRO.... DEVE CONTINUAR O PROCESSO   ( Renato - Supero - 30/08 )
                   --RAISE vr_exc_erro;
                   CONTINUE;
                 END IF;
                 
                 -- Guardar o valor do registro de memória
                 vr_vllimcrd := NVL(vr_tab_craptlc(vr_index_craptlc), 0);
                 
               END IF;
               
               --Somar valor limite total e da agencia
               IF vr_tab_vllimite.exists(vr_cdagenci) THEN
                 vr_tab_vllimite(vr_cdagenci):= vr_tab_vllimite(vr_cdagenci) + vr_vllimcrd;
               ELSE
                 vr_tab_vllimite(vr_cdagenci):= vr_vllimcrd;
               END IF;
                    
               vr_index_crapdcd:= LPad(rw_crawcrd.nrdconta,10,'0')||
                                  LPad(rw_crawcrd.nrcrcard*100,25,'0');
               --Se existir debito no cartao
               IF vr_tab_crapdcd.EXISTS(vr_index_crapdcd) THEN
                 IF vr_tab_vldebito.exists(vr_cdagenci) THEN
                   vr_tab_vldebito(vr_cdagenci):= vr_tab_vldebito(vr_cdagenci) + vr_tab_crapdcd(vr_index_crapdcd);
                 ELSE
                   vr_tab_vldebito(vr_cdagenci):= vr_tab_crapdcd(vr_index_crapdcd);
                 END IF;  
               END IF;

               --Atualizar tabela auxiliar cartao
               vr_index_crawcrd:= vr_tab_crawcrd.Count+1;
               vr_tab_crawcrd(vr_index_crawcrd).cdcooper:= pr_cdcooper;
               vr_tab_crawcrd(vr_index_crawcrd).nrdconta:= rw_crawcrd.nrdconta;
               vr_tab_crawcrd(vr_index_crawcrd).nrctrcrd:= rw_crawcrd.nrctrcrd;

               --Somar quantidade usando total e da agencia
               IF vr_tab_qtusando.exists(vr_cdagenci) THEN
                 vr_tab_qtusando(vr_cdagenci):= vr_tab_qtusando(vr_cdagenci) + 1;
               ELSE
                 vr_tab_qtusando(vr_cdagenci):= 1;
               END IF;  
             ELSE
               NULL;
           END CASE;
         END LOOP; --rw_crawcrd

         vr_existe := false;

         --Percorrer todas as agencia por administradora
         vr_index_crapage:= vr_tab_crapage.FIRST;
         WHILE vr_index_crapage IS NOT NULL LOOP

           --Determinar a agencia
           vr_cdagenci:= vr_index_crapage;

           IF NOT (vr_tab_qtaprova(vr_cdagenci) = 0 AND
                   vr_tab_qtsolici(vr_cdagenci) = 0 AND
                   vr_tab_qtlibera(vr_cdagenci) = 0 AND
                   vr_tab_vllimite(vr_cdagenci) = 0 AND
                   vr_tab_vldebito(vr_cdagenci) = 0 AND
                   vr_tab_qtusando(vr_cdagenci) = 0) THEN

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
             ('<agencia>
                <dsagenci>'||substr(To_Char(vr_cdagenci,'fm009')||' '||vr_tab_crapage(vr_cdagenci),1,19)||'</dsagenci>
                <qtaprova>'||To_Char(vr_tab_qtaprova(vr_cdagenci),'fm99g990')||'</qtaprova>
                <qtsolici>'||To_Char(vr_tab_qtsolici(vr_cdagenci),'fm999g990')||'</qtsolici>
                <qtlibera>'||To_Char(vr_tab_qtlibera(vr_cdagenci),'fm99g990')||'</qtlibera>
                <qtusando>'||To_Char(vr_tab_qtusando(vr_cdagenci),'fm99g990')||'</qtusando>
                <vllimite>'||To_Char(vr_tab_vllimite(vr_cdagenci),'fm999g999g990d00')||'</vllimite>
                <vldebito>'||To_Char(vr_tab_vldebito(vr_cdagenci),'fm999g999g990d00')||'</vldebito>
             </agencia>');

             vr_existe := true;
           END IF;
           --Encontrar o proximo registro do vetor de agencias
           vr_index_crapage:= vr_tab_crapage.NEXT(vr_index_crapage);
         END LOOP; --rw_crapage

         IF NOT vr_existe THEN
            -- somente colocar a tag do grupo para aparecer o cabecalho no relatorio
            pc_escreve_xml
               ('<agencia></agencia>');

         END IF;
       END LOOP; --rw_crapadc

       -- Finalizar o agrupador do relatório
       pc_escreve_xml('</adm></crrl407>');

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl407/adm/agencia' --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl407.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Sem parametros
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                  ,pr_qtcoluna  => 80                  --> 80 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                  ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '80col'            --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 1                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                  ,pr_des_erro  => vr_dscritic);       --> Saída com erro
       -- Testar se houve erro
       IF vr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_erro;
       END IF;

       --Atualizar todas as informacoes da crawcrd em um único momento
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crawcrd SAVE EXCEPTIONS
           UPDATE crawcrd SET crawcrd.inanuida = 0
           WHERE crawcrd.cdcooper = vr_tab_crawcrd(idx).cdcooper
           AND   crawcrd.nrdconta = vr_tab_crawcrd(idx).nrdconta
           AND   crawcrd.nrctrcrd = vr_tab_crawcrd(idx).nrctrcrd;
       EXCEPTION
         WHEN OTHERS THEN
           -- Gerar erro
           vr_dscritic := 'Erro ao inserir na tabela crawcrd. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
           RAISE vr_exc_erro;
       END;

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

        --Limpar tabelas de memoria
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
   END pc_crps432;
/

