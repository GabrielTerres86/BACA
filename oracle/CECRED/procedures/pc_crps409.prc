CREATE OR REPLACE PROCEDURE CECRED.pc_crps409 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps409       (Fontes/crps409.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Setembro/2004                   Ultima atualizacao: 11/06/2015

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 082.
                 Gerar arquivo com SALDO DISPONIVEL (COO404) na c/c dos
                 associados para enviar ao B. Brasil - CHEQUES COMPE.

     Alteracoes: 28/03/2005 - Gerar Saldo Disponivel + Limite Credito(Mirtes)

                 06/04/2005 - Gravar os erros no log da tela PRCITG (Evandro).

                 29/07/2005 - Alterada mensagem Log referente critica 847
                              (Diego).

                 23/09/2005 - Zerar o total para cada arquivo (Evandro).

                 23/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 01/11/2005 - Alterado limite de registros por arquivo (Evandro).

                 03/11/2005 - Corrigida leitura do bloqueio da craptab (Evandro).

                 10/01/2006 - Correcao das mensagens para o LOG (Evandro).

                 17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                 04/01/2007 - Somente enviar o arquivo de saldos se a conta for
                              do tipo - conta integracao (12,13,14,15,17,18)
                              (Evandro).

                 12/04/2007 - Enviar arquivo de saldo se conta for itg.
                              Devido aos debitos automaticos(Mirtes)

                 30/10/2012 - Ajustes para migracao contas Altovale (Tiago).

                 04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                              da craptco (Tiago).

                 16/12/2013 - Ajuste migraçao Acredi. (Rodrigo)

                 04/06/2014 - Ajuste no valor do Saldo Disponivel, buscando via
                              obtem-saldo-dia e nao mais pelo valor da SLD
                              (Guilherme/SUPERO)

                 11/09/2014 - Ajustes devido a migracao Concredi e Credimilsul
                              (Odirlei/Amcom).

                 11/06/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
                 
                 20/01/2015 - Ajuste para completar a linha do arquivo com espaço
                              até o tamanho do layout(70pos) SD389759 (Odirlei-AMcom)
                              
  ............................................................................ */
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS409';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_reto    VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro    GENE0001.typ_tab_erro;  --> Tabela com erros

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

    /* Tratar contas migradas*/
    /* Nao é necessario enviar informacoes se é uma conta migrada*/
    CURSOR cr_craptco (pr_cdcooper craptco.cdcopant%TYPE,
                       pr_nrdconta craptco.nrctaant%TYPE) IS
      SELECT craptco.nrdconta,
             craptco.cdcopant,
             craptco.nrctaant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf <> 3;
    rw_craptco cr_craptco%ROWTYPE;

    -- Verificar se conta foi migrada
    CURSOR cr_craptco2 (pr_cdcooper craptco.cdcopant%TYPE,
                       pr_nrdconta craptco.nrctaant%TYPE) IS
      SELECT craptco.nrdconta,
             craptco.cdcopant,
             craptco.nrctaant
        FROM craptco
       WHERE craptco.cdcooper = pr_cdcooper
         AND craptco.nrdconta = pr_nrdconta
         AND craptco.flgativo = 0 -- FALSE
         AND craptco.tpctatrf <> 3;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_saldos EXTR0001.typ_tab_saldos;

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
    vr_vlsddisp_tot    NUMBER;
    vr_vltotsld        NUMBER;
    vr_indvlsdd        VARCHAR2(10);
    vr_vlsddisp        crapass.vllimcre%TYPE;
    vr_cdcooper        crapass.cdcooper%TYPE;
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_nrdctitg        crapass.nrdctitg%TYPE;
    vr_digctitg        crapass.nrdctitg%TYPE;
    vr_idx             BINARY_INTEGER;

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
      vr_nmarqimp     := 'coo404'||to_char(rw_crapdat.dtmvtolt,'DDMM')||
                         to_char(vr_nrtextab,'fm00000')||'.rem';
      vr_nrregist     := 0;
      vr_vlsddisp_tot := 0;

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_clob := NULL;
      dbms_lob.createtemporary(vr_des_clob, TRUE);
      dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      /* header */
      vr_dsdlinha := RPAD( '0000000'||
                           to_char(rw_crapcop.cdageitg,'fm0000')||
                           to_char(rw_crapcop.nrctaitg,'fm00000000') ||
                           'COO404  '||
                           to_char(vr_nrtextab,'fm00000')  ||
                           to_char(rw_crapdat.dtmvtolt,'DDMMRRRR')||
                           to_char(rw_crapcop.cdcnvitg,'fm000000000'),
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

       /* saldo total */
       vr_vltotsld := nvl(vr_vlsddisp_tot,0);

       IF vr_vltotsld < 0 THEN
         vr_indvlsdd := 'D';
         vr_vltotsld := vr_vltotsld * -1;
       ELSE
         vr_indvlsdd := 'C';
       END IF;

       /* trailer */
       /* total de registros + header + trailer */
       vr_nrregist := vr_nrregist + 2;
       vr_dsdlinha := RPAD('9999999'||
                            to_char(vr_nrregist,'fm0000000000')||
                            to_char(vr_vltotsld,'fm00000000000000000')||
                            vr_indvlsdd,
                      70,' ');/* o restante sao brancos */

      -- escrever ultima linha e descarregar buffer
      pc_escreve_clob(vr_dsdlinha,TRUE);

      /* verifica se o arquivo a ser gerado tem registros "detalhe" */
      IF vr_nrregist > 2 THEN
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                         --> Cooperativa conectada
                                           ,pr_cdprogra  => 'CRPS409'                           --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                 --> Data do movimento atual
                                           ,pr_dsxml     => vr_des_clob                         --> Arquivo CLOB de dados
                                           ,pr_cdrelato  => NULL                                --> Código do relatório
                                           ,pr_dsarqsaid => vr_nom_direto||'/arq/'||vr_nmarqimp --> Arquivo final com o path
                                           ,pr_flg_gerar => 'S'                                 --> Geraçao na hora
                                           ,pr_dspathcop => vr_nom_direto||'/salvar;'||vr_dsdircop_mic||'/compel' --> copiar arquivo para os diretorios
                                           ,pr_fldoscop  => 'S'                                 --> indicativo que precisa converter copia
                                           ,pr_dscmaxcop => ' | tr -d "\032" '                  --> comando auxiliar para ux2dos
                                           ,pr_flgremarq => 'S'                                 --> remover arquivo original
                                           ,pr_des_erro  => vr_dscritic);                       --> Saída com erro


        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- dar permissão nos arquivos gerados
        gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_nom_direto  ||'/salvar/'||vr_nmarqimp);
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
                                                    ' - COO404 - '|| vr_cdprogra ||' --> '
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
           AND craptab.tpregist        = 404
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
                                              pr_tpregist => 404         );
    IF TRIM(vr_dstextab) IS NULL THEN
      -- Montar mensagem de critica
      vr_cdcritic := 393; --> Tabela de contas de convenio com B.BRASIL nao cadastrada.
      RAISE vr_exc_fimprg;
    ELSIF to_number(SUBSTR(vr_dstextab,07,01)) = 1 THEN
      vr_dscritic := 'COO404 --> PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS';
      RAISE vr_exc_fimprg;
    END IF;

    -- Inicializar arquivo
    pc_abre_arquivo(pr_dscritic => vr_dscritic);
    -- se ocorreu problema deve abortar processo
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Buscar associados
    FOR rw_crapass IN cr_crapass LOOP

      /* Limite de 49990 registros */
      IF vr_nrregist = 49988 THEN  /* precisa criar outro arquivo */
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

      vr_vlsddisp := rw_crapass.vllimcre;

      /* Nao é necessario enviar informacoes se é uma conta migrada */
      OPEN cr_craptco (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_craptco INTO rw_craptco;

      -- se localizou deve pular o registro
      IF cr_craptco%FOUND THEN
        CLOSE cr_craptco;
        continue;
      END IF;
      CLOSE cr_craptco;

      -- Verificar se é uma conta migrada
      OPEN cr_craptco2 (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_craptco2 INTO rw_craptco;

      /*Se é uma conta migrada porém tco inativo deve usar os dados na cooperativa anterior*/
      IF cr_craptco2%FOUND THEN
        vr_cdcooper := rw_craptco.cdcopant;
        vr_nrdconta := rw_craptco.nrctaant;
      ELSE
        vr_cdcooper := pr_cdcooper;
        vr_nrdconta := rw_crapass.nrdconta;
      END IF;

      CLOSE cr_craptco2;

      -- OBTENÇÃO DO SALDO DA CONTA
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => rw_crapdat,
                                  pr_cdagenci   => 1,
                                  pr_nrdcaixa   => 999,
                                  pr_cdoperad   => '996',
                                  pr_nrdconta   => vr_nrdconta,
                                  pr_vllimcre   => rw_crapass.vllimcre,
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
          vr_vlsddisp := (vr_tab_saldos(vr_idx).vlsddisp + vr_vlsddisp) * 100;
        END IF;
      END IF;

      -- somar total disponivel
      vr_vlsddisp_tot := vr_vlsddisp_tot + vr_vlsddisp;

      -- Diferenciar debito/credito
      IF vr_vlsddisp < 0 THEN
        vr_indvlsdd := 'D';
        vr_vlsddisp := vr_vlsddisp * -1;
      ELSE
        vr_indvlsdd := 'C';
      END IF;

      vr_nrregist := vr_nrregist + 1;
      vr_nrdctitg := SUBSTR(rw_crapass.nrdctitg,1,7);
      vr_digctitg := SUBSTR(rw_crapass.nrdctitg,8,1);
      vr_dsdlinha := RPAD(to_char(vr_nrregist,'fm00000')||
                          '01'||
                          RPAD(vr_nrdctitg,7,' ')||
                          RPAD(vr_digctitg,1,' ')||
                          to_char(rw_crapdat.dtmvtolt,'RRRRMMDD')||
                          to_char(vr_vlsddisp,'FM00000000000000000')||
                          vr_indvlsdd || to_char(rw_crapass.nrdconta,'fm00000000'),
                     70,' ');/* o restante sao brancos */

      -- escrever no arquivo
      pc_escreve_clob(vr_dsdlinha||chr(10));

    END LOOP; --> Fim loop crapass

    -- fechar arquivo
    pc_fecha_arquivo(pr_dscritic => vr_dscritic);
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
  END pc_crps409;
/

