CREATE OR REPLACE PROCEDURE CECRED.pc_crps658 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                           ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                           ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                           ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                           ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

      Programa: pc_crps658 (Fontes/crps658.p)
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autora  : Lucas R.
      Data    : Setembro/2013                        Ultima atualizacao: 14/06/2017

      Dados referentes ao programa:

      Frequencia: Diario (Batch).
      Objetivo  : Importar os arquivos de atualizacao das informacoes dos
                  consorcios do Sicredi e gerara relatorio crrl667.

      Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                               a glb_cdcritic <> 0 antes do return. (Lucas R.)
                               
                  29/11/2013 - Ajustes no for each crapcns, retirado o INT das
                               variaveis. Ajustado para que quando data errada na 
                               linha detalhe gera critica no relatorio 667 (Lucas R.)
                               
                  06/03/2014 - Conversao Progress -> Oracle - Andrino (RKAM)
                  
                  06/10/2015 - Alterado log para gerar o proc_message, incluir envio
                               de e-mail para a area responsavel (Lucas Ranghetti #332179)
                               
                  25/01/2016 - Ajustes de perfomace, alterar leitura da crapass para 
                               incluir contas em temptable evitando leitura na crapass (Odirlei-AMcom)
                               
                  28/10/2016 - Incluir replace de "&" por "e" no nome do consorciado, 
                               pois estava estourando o xml na hora de gerar o relatorio
                               (Lucas Ranghetti #520936)
                               
                  13/02/2017 - Remover envio de e-mail para quando as criticas 190 e 191
                               (Lucas Ranghetti #597333)
                               
                  14/06/2017 - Ajuste para logar o cancelamento de consórcios (Jonata - RKAM / P364).                               
                  
      ............................................................................*/


    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS658';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Busca os dados dos associados
      CURSOR cr_crapass IS
        SELECT crapass.cdcooper,
               crapass.nrdconta,
               crapass.nrctacns
          FROM crapass 
         WHERE crapass.nrctacns <> 0;

      -- Busca dos dados da cooperativa com base no numero da agencia SICREDI
      CURSOR cr_crapcop_sic(pr_cdagesic crapcop.cdagesic%type) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdagesic = pr_cdagesic;
      rw_crapcop_sic cr_crapcop_sic%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --Tabela para receber arquivos lidos no unix
      vr_tab_nmarquiv    GENE0002.typ_split;

      -- Definicao do tipo de tabela para o relatorio crrl667
      TYPE typ_reg_relato IS
        RECORD(cdcooper crapcns.cdcooper%TYPE,
               dscooper crapcop.nmrescop%TYPE,
               nrdconta crapcns.nrdconta%TYPE,
               nrdgrupo crapcns.nrdgrupo%TYPE,
               nrcotcns crapcns.nrcotcns%TYPE,
               nrctacns crapcns.nrctacns%TYPE,
               nrctrato crapcns.nrctrato%TYPE,
               segmento VARCHAR2(09),
               nmconsor crapcns.nmconsor%TYPE,
               nrcpfcgc crapcns.nrcpfcgc%TYPE,
               nrdiadeb crapcns.nrdiadeb%TYPE,
               dtinicns crapcns.dtinicns%TYPE,
               dtfimcns crapcns.dtfimcns%TYPE,
               qtparpag crapcns.qtparpag%TYPE,
               qtparres crapcns.qtparres%TYPE,
               vlparcns crapcns.vlparcns%TYPE,
               vlrcarta crapcns.vlrcarta%TYPE,
               dtcancel crapcns.dtcancel%TYPE,
               dtctpcns crapcns.dtctpcns%TYPE,
               dtentcns crapcns.dtentcns%TYPE,
               tpconsor crapcns.tpconsor%TYPE);
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
        INDEX BY VARCHAR2(51);
      -- Vetor para armazenar os dados para o relatorio crrl667
      vr_tab_relato typ_tab_relato;
      vr_ind VARCHAR2(51);

      -- Definicao do tipo de tabela para o relatorio de criticas
      TYPE typ_reg_criticas IS
        RECORD(cdcooper crapcns.cdcooper%TYPE,
               dscooper crapcop .nmrescop%TYPE,
               cdagesic crapcop.cdagesic%TYPE,
               nrdgrupo crapcns.nrdgrupo%TYPE,
               nrcotcns crapcns .nrcotcns%TYPE,
               nrctacns crapcns.nrctacns%TYPE,
               nrctrato crapcns.nrctrato%TYPE,
               dscritic VARCHAR2(500));
      TYPE typ_tab_criticas IS
        TABLE OF typ_reg_criticas
        INDEX BY VARCHAR2(33);
      -- Vetor para armazenar os dados para o relatorio de criticas
      vr_tab_criticas typ_tab_criticas;
      vr_ind_criticas VARCHAR2(33);
      vr_qtd_criticas PLS_INTEGER := 0;
      
      TYPE typ_tab_crapass IS TABLE OF crapass.nrdconta%TYPE
        INDEX BY VARCHAR2(20); --cdcooper(5) + nrctacns(10)
      vr_tab_crapass typ_tab_crapass;
     
      ------------------------------- VARIAVEIS -------------------------------
      vr_texto_completo VARCHAR2(32600);        --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml    CLOB;                       --> XML do relatorio
      vr_nom_direto VARCHAR2(100);              --> Nome do diretorio para a geracao do arquivo de saida
      vr_caminho_arq     VARCHAR2(200);         --> Caminho dos arquivos de consorcios
      vr_caminho_arq_rec VARCHAR2(200);         --> Caminho dos arquivos de consorcios recebidos e processados
      vr_nmarquiv        VARCHAR2(50);          --> Filtro para a busca dos arquivos de debito
      vr_nmarquiv_err    VARCHAR2(50);          --> Nome do arquivo em casos de erro de processo
      vr_setlinha        VARCHAR2(500);         --> Linha de cada arquivo
      vr_tpregist        VARCHAR2(01);          --> Tipo de registro (1-cabecalho, 0-Corpo, 9-Final)
      vr_dstextab        craptab.dstextab%TYPE; --> Retorno dos dados dos parametros do arquivo
      vr_seqarqui        VARCHAR2(03);          --> Sequencial do arquivo
      vr_diaarqui        VARCHAR2(02);          --> Dia de referencia do arquivo
      vr_mesarqui        VARCHAR2(02);          --> Mes de referencia do arquivo
      vr_anoarqui        VARCHAR2(04);          --> Ano de referencia do arquivo
      vr_listadir        VARCHAR2(4000);        --> Lista dos arquivos existentes no diretorio
      vr_vldebito        NUMBER(17,2);          --> Valor acumulado de debito
      vr_linha           PLS_INTEGER;           --> Numero da linha de leitura do arquivo
      vr_input_file      utl_file.file_type;    --> Variavel do arquivo
      vr_cont            PLS_INTEGER;           --> Sequencial do arquivo
      vr_dtrefere        DATE;                  --> Data de referencia do arquivo
      vr_contareg        PLS_INTEGER;           --> Quantidade de registros no corpo do arquivo
      vr_cdagesic        crapcop.cdcooper%TYPE; --> Codigo da cooperativa
      vr_nrctacns        crapcns.nrctacns%TYPE; --> Numero da  consorcio
      vr_nrdgrupo        crapcns.nrdgrupo%TYPE; --> Numero do grupo do consorcio
      vr_nrcotcns        crapcns.nrcotcns%TYPE; --> Numero da cota consorcio
      vr_nrctrato        crapcns.nrctrato%TYPE; --> Numero do contrato do consorcio
      vr_tpconsor        crapcns.tpconsor%TYPE; --> Tipo de consorcio (1-moto,2-auto,3-pesados,4-imoveis,5-servicos)
      vr_qtparres        crapcns.qtparres%TYPE; --> Quantidade de parcelas restantes.
      vr_dtinicns        crapcns.dtinicns%TYPE; --> Data de inicio do consorcio 
      vr_dtfimcns        crapcns.dtfimcns%TYPE; --> Data do termino do consorcio
      vr_dtcancel        crapcns.dtcancel%TYPE; --> Data de cancelamento do consorcio
      vr_dtctpcns        crapcns.dtctpcns%TYPE; --> Data da contemplacao do consorcio
      vr_dtentcns        crapcns.dtentcns%TYPE; --> Data da entrega do consorcio
      vr_cdcooper        crapcop.cdcooper%TYPE; --> Codigo da cooperativa
      vr_nmrescop        crapcop.nmrescop%TYPE; --> Nome da cooperativa
      vr_flgativo        INTEGER;               --> Indicador de consorcio ativo
      vr_flgconta        BOOLEAN;               --> Indicador de existencia de associado
      vr_nrdconta        crapass.nrdconta%TYPE; --> Numero da conta do associado
      vr_qtparcns        crapcns.qtparcns%TYPE; --> Total de parcelas
      vr_nmconsor        crapcns.nmconsor%TYPE; --> Nome consorciado
      vr_segmento        VARCHAR2(09):= ' ';    --> Segmento do consorcio
      vr_emaildst        VARCHAR2(200);         --> Email para os casos de critica
      vr_texto_email     VARCHAR2(4000);        --> Texto do email de erro
      vr_nmarqimp        VARCHAR2(100);         --> Nome arquivo a ser processado
      vr_idxass          VARCHAR2(20);          --> indice da temp table da crapass
      vr_nrdrowid        ROWID;
      
      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
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

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      
      -- Email destino --      'consorcio@cecred.coop.br';      
      vr_emaildst := gene0001.fn_param_sistema('CRED',nvl(pr_cdcooper,0),'CRPS658_EMAIL');

      -- Caminho dos arquivos
      vr_caminho_arq := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_658_RECEBE'); 
      -- Arquivos que devem ser pesquisados
      vr_nmarquiv := 'consorcios_' || to_char(rw_crapdat.dtmvtolt,'YYYYMMDD') || '%'; 

      --Listar arquivos no diretorio   
      gene0001.pc_lista_arquivos (pr_path     => vr_caminho_arq
                                 ,pr_pesq     => vr_nmarquiv
                                 ,pr_listarq  => vr_listadir
                                 ,pr_des_erro => vr_dscritic);
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_fimprg;
      END IF;

      --Montar vetor com nomes dos arquivos
      vr_tab_nmarquiv := GENE0002.fn_quebra_string(pr_string => vr_listadir);

      --Percorrer todos os arquivos
      FOR idx IN 1..vr_tab_nmarquiv.COUNT LOOP
        -- Inicializa as variaveis
        vr_vldebito := 0;
        vr_linha    := 0;
        vr_contareg := 0;
        vr_nmarqimp := '';
        
        -- Nome arquivo para enviar no email
        vr_nmarqimp := vr_tab_nmarquiv(idx);
        
        --Abrir o arquivo de dados 
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq       --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_tab_nmarquiv(idx) --> Nome do arquivo
                                ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);        --> Erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_fimprg;
        END IF;

        -- Efetua a varredura das linhas do arquivo        
        LOOP
          -- Incrementa o contados de linhas
          vr_linha := vr_linha + 1;
          
          BEGIN
            -- Ler a linha do arquivo.  
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --Chegou ao final arquivo, sair do loop
              EXIT;
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
              RAISE vr_exc_fimprg;
          END;
          
          -- Busca o tipo de registro
          vr_tpregist := SUBSTR(vr_setlinha,1,1);
          
          -- Efetua a validacao sobre a linha de cabecalho (primeira linha)
          IF vr_linha = 1 THEN
            -- Busca os parametros do arquivo 
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'ARQSICREDI'
                                                     ,pr_tpregist => 0);
            
            -- Verifica se nao encontrou dados de parametro
            IF vr_dstextab IS NULL THEN
              vr_dscritic := 'Nao encontrado dados de parametro para ARQSICREDI: ';
              RAISE vr_exc_fimprg;
            END IF;
              
            -- Verifica a sequencia do arquivo
            IF SUBSTR(vr_setlinha,10,6) <> SUBSTR(vr_dstextab,15,6) THEN
              vr_cdcritic := 476;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' ' ||
                               vr_tab_nmarquiv(idx) ||
                               ' Seq. Parametrizada: '|| SUBSTR(vr_dstextab,15,6) ||
                               ' Seq. Arquivo: '      || SUBSTR(vr_setlinha,10,6);
            END IF; 
          
            /* Busca sequencial do arquivo */
            vr_cont     := SUBSTR(vr_dstextab,15,6);
            vr_seqarqui := to_char(SUBSTR(vr_setlinha,13,3),'fm000');
            vr_cont     := vr_cont + 1;

            /* Verifica se data esta correta */
            vr_diaarqui := SUBSTR(vr_setlinha,2,2);
            vr_mesarqui := SUBSTR(vr_setlinha,4,2);
            vr_anoarqui := SUBSTR(vr_setlinha,6,4);
              
            -- Validacao da data
            IF vr_mesarqui < 1  OR
               vr_mesarqui > 12 OR 
               vr_diaarqui < 1 THEN
              vr_cdcritic := 13; /* Data errada */
            ELSE
              vr_dtrefere := to_date(vr_anoarqui||vr_mesarqui,'YYYYMM'); -- Data de referencia
            END IF;
            
            -- Se a data nao estiver errada
            IF vr_cdcritic <> 13 THEN
              -- Busca o ultimo dia do mes
              vr_dtrefere := last_day(vr_dtrefere);
                   
              -- Verifica se o dia do arquivo eh maior que o maior dia do mes     
              IF vr_diaarqui > to_char(vr_dtrefere,'DD') THEN
                vr_cdcritic := 13; /* Data errada */
              ELSE
                vr_dtrefere := TO_DATE(vr_diaarqui||vr_mesarqui||vr_anoarqui,'ddmmyyyy');
              END IF;
            END IF;

            IF vr_cdcritic <> 0 THEN
              /* gera arquivo erro e nao importa para recebidos */
              vr_nmarquiv_err := 'errconsorcios_' || to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')|| '.' || 
                                 vr_seqarqui || '.txt';

              --Executar o comando no unix para alterar nome do arquivo para arquivo com erro
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => 'mv '||vr_caminho_arq||'/'||vr_tab_nmarquiv(idx)|| ' '||
                                                             vr_caminho_arq||'/'||vr_nmarquiv_err);
                RAISE vr_exc_fimprg;
            END IF;

            /* incrementa Seq. Arq. Atualizacao Consorcios tab057 */
            BEGIN
              UPDATE craptab
                 SET dstextab = substr(dstextab,1,14)||to_char(vr_cont,'fm000000')||substr(dstextab,21,999)
               WHERE craptab.cdcooper = pr_cdcooper
                 AND nmsistem = 'CRED'
                 AND tptabela = 'GENERI'
                 AND cdempres = 0
                 AND cdacesso = 'ARQSICREDI'
                 AND tpregist = 0;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPTAB: '||SQLERRM;
            END;
          ELSE -- Se nao for a primeira linha
            -- Se o tipo de registro for diferente de 1(cabecalho), 0(corpo) e 9(termino)
            IF vr_tpregist NOT IN ('1','0','9') THEN 
              -- Envio centralizado de log de erro 
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || gene0001.fn_busca_critica(468)); --468 - Tipo de registro errado.

              -- Montar assunto do email                                          
              vr_texto_email := 'Arquivo: ' || '<b>' || to_char(vr_nmarqimp) || '</b><br><br>' ||
                                'Critica: ' || '<b>' || to_char(gene0001.fn_busca_critica(468)) || '.</b>';
                                                         
              -- Enviar email para area responsavel                                           
              gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                        ,pr_cdprogra    => vr_cdprogra
                                        ,pr_des_destino => vr_emaildst
                                        ,pr_des_assunto => 'Criticas atualizacoes consorcios'
                                        ,pr_des_corpo   => vr_texto_email
                                        ,pr_des_anexo   => NULL
                                        ,pr_flg_enviar  => 'N'
                                        ,pr_des_erro    => vr_dscritic);                                                           
               continue; -- Vai par ao proximo registro
            ELSIF vr_tpregist = '1' THEN -- Cabecalho
              vr_cdcritic := 468; -- Tipo de registro errado
              EXIT; -- Sai do loop
            ELSIF vr_tpregist = '0' THEN -- Corpo do arquivo
              /* somatoria da quantidade e valores das parcelas dos 
                 registros no arquivo */
              vr_contareg := vr_contareg + 1;
              vr_vldebito := vr_vldebito + (SUBSTR(vr_setlinha,115,11) / 100);
                
            ELSIF vr_tpregist = '9' THEN /* Trailer */
              -- Verifica se a quantidade de registros do corpo eh diferente do informado no trailer do arquivo
              IF vr_contareg <> SUBSTR(vr_setlinha,2,6) THEN
                vr_cdcritic := 504; --504 - Quantidade de registros errada.
                EXIT;
              -- Verifica se o valor do debito do corpo eh diferente do informado no trailer do arquivo
              ELSIF vr_vldebito <> (SUBSTR(vr_setlinha,8,12) / 100) THEN
                vr_cdcritic := 505; --505 - Valor dos debitos errado.
                EXIT;
              END IF;
            END IF;
            
          END IF;
          
        END LOOP; -- Final da leitura do corpo de cada arquivo

        -- Verifica se ocorreu erro na leitura do arquivo
        IF vr_cdcritic <> 0 THEN 
          /* gera arquivo erro e nao importa para recebidos */
          vr_nmarquiv_err := 'errconsorcios_' || to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')|| '.' || 
                                 vr_seqarqui || '.txt';

          --Executar o comando no unix para alterar nome do arquivo para arquivo com erro
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||vr_caminho_arq||'/'||vr_tab_nmarquiv(idx)|| ' '||
                                                         vr_caminho_arq||'/'||vr_nmarquiv_err);

          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_fimprg;
        END IF;
    
        -- Fecha arquivo de dados para nova leitura desde o inicio
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao fechar arquivo dados: '||vr_tab_nmarquiv(idx);
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;

        /************************************************************************/
        /************************ INTEGRA ARQUIVO RECEBIDO **********************/
        /************************************************************************/
        
        --carregar crapass em temptable para melhoria de performace
        FOR rw_crapass IN cr_crapass LOOP
          vr_idxass := lpad(rw_crapass.cdcooper,5,'0')||lpad(rw_crapass.nrctacns,10,'0');
          vr_tab_crapass(vr_idxass) := rw_crapass.nrdconta;        
        END LOOP;        
        
        -- Gera o log de 219 - INTEGRANDO ARQUIVO
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo normal
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')                            
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || gene0001.fn_busca_critica(219)||
                                                   ' --> '||vr_caminho_arq||'/'||vr_tab_nmarquiv(idx)); 

        --Abrir o arquivo de dados
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq       --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_tab_nmarquiv(idx) --> Nome do arquivo
                                ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);        --> Erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        
        -- Efetua a varredura das linhas do arquivo        
        LOOP
          BEGIN
            -- Ler a linha do arquivo. 
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --Chegou ao final arquivo, sair do loop
              EXIT;
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro na leitura do arquivo. '||sqlerrm;
              RAISE vr_exc_saida;
          END;

          -- Busca o tipo de registro
          vr_tpregist := SUBSTR(vr_setlinha,1,1);

          -- Verifica se eh o corpo do arquivo
          IF vr_tpregist = '0' THEN
            vr_cdagesic := SUBSTR(vr_setlinha,76,4);
            OPEN cr_crapcop_sic(vr_cdagesic);
            FETCH cr_crapcop_sic INTO rw_crapcop_sic;
            IF cr_crapcop_sic%NOTFOUND THEN
              vr_cdcritic := 15;
              vr_cdcooper := 0;
              vr_nmrescop := ' ';
            ELSE
              vr_cdcooper := rw_crapcop_sic.cdcooper;
              vr_nmrescop := rw_crapcop_sic.nmrescop;
            END IF;
            CLOSE cr_crapcop_sic;
            
            vr_nrctacns := SUBSTR(vr_setlinha,80,6);
            vr_nrdgrupo := SUBSTR(vr_setlinha,2,6);
            vr_nrcotcns := SUBSTR(vr_setlinha,8,4);
            vr_nrctrato := SUBSTR(vr_setlinha,14,8);
            vr_tpconsor := SUBSTR(vr_setlinha,86,2);
            vr_qtparres := SUBSTR(vr_setlinha,101,3);
            vr_nmconsor := REPLACE(SUBSTR(vr_setlinha,22,40),'&','E');
            BEGIN
              vr_dtinicns := to_date(trim(SUBSTR(vr_setlinha,88,8)) ,'ddmmyyyy');
              vr_dtfimcns := to_date(trim(SUBSTR(vr_setlinha,126,8)),'ddmmyyyy');
              vr_dtcancel := to_date(trim(SUBSTR(vr_setlinha,134,8)),'ddmmyyyy');
              vr_dtctpcns := to_date(trim(SUBSTR(vr_setlinha,142,8)),'ddmmyyyy');
              vr_dtentcns := to_date(trim(SUBSTR(vr_setlinha,150,8)),'ddmmyyyy');
            EXCEPTION
              WHEN OTHERS THEN
                -- Se ocorreu erro nas datas, gera codigo de critica 13 (Data errada)
                vr_cdcritic := 13;
            END;
            
            /* Se terminou de pagar situacao muda para cancelado */
            IF vr_qtparres = 0 OR vr_dtcancel IS NOT NULL THEN 
              vr_flgativo := 0; /* cancelado */
            END IF;

            IF vr_dtcancel IS NULL THEN
               vr_flgativo := 1; /* ativo */
            END IF;
            
            IF vr_nrctacns = 0 THEN
              vr_cdcritic := 961; /*nao existe conta consorcio*/
            END IF;
            
            --> Verificar qual o numero da conta na cooperativa no sistema CECRED
            vr_idxass := lpad(vr_cdcooper,5,'0')||lpad(vr_nrctacns,10,'0');
                        
            IF vr_tab_crapass.exists(vr_idxass) THEN
              vr_flgconta := TRUE; /*existe conta*/
              vr_nrdconta := vr_tab_crapass(vr_idxass);
            ELSE
              vr_flgconta := FALSE; /*nao existe conta*/
              vr_nrdconta := 0;
              vr_cdcritic := 961; /* nao existe cta consorcio */
            END IF;

            -- Se ocorreu erro, insere na temp-table de criticas para depois gerar o relatorio
            IF vr_cdcritic <> 0 THEN
              vr_qtd_criticas := vr_qtd_criticas + 1;
              vr_ind_criticas := lpad(vr_cdcooper,10,'0')||
                                 lpad(SUBSTR(vr_setlinha,76,4),7,'0')||
                                 lpad(vr_nrdgrupo,11,'0')||
                                 lpad(vr_qtd_criticas,5,'0');
              vr_tab_criticas(vr_ind_criticas).cdcooper := vr_cdcooper;
              vr_tab_criticas(vr_ind_criticas).dscooper := vr_nmrescop;
              vr_tab_criticas(vr_ind_criticas).cdagesic := SUBSTR(vr_setlinha,76,4);
              vr_tab_criticas(vr_ind_criticas).nrdgrupo := vr_nrdgrupo  ;
              vr_tab_criticas(vr_ind_criticas).nrcotcns := vr_nrcotcns ;
              vr_tab_criticas(vr_ind_criticas).nrctacns := vr_nrctacns;
              vr_tab_criticas(vr_ind_criticas).nrctrato := vr_nrctrato;
              vr_tab_criticas(vr_ind_criticas).dscritic := gene0001.fn_busca_critica(vr_cdcritic);

              -- limpa as variaveis de critica
              vr_cdcritic := 0;
              vr_dscritic := NULL;
               
              -- Vai para a proxima linha do arquivo
              continue;
            END IF;
                
            /* Se existe conta cria dados da tabela crapcns */
            IF vr_flgconta THEN
              /* somatoria do total de parcelas, parcelas pagas + 
                 restantes */
              vr_qtparcns := SUBSTR(vr_setlinha,98,3) + vr_qtparres;

              -- Insere os dados do arquivo no cadastro de consorcio
              BEGIN
                INSERT INTO crapcns
                  (cdcooper,
                   nrdconta,
                   nrdgrupo,
                   nrctacns,
                   nrcotcns,
                   cdversao,
                   tpconsor,
                   nrctrato,
                   nmconsor,
                   nrcpfcgc,
                   nrdiadeb,
                   dtinicns,
                   qtparpag,
                   qtparres,
                   vlrcarta,
                   vlparcns,
                   flgativo,
                   qtparcns,
                   dtfimcns,
                   dtcancel,
                   dtctpcns,
                   dtentcns,
                   dtmvtolt,
                   dtinclus)
                 VALUES
                   (vr_cdcooper,
                    vr_nrdconta,
                    vr_nrdgrupo,
                    vr_nrctacns,
                    vr_nrcotcns,
                    SUBSTR(vr_setlinha,12,2),
                    vr_tpconsor,
                    vr_nrctrato,
                    vr_nmconsor,
                    SUBSTR(vr_setlinha,62,14),
                    SUBSTR(vr_setlinha,96,2),
                    vr_dtinicns,
                    SUBSTR(vr_setlinha,98,3),
                    vr_qtparres,
                    SUBSTR(vr_setlinha,104,11) / 100,
                    SUBSTR(vr_setlinha,115,11) / 100,
                    vr_flgativo,
                    vr_qtparcns,
                    vr_dtfimcns,
                    vr_dtcancel,
                    vr_dtctpcns, 
                    vr_dtentcns,
                    rw_crapdat.dtmvtolt,
                    rw_crapdat.dtmvtolt);
              EXCEPTION
                WHEN dup_val_on_index THEN 
                  -- Se ja existir atualiza o registro
                  BEGIN
                    UPDATE crapcns
                       SET crapcns.nmconsor = vr_nmconsor,
                           crapcns.nrcpfcgc = SUBSTR(vr_setlinha,62,14),
                           crapcns.nrdiadeb = SUBSTR(vr_setlinha,96,2),
                           crapcns.dtinicns = vr_dtinicns,
                           crapcns.qtparpag = SUBSTR(vr_setlinha,98,3),
                           crapcns.qtparres = vr_qtparres,
                           crapcns.vlrcarta = SUBSTR(vr_setlinha,104,11) / 100,
                           crapcns.vlparcns = SUBSTR(vr_setlinha,115,11) / 100,
                           crapcns.dtfimcns = vr_dtfimcns,
                           crapcns.dtcancel = vr_dtcancel,
                           crapcns.dtctpcns = vr_dtctpcns,
                           crapcns.dtentcns = vr_dtentcns,
                           crapcns.dtmvtolt = rw_crapdat.dtmvtolt,
                           crapcns.flgativo = vr_flgativo,
                           crapcns.qtparcns = vr_qtparcns,
                           crapcns.tpconsor = vr_tpconsor
                     WHERE crapcns.cdcooper = vr_cdcooper 
                       AND crapcns.nrdgrupo = vr_nrdgrupo 
                       AND crapcns.nrctacns = vr_nrctacns
                       AND crapcns.nrcotcns = vr_nrcotcns 
                       AND crapcns.nrctrato = vr_nrctrato;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar crapcns: ' || SQLERRM;
                  END;

                  --Gravar log somente se estiver cancelando o consórcio (P364).
                  IF vr_flgativo = 0 THEN
                    
                    -- Gerar informações do log
                    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                        ,pr_cdoperad => 1
                                        ,pr_dscritic => NULL
                                        ,pr_dsorigem => 'AYLLOS'
                                        ,pr_dstransa => 'Cancelamento de consorcio'
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1 --> TRUE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => 1
                                        ,pr_nmdatela => 'CRPS658'
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);

                    -- Gerar log do nrctacns
                    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'nrctacns'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => trim(to_char(vr_nrctacns,'9999G999G999')));
                                             
                    -- Gerar log do nrctrato
                    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'nrctrato'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => trim(to_char(vr_nrctrato,'99G999G999G999')));
                                             
                    -- Gerar log do flgativo
                    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'flgativo'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => vr_flgativo);
                              
                  END IF;

                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir crapcns: ' || SQLERRM;
              END;
                           
              CASE vr_tpconsor
                WHEN 1 THEN /* historico 1230 */
                  vr_segmento := 'MOTO';     
                WHEN 2 THEN /* historico 1231 */               
                  vr_segmento := 'AUTO';  
                WHEN 3 THEN /* historico 1232 */             
                  vr_segmento := 'PESADOS';  
                WHEN 4 THEN /* historico 1233 */
                  vr_segmento := 'IMOVEIS'; 
                WHEN 5 THEN /* historico 1234 */                
                  vr_segmento := 'SERVICOS'; 
                ELSE  --Verificar com Guilherme
                  vr_segmento := ' '; 
              END CASE;
                       
              -- Monta a chave para a temp-table vr_tab_relato
              vr_ind := lpad(vr_cdcooper,6,'0') ||
                        lpad(vr_nrdgrupo,11,'0')||
                        lpad(vr_nrctacns,10,'0')||
                        lpad(vr_nrcotcns,10,'0')||
                        lpad(vr_tpconsor,3,'0') ||
                        lpad(vr_nrctrato,11,'0');
                        
              -- Se nao existir o registro na temp-table, cria o mesmo
              IF NOT vr_tab_relato.exists(vr_ind) THEN
                vr_tab_relato(vr_ind).dscooper := vr_nmrescop;
                vr_tab_relato(vr_ind).cdcooper := vr_cdcooper;
                vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                vr_tab_relato(vr_ind).nrdgrupo := vr_nrdgrupo;
                vr_tab_relato(vr_ind).nrcotcns := vr_nrcotcns;
                vr_tab_relato(vr_ind).nrctacns := vr_nrctacns;
                vr_tab_relato(vr_ind).nrctrato := vr_nrctrato;
                vr_tab_relato(vr_ind).segmento := vr_segmento;
                vr_tab_relato(vr_ind).nmconsor := vr_nmconsor;
                vr_tab_relato(vr_ind).nrcpfcgc := SUBSTR(vr_setlinha,62,14);
                vr_tab_relato(vr_ind).nrdiadeb := SUBSTR(vr_setlinha,96,2);
                vr_tab_relato(vr_ind).dtinicns := vr_dtinicns;
                vr_tab_relato(vr_ind).dtfimcns := vr_dtfimcns;
                vr_tab_relato(vr_ind).qtparpag := SUBSTR(vr_setlinha,98,3);
                vr_tab_relato(vr_ind).qtparres := vr_qtparres;
                vr_tab_relato(vr_ind).vlparcns := SUBSTR(vr_setlinha,115,11) / 100;
                vr_tab_relato(vr_ind).vlrcarta := SUBSTR(vr_setlinha,104,11) / 100;
                vr_tab_relato(vr_ind).dtcancel := vr_dtcancel;
                vr_tab_relato(vr_ind).dtctpcns := vr_dtctpcns;
                vr_tab_relato(vr_ind).dtentcns := vr_dtentcns;
                vr_tab_relato(vr_ind).tpconsor := vr_tpconsor;
              END IF; /* fim do vr_tab_relato */
                       
            END IF;  /* fim do vr_flgconta */
               
          END IF; /* fim do vr_tpregist = '0' */

        END LOOP; -- Varredura do arquivo

        -- Verifica se ocorreram criticas
        /* se nao houver erro importa arquivo e exibe critica 190 */
        IF vr_tab_criticas.first IS NULL THEN
          -- busca o diretorio padrao dos arquivos recebidos e processados
          vr_caminho_arq_rec := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_658_RECEBIDOS'); 
          
          vr_nmarquiv_err := 'consorcios_' || to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')|| '.' || vr_seqarqui || '.txt';
          
          --Executar o comando no unix para alterar nome do arquivo para arquivo com erro
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||vr_caminho_arq    ||'/'||vr_tab_nmarquiv(idx)|| ' '||
                                                         vr_caminho_arq_rec||'/'||vr_nmarquiv_err);

          -- Gera o log de arquivo integrado com sucesso
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo normal
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || gene0001.fn_busca_critica(190)||
                                                     ' --> '||vr_nmarquiv_err); 
          
        ELSE /* se houver erro importa arquivo e exibe critica 191 */
          -- busca o diretorio padrao dos arquivos recebidos e processados
          vr_caminho_arq_rec := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_658_RECEBIDOS'); 

          vr_nmarquiv_err := 'consorcios_' || to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')|| '.' || vr_seqarqui || '.txt';
          
          --Executar o comando no unix para alterar nome do arquivo para arquivo com erro
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||vr_caminho_arq    ||'/'||vr_tab_nmarquiv(idx)|| ' '||
                                                         vr_caminho_arq_rec||'/'||vr_nmarquiv_err);

          -- Gera o log de arquivo integrado com rejeitados
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo normal
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || gene0001.fn_busca_critica(191)||
                                                     ' --> '||vr_nmarquiv_err); 
        END IF;
        
        -- Fecha arquivo de dados
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao fechar arquivo dados: '||vr_tab_nmarquiv(idx);
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;

        -- Inicializar o CLOB
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicializa o XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '<?xml version="1.0" encoding="utf-8"?><crrl667>'||
                              '<nmarquivo>'||vr_nmarquiv_err||'</nmarquivo>');

        -- Vai para o primeiro registro da temp-rable vr_tab_relato
        vr_ind := vr_tab_relato.first;
        
        WHILE vr_ind IS NOT NULL LOOP
          -- Se for o primeiro registro, abre o no de processados
          IF vr_ind = vr_tab_relato.first THEN 
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<processados>');
          END IF;
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<linha>'||
              '<dscooper>'||upper(vr_tab_relato(vr_ind).dscooper)||'</dscooper>'||
              '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_relato(vr_ind).nrdconta)||'</nrdconta>'||
              '<nrdgrupo>'||to_char(vr_tab_relato(vr_ind).nrdgrupo,'fm000000')||'</nrdgrupo>'||
              '<nrcotcns>'||to_char(vr_tab_relato(vr_ind).nrcotcns,'fm0000')||'</nrcotcns>'||
              '<nrctacns>'||gene0002.fn_mask(vr_tab_relato(vr_ind).nrctacns,'zzzz.zzz.9')||'</nrctacns>'||
              '<nrctrato>'||to_char(vr_tab_relato(vr_ind).nrctrato,'fm00000000')||'</nrctrato>'||
              '<segmento>'||nvl(vr_tab_relato(vr_ind).segmento,' ')||'</segmento>'||
              '<nmconsor>'||vr_tab_relato(vr_ind).nmconsor||'</nmconsor>'||
              '<nrcpfcgc>'||vr_tab_relato(vr_ind).nrcpfcgc||'</nrcpfcgc>'||
              '<nrdiadeb>'||to_char(vr_tab_relato(vr_ind).nrdiadeb,'fm00')||'</nrdiadeb>'||
              '<dtinicns>'||to_char(vr_tab_relato(vr_ind).dtinicns,'dd/mm/yyyy')||'</dtinicns>'||
              '<dtfimcns>'||to_char(vr_tab_relato(vr_ind).dtfimcns,'dd/mm/yyyy')||'</dtfimcns>'||
              '<qtparpag>'||to_char(vr_tab_relato(vr_ind).qtparpag,'fm000')||'</qtparpag>'||
              '<qtparres>'||to_char(vr_tab_relato(vr_ind).qtparres,'fm000')||'</qtparres>'||
              '<vlparcns>'||to_char(vr_tab_relato(vr_ind).vlparcns,'fm999G999G990D00')||'</vlparcns>'||
              '<vlrcarta>'||to_char(vr_tab_relato(vr_ind).vlrcarta,'fm999G999G990D00')||'</vlrcarta>'||
              '<dtcancel>'||to_char(vr_tab_relato(vr_ind).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
              '<dtctpcns>'||to_char(vr_tab_relato(vr_ind).dtctpcns,'dd/mm/yyyy')||'</dtctpcns>'||
              '<dtentcns>'||to_char(vr_tab_relato(vr_ind).dtentcns,'dd/mm/yyyy')||'</dtentcns>'||
            '</linha>'); 

          -- Se for o ultimo registro, fecha o no de processados
          IF vr_ind = vr_tab_relato.last THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</processados>');
          END IF;

          vr_ind := vr_tab_relato.next(vr_ind);
        END LOOP;  /* fim do for loop vr_tab_relato */

        -- Vai para o primeiro registro da temp-rable vr_tab_criticas
        vr_ind_criticas := vr_tab_criticas.first;
        
        WHILE vr_ind_criticas IS NOT NULL LOOP
          -- Se for o primeiro registro, abre o no de criticas
          IF vr_ind_criticas = vr_tab_criticas.first THEN 
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<criticas>');
          END IF;

          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<linha>'||
              '<dscooper>'||upper(vr_tab_criticas(vr_ind_criticas).dscooper)||'</dscooper>'||
              '<cdagesic>'||to_char(vr_tab_criticas(vr_ind_criticas).cdagesic,'fm0000')||'</cdagesic>'||
              '<nrdgrupo>'||to_char(vr_tab_criticas(vr_ind_criticas).nrdgrupo,'fm000000')||'</nrdgrupo>'||
              '<nrcotcns>'||to_char(vr_tab_criticas(vr_ind_criticas).nrcotcns,'fm0000')||'</nrcotcns>'||
              '<nrctacns>'||gene0002.fn_mask(vr_tab_criticas(vr_ind_criticas).nrctacns,'zzzz.zzz.9')||'</nrctacns>'||
              '<nrctrato>'||to_char(vr_tab_criticas(vr_ind_criticas).nrctrato,'fm00000000')||'</nrctrato>'||
              '<dscritic>'||vr_tab_criticas(vr_ind_criticas).dscritic||'</dscritic>'||
            '</linha>'); 

          -- Se for o ultimo registro, fecha o no de processados
          IF vr_ind_criticas = vr_tab_criticas.last THEN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</criticas>');
          END IF;


          vr_ind_criticas := vr_tab_criticas.next(vr_ind_criticas);
        END LOOP;  /* fim do for loop vr_tab_criticas */
        
        -- Finaliza o XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</crrl667>',TRUE);

        -- Busca do diretorio base da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rl'); 

        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/crrl667',                     --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl667.jasper',               --> Arquivo de layout do iReport
                                    pr_dsparams  => null,                           --> Nao enviar parametro
                                    pr_dsarqsaid => vr_nom_direto||'/crrl667.lst',  --> Arquivo final
                                    pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                    pr_qtcoluna  => 234,                            --> Quantidade de colunas
                                    pr_nmformul  => '234dh',                        --> Nome do formulario
                                    pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                    pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                    pr_nrcopias  => 1,                              --> Numero de copias
                                    pr_des_erro  => vr_dscritic);                   --> Saida com erro

        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        COMMIT; -- Efetua commit apos processado cada arquivo, pois o mesmo eh enviado para outro diretorio

      END LOOP; -- Final do loop de leitura de todos os arquivos

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
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Montar texto do email                                          
        vr_texto_email := 'Arquivo: ' || '<b>' || to_char(vr_nmarqimp) || '</b><br><br>' ||
                          'Critica: ' || '<b>' || to_char(vr_dscritic) || '</b>';
                                                   
        -- Enviar email para area responsavel                                           
        gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                  ,pr_cdprogra    => vr_cdprogra
                                  ,pr_des_destino => vr_emaildst
                                  ,pr_des_assunto => 'Criticas atualizacoes consorcios'
                                  ,pr_des_corpo   => vr_texto_email
                                  ,pr_des_anexo   => NULL
                                  ,pr_flg_enviar  => 'N'
                                  ,pr_des_erro    => vr_dscritic);
                                                                                        
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

  END pc_crps658;
/
