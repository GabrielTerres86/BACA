PL/SQL Developer Test script 3.0
487
DECLARE
  -- Estrutura para PL Table de CRAPRIS
  TYPE typ_reg_crapris IS
    RECORD(nrdconta crapris.nrdconta%TYPE
          ,dtrefere crapris.dtrefere%TYPE
          ,innivris crapris.innivris%TYPE
          ,qtdiaatr crapris.qtdiaatr%TYPE
          ,vldivida crapris.vldivida%TYPE
          ,vlvec180 crapris.vlvec180%TYPE
          ,vlvec360 crapris.vlvec360%TYPE
          ,vlvec999 crapris.vlvec999%TYPE
          ,vldiv060 crapris.vldiv060%TYPE
          ,vldiv180 crapris.vldiv180%TYPE
          ,vldiv360 crapris.vldiv360%TYPE
          ,vldiv999 crapris.vldiv999%TYPE
          ,vlprjano crapris.vlprjano%TYPE
          ,vlprjaan crapris.vlprjaan%TYPE
          ,inpessoa crapris.inpessoa%TYPE
          ,nrcpfcgc crapris.nrcpfcgc%TYPE
          ,vlprjant crapris.vlprjant%TYPE
          ,inddocto crapris.inddocto%TYPE
          ,cdmodali crapris.cdmodali%TYPE
          ,nrctremp crapris.nrctremp%TYPE
          ,nrseqctr crapris.nrseqctr%TYPE
          ,dtinictr crapris.dtinictr%TYPE
          ,cdorigem crapris.cdorigem%TYPE
          ,cdagenci crapris.cdagenci%TYPE
          ,innivori crapris.innivori%TYPE
          ,cdcooper crapris.cdcooper%TYPE
          ,vlprjm60 crapris.vlprjm60%TYPE
          ,dtdrisco crapris.dtdrisco%TYPE
          ,qtdriclq crapris.qtdriclq%TYPE
          ,nrdgrupo crapris.nrdgrupo%TYPE
          ,vljura60 crapris.vljura60%TYPE
          ,inindris crapris.inindris%TYPE
          ,cdinfadi crapris.cdinfadi%TYPE
          ,nrctrnov crapris.nrctrnov%TYPE
          ,flgindiv crapris.flgindiv%TYPE
          ,dtprxpar crapris.dtprxpar%TYPE
          ,vlprxpar crapris.vlprxpar%TYPE
          ,qtparcel crapris.qtparcel%TYPE
          ,dtvencop crapris.dtvencop%TYPE
          ,dsinfaux crapris.dsinfaux%TYPE);
  TYPE typ_tab_crapris    IS TABLE OF typ_reg_crapris INDEX BY VARCHAR2(31);
  TYPE typ_tab_crapris_n  IS TABLE OF typ_reg_crapris INDEX BY PLS_INTEGER;

  -- Estrutura da PL Table CRAPEPR
  TYPE typ_reg_crapepr IS
    RECORD(qtmesdec crapepr.qtmesdec%TYPE
          ,qtpreemp crapepr.qtpreemp%TYPE
          ,inliquid crapepr.inliquid%TYPE);
  TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(100);

  -- Estrutura de PL Table CRAWEPR
  TYPE typ_tab_crawepr IS TABLE OF crawepr.nrctremp%TYPE INDEX BY VARCHAR2(100);

  /* Estrutra de PL Table para tabela CRAPTCO */
  TYPE typ_tab_craptco
    IS TABLE OF crapass.nrdconta%TYPE
      INDEX BY VARCHAR2(100);
  vr_tab_craptco typ_tab_craptco;

  /* Estrutura de PLTable para armazenar os Rowids de CRAPRIS para atualização */
  TYPE typ_tab_rowid
    IS TABLE OF ROWID
      INDEX BY PLS_INTEGER;
  vr_tab_rowid typ_tab_rowid;

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  -- Código do programa
  vr_fltemris       BOOLEAN;                                     --> Flag de risco
  vr_dtrefere       DATE;                                        --> Data de referencia
  vr_tab_craprispl  typ_tab_crapris;                             --> PL Table
  vr_dsparame       crapsol.dsparame%type;                       --> Parâmetro de execução
  vr_cdcooper       crapcop.cdcooper%TYPE;                       --> Codigo da Cooperativa

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;                                       --> Controle de saída para erros
  vr_exc_fimprg EXCEPTION;                                       --> Controle de saída para erros
  vr_cdcritic   PLS_INTEGER;                                     --> Código da crítica
  vr_dscritic   VARCHAR2(4000);                                  --> Descrição da crítica

  ------------------------------- CURSORES ----------------------------------------------------------
  -- Busca dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  ------------------------------- PROCEDURES INTERNAS ---------------------------------
  /* Processar conta de migração entre cooperativas */
  FUNCTION fn_verifica_conta_migracao(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE) --> Número da conta
                                                                             RETURN BOOLEAN IS
  BEGIN
    -- Validamos Apenas Via, AV, SCR e Tranpocred
    IF pr_cdcooper NOT IN(1,13,16,9) THEN
      -- OK
      RETURN TRUE;
    ELSE
      IF vr_tab_craptco.exists(LPAD(pr_cdcooper,03,'0')||LPAD(pr_nrdconta,15,'0')) THEN
        RETURN FALSE;
      ELSE
        -- Tudo OK até aqui, retornamos true
        RETURN TRUE;
      END IF;
    END IF;
  END fn_verifica_conta_migracao;

  /* Processar saída da operação */
  PROCEDURE pc_cria_saida_operacao(pr_cdcooper    IN PLS_INTEGER                 --> Código da cooperativa
                                  ,pr_dtrefere    IN DATE                        --> Data de referencia
                                  ,pr_rw_crapdat  IN btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                  ,pr_des_erro    OUT VARCHAR2) IS               --> Saída de erros
  BEGIN
    DECLARE

      vr_tab_crapris typ_tab_crapris;          --> PL Table para os riscos
      vr_nrseqctr    PLS_INTEGER;              --> Número de contrato
      vr_cdinfadi    VARCHAR2(400);            --> Descrição do motivo
      vr_cdmodali    crapris.cdmodali%TYPE;    --> Modalidade
      vr_dtultdma    DATE;                     --> Última data
      vr_contareg    PLS_INTEGER := 1;         --> Contador para iteração
      vr_exc_erro    EXCEPTION;                --> Controle de saída de erros
      vr_idxcrapris  VARCHAR2(31);             --> Índice para PL Table
      vr_contcraptis PLS_INTEGER := 0;         --> Contador para o indice vr_idxcrapris
      vr_tab_crapris_n typ_tab_crapris_n;      --> Variavel que contera a mesma informacao que a pr_tab_crapris, porem com indice numero
      vr_idxcrapris_n  PLS_INTEGER := 0;       --> Indice da pl/table vr_tab_crapris_n

      /* Buscar dados do risco */
      CURSOR cr_crapris_1513(pr_cdcooper IN crapris.cdcooper%TYPE      --> Código da cooperativa
                            ,pr_dtrefere IN crapris.dtrefere%TYPE) IS  --> Data de referencia
        SELECT cr.nrdconta          -- Mesmos campos do crps660 para criar o registro de saida
              ,cr.dtrefere
              ,cr.cdmodali
              ,cr.cdcooper
              ,cr.nrctremp
              ,cr.inddocto
              ,cr.cdorigem
              ,cr.innivris
              ,cr.qtdiaatr
              ,cr.vldivida
              ,cr.vlvec180
              ,cr.vlvec360
              ,cr.vlvec999
              ,cr.vldiv060
              ,cr.vldiv180
              ,cr.vldiv360
              ,cr.vldiv999
              ,cr.vlprjano
              ,cr.vlprjaan
              ,cr.inpessoa
              ,cr.nrcpfcgc
              ,cr.vlprjant
              ,cr.dtinictr
              ,cr.cdagenci
              ,cr.innivori
              ,cr.vlprjm60
              ,cr.dtdrisco
              ,cr.qtdriclq
              ,cr.nrdgrupo
              ,cr.vljura60
              ,cr.inindris
              ,cr.flgindiv
              ,cr.nrctrnov
              ,cr.cdinfadi
              ,cr.nrseqctr
              ,cr.dtprxpar
              ,cr.vlprxpar
              ,cr.qtparcel
              ,cr.dtvencop
              ,cr.dsinfaux
              ,cr.rowid
        FROM crapris cr
        -- Regras da CRAPRIS, mesma base do crps573 base riscos
        WHERE cr.cdcooper = pr_cdcooper
          AND cr.dtrefere = pr_dtrefere
          AND cr.inddocto IN (4,5) --Cartão de Crédito
          AND cr.cdmodali = 1513   --Cartão Rotativo
          AND cr.inpessoa IN (1,2) --Física/Jurídica
          AND cr.vldivida <> 0     
          AND cr.cdinfadi = ' '
          --Sem Saídas
          AND NOT EXISTS(SELECT 1
                           FROM crapris r
                          WHERE r.cdcooper = cr.cdcooper 
                            AND r.dtrefere = cr.dtrefere
                            AND r.nrdconta = cr.nrdconta
                            AND r.nrctremp = cr.nrctremp
                            AND r.cdmodali = cr.cdmodali
                            AND r.inddocto = 2)
        ORDER BY cr.nrdconta
                ,cr.nrctremp
                ,cr.nrseqctr;

    BEGIN
      -- Inicializar variáveis
      vr_dtultdma := pr_dtrefere;
      vr_cdinfadi := '';
      vr_nrseqctr := 0;
      vr_cdmodali := 0;

      -- Executar consulta de riscos
      FOR rw_crapris IN cr_crapris_1513(pr_cdcooper => pr_cdcooper
                                      , pr_dtrefere => pr_dtrefere) LOOP
        -- Verifica migração/incorporação
        IF NOT fn_verifica_conta_migracao(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta) THEN
          CONTINUE;
        END IF;

        vr_fltemris := FALSE;
        vr_contareg := 1;

        -- Verificar riscos para determinar indicador
        LOOP
          EXIT WHEN vr_contareg > 10;

          -- Verificar modalidade
          IF rw_crapris.cdmodali = 0299 THEN
            vr_cdmodali := 0499;
          ELSE
            IF rw_crapris.cdmodali = 0499 THEN
              vr_cdmodali := 0299;
            ELSE
              vr_cdmodali := rw_crapris.cdmodali;
            END IF;
          END IF;

          -- Verifica se existe o risco
          IF vr_tab_craprispl.exists(lpad(rw_crapris.nrdconta,10,'0')||
                                     lpad(vr_contareg,5,'0') ||
                                     lpad(rw_crapris.nrctremp,10,'0')||
                                     lpad(rw_crapris.cdmodali,5,'0')) OR
             vr_tab_craprispl.exists(lpad(rw_crapris.nrdconta,10,'0')||
                                     lpad(vr_contareg,5,'0') ||
                                     lpad(rw_crapris.nrctremp,10,'0')||
                                     lpad(vr_cdmodali,5,'0')) THEN
            vr_fltemris := TRUE;
            EXIT;
          END IF;

          vr_contareg := vr_contareg + 1;
        END LOOP;

        -- Verifica o flag de risco
        IF NOT vr_fltemris THEN
          -- Sequencia do risco
          vr_nrseqctr := 1;

          -- Busca a sequencia
          -- Verifica se existe registro para o risco
          vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                           to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                           '00002'                          ||   -- inddocto
                           '00000000';                           -- contador
          vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);

          WHILE vr_idxcrapris IS NOT NULL LOOP
            -- Verifica se existe registro
            IF vr_tab_crapris(vr_idxcrapris).nrdconta = rw_crapris.nrdconta AND
               vr_tab_crapris(vr_idxcrapris).dtrefere = pr_dtrefere AND
               vr_tab_crapris(vr_idxcrapris).inddocto = 2 THEN
              IF nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) >= vr_nrseqctr THEN
                vr_nrseqctr := nvl(vr_tab_crapris(vr_idxcrapris).nrseqctr, 0) + 1;
              END IF;
            ELSE
              EXIT;
            END IF;
            vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
          END LOOP;

          -- Motivo de saida 0399 - Outras Saídas
          vr_cdinfadi := '0399';

          -- Criar registros na PL Table com base na tabela física
          vr_contcraptis := vr_contcraptis + 1;
          vr_idxcrapris := lpad(rw_crapris.nrdconta,10,'0') ||   -- nrdconta
                           to_char(pr_dtrefere,'YYYYMMDD')  ||   -- dtrefere
                           '00002'                          ||   -- inddocto
                           lpad(vr_contcraptis,8,'0');           -- contador
          vr_tab_crapris(vr_idxcrapris).nrdconta := rw_crapris.nrdconta;
          vr_tab_crapris(vr_idxcrapris).dtrefere := pr_dtrefere;
          vr_tab_crapris(vr_idxcrapris).innivris := rw_crapris.innivris;
          vr_tab_crapris(vr_idxcrapris).qtdiaatr := rw_crapris.qtdiaatr;
          vr_tab_crapris(vr_idxcrapris).vldivida := rw_crapris.vldivida;
          vr_tab_crapris(vr_idxcrapris).vlvec180 := rw_crapris.vlvec180;
          vr_tab_crapris(vr_idxcrapris).vlvec360 := rw_crapris.vlvec360;
          vr_tab_crapris(vr_idxcrapris).vlvec999 := rw_crapris.vlvec999;
          vr_tab_crapris(vr_idxcrapris).vldiv060 := rw_crapris.vldiv060;
          vr_tab_crapris(vr_idxcrapris).vldiv180 := rw_crapris.vldiv180;
          vr_tab_crapris(vr_idxcrapris).vldiv360 := rw_crapris.vldiv360;
          vr_tab_crapris(vr_idxcrapris).vldiv999 := rw_crapris.vldiv999;
          vr_tab_crapris(vr_idxcrapris).vlprjano := rw_crapris.vlprjano;
          vr_tab_crapris(vr_idxcrapris).vlprjaan := rw_crapris.vlprjaan;
          vr_tab_crapris(vr_idxcrapris).inpessoa := rw_crapris.inpessoa;
          vr_tab_crapris(vr_idxcrapris).nrcpfcgc := rw_crapris.nrcpfcgc;
          vr_tab_crapris(vr_idxcrapris).vlprjant := rw_crapris.vlprjant;
          vr_tab_crapris(vr_idxcrapris).inddocto := 2;
          vr_tab_crapris(vr_idxcrapris).cdmodali := rw_crapris.cdmodali;
          vr_tab_crapris(vr_idxcrapris).nrctremp := rw_crapris.nrctremp;
          vr_tab_crapris(vr_idxcrapris).nrseqctr := vr_nrseqctr;
          vr_tab_crapris(vr_idxcrapris).dtinictr := rw_crapris.dtinictr;
          vr_tab_crapris(vr_idxcrapris).cdorigem := rw_crapris.cdorigem;
          vr_tab_crapris(vr_idxcrapris).cdagenci := rw_crapris.cdagenci;
          vr_tab_crapris(vr_idxcrapris).innivori := rw_crapris.innivori;
          vr_tab_crapris(vr_idxcrapris).cdcooper := rw_crapris.cdcooper;
          vr_tab_crapris(vr_idxcrapris).vlprjm60 := rw_crapris.vlprjm60;
          vr_tab_crapris(vr_idxcrapris).dtdrisco := rw_crapris.dtdrisco;
          vr_tab_crapris(vr_idxcrapris).qtdriclq := rw_crapris.qtdriclq;
          vr_tab_crapris(vr_idxcrapris).nrdgrupo := rw_crapris.nrdgrupo;
          vr_tab_crapris(vr_idxcrapris).vljura60 := rw_crapris.vljura60;
          vr_tab_crapris(vr_idxcrapris).inindris := rw_crapris.inindris;
          vr_tab_crapris(vr_idxcrapris).cdinfadi := vr_cdinfadi;
          vr_tab_crapris(vr_idxcrapris).flgindiv := rw_crapris.flgindiv;
          vr_tab_crapris(vr_idxcrapris).dtprxpar := rw_crapris.dtprxpar;
          vr_tab_crapris(vr_idxcrapris).vlprxpar := rw_crapris.vlprxpar;
          vr_tab_crapris(vr_idxcrapris).qtparcel := rw_crapris.qtparcel;
          vr_tab_crapris(vr_idxcrapris).dtvencop := rw_crapris.dtvencop;
          vr_tab_crapris(vr_idxcrapris).dsinfaux := rw_crapris.dsinfaux;
          vr_tab_crapris(vr_idxcrapris).nrctrnov := rw_crapris.nrctrnov;
        END IF;
      END LOOP;

      -- Converte a pl/table para um indice numerico e sequencial
      vr_idxcrapris := vr_tab_crapris.first;
      WHILE vr_idxcrapris IS NOT NULL LOOP
        vr_idxcrapris_n := vr_idxcrapris_n + 1;
        vr_tab_crapris_n(vr_idxcrapris_n) := vr_tab_crapris(vr_idxcrapris);
        vr_idxcrapris := vr_tab_crapris.next(vr_idxcrapris);
      END LOOP;

      -- Gravar todos os registros da PL Table que coletou os dados
      BEGIN
        FORALL idx IN vr_tab_crapris_n.FIRST..vr_tab_crapris_n.LAST SAVE EXCEPTIONS
          INSERT INTO crapris(nrdconta
                             ,dtrefere
                             ,innivris
                             ,qtdiaatr
                             ,vldivida
                             ,vlvec180
                             ,vlvec360
                             ,vlvec999
                             ,vldiv060
                             ,vldiv180
                             ,vldiv360
                             ,vldiv999
                             ,vlprjano
                             ,vlprjaan
                             ,inpessoa
                             ,nrcpfcgc
                             ,vlprjant
                             ,inddocto
                             ,cdmodali
                             ,nrctremp
                             ,nrseqctr
                             ,dtinictr
                             ,cdorigem
                             ,cdagenci
                             ,innivori
                             ,cdcooper
                             ,vlprjm60
                             ,dtdrisco
                             ,qtdriclq
                             ,nrdgrupo
                             ,vljura60
                             ,inindris
                             ,cdinfadi
                             ,flgindiv
                             ,nrctrnov
                             ,dtprxpar
                             ,vlprxpar
                             ,qtparcel
                             ,dtvencop
                             ,dsinfaux)
            VALUES(vr_tab_crapris_n(idx).nrdconta
                  ,vr_tab_crapris_n(idx).dtrefere
                  ,vr_tab_crapris_n(idx).innivris
                  ,vr_tab_crapris_n(idx).qtdiaatr
                  ,vr_tab_crapris_n(idx).vldivida
                  ,vr_tab_crapris_n(idx).vlvec180
                  ,vr_tab_crapris_n(idx).vlvec360
                  ,vr_tab_crapris_n(idx).vlvec999
                  ,vr_tab_crapris_n(idx).vldiv060
                  ,vr_tab_crapris_n(idx).vldiv180
                  ,vr_tab_crapris_n(idx).vldiv360
                  ,vr_tab_crapris_n(idx).vldiv999
                  ,vr_tab_crapris_n(idx).vlprjano
                  ,vr_tab_crapris_n(idx).vlprjaan
                  ,vr_tab_crapris_n(idx).inpessoa
                  ,vr_tab_crapris_n(idx).nrcpfcgc
                  ,vr_tab_crapris_n(idx).vlprjant
                  ,vr_tab_crapris_n(idx).inddocto
                  ,vr_tab_crapris_n(idx).cdmodali
                  ,vr_tab_crapris_n(idx).nrctremp
                  ,vr_tab_crapris_n(idx).nrseqctr
                  ,vr_tab_crapris_n(idx).dtinictr
                  ,vr_tab_crapris_n(idx).cdorigem
                  ,vr_tab_crapris_n(idx).cdagenci
                  ,vr_tab_crapris_n(idx).innivori
                  ,vr_tab_crapris_n(idx).cdcooper
                  ,vr_tab_crapris_n(idx).vlprjm60
                  ,vr_tab_crapris_n(idx).dtdrisco
                  ,vr_tab_crapris_n(idx).qtdriclq
                  ,vr_tab_crapris_n(idx).nrdgrupo
                  ,vr_tab_crapris_n(idx).vljura60
                  ,vr_tab_crapris_n(idx).inindris
                  ,vr_tab_crapris_n(idx).cdinfadi
                  ,vr_tab_crapris_n(idx).flgindiv
                  ,vr_tab_crapris_n(idx).nrctrnov
                  ,vr_tab_crapris_n(idx).dtprxpar
                  ,vr_tab_crapris_n(idx).vlprxpar
                  ,vr_tab_crapris_n(idx).qtparcel
                  ,vr_tab_crapris_n(idx).dtvencop
                  ,vr_tab_crapris_n(idx).dsinfaux);
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          pr_des_erro := 'Erro ao inserir na tabela crapris. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));

          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em pc_cria_saida_operacao: ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_cria_saida_operacao: ' || SQLERRM;
    END;
  END pc_cria_saida_operacao;

BEGIN

  DELETE crapris  cr
   WHERE cr.dtrefere >= to_date('30/06/2020','dd/mm/yyyy')
     AND cr.inddocto = 2
     AND cr.cdmodali = 1513
     AND cr.cdinfadi = '0399';
  COMMIT;

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

  -- Carrega as tabelas de contas transferidas da Viacredi e do AltoVale e SCRCred
  FOR rw_crapcop IN cr_crapcop(0) LOOP

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

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

    -- Atribui data
    vr_dtrefere := TO_DATE('31/07/2020', 'DD/MM/YYYY');

    -- Executar procedimento de saída de operação
    pc_cria_saida_operacao(pr_cdcooper    => rw_crapcop.cdcooper
                          ,pr_dtrefere    => vr_dtrefere
                          ,pr_rw_crapdat  => rw_crapdat
                          ,pr_des_erro    => vr_dscritic);

    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    COMMIT;

  END LOOP;

  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  -- Salvar informações atualizadas
  COMMIT;
END;
0
6
vr_dtrefere
vr_dtultdma
rw_crapcop.cdcooper
vr_cdinfadi
vr_contareg
rw_crapris.nrdconta
