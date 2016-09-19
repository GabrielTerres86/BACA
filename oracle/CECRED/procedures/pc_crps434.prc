CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS434" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps434                        Antigo: fontes/crps434.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2005.                 Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 087.
               Listar associados com vinculo que tem cheques descontados,
               Emite relatorio 409.

   Alteracoes: 17/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               28/11/2005 - Incluido tipo do cheque na busca e calculo do
                            digito da conta para o caso de ser conta integracao
                            (Evandro).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               13/02/2007 - Reestruturacao das chaves do crapfdc (Ze).

               22/03/2007 - Incluido comite cooperativa (Magui).

               12/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

     ............................................................................. */

     DECLARE

       --Tipo de registro de cheques
       TYPE typ_reg_cheques IS
         RECORD (nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,tpvincul crapass.tpvincul%TYPE
                ,nrcheque crapcdb.nrcheque%TYPE
                ,vlcheque crapcdb.vlcheque%TYPE
                ,dtmvtolt crapcdb.dtmvtolt%TYPE   /* foi descontado em */
                ,dtlibera crapcdb.dtlibera%TYPE   /* vencimento */
                ,nrctades crapass.nrdconta%TYPE   /* cta de quem descontou */
                ,nmprides crapass.nmprimtl%TYPE); /* nome de quem descontou */

       --Tipo de registro de associados
       TYPE typ_reg_crapass IS
         RECORD (nmprimtl crapass.nmprimtl%TYPE
                ,cdagenci crapass.cdagenci%TYPE
                ,tpvincul crapass.tpvincul%TYPE);

       --Tipo de tabela de memoria
       TYPE typ_tab_cheques IS TABLE OF typ_reg_cheques INDEX BY VARCHAR2(30);
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;

       --Tabela de memoria dos emprestimos
       vr_tab_cheques typ_tab_cheques;
       vr_tab_crapass typ_tab_crapass;

       /* Cursores da rotina crps434 */

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
               ,crapass.inisipmf
               ,crapass.nrcadast
               ,crapass.tpvincul
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

       --Selecionar todos os cheques descontados
       CURSOR cr_crapcdb_new (pr_cdcooper IN crapcdb.cdcooper%TYPE
                             ,pr_dtlibera IN crapcdb.dtlibera%TYPE) IS
         SELECT /*+ INDEX (crapcdb crapcdb##crapcdb3) */
                crapcdb.cdbanchq
               ,crapcdb.cdagechq
               ,crapcdb.nrctachq
               ,crapcdb.nrcheque
               ,crapcdb.vlcheque
               ,crapcdb.dtmvtolt
               ,crapcdb.dtlibera
               ,crapcdb.nrdconta
               ,crapfdc.nrdconta nrdconta2
         FROM crapcdb crapcdb, crapfdc crapfdc
         WHERE crapcdb.cdcooper  = pr_cdcooper
         AND   crapcdb.dtlibera  > pr_dtlibera
         AND   crapcdb.dtdevolu  IS NULL
         AND   crapcdb.dtlibbdc  IS NOT NULL
         AND   crapcdb.inchqcop  = 1
         AND   crapfdc.cdcooper = crapcdb.cdcooper
         AND   crapfdc.cdbanchq = crapcdb.cdbanchq
         AND   crapfdc.cdagechq = crapcdb.cdagechq
         AND   crapfdc.nrctachq = crapcdb.nrctachq
         AND   crapfdc.nrcheque = crapcdb.nrcheque
         AND   crapfdc.tpcheque = 1;


       --Variaveis Locais
       vr_flgproces    BOOLEAN;
       vr_cdagenci     INTEGER;
       vr_flgshow      VARCHAR2(1);
       vr_nrdconta     VARCHAR2(50);
       vr_nmprimtl     crapass.nmprimtl%TYPE;
       vr_dsvincul     VARCHAR2(100);

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS434';
       vr_cdcritic     INTEGER;

       --Variaveis do indice
       vr_index       VARCHAR2(30);

       -- Variável para armazenar as informações em XML
       vr_des_xml     CLOB;
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis para retorno de erro
       vr_dscritic   VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_erro  EXCEPTION;
       vr_exc_fim   EXCEPTION;
       vr_exc_pula  EXCEPTION;
       vr_exc_fimprg EXCEPTION;


       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_cheques.DELETE;
         vr_tab_crapass.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps434.pc_limpa_tabela. '||sqlerrm;
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
     -- Inicio Bloco Principal pc_crps434
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
                                 ,pr_flgbatch => 1 /* 1=true 2=false */
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

       --Carregar tabela de memoria de associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
         vr_tab_crapass(rw_crapass.nrdconta).tpvincul:= rw_crapass.tpvincul;
       END LOOP;

       /* Selecionar todos os cheques descontados */
       FOR rw_crapcdb IN cr_crapcdb_new (pr_cdcooper => pr_cdcooper
                                        ,pr_dtlibera => rw_crapdat.dtmvtolt) LOOP

         /* Encontrar o dono do cheque*/
         IF NOT vr_tab_crapass.EXISTS(rw_crapcdb.nrdconta2) OR
            /* se nao tiver vinculo, proximo */
            TRIM(vr_tab_crapass(rw_crapcdb.nrdconta2).tpvincul) IS NULL THEN
           --Marcar para não processar
           vr_flgproces:= FALSE;
           --Proximo registro
           CONTINUE;
         ELSE
           --Marcar para Processar
           vr_flgproces:= TRUE;
         END IF;

         /* Pega o nome de quem descontou o cheque */
         IF vr_tab_crapass.EXISTS(rw_crapcdb.nrdconta) THEN
           --Determinar a nome de quem descontou
           vr_nmprimtl:= vr_tab_crapass(rw_crapcdb.nrdconta).nmprimtl;
         ELSE
           vr_nmprimtl:= NULL;
         END IF;

         --Se deve processar
         IF vr_flgproces THEN
           --Montar indice para tabela memoria
           vr_index:= LPad(vr_tab_crapass(rw_crapcdb.nrdconta2).cdagenci,10,'0')||
                      LPad(rw_crapcdb.nrdconta2,10,'0')||
                      LPad(rw_crapcdb.nrcheque,10,'0');
           vr_tab_cheques(vr_index).nrdconta:= rw_crapcdb.nrdconta2;
           vr_tab_cheques(vr_index).nmprimtl:= vr_tab_crapass(rw_crapcdb.nrdconta2).nmprimtl;
           vr_tab_cheques(vr_index).cdagenci:= vr_tab_crapass(rw_crapcdb.nrdconta2).cdagenci;
           vr_tab_cheques(vr_index).tpvincul:= vr_tab_crapass(rw_crapcdb.nrdconta2).tpvincul;
           vr_tab_cheques(vr_index).nrcheque:= rw_crapcdb.nrcheque;
           vr_tab_cheques(vr_index).vlcheque:= rw_crapcdb.vlcheque;
           vr_tab_cheques(vr_index).dtmvtolt:= rw_crapcdb.dtmvtolt;
           vr_tab_cheques(vr_index).dtlibera:= rw_crapcdb.dtlibera;
           vr_tab_cheques(vr_index).nrctades:= rw_crapcdb.nrdconta;
           vr_tab_cheques(vr_index).nmprides:= vr_nmprimtl;
         END IF;
       END LOOP; --rw_crapcdb

       -- Busca do diretório base da cooperativa para PDF
       vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

       --Determinar o nome do arquivo que será gerado
       vr_nom_arquivo := 'crrl409';

       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl409>');

       --Percorrer a tabela de memoria
       vr_index:= vr_tab_cheques.FIRST;
       WHILE vr_index IS NOT NULL LOOP
         --Verificar se é a mesma conta da anterior
         IF vr_index = vr_tab_cheques.FIRST  OR
            vr_tab_cheques(vr_index).nrdconta <> vr_tab_cheques(vr_tab_cheques.PRIOR(vr_index)).nrdconta THEN
           --Determinar o numero da conta
           vr_nrdconta:= GENE0002.fn_mask_conta(vr_tab_cheques(vr_index).nrdconta);
           --Determinar o nome do associado
           vr_nmprimtl:= SubStr(vr_tab_cheques(vr_index).nmprimtl,1,20);
           --Determinar o codigo da agencia
           vr_cdagenci:= vr_tab_cheques(vr_index).cdagenci;
           --Determinar o tipo da vinculacao
           CASE Trim(vr_tab_cheques(vr_index).tpvincul)
             WHEN 'CA' THEN vr_dsvincul:= 'CA-Conselho de Administ';
             WHEN 'CC' THEN vr_dsvincul:= 'CC-Conselho da Central';
             WHEN 'CF' THEN vr_dsvincul:= 'CF-Conselho Fiscal';
             WHEN 'CO' THEN vr_dsvincul:= 'CO-Comite Cooperativa';
             WHEN 'ET' THEN vr_dsvincul:= 'ET-Estagiario Terceiro';
             WHEN 'FC' THEN vr_dsvincul:= 'FC-Funcion. da Central';
             WHEN 'FO' THEN vr_dsvincul:= 'FO-Funcion. Outras Coop';
             WHEN 'FU' THEN vr_dsvincul:= 'FU-Funcion. da Cooperat';
             ELSE vr_dsvincul:= NULL;
           END CASE;
           --Mostrar registro
           vr_flgshow:= 'S';
         ELSE
           --Nao Mostrar registro
           vr_flgshow:= 'N';
         END IF;
         --Montar tag da conta para arquivo XML
         pc_escreve_xml
             ('<conta>
                <nrdconta>'||vr_nrdconta||'</nrdconta>
                <nmprimtl>'||vr_nmprimtl||'</nmprimtl>
                <cdagenci>'||vr_cdagenci||'</cdagenci>
                <dsvincul>'||vr_dsvincul||'</dsvincul>
                <nrcheque>'||GENE0002.fn_mask(vr_tab_cheques(vr_index).nrcheque,'zzz.zz9')||'</nrcheque>
                <vlcheque>'||To_Char(vr_tab_cheques(vr_index).vlcheque,'fm999g999g990d00')||'</vlcheque>
                <dtmvtolt>'||To_Char(vr_tab_cheques(vr_index).dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>
                <dtlibera>'||To_Char(vr_tab_cheques(vr_index).dtlibera,'DD/MM/YYYY')||'</dtlibera>
                <nrdconta2>'||GENE0002.fn_mask_conta(vr_tab_cheques(vr_index).nrctades)||'</nrdconta2>
                <nmprimtl2>'||SubStr(vr_tab_cheques(vr_index).nmprides,1,15)||'</nmprimtl2>
                <show>'||vr_flgshow||'</show>
           </conta>');

         --Apontar para proximo registro
         vr_index:= vr_tab_cheques.NEXT(vr_index);
       END LOOP;

       -- Finalizar o agrupador do relatório
       pc_escreve_xml('</crrl409>');

       -- Efetuar solicitação de geração de relatório --
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl409/conta' --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl409.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Sem parametros
                                  ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                  ,pr_qtcoluna  => 132                 --> 132 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                  ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 1                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> gerar PDF
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
   END pc_crps434;
/

