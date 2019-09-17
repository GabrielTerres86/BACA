CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS539(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdoperad  IN gncpdoc.cdoperad%TYPE  --> C?digo do operador
                                      ,pr_nmtelant  IN varchar2               --> tela anterior
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS539 ( Fontes/crps539.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Novembro/2009.                   Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de DOCs da Nossa Remessa - Conciliacao.

   Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que
                            esta no HEADER do arquivo e incluir um resumo ao
                            fim do relatorio de Rejeitados, Integrados e
                            Recebidos (Guilherme/Supero)

               28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                            e sair do laco de importacao do arquivo(Guilherme).

               04/06/2010 - Acertos Gerais (Ze).

               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               09/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

               12/11/2013 - Ajustes na rotina para mover os arquivos de remessa
                            para a pasta salvar (Marcos-Supero)

               18/11/2013 - Ajustar a rotina para passar informação de existência
                            de detalhe.
                          - Ajuste no formato da data do arquivo.
                          - Também remoção da chamada ambígua de relatório somente
                            pelo fato de gravar também na rlnsv (Marcos-Supero)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

............................................................................. */
  DECLARE
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS539';
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor generico de calendario */
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

    /*  Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC  */
    CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT 1
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 0
         AND craptab.cdacesso = 'EXECUTAABBC'
         AND craptab.tpregist = 0
         AND craptab.dstextab = 'SIM';
    rw_craptab cr_craptab%ROWTYPE;

    --Buscar ultimo registro Compensacao Documentos da Central(FIND LAST)
    CURSOR cr_gncpdoc (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_dtarquiv IN date,
                       pr_nrdconta IN gncpdoc.nrdconta%type,
                       pr_tpdoctrf IN gncpdoc.tpdoctrf%type,
                       pr_nrdocmto IN gncpdoc.nrdocmto%type) IS
      SELECT ROWID,
             cdtipreg
        FROM gncpdoc g
       WHERE g.progress_recid =
             (SELECT MAX(g1.progress_recid)
                FROM gncpdoc g1
               WHERE g1.cdcooper = pr_cdcooper
                 AND g1.dtmvtolt = pr_dtarquiv
                 AND g1.nrdconta = pr_nrdconta
                 AND g1.tpdoctrf = pr_tpdoctrf
                 AND g1.nrdocmto = pr_nrdocmto);
    rw_gncpdoc cr_gncpdoc%rowtype;

    -- Buscar registros inseridos para geracao do relatorio
    CURSOR cr_craprej (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_dtmvtolt IN craprej.dtmvtolt%TYPE)IS
      SELECT cdcritic,
             cdpesqbb,
             nrseqdig,
             nrdconta,
             nrdocmto,
             vllanmto
        FROM craprej
       WHERE craprej.cdcooper = pr_cdcooper
         AND craprej.dtmvtolt = pr_dtmvtolt
         AND craprej.cdagenci = 539
       ORDER BY craprej.nrseqdig;
    rw_craprej cr_craprej%rowtype;

    -- Type para armazenar nome dos arquivos para processamento
    TYPE typ_tab_nmarquiv IS
      TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

    --Vetor para armazenar os arquivos para processamento
    vr_vet_nmarquiv typ_tab_nmarquiv;
    vr_nmdirconv     varchar2(100);
    vr_nmdirsalv     varchar2(100);
    vr_nom_arquivo   varchar2(100);
    vr_dspath_copi   varchar2(200);
    --variavei para impressao
    vr_nom_dirimp    varchar2(100);
    vr_nom_arqimp    varchar2(100);
    vr_input_file    UTL_FILE.file_type;

    -- variaveis para utilizacao de comando no OS
    vr_comando       varchar2(200);
    vr_typ_saida     varchar2(4);
    vr_setlinha      varchar2(500);

    -- Armazenar informacoes para geracao da tabela
    vr_dtauxili      varchar2(8) := null;
    vr_dtarquiv      date;
    vr_nrdconta      gncpdoc.nrdconta%type;
    vr_tpdoctrf      gncpdoc.tpdoctrf%type;
    vr_nrdocmto      gncpdoc.nrdocmto%type;

    -- Controle e totalizadores
    vr_conta_linha   number := 0;
    vr_tot_qtregint  number := 0;
    vr_tot_vlregint  number := 0;
    vr_tot_qtregrec  number := 0;
    vr_tot_vlregrec  number := 0;
    vr_contador      number := 0;
    vr_tot_qtregrej  number := 0;
    vr_tot_vllanrej  number := 0;
    vr_flg_vazio     varchar2(1);

    -- Variavel para armazenar as informacos em XML
    vr_des_xml clob;

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;
    END;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    /*  Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC  */
    OPEN cr_craptab(pr_cdcooper => pr_cdcooper);
    FETCH cr_craptab
     INTO rw_craptab;
    -- Se nao encontrar
    IF cr_craptab%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_craptab;
      vr_dscritic := 'Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC';
      RAISE vr_exc_fimprg;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_craptab;
    END IF;

    -- Busca do diretorio base da cooperativa
    vr_nmdirconv := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => null);
    -- Diretorio para impressao
    vr_nom_dirimp := vr_nmdirconv;
    -- Diretorio salvar
    vr_nmdirsalv := vr_nmdirconv||'/salvar';

    -- diretorio arquivos a processar
    vr_nmdirconv := vr_nmdirconv||'/integra';

    vr_nom_arquivo := '3'||lpad(rw_crapcop.cdagectl,4,0)||'*.REM';

    -- Remove os arquivos ".q" caso existam
    vr_comando:= 'rm ' || vr_nmdirconv || '/'|| vr_nom_arquivo || '.q 2> /dev/null';
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Apaga o arquivo pc_crps539.txt caso exista
    vr_comando:= 'rm ' || vr_nmdirconv || '/pc_crps539.txt 2> /dev/null';
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    -- Verificar se existe arquivos a serem importatos
    vr_comando:= 'ls ' || vr_nmdirconv || '/'|| vr_nom_arquivo|| ' | wc -l';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    ELSE
      --Se retornou zero arquivos entao sai do programa
      IF SUBSTR(vr_dscritic,1,1) = '0' OR
         vr_dscritic IS NULL THEN
        --Critica
        vr_cdcritic:= 182;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_fimprg;
      ELSE
        vr_dscritic := NULL;
      END IF;
    END IF;

    -- Criar o arquivo pc_crps539.txt baseado no comando LS
    vr_comando:= 'ls ' || vr_nmdirconv || '/'|| vr_nom_arquivo|| ' 1>> '|| vr_nmdirconv || '/pc_crps539.txt';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    --Bloco de leitura do arquivo pc_crps539.txt
    BEGIN
      --Abre o arquivo pc_crps539.txt
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirconv     --> Diretorio do arquivo
                              ,pr_nmarquiv => 'pc_crps539.txt'  --> Nome do arquivo
                              ,pr_tipabert => 'R'               --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file     --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);     --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      LOOP
        --Verifica se o arquivo esta aberto
        IF  utl_file.IS_OPEN(vr_input_file) THEN
          -- Le os dados em pedacos e escreve no Blob
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_nom_arquivo); --> Texto lido
          --Incrementar contador
          vr_contador:= Nvl(vr_contador,0) + 1;

          --Separar o nome do arquivo do caminho
          GENE0001.pc_separa_arquivo_path(pr_caminho => vr_nom_arquivo
                                         ,pr_direto  => vr_nmdirconv
                                         ,pr_arquivo => vr_nom_arquivo);

          --Popular o vetor de arquivos
          vr_vet_nmarquiv(vr_contador):= vr_nom_arquivo;
        END IF;
      END LOOP;

      -- Fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
               -- Apaga o arquivo pc_crps539.txt no unix
      vr_comando:= 'rm '||vr_nmdirconv||'/'||'pc_crps539.txt';
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN utl_file.invalid_operation THEN
        --Nao conseguiu abrir o arquivo
        vr_dscritic:= 'Erro ao abrir o arquivo pc_crps539.txt na rotina pc_crps539.';
        RAISE vr_exc_erro;
      WHEN no_data_found THEN
        -- Terminou de ler o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
    END;

    --Se o contador esta zerado
    IF vr_contador = 0 THEN
      vr_cdcritic:= 182;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_fimprg;
    END IF;

    --Verificar o nome da tela anterior
    IF pr_nmtelant = 'COMPEFORA'   THEN
      vr_dtauxili:= To_Char(rw_crapdat.dtmvtoan,'YYYYMMDD');
    ELSE
      vr_dtauxili:= To_Char(rw_crapdat.dtmvtolt,'YYYYMMDD');
    END IF;

    --Processa cada arquivo lido
    FOR idx IN 1..vr_contador LOOP
      -- Comando para listar a ultima linha do arquivo
      vr_comando:= 'tail -2 ' || vr_nmdirconv|| '/' || vr_vet_nmarquiv(idx);

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_setlinha);
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;

      --Se o final do arquivo estiver errado
      IF SUBSTR(vr_setlinha,01,10) <> '9999999999' THEN
        vr_cdcritic:= 258;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - Arquivo: '|| vr_vet_nmarquiv(idx);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        vr_cdcritic := 0;
      END IF;

      --Abrir o arquivo lido e percorrer as linhas do mesmo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirconv  --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_vet_nmarquiv(idx)    --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF utl_file.IS_OPEN(vr_input_file) THEN
        -- Le os dados do arquivo e coloca na variavel vr_setlinha
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      END IF;

      /*  Verifica cada linha do arquivo importado  */
      IF SUBSTR(vr_setlinha,21,6) <> 'DCR605' THEN
        vr_cdcritic := 181;
      ELSIF SUBSTR(vr_setlinha,27,3) <> lpad(rw_crapcop.cdbcoctl,3,'0') THEN
        vr_cdcritic := 057;
      ELSIF SUBSTR(vr_setlinha,31,8) <> vr_dtauxili THEN
        vr_cdcritic := 013;
      END IF;

      if vr_cdcritic > 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - Arquivo: '|| vr_vet_nmarquiv(idx);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        vr_cdcritic := 0;
        continue;
      end if;

      vr_dtarquiv := TO_DATE(SUBSTR(vr_setlinha,50,8),'RRRRMMDD');

      --Abrir o arquivo lido e percorrer as linhas do mesmo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirconv  --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_vet_nmarquiv(idx) --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Inicializa variavel de controle de linhas com zero
      vr_conta_linha:= 0;
      LOOP
        --Incrementa o contador de linhas
        vr_conta_linha:= vr_conta_linha+1;
        -- Le os dados do arquivo e coloca na variavel vr_setlinha
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
        --Se for a primeira linha ignora
        IF vr_conta_linha = 1 THEN
          -- Le os dados do arquivo e coloca na variavel vr_setlinha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido
        END IF;

        -- Sair quando nao existir mais linhas
        EXIT WHEN SUBSTR(vr_setlinha,1,15) = '999999999999999';

        vr_nrdconta := SUBSTR(vr_setlinha,129,13);
        vr_tpdoctrf := SUBSTR(vr_setlinha,203,1);
        vr_nrdocmto := SUBSTR(vr_setlinha,25,6);

        /*  buscar ultimo registro na tabela Compensacao Documentos da Central(Find Last)*/
        OPEN cr_gncpdoc(pr_cdcooper => pr_cdcooper,
                        pr_dtarquiv => vr_dtarquiv,
                        pr_nrdconta => vr_nrdconta,
                        pr_tpdoctrf => vr_tpdoctrf,
                        pr_nrdocmto => vr_nrdocmto);
        FETCH cr_gncpdoc
         INTO rw_gncpdoc;
        -- Se nao encontrar
        IF cr_gncpdoc%NOTFOUND THEN
          CLOSE cr_gncpdoc;
          /*  Criacao da tabela Generica - gncpdoc  */
          BEGIN
            INSERT INTO gncpdoc
                     ( cdcooper
                      ,cdagenci
                      ,dtmvtolt
                      ,dtliquid
                      ,cdcmpchq
                      ,cdbccrcb
                      ,cdagercb
                      ,dvagenci
                      ,nrcctrcb
                      ,nrdocmto
                      ,vldocmto
                      ,nmpesrcb
                      ,cpfcgrcb
                      ,tpdctacr
                      ,cdfinrcb
                      ,cdagectl
                      ,nrdconta
                      ,nmpesemi
                      ,cpfcgemi
                      ,tpdctadb
                      ,tpdoctrf
                      ,qtdregen
                      ,nmarquiv
                      ,cdoperad
                      ,hrtransa
                      ,cdtipreg
                      ,flgconci
                      ,flgpcctl
                      ,nrseqarq
                      ,cdcritic
                      ,cdmotdev)
                  VALUES
                     ( pr_cdcooper                             -- cdcooper
                      ,0                                       -- cdagenci
                      ,vr_dtarquiv                             -- dtmvtolt
                      ,rw_crapdat.dtmvtolt                     -- dtliquid
                      ,to_number(SUBSTR(vr_setlinha,118,3))    -- cdcmpchq
                      ,to_number(SUBSTR(vr_setlinha,4,3))      -- cdbccrcb
                      ,to_number(SUBSTR(vr_setlinha,7,4))      -- cdagercb
                      ,SUBSTR(vr_setlinha,11,1)                -- dvagenci
                      ,to_number(SUBSTR(vr_setlinha,12,13))    -- nrcctrcb
                      ,vr_nrdocmto                             -- nrdocmto
                      ,to_number(SUBSTR(vr_setlinha,31,18))/100--vldocmto
                      ,SUBSTR(vr_setlinha,49,40)               -- nmpesrcb
                      ,to_number(SUBSTR(vr_setlinha,89,14))    -- cpfcgrcb
                      ,to_number(SUBSTR(vr_setlinha,103,2))    -- tpdctacr
                      ,to_number(SUBSTR(vr_setlinha,105,2))    -- cdfinrcb
                      ,to_number(SUBSTR(vr_setlinha,124,4))    -- cdagectl
                      ,vr_nrdconta                             -- nrdconta
                      ,SUBSTR(vr_setlinha,142,40)              -- nmpesemi
                      ,to_number(SUBSTR(vr_setlinha,182,14))   -- cpfcgemi
                      ,to_number(SUBSTR(vr_setlinha,196,2))    -- tpdctadb
                      ,vr_tpdoctrf                             -- tpdoctrf
                      ,to_number(SUBSTR(vr_setlinha,209,6))    -- qtdregen
                      ,vr_vet_nmarquiv(idx)                    -- nmarquiv
                      ,pr_cdoperad                             -- cdoperad
                      --Quardar a hora em segundos, sysdate-trunc(sysdate) traz a hora no formato de dias,
                      --multiplicar por quantos segundos tem num dia
                      ,(sysdate - trunc(sysdate))* 86400       -- hrtransa
                      ,2                                       -- cdtipreg
                      ,1                                       -- flgconci
                      ,0                                       -- flgpcctl(NO)
                      ,to_number(SUBSTR(vr_setlinha,248,8))    -- nrseqarq
                      ,927                                     -- cdcritic
                      ,0                                       -- cdmotdev
                      );
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir compensacao(gncpdoc): '||SQLerrm;
              RAISE vr_exc_erro;
          END;

          -- Inserir Cadastro de rejeitados na integracao - D23.
          BEGIN
            INSERT INTO craprej
                       (dtmvtolt
                       ,cdagenci
                       ,nrdconta
                       ,nrdocmto
                       ,vllanmto
                       ,nrseqdig
                       ,cdpesqbb
                       ,cdcritic
                      ,cdcooper)
                    VALUES
                      (rw_crapdat.dtmvtolt             -- dtmvtolt
                      ,539                             -- cdagenc
                      ,vr_nrdconta                     -- nrdconta
                      ,vr_nrdocmto                     -- nrdocmto
                      ,(SUBSTR(vr_setlinha,31,18)/100) -- vllanmto
                      ,SUBSTR(vr_setlinha,248,08)     -- nrseqdig
                      ,SUBSTR(vr_setlinha,1,50)       -- cdpesqbb
                      ,927                             -- cdcritic
                      ,pr_cdcooper                     -- cdcooper
                      );
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir rejeitados(craprej): '||SQLerrm;
              RAISE vr_exc_erro;
          END;
        ELSE
          CLOSE cr_gncpdoc;
          IF rw_gncpdoc.cdtipreg = 2  THEN
            -- Inserir Cadastro de rejeitados na integracao - D23.
            BEGIN
              INSERT INTO craprej
                         (dtmvtolt
                         ,cdagenci
                         ,nrdconta
                         ,nrdocmto
                         ,vllanmto
                         ,nrseqdig
                         ,cdpesqbb
                         ,cdcritic
                         ,cdcooper)
                      VALUES
                         (rw_crapdat.dtmvtolt             -- dtmvtolt
                         ,539                             -- cdagenc
                         ,vr_nrdconta                     -- nrdconta
                         ,vr_nrdocmto                     -- nrdocmto
                         ,(SUBSTR(vr_setlinha,31,18)/100) -- vllanmto
                         ,SUBSTR(vr_setlinha,248,08)     -- nrseqdig
                         ,SUBSTR(vr_setlinha,1,50)       -- cdpesqbb
                         ,927                             -- cdcritic
                         ,pr_cdcooper                     -- cdcooper
                         );

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir rejeitados(craprej): '||SQLerrm;
                RAISE vr_exc_erro;
            END;

          ELSE
            /*  Se encontrou um registro do tipo 1(Nossa Remessa) eh pq conseguiu conciliar  */
            BEGIN
              UPDATE gncpdoc
                 SET cdtipreg = 2
                    ,flgconci = 1
                    ,dtliquid = rw_crapdat.dtmvtolt
              WHERE ROWID = rw_gncpdoc.ROWID;
              -- Incrementar totais de valor de registros integrados
              vr_tot_qtregint := vr_tot_qtregint + 1;
              vr_tot_vlregint := vr_tot_vlregint + to_number(SUBSTR(vr_setlinha,31,18))/100;
            EXCEPTION
              WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao inserir compensacao(gncpdoc): '||SQLerrm;
                 RAISE vr_exc_erro;
            END;
          END IF;

        END IF;
        -- Incrementar totais e valor de registros recebidos
        vr_tot_qtregrec := vr_tot_qtregrec + 1;
        vr_tot_vlregrec := vr_tot_vlregrec +(to_number(SUBSTR(vr_setlinha,31,18)) / 100);

      END LOOP;-- Fim leitura arquivo

      -- Comando para mover arquivo processado para a pasta salvar
      vr_comando:= 'mv '|| vr_nmdirconv|| '/' || vr_vet_nmarquiv(idx) ||' '||vr_nmdirsalv||' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_setlinha);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;

      vr_cdcritic := 190;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                     ||' - Arquivo: '|| vr_vet_nmarquiv(idx);

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      vr_cdcritic := 0;

      --Determinar o nome do arquivo que sera gerado
      vr_nom_arqimp := 'crrl524_' || lpad(idx,2,0)||'.lst';

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml('<arquivo nmarq="'||vr_nmdirconv||'/'||vr_vet_nmarquiv(idx)||'" dtmvtolt="'||to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy')||'">'||
                      '<tot_qtregint>'||vr_tot_qtregint||'</tot_qtregint>'||
                      '<tot_vlregint>'||vr_tot_vlregint||'</tot_vlregint>'||
                      '<tot_qtregrec>'||vr_tot_qtregrec||'</tot_qtregrec>'||
                      '<tot_vlregrec>'||vr_tot_vlregrec||'</tot_vlregrec>');

      vr_flg_vazio := 'S';

      -- Ler todos os registros rejeitos para gerar o relatório
      FOR rw_craprej IN cr_craprej(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        -- Indica que não está vazio
        vr_flg_vazio := 'N';
        -- Incrementar totalizadores
        vr_tot_qtregrej := vr_tot_qtregrej + 1;
        vr_tot_vllanrej := vr_tot_vllanrej + nvl(rw_craprej.vllanmto,0);
        -- Enviar dados ao XML
        pc_escreve_xml('
                  <registro>
                    <nrseqdig>'||rw_craprej.nrseqdig||'</nrseqdig>
                    <nrdconta>'||gene0002.fn_mask_conta(rw_craprej.nrdconta)||'</nrdconta>
                    <nrdocmto>'||rw_craprej.nrdocmto||'</nrdocmto>
                    <vllanmto>'||rw_craprej.vllanmto||'</vllanmto>
                    <rel_dspesqbb>'||SUBSTR(rw_craprej.cdpesqbb,04,03)||' '||
                                     SUBSTR(rw_craprej.cdpesqbb,07,03)||' '||
                                     SUBSTR(rw_craprej.cdpesqbb,12,13)||
                   '</rel_dspesqbb>
                    <dscritic>'||gene0001.fn_busca_critica(pr_cdcritic => rw_craprej.cdcritic)||'</dscritic>
                  </registro>');
      END LOOP;

      -- Enviar flag de arquivo sem rejeitos
      pc_escreve_xml('<flg_vazio>'||vr_flg_vazio||'</flg_vazio>'||
                     '<tot_qtregrej>'||vr_tot_qtregrej||'</tot_qtregrej>'||
                     '<tot_vllanrej>'||vr_tot_vllanrej||'</tot_vllanrej>');

      pc_escreve_xml('</arquivo>');
      vr_des_xml := '<?xml version="1.0" encoding="utf-8"?><crrl524>'||vr_des_xml||'</crrl524>';

      --Verificar o nome da tela anterior
      IF pr_nmtelant = 'COMPEFORA'   THEN
        -- Copiar também para o diretório rlnsv
        vr_dspath_copi := vr_nom_dirimp||'/rlnsv'||'/'||vr_nom_arqimp;
      ELSE
        -- Cópia não necessária
        vr_dspath_copi := null;
      END IF;

      -- Solicitar impressao
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl524/arquivo'  --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl524.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nom_dirimp||'/rl'||'/'||vr_nom_arqimp --> Arquivo final com codigo da agencia
                                 ,pr_sqcabrel  => 1                   --> Primeiro cabrel
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressao (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impressao
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_dspathcop => vr_dspath_copi      --> Cfme if acima
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_erro;
      END IF;

      -- Limpar tabela de rejeitados
      BEGIN
        DELETE craprej
         WHERE craprej.cdcooper = pr_cdcooper
           AND craprej.dtmvtolt = rw_crapdat.dtmvtolt
           AND craprej.cdagenci = 539;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao deletear rejeitados(craprej): '||SQLerrm;
          RAISE vr_exc_erro;
      END;

      -- Reinicializar totalizadores
      vr_tot_qtregint := 0;
      vr_tot_vlregint := 0;
      vr_tot_qtregrec := 0;
      vr_tot_vlregrec := 0;
      vr_tot_qtregrej := 0;
      vr_tot_vllanrej := 0;

    END LOOP;-- Fim leitura lista de arquivos

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
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
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;
  END;
END;
/

