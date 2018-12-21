CREATE OR REPLACE PACKAGE CECRED.CXON0053 IS

PROCEDURE pc_ver_necessidade_senha(pr_cdcooper             IN tbcc_provisao_especie.cdcooper%TYPE       --> Codigo cooperativa
                                  ,pr_cdagenci_saque       IN tbcc_provisao_especie.cdagenci_saque%TYPE --> PA aonde será realizado o saque
                                  ,pr_nrcpfcgc             IN tbcc_provisao_especie.nrcpfcgc%TYPE       --> CPF CNPJ
                                  ,pr_vlsaque              IN tbcc_provisao_especie.vlsaque%TYPE        --> Valor do saque
                                  ,pr_dhprevisao_operacao OUT VARCHAR2                                  --> Data e hora prevista para saque/pagamento em especie
                                  ,pr_nrdconta_provisao   OUT tbcc_provisao_especie.nrdconta%TYPE       --> Numero da conta da provisao
                                  ,pr_inexige_senha       OUT VARCHAR2                                  --> Indicador de necessidade de senha
                                  ,pr_cdcritic            OUT PLS_INTEGER                               --> Código da crítica
                                  ,pr_dscritic            OUT VARCHAR2);                                --> Descrição da crítica

PROCEDURE pc_realiza_provisao(pr_cdcooper             IN tbcc_provisao_especie.cdcooper%TYPE            --> Codigo cooperativa
                             ,pr_cdagenci_saque       IN tbcc_provisao_especie.cdagenci_saque%TYPE      --> PA aonde será realizado o saque
                             ,pr_dhprevisao_operacao  IN VARCHAR2                                       --> Data e Hora da provisão
                             ,pr_nrcpfcgc             IN tbcc_provisao_especie.nrcpfcgc%TYPE            --> CPF CNPJ
                             ,pr_nrdconta             IN tbcc_provisao_especie.nrdconta%TYPE            --> Número da conta da provisão
                             ,pr_nrdconta_provisao    IN tbcc_provisao_especie.nrdconta%TYPE            --> Número da conta da provisão
                             ,pr_vloperacao           IN tbcc_operacoes_diarias.vloperacao%TYPE         --> Valor da operação
                             ,pr_cdope_autorizador    IN crapope.cdoperad%TYPE                          --> Código do operador que autorizou a provisão
                             ,pr_cdagenci             IN NUMBER                     DEFAULT NULL        --> PA aonde foi feito o saque
                             ,pr_cdbccxlt             IN NUMBER                     DEFAULT NULL        --> Caixa aonde foi feito o saque
                             ,pr_cdcritic            OUT PLS_INTEGER                                    --> Código da crítica
                             ,pr_dscritic            OUT VARCHAR2);                                     --> Descrição da crítica

END CXON0053;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CXON0053 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : CXON0053
  --  Sistema  : Caixa On Line
  --  Autor    : Marcelo Telles Coelho (mouts)
  --  Data     : Junho - 2018.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela ROTINA53
  --
  --
  --  Alterações:
  ---------------------------------------------------------------------------

