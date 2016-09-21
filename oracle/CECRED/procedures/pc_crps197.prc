CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS197" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps197                        Antigo: fontes/crps197.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/97                            Ultima atualizacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio com o valor minimo para credito em conta
               dos funcionarios da LOHESA - 154.

   Alteracoes: 07/06/1999 - Tratar CPMF (Deborah).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               11/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)
     ............................................................................. */

     DECLARE

       --Tipo de tabela de memoria
       TYPE typ_tab_crapttl IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

       --Tabela de memoria dos emprestimos
       vr_tab_crapttl typ_tab_crapttl;

       /* Cursores da rotina crps197 */

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
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         ORDER BY crapass.nrcadast;

       --Selecionar informacoes da empresa
       CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdempres IN crapemp.cdempres%TYPE) IS
         SELECT crapemp.nmresemp
         FROM  crapemp crapemp
         WHERE crapemp.cdcooper = pr_cdcooper
         AND   crapemp.cdempres = pr_cdempres;
       rw_crapemp cr_crapemp%ROWTYPE;

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

       --Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
			                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
				                 ,pr_inliquid IN crapepr.inliquid%TYPE) IS
         SELECT crapepr.vlsdeved
               ,crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.cdlcremp
			         ,crapepr.dtmvtolt
               ,crapepr.vlemprst
			         ,crapepr.dtultpag
               ,crapepr.cdcooper
               ,crapepr.cdagenci
               ,crapepr.vlpreemp
               ,crapepr.txjuremp
		     FROM crapepr crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
		     AND   crapepr.nrdconta = pr_nrdconta
		     AND   crapepr.inliquid = pr_inliquid;

       --Selecionar informacoes dos planos
       CURSOR cr_crappla (pr_cdcooper IN crappla.cdcooper%TYPE
                         ,pr_nrdconta IN crappla.nrdconta%TYPE
                         ,pr_cdsitpla IN crappla.cdsitpla%TYPE) IS
         SELECT /*+ INDEX crappla (crappla##crappla3) */
                Nvl(Sum(Nvl(crappla.vlprepla,0)),0) vlprepla
         FROM crappla crappla
         WHERE crappla.cdcooper = pr_cdcooper
         AND   crappla.nrdconta = pr_nrdconta
         AND   crappla.cdsitpla = pr_cdsitpla;


       --Variaveis Locais
       vr_dtrefere     DATE;
       vr_cdempres     INTEGER;
       vr_tot_vlsdeved NUMBER:= 0;
       vr_tot_vlplanos NUMBER:= 0;
       vr_tot_vlcredit NUMBER:= 0;

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;

       --Variaveis do ipmf
       vr_txcpmfcc  NUMBER:= 0;
       vr_txrdcpmf  NUMBER:= 0;
       vr_indabono  NUMBER:= 0;
       vr_dtinipmf  DATE;
       vr_dtfimpmf  DATE;
       vr_dtiniabo  DATE;

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;
       vr_dtmvtopr     DATE;
       vr_dtmvtoan     DATE;
       vr_dtultdia     DATE;
       vr_qtdiaute     INTEGER;

	     -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis para retorno de erro
       vr_des_erro       VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;
       vr_exc_pula  EXCEPTION;


       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapttl.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps197.pc_limpa_tabela. '||sqlerrm;
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
     -- Inicio Bloco Principal pc_crps197
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS197';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS197'
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
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_erro;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
         --Ultimo dia do mes atual
         vr_dtultdia:= rw_crapdat.dtultdia;
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
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Sair do programa
         RAISE vr_exc_erro;
       END IF;

       --Limpar tabelas de memoria
       pc_limpa_tabela;

       -- Procedimento padrão de busca de informações de CPMF
       gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                             ,pr_dtmvtolt  => vr_dtmvtolt
                             ,pr_dtinipmf  => vr_dtinipmf
                             ,pr_dtfimpmf  => vr_dtfimpmf
                             ,pr_txcpmfcc  => vr_txcpmfcc
                             ,pr_txrdcpmf  => vr_txrdcpmf
                             ,pr_indabono  => vr_indabono
                             ,pr_dtiniabo  => vr_dtiniabo
                             ,pr_cdcritic  => vr_cdcritic
                             ,pr_dscritic  => vr_des_erro);
       -- Se retornou erro
       IF vr_des_erro IS NOT NULL THEN
         -- Gerar raise
         RAISE vr_exc_erro;
       END IF;

       --Selecionar informacoes da empresa
       OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                       ,pr_cdempres => 5);
       --Posicionar no primeiro registro
       FETCH cr_crapemp INTO rw_crapemp;
       --Fechar Cursor
       CLOSE cr_crapemp;

       --Carregar tabela de memoria de titulares da conta
       FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                    ,pr_idseqttl => 1) LOOP
         vr_tab_crapttl(rw_crapttl.nrdconta):=  rw_crapttl.cdempres;
       END LOOP;

       -- Busca do diretório base da cooperativa para PDF
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl154';

       --Atribuir o ultimo dia do mes atual para data referencia
       vr_dtrefere:= Last_Day(rw_crapdat.dtmvtolt);

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl154 dsempres="'||
                      rw_crapemp.nmresemp||'" dtrefere="'||To_Char(vr_dtrefere,'DD/MM/YYYY')||'">');

       /* Selecionar todos os associados */
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP

         --Se for pessoa fisica
         IF rw_crapass.inpessoa = 1 THEN

           --Selecionar informacoes dos titulares da conta
           IF vr_tab_crapttl.EXISTS(rw_crapass.nrdconta) THEN
             --Codigo da empresa recebe o codigo da empresa do titular da conta
             vr_cdempres:= vr_tab_crapttl(rw_crapass.nrdconta);
           ELSE
             --Codigo da empresa recebe zero
             vr_cdempres:= 0;
           END IF;
         ELSE
           --Selecionar informacoes dos titulares da conta
           FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapass.nrdconta) LOOP
             --Codigo da empresa recebe o codigo da empresa do titular da conta
             vr_cdempres:= rw_crapjur.cdempres;
           END LOOP;
         END IF;

         --Só processar empresa 5
         IF vr_cdempres = 5 THEN

           --Zerar totalizadores
           vr_tot_vlsdeved:= 0;
           vr_tot_vlplanos:= 0;
           vr_tot_vlcredit:= 0;

           --Selecionar emprestimos
           FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_inliquid => 0) LOOP
             --Se o saldo devedor for menor valor emprestado
             IF rw_crapepr.vlsdeved < rw_crapepr.vlpreemp THEN
               --Acumular saldo devedor
               vr_tot_vlsdeved:= vr_tot_vlsdeved + rw_crapepr.vlsdeved +
                                 (rw_crapepr.vlsdeved * 10 * rw_crapepr.txjuremp);
             ELSE
               --Acumular saldo devedor
               vr_tot_vlsdeved:= vr_tot_vlsdeved + rw_crapepr.vlpreemp;
             END IF;
           END LOOP; --rw_crapepr

           --Acumular total de planos de cota
           FOR rw_crappla IN cr_crappla (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_cdsitpla => 1) LOOP
             vr_tot_vlplanos:= rw_crappla.vlprepla;
           END LOOP;

           --Ignorar valores zerados
           IF NOT (vr_tot_vlsdeved = 0 AND vr_tot_vlplanos = 0) THEN
             --Se for isento de ipmf
             IF rw_crapass.inisipmf = 1 THEN
               vr_tot_vlsdeved:= ROUND(vr_tot_vlsdeved + (vr_tot_vlsdeved * vr_txcpmfcc),2);
             END IF;

             --Total do credito recebe saldo devedor + saldo planos
             vr_tot_vlcredit:= vr_tot_vlsdeved + vr_tot_vlplanos;

             --Verificar se os valores estao zerados para mandar null
             IF vr_tot_vlsdeved = 0 THEN
               vr_tot_vlsdeved:= NULL;
             END IF;
             IF vr_tot_vlplanos = 0 THEN
               vr_tot_vlplanos:= NULL;
             END IF;

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta>
                  <nrdconta>'||GENE0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                  <nrcadast>'||GENE0002.fn_mask_conta(rw_crapass.nrcadast)||'</nrcadast>
                  <nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>
                  <vlsdeved>'||To_Char(vr_tot_vlsdeved,'fm999g999g999d00')||'</vlsdeved>
                  <vlplanos>'||To_Char(vr_tot_vlplanos,'fm999g999g999d00')||'</vlplanos>
                  <vlcredit>'||To_Char(vr_tot_vlcredit,'fm999g999g999d00')||'</vlcredit>
             </conta>');
           END IF;
         END IF; --vr_cdempres <> 5
       END LOOP; --rw_crapass

       -- Finalizar o agrupador do relatório
       pc_escreve_xml('</crrl154>');

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl154/conta' --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl154.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Sem parametros
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                  ,pr_qtcoluna  => 132                 --> 132 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                  ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 2                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> gerar PDF
                                  ,pr_des_erro  => vr_des_erro);       --> Saída com erro
       -- Testar se houve erro
       IF vr_des_erro IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_erro;
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
       WHEN vr_exc_erro THEN
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

        -- Se foi retornado apenas código
        IF nvl(vr_cdcritic,0) > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_des_erro;
        -- Efetuar rollback
        ROLLBACK;

       WHEN OTHERS THEN
         -- Retornar texto do erro
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

         -- Efetuar rollback
         ROLLBACK;

     END;
   END pc_crps197;
/

