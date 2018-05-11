CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS430" ( pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  BEGIN

  /* .............................................................................

   Programa: pc_crps430                        Antigo: fontes/crps430.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Dezembro/2004.                    Ultima atualizacao: 26/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (Cadeia 3).

   Objetivo  : Atende a solicitacao 86.
               Emitir relatorio 401 - Aditivos Contratuais Efetuados no Dia.

   Alteracoes: 21/12/2004 - Incluida a data do contrato (Evandro).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadm (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               26/01/2007 - Substituido formato dos campos do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               11/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               21/01/2014 - Gerar o pdf do crrl401 somente quando tiver dados
                            (Gabriel)

               21/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)

               26/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)

     ............................................................................. */

     DECLARE

       --Tipo de tabela de memoria
       TYPE typ_tab_crapadt  IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       TYPE typ_tab_dsaditiv IS VARRAY (9) OF VARCHAR2(50);

       --Tabela de memoria dos emprestimos
       vr_tab_crapadt  typ_tab_crapadt;
       vr_tab_dsaditiv typ_tab_dsaditiv:= typ_tab_dsaditiv('1- Alteracao Data do Debito'
                                                          ,'2- Aplicacao Vinculada'
                                                          ,'3- Aplicacao Vinculada Terceiro'
                                                          ,'4- Inclusao de Fiador/Avalista'
                                                          ,'5- Substituicao de Veiculo'
                                                          ,'6- Interveniente Garantidor Veiculo'
                                                          ,'7- Sub-rogacao - C/Nota Promissoria'
                                                          ,'8- Sub-rogacao - S/Nota Promissoria'
                                                          ,'9- Cobertura de Aplicacao Vinculada a Operacao');


       /* Cursores da rotina crps430 */

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
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
         ORDER BY crapass.cdagenci,crapass.nrdconta;

       --Selecionar informacoes dos aditivos contratuais
       CURSOR cr_crapadt (pr_cdcooper IN crapadt.cdcooper%TYPE
                         ,pr_nrdconta IN crapadt.nrdconta%TYPE
                         ,pr_dtmvtolt IN crapadt.dtmvtolt%TYPE) IS
         SELECT crapadt.nrdconta
               ,crapadt.nrctremp
               ,crapadt.cdaditiv
               ,crapadt.nraditiv
               ,crapadt.tpctrato
         FROM crapadt
         WHERE crapadt.cdcooper = pr_cdcooper
         AND   crapadt.nrdconta = pr_nrdconta
         AND   crapadt.dtmvtolt = pr_dtmvtolt;

       --Selecionar informacoes dos aditivos contratuais
       CURSOR cr_crapadt_carga (pr_cdcooper IN crapadt.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapadt.dtmvtolt%TYPE) IS
         SELECT crapadt.nrdconta
         FROM crapadt
         WHERE crapadt.cdcooper = pr_cdcooper
         AND   crapadt.dtmvtolt = pr_dtmvtolt;

       --Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
         SELECT crapepr.dtmvtolt
               ,crapepr.nrdconta
               ,crapepr.nrctremp
         FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
         AND   crapepr.nrdconta = pr_nrdconta
         AND   crapepr.nrctremp = pr_nrctremp;
       rw_crapepr cr_crapepr%ROWTYPE;

       --Selecionar informacoes do cadastro auxiliar dos emprestimos
       CURSOR cr_crawepr (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
         SELECT crawepr.dtmvtolt
               ,crawepr.nrdconta
               ,crawepr.nrctremp
         FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
         AND   crawepr.nrdconta = pr_nrdconta
         AND   crawepr.nrctremp = pr_nrctremp;
       rw_crawepr cr_crawepr%ROWTYPE;

       -- Buscar dados do contrato de limite
       CURSOR cr_craplim(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                        ,pr_nrctremp IN crapepr.nrctremp%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
         SELECT craplim.dtinivig
         FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
         AND   craplim.nrdconta = pr_nrdconta
         AND   craplim.nrctrlim = pr_nrctremp
         AND   craplim.tpctrlim = pr_tpctrlim;
       rw_craplim cr_craplim%ROWTYPE;

       --Variaveis Locais
       vr_rel_dtctrato DATE;
       vr_flgerpdf     BOOLEAN := FALSE;
       vr_flg_impri    VARCHAR2(10);
       vr_dstipctr     VARCHAR2(15);

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS430';
       vr_cdcritic     INTEGER;
       vr_dscritic     VARCHAR2(4000);

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);


       --Variaveis de Excecao
       vr_exc_erro   EXCEPTION;
       vr_exc_pula   EXCEPTION;
       vr_exc_fimprg EXCEPTION;


       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapadt.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps430.pc_limpa_tabela. '||sqlerrm;
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
     -- Inicio Bloco Principal pc_crps430
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

       --Limpar tabelas de memoria
       pc_limpa_tabela;

       --Carregar tabela de memoria de aditivos contratuais
       FOR rw_crapadt IN cr_crapadt_carga (pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
         vr_tab_crapadt(rw_crapadt.nrdconta):= 0;
       END LOOP;

       -- Busca do diretório base da cooperativa para PDF
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl401';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl401>');

       /* Selecionar todos os associados */
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP

         /* Aditivos cadastrais */
         --Verificar se a conta possui aditivo
         IF vr_tab_crapadt.EXISTS(rw_crapass.nrdconta) THEN
           --Selecionar informacoes dos aditivos
           FOR rw_crapadt IN cr_crapadt (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapass.nrdconta
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

             /* data do contrato */
             -- Se for Emprestimo/Financimento
             IF rw_crapadt.tpctrato = 90 THEN
             --Selecionar informacoes dos emprestimos
             OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapass.nrdconta
                             ,pr_nrctremp => rw_crapadt.nrctremp);
             --Posicionar no primeiro registro
             FETCH cr_crapepr INTO rw_crapepr;
             --Se nao encontrou
             IF cr_crapepr%NOTFOUND THEN
               --Selecionar informacoes adicionais do emprestimo
               OPEN cr_crawepr (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrctremp => rw_crapadt.nrctremp);
               --Posicionar no primeiro registro
               FETCH cr_crawepr INTO rw_crawepr;
               --Se Encontrou
               IF cr_crawepr%FOUND THEN
                 --Atribuir a data do contrato
                 vr_rel_dtctrato:= rw_crawepr.dtmvtolt;
               END IF;
               --Fechar Cursor
               CLOSE cr_crawepr;
             ELSE
               --Atribuir a data do contrato
               vr_rel_dtctrato:= rw_crapepr.dtmvtolt;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapepr;
             ELSE
               --Selecionar informacoes do limite
               OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta
                               ,pr_nrctremp => rw_crapadt.nrctremp
                               ,pr_tpctrlim => rw_crapadt.tpctrato);
               FETCH cr_craplim INTO rw_craplim;
               --Se encontrou
               IF cr_craplim%FOUND THEN
                 --Atribuir a data do contrato
                 vr_rel_dtctrato := rw_craplim.dtinivig;
               END IF;
               --Fechar Cursor
               CLOSE cr_craplim;
             END IF;

             CASE rw_crapadt.tpctrato
               WHEN 1 THEN vr_dstipctr := '01-LIM.CRED';
               WHEN 2 THEN vr_dstipctr := '02-DSCT.CHQ';
               WHEN 3 THEN vr_dstipctr := '03-DSCT.TIT';
               WHEN 90 THEN vr_dstipctr := '90-EMP/FIN';
             END CASE;

             --Montar tag da conta para arquivo XML
             pc_escreve_xml
               ('<conta>
                  <cdagenci>'||rw_crapass.cdagenci||'</cdagenci>
                  <nrdconta>'||GENE0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                  <nrctremp>'||To_Char(rw_crapadt.nrctremp,'fm99g999g999')||'</nrctremp>
                  <dtctrato>'||To_Char(vr_rel_dtctrato,'DD/MM/YYYY')||'</dtctrato>
                  <dsaditiv>'||vr_tab_dsaditiv(rw_crapadt.cdaditiv)||'</dsaditiv>
                  <nraditiv>'||To_Char(rw_crapadt.nraditiv,'fm999g999')||'</nraditiv>
                  <dstipctr>'||vr_dstipctr||'</dstipctr>
             </conta>');

             vr_flgerpdf := TRUE;

           END LOOP; --rw_craptdb
         END IF;
       END LOOP; --rw_crapass

       -- Se tem dados, gerar o PDF
       IF  vr_flgerpdf  THEN
         vr_flg_impri := 'S';
       ELSE
         vr_flg_impri := 'N';
       END IF;

       -- Finalizar o agrupador do relatório
       pc_escreve_xml('</crrl401>');

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl401/conta' --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl401.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Sem parametros
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                  ,pr_qtcoluna  => 132                --> 132 colunas
                                  ,pr_sqcabrel  => 1                  --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                  ,pr_flg_impri => vr_flg_impri       --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '132col'           --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 1                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> Gerar o arquivo na hora
                                  ,pr_des_erro  => vr_dscritic);       --> Saída com erro
       -- Testar se houve erro
       IF vr_dscritic IS NOT NULL THEN
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
   END pc_crps430;
/
