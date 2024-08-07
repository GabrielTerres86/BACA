DECLARE

  -- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_dtrefere DATE;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop
     WHERE flgativo = 1 
     order BY cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  

  FUNCTION fn_verifica_conta_migracao(par_cdcooper IN craptco.cdcooper%TYPE
                                     ,par_nrdconta IN craptco.nrdconta%TYPE
                                     ,par_dtrefere IN DATE) RETURN BOOLEAN IS
  -- ..........................................................................
    --
    --  Programa : fn_verifica_conta_migracao            Antigo: ????????????

    --  Sistema  : Rotinas genericas para RISCO
    --  Sigla    : RISC
    --  Autor    : ?????
    --  Data     : ?????                         Ultima atualizacao: 31/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : 31/12/2016 - Incorporação Transulcred -> Transpocred (Oscar).
    --
    -- .............................................................................

  vr_return BOOLEAN := FALSE;

  CURSOR cr_craptco(par_cdcooper IN craptco.cdcooper%TYPE
                   ,par_cdcopant IN craptco.cdcopant%TYPE
                   ,par_nrdconta IN craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3;
  rw_craptco cr_craptco%ROWTYPE;

  CURSOR cr_craptco_acredi(par_cdcooper IN craptco.cdcooper%TYPE
                          ,par_cdcopant IN craptco.cdcopant%TYPE
                          ,par_nrdconta IN craptco.cdcooper%TYPE) IS
    SELECT craptco.cdcooper
      FROM craptco
     WHERE craptco.cdcooper = par_cdcooper
       AND craptco.cdcopant = par_cdcopant
       AND craptco.nrdconta = par_nrdconta
       AND craptco.tpctatrf <> 3
       AND (craptco.cdageant = 2 OR craptco.cdageant = 4 OR
           craptco.cdageant = 6 OR craptco.cdageant = 7 OR
           craptco.cdageant = 11);
  rw_craptco_acredi cr_craptco_acredi%ROWTYPE;


  BEGIN

    -- Incorporacao Concredi -> Viacredi
    IF par_cdcooper = 1 AND
       par_dtrefere <= to_date('30/11/2014', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(1, 4, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Incorporacao Credimilsul -> Scrcred
    IF par_cdcooper = 13 AND
       par_dtrefere <= to_date('30/11/2014', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(13, 15, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Migracao Viacredi -> Altovale

    IF par_cdcooper = 16 AND
       par_dtrefere <= to_date('31/12/2012', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(16, 1, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;

    -- Migracao Acredicop -> Viacredi
    IF par_cdcooper = 1 AND
       par_dtrefere <= to_date('31/12/2013', 'dd/mm/YYYY') THEN

      OPEN cr_craptco_acredi(1, 2, par_nrdconta);
      FETCH cr_craptco_acredi
        INTO rw_craptco_acredi;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF  vr_return  THEN
        RETURN FALSE;
      END IF;

    END IF;


    -- Migracao Transulcred -> Transpocred
    IF par_cdcooper = 09 AND
       par_dtrefere <= to_date('31/12/2016', 'dd/mm/YYYY') THEN

      OPEN cr_craptco(09, 17, par_nrdconta);
      FETCH cr_craptco
        INTO rw_craptco;
        vr_return := cr_craptco%FOUND;
      CLOSE cr_craptco;
      IF vr_return THEN
        RETURN FALSE;
      END IF;

    END IF;


    RETURN TRUE;

  END fn_verifica_conta_migracao;

PROCEDURE pc_risco_t(pr_cdcooper   IN crapcop.cdcooper%TYPE
                      ,pr_dtrefere   IN VARCHAR2
                      ,pr_dscritic  OUT VARCHAR2) IS
  BEGIN

    DECLARE
      -- Buscar todos os percentual de cada nivel de risco
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT craptab.dstextab
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND UPPER(craptab.nmsistem) = 'CRED'
           AND UPPER(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres = 00
           AND UPPER(craptab.cdacesso) = 'PROVISAOCL';

      -- Buscar informações da central de risco para documento 3020
      CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT ris.cdcooper
              ,ris.dtrefere
              ,ris.vldivida
              ,ris.nrdconta
              ,ris.innivris
              ,ris.cdmodali
              ,ris.nrctremp
              ,ris.nrseqctr
              ,ris.cdorigem
              ,a.inpessoa
              ,a.cdagenci
          FROM crapris ris, crapass a
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 4
           AND a.cdcooper = ris.cdcooper 
           AND a.nrdconta = ris.nrdconta
      ORDER BY a.cdagenci;

      CURSOR cr_tot_limite_cartao(pr_cdcooper IN crapvri.cdcooper%TYPE
                                 ,pr_dtrefere IN crapvri.dtrefere%TYPE) IS
        SELECT COALESCE(SUM(a.vlcontrato),0) vlcontrato
          FROM crapris a
         WHERE a.cdcooper = pr_cdcooper 
           AND a.dtrefere = pr_dtrefere
           AND a.inddocto = 4
           AND a.vldivida > 0
           AND a.cdmodali = 1513;

      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));

      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_fisica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_fisica IS
        TABLE OF typ_reg_pessoa_fisica
          INDEX BY PLS_INTEGER;

      -- Tabela temporaria para guardar os valores de pessoa fisisca
      TYPE typ_reg_pessoa_juridica IS
       RECORD(cdagenci crapris.cdagenci%TYPE
             ,valor NUMBER(25,2));

      TYPE typ_tab_pessoa_juridica IS
        TABLE OF typ_reg_pessoa_juridica
          INDEX BY PLS_INTEGER;

      -- Vetor
      vr_tab_percentual       typ_tab_percentual;
      vr_tab_pessoa_fisica    typ_tab_pessoa_fisica;
      vr_tab_pessoa_juridica  typ_tab_pessoa_juridica;
      vr_tipsplit             gene0002.typ_split;

      -- Variaveis de controle de erro
      vr_cdcritic             PLS_INTEGER;
      vr_dscritic             VARCHAR2(4000);

      -- Cursor generico de calendario
      rw_crapdat              BTCH0001.cr_crapdat%ROWTYPE;
      vr_dsprmris             crapprm.dsvlrprm%TYPE;
      vr_dtultdma_util        crapdat.dtultdma%TYPE;
      vr_dtmvtopr_arq         crapdat.dtmvtopr%TYPE;
      vr_vlpreatr             NUMBER;
      vr_total_vlpreatr_fis   NUMBER;
      vr_total_vlpreatr_jur   NUMBER;
      vr_total_limite         NUMBER;
      vr_vlpercen             NUMBER;
      vr_hasfound             BOOLEAN;
      vr_linhadet             VARCHAR(3000);
      vr_linhadet_dtultdma    VARCHAR(3000);
      vr_linhadet_dtultdia    VARCHAR(3000);
      vr_dtrefere             DATE;
      vr_indice               PLS_INTEGER;

      -- Declarando handle do Arquivo
      vr_ind_arquivo          utl_file.file_type;
      vr_utlfileh             VARCHAR2(4000);
      -- Nome do Arquivo
      vr_nmarquiv             VARCHAR2(100);

      -- Escrever linha no arquivo
      PROCEDURE pc_gravar_linha(pr_ind_arquivo IN OUT utl_file.file_type
                               ,pr_linha       IN VARCHAR2) IS
      BEGIN
        GENE0001.pc_escr_linha_arquivo(pr_ind_arquivo,pr_linha);
      END;

    BEGIN
      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      vr_hasfound := btch0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      IF NOT vr_hasfound THEN
        -- Gerar excecao
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Vamos verificar se nesse exato momento estah sendo importado o arquivo CB117, pelo JOB
      vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'RISCO_CARTAO_BACEN');

      vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
      IF vr_tipsplit(3) = '1' THEN
        vr_dscritic := 'Nao foi possivel gerar o arquivo contabil. Arquivo CB117 esta sendo importado!';
        RAISE vr_exc_erro;
      END IF;

      IF vr_dtrefere > rw_crapdat.dtmvcentral THEN
        vr_dscritic := 'Dados da central de risco para a data ' || pr_dtrefere || ' ainda nao disponivel.';
        RAISE vr_exc_erro;
      END IF;

      -- Seta a flag que nesse momento estamos gerando o arquivo contabil, e nao podera ocorrer importacao de arquivos
      vr_tipsplit(2) := 1;
      RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                             ,pr_tipsplit => vr_tipsplit
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetua a gravacao da Flag, que nesse momento estah sendo gerado o arquivo contabil
      COMMIT;

      -- CRAPTAB -> 'PROVISAOCL'
      FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
      END LOOP;

      -- Buscar o ultimo dia útil
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                     ,pr_dtmvtolt  => vr_dtrefere -- último dia util
                                                     ,pr_tipo      => 'A');       -- Próximo ou anterior

      -- Data do proximo dia util, depois da mensal
      vr_dtmvtopr_arq := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                                    ,pr_dtmvtolt  => vr_dtrefere + 1 -- último dia util
                                                    ,pr_tipo      => 'P');           -- Próximo ou anterior

     -- Define o diretório do arquivo
     vr_utlfileh := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => vc_cdtodascooperativas
                                             ,pr_cdacesso => vc_cdacesso);


      -- Define Nome do Arquivo
      vr_nmarquiv := TO_CHAR(vr_dtultdma_util,'RR') ||
                     TO_CHAR(vr_dtultdma_util,'MM') ||
                     TO_CHAR(vr_dtultdma_util,'DD') ||'_' ||
                     LPAD(TO_CHAR(pr_cdcooper),2,'0') ||
                     '_RISCOCARTAO.txt';

      -- Abre arquivo em modo de escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Percorrer todos os dados de risco
      FOR rw_crapris IN cr_crapris(pr_cdcooper => pr_cdcooper,
                                   pr_dtrefere => vr_dtrefere) LOOP

        -- Tratar incorporação 17 -> 9
        --> Desprezar contas migradas antes da data de incorporação
        --> contas nao devem ser enviadas no arquivo
        IF pr_cdcooper IN (9) THEN
          IF NOT fn_verifica_conta_migracao(rw_crapris.cdcooper,
                                            rw_crapris.nrdconta,
                                            rw_crapris.dtrefere) THEN
            CONTINUE;
          END IF;
        END IF;

        -- Calculo do % de provisao do Risco
        IF vr_tab_percentual.exists(rw_crapris.innivris) THEN
          vr_vlpercen := vr_tab_percentual(rw_crapris.innivris).percentual / 100;
        ELSE
          vr_vlpercen := 0;
        END IF;

        -- Valor do atraso
        vr_vlpreatr := ROUND((rw_crapris.vldivida *  vr_vlpercen), 2);
        GESTAODERISCO.calcularProvisaoRiscoAtual(pr_cdcooper => rw_crapris.cdcooper,
                                                 pr_nrdconta => rw_crapris.nrdconta,
                                                 pr_nrctremp => rw_crapris.nrctremp,
                                                 pr_cdmodali => rw_crapris.cdmodali,
                                                 pr_vlpreatr => vr_vlpreatr,
                                                 pr_dscritic => vr_dscritic);

        IF rw_crapris.inpessoa = 1 THEN
          -- Valor total pessoa fisica
          vr_total_vlpreatr_fis := NVL(vr_total_vlpreatr_fis,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa fisica
          IF vr_tab_pessoa_fisica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor := vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_fisica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        ELSE
          -- Valor total pessoa juridica
          vr_total_vlpreatr_jur := NVL(vr_total_vlpreatr_jur,0) + vr_vlpreatr;
          -- Armazenar o valor total da pessoa juridica
          IF vr_tab_pessoa_juridica.exists(rw_crapris.cdagenci) THEN
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor := vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor + vr_vlpreatr;
          ELSE
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).valor    := vr_vlpreatr;
            vr_tab_pessoa_juridica(rw_crapris.cdagenci).cdagenci := rw_crapris.cdagenci;
          END IF;
        END IF;
      END LOOP;

      -- Somar todos os limites de creditos
      OPEN cr_tot_limite_cartao(pr_cdcooper => pr_cdcooper
                               ,pr_dtrefere => vr_dtrefere);
      FETCH cr_tot_limite_cartao
       INTO vr_total_limite;
      CLOSE cr_tot_limite_cartao;

      -- Linha da ultima data do mes anterior
      vr_linhadet_dtultdma := '70' ||
                              TO_CHAR(vr_dtultdma_util, 'yy') ||
                              TO_CHAR(vr_dtultdma_util, 'mm') ||
                              TO_CHAR(vr_dtultdma_util, 'dd');

      -- Linha do ultimo dia do mes
      vr_linhadet_dtultdia := '70' ||
                              TO_CHAR(rw_crapdat.dtultdma, 'yy') ||
                              TO_CHAR(rw_crapdat.dtultdma, 'mm') ||
                              TO_CHAR(rw_crapdat.dtultdma, 'dd');

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DO CARTAO DE CREDITO PESSOA FISICA
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_vlpreatr_fis > 0 THEN
      vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8484,4914,' ||
                     TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA FISICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa fisica e grava no arquivo
      vr_indice := vr_tab_pessoa_fisica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
      -----------------------------------------------------------------------------------------------------------
      vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                     TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                             ,pr_dtmvtolt  => rw_crapdat.dtultdma
                                                             ,pr_tipo      => 'A'
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8484,' ||
                     TRIM(to_char(vr_total_vlpreatr_fis, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA FISICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa fisica e grava no arquivo
      vr_indice := vr_tab_pessoa_fisica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_fisica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_fisica.next(vr_indice);
      END LOOP;
      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DO CARTAO DE CREDITO PESSOA JURIDICA
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_vlpreatr_jur > 0 THEN
      vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                     TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',8484,4914,' ||
                     TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA JURIDICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa juridica e grava no arquivo
      vr_indice := vr_tab_pessoa_juridica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
      -----------------------------------------------------------------------------------------------------------
      vr_linhadet := TRIM(vr_linhadet_dtultdia) || ',' ||
                     TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                             ,pr_dtmvtolt  => rw_crapdat.dtultdma
                                                             ,pr_tipo      => 'A'
                                                             ,pr_excultdia => TRUE), 'ddmmyy')) || ',4914,8484,' ||
                     TRIM(to_char(vr_total_vlpreatr_jur, '99999999999990.00')) ||
                     ',1434,' ||
                     '"(risco) REVERSAO PROVISAO AVAIS E FIANCAS E GARANTIAS PRESTADAS CARTAO PESSOA JURIDICA"';

      -- Grava a linha no arquivo
      pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                     ,pr_linha       => vr_linhadet);

      -- Percorre todas as agencias de pessoa juridica e grava no arquivo
      vr_indice := vr_tab_pessoa_juridica.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_pessoa_juridica(vr_indice).valor, '99999999999990.00'));
        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);
        -- Proximo registro
        vr_indice := vr_tab_pessoa_juridica.next(vr_indice);
      END LOOP;

      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA MONTAR O REGISTRO DE LIMITE CONCEDIDO CARTAO
      -----------------------------------------------------------------------------------------------------------
      IF vr_total_limite > 0 THEN
        vr_linhadet := TRIM(vr_linhadet_dtultdma) || ',' ||
                       TRIM(to_char(vr_dtultdma_util, 'ddmmyy')) || ',3133,9131,' ||
                       TRIM(to_char(vr_total_limite, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) LIMITE CONCEDIDO CARTAO"';

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);

        -----------------------------------------------------------------------------------------------------------
        --  INICIO PARA MONTAR O REGISTRO DE REVERSAO
        -----------------------------------------------------------------------------------------------------------
        vr_linhadet := '70' ||
                       TO_CHAR(vr_dtmvtopr_arq, 'yy') ||
                       TO_CHAR(vr_dtmvtopr_arq, 'mm') ||
                       TO_CHAR(vr_dtmvtopr_arq, 'dd') || ',' ||
                       TRIM(to_char(GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                               ,pr_dtmvtolt  => vr_dtmvtopr_arq
                                                               ,pr_tipo      => 'A'
                                                               ,pr_excultdia => TRUE), 'ddmmyy')) || ',9131,3133,' ||
                       TRIM(to_char(vr_total_limite, '99999999999990.00')) ||
                       ',1434,' ||
                       '"(risco) REVERSAO LIMITE CONCEDIDO CARTAO"';

        -- Grava a linha no arquivo
        pc_gravar_linha(pr_ind_arquivo => vr_ind_arquivo
                       ,pr_linha       => vr_linhadet);

      END IF;

      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      -----------------------------------------------------------------------------------------------------------
      --  Grava na tabela de controle que o arquivo contabil foi gerado
      -----------------------------------------------------------------------------------------------------------
      vr_tipsplit(1) := TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR');
      vr_tipsplit(2) := 0;
      vr_tipsplit(4) := 1;
      RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                             ,pr_tipsplit => vr_tipsplit
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;
        -- Atualiza os dados de controle do arquivo contabil
        vr_tipsplit(2) := 0;
        RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                               ,pr_tipsplit => vr_tipsplit
                                               ,pr_dscritic => vr_dscritic);
        COMMIT;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Monta mensagem de erro
        pr_dscritic := 'Erro em RISC0001.pc_risco_t: ' || SQLERRM;
        -- Atualiza os dados de controle do arquivo contabil
        vr_tipsplit(2) := 0;
        RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => pr_cdcooper
                                               ,pr_tipsplit => vr_tipsplit
                                               ,pr_dscritic => vr_dscritic);
        COMMIT;
    END;

  END pc_risco_t;
  
BEGIN 
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = '',.''';


  vr_dtrefere := to_date('31/07/2024','dd/mm/rrrr');

  FOR rw_crapcop IN cr_crapcop LOOP

    pc_risco_t(pr_cdcooper => rw_crapcop.cdcooper
              ,pr_dtrefere => vr_dtrefere
              ,pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
       dbms_output.put_line('Erro Risco T - Coop: ' || rw_crapcop.cdcooper);
    END IF;

    COMMIT;

  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
