CREATE OR REPLACE PROCEDURE CECRED.pc_crps521(pr_cdcooper IN crapcop.cdcooper%TYPE --> Coop conectada
                                      ,pr_flgresta IN PLS_INTEGER --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS
  /* ............................................................................
     Programa: c_crps521 (Antigo Fontes/crps521.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Gabriel
     Data    : Novembro/2008                       Ultima Atualizacao : 14/06/2016
  
     Dados referente ao programa:
  
     Frequencia: Diario (Batch).
     Objetivo  : Mudar o status de todos os seguros autos vencidos.
  
     Alteracoes: 05/03/2015 - Conversão Progress >> Oracle PL-Sql (Dionathan)
  
                 14/06/2016 - P187.2 - Sicredi Seguros (Guilherme/SUPERO)

  ............................................................................. */
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  ------------------------------- REGISTROS -------------------------------
  rw_crapcop cr_crapcop%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS521';
  -- Data de movimento
  vr_dtmvtolt DATE;

  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra);

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
  END IF;

  -- Apenas fechar o cursor
  CLOSE cr_crapcop;

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO btch0001.rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Guarda a data
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  END IF;

  -- Fechar o cursor
  CLOSE btch0001.cr_crapdat;

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper, pr_flgbatch => 1, pr_cdprogra => vr_cdprogra, pr_infimsol => pr_infimsol, pr_cdcritic => vr_cdcritic);

  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  BEGIN
    -- Executa update que altera o status de todos os seguros autos vencidos.
    UPDATE crapseg
       SET crapseg.cdsitseg = 4 -- Vencido
     WHERE crapseg.cdcooper = pr_cdcooper
       AND crapseg.tpseguro = 2 -- Auto
       AND crapseg.flgconve = 1
       AND crapseg.cdsitseg IN (1, 3) -- Novo, Renovado
       AND crapseg.dtfimvig <= vr_dtmvtolt;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := ' Erro ao atualizar a tabela CRAPSEG: ' || SQLERRM;
      RAISE vr_exc_saida;
  END;


  -- NOVO SEGURO AUTO - SICREDI/SIS
  BEGIN
    -- Executa update que altera o status de todos os seguros autos vencidos.
    UPDATE tbseg_contratos seg
       SET seg.indsituacao = 'V' -- Atualiza para Vencido
     WHERE seg.cdcooper    = pr_cdcooper
       AND seg.tpseguro    = 'A' -- Auto
       AND seg.indsituacao = 'A' -- Ativo
       AND seg.nrapolice   > 0   -- Se for 0, é proposta, e nao precisa atualizar
       AND seg.dttermino_vigencia <= vr_dtmvtolt;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := ' Erro ao atualizar a tabela TBSEG_CONTRATOS: ' || SQLERRM;
      RAISE vr_exc_saida;
  END;


  -- Se retornar crítica
  IF vr_dscritic IS NOT NULL THEN
    -- Saida
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper, pr_cdprogra => vr_cdprogra, pr_infimsol => pr_infimsol, pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps521;
/