PROCEDURE pc_ver_necessidade_senha(pr_cdcooper             IN tbcc_provisao_especie.cdcooper%TYPE       --> Codigo cooperativa
                                  ,pr_cdagenci_saque       IN tbcc_provisao_especie.cdagenci_saque%TYPE --> PA aonde será realizado o saque
                                  ,pr_nrcpfcgc             IN tbcc_provisao_especie.nrcpfcgc%TYPE       --> CPF CNPJ
                                  ,pr_vlsaque              IN tbcc_provisao_especie.vlsaque%TYPE        --> Valor do saque
                                  ,pr_dhprevisao_operacao OUT VARCHAR2                                  --> Data e hora prevista para saque/pagamento em especie
                                  ,pr_nrdconta_provisao   OUT tbcc_provisao_especie.nrdconta%TYPE       --> Numero da conta da provisao
                                  ,pr_inexige_senha       OUT VARCHAR2                                  --> Indicador de necessidade de senha
                                  ,pr_cdcritic            OUT PLS_INTEGER                               --> Código da crítica
                                  ,pr_dscritic            OUT VARCHAR2) IS                              --> Erros do processo
    /* .............................................................................

        Programa: pc_ver_necessidade_senha
        Sistema : CECRED
        Sigla   :
        Autor   : Marcelo Telles Coelho
        Data    : Jun/17.                    Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Verificar a necessidade de autorização para atender ao somatório de saques em espécie efetuados no dia pelo cooperado na cooperativa.

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    -- Cursor generico de calendario
    CURSOR cr_parmon(pr_cdcooper IN crapope.cdcooper%TYPE) IS
      SELECT *
        FROM tbcc_monitoramento_parametro
       WHERE cdcooper = pr_cdcooper;
    rw_parmon cr_parmon%ROWTYPE;

    -- Buscar na tabela TBCC_OPERACOES_DIARIAS o total de saques realizados pelo CPF/CNPJ na cooperativa e no dia.
    CURSOR cr_total_saque_dia(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(vloperacao),0) vltot_saque_dia
        FROM tbcc_operacoes_diarias
       WHERE cdcooper   = pr_cdcooper
         AND cdoperacao = 22 -- SAQUE EM ESPECIE
         AND nrdconta  IN (SELECT nrdconta
                             FROM crapass
                            WHERE nrcpfcgc=pr_nrcpfcgc
                              AND cdcooper=pr_cdcooper)
         AND dtoperacao = pr_dtmvtolt;
    rw_total_saque_dia cr_total_saque_dia%ROWTYPE;

    -- Buscar na tabela TBCC_PROVISAO_ESPECIE uma provisão para atender a soma de saques no dia
    CURSOR cr_provisao(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE
                      ,pr_nrcpfcgc        IN tbcc_provisao_especie.nrcpfcgc%TYPE
                      ,pr_cdagenci_saque  IN tbcc_provisao_especie.cdagenci_saque%TYPE
                      ,pr_vlsaque         IN tbcc_provisao_especie.vlsaque%TYPE
                      ,pr_vltot_saque_dia IN tbcc_provisao_especie.vlsaque%TYPE
                      ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE) IS
      SELECT *
        FROM tbcc_provisao_especie
       WHERE cdcooper       = pr_cdcooper
         -- AND cdagenci_saque = pr_cdagenci_saque -- Pode acontecer em qualquer PA
         AND nrcpfcgc       = pr_nrcpfcgc
         -- AND incheque       = 1 -- SAQUE EM CHEQUE
         AND insit_provisao = 1 -- PENDENTE
         AND vlsaque       >= pr_vlsaque
         AND TRUNC(dhprevisao_operacao) = pr_dtmvtolt
         ORDER BY dhcadastro || vlsaque;
    rw_provisao cr_provisao%ROWTYPE;

    -- Buscar na tabela CRAPDAT as datas da cooperativa
    CURSOR cr_crapdat(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE) IS
      SELECT *
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis de trabalho
    vr_dhprevisao_operacao tbcc_provisao_especie.dhprevisao_operacao%TYPE;
    vr_nrdconta            tbcc_provisao_especie.nrdconta%TYPE;
    vr_inexige_senha       VARCHAR2(01);

  BEGIN -- Inicio pc_ver_necessidade_senha

    -- Leitura CRAPDAT da cooperativa
    OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapdat
      INTO rw_crapdat;
    IF cr_crapdat%NOTFOUND THEN
      CLOSE cr_crapdat;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros CRAPDAT da cooperativa não encontrado!';
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapdat;

    -- Leitura parametros PLD da cooperativa
    OPEN cr_parmon(pr_cdcooper => pr_cdcooper);
     FETCH cr_parmon
      INTO rw_parmon;
    IF cr_parmon%NOTFOUND THEN
      CLOSE cr_parmon;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros PLD da cooperativa não encontrado!';
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_parmon;

    pr_dscritic            := NULL;

    -- Buscar na tabela TBCC_OPERACOES_DIARIAS o total de saques realizados pelo CPF/CNPJ na cooperativa e no dia.
    OPEN cr_total_saque_dia(pr_cdcooper => pr_cdcooper
                           ,pr_nrcpfcgc => pr_nrcpfcgc
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
     FETCH cr_total_saque_dia
      INTO rw_total_saque_dia;
    IF cr_total_saque_dia%NOTFOUND THEN
      rw_total_saque_dia.vltot_saque_dia := 0;
    END IF;
    -- Fechar o cursor
    CLOSE cr_total_saque_dia;

    pr_dhprevisao_operacao := NULL;
    pr_nrdconta_provisao   := NULL;
    pr_inexige_senha       := 'N';

    -- Buscar na tabela TBCC_PROVISAO_ESPECIE uma provisão para atender a soma de saques no dia
    OPEN cr_provisao(pr_cdcooper        => pr_cdcooper
                    ,pr_nrcpfcgc        => pr_nrcpfcgc
                    ,pr_cdagenci_saque  => pr_cdagenci_saque
                    ,pr_vlsaque         => pr_vlsaque
                    ,pr_vltot_saque_dia => rw_total_saque_dia.vltot_saque_dia
                    ,pr_dtmvtolt        => rw_crapdat.dtmvtolt);
     FETCH cr_provisao
      INTO rw_provisao;
    IF cr_provisao%FOUND THEN
      -- Se encontrar uma provisão devolve para o chamador e
      -- Não necessita de senha autorização
      pr_dhprevisao_operacao := TO_CHAR(rw_provisao.dhprevisao_operacao,'YYYYMMDD HH24MISS');
      pr_nrdconta_provisao   := rw_provisao.nrdconta;
      pr_inexige_senha       := 'N';
    ELSE
      -- Se não encontrar uma provisão devolve embranco para o chamador
      pr_dhprevisao_operacao := NULL;
      pr_nrdconta_provisao   := NULL;
      --
      IF (rw_total_saque_dia.vltot_saque_dia + pr_vlsaque) >= rw_parmon.vlprovisao_saque THEN
        -- Se o valor do saque + o saque do dia for maior/igual ao parametrizado
        -- Necessita de senha autorização
        pr_inexige_senha     := 'S';
      ELSE
        -- Se o valor do saque + o saque do dia não for maior/igual ao parametrizado
        -- Não Necessita de senha autorização
        pr_inexige_senha     := 'N';
      END IF;
    END IF;
    -- Fechar o cursor
    CLOSE cr_provisao;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CXON0053,pc_ver_necessidade_senha: ' || SQLERRM;
END pc_ver_necessidade_senha;

PROCEDURE pc_realiza_provisao(pr_cdcooper             IN tbcc_provisao_especie.cdcooper%TYPE            --> Codigo cooperativa
                             ,pr_cdagenci_saque       IN tbcc_provisao_especie.cdagenci_saque%TYPE      --> PA aonde será realizado o saque
                             ,pr_dhprevisao_operacao  IN VARCHAR2                                       --> Data e Hora da provisão
                             ,pr_nrcpfcgc             IN tbcc_provisao_especie.nrcpfcgc%TYPE            --> CPF CNPJ
                             ,pr_nrdconta             IN tbcc_provisao_especie.nrdconta%TYPE            --> Número da conta do pagamento
                             ,pr_nrdconta_provisao    IN tbcc_provisao_especie.nrdconta%TYPE            --> Número da conta da provisão
                             ,pr_vloperacao           IN tbcc_operacoes_diarias.vloperacao%TYPE         --> Valor da operação
                             ,pr_cdope_autorizador    IN crapope.cdoperad%TYPE                          --> Código do operador que autorizou a provisão
                             ,pr_cdagenci             IN NUMBER                     DEFAULT NULL        --> PA aonde foi feito o saque
                             ,pr_cdbccxlt             IN NUMBER                     DEFAULT NULL        --> Caixa aonde foi feito o saque
                             ,pr_cdcritic            OUT PLS_INTEGER                                    --> Código da crítica
                             ,pr_dscritic            OUT VARCHAR2) IS                                   --> Erros do processo

    /* .............................................................................

        Programa: pc_realiza_provisao
        Sistema : CECRED
        Sigla   :
        Autor   : Marcelo Telles Coelho
        Data    : Jun/17.                    Ultima atualizacao: 14/12/2018 

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Marcar a provisão como REALIZADA - Saque efetuado.

        Observacao: -----

        Alteracoes: 14/12/2018 - Andreatta - Mouts : Ajustar para utilizar fn_Sequence e 
                    não mais max na busca no nrsequen para tbcc_operacoes_diarias
                    
    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis de trabalho

    -- Cursor generico de calendario
    CURSOR cr_parmon(pr_cdcooper IN crapope.cdcooper%TYPE) IS
      SELECT *
        FROM tbcc_monitoramento_parametro
       WHERE cdcooper = pr_cdcooper;
    rw_parmon cr_parmon%ROWTYPE;

    -- Buscar na tabela TBCC_OPERACOES_DIARIAS o total de saques realizados pelo CPF/CNPJ na cooperativa e no dia.
    CURSOR cr_total_saque_dia(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(vloperacao),0) vltot_saque_dia
        FROM tbcc_operacoes_diarias
       WHERE cdcooper   = pr_cdcooper
         AND cdoperacao = 22 -- SAQUE EM ESPECIE
         AND nrdconta  IN (SELECT nrdconta
                             FROM crapass
                            WHERE nrcpfcgc=pr_nrcpfcgc
                              AND cdcooper=pr_cdcooper)
         AND dtoperacao = pr_dtmvtolt;
    rw_total_saque_dia cr_total_saque_dia%ROWTYPE;

    -- Buscar na tabela CRAPDAT as datas da cooperativa
    CURSOR cr_crapdat(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE) IS
      SELECT *
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%ROWTYPE;

  BEGIN -- Inicio pc_realiza_provisao
    
  	-- Leitura CRAPDAT da cooperativa
    OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapdat
      INTO rw_crapdat;
    IF cr_crapdat%NOTFOUND THEN
      CLOSE cr_crapdat;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros CRAPDAT da cooperativa não encontrado!';
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapdat;

    IF  pr_cdcooper                     IS NOT NULL
    AND pr_cdagenci_saque               IS NOT NULL
    AND pr_nrcpfcgc                     IS NOT NULL
    AND pr_nrdconta_provisao            IS NOT NULL
    AND NVL(pr_dhprevisao_operacao,' ') <> ' '
    THEN
      -- Buscar na tabela TBCC_OPERACOES_DIARIAS o total de saques realizados pelo CPF/CNPJ na cooperativa e no dia.
      OPEN cr_total_saque_dia(pr_cdcooper => pr_cdcooper
                             ,pr_nrcpfcgc => pr_nrcpfcgc
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
       FETCH cr_total_saque_dia
        INTO rw_total_saque_dia;
      IF cr_total_saque_dia%NOTFOUND THEN
        rw_total_saque_dia.vltot_saque_dia := 0;
      END IF;
      -- Fechar o cursor
      CLOSE cr_total_saque_dia;

      BEGIN
        UPDATE tbcc_provisao_especie a
           SET insit_provisao     = 2 -- REALIZADA
              ,vlpagamento        = pr_vloperacao
              ,dhoperacao         = SYSDATE
              ,cdoperad_alteracao = USER
              ,dhalteracao        = SYSDATE
         WHERE cdcooper            = pr_cdcooper
           -- AND cdagenci_saque      = pr_cdagenci_saque -- Pode acontecer em qualquer PA
           AND nrcpfcgc            = pr_nrcpfcgc
           AND nrdconta            = pr_nrdconta_provisao
           AND dhprevisao_operacao = TO_DATE(pr_dhprevisao_operacao,'YYYYMMDD HH24MISS')
           -- AND incheque            = 1
           AND vlsaque            >= pr_vloperacao
           AND dhcadastro||vlsaque = (SELECT min(aa.dhcadastro)|| min(aa.vlsaque)
                                        FROM tbcc_provisao_especie aa
                                       WHERE aa.cdcooper            = a.cdcooper
                                         AND aa.cdagenci_saque      = a.cdagenci_saque
                                         AND aa.nrcpfcgc            = a.nrcpfcgc
                                         AND aa.nrdconta            = a.nrdconta
                                         AND aa.vlsaque            >= pr_vloperacao
                                         AND aa.dhprevisao_operacao = a.dhprevisao_operacao
                                         -- AND aa.incheque            = a.incheque
                                         AND aa.insit_provisao      = 1)
           ;
      EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao marcar a provisão - '||sqlerrm;
        RAISE vr_exc_saida;
      END;
    END IF;
    
    --
    BEGIN 
          
      INSERT INTO tbcc_operacoes_diarias
             (cdcooper
             ,nrdconta
             ,cdoperacao
             ,dtoperacao
             ,nrsequen
             ,flgisencao_tarifa
             ,vloperacao)
      VALUES (pr_cdcooper
             ,pr_nrdconta
             ,22
             ,rw_crapdat.dtmvtolt
             ,fn_sequence('TBCC_OPERACOES_DIARIAS','NRSEQUEN',to_char(pr_cdcooper)||';'||to_char(pr_nrdconta)||';22;'||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr'))
             ,0
             ,pr_vloperacao);
    EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao incluir TBCC_OPERACOES_DIARIAS - '||sqlerrm;
      RAISE vr_exc_saida;
    END;
    --
    -- Pode ser removido, o log ja é gerado na proc valida-permissao-provisao da b1crap54
    /*IF pr_cdope_autorizador IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'provisao_especie.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' --> PA: '|| pr_cdagenci ||' - '||
                                                    'Caixa: '|| pr_cdbccxlt ||' - '||
                                                    'Operador '|| pr_cdope_autorizador ||' - '||
                                                    'Efetuou a liberação do saque sem provisão de R$ '||TO_CHAR(pr_vloperacao,'9999999990.00') ||' '||
                                                    'da conta '||gene0002.fn_mask_conta(pr_nrdconta) || '.  [PL/SQL]');
    END IF;*/

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CXON0053.pc_realiza_provisao: ' || SQLERRM;
END pc_realiza_provisao;

END CXON0053;
/
