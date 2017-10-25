CREATE OR REPLACE PROCEDURE CECRED.pc_crps704 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada
  /* .............................................................................

     Programa: pc_crps704 (Fontes/crps704.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Março/2016                     Ultima atualizacao: 08/11/2016

     Dados referentes ao programa:

     Frequencia: Executado via Job - Primeira segunda do mês
     Objetivo  : Enviar cancelamento das propostas que serão excluidas pelo proceso de limpeza

     Alteracoes: 

     08/11/2016 - #551196 padronizar os nomes do job por produto e monitorar a sua 
                  execução em log (Carlos)

     13/09/2017 - Colocado Log no padrão
                  Tratado Others
                  Retirada rotina pc_controla_log_batch, pois não gravará o arquivo, apenas tabela de ocorrencia
                  (Ana - Envolti - Chamado 731974)
                            
  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS704';
  vr_cdcooper   NUMBER  := 3;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  --Chamado 731974
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;      
  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = nvl(NULLIF(pr_cdcooper,0),cop.cdcooper) --> buscar todas as coops se for coop 0
       AND cop.flgativo = 1
     ORDER BY cop.cdcooper;

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg 
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;
  
  -- Cadastro auxiliar dos emprestimos com movimento a mais de 4 meses
  -- que não estejam cadastrados na crapepr
  CURSOR cr_crawepr ( pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN DATE) IS
    SELECT crawepr.cdcooper 
          ,crawepr.nrdconta
          ,crawepr.nrctremp
          ,crawepr.cdagenci
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.dtenvest IS NOT NULL
       AND crawepr.dtmvtolt < pr_dtmvtolt --data do movimento
       AND NOT EXISTS ( SELECT 1
                          FROM crapepr
                         WHERE crapepr.cdcooper = crawepr.cdcooper
                           AND crapepr.nrdconta = crawepr.nrdconta
                           AND crapepr.nrctremp = crawepr.nrctremp)
     ORDER BY crawepr.cdcooper,
              crawepr.nrdconta,
              crawepr.nrctremp;

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  vr_qtmeslim     INTEGER := 0;
  vr_dtlimepr     DATE;
  vr_qtderros     NUMBER  := 0;
  vr_qtsucess     NUMBER  := 0;
  
  -- Nome do arquivo de limpeza
  vr_nmarqlmp VARCHAR2(500) := 'arquivos/.limpezaok';
  -- Nome do diretorio da cooperativa
  vr_nmdireto VARCHAR2(500);
  
  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBEPR_CANCELA_PROPOSTA';
  vr_flgerlog    BOOLEAN := FALSE;

BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  
  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;
  
  -- Verificar se é para rodar para todas as cooperativas
  IF pr_cdcooper = 0 THEN
    vr_cdcooper := 3;
  ELSE
    vr_cdcooper := pr_cdcooper;
  END IF;

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
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
  
  --> verificar se é uma segunda-feira
  IF to_char(rw_crapdat.dtmvtolt,'D') <> 2 THEN  
    vr_dscritic := 'Processo não pode ser executado neste dia.';
    RAISE vr_exc_saida;  
  END IF;  

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  --> Buscar parametro que define quantidade de meses para limpeza
  vr_qtmeslim := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => vr_cdcooper, 
                                           pr_cdacesso => 'QTD_MES_LIMPEZA_WEPR');

  IF nvl(vr_qtmeslim,0) = 0 THEN
    vr_dscritic := 'Quantidade de meses para limpeza nao encontrado.';
    RAISE vr_exc_saida;
  ELSE
    -- primeiro dia de 4 meses atras (120 dias)
    vr_dtlimepr := TRUNC(add_months(rw_crapdat.dtmvtolt,vr_qtmeslim*-1),'MONTH');                                      
  END IF;

  FOR rw_crapcop IN cr_crapcop LOOP 
  
    -- Buscar diretorio da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nmsubdir => '');

    /* Verificar se arquivo .limpezaok esta criado, significa que processo ja rodou no mês, 
       crps000 faz exclusao do arquivo no final do mês  */

    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto||'/'||vr_nmarqlmp) THEN
    
      vr_dscritic := to_char(rw_crapcop.cdcooper,'fm00')||' - Processo de limpeza ja rodou este mes para esta cooperativa.';  

      -- Colocado Log no padrão - 13/09/2017 - Chamado 731974
      vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                             ' --> ' || 'ERRO: ' || vr_dscritic;

      -- Envio centralizado de log de erro
      cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                             pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                             pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                             pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                             pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                             pr_nmarqlog      => NULL,
                             pr_idprglog      => vr_idprglog);

      vr_dscritic := NULL;                                    
      continue; --> Buscar proxima cooperativa
    END IF;

    -->  Leitura do crawepr a ser enviado o cancelamento
    FOR rw_crawepr IN cr_crawepr( pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_dtmvtolt => vr_dtlimepr) LOOP

      vr_cdcritic := 0;
      vr_dscritic := NULL;
      --> Enviar o cancelamento da proposta para a esteira
      ESTE0001.pc_cancelar_proposta_est ( pr_cdcooper  => rw_crawepr.cdcooper,  --> Codigo da cooperativa
                                          pr_cdagenci  => rw_crawepr.cdagenci,  --> Codigo da agencia                                          
                                          pr_cdoperad  => 1,                    --> codigo do operador
                                          pr_cdorigem  => 9,-- Esteira          --> Origem da operacao
                                          pr_nrdconta  => rw_crawepr.nrdconta,  --> Numero da conta do cooperado
                                          pr_nrctremp  => rw_crawepr.nrctremp,  --> Numero da proposta de emprestimo atual/antigo                                      
                                          pr_dtmvtolt  => rw_crapdat.dtmvtolt,  --> Data do movimento                                      
                                          ---- OUT ----                           
                                          pr_cdcritic  => vr_cdcritic,          --> Codigo da critica
                                          pr_dscritic  => vr_dscritic);         --> Descricao da critica

      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Colocado Log no padrão - 13/09/2017 - Chamado 731974
        vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                               ' --> ' || 'ERRO: '|| vr_dscritic    ||
                               ' - cdcooper:'|| rw_crawepr.cdcooper ||
                               ' ,cdagenci:'||rw_crawepr.cdagenci   ||
                               ' ,nrdconta:'|| rw_crawepr.nrdconta  ||
                               ' ,nrctremp:'|| rw_crawepr.nrctremp  ||
                               ' ,dtmvtolt:'|| rw_crapdat.dtmvtolt;

        -- Envio centralizado de log de erro
        cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                               pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                               pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                               pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                               pr_nmarqlog      => NULL,
                               pr_idprglog      => vr_idprglog);

        vr_qtderros := vr_qtderros + 1; 
        continue; --> buscar proximo
      END IF;   
      
      vr_qtsucess := vr_qtsucess + 1;
      
    END LOOP; --> Fim Loop crawepr
  END LOOP;
  
  --Seta o módulo novamente - Chamado 731974
  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra
                        ,pr_action => null);


  --cancelamentos para Esteira,
  -- Gerar log
  IF (vr_qtderros + vr_qtsucess) > 0 THEN
    vr_dscritic := 'Foram enviados '|| (vr_qtderros + vr_qtsucess)||
                   ' cancelamentos para Esteira, '||
                   vr_qtsucess ||' com sucesso e '||
                   vr_qtderros ||' com erro.';
  ELSE
    vr_dscritic := 'Nenhum cancelamento de proposta enviado.';
  END IF;               

  -- Colocado Log no padrão - 13/09/2017 - Chamado 731974
  vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                         ' --> ' || 'ERRO: '|| vr_dscritic;
  
  -- Envio centralizado de log de erro
  cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                         pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                         pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                         pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                         pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                         pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                         pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                         pr_nmarqlog      => NULL,
                         pr_idprglog      => vr_idprglog);

  vr_dscritic := NULL;
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  -- Salvar informações atualizadas
  COMMIT;

EXCEPTION  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Colocado Log no padrão - 13/09/2017 - Chamado 731974
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' || vr_dscritic;

    -- Envio centralizado de log de erro
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL,
                           pr_idprglog      => vr_idprglog);

    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- No caso de erro de programa gravar tabela especifica de log - 13/09/2017 - Chamado 731974        
    CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);       

    -- Efetuar retorno do erro não tratado
    vr_dscritic := sqlerrm;

    --Colocado Log no padrão - 13/09/2017 - Chamado 731974
    vr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || 
                           ' --> ' || 'ERRO: ' || vr_dscritic;
    
    -- Envio centralizado de log de erro
    cecred.pc_log_programa(pr_dstiplog      => 'E',          -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma    => vr_cdprogra,  -- tbgen_prglog
                           pr_cdcooper      => vr_cdcooper,  -- tbgen_prglog
                           pr_tpexecucao    => 1,            -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia  => 1,            -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                           pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                           pr_dsmensagem    => vr_dscritic,  -- tbgen_prglog_ocorrencia
                           pr_flgsucesso    => 1,            -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                           pr_nmarqlog      => NULL,
                           pr_idprglog      => vr_idprglog);
    -- Efetuar rollback
    ROLLBACK;                             

END pc_crps704;
/
