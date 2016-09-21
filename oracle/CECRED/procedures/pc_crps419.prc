CREATE OR REPLACE PROCEDURE CECRED.pc_crps419 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps419       (Fontes/crps419.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro/Diego
     Data    : Abril/2006                     Ultima atualizacao: 04/02/2016

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 99.
                 Gerar arquivo com LIMITES DE DEBITO dos associados para enviar
                 ao B. Brasil (COO401).

     Alteracoes: 22/05/2006 - Incluido codigo da cooperativa nas leituras das
                              tabelas (Diego).

                 29/05/2006 - Efetuado acerto limite (Mirtes)

                 30/06/2006 - Modificado aux_vllimdeb para INTEGER (Diego).

                 25/07/2006 - Incluida verificacao de bloqueio e mensagem para
                              enviar arquivo (Evandro).

                 26/07/2007 - Saldo disponivel do dia - BO(b1wgen0001)(Guilherme).

                 20/05/2008 - Calcular dia valido para dtlimdeb (Guilherme).

                 23/06/2010 - Ajustar tt-saldo para o TAA (Magui).

                 22/09/2010 - Foi feito a retirada de temp-table e chamado
                              a BO b1wgen0001tt.i (Adriano).

                 12/01/2011 - Inserido o format de 40 para o campo nmprimtl
                              (Kbase - Gilnei)

                 24/04/2012 - Inserido procedure gera_limite_debito_bb
                              (David Kruger).

                 29/10/2012 - Ajustes para migracao contas Altovale (Tiago).

                 04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                              da craptco (Tiago).

                 09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                              a escrita será PA (André Euzébio - Supero).

                 16/12/2013 - Ajuste migraçao Acredi. (Rodrigo)

                 27/02/2014 - Incluir tratamento para o limite do debito para o
                              feriado do carnaval (Lucas R.)

                 11/09/2014 - Ajustes devido a migracao Concredi e Credimilsul
                              (Odirlei/Amcom).

                 25/11/2014 - Alterada quantidade de dias limite devido vencimento
                              de contrato BB (Rodrigo).

                 26/11/2014 - Tratamento pra incorporaçao da credimilsul,
                              para permitir apos a incorporacao gerar o arquivo na
                              credimilsul, porem lendo as informaçoes na SCRcred
                              (Odirlei-Amcom)

                 28/11/2014 - Retornada quantidade de dias limite devido
                              prorrogacao do vencimento contrato BB (Rodrigo).

                 23/12/2014 - Ajuste para quando for executado pela 15-Credimilsul
                              buscar a data da nova cooperativa 13-SCrcred(Odirlei-AMcom)

                 12/06/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
                 
                 20/01/2015 - Ajuste para completar a linha do arquivo com espaço
                              até o tamanho do layout(70pos) SD389759 (Odirlei-AMcom)
                 
                 04/02/2016 - Fechar o cursor cr_craplau que nao era fechado
                              (Douglas - Chamado 398079)
  ............................................................................ */
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS419';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_reto   VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro   GENE0001.typ_tab_erro;  --> Tabela com erros

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdageitg
            ,cop.nrctaitg
            ,cop.cdcnvitg
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- buscar associados
    CURSOR cr_crapass IS
      SELECT ass.vllimcre,
             ass.nrdconta,
             ass.nrdctitg
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdctitg IS NOT NULL
         AND ass.flgctitg = 2;

    -- Buscar dados dos cartões
    CURSOR cr_crawcrd IS
      SELECT ass.cdcooper,
             ass.nrdconta,
             ass.vllimcre,
             ass.vllimdeb,
             ass.nrdctitg,
             ass.cdagenci,
             ass.nmprimtl,
             row_number() over (PARTITION BY ass.cdcooper, ass.nrdconta
                                  ORDER BY ass.cdcooper, ass.nrdconta ) nrseqass -- simula first-of
        FROM crawcrd crd
            ,crapass ass
       WHERE crd.cdcooper = pr_cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.cdcooper = crd.cdcooper
         AND ass.nrdconta = crd.nrdconta
         AND crd.insitcrd = 4
         AND crd.cdadmcrd IN (83,84,85,86,87,88)
       ORDER BY ass.cdcooper, ass.nrdconta;

    /* Tratar contas migradas*/
    /* Nao é necessario enviar informacoes se é uma conta migrada*/
    CURSOR cr_craptco (pr_cdcooper craptco.cdcopant%TYPE,
                       pr_nrdconta craptco.nrctaant%TYPE) IS
      SELECT craptco.nrdconta,
             craptco.cdcooper,
             crapass.vllimcre, -- limite de credito na nova coop
             craptco.cdcopant,
             craptco.nrctaant,
             craptco.flgativo
        FROM craptco, crapass
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf <> 3
         AND craptco.cdcooper = crapass.cdcooper
         AND craptco.nrdconta = crapass.nrdconta;
    rw_craptco cr_craptco%ROWTYPE;

    -- Verificar se conta foi migrada
    CURSOR cr_craptco2 (pr_cdcooper craptco.cdcopant%TYPE,
                        pr_nrdconta craptco.nrctaant%TYPE) IS
      SELECT craptco.nrdconta,
             craptco.cdcooper,
             crapass.vllimcre, -- limite de credito na nova coop
             craptco.cdcopant,
             craptco.nrctaant,
             craptco.flgativo
        FROM craptco, crapass
       WHERE craptco.cdcooper = pr_cdcooper
         AND craptco.nrdconta = pr_nrdconta
         AND craptco.flgativo = 0 -- FALSE
         AND craptco.tpctatrf <> 3
         AND craptco.cdcooper = crapass.cdcooper
         AND craptco.nrdconta = crapass.nrdconta;

    -- Verificar feriado do carnaval
    CURSOR cr_crapfer (pr_cdcooper IN crapfer.cdcooper%TYPE,
                       pr_dtmvtolt IN crapfer.dtferiad%TYPE)IS
      SELECT crapfer.dtferiad
        FROM crapfer
       WHERE crapfer.cdcooper = pr_cdcooper
         AND crapfer.dsferiad LIKE '%CARNAVAL%'
         AND crapfer.dtferiad = pr_dtmvtolt + 4;
    rw_crapfer cr_crapfer%ROWTYPE;

    -- Buscar lançamentos
    CURSOR cr_craplau (pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE,
                       pr_dtmvtolt  craplau.dtmvtopg%TYPE,
                       pr_cdhistor  craplau.cdhistor%TYPE)IS
      SELECT 1
        FROM craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.nrdconta = pr_nrdconta
         AND craplau.dtmvtopg = pr_dtmvtolt
         AND craplau.cdhistor = pr_cdhistor;
    rw_craplau cr_craplau%ROWTYPE;

    -- Buscar dados da agencia
    CURSOR cr_crapage (pr_cdcooper crapage.cdcooper%TYPE,
                       pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT crapage.nmresage
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_saldos EXTR0001.typ_tab_saldos;

    /* para os que foram enviados */
    TYPE typ_reg_enviados
         IS RECORD (cdagenci crapass.cdagenci%TYPE,
                    nrdconta crapass.nrdconta%TYPE,
                    nrdctitg crapass.nrdctitg%TYPE,
                    nmprimtl crapass.nmprimtl%TYPE,
                    vllimdeb crapass.vllimdeb%TYPE);
    TYPE typ_tab_enviados IS TABLE OF typ_reg_enviados
      INDEX BY VARCHAR2(30); -- coop + agen + nrdconta
    vr_tab_enviados typ_tab_enviados;

    ------------------------------- VARIAVEIS -------------------------------
    -- Variáveis para armazenar as informações em XML
    vr_des_clob         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto      VARCHAR2(100);
    vr_dsdircop_mic    VARCHAR2(100);
    vr_dsdlinha        VARCHAR2(500);
    vr_nmarqlog        VARCHAR2(100);

    vr_dstextab        craptab.dstextab%TYPE;
    vr_nrtextab        NUMBER;
    vr_nmarqimp        VARCHAR2(200);

    vr_nrregist        NUMBER;
    vr_vltotlim        NUMBER;
    vr_vltotsld        NUMBER;
    vr_indvlsdd        VARCHAR2(10);
    vr_vllimdeb        crapass.vllimcre%TYPE;
    vr_cdcooper        crapass.cdcooper%TYPE;
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_nrdctitg        crapass.nrdctitg%TYPE;
    vr_digctitg        crapass.nrdctitg%TYPE;
    vr_vllimcre        crapass.vllimcre%TYPE;
    vr_idx             BINARY_INTEGER;
    vr_data            DATE;
    vr_dtlimdeb        DATE;
    vr_flglau          NUMBER := 0;
    vr_valortot        NUMBER := 0;
    vr_idxenv          VARCHAR2(30);

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

    -- Abrir/inicializar arquivo
    PROCEDURE pc_abre_arquivo(pr_dscritic OUT VARCHAR2) IS
    BEGIN
      vr_nrtextab     := SUBSTR(vr_dstextab,1,5);
      vr_nmarqimp     := 'coo401'||to_char(rw_crapdat.dtmvtolt,'DDMM')||
                         to_char(vr_nrtextab,'fm00000')||'.rem';
      vr_nrregist     := 0;
      vr_vltotlim     := 0;

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_clob := NULL;
      dbms_lob.createtemporary(vr_des_clob, TRUE);
      dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      /* header */
      vr_dsdlinha := RPAD('0000000'||
                           to_char(rw_crapcop.cdageitg,'fm0000')||
                           to_char(rw_crapcop.nrctaitg,'fm00000000') ||
                           'COO401  '||
                           to_char(vr_nrtextab,'fm00000')  ||
                           to_char(rw_crapdat.dtmvtolt,'DDMMRRRR')||
                           to_char(rw_crapcop.cdcnvitg,'fm000000000')||
                           '00000',
                     70,' ');/* o restante sao brancos */

      pc_escreve_clob(vr_dsdlinha || chr(10));

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel abrir arquivo: '||SQLERRM;
    END pc_abre_arquivo;

    -- fechar/gerar arquivo
    PROCEDURE pc_fecha_arquivo(pr_dscritic OUT VARCHAR2) IS
    BEGIN

       /* trailer */
       /* total de registros + header + trailer */
       vr_nrregist := vr_nrregist + 2;
       vr_dsdlinha := RPAD('9999999'||
                            to_char(vr_nrregist,'fm000000000')||
                            to_char(vr_vltotlim,'fm000000000000000')||
                            'C',
                      70,' ');/* o restante sao brancos */

      -- escrever ultima linha e descarregar buffer
      pc_escreve_clob(vr_dsdlinha,TRUE);

      /* verifica se o arquivo a ser gerado tem registros "detalhe" */
      IF vr_nrregist > 2 THEN
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                         --> Cooperativa conectada
                                           ,pr_cdprogra  => 'CRPS419'                           --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                 --> Data do movimento atual
                                           ,pr_dsxml     => vr_des_clob                         --> Arquivo CLOB de dados
                                           ,pr_cdrelato  => NULL                                --> Código do relatório
                                           ,pr_dsarqsaid => vr_nom_direto||'/salvar/'||vr_nmarqimp --> Arquivo final com o path
                                           ,pr_flg_gerar => 'S'                                 --> Geraçao na hora
                                           ,pr_dspathcop => vr_dsdircop_mic||'/compel'          --> copiar arquivo para os diretorios
                                           ,pr_fldoscop  => 'S'                                 --> indicativo que precisa converter copia
                                           ,pr_dscmaxcop => ' | tr -d "\032" '                  --> comando auxiliar para ux2dos
                                           ,pr_flgremarq => 'N'                                 --> remover arquivo original
                                           ,pr_des_erro  => vr_dscritic);                       --> Saída com erro


        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- dar permissão nos arquivos gerados
        gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_dsdircop_mic||'/compel/'||vr_nmarqimp);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_clob);
        dbms_lob.freetemporary(vr_des_clob);

      END IF;

      vr_cdcritic := 847; --> ATENCAO !! Envie o arquivo pelo Gerenciador
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' ||
                                                    ' - COO401 - '|| vr_cdprogra ||' --> '
                                                    || vr_dscritic||' - '|| vr_nmarqimp);

      -- atualizar sequencial do arquivo
      BEGIN
        UPDATE craptab
           SET craptab.dstextab     = TO_CHAR(vr_nrtextab + 1,'fm00000') ||
                                      SUBSTR(craptab.dstextab,6)
         WHERE craptab.cdcooper        = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres        = 0
           AND upper(craptab.cdacesso) = 'NRARQMVITG'
           AND craptab.tpregist        = 401
        RETURNING craptab.dstextab INTO vr_dstextab;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar craptab(NRARQMVITG): '||SQLERRM;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel fechar arquivo: '||SQLERRM;
    END pc_fecha_arquivo;

    /* Gera o arquivo de prcitg.log informando o valor
      total limite de debito para o Banco do Brasil. */
    PROCEDURE pc_gera_limite_debito_bb (pr_cdcooper IN INTEGER,
                                        pr_dtmvtolt IN DATE,
                                        pr_vltotlim IN NUMBER,
                                        pr_valortot IN NUMBER,
                                        pr_dscritic OUT VARCHAR2) IS
    BEGIN
      -- atualizar sequencial do arquivo
      BEGIN
        UPDATE craptab
           SET craptab.dstextab     = SUBSTR(craptab.dstextab,1,52)||
                                      TO_CHAR(pr_valortot,'fm000000000D00')||
                                      SUBSTR(craptab.dstextab,65)

         WHERE craptab.cdcooper        = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'USUARI'
           AND craptab.cdempres        = 11
           AND upper(craptab.cdacesso) = 'VLCONTRCRD'
           AND craptab.tpregist        = 0;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar craptab(VLCONTRCRD): '||SQLERRM;
      END;

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Erro tratato
                                ,pr_nmarqlog     => 'prcitg.log'
                                ,pr_des_log      => to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' - '||
                                                    to_char(sysdate,'hh24:mi:ss')||' - ' ||
                                                    ' - COO401 - '|| vr_cdprogra ||' --> '||
                                                    'Total valor do limite de saque enviado ao B.Brasil R$:'||
                                                    to_char(pr_valortot, 'fm999G999G990D00'));


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel atualizar limite BB: '||SQLERRM;
    END pc_gera_limite_debito_bb;

    -- Procedimento para geracao do relatorio
    PROCEDURE pc_rel_enviados(pr_dscritic OUT VARCHAR2) IS
      vr_cdagenci NUMBER;
    BEGIN

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_clob := NULL;
      dbms_lob.createtemporary(vr_des_clob, TRUE);
      dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><crrl382>');

      -- Buscar primeiro index
      vr_idxenv := vr_tab_enviados.first;
      vr_cdagenci := -1;

      -- varrer tabela de enviados
      WHILE vr_idxenv IS NOT NULL LOOP
        -- verificar se mudou a agencia deve iniciar o nó do xml
        IF vr_cdagenci <> vr_tab_enviados(vr_idxenv).cdagenci THEN

          -- se nao for o primeira agencia deve fechar
          -- a tag já iniciada
          IF vr_cdagenci <> -1 THEN
            pc_escreve_clob('</agencia>');
          END IF;

          -- Buscar dados da agencia
          OPEN cr_crapage (pr_cdcooper => pr_cdcooper,
                           pr_cdagenci => vr_tab_enviados(vr_idxenv).cdagenci);
          FETCH cr_crapage INTO rw_crapage;
          CLOSE cr_crapage;
          vr_cdagenci := vr_tab_enviados(vr_idxenv).cdagenci;

          -- criar nó
          pc_escreve_clob('<agencia dsagenci="PA: '|| vr_tab_enviados(vr_idxenv).cdagenci||' - '||
                                                     rw_crapage.nmresage  ||'">');
        END IF;

        -- incluir tag de registros
        pc_escreve_clob('<registro>
                           <nrdconta>'|| gene0002.fn_mask_conta(vr_tab_enviados(vr_idxenv).nrdconta)  ||'</nrdconta>
                           <nrdctitg>'|| gene0002.fn_mask(vr_tab_enviados(vr_idxenv).nrdctitg,'9.999.999-9')  ||'</nrdctitg>
                           <nmprimtl>'|| substr(vr_tab_enviados(vr_idxenv).nmprimtl,1,40)  ||'</nmprimtl>
                           <vllimdeb>'|| vr_tab_enviados(vr_idxenv).vllimdeb  ||'</vllimdeb>
                         </registro>');


        vr_idxenv := vr_tab_enviados.next(vr_idxenv);
      END LOOP;

      -- verificar se foi aberta a TAG
      IF vr_cdagenci <> -1 THEN
        pc_escreve_clob('</agencia>');
      END IF;

      -- fechar tag principal e descarregar buffer
      pc_escreve_clob('</crrl382>',TRUE);

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_clob          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl382/agencia/registro'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl382.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl382.lst'                --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'S'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_clob);
      dbms_lob.freetemporary(vr_des_clob);
   EXCEPTION
     WHEN vr_exc_saida THEN
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       pr_dscritic := 'Não foi gerar relatorio crrl382: '||SQLERRM;
    END pc_rel_enviados;


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
    OPEN btch0001.cr_crapdat(pr_cdcooper => (CASE pr_cdcooper
                                               -- se for cooperativa 15, buscar data da coop migrada,
                                               -- pois 15 não tem mais processo
                                               WHEN 15 THEN 13
                                               ELSE pr_cdcooper
                                               END));
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
    vr_nmarqlog := 'prcitg_'|| to_char(rw_crapdat.dtmvtolt,'RRRRMMDD')||'.log';

    -- Busca do diretório base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);

    -- Busca do diretório micros da cooperativa
    vr_dsdircop_mic := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros
                                            ,pr_cdcooper => pr_cdcooper);

    -- Buscar numero do arquivo
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                              pr_nmsistem => 'CRED'      ,
                                              pr_tptabela => 'GENERI'    ,
                                              pr_cdempres => 0           ,
                                              pr_cdacesso => 'NRARQMVITG',
                                              pr_tpregist => 401         );
    IF TRIM(vr_dstextab) IS NULL THEN
      -- Montar mensagem de critica
      vr_cdcritic := 393; --> Tabela de contas de convenio com B.BRASIL nao cadastrada.
      RAISE vr_exc_fimprg;
    ELSIF to_number(SUBSTR(vr_dstextab,07,01)) = 1 THEN
      vr_dscritic := 'COO401 --> PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS';
      RAISE vr_exc_fimprg;
    END IF;

    -- Inicializar arquivo
    pc_abre_arquivo(pr_dscritic => vr_dscritic);
    -- se ocorreu problema deve abortar processo
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Buscar informações dos cartões
    FOR rw_crawcrd IN cr_crawcrd LOOP

      -- se for a primeira vez que a conta aparece
      IF rw_crawcrd.nrseqass = 1 THEN -- simula First-of

        /* Nao é necessario enviar informacoes se é uma conta migrada */
        OPEN cr_craptco (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crawcrd.nrdconta);
        FETCH cr_craptco INTO rw_craptco;

        IF pr_cdcooper = 15 THEN

          /* Apos a incorporaçao ainda será gerado o arquivo na
                credimilsul, porém  deverá buscar informaçoes na nova coop. */
          IF cr_craptco%FOUND AND
             rw_craptco.flgativo = 1 THEN
            vr_cdcooper := rw_craptco.cdcooper;
            vr_nrdconta := rw_craptco.nrdconta;
            vr_vllimcre := rw_craptco.vllimcre; -- limite de credito na coop nova
          ELSE -- senao achou tco usar dados do cooperado
            vr_cdcooper := pr_cdcooper;
            vr_nrdconta := rw_crawcrd.nrdconta;
            vr_vllimcre := rw_crawcrd.vllimcre;
          END IF;

        -- se localizou deve pular o registro
        ELSIF cr_craptco%FOUND THEN
          CLOSE cr_craptco;
          continue;
        ELSE

          -- Verificar se é uma conta migrada
          OPEN cr_craptco2 (pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => rw_crawcrd.nrdconta);
          FETCH cr_craptco2 INTO rw_craptco;

          /*Se é uma conta migrada deve usar os dados na cooperativa anterior*/
          IF cr_craptco2%FOUND AND
             /* porém se a migraçao da concredi ou credimilsul,
              até da data estipulada nao deve usar as informaçoes antigas*/
             /* comentado pois migraçao da credimilsul acontecerá em outro periodo   18/11/2014*/
             NOT((rw_craptco.cdcopant = 4 /*OR craptco.cdcopant = 15*/ ) AND
                  rw_crapdat.dtmvtolt < to_date('18/11/2014','DD/MM/RRRR'))
             THEN
            vr_cdcooper := rw_craptco.cdcopant;
            vr_nrdconta := rw_craptco.nrctaant;
            vr_vllimcre := rw_crawcrd.vllimcre;
          ELSE
            vr_cdcooper := pr_cdcooper;
            vr_nrdconta := rw_crawcrd.nrdconta;
            vr_vllimcre := rw_crawcrd.vllimcre;
          END IF;

          CLOSE cr_craptco2;
        END IF;
        CLOSE cr_craptco;

        -- OBTENÇÃO DO SALDO DA CONTA
        extr0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => 1,
                                    pr_nrdcaixa   => 999,
                                    pr_cdoperad   => '996',
                                    pr_nrdconta   => vr_nrdconta,
                                    pr_vllimcre   => vr_vllimcre,
                                    pr_tipo_busca => 'A',
                                    pr_dtrefere   => rw_crapdat.dtmvtolt,
                                    pr_des_reto   => vr_des_reto,
                                    pr_tab_sald   => vr_tab_saldos,
                                    pr_tab_erro   => vr_tab_erro);

         -- Verifica se deu erro
        IF vr_des_reto = 'OK' THEN
          vr_idx := vr_tab_saldos.first; -- Vai para o primeiro registro
          -- se localizou saldo disponivel
          IF vr_idx IS NOT NULL THEN

            -- verificar sado positivo
            IF vr_tab_saldos(vr_idx).vlsddisp > 0 THEN
              IF vr_tab_saldos(vr_idx).vllimcre > 0 THEN
                vr_vllimdeb := round(vr_tab_saldos(vr_idx).vllimcre) + round(vr_tab_saldos(vr_idx).vlsddisp);
              ELSE
                vr_vllimdeb := vr_tab_saldos(vr_idx).vlsddisp;
              END IF;
            ELSE -- Saldo Negativo
              IF vr_tab_saldos(vr_idx).vllimcre > vr_tab_saldos(vr_idx).vlsddisp THEN
                vr_vllimdeb := round(vr_tab_saldos(vr_idx).vllimcre) + round(vr_tab_saldos(vr_idx).vlsddisp);
              ELSE
                vr_vllimdeb := 0;
              END IF;
            END IF;

          END IF;

          -- Verificar feriado do carnaval
          OPEN cr_crapfer (pr_cdcooper => pr_cdcooper,
                           pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_crapfer INTO rw_crapfer;
          -- se localizou
          IF cr_crapfer%FOUND THEN
            CLOSE cr_crapfer;
            -- verificar dias que antecedem o feriado
            vr_data := rw_crapdat.dtmvtolt + 1;
            LOOP
              -- sair qnd ultrapassar a data do feriado
              EXIT WHEN vr_data > rw_crapfer.dtferiad;

              IF  pr_cdcooper IN (1,6,    /* Viacredi - Credifiesc   */
                                  7,8,    /* Credcrea - Credelesc    */
                                  10)THEN /* Credicomin  */
                -- Buscar lançamentos
                OPEN cr_craplau (pr_cdcooper  => pr_cdcooper,
                                 pr_nrdconta  => vr_nrdconta,
                                 pr_dtmvtolt  => vr_data,
                                 pr_cdhistor  => 658);
                FETCH cr_craplau INTO rw_craplau;
                -- se localizou lançamento
                IF cr_craplau%FOUND THEN
                  -- Fechar o Cursor 
                  CLOSE cr_craplau;
                  -- marcar como localizado
                  vr_flglau := 1;

                  CASE pr_cdcooper
                    WHEN 1 THEN
                      /* Limitar a R$ 20.000,00 */
                      IF vr_vllimdeb > 20000  THEN
                        vr_vllimdeb := 20000;
                      END IF;
                    WHEN 6 THEN
                      /* Limitar a R$ 3.000,00 */
                      IF vr_vllimdeb > 3000   THEN
                        vr_vllimdeb := 3000;
                      END IF;
                    WHEN 7 THEN
                      /* Limitar a R$ 9.500,00 */
                      IF vr_vllimdeb > 9500   THEN
                        vr_vllimdeb := 9500;
                      END IF;
                    WHEN 8 THEN
                      /* Limitar a R$ 2.400,00 */
                      IF vr_vllimdeb > 2400   THEN
                        vr_vllimdeb := 2400;
                      END IF;
                    WHEN 10 THEN
                      /* Limitar a R$ 3.700,00 */
                      IF vr_vllimdeb > 3700   THEN
                        vr_vllimdeb := 3700;
                      END IF;
                    ELSE NULL;
                  END CASE;
                ELSE
                  -- Fechar o Cursor 
                  CLOSE cr_craplau;
                END IF;
              ELSE -- para as demais cooperativas
                IF rw_crawcrd.vllimdeb < vr_vllimdeb THEN
                  vr_vllimdeb := rw_crawcrd.vllimdeb;
                END IF;
              END IF;
              -- incrementar 1 dia
              vr_data := vr_data + 1;
            END LOOP;
          ELSE
            CLOSE cr_crapfer;
            IF rw_crawcrd.vllimdeb < vr_vllimdeb THEN
              vr_vllimdeb := rw_crawcrd.vllimdeb;
            END IF;
          END IF; -- FIM IF crapfer

          -- se nao encotrou craplau
          IF vr_flglau <> 1 THEN
            IF rw_crawcrd.vllimdeb < vr_vllimdeb THEN
              vr_vllimdeb := rw_crawcrd.vllimdeb;
            END IF;
          END IF;

          -- se valor for negativo, deve substituir por zero
          IF vr_vllimdeb < 0 THEN
            vr_vllimdeb := 0;
          END IF;

          /* Limite de 1998 registros */
          IF vr_nrregist = 1998 THEN  /* precisa criar outro arquivo */
            -- fechar arquivo
            pc_fecha_arquivo(pr_dscritic => vr_dscritic);
            -- se ocorreu problema deve abortar processo
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Inicializar novo arquivo
            pc_abre_arquivo(pr_dscritic => vr_dscritic);
            -- se ocorreu problema deve abortar processo
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- arredondar valor
          vr_vllimdeb := round(vr_vllimdeb);

          /* Validade limite */
          vr_dtlimdeb :=  gene0005.fn_valida_dia_util
                                      (pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => rw_crapdat.dtmvtolt + 5,
                                       pr_tipo     => 'P',
                                       pr_feriado  => TRUE);

          vr_nrregist := vr_nrregist + 1;
          vr_nrdctitg := SUBSTR(rw_crawcrd.nrdctitg,1,7);
          vr_digctitg := SUBSTR(rw_crawcrd.nrdctitg,8,1);
          vr_dsdlinha := RPAD( to_char(vr_nrregist,'fm00000')||
                               '01'||
                               RPAD(vr_nrdctitg,7,' ')||
                               RPAD(vr_digctitg,1,' ')||
                               to_char(vr_vllimdeb,'fm000000000')||
                               'C'|| to_char(vr_dtlimdeb,'DDMMRRRR')||
                               to_char(rw_crawcrd.nrdconta,'fm00000000'),
                         70,' ');/* o restante sao brancos */

          -- escrever no arquivo
          pc_escreve_clob(vr_dsdlinha||chr(10));

          -- totalizar os limites
          vr_vltotlim := vr_vltotlim + vr_vllimdeb;
          vr_valortot := vr_valortot + vr_vllimdeb;

          vr_idxenv := lpad(pr_cdcooper,5,'0')||
                       lpad(rw_crawcrd.cdagenci,10,'0')||
                       lpad(rw_crawcrd.nrdconta,10,'0');
          -- guardar dados enviados para o relatorio
          vr_tab_enviados(vr_idxenv).cdagenci := rw_crawcrd.cdagenci;
          vr_tab_enviados(vr_idxenv).nrdconta := rw_crawcrd.nrdconta;
          vr_tab_enviados(vr_idxenv).nrdctitg := rw_crawcrd.nrdctitg;
          vr_tab_enviados(vr_idxenv).nmprimtl := rw_crawcrd.nmprimtl;
          vr_tab_enviados(vr_idxenv).vllimdeb := vr_vllimdeb;

        END IF; -- Fim retorno OK buscar saldo

      END IF; -- fim first-of ass.nrdconta
    END LOOP; --> Fim loop crapass

    -- atualizar limite enviado ao BB
    pc_gera_limite_debito_bb (pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                              pr_vltotlim => vr_vltotlim,
                              pr_valortot => vr_valortot,
                              pr_dscritic => vr_dscritic);

    -- se ocorreu problema deve abortar processo
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- fechar arquivo
    pc_fecha_arquivo(pr_dscritic => vr_dscritic);
    -- se ocorreu problema deve abortar processo
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Gerar relatorio de contas enviadas crrl382
    pc_rel_enviados(pr_dscritic => vr_dscritic);

    -- se ocorreu problema deve abortar processo
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;


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
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
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
  END pc_crps419;
/
