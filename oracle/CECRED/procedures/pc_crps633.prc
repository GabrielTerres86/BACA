CREATE OR REPLACE PROCEDURE CECRED.pc_crps633(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
BEGIN
  /* ............................................................................

    Programa: pc_crps633                                 (Fontes/crps633.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas R.
    Data    : DEZEMBRO/2012                      Ultima atualizacao: 20/03/2014

    Dados referentes ao programa:

    Frequencia: Mensal.
    Objetivo  : Responsavel por gerar o arquivo txt do Censo do Cooperado.

    Alteracoes: 15/03/2013 - Não é necessário converter arquivo para formato
                             WINDOWS/DOS (Oscar).

                02/12/2013 - Conversão Progress >> PLSQL (Jean Michel).

                04/02/2014 - Incluir validacao de conta migrada da Acredi
                             para Viacredi (Lucas R.)

                21/02/2014 - Manutenção crps633-010001.p.pdf - 201402 (Edison-AMcom)

  .......................................................................... */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- CÓDIGO DO PROGRAMA
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS633';

    -- TRATAMENTO DE ERROS
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
--    vr_typ_said VARCHAR(20);

    -- VARIAVEIS DIVERSAS
    vr_dtmvtolt VARCHAR2(10);
    vr_semestre VARCHAR2(02);
    vr_dtainici DATE;--VARCHAR2(10);
    vr_dtafinal DATE;--VARCHAR2(10);
    vr_nrdocnpj VARCHAR2(14);
    vr_nrcnpjco VARCHAR2(08);
    vr_dsnomscr VARCHAR2(59);
    vr_dddcoope VARCHAR2(02);
    vr_telcoope VARCHAR2(09);
    vr_cdcidade INTEGER;
    vr_inpessoa INTEGER;
    vr_situcoop INTEGER;
    vr_situacao INTEGER;
    vr_dtultatu DATE;
    vr_dtadmiss DATE;

    -- variaveis de escrita CLOB
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    -- VARIAVEIS DE ARQUIVOS
    vr_nmarqimp   VARCHAR2(500);

    -- VARIAVEL DE INDICE DA PLTABLE
    vr_ind_cens VARCHAR2(100);

    -- DEFINIÇÃO DE TIPO DE REGISTRO
    TYPE typ_reg_censo IS RECORD(
      cdcooper crapcop.cdcooper%TYPE -- CODIGO DA COOPERATIVA
      ,nrdconta crapass.nrdconta%TYPE -- NUMERO DA CONTA
      ,nrcpfcgc crapass.nrcpfcgc%TYPE -- NUMERO DE CPF OU CNPJ
      ,inpessoa crapass.inpessoa%TYPE -- TIPO DE PESSOA
      ,dtadmiss crapass.dtadmiss%TYPE -- DATA DE ADMISSAO
      ,cdcidade INTEGER -- CODIGO DA CIDADE
      ,situacao INTEGER -- SITUACAO DO COOPERADO
      ,dtultatu DATE -- DATA DA ULTIMA ATUALIZACAO
      ,vltizado DECIMAL(18) := 0
      ,vltinzar DECIMAL(18) := 0);

    -- PL TABLE
    TYPE typ_tab_censo IS TABLE OF typ_reg_censo INDEX BY VARCHAR2(16); -- PK DA PL TABLE NRCPFCGC

    -- VETOR QUE ARMAZENARÁ UMA INSTANCIA COM O FORMATO DA TABELA ACIMA
    vr_tab_censo typ_tab_censo;
    ------------------------------- CURSORES ---------------------------------

    -- BUSCA DOS DADOS DA COOPERATIVA
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nmextcop,
             cop.dsdircop,
             cop.nrdocnpj,
             cop.dsnomscr,
             cop.dstelscr
        FROM crapcop cop
       WHERE cop.cdcooper <> 3;

    rw_crapcop cr_crapcop%ROWTYPE;

    -- BUSCA DE ASSOCIADOS
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT ass.dtadmiss,
             ass.inpessoa,
             ass.dtdemiss,
             ass.cdcooper,
             ass.nrdconta,
             ass.nrcpfcgc,
             ass.dtelimin
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
       ORDER BY ass.cdcooper, ass.nrdconta;

    rw_crapass cr_crapass%ROWTYPE;

    -- BUSCA DE CONTAS TRANSFERIDAS DA VIACREDI
    CURSOR cr_craptco(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_cdcopant IN crapcop.cdcooper%TYPE) IS
      SELECT tco.cdcooper, tco.cdcopant, tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.nrdconta = pr_nrdconta
         AND tco.cdcopant = pr_cdcopant;

    rw_craptco cr_craptco%ROWTYPE;

    -- BUSCA DE CONTAS TRANSFERIDAS DA VIACREDI
    CURSOR cr_craptco_II(pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE,
                         pr_cdcopant IN crapcop.cdcooper%TYPE) IS
      SELECT tco.cdcooper, tco.cdcopant, tco.nrdconta
        FROM craptco tco
       WHERE tco.cdcooper = pr_cdcooper
         AND tco.nrctaant = pr_nrdconta
         AND tco.cdcopant = pr_cdcopant;

    rw_craptco_II cr_craptco_II%ROWTYPE;

    --Contas transferidas entre cooperativas com origem na
    --cooperativa pr_cdcopant e agencias 2,4,6,7,11.
    CURSOR cr_craptco_III( pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_cdcopant IN crapcop.cdcooper%TYPE) IS
      SELECT craptco.cdcooper
      FROM   craptco
      WHERE  craptco.cdcooper = pr_cdcooper
      AND    craptco.nrdconta = pr_nrdconta
      AND    craptco.cdcopant = pr_cdcopant
      AND    craptco.cdageant IN ( 2,4,6,7,11);

    rw_craptco_III cr_craptco_III%ROWTYPE;

    -- BUSCA DE LANCAMENTOS
    CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_dtainici IN VARCHAR2) IS
      SELECT lcm.dtmvtolt as dtmvtolt
      FROM   craplcm lcm
      WHERE  lcm.cdcooper = pr_cdcooper AND
             lcm.nrdconta = pr_nrdconta AND
             lcm.dtmvtolt < pr_dtainici
      ORDER BY lcm.progress_recid DESC;

    rw_craplcm cr_craplcm%ROWTYPE;

    -- CURSOR GENÉRICO DE CALENDÁRIO
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- FUNCAO PARA BUSCA DO CODIGO DA CIDADE
    FUNCTION fn_busca_municipio(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrdconta IN crapass.nrdconta%TYPE)
      RETURN INTEGER IS

      /* .............................................................................
      Programa: fn_busca_municipio
      Autor   : Jean Michel.
      Data    : 03/12/2013                     Ultima atualizacao:

      Dados referentes ao programa:

      Objetivo  : Função criada p/ busca do codigo de cidades, especifica p/
                  o programa pc_crps633.

      Parametros : pr_cdcooper => Codigo da cooperativa
                   pr_nrdconta => Numero da conta

      Premissa  : -

      Alteracoes :

      .............................................................................*/
    BEGIN
      DECLARE

        -- VARIAVEIS --
        vr_cdcidade INTEGER;

        -- BUSCA DOS DADOS DE NOME CEP DA CIDADE CO COOPERADO
        CURSOR cr_crapenc IS
          SELECT enc.nrcepend, enc.nmcidade
            FROM crapenc enc
           WHERE enc.cdcooper = pr_cdcooper
             AND enc.nrdconta = pr_nrdconta
           ORDER BY enc.progress_recid ASC;

        rw_crapenc cr_crapenc%ROWTYPE;

        -- BUSCA CIDADES DE ACORDO COM O CEP INFORMADO
        CURSOR cr_crapdne(pr_nrceplog IN crapdne.nrceplog%TYPE) IS
          SELECT dne.nmextcid, dne.nmrescid
            FROM crapdne dne
           WHERE
              dne.nrceplog = pr_nrceplog AND
              rownum = 1
           ORDER BY
            dne.progress_recid ASC;

        rw_crapdne cr_crapdne%ROWTYPE;

        -- BUSCA DE CIDADES
        CURSOR cr_crapcaf(pr_nmcidade IN crapdne.nmextcid%TYPE) IS
          SELECT
            caf.cdcidade
          FROM
            crapcaf caf
          WHERE
            TRIM(UPPER(caf.nmcidade)) LIKE UPPER(pr_nmcidade || '%') AND
            rownum = 1
          ORDER BY
            caf.progress_recid ASC;

        rw_crapcaf cr_crapcaf%ROWTYPE;

      BEGIN

        -- CURSOR DE ENDERECOS DE COOPERADOS
        OPEN cr_crapenc;
        FETCH cr_crapenc
          INTO rw_crapenc;

        -- SE NÃO ENCONTRAR
        IF cr_crapenc%NOTFOUND THEN
          CLOSE cr_crapenc;
          -- ATRIBUI COD GENERICO
          vr_cdcidade := 999999;
        ELSE
          -- APENAS FECHAR O CURSOR
          CLOSE cr_crapenc;

          -- CURSOR DE ENDERECOS NACIONAIS
          OPEN cr_crapdne(pr_nrceplog => rw_crapenc.nrcepend);
          FETCH cr_crapdne
            INTO rw_crapdne;

          -- SE NÃO ENCONTRAR
          IF cr_crapdne%NOTFOUND THEN
            -- APENAS FECHAR O CURSOR
            CLOSE cr_crapdne;

            OPEN cr_crapcaf(pr_nmcidade => TRIM(rw_crapenc.nmcidade));
            FETCH cr_crapcaf
              INTO rw_crapcaf;

            -- SE NÃO ENCONTRAR
            IF cr_crapcaf%NOTFOUND THEN

              CLOSE cr_crapcaf;
              -- ATRIBUI COD GENERICO
              vr_cdcidade := 999999;
            ELSE
              -- APENAS FECHAR O CURSOR
              CLOSE cr_crapcaf;
              -- ATRIBUI COD CIDADE
              vr_cdcidade := rw_crapcaf.cdcidade;
            END IF;

          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_crapdne;

            OPEN cr_crapcaf(pr_nmcidade => TRIM(rw_crapdne.nmextcid));
            FETCH cr_crapcaf
              INTO rw_crapcaf;

            -- SE NÃO ENCONTRAR
            IF cr_crapcaf%NOTFOUND THEN
              -- FECHAR O CURSOR POIS IRÁ ATRIBUIR COD GENÉRICO
              CLOSE cr_crapcaf;

              OPEN cr_crapcaf(pr_nmcidade => TRIM(rw_crapdne.nmrescid));
              FETCH cr_crapcaf
                INTO rw_crapcaf;

              IF cr_crapcaf%NOTFOUND THEN
                -- FECHAR O CURSOR
                CLOSE cr_crapcaf;
                -- ATRIBUI COD GENERICO
                vr_cdcidade := 999999;
              ELSE
                CLOSE cr_crapcaf;
                -- ATRIBUI COD CIDADE
                vr_cdcidade := rw_crapcaf.cdcidade;
              END IF;

            ELSE
              -- APENAS FECHAR O CURSOR
              CLOSE cr_crapcaf;
              -- ATRIBUI COD CIDADE
              vr_cdcidade := rw_crapcaf.cdcidade;
            END IF;

          END IF;

        END IF;

        RETURN vr_cdcidade; -- RETORNO O CODIGO DO MUNICIPIO

      END;

    END fn_busca_municipio;

    -- VERIFICA SITUACAO DE MOVIMENTACAO DO COOPERADO
    FUNCTION fn_situacao_cooperado(pr_cdcooper IN INTEGER,
                                   pr_nrdconta IN INTEGER,
                                   pr_dtmvtolt IN DATE,
                                   pr_dtainici IN DATE,
                                   pr_dtafinal IN DATE,
                                   pr_dtadmiss IN DATE) RETURN INTEGER IS

      /* .............................................................................
      Programa: fn_situacao_cooperado
      Autor   : Jean Michel.
      Data    : 03/12/2013                     Ultima atualizacao:

      Dados referentes ao programa:

      Objetivo  : Função criada p/ verificar se cooperado está ativo com movimentações,
                  função especifica p/ o programa pc_crps633.

      Parametros : pr_cdcooper => Codigo da cooperativa
                   pr_nrdconta => Numero da conta
                   pr_dtmvtolt => Data de Movimentacao Atual
                   pr_dtainici => Data Inicial
                   pr_dtafinal => Data Final
                   pr_dtadmiss => Data de Admissao

      Premissa  : -

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        -- VARIAVEIS --
        vr_situacao INTEGER := 0;
        vr_dtmvtolt DATE;

        -- CURSORES --

        -- BUSCA DOS DADOS REFERENTE AO SALDO DE CONTA DO COOPERADO
        CURSOR cr_crapsda IS
          SELECT vldestit, -- VALOR DESCTO TITULOS
                 vldeschq, -- VALOR DESCTO CHEQUES
                 vlsddisp, -- VALOR DISPONIVEL
                 vlsdchsl, -- VALOR CHEQUE SALARIO
                 vlsdbloq, -- VALOR BLOQUEADO
                 vlsdblpr, -- VALOR BLOQUEADO PRACA
                 vlsdblfp, -- VALOR BLOQUEADO FORA PRACA
                 vlsdindi, -- VALOR INDISPONIVEL
                 vlsdeved, -- SALDO DEVEDOR EMPRESTIMO
                 vllimutl, -- VALOR LIMITE UTILIZADO
                 vladdutl, -- VALOR ADIANT. UTILIZADO
                 vlsdrdca, -- SALDO DE APLICACAO
                 vlsdrdpp, -- SALDO DA POUPANCA PROGRAMADA
                 vlopcdia, -- VALOR OPERACÃO CREDITO
                 vlsdempr, -- SALDO DEVEDOR EMPRESTIMO
                 vlsdfina, -- SALDO DEVEDOR FINANCIAMENTO
                 vlsrdc30, -- SALDO DE RDCA 30
                 vlsrdc60, -- SALDO DE RDCA 60
                 vlsrdcpr, -- SALDO DE RDC PRE
                 vlsrdcpo, -- SALDO DE RDC POS
                 vlsdcota  -- SALDO DE COTAS
            FROM crapsda sda
           WHERE sda.cdcooper = pr_cdcooper
             AND sda.nrdconta = pr_nrdconta
             AND sda.dtmvtolt >= vr_dtmvtolt
             AND sda.dtmvtolt <= pr_dtafinal
             AND ((sda.vldestit <> 0) OR (sda.vldeschq <> 0) OR
                 (sda.vlsddisp <> 0)  OR (sda.vlsdchsl <> 0) OR
                 (sda.vlsdbloq <> 0)  OR (sda.vlsdblpr <> 0) OR
                 (sda.vlsdblfp <> 0)  OR (sda.vlsdindi <> 0) OR
                 (sda.vlsdeved <> 0)  OR (sda.vllimutl <> 0) OR
                 (sda.vladdutl <> 0)  OR (sda.vlsdrdca <> 0) OR
                 (sda.vlsdrdpp <> 0)  OR (sda.vlopcdia <> 0) OR
                 (sda.vlsdempr <> 0)  OR (sda.vlsdfina <> 0) OR
                 (sda.vlsrdc30 <> 0)  OR (sda.vlsrdc60 <> 0) OR
                 (sda.vlsrdcpr <> 0)  OR (sda.vlsrdcpo <> 0) OR
                 (sda.vlsdcota <> 0));

        rw_crapsda cr_crapsda%ROWTYPE;

      BEGIN

        -- VERIFICA SE O MES DA DATA DE ADMISSAO É IGUAL A DATA DE MOVIMENTO
        IF TRUNC(pr_dtadmiss, 'MM') = TRUNC(pr_dtmvtolt, 'MM') THEN

          vr_situacao := 1; -- COOPERADO ATIVO
        ELSE
          -- VERIFICA DE A DATA DE ADMISSAO É MAIOR QUE A DATA INICIAL
          IF pr_dtadmiss > pr_dtainici THEN
            -- DATA DE MOVIMENTO ATUAL RECEBE DATA DE ADMISSAO
            vr_dtmvtolt := pr_dtadmiss;
          ELSE
            -- DATA DE MOVIMENTO ATUAL RECEBE DATA INICIAL
            vr_dtmvtolt := pr_dtainici;
          END IF;
          OPEN cr_crapsda;
          FETCH cr_crapsda
            INTO rw_crapsda;

          IF cr_crapsda%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_crapsda;
          ELSE
            -- APENAS FECHAR O CURSOR
            CLOSE cr_crapsda;
            vr_situacao := 1; -- COOPERADO ATIVO
          END IF;

        END IF;

        RETURN vr_situacao;

      END;

    END fn_situacao_cooperado;

    -- FAZER O CALCULO DO CAPITAL TOTAL E DO CAPITAL A INTEGRALIZAR
    PROCEDURE pc_calculo_capital(pr_cdcooper IN INTEGER,
                                 pr_nrdconta IN INTEGER,
                                 pr_inpessoa IN crapass.inpessoa%TYPE,
                                 pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE,
                                 pr_dtadmiss IN crapass.dtadmiss%TYPE,
                                 pr_cdcidade IN crapcaf.cdcidade%TYPE,
                                 pr_situacao IN INTEGER,
                                 pr_dtultatu IN DATE) IS

      /* .............................................................................
      Programa: pc_calculo_capital
      Autor   : Jean Michel.
      Data    : 05/12/2013                     Ultima atualizacao:

      Dados referentes ao programa:

      Objetivo  : Procedure criada p/ fazer o calculo do capital total e do capital
                  a integralizar, função especifica p/ o programa pc_crps633.

      Parametros : pr_cdcooper => Codigo da cooperativa
                   pr_nrdconta => Numero da conta
                   pr_inpessoa => Tipo de Pessoa 1-Fisica / 2-Juridica
                   pr_nrcpfcgc => Numero de CPF
                   pr_dtadmiss => Data de Admissao
                   pr_cdcidade => Codigo da Cidade
                   pr_situacao => Situacao do Cooperado
                   pr_dtultatu => Data da Ultima Atualizacao na Conta

      Premissa  :

      Alteracoes :

      .............................................................................*/

    BEGIN
      DECLARE

        -- CURSORES --
        -- BUSCA DADOS DO CAPITAL DOS ASSOCIADOS ADMITIDOS
        CURSOR cr_crapsdc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT
            SUM(sdc.vllanmto) as vllanmto
            FROM crapsdc sdc
           WHERE sdc.cdcooper = pr_cdcooper
             AND sdc.nrdconta = pr_nrdconta
             AND sdc.dtdebito IS NULL
             AND sdc.indebito = 0;

        rw_crapsdc cr_crapsdc%ROWTYPE;

        -- BUSCA DADOS REFERENTES AS COTAS DOS COOPERADOS
        CURSOR cr_crapcot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT
            cot.vldcotas
          FROM crapcot cot
          WHERE
            cot.cdcooper = pr_cdcooper AND
            cot.nrdconta = pr_nrdconta
          ORDER BY cot.progress_recid ASC;

        rw_crapcot cr_crapcot%ROWTYPE;

      BEGIN

        -- MONTA INDICE DA TABELA
        vr_ind_cens := LPAD(pr_nrcpfcgc, 14, 0);

        -- VERIFICA SE INDICE JA EXISTE, SE NAO EXISTIR CRIA O REGISTRO
        IF NOT vr_tab_censo.EXISTS(vr_ind_cens) THEN

          vr_tab_censo(vr_ind_cens).cdcooper := pr_cdcooper; -- CODIGO DA COOPERATIVA
          vr_tab_censo(vr_ind_cens).nrdconta := pr_nrdconta; -- CONTA DO COOPERADO
          vr_tab_censo(vr_ind_cens).inpessoa := pr_inpessoa; -- TIPO DE PESSOA
          vr_tab_censo(vr_ind_cens).nrcpfcgc := pr_nrcpfcgc; -- NUMERO DE CPF OU CNPJ
          vr_tab_censo(vr_ind_cens).dtadmiss := pr_dtadmiss; -- DATA DE ADMISSAO DO COOPERADO
          vr_tab_censo(vr_ind_cens).cdcidade := pr_cdcidade; -- CODIGO DA CIDADE
          vr_tab_censo(vr_ind_cens).situacao := pr_situacao; -- SITUACAO DO COOPERADO - 1-ATIVO / 2-INATIVO
          vr_tab_censo(vr_ind_cens).dtultatu := pr_dtultatu; -- DATA DA ULTIMA ATUALIZACAO
        END IF;

        -- VERIFICA SE DATA DE ADMISSAO DO COOPERADO É NULA
        IF rw_crapass.dtdemiss IS NULL THEN

          OPEN cr_crapsdc(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta);
          FETCH cr_crapsdc
              INTO rw_crapsdc;

          IF cr_crapsdc%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_crapsdc;
          ELSE
            -- FECHAR O CURSOR
            CLOSE cr_crapsdc;
            -- UTILIZA (* 100) PARA PEGAR OS CENTAVOS
            vr_tab_censo(vr_ind_cens).vltinzar := (rw_crapsdc.vllanmto * 100);
          END IF;

          OPEN cr_crapcot(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta);

          FETCH cr_crapcot
            INTO rw_crapcot;

          IF cr_crapcot%NOTFOUND THEN
            -- FECHAR O CURSOR
            CLOSE cr_crapcot;
          ELSE
            -- APENAS FECHAR O CURSOR
            CLOSE cr_crapcot;
            -- INTEGRALIZAÇÃO DO VALOR DE COTAS
            vr_tab_censo(vr_ind_cens).vltizado := vr_tab_censo(vr_ind_cens).vltizado + (rw_crapcot.vldcotas * 100);
          END IF;

        END IF;
      END;

    END pc_calculo_capital;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- INCLUIR NOME DO MÓDULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => null);

    -- LEITURA DO CALENDÁRIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- SE NÃO ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;
        
    -- VALIDAÇÕES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- SE A VARIAVEL DE ERRO É <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- ATRIBUICAO DO ANO VIGENTE
    vr_dtmvtolt := TO_CHAR(rw_crapdat.dtmvtolt, 'yyyy');

    -- VERIFICACAO DE SEMESTRE DO ANO
    IF TO_CHAR(rw_crapdat.dtmvtolt, 'MM') = 6 THEN
      -- PRIMEIRO SEMESTRE
      vr_semestre := '01';
      vr_dtainici := to_date('01/01/' || vr_dtmvtolt,'DD/MM/YYYY');
      vr_dtafinal := to_date('30/06/' || vr_dtmvtolt,'DD/MM/YYYY');
    ELSE
      IF TO_CHAR(rw_crapdat.dtmvtolt, 'MM') = 12 THEN
        -- SEGUNDO SEMESTRE
        vr_semestre := '02';
        vr_dtainici := to_date('01/07/' || vr_dtmvtolt,'DD/MM/YYYY');
        vr_dtafinal := to_date('31/12/' || vr_dtmvtolt,'DD/MM/YYYY');
      END IF;

    END IF;

    -- VERIFICA SE É FINAL DE SEMESTRE
    IF TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <> TO_CHAR(rw_crapdat.dtmvtopr, 'MM') AND
       (TO_CHAR(rw_crapdat.dtmvtolt, 'MM') = 6 OR
        TO_CHAR(rw_crapdat.dtmvtolt, 'MM') = 12) THEN

      -- CONSULTA DAS COOPERATIVA
      OPEN cr_crapcop;
      LOOP
        FETCH cr_crapcop
          INTO rw_crapcop;

        -- SAI DO LOOP QUANDO CHEGAR AO FIM DO ARQUIVO
        EXIT WHEN cr_crapcop%NOTFOUND;

        -- Inicializar o CLOB
        vr_des_xml := null;
        vr_texto_completo := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- LIMPA A TABELA POR COOPERATIVA
        vr_tab_censo.DELETE;

        -- VARIAVEIS P/ MONTAR O CABECALHO DO ARQUIVO
        vr_nrdocnpj := LPAD(rw_crapcop.nrdocnpj, 14, '0');
        vr_nrcnpjco := SUBSTR(vr_nrdocnpj, 1, 8);
        vr_dsnomscr := RPAD(rw_crapcop.dsnomscr, 59, ' ');
        vr_dddcoope := SUBSTR(rw_crapcop.dstelscr, 1, 2);
        vr_telcoope := REPLACE(TRIM(SUBSTR(rw_crapcop.dstelscr, 3, 9)), '-', '') || ' ';

        -- MONTA CABECALHO DO ARQUIVO
        gene0002.pc_escreve_xml(vr_des_xml,
                                vr_texto_completo,
                                vr_nrcnpjco || vr_dsnomscr || vr_dddcoope || vr_telcoope||chr(13));

        -- CONSULTA COOPERADOS DA COOPERATIVA PASSADA POR PARAMETRO
        OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper);
        LOOP
          FETCH cr_crapass
            INTO rw_crapass;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DO ARQUIVO
          EXIT WHEN cr_crapass%NOTFOUND;

          -- CASO DATA DE ELIMINACAO SEJA NULA OU DATA DE DEMISSAO MAIOR QUE A DATA FINAL,
          -- AVANÇA PARA O PROXIMO REGISTRO
          IF rw_crapass.dtelimin IS NOT NULL OR
             rw_crapass.dtadmiss > vr_dtafinal THEN

            CONTINUE;

          END IF;

          -- VERIFICA SE A COOPERATIVA É A VIACREDI ALTO VALE
          IF rw_crapass.cdcooper = 16 THEN

            IF rw_crapdat.dtmvtolt <= to_date('31/12/2012','DD/MM/YYYY') THEN

              OPEN cr_craptco(pr_cdcooper => rw_crapass.cdcooper,
                              pr_nrdconta => rw_crapass.nrdconta,
                              pr_cdcopant => 1);
              FETCH cr_craptco
                INTO rw_craptco;

              -- SE NÃO ENCONTRAR
              IF cr_craptco%NOTFOUND THEN
                -- FECHAR O CURSOR POIS IRÁ ATRIBUIR COD GENÉRICO
                CLOSE cr_craptco;
              ELSE
                -- APENAS FECHAR O CURSOR
                CLOSE cr_craptco;
                CONTINUE;
              END IF;

            END IF;

            -- VERIFICA SE A COOPERATIVA É A VIACREDI
          ELSE
            IF rw_crapass.cdcooper = 1 THEN

              IF rw_crapdat.dtmvtolt > to_date('31/12/2012','DD/MM/YYYY') THEN

                OPEN cr_craptco_II(pr_cdcooper => 16,
                                   pr_nrdconta => rw_crapass.nrdconta,
                                   pr_cdcopant => rw_crapass.cdcooper);
                FETCH cr_craptco_II
                  INTO rw_craptco_II;

                -- SE NÃO ENCONTRAR
                IF cr_craptco_II%NOTFOUND THEN
                  -- FECHAR O CURSOR POIS IRÁ ATRIBUIR COD GENÉRICO
                  CLOSE cr_craptco_II;
                ELSE
                  -- APENAS FECHAR O CURSOR
                  CLOSE cr_craptco_II;
                  CONTINUE;
                END IF;

              END IF;
            END IF;
          END IF;

          /************* Verifica se foi migrado da Acredi para Viacredi ***********/
          IF rw_crapass.cdcooper = 1 THEN

            -- Verifica a data do movimento
            IF rw_crapdat.dtmvtolt <= to_date('31/12/2013','DD/MM/YYYY') THEN

              --seleciona as contas transferidas entre cooperativas com origem na
              --cooperativa 2 e agencias 2,4,6,7,11.
              OPEN cr_craptco_III( pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_cdcopant => 2);
              FETCH cr_craptco_III INTO rw_craptco_III;

              --se encontrar alguma informação, processa o proximo registro
              IF cr_craptco_III%FOUND  THEN
                -- Fecha o cursor
                CLOSE CR_craptco_III;
                -- processa o proximo registro do loop
                CONTINUE;
              ELSE
                -- Fecha o cursor
                CLOSE CR_craptco_III;
              END IF;--IF cr_craptco_III%FOUND  THEN
            END IF;--IF rw_crapdat.dtmvtolt <= to_date('31/12/2013','DD/MM/YYYY') THEN

          ELSE --IF rw_crapass.cdcooper = 1 THEN

            -- se é da cooperativa 2
            IF rw_crapass.cdcooper = 2 THEN

              /* Migrado para Viacredi */
              IF rw_crapdat.dtmvtolt > to_date('31/12/2013','DD/MM/YYYY') THEN

                --seleciona as contas transferidas entre cooperativas com origem na
                --cooperativa 1 e agencias 2,4,6,7,11.
                OPEN cr_craptco_III( pr_cdcooper => 1
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_cdcopant => rw_crapass.cdcooper);
                FETCH cr_craptco_III INTO rw_craptco_III;

                --se encontrar alguma informação, processa o proximo registro
                IF cr_craptco_III%FOUND THEN
                  -- Fecha o cursor
                  CLOSE CR_craptco_III;
                  -- processa o proximo registro do loop
                  CONTINUE;
                ELSE
                  -- Fecha o cursor
                  CLOSE CR_craptco_III;
                END IF;--IF cr_craptco_III%FOUND THEN
              END IF;--IF rw_crapdat.dtmvtolt > to_date('31/12/2013','DD/MM/YYYY') THEN
            END IF;--IF rw_crapass.cdcooper = 2 THEN
          END IF;--IF rw_crapass.cdcooper = 1 THEN
           /*********** Fim da verificacao se foi migrado da Acredi para Viacredi ***********/

          -- RECEBE A DATA DE ADMISSAO DO COOPERADO
          vr_dtadmiss := rw_crapass.dtadmiss;

          -- VERIFICA O TIPO DE PESSOA
          IF rw_crapass.inpessoa = 1 THEN
            vr_inpessoa := 1; -- PESSOA FISICA
          ELSE
            vr_inpessoa := 2; -- PESSOA JURIDICA
          END IF;

          -- VERIFICA SITUACAO DO COOPERADO 1-COOPERADO ATIVO / 2-COOPERADO INATIVO
          vr_situcoop := fn_situacao_cooperado(pr_cdcooper => rw_crapass.cdcooper,
                                               pr_nrdconta => rw_crapass.nrdconta,
                                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                               pr_dtainici => vr_dtainici,
                                               pr_dtafinal => vr_dtafinal,
                                               pr_dtadmiss => rw_crapass.dtadmiss);


          IF vr_situcoop = 1 THEN

            vr_situacao := 1; -- COOPERADO ATIVO
            vr_dtultatu := NULL;
            vr_cdcidade := fn_busca_municipio(pr_cdcooper => rw_crapass.cdcooper,
                                              pr_nrdconta => rw_crapass.nrdconta);
            -- CALCULO DE CAPITAL  A SER INTEGRADO
            pc_calculo_capital(pr_cdcooper => rw_crapass.cdcooper,
                               pr_nrdconta => rw_crapass.nrdconta,
                               pr_inpessoa => vr_inpessoa,
                               pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                               pr_dtadmiss => vr_dtadmiss,
                               pr_cdcidade => vr_cdcidade,
                               pr_situacao => vr_situacao,
                               pr_dtultatu => vr_dtultatu);

          ELSE

            OPEN cr_craplcm(pr_cdcooper => rw_crapass.cdcooper,
                            pr_nrdconta => rw_crapass.nrdconta,
                            pr_dtainici => vr_dtainici);
            FETCH cr_craplcm
              INTO rw_craplcm;

            -- SE NÃO ENCONTRAR
            IF cr_craplcm%NOTFOUND THEN
              CLOSE cr_craplcm;

              IF rw_crapass.dtdemiss IS NOT NULL AND
                 rw_crapass.dtdemiss <= vr_dtafinal THEN
                vr_dtultatu := rw_crapass.dtdemiss;
              ELSE
                vr_dtultatu := rw_crapass.dtadmiss;
              END IF;

            ELSE
              -- APENAS FECHAR O CURSOR
              CLOSE cr_craplcm;
              vr_dtultatu := rw_craplcm.dtmvtolt;
            END IF;

            vr_situacao := 2; -- COOPERADO INATIVO
            vr_cdcidade := fn_busca_municipio(pr_cdcooper => rw_crapass.cdcooper,
                                              pr_nrdconta => rw_crapass.nrdconta);

            -- CALCULO DE CAPITAL  A SER INTEGRADO
            pc_calculo_capital(pr_cdcooper => rw_crapass.cdcooper,
                               pr_nrdconta => rw_crapass.nrdconta,
                               pr_inpessoa => vr_inpessoa,
                               pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                               pr_dtadmiss => vr_dtadmiss,
                               pr_cdcidade => vr_cdcidade,
                               pr_situacao => vr_situacao,
                               pr_dtultatu => vr_dtultatu);
          END IF;

        END LOOP;

        -- FECHA CURSOR REFERENTE AOS ASSOCIADOS
        CLOSE cr_crapass;

        -- CONSULTA O PRIMEIRO REGISTRO
        vr_ind_cens := vr_tab_censo.FIRST;

        LOOP
          -- VERIFICA SE ESTA NO FINAL DO ARQUIVO
          EXIT WHEN vr_ind_cens IS NULL;

          -- ESCREVE DADOS DA CONSULTA NO ARQUIVO
          gene0002.pc_escreve_xml(vr_des_xml,
                                  vr_texto_completo,
                                  vr_tab_censo(vr_ind_cens).inpessoa ||
                                  LPAD(vr_tab_censo(vr_ind_cens).nrcpfcgc,14,'0') ||
                                  NVL(TO_CHAR(vr_tab_censo(vr_ind_cens).dtadmiss,'dd/mm/yyyy'),'          ') ||
                                  LPAD(vr_tab_censo(vr_ind_cens).cdcidade,6,'0') ||
                                  LPAD(vr_tab_censo(vr_ind_cens).situacao,1,'0') ||
                                  NVL(TO_CHAR(vr_tab_censo(vr_ind_cens).dtultatu,'dd/mm/yyyy'),'          ') ||
                                  LPAD(NVL(vr_tab_censo(vr_ind_cens).vltizado,0),18,'0') ||
                                  LPAD(NVL(vr_tab_censo(vr_ind_cens).vltinzar,0),18,'0')||chr(13));

          -- CONSULTA O PROXIMO REGISTRO
          vr_ind_cens := vr_tab_censo.NEXT(vr_ind_cens);

        END LOOP;

        -- ESCREVE DADOS DA CONSULTA NO ARQUIVO
        gene0002.pc_escreve_xml(vr_des_xml,
                                vr_texto_completo,
                                '',TRUE);

        -- ATRIBUICAO DO CAMINHO REFERENTE A COOPERATIVA
        vr_nmarqimp := gene0001.fn_diretorio(pr_tpdireto => 'M',
                                             pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_nmsubdir => 'contab');

        -- Criar o arquivo no diretorio especificado
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => vr_nmarqimp
                                     ,pr_arquivo  => rw_crapcop.dsdircop||vr_dtmvtolt||vr_semestre||'.txt'
                                     ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

      END LOOP;

      -- FECHA CURSOR
      CLOSE cr_crapcop;

    END IF;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMAÇÕES ATUALIZADAS
    COMMIT; 
    
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- EFETUAR COMMIT
      COMMIT;       

    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS CÓDIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRIÇÃO
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- DEVOLVEMOS CÓDIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN

      -- EFETUAR RETORNO DO ERRO NÃO TRATADO
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- EFETUAR ROLLBACK
      ROLLBACK;

  END;

END pc_crps633;
/

