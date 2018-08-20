CREATE OR REPLACE PACKAGE CECRED.prvd0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : prvd0001
  --  Sistema  : Rotinas para informações de previdencia. Chamada pela SOA
  --  Sigla    : PRVD
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Correção dos valores de update (Cláudio - CIS Corporate)
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_manter_previdencia(pr_cdcooper IN NUMBER, -- Codigo da cooperativa
                                  pr_nrdconta IN crapass.nrdconta%type,
                                  pr_cdoperad IN crapope.cdoperad%type,
                                  pr_insituac IN INTEGER, -- 0->Cancelar, 1->Ativar 
                                  pr_dtsituac IN DATE,
                                  pr_cdcritic OUT INTEGER,
                                  pr_dscritic OUT VARCHAR2);
END prvd0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.prvd0001 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : prvd0001
  --  Sistema  : Rotinas para informações de previdencia. Chamada pela SOA
  --  Sigla    : PRVD
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Correção dos valores de update (Cláudio - CIS Corporate)
  --  14/08/2018 - Validação do campo pr_insituac. PRJ468 (Lombardi)
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_manter_previdencia(pr_cdcooper IN NUMBER, -- Codigo da cooperativa
                                  pr_nrdconta IN crapass.nrdconta%type,
                                  pr_cdoperad IN crapope.cdoperad%type,
                                  pr_insituac IN INTEGER, -- 0->Cancelar, 1->Ativar 
                                  pr_dtsituac IN DATE,
                                  pr_cdcritic OUT INTEGER,
                                  pr_dscritic OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
  
    ---------------> CURSORES <-----------------
  
    --> Buscar cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT 1 FROM crapcop WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    --> Buscar associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
  BEGIN
    -- Verifica se a cooperativa e valida
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
  
    IF cr_crapcop%NOTFOUND THEN
      vr_cdcritic := 794;
      -- Fecha cursor
      CLOSE cr_crapcop;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapcop;
  
    -- Verifica se a conta e valida
    OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
  
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Conta/Dig inválido';
      -- vr_dscritic := NULL;
      -- Fecha cursor
      CLOSE cr_crapass;
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapass;
    
    IF pr_insituac IS NULL     OR 
       pr_insituac NOT IN(0,1) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Situação inválida';
      RAISE vr_exc_erro;
    END IF;
  
    -- Efetua a inclusao do conta (previdencia)
    BEGIN
      INSERT INTO tbprevidencia_conta
        (cdcooper,
         nrdconta,
         dtmvtolt,
         dtadesao,
         cdopeade,
         dtcancel,
         cdopecan,
         insituac)
      VALUES
        (pr_cdcooper,
         pr_nrdconta,
         SYSDATE,
         DECODE(pr_insituac, 0, NULL, pr_dtsituac),
         DECODE(pr_insituac, 0, NULL, pr_cdoperad),
         DECODE(pr_insituac, 1, NULL, pr_dtsituac),
         DECODE(pr_insituac, 1, NULL, pr_cdoperad),
         pr_insituac);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao 
        BEGIN
          UPDATE tbprevidencia_conta
             SET dtmvtolt = SYSDATE,
                 dtadesao = DECODE(pr_insituac, 1, pr_dtsituac, dtadesao),
                 cdopeade = DECODE(pr_insituac, 1, pr_cdoperad, cdopeade),
                 dtcancel = DECODE(pr_insituac, 0, pr_dtsituac, dtcancel),
                 cdopecan = DECODE(pr_insituac, 0, pr_cdoperad, cdopecan),
                 insituac = pr_insituac
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tbprevidencia_conta: ' ||
                           SQLERRM;
            RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbprevidencia_conta: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_manter_previdencia: ' ||
                     SQLERRM;
  END;
END prvd0001;
/
