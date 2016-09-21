CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps046 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    /* .............................................................................

       Programa: pc_crps046       (Fontes/crps046.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Fevereiro/93.                       Ultima atualizacao: 22/07/2014

       Dados referentes ao programa:

       Frequencia: Mensal (Batch - Background).
       Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
                   Emite: arquivo geral da COMPBB para microfilmagem.

       Alteracoes: 28/01/97 - Selecionar historicos 169 e 170 independente de
                              numero de lote (Odair).

                   03/04/97 - Alterado para mudar do /win10 para o /win12 (Deborah).

                   04/02/98 - Incluir a funcao transmic (Odair)

                   09/03/98 - Alterado para passar novo parametro para o shell
                              transmic (Deborah).

                   23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                   21/10/1999 - Buscar dados da Cooperativa no crapcop (Edson).

                   10/01/2000 - Padronizar mensagens (Deborah).

                   23/03/2000 - Tratar arquivos de microfilmagem, transmitindo
                                para Hering somente arquivos com registros (Odair)

                   02/08/2004 - Modificado caminho do win12 (Evandro).

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   05/01/2006 - Acerto no Nro Documento e Nro Lote (Ze).

                   14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/acesso
                                (Sidnei - Precise)

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   19/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

                   22/07/2014 - conversão progres -> oracle (Odirlei-AMcom)

    ............................................................................ */

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS046';

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
            ,cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    /*  Pesquisa dos lancamentos a serem microfilmados  */
    CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%type,
                       pr_dtmvtolt craplcm.dtmvtolt%type,
                       pr_dtlimite craplcm.dtmvtolt%type)IS
      SELECT  /*+ index (craplcm CRAPLCM##CRAPLCM1)*/
              craplcm.cdhistor
             ,craplcm.nrdocmto
             ,craplcm.vllanmto
             ,craplcm.cdpesqbb
             ,craplcm.nrdctabb
             ,craplcm.nrdconta
             ,craplcm.dtmvtolt
             ,nvl(craphis.indebcre,'*') indebcre
             ,to_char(craplcm.cdhistor,'fm0000')||' - '||
              nvl(craphis.dshistor,lpad('*',15,'*')) dshistor
             ,row_number() over (PARTITION BY craplcm.dtmvtolt
                                 ORDER BY craplcm.cdcooper
                                        ,craplcm.dtmvtolt
                                        ,craplcm.nrdctabb
                                        ,craplcm.nrdocmto
                                        ,craplcm.nrdolote) nrseqreg
              ,COUNT(1) over (PARTITION BY craplcm.dtmvtolt) nrtotreg

        FROM craplcm craplcm,
             craphis craphis
       WHERE craplcm.cdcooper  = pr_cdcooper
         AND craplcm.dtmvtolt >= pr_dtmvtolt
         AND craplcm.dtmvtolt <  pr_dtlimite
         AND craphis.cdcooper(+)  = pr_cdcooper
         AND craplcm.cdcooper  = craphis.cdcooper(+)
         AND craplcm.cdhistor  = craphis.cdhistor(+)
         AND (
               (craplcm.cdhistor IN (50,  -- CHEQUE COMP.
                                     56,  -- CHQ.SAL.COMP
                                     169, -- DEPOSITO BB
                                     170))-- DEPOS.BB BLOQ
                OR
               (craplcm.cdhistor = 59  AND -- CHQ.TRF.COMP.
                craplcm.nrdolote > 7000 AND
                craplcm.nrdolote < 7050)
              )
       ORDER BY craplcm.dtmvtolt
               ,craplcm.nrdctabb
               ,craplcm.nrdocmto
               ,craplcm.nrdolote;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    --Tabela de Memoria para armazenar cabecalhos
    vr_tab_cabmex CADA0001.typ_tab_char;

    --Tabela de Memoria do Clob de dados
    vr_tab_clob CADA0001.typ_tab_linha;

    ------------------------------- VARIAVEIS -------------------------------
    -- informações dos parametros genericos
    vr_dstextab     craptab.dstextab%TYPE;
    vr_cfg_regis000 craptab.dstextab%TYPE;
    vr_cfg_regis046 craptab.dstextab%TYPE;

    -- conta linhas
    vr_contlinh     INTEGER;
    vr_nrdordem     INTEGER;

    -- datas de controle
    vr_dtmvtolt     DATE;
    vr_dtlimite     DATE;
    vr_dtrefere     DATE;

    -- variavel clob para montar relatorio
    vr_des_xml      CLOB;
    --Variaveis de Indice para temp-tables
    vr_index_clob   PLS_INTEGER;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);

    -- controle de geração
    vr_flgfirst     BOOLEAN;
    vr_regexist     BOOLEAN;

    -- variaveis para manipulação dos arquivos
    vr_typ_saida    VARCHAR2(3);
    vr_comando      VARCHAR2(100);
    vr_caminho      VARCHAR2(100);
    vr_nmsufixo     VARCHAR2(100);
    vr_nmarquiv     VARCHAR2(100);

    -- registros do arquivo
    vr_reg_lindetal VARCHAR2(500);
    vr_reg_nmmesref VARCHAR2(20);
    vr_mex_indsalto VARCHAR2(1);

    --Variaveis dos Totalizadores
    vr_tot_qtcompcr INTEGER;
    vr_tot_vlcompcr NUMBER;
    vr_tot_qtcompdb INTEGER;
    vr_tot_vlcompdb NUMBER;
    vr_ger_qtcompcr INTEGER;
    vr_ger_vlcompcr NUMBER;
    vr_ger_qtcompdb INTEGER;
    vr_ger_vlcompdb NUMBER;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

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
    vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'CONFIG'
                                            ,pr_cdempres => rw_crapcop.cdcooper
                                            ,pr_cdacesso => 'MICROFILMA'
                                            ,pr_tpregist => 46);

    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 652;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Complementar mensagem
      vr_dscritic:= vr_dscritic ||' - CRED-CONFIG-NN-MICROFILMA-046';
      RAISE vr_exc_saida;
    ELSE
      --Configuracao
      vr_cfg_regis046:= vr_dstextab; /* contem CCOH na tabela */

      /*  Verifica se o programa deve rodar para esta Cooperativa  */
      IF to_number(substr(vr_cfg_regis046,1,1)) <> 1 THEN
        --Levantar Excecao
        RAISE vr_exc_fimprg;
      END IF;
    END IF;

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

    vr_contlinh := 0;
    vr_flgfirst := TRUE;
    vr_regexist := FALSE;

    -- inicio do mês anterior
    vr_dtmvtolt := trunc(add_months(rw_crapdat.dtmvtolt,-1),'MM');
    -- primeiro dia do mês atual
    vr_dtlimite := rw_crapdat.dtinimes;
    -- ultimo dia do mês anterior
    vr_dtrefere := rw_crapdat.dtultdma;
    -- sufixo para o arquivo
    vr_nmsufixo := '.'|| to_char(vr_dtrefere,'RRRRMM');

    -- iniciar variaveis
    vr_nrdordem := 0;

    vr_tot_qtcompcr := 0;
    vr_tot_vlcompcr := 0;
    vr_tot_qtcompdb := 0;
    vr_tot_vlcompdb := 0;

    vr_ger_qtcompcr := 0;
    vr_ger_vlcompcr := 0;
    vr_ger_qtcompdb := 0;
    vr_ger_vlcompdb := 0;

    vr_reg_nmmesref := GENE0001.vr_vet_nmmesano(to_char(vr_dtmvtolt,'MM'))||'/'||
                       to_char(vr_dtmvtolt,'RRRR');

    --Cabecalho 1
    vr_tab_cabmex(1):= rpad(rw_crapcop.nmrescop,20,' ')||
                       ' **** LANCAMENTOS INTEGRADOS VIA COMPEN'||
                       'SACAO DO BANCO DO BRASIL NO MES DE '||Lpad(vr_reg_nmmesref,14,' ')||
                       ' ****';
    --Cabecalho 3
    vr_tab_cabmex(3):= 'CONTA BASE     CONTA/DV   DOCUMENTO   COD. PESQUISA'||
                       '                    VALOR D/C HISTORICO            ';
    --Cabecalho 6
    vr_tab_cabmex(6):= rpad('-',102,'-');  /*102*/

    --Juntar nome com sufixo
    vr_nmarquiv:= 'cradmbb' || vr_nmsufixo;

    -- inicializar lob
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    /*  Pesquisa dos lancamentos a serem microfilmados  */
    FOR rw_craplcm IN cr_craplcm ( pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => vr_dtmvtolt,
                                   pr_dtlimite => vr_dtlimite) LOOP

      vr_reg_lindetal :=  RPAD(gene0002.fn_mask_conta(rw_craplcm.nrdctabb),10,' ') ||'   '||
                          RPAD(gene0002.fn_mask_conta(rw_craplcm.nrdconta),10,' ') ||' '||
                          LPAD(TO_CHAR(rw_craplcm.nrdocmto,'fm99999G999G0'),11,' ')               ||'   '||
                          RPAD(rw_craplcm.cdpesqbb,13,' ')                         ||'   '||
                          LPAD(TO_CHAR(rw_craplcm.vllanmto,'fm999G999G999G999G990D00'),22,' ')||'  '||
                          RPAD(rw_craplcm.indebcre,1,' ')                          ||'  '||
                          RPAD(rw_craplcm.dshistor,21,' ');

      -- Simulando first-of
      IF rw_craplcm.nrseqreg = 1 THEN
        --Cabecalho 2
        vr_tab_cabmex(2) := 'DATA: '|| to_char(rw_craplcm.dtmvtolt,'DD/MM/YYYY')||
                             rpad(' ',77,' ')|| 'SEQ.: ';

        --Se for o primeiro - dtmvtolt
        IF vr_flgfirst THEN
          --Mudar flag
          vr_flgfirst:= FALSE;
          --Indicador Salto
          vr_mex_indsalto := '+';

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
      END IF; -- fim first-of

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
      END IF; -- Fim linha 84

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
      IF rw_craplcm.indebcre = 'D' THEN
        --Acumular Quantidade Debitos
        vr_tot_qtcompdb:= nvl(vr_tot_qtcompdb,0) + 1;
        --Acumular Valor dos Debitos
        vr_tot_vlcompdb:= nvl(vr_tot_vlcompdb,0) + nvl(rw_craplcm.vllanmto,0);
      ELSIF rw_craplcm.indebcre = 'C' THEN
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
        END IF; -- Fim vr_contlinh > 80
      END IF; --LAST-OF

      vr_regexist := TRUE;
    END LOOP; -- fim for craplcm

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

    -- descarregar buffer
    pc_escreve_xml(pr_des_dados => null, pr_fecha_xml => TRUE);

    --Verificar tamanho e Gerar Arquivo Dados
    IF dbms_lob.getlength(vr_des_xml) > 0 THEN
      -- Geracao do arquivo
      dbms_xslprocessor.clob2file(vr_des_xml, vr_caminho, vr_nmarquiv ,0);
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    --Transmitir Arquivo para CIA HERING
    IF TO_NUMBER(SUBSTR(vr_cfg_regis046,3,1)) = 1 AND vr_regexist THEN
      /*  Transm. para CIA HERING  */
      --Montar Comando Unix para transmitir
      vr_comando:= 'transmic . '||vr_caminho||'/'||vr_nmarquiv||
                   '  AX/'||upper(vr_cfg_regis000)||'/MICMBB '||gene0002.fn_busca_time;
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
  END pc_crps046;
/

