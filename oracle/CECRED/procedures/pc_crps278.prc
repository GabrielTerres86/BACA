CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS278 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS278                      Antigo: Fontes/CRPS278.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/99                     Ultima atualizacao: 26/07/2012

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
               Emite: arquivo geral do BANCOOB para microfilmagem.

   Alteracoes: 10/01/2000 - Padronizar mensagens (Deborah).

               23/03/2000 - Tratar arquivos de microfilmagem, transmitindo
                            para Hering somente arquivos com registros (Odair).

               21/07/2000 - Tratar historico 358 (Deborah).

               11/06/2001 - Usar novos campos do craplcm para
                            atender circular 3030 (Margarete).

               07/01/2003 - Aumentar o campo do documento (Deborah).

               08/07/2003 - Aumentar o campo do documento (Ze Eduardo)

               02/08/2004 - Alterar diretorio win12 (Margarete).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               26/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

               17/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)

     ............................................................................. */

     DECLARE

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
         FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       --Selecionar lancamentos
       CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_dtinic   IN craplcm.dtmvtolt%TYPE
                         ,pr_dtfinal  IN craplcm.dtmvtolt%TYPE) IS
         /* INDEX (craplcm craplcm##craplcm4) */
         SELECT /*+ PARALLEL (craplcm,4,1) */
             craplcm.cdhistor
            ,craplcm.cdpesqbb
            ,craplcm.nrdocmto
            ,craplcm.nrdconta
            ,craplcm.dtmvtolt
            ,craplcm.vllanmto
            ,craplcm.cdagenci
            ,craplcm.cdbccxlt
            ,craplcm.nrdolote
            ,craplcm.cdbanchq
            ,craplcm.cdagechq
            ,craplcm.cdcmpchq
            ,craplcm.nrlotchq
            ,craplcm.sqlotchq
            ,craplcm.nrctachq
            ,row_number() over (PARTITION BY craplcm.dtmvtolt
                                ORDER BY craplcm.cdcooper
                                        ,craplcm.dtmvtolt
                                        ,craplcm.nrdconta
                                        ,craplcm.nrdocmto
                                        ,craplcm.cdhistor
                                        ,craplcm.cdagenci
                                        ,craplcm.cdbccxlt
                                        ,craplcm.nrdolote
                                        ,craplcm.nrseqdig) nrseqreg
              ,COUNT(1) over (PARTITION BY craplcm.dtmvtolt) nrtotreg
         FROM craplcm
         WHERE craplcm.cdcooper  = pr_cdcooper
         AND   craplcm.dtmvtolt  >= pr_dtinic
         AND   craplcm.dtmvtolt  < pr_dtfinal
         AND   craplcm.cdhistor IN (313,314,319,339,340,342,345,358);
       rw_craplcm cr_craplcm%ROWTYPE;

       --Selecionar Historicos
       CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE) IS
         SELECT /*+ PARALLEL (craphis,4,1) */
                craphis.cdhistor
               ,craphis.inhistor
               ,craphis.indebcre
               ,craphis.dshistor
         FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper;

       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS278';

       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Tabela de Memoria de Historicos
       vr_tab_craphis CADA0001.typ_tab_craphis;

       --Tabela de Memoria do Clob de dados
       vr_tab_clob CADA0001.typ_tab_linha;

       --Tabela de Memoria para armazenar cabecalhos
       vr_tab_cabmex CADA0001.typ_tab_char;

       --Variaveis Locais
       vr_dstextab     craptab.dstextab%TYPE;
       vr_cfg_regis000 craptab.dstextab%TYPE;
       vr_cfg_regis278 craptab.dstextab%TYPE;
       vr_regexist     BOOLEAN:= FALSE;
       vr_flgfirst     BOOLEAN:= FALSE;
       vr_reg_indebcre VARCHAR2(1);
       vr_mex_indsalto VARCHAR2(1);
       vr_typ_saida    VARCHAR2(3);
       vr_comando      VARCHAR2(100);
       vr_nmarquiv     VARCHAR2(100);
       vr_nmsufixo     VARCHAR2(100);
       vr_caminho      VARCHAR2(100);
       vr_reg_dshistor VARCHAR2(100);
       vr_reg_cdpesqbb VARCHAR2(100);
       vr_reg_nrdocmto VARCHAR2(100);
       vr_reg_vllanmto VARCHAR2(100);
       vr_reg_nrdconta VARCHAR2(100);
       vr_reg_lindetal VARCHAR2(500);
       vr_reg_nmmesref VARCHAR2(20);
       vr_contlinh     INTEGER;
       vr_nrdordem     INTEGER;
       vr_cdhistor     INTEGER;
       vr_dtmvtolt     DATE;
       vr_dtlimite     DATE;
       vr_dtrefere     DATE;
       vr_des_xml      CLOB;

       --Variaveis de Indice para temp-tables
       vr_index_clob     PLS_INTEGER;

       --Variaveis dos Totalizadores
       vr_tot_qtcompcr INTEGER;
       vr_tot_vlcompcr NUMBER;
       vr_tot_qtcompdb INTEGER;
       vr_tot_vlcompdb NUMBER;
       vr_ger_qtcompcr INTEGER;
       vr_ger_vlcompcr NUMBER;
       vr_ger_qtcompdb INTEGER;
       vr_ger_vlcompdb NUMBER;

       --Variaveis para retorno de erro
       vr_cdcritic     INTEGER:= 0;
       vr_dscritic     VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_final    EXCEPTION;
       vr_exc_saida    EXCEPTION;
       vr_exc_fimprg   EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_craphis.DELETE;
         vr_tab_clob.DELETE;
         vr_tab_cabmex.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_crps278.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_limpa_tabela;

       --Procedure para Inicializar os CLOBs
       PROCEDURE pc_inicializa_clob IS
       BEGIN
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps278.pc_inicializa_clob. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_inicializa_clob;

       --Procedure para Finalizar os CLOBs
       PROCEDURE pc_finaliza_clob IS
       BEGIN
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao finalizar CLOB. Rotina pc_crps278.pc_finaliza_clob. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_finaliza_clob;

       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
         vr_idx PLS_INTEGER;
       BEGIN
         --Se foi passada infomacao
         IF pr_des_dados IS NOT NULL THEN
           --Escrever no Clob
           dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_escreve_xml;

     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS278
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
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
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Inicializar Clob
       pc_inicializa_clob;

       /*  Diretorio no MAINFRAME da CIA HERING  */
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => rw_crapcop.cdcooper
                                               ,pr_cdacesso => 'MICROFILMA'
                                               ,pr_tpregist => 0);

       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 652;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' - CRED-CONFIG-NN-MICROFILMA-000';
         RAISE vr_exc_saida;
       ELSE
         --Configuracao
         vr_cfg_regis000:= vr_dstextab; /* contem CCOH na tabela */
       END IF;

       /*  Parametros de execucao do programa  */

       /*  Diretorio no MAINFRAME da CIA HERING  */
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => rw_crapcop.cdcooper
                                               ,pr_cdacesso => 'MICROFILMA'
                                               ,pr_tpregist => 278);

       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 652;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' - CRED-CONFIG-NN-MICROFILMA-278';
         RAISE vr_exc_saida;
       ELSE
         --Configuracao
         vr_cfg_regis278:= vr_dstextab; /* contem CCOH na tabela */

         IF to_number(substr(vr_cfg_regis278,1,1)) <> 1 THEN
           --Levantar Excecao
           RAISE vr_exc_fimprg;
         END IF;
       END IF;

       /*  Carrega tabela de indicadores de historicos  */
       FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craphis(rw_craphis.cdhistor).cdhistor:= rw_craphis.cdhistor;
         vr_tab_craphis(rw_craphis.cdhistor).inhistor:= rw_craphis.inhistor;
         vr_tab_craphis(rw_craphis.cdhistor).indebcre:= rw_craphis.indebcre;
         vr_tab_craphis(rw_craphis.cdhistor).dshistor:= rw_craphis.dshistor;
       END LOOP;

       --Buscar Diretorio padrao Microfilmagens para a cooperativa
       vr_caminho:= lower(gene0001.fn_diretorio(pr_tpdireto => 'W' --> Usr/Coop/Win12
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'microfilmagem'));
       --Se nao encontrou
       IF vr_caminho IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Diretorio padrao de microfilmagem não encontrado!';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       --Inicializar variaveis
       vr_contlinh:= 0;
       --Primeiro Registro
       vr_flgfirst:= TRUE;
       --Existe registro
       vr_regexist:= FALSE;

       --Primeiro dia do mes anterior
       vr_dtmvtolt:= trunc(add_months(rw_crapdat.dtmvtolt,-1),'MM');

       --Data Limite recebe primeiro dia do mes atual
       vr_dtlimite:= trunc(rw_crapdat.dtmvtolt,'MM');

       --Data Referencia recebe ultimo dia mes anterior
       vr_dtrefere:= last_day(add_months(rw_crapdat.dtmvtolt,-1));

       --Nome Sufixo
       vr_nmsufixo:= '.'|| to_char(vr_dtrefere,'YYYYMM');

       --Juntar nome com sufixo
       vr_nmarquiv:= 'cradbcb'||vr_nmsufixo;

       --Zerar Totalizadores
       vr_nrdordem:= 0;
       vr_cdhistor:= 0;
       vr_tot_qtcompcr:= 0;
       vr_tot_vlcompcr:= 0;
       vr_tot_qtcompdb:= 0;
       vr_tot_vlcompdb:= 0;
       vr_ger_qtcompcr:= 0;
       vr_ger_vlcompcr:= 0;
       vr_ger_qtcompdb:= 0;
       vr_ger_vlcompdb:= 0;

       --Mes Referencia
       vr_reg_nmmesref:= lpad(GENE0001.vr_vet_nmmesano (to_number(to_char(vr_dtmvtolt,'MM'))),9,' ') ||'/'||
                         to_char(vr_dtmvtolt,'YYYY');

       --Cabecalho 1
       vr_tab_cabmex(1):= rpad(rw_crapcop.nmrescop,20,' ')||
                          ' ****** LANCAMENTOS INTEGRADOS VIA COMPEN'||
                          'SACAO DO BANCOOB NO MES DE '||vr_reg_nmmesref||
                          '         ************';
       --Cabecalho 3
       vr_tab_cabmex(3):= '  CONTA/DV    DOCUMENTO'||
                          '           VALOR D/C HISTORICO            '||
                          '  BCO-AGEN-COM-  LOTE -CONTA  ACOLHIDA       DATA';
       --Cabecalho 6
       vr_tab_cabmex(6):= rpad('-',115,'-');  /*102*/

       /*  Pesquisa dos lancamentos a serem microfilmados  */

       FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                    ,pr_dtinic   => vr_dtmvtolt
                                    ,pr_dtfinal  => vr_dtlimite) LOOP

          --Se o historico esta preenchido
          IF nvl(rw_craplcm.cdhistor,0) <> nvl(vr_cdhistor,0) THEN
            --Verificar se o Historico está cadastrado
            IF NOT vr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
              --Descricao do Historico
              vr_reg_dshistor:= gene0002.fn_mask(rw_craplcm.cdhistor,'9999')||' - '||lpad('*',15,'*');
              --Indicador Debito Credito
              vr_reg_indebcre:= '*';
              --Codigo Historico
              vr_cdhistor:= rw_craplcm.cdhistor;
            ELSE
              --Descricao do Historico
              vr_reg_dshistor:= gene0002.fn_mask(rw_craplcm.cdhistor,'9999')||' - '||vr_tab_craphis(rw_craplcm.cdhistor).dshistor;
              --Indicador Debito Credito
              vr_reg_indebcre:= vr_tab_craphis(rw_craplcm.cdhistor).indebcre;
              --Codigo Historico
              vr_cdhistor:= rw_craplcm.cdhistor;
            END IF;
          END IF;

          --Historico
          IF rw_craplcm.cdhistor = 342 THEN /* cobranca */
            --Codigo Pesquisa
            vr_reg_cdpesqbb:= SUBSTR(rw_craplcm.cdpesqbb,54,03)||'-'||
                              SUBSTR(rw_craplcm.cdpesqbb,57,04)||'-'||
                              lpad(' ',3,' ')                  ||'-'||
                              SUBSTR(rw_craplcm.cdpesqbb,61,07)||'-'||
                              lpad(' ',17,' ')                 ||' '||
                              SUBSTR(rw_craplcm.cdpesqbb,71,08);
          ELSE  --Se for Historicos De Cheques
            --Codigo Pesquisa
            vr_reg_cdpesqbb:= gene0002.fn_mask(rw_craplcm.cdbanchq,'999')    ||'-'||
                              gene0002.fn_mask(rw_craplcm.cdagechq,'9999')   ||'-'||
                              gene0002.fn_mask(rw_craplcm.cdcmpchq,'999')    ||'-'||
                              gene0002.fn_mask(rw_craplcm.nrlotchq,'9999999')||'-'||
                              rw_craplcm.nrctachq;
            --Concatenar pesquisa do Lancamento
            vr_reg_cdpesqbb:= rpad(vr_reg_cdpesqbb,39,' ')||SUBSTR(rw_craplcm.cdpesqbb,82,08);
          END IF;

          --Numero do Documento
          vr_reg_nrdocmto:= to_char(rw_craplcm.nrdocmto,'fm999999g999g0');
          --Valor Lancamento
          vr_reg_vllanmto:= to_char(rw_craplcm.vllanmto,'fm999g999g990d00');
          --Numero da Conta
          vr_reg_nrdconta:= to_char(rw_craplcm.nrdconta,'fm9999g999g0');

          --Linha Detalhe /* 13 posicoes */
          vr_reg_lindetal:= lpad(vr_reg_nrdconta,10,' ')|| ' '||
                            lpad(vr_reg_nrdocmto,12,' ')|| '  '||
                            lpad(vr_reg_vllanmto,14,' ')|| '  '||
                            lpad(vr_reg_indebcre,01,' ')|| '  '||
                            rpad(vr_reg_dshistor,21,' ')|| '  '||
                            rpad(vr_reg_cdpesqbb,47,' ');

          --Se for a primeira ocorrencia da data
          IF rw_craplcm.nrseqreg = 1 THEN --FIRST-OF
            --Cabecalho 2
            vr_tab_cabmex(2):= 'DATA: '|| to_char(rw_craplcm.dtmvtolt,'DD/MM/YYYY')||rpad(' ',87,' ')|| 'SEQ.: ';
            --Se for o primeiro
            IF vr_flgfirst THEN
              --Mudar flag
              vr_flgfirst:= FALSE;
              --Indicador Salto
              vr_mex_indsalto:= '+';
              FOR idx IN 1..3 LOOP
                -- Gravar Informacao Arquivo
                LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                      ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                      ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                      ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                      ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                      ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                      ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                      ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
                --Verificar se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END LOOP;
              --Setar Quantidade Linhas
              vr_contlinh:= 5;
            ELSE
              --Indicador Salto
              vr_mex_indsalto:= '1';
              FOR idx IN 1..3 LOOP
                -- Gravar Informacao Arquivo
                LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                      ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                      ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                      ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                      ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                      ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                      ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                      ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
                --Verificar se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END LOOP;
              --Contador Linha
              vr_contlinh:= 5;
            END IF;
          END IF;  --FIRST-OF

          --Contador Linha
          IF vr_contlinh = 84 THEN
            --Indicador Salto
            vr_mex_indsalto:= '1';
            FOR idx IN 1..3 LOOP
              -- Gravar Informacao Arquivo
              LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                    ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                    ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                    ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                    ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                    ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                    ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                    ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
              --Verificar se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END LOOP;
            --Contador Linha
            vr_contlinh:= 5;
          END IF;
          -- Gravar Informacao Arquivo /* linha detalhe */
          LIMP0001.pc_crps046_i (pr_tipo         => 7                    --> Identificador do Cabecalho
                                ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
          --Verificar se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          --Incrementar Contador Linha
          vr_contlinh:= vr_contlinh + 1;
          --Se for Debito
          IF vr_reg_indebcre = 'D' THEN
            --Acumular Quantidade Debitos
            vr_tot_qtcompdb:= nvl(vr_tot_qtcompdb,0) + 1;
            --Acumular Valor dos Debitos
            vr_tot_vlcompdb:= nvl(vr_tot_vlcompdb,0) + nvl(rw_craplcm.vllanmto,0);
          ELSIF vr_reg_indebcre = 'C' THEN
            --Acumular Quantidade Creditos
            vr_tot_qtcompcr:= nvl(vr_tot_qtcompcr,0) + 1;
            --Acumular Valor dos Creditos
            vr_tot_vlcompcr:= nvl(vr_tot_vlcompcr,0) + nvl(rw_craplcm.vllanmto,0);
          END IF;

          --Se for Ultimo registro da Data --LAST-OF
          IF rw_craplcm.nrseqreg = rw_craplcm.nrtotreg THEN
            --Cabecalho 5
            vr_tab_cabmex(5):= 'TOTAIS:  A DEBITO: '||
                               gene0002.fn_mask(vr_tot_qtcompdb,'ZZZ.ZZ9')|| ' -'||
                               to_char(vr_tot_vlcompdb,'999g999g999g999g990d00')||
                               '        A CREDITO: '||
                               gene0002.fn_mask(vr_tot_qtcompcr,'ZZZ.ZZ9')|| ' -'||
                               to_char(vr_tot_vlcompcr,'999g999g999g999g990d00');
            --Acumular total geral
            vr_ger_qtcompcr:= nvl(vr_ger_qtcompcr,0) + nvl(vr_tot_qtcompcr,0);
            vr_ger_vlcompcr:= nvl(vr_ger_vlcompcr,0) + nvl(vr_tot_vlcompcr,0);
            vr_ger_qtcompdb:= nvl(vr_ger_qtcompdb,0) + nvl(vr_tot_qtcompdb,0);
            vr_ger_vlcompdb:= nvl(vr_ger_vlcompdb,0) + nvl(vr_tot_vlcompdb,0);

            --Zerar Total
            vr_tot_qtcompcr:= 0;
            vr_tot_vlcompcr:= 0;
            vr_tot_qtcompdb:= 0;
            vr_tot_vlcompdb:= 0;
            --Zerar Ordem
            vr_nrdordem:= 0;

            --Quantidade Linhas
            IF vr_contlinh > 80 THEN
              --Indicador Salto
              vr_mex_indsalto:= '1';
              FOR idx IN 1..6 LOOP
                --Nao executar 3 e 4
                IF idx NOT IN (3,4) THEN
                  -- Gravar Informacao Arquivo
                  LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                        ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                        ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                        ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                        ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                        ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                        ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                        ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
                  --Verificar se ocorreu erro
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                END IF;
              END LOOP;
              --Setar quantidade linhas
              vr_contlinh:= 7;
            ELSE
              --Gravar Cabecalhos 5 e 6
              FOR idx IN 5..6 LOOP
                -- Gravar Informacao Arquivo
                LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                      ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                      ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                      ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                      ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                      ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                      ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                      ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
                --Verificar se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END LOOP;
              --Setar quantidade linhas
              vr_contlinh:= vr_contlinh + 4;
            END IF;
          END IF; --LAST-OF
          --Marcar que existe registro
          vr_regexist:= TRUE;
       END LOOP;  --rw_craplcm

       /*  Imprime total geral da compensacao  */
       vr_tab_cabmex(5):= '         A DEBITO: '||
                          gene0002.fn_mask(vr_ger_qtcompdb,'ZZZ.ZZ9')|| ' -'||
                          to_char(vr_ger_vlcompdb,'999g999g999g999g990d00')||
                          '        A CREDITO: '||
                          gene0002.fn_mask(vr_ger_qtcompcr,'ZZZ.ZZ9')|| ' -'||
                          to_char(vr_ger_vlcompcr,'999g999g999g999g990d00');

       --Cabecalho 3
       vr_tab_cabmex(3):= 'TOTAL GERAL';
       --Indicador Salto
       vr_mex_indsalto:= '1';

       --gerar Cabecalhos 1,3,5 e 6
       FOR idx IN 1..6 LOOP
         --Nao executar cabecalhos 2 e 4
         IF idx NOT IN (2,4) THEN
           -- Gravar Informacao Arquivo
           LIMP0001.pc_crps046_i (pr_tipo         => idx                  --> Identificador do Cabecalho
                                 ,pr_tab_clob     => vr_tab_clob          --> Clob de dados
                                 ,pr_nrdordem     => vr_nrdordem          --> Numero da ordem
                                 ,pr_indsalto     => vr_mex_indsalto      --> Indicador de Salto
                                 ,pr_tab_cabmex   => vr_tab_cabmex        --> Tabela de Memoria com Cabecalhos
                                 ,pr_reg_lindetal => vr_reg_lindetal      --> Linha Detalhe
                                 ,pr_cdcritic     => vr_cdcritic          --> Codigo da Critica
                                 ,pr_dscritic     => vr_dscritic);        --> Descricao da Critica
           --Verificar se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
         END IF;
       END LOOP;

       --Buscar primeira linha do Clob para descarregar a tabela toda no CLOB
       vr_index_clob:= vr_tab_clob.FIRST;
       WHILE vr_index_clob IS NOT NULL LOOP
         --Gravar tamp-table no Clob
         pc_escreve_xml(pr_des_dados => vr_tab_clob(vr_index_clob));
         --Pegar Proximo registro
         vr_index_clob:= vr_tab_clob.NEXT(vr_index_clob);
       END LOOP;

       --Verificar tamanho e Gerar Arquivo Dados
       IF dbms_lob.getlength(vr_des_xml) > 0 THEN
         -- Geracao do arquivo
         gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                      ,pr_caminho  => vr_caminho
                                      ,pr_arquivo  => vr_nmarquiv
                                      ,pr_des_erro => vr_dscritic);
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
       END IF;

       --Transmitir Arquivo para CIA HERING
       IF TO_NUMBER(SUBSTR(vr_cfg_regis278,3,1)) = 1 AND vr_regexist THEN
         /*  Transm. para CIA HERING  */
         --Montar Comando Unix para transmitir
         vr_comando:= 'transmic . '||vr_caminho||'/'||vr_nmarquiv||
                      '  AX/'||upper(vr_cfg_regis000)||'/MICBCB '||gene0002.fn_busca_time;
         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
         END IF;
         --Escrever mensagem log
         vr_cdcritic:= 658;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar Mensagem
         vr_dscritic:= vr_dscritic||' '||vr_caminho||'/'||vr_nmarquiv||' PARA HERING';
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

       --Limpar Memoria alocada pelo Clob
       pc_finaliza_clob;
       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Salvar informacoes no banco de dados
       COMMIT;

     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao da critica
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
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS278;
/

